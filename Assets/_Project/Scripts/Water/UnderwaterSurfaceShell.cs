using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水下水面「下表面」：给每片 WaterSurface 生成一块贴着水面、朝向下的透明面片，
    /// 只在相机水下时启用。
    ///
    /// 为什么需要它：第三方水体包的水面材质是单面（_Cull = 2，剔除背面），
    /// 玩家潜到水下抬头时水面**整片消失**，直接看到天空 —— 这是「看不出在水下」的根因。
    /// 补上这一层，抬头才有「Snell 窗 + 全反射水色」的水面读感。
    ///
    /// 约束：只在相机水下启用，水上完全不参与渲染，不影响现有俯视水面。
    /// </summary>
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Underwater Surface Shell")]
    public sealed class UnderwaterSurfaceShell : MonoBehaviour
    {
        [Tooltip("留空则运行时用 Resources/Shaders/UnderwaterSurface 建一个")]
        public Material material;

        [Tooltip("面片相对水面下沉多少米（避免和原水面 Z-fighting）")]
        public float surfaceDrop = 0.03f;

        [Tooltip("水面包围盒高度超过这个值的视为竖直水体（瀑布），跳过 —— 它们的「水面」是包围盒顶，会盖住整个区域")]
        public float maxVolumeHeight = 4f;

        [Tooltip("重新扫描水面的间隔（秒）")]
        public float rescanInterval = 2f;

        Mesh _quad;
        Material _runtimeMaterial;
        bool _visible;
        float _nextScan;
        readonly List<GameObject> _shells = new List<GameObject>();

        void Awake()
        {
            _quad = BuildQuad();
            EnsureMaterial();
        }

        void Start()
        {
            Rebuild();
            _nextScan = Time.unscaledTime + Mathf.Max(0.5f, rescanInterval);
        }

        void OnDestroy()
        {
            Clear();
            if (_quad != null) Destroy(_quad);
            if (_runtimeMaterial != null) Destroy(_runtimeMaterial);
        }

        void Update()
        {
            float amount = UnderwaterCameraController.Instance != null
                ? UnderwaterCameraController.Instance.Submerge
                : 0f;

            bool want = amount > 0.002f;
            if (want != _visible)
            {
                _visible = want;
                for (int i = 0; i < _shells.Count; i++)
                    if (_shells[i] != null) _shells[i].SetActive(want);
            }

            if (Time.unscaledTime >= _nextScan)
            {
                _nextScan = Time.unscaledTime + Mathf.Max(0.5f, rescanInterval);
                // 水面是运行时自动注册的，开场可能还没有；数量变了就重建
                if (CountEligibleSurfaces() != _shells.Count) Rebuild();
            }
        }

        int CountEligibleSurfaces()
        {
            int n = 0;
            var all = WaterSurface.All;
            for (int i = 0; i < all.Count; i++)
            {
                var ws = all[i];
                if (ws == null || !ws.underwaterShell) continue;
                var r = ws.targetRenderer != null ? ws.targetRenderer : ws.GetComponent<Renderer>();
                if (r == null) { n++; continue; }
                if (r.bounds.size.y <= maxVolumeHeight) n++;
            }
            return n;
        }

        void Rebuild()
        {
            Clear();
            var all = WaterSurface.All;
            Vector3 parentScale = transform.lossyScale;

            for (int i = 0; i < all.Count; i++)
            {
                var ws = all[i];
                if (ws == null || !ws.underwaterShell) continue;

                var r = ws.targetRenderer != null ? ws.targetRenderer : ws.GetComponent<Renderer>();
                Bounds b = r != null
                    ? r.bounds
                    : new Bounds(ws.transform.position, new Vector3(24f, 0.1f, 24f));

                if (b.size.y > maxVolumeHeight) continue;   // 瀑布这类竖直水体跳过

                float y = ws.GetSurfaceY(b.center) - surfaceDrop;

                var go = new GameObject("UnderwaterShell");
                go.transform.SetParent(transform, true);
                go.transform.position = new Vector3(b.center.x, y, b.center.z);
                go.transform.rotation = Quaternion.identity;
                go.transform.localScale = new Vector3(
                    b.size.x / Mathf.Max(1e-4f, Mathf.Abs(parentScale.x)),
                    1f,
                    b.size.z / Mathf.Max(1e-4f, Mathf.Abs(parentScale.z)));

                var mf = go.AddComponent<MeshFilter>();
                mf.sharedMesh = _quad;

                var mr = go.AddComponent<MeshRenderer>();
                mr.sharedMaterial = material;
                mr.shadowCastingMode = ShadowCastingMode.Off;
                mr.receiveShadows = false;
                mr.lightProbeUsage = LightProbeUsage.Off;
                mr.reflectionProbeUsage = ReflectionProbeUsage.Off;

                go.SetActive(_visible);
                _shells.Add(go);
            }
        }

        void Clear()
        {
            for (int i = 0; i < _shells.Count; i++)
                if (_shells[i] != null) Destroy(_shells[i]);
            _shells.Clear();
        }

        void EnsureMaterial()
        {
            if (material != null) return;

            var shader = Resources.Load<Shader>("Shaders/UnderwaterSurface");
            if (shader == null) shader = Shader.Find("WindmillFarm/Underwater Surface");
            if (shader == null)
            {
                Debug.LogWarning("[UnderwaterSurfaceShell] 找不到 WindmillFarm/Underwater Surface 着色器，水下水面不会显示。", this);
                return;
            }

            _runtimeMaterial = new Material(shader) { hideFlags = HideFlags.DontSave };
            _runtimeMaterial.name = "UnderwaterSurface (Runtime)";
            material = _runtimeMaterial;
        }

        static Mesh BuildQuad()
        {
            var m = new Mesh { name = "UnderwaterShellQuad" };
            m.vertices = new[]
            {
                new Vector3(-0.5f, 0f, -0.5f),
                new Vector3( 0.5f, 0f, -0.5f),
                new Vector3( 0.5f, 0f,  0.5f),
                new Vector3(-0.5f, 0f,  0.5f)
            };
            m.normals = new[] { Vector3.up, Vector3.up, Vector3.up, Vector3.up };
            m.uv = new[] { new Vector2(0, 0), new Vector2(1, 0), new Vector2(1, 1), new Vector2(0, 1) };
            m.triangles = new[] { 0, 2, 1, 0, 3, 2 };
            m.RecalculateBounds();
            return m;
        }
    }
}
