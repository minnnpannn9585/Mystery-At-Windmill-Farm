using UnityEngine;

namespace EggRescue
{
    /// <summary>
    /// 主菜单和游戏共用的音乐声源，独立于每次进入农场时创建的游戏系统。
    /// </summary>
    public static class BackgroundMusic
    {
        static AudioSource _source;

        public static AudioSource CurrentSource { get { return _source; } }

        static AudioSource EnsureSource()
        {
            if (_source != null) return _source;
            var go = new GameObject("BackgroundMusic");
            Object.DontDestroyOnLoad(go);
            _source = go.AddComponent<AudioSource>();
            _source.playOnAwake = false;
            _source.loop = true;
            _source.spatialBlend = 0f;
            return _source;
        }

        public static AudioSource Adopt(AudioSource sceneSource)
        {
            var source = EnsureSource();
            if (sceneSource == null || sceneSource == source) return source;

            source.outputAudioMixerGroup = sceneSource.outputAudioMixerGroup;
            source.volume = sceneSource.volume;
            source.pitch = sceneSource.pitch;
            source.mute = sceneSource.mute;
            if (sceneSource.clip != null && source.clip != sceneSource.clip)
                source.clip = sceneSource.clip;

            // 场景里的自动播放声源只提供配置，避免切换场景时两份音乐叠加。
            sceneSource.Stop();
            sceneSource.playOnAwake = false;
            sceneSource.enabled = false;
            return source;
        }

        public static void Play(AudioClip clip)
        {
            if (clip == null) return;
            var source = EnsureSource();
            if (source.clip != clip) source.clip = clip;
            source.loop = true;
            // 同一首歌跨场景继续播放，不重置播放位置。
            if (!source.isPlaying) source.Play();
        }
    }
}
