using UnityEngine;

namespace EggRescue
{
    /// <summary>
    /// 主菜单里改的音量和鼠标灵敏度。写入 PlayerPrefs，进游戏后由相机和 AudioListener 使用。
    /// </summary>
    public static class GameSettings
    {
        const string VolumeKey = "egg.masterVolume";
        const string SensitivityKey = "egg.mouseSensitivity";
        public const float DefaultSensitivity = 2.2f;

        public static float MasterVolume { get; private set; } = 1f;
        public static float MouseSensitivity { get; private set; } = DefaultSensitivity;

        public static void Load()
        {
            MasterVolume = Mathf.Clamp01(PlayerPrefs.GetFloat(VolumeKey, 1f));
            MouseSensitivity = Mathf.Clamp(PlayerPrefs.GetFloat(SensitivityKey, DefaultSensitivity), 0.4f, 6f);
            Apply();
        }

        public static void SetMasterVolume(float value)
        {
            MasterVolume = Mathf.Clamp01(value);
            PlayerPrefs.SetFloat(VolumeKey, MasterVolume);
            PlayerPrefs.Save();
            Apply();
        }

        public static void SetMouseSensitivity(float value)
        {
            MouseSensitivity = Mathf.Clamp(value, 0.4f, 6f);
            PlayerPrefs.SetFloat(SensitivityKey, MouseSensitivity);
            PlayerPrefs.Save();
            Apply();
        }

        public static void Apply()
        {
            AudioListener.volume = MasterVolume;
            if (ThirdPersonCamera.Instance != null)
                ThirdPersonCamera.Instance.SetMouseSensitivity(MouseSensitivity);
        }
    }
}
