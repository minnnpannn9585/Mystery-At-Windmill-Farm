using System;
using System.IO;
using System.Reflection;
using EggRescue;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;

// Exercises real menu transitions without writing a save or modifying scene assets.
[InitializeOnLoad]
public static class MenuTransitionRegression
{
    const string Key = "EggRescue.MenuTransitionRegression.";
    const string LogPath = "Logs/menu-transition-regression.log";
    const string GamePath = "Assets/Scenes/Mechanics_Code.unity";
    static int stage;
    static int nextFrame;
    static bool running;
    static double deadline;
    static AudioSource music;
    static AudioClip clip;
    static float musicTime;
    static double musicDsp;
    static SphericalHarmonicsL2 baselineProbe;
    static Material baselineSky;
    static Color baselineSunColor;
    static float baselineSunIntensity;
    static Vector3 baselineSunDirection;

    static MenuTransitionRegression()
    {
        EditorApplication.playModeStateChanged += OnPlayModeState;
        EditorApplication.update += Tick;
    }

    [MenuItem("Tools/Egg Rescue/Validate Menu Transitions")]
    public static void Run()
    {
        if (EditorApplication.isPlayingOrWillChangePlaymode || EditorApplication.isCompiling)
            throw new InvalidOperationException("Run after compilation, outside Play Mode.");
        var scene = SceneManager.GetActiveScene();
        if (SceneManager.sceneCount != 1 || scene.isDirty || string.IsNullOrEmpty(scene.path))
            throw new InvalidOperationException("Run with one saved, clean scene open so it can be restored safely.");
        SessionState.SetString(Key + "scene", scene.path);
        SessionState.SetString(Key + "startScene", AssetDatabase.GetAssetPath(EditorSceneManager.playModeStartScene));
        SessionState.SetString(Key + "save", SaveFingerprint());
        SessionState.SetBool(Key + "active", true);
        Directory.CreateDirectory("Logs");
        File.WriteAllText(LogPath, "Menu transition regression started. No save writes.\n");
        EditorSceneManager.playModeStartScene = null;
        EditorSceneManager.OpenScene(GamePath);
        GameSession.Pending = GameSession.Mode.NewGame;
        EditorApplication.isPlaying = true;
    }

    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    static void PrepareNewGame()
    {
        if (SessionState.GetBool(Key + "active", false))
            GameSession.Pending = GameSession.Mode.NewGame;
    }

    static void OnPlayModeState(PlayModeStateChange state)
    {
        if (!SessionState.GetBool(Key + "active", false)) return;
        if (state == PlayModeStateChange.EnteredPlayMode)
        {
            stage = 0;
            music = null;
            running = true;
            WaitForScene();
        }
        else if (state == PlayModeStateChange.EnteredEditMode)
        {
            running = false;
            SessionState.SetBool(Key + "active", false);
            var startPath = SessionState.GetString(Key + "startScene", "");
            EditorSceneManager.playModeStartScene = AssetDatabase.LoadAssetAtPath<SceneAsset>(startPath);
            EditorSceneManager.OpenScene(SessionState.GetString(Key + "scene", GamePath));
            if (SaveFingerprint() != SessionState.GetString(Key + "save", ""))
                Report("FAIL: Save file changed during validation.");
            Report("Original editor scene restored.");
        }
    }

    static void WaitForScene()
    {
        nextFrame = Time.frameCount + 90;
        deadline = EditorApplication.timeSinceStartup + 120;
    }

    static void Tick()
    {
        if (!running || !SessionState.GetBool(Key + "active", false) || !EditorApplication.isPlaying || stage < 0)
            return;
        try
        {
            Check(EditorApplication.timeSinceStartup < deadline, "Timed out waiting for rendered frames.");
            if (Time.frameCount < nextFrame) return;
            CheckMusic();
            if (stage == 0)
            {
                Check(SceneManager.GetActiveScene().name == GameSession.GameSceneName, "Direct gameplay scene loaded.");
                baselineProbe = RenderSettings.ambientProbe;
                baselineSky = RenderSettings.skybox;
                Check(RenderSettings.sun != null, "Gameplay sun exists.");
                baselineSunColor = RenderSettings.sun.color;
                baselineSunIntensity = RenderSettings.sun.intensity;
                baselineSunDirection = RenderSettings.sun.transform.forward;
                Check(ProbeEnergy(baselineProbe) > 0.01f, "Direct gameplay has nonzero sky ambient lighting.");
                Report("PASS: Direct gameplay baseline and BGM.");
                Invoke(Object.FindObjectOfType<PauseMenu>(), "ReturnToMenu");
            }
            else if (stage == 1 || stage == 3)
            {
                Check(SceneManager.GetActiveScene().name == GameSession.MenuSceneName, "Menu loaded.");
                Check(!AudioListener.pause, "Menu audio is not paused.");
                Report("PASS: Menu BGM survives return without restarting.");
                // Prevent the preceding gameplay probe from hiding a missing refresh.
                RenderSettings.ambientProbe = new SphericalHarmonicsL2();
                Invoke(Object.FindObjectOfType<StartMenuController>(), "EnterGame", GameSession.Mode.NewGame);
            }
            else
            {
                Check(SceneManager.GetActiveScene().name == GameSession.GameSceneName, "Menu entered gameplay.");
                Check(RenderSettings.skybox == baselineSky, "Gameplay skybox matches direct entry.");
                Check(RenderSettings.ambientMode == AmbientMode.Skybox, "Gameplay uses sky ambient lighting.");
                Check(RenderSettings.sun != null, "Gameplay sun exists after transition.");
                Check(RenderSettings.sun.color == baselineSunColor &&
                      Mathf.Abs(RenderSettings.sun.intensity - baselineSunIntensity) < 0.001f &&
                      Vector3.Distance(RenderSettings.sun.transform.forward, baselineSunDirection) < 0.001f,
                    "Gameplay sunlight matches direct entry.");
                var error = ProbeDifference(RenderSettings.ambientProbe, baselineProbe);
                Check(error < 0.05f, "Sky ambient probe matches direct entry (relative error " + error + ").");
                Report("PASS: Menu -> new game lighting and continuous BGM, cycle " + (stage / 2) + ".");
                if (stage == 4)
                {
                    Report("PASS: All menu transition checks completed.");
                    stage = -1;
                    EditorApplication.isPlaying = false;
                    return;
                }
                Invoke(Object.FindObjectOfType<PauseMenu>(), "ReturnToMenu");
            }
            stage++;
            WaitForScene();
        }
        catch (Exception e)
        {
            Report("FAIL: " + e);
            Debug.LogException(e);
            stage = -1;
            EditorApplication.isPlaying = false;
        }
    }

    static void CheckMusic()
    {
        var current = BackgroundMusic.CurrentSource;
        Check(current != null && current.clip != null && current.isPlaying && current.loop,
            "Background music is playing and looping.");
        var expectedClip = AssetDatabase.LoadAssetAtPath<AudioClip>("Assets/Res/AudioAssets/bgm.wav");
        Check(current.clip == expectedClip, "Menu and gameplay use the original gameplay BGM.");
        var count = 0;
        foreach (var source in Object.FindObjectsOfType<AudioSource>(true))
            if (source.isPlaying && source.clip == expectedClip) count++;
        Check(count == 1, "Exactly one BGM source plays.");
        if (music != null)
        {
            Check(current == music && current.clip == clip, "BGM source and clip persist across scene changes.");
            var expectedTime = (musicTime + (float)(AudioSettings.dspTime - musicDsp) * current.pitch) % clip.length;
            var difference = Mathf.Abs(current.time - expectedTime);
            difference = Mathf.Min(difference, clip.length - difference);
            Check(difference < 1f, "BGM playback continues without restarting (time difference " + difference + ").");
        }
        music = current;
        clip = current.clip;
        musicTime = current.time;
        musicDsp = AudioSettings.dspTime;
    }

    static float ProbeEnergy(SphericalHarmonicsL2 probe)
    {
        var result = 0f;
        for (var channel = 0; channel < 3; channel++)
            for (var coefficient = 0; coefficient < 9; coefficient++)
                result += probe[channel, coefficient] * probe[channel, coefficient];
        return result;
    }

    static float ProbeDifference(SphericalHarmonicsL2 actual, SphericalHarmonicsL2 expected)
    {
        var difference = 0f;
        for (var channel = 0; channel < 3; channel++)
            for (var coefficient = 0; coefficient < 9; coefficient++)
            {
                var delta = actual[channel, coefficient] - expected[channel, coefficient];
                difference += delta * delta;
            }
        return Mathf.Sqrt(difference / Mathf.Max(0.0001f, ProbeEnergy(expected)));
    }

    static void Invoke(Object target, string method, params object[] args)
    {
        Check(target != null, "Transition controller exists: " + method);
        target.GetType().GetMethod(method, BindingFlags.Instance | BindingFlags.NonPublic).Invoke(target, args);
    }

    static string SaveFingerprint()
    {
        if (!File.Exists(SaveService.Path)) return "missing";
        using (var sha = System.Security.Cryptography.SHA256.Create())
            return Convert.ToBase64String(sha.ComputeHash(File.ReadAllBytes(SaveService.Path)));
    }

    static void Check(bool condition, string message)
    {
        if (!condition) throw new InvalidOperationException(message);
    }

    static void Report(string message)
    {
        File.AppendAllText(LogPath, message + "\n");
        Debug.Log("[MenuTransitionRegression] " + message);
    }
}
