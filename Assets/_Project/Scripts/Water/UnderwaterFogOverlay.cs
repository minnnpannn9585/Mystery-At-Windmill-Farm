using UnityEngine;
using UnityEngine.Rendering;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水下全屏介质层：距离雾 + 垂直亮度梯度 + 屏幕抖动。
    ///
    /// 实现是「相机前置全屏 Quad」而不是 ScriptableRendererFeature ——
    /// 加 Feature 要手改 FlatKit 的 Renderer Data（那条链已有 3 个 Feature），风险高且没有开关；
    /// 而这个 Quad 的顶点直接输出裁剪空间坐标，天然铺满全屏，在透明队列里还能采样 `_CameraDepthTexture`。
    /// 只在相机水下时启用，水上零开销。
    /// </summary>
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Underwater Fog Overlay")]
    public sealed class UnderwaterFogOverlay : MonoBehaviour
    {
        [Tooltip("留空则运行时用 Resources/Shaders/UnderwaterFog 建一个")]
        public Material material;

        [Tooltip("Quad 挂在相机前多少米（只影响剔除，不影响画面）")]
        public float quadDistance = 0.3f;

        Mesh _quad;
        Material _runtimeMaterial;
        MeshFilter _filter;
        MeshRenderer _renderer;
        float _nextRebind;

        void Awake()
        {
            _quad = BuildQuad();
            EnsureMaterial();
            Bind(Camera.main);
        }

        void OnDestroy()
        {
            if (_quad != null) Destroy(_quad);
            if (_runtimeMaterial != null) Destroy(_runtimeMaterial);
        }

        void Update()
        {
            float amount = UnderwaterCameraController.Instance != null
                ? UnderwaterCameraController.Instance.Submerge
                : 0f;
            bool want = amount > 0.002f;

            if (_renderer != null && _renderer.enabled != want) _renderer.enabled = want;

            // 换相机 / 相机晚生成时重新挂一次
            if (_filter == null || _filter.transform.parent == null)
            {
                if (Time.unscaledTime < _nextRebind) return;
                _nextRebind = Time.unscaledTime + 1f;
                Bind(Camera.main);
            }
        }

        void Bind(Camera cam)
        {
            if (cam == null || _quad == null || material == null) return;

            if (_filter == null)
            {
                var go = new GameObject("UnderwaterFogQuad");
                go.hideFlags = HideFlags.DontSave;
                _filter = go.AddComponent<MeshFilter>();
                _filter.sharedMesh = _quad;
                _renderer = go.AddComponent<MeshRenderer>();
                _renderer.sharedMaterial = material;
                _renderer.shadowCastingMode = ShadowCastingMode.Off;
                _renderer.receiveShadows = false;
                _renderer.lightProbeUsage = LightProbeUsage.Off;
                _renderer.reflectionProbeUsage = ReflectionProbeUsage.Off;
                _renderer.enabled = false;
            }

            _filter.transform.SetParent(cam.transform, false);
            _filter.transform.localPosition = new Vector3(0f, 0f, Mathf.Max(0.05f, quadDistance));
            _filter.transform.localRotation = Quaternion.identity;
            _filter.transform.localScale = Vector3.one;
        }

        void EnsureMaterial()
        {
            if (material != null) return;

            var shader = Resources.Load<Shader>("Shaders/UnderwaterFog");
            if (shader == null) shader = Shader.Find("WindmillFarm/Underwater Fog");
            if (shader == null)
            {
                Debug.LogWarning("[UnderwaterFogOverlay] 找不到 WindmillFarm/Underwater Fog 着色器，水下雾不会显示。", this);
                return;
            }

            _runtimeMaterial = new Material(shader) { hideFlags = HideFlags.DontSave };
            _runtimeMaterial.name = "UnderwaterFog (Runtime)";
            material = _runtimeMaterial;
        }

        /// <summary>
        /// 顶点放在 ±1，着色器把它们直接当裁剪空间坐标用 → transform 完全不参与，永远铺满全屏。
        /// bounds 放大，避免被视锥剔除。
        /// </summary>
        static Mesh BuildQuad()
        {
            var m = new Mesh { name = "UnderwaterFogQuad" };
            m.vertices = new[]
            {
                new Vector3(-1f, -1f, 0f),
                new Vector3( 1f, -1f, 0f),
                new Vector3( 1f,  1f, 0f),
                new Vector3(-1f,  1f, 0f)
            };
            m.uv = new[] { new Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1) };
            m.triangles = new[] { 0, 2, 1, 0, 3, 2 };
            m.bounds = new Bounds(Vector3.zero, Vector3.one * 100000f);
            return m;
        }
    }
}
