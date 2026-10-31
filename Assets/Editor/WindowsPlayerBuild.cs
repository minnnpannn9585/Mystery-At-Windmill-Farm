using System;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

// Build from the open editor without replacing or saving the user's scene setup.
[InitializeOnLoad]
public static class WindowsPlayerBuild
{
    const string MenuScene = "Assets/Scenes/StartMenu.unity";
    const string GameScene = "Assets/Scenes/Mechanics_Code.unity";
    const string OutputPath = "Builds/windowsBuild1031-fixed/Mystery at Windmill Farm.exe";
    const string ResultPath = "Logs/windows-player-build-result.txt";
    const string RequestPath = "Logs/request-windows-player-build";
    static double readySince = -1;
    static bool building;

    static WindowsPlayerBuild()
    {
        EditorApplication.update += CheckBuildRequest;
    }

    static bool EditorBusy()
    {
        return EditorApplication.isCompiling || EditorApplication.isUpdating ||
               EditorApplication.isPlayingOrWillChangePlaymode || BuildPipeline.isBuildingPlayer;
    }

    static void CheckBuildRequest()
    {
        if (building) return;
        if (!File.Exists(RequestPath) || EditorBusy())
        {
            readySince = -1;
            return;
        }
        if (readySince < 0)
            readySince = EditorApplication.timeSinceStartup;
        if (EditorApplication.timeSinceStartup - readySince < 2) return;

        readySince = -1;
        try
        {
            // Consume once, before the build can trigger asset imports or a domain reload.
            File.Delete(RequestPath);
            Build();
        }
        catch (Exception exception)
        {
            Debug.LogException(exception);
        }
    }

    [MenuItem("Tools/Egg Rescue/Build Windows Player")]
    public static void Build()
    {
        Directory.CreateDirectory("Logs");
        var result = new StringBuilder();
        result.AppendLine("Windows x64 release build");
        result.AppendLine("Started (UTC): " + DateTime.UtcNow.ToString("O"));
        result.AppendLine("Output: " + Path.GetFullPath(OutputPath));
        try
        {
            if (building || EditorBusy())
                throw new BuildFailedException("Wait for compilation/imports and exit Play Mode before building.");
            building = true;
            File.WriteAllText(ResultPath, result + "Status: Running\n");

            var scenes = EditorBuildSettings.scenes.Where(scene => scene.enabled)
                .Select(scene => scene.path).ToArray();
            ValidateScenes(scenes);
            result.AppendLine("Validation: Main menu first; gameplay has an active exportable MainCamera.");
            Directory.CreateDirectory(Path.GetDirectoryName(OutputPath));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = OutputPath,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            });
            if (report == null)
                throw new BuildFailedException("BuildPipeline returned no build report.");
            result.AppendLine("Result: " + report.summary.result);
            result.AppendLine("Size (bytes): " + report.summary.totalSize);
            result.AppendLine("Duration: " + report.summary.totalTime);
            result.AppendLine("Errors: " + report.summary.totalErrors);
            result.AppendLine("Warnings: " + report.summary.totalWarnings);
            if (report.summary.result != BuildResult.Succeeded)
                throw new BuildFailedException("Windows player build " + report.summary.result + ".");
            result.AppendLine("Status: Succeeded");
            Debug.Log("[WindowsPlayerBuild] Built " + Path.GetFullPath(OutputPath));
        }
        catch (Exception exception)
        {
            result.AppendLine("Status: Failed");
            result.AppendLine(exception.ToString());
            throw;
        }
        finally
        {
            building = false;
            result.AppendLine("Finished (UTC): " + DateTime.UtcNow.ToString("O"));
            File.WriteAllText(ResultPath, result.ToString());
        }
    }

    static void ValidateScenes(string[] scenes)
    {
        if (scenes.Length == 0 || scenes[0] != MenuScene)
            throw new BuildFailedException("StartMenu must be the first enabled scene in Build Settings.");
        if (!scenes.Contains(GameScene))
            throw new BuildFailedException("Mechanics_Code must be enabled in Build Settings.");

        // Tuanjie 2022 does not expose OpenPreviewScene. Inspect an additive scene,
        // then close only the scene we opened and restore the user's active scene.
        var originalActive = SceneManager.GetActiveScene();
        var gameplay = SceneManager.GetSceneByPath(GameScene);
        var openedForValidation = !gameplay.IsValid() || !gameplay.isLoaded;
        if (!openedForValidation && gameplay.isDirty)
            throw new BuildFailedException("Save Mechanics_Code before building so validation matches the exported scene.");
        if (openedForValidation)
            gameplay = EditorSceneManager.OpenScene(GameScene, OpenSceneMode.Additive);
        try
        {
            foreach (var root in gameplay.GetRootGameObjects())
            {
                foreach (var camera in root.GetComponentsInChildren<Camera>(true))
                {
                    if (!camera.enabled || !camera.CompareTag("MainCamera")) continue;
                    var exportable = true;
                    for (var parent = camera.transform; parent != null; parent = parent.parent)
                    {
                        if (!parent.gameObject.activeSelf || parent.CompareTag("EditorOnly"))
                        {
                            exportable = false;
                            break;
                        }
                    }
                    if (exportable) return;
                }
            }
            throw new BuildFailedException("Mechanics_Code has no enabled MainCamera with active, non-EditorOnly ancestors. " +
                                           "EditorOnly objects are stripped from the player and leave gameplay without a camera.");
        }
        finally
        {
            if (openedForValidation && gameplay.IsValid() && gameplay.isLoaded)
                EditorSceneManager.CloseScene(gameplay, true);
            if (originalActive.IsValid() && originalActive.isLoaded)
                SceneManager.SetActiveScene(originalActive);
        }
    }
}
