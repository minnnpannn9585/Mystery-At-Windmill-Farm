using UnityEngine;
using UnityEngine.SceneManagement;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水下表现层的自举器：场景加载后自动把四个组件挂到主相机/管理器上，不需要手摆场景。
    ///
    ///   UnderwaterCameraController —— 判定 + 调色 Volume（挂相机）
    ///   UnderwaterSurfaceShell    —— 水面下表面（Snell 窗）
    ///   UnderwaterFogOverlay      —— 全屏介质雾
    ///   UnderwaterMotes           —— 浮游颗粒
    ///
    /// 与 WaterCollisionFilter 的做法一致：零场景改动，删掉本组件即可整体关闭。
    /// </summary>
    [DisallowMultipleComponent]
    [DefaultExecutionOrder(-60)]
    [AddComponentMenu("Water/Underwater Environment")]
    public sealed class UnderwaterEnvironment : MonoBehaviour
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void Install()
        {
            SceneManager.sceneLoaded -= OnSceneLoaded;
            SceneManager.sceneLoaded += OnSceneLoaded;
            Bootstrap();
        }

        static void OnSceneLoaded(Scene scene, LoadSceneMode mode)
        {
            Bootstrap();
        }

        static void Bootstrap()
        {
            if (Object.FindObjectOfType<UnderwaterEnvironment>() != null) return;

            // 注意：这里不能因为「Camera.main 还没生成」就跳过 —— 本工程的玩家/相机是
            // GameBootstrap 在运行时造的，场景加载时相机可能还不存在。
            // 相机晚到由 Update 里的补挂逻辑兜底。
            var go = new GameObject("[Underwater]");
            go.AddComponent<UnderwaterEnvironment>();
        }

        void Start()
        {
            EnsureCameraBinding();

            if (GetComponent<UnderwaterSurfaceShell>() == null)
                gameObject.AddComponent<UnderwaterSurfaceShell>();

            if (GetComponent<UnderwaterFogOverlay>() == null)
                gameObject.AddComponent<UnderwaterFogOverlay>();

            if (GetComponent<UnderwaterMotes>() == null)
                gameObject.AddComponent<UnderwaterMotes>();
        }

        void Update()
        {
            if (Time.unscaledTime < _nextCameraCheck) return;
            _nextCameraCheck = Time.unscaledTime + 1f;
            EnsureCameraBinding();
        }

        void EnsureCameraBinding()
        {
            var cam = Camera.main;
            if (cam == null) return;

            if (cam.GetComponent<UnderwaterCameraController>() == null)
                cam.gameObject.AddComponent<UnderwaterCameraController>();

            if (_camera != cam)
            {
                _camera = cam;
                var motes = GetComponent<UnderwaterMotes>();
                if (motes != null) motes.follow = cam.transform;
            }
        }

        Camera _camera;
        float _nextCameraCheck;
    }
}
