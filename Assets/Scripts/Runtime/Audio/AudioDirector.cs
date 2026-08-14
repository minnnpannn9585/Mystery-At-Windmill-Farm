using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public sealed class AudioDirector : MonoBehaviour
    {
        public static AudioDirector Instance { get; private set; }

        [SerializeField] AudioClip[] audioClips;
        [SerializeField] AudioSource sfxSource;
        [SerializeField] AudioSource bgmSource;
        [SerializeField] ParticleSystem[] particleSystems;

        AudioClip _originalBgm;
        readonly Dictionary<string, AudioClip> _byName = new Dictionary<string, AudioClip>();

        void Awake()
        {
            Instance = this;
            if (sfxSource == null) sfxSource = gameObject.AddComponent<AudioSource>();
            if (bgmSource == null)
            {
                bgmSource = gameObject.AddComponent<AudioSource>();
                bgmSource.loop = true;
                bgmSource.playOnAwake = false;
            }
            RebuildMap();
            LoadEditorClipsIfNeeded();
            if (bgmSource.clip != null) _originalBgm = bgmSource.clip;
        }

        void Start()
        {
            if (_byName.ContainsKey("audio_bgm"))
                PlayBGM();
            else if (_byName.ContainsKey("bgm"))
            {
                bgmSource.clip = _byName["bgm"];
                bgmSource.loop = true;
                bgmSource.Play();
                _originalBgm = bgmSource.clip;
            }
        }

        public void SetClips(AudioClip[] clips)
        {
            audioClips = clips;
            RebuildMap();
        }

        public void SetParticles(ParticleSystem[] systems)
        {
            particleSystems = systems;
        }

        void RebuildMap()
        {
            _byName.Clear();
            if (audioClips == null) return;
            for (var i = 0; i < audioClips.Length; i++)
            {
                var clip = audioClips[i];
                if (clip != null && !_byName.ContainsKey(clip.name))
                    _byName[clip.name] = clip;
            }
        }

        void LoadEditorClipsIfNeeded()
        {
            if (_byName.Count > 0) return;
#if UNITY_EDITOR
            var guids = UnityEditor.AssetDatabase.FindAssets("t:AudioClip", new[] { "Assets/Res/AudioAssets" });
            var list = new List<AudioClip>();
            for (var i = 0; i < (guids == null ? 0 : guids.Length); i++)
            {
                var path = UnityEditor.AssetDatabase.GUIDToAssetPath(guids[i]);
                var clip = UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(path);
                if (clip != null) list.Add(clip);
            }
            audioClips = list.ToArray();
            RebuildMap();
#endif
        }

        public static void PlayAudio(string name)
        {
            if (Instance != null) Instance.PlayOneShot(name);
        }

        public static void PlayBGM()
        {
            if (Instance == null) return;
            if (Instance._originalBgm != null)
                Instance.bgmSource.clip = Instance._originalBgm;
            else
            {
                AudioClip clip;
                if (Instance._byName.TryGetValue("audio_bgm", out clip) || Instance._byName.TryGetValue("bgm", out clip))
                    Instance.bgmSource.clip = clip;
            }
            Instance.bgmSource.loop = true;
            if (Instance.bgmSource.clip != null)
                Instance.bgmSource.Play();
        }

        public static void StopBGM()
        {
            if (Instance != null && Instance.bgmSource != null)
                Instance.bgmSource.Stop();
        }

        public static void PlayMusic(string name)
        {
            if (Instance == null) return;
            AudioClip clip;
            if (!Instance._byName.TryGetValue(name ?? "", out clip) || clip == null)
            {
                Debug.Log("[AudioDirector] missing music " + name);
                return;
            }
            Instance.bgmSource.Stop();
            Instance.bgmSource.clip = clip;
            Instance.bgmSource.loop = true;
            Instance.bgmSource.Play();
        }

        public static float GetClipLength(string name)
        {
            if (Instance == null) return 0f;
            AudioClip clip;
            if (!Instance._byName.TryGetValue(name ?? "", out clip) || clip == null) return 0f;
            return clip.length;
        }

        public static void PlayParticle(string name, Vector3 position)
        {
            if (Instance == null || Instance.particleSystems == null) return;
            for (var i = 0; i < Instance.particleSystems.Length; i++)
            {
                var ps = Instance.particleSystems[i];
                if (ps == null || ps.name != name) continue;
                ps.transform.position = position;
                ps.Stop();
                ps.Clear();
                ps.Play();
                return;
            }
        }

        void PlayOneShot(string name)
        {
            AudioClip clip;
            if (!_byName.TryGetValue(name ?? "", out clip) || clip == null)
            {
                Debug.Log("[AudioDirector] missing clip " + name);
                return;
            }
            sfxSource.PlayOneShot(clip);
        }
    }
}
