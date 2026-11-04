using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 按地形水深重新生成水面网格的顶点色 R 通道，用来驱动第三方水体包
    /// （FullOpaqueWater&Waterfall）**原本自带**的岸边泡沫与涟漪。
    ///
    /// 为什么这样做而不是另画一层泡沫：
    ///   S_Water.shadergraph 里岸边泡沫的完整链路是
    ///     shoreFoam = step(_ShoreStep,   softLight(VColor.r, 流动噪声))
    ///     foamWave  = step(_FoamWaveStep, softLight(sqrt(VColor.r) * sin((sqrt(VColor.r)
    ///                            + TIME * _FoamWaveSpeed) * _FoamWavesNumber), 流动噪声))
    ///     BaseColor = lerp(水色, 泡沫色, saturate(shoreFoam + foamWave + 冲击区 + 瀑布湍流))
    ///   也就是说：
    ///     · 泡沫的**位置**完全由顶点色 R 决定；
    ///     · 泡沫的**涟漪**是把 sqrt(VColor.r) 当径向相位去 sin 出来的。
    ///   所以只要把 VColor.r 重新按「离岸远近」烘一遍，原有的碎边、噪声抖动、
    ///   涟漪推进全部原样生效，观感和原包手绘完全一致，而且水体移动后自动贴合新岸线。
    ///
    /// 之前那套「压制原泡沫 + 另画程序化叠加层」的做法会把这套涟漪机制整个关掉，
    /// 只能得到一条平滑死板的实心白带，因此弃用。
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Water Shore Vertex Color Baker")]
    public class WaterShoreVertexColorBaker : MonoBehaviour
    {
        [Header("源网格")]
        [Tooltip("原始水面网格。留空则自动取当前 MeshFilter 上的网格（第一次烘焙时记录）")]
        public Mesh sourceMesh;

        [Header("岸线遮罩（写入顶点色 R）")]
        [Tooltip("水深达到该值（米）时顶点色归零。顶点色 = 1 - 水深 / 该值\n" +
                 "泡沫带宽 ≈ 该值 × (1 - _ShoreStep)" )]
        public float shoreWidth = 1.0f;

        [Tooltip("曲线指数。=1 线性；>1 让遮罩更快落到 0，泡沫带更窄更利")]
        public float falloffPower = 1.0f;

        [Tooltip("顶点高于水面的部分（岸上、或埋进地形的裙边）也当作岸边，顶点色记 1")]
        public bool aboveWaterIsShore = true;

        [Header("地形采样")]
        [Tooltip("留空则自动收集场景里所有 Terrain")]
        public Terrain[] terrains;

        [Tooltip("没有 Terrain 时改为从顶点向下打物理射线找地面（地面需要有 Collider）")]
        public bool physicsFallback = true;

        public LayerMask groundMask = ~0;

        [Header("自动重烘")]
        public bool autoRebake = true;

        [Tooltip("移动后静止多久才重烘，避免拖动时每帧烘焙卡顿")]
        public float rebakeDelay = 0.25f;

        [Header("状态（只读）")]
        [Tooltip("当前实际挂在 MeshFilter 上的、写入了顶点色的网格副本")]
        public Mesh bakedMesh;

        MeshFilter _mf;
        Vector3    _lastPos;
        Quaternion _lastRot;
        Vector3    _lastScale;
        float      _dirtyAt = -1f;

        void OnEnable()
        {
            _mf = GetComponent<MeshFilter>();
            RememberTransform();
            if (Application.isEditor) Bake();
        }

        void Update()
        {
            if (!autoRebake) return;

            Transform tr = transform;
            bool moved = Vector3.SqrMagnitude(tr.position - _lastPos) > 1e-6f
                      || Quaternion.Angle(tr.rotation, _lastRot) > 0.01f
                      || Vector3.SqrMagnitude(tr.lossyScale - _lastScale) > 1e-6f;

            if (moved)
            {
                RememberTransform();
                _dirtyAt = Time.realtimeSinceStartup;
            }
            else if (_dirtyAt > 0f && Time.realtimeSinceStartup - _dirtyAt >= rebakeDelay)
            {
                _dirtyAt = -1f;
                Bake();
            }
        }

        void RememberTransform()
        {
            Transform tr = transform;
            _lastPos   = tr.position;
            _lastRot   = tr.rotation;
            _lastScale = tr.lossyScale;
        }

        /// <summary>立即重算顶点色。编辑器菜单 / Inspector 按钮调用。</summary>
        public void Bake()
        {
            if (_mf == null) _mf = GetComponent<MeshFilter>();
            if (_mf == null) return;

            // 当前挂的如果不是我们烘出来的副本，那它就是原始网格（第一次烘焙 / 用户手动换了网格）
            bool onBaked = bakedMesh != null && _mf.sharedMesh == bakedMesh;
            if (!onBaked && _mf.sharedMesh != null) sourceMesh = _mf.sharedMesh;

            if (sourceMesh == null) return;

            Vector3[] verts;
            try { verts = sourceMesh.vertices; }
            catch (System.Exception)
            {
                Debug.LogError("[ShoreVC] 网格 " + sourceMesh.name +
                               " 不可读，请在模型导入设置里勾选 Read/Write。", this);
                return;
            }
            if (verts.Length == 0) return;

            Color[] cols = sourceMesh.colors;
            if (cols == null || cols.Length != verts.Length)
            {
                cols = new Color[verts.Length];
                for (int i = 0; i < cols.Length; i++) cols[i] = Color.white;
            }

            if (terrains == null || terrains.Length == 0)
                terrains = FindObjectsOfType<Terrain>();

            Transform tr = transform;

            for (int i = 0; i < verts.Length; i++)
            {
                Vector3 wp = tr.TransformPoint(verts[i]);
                float depth = wp.y - SampleGround(wp);

                float r;
                if (depth <= 0f)
                    r = aboveWaterIsShore ? 1f : 0f;
                else
                    r = 1f - Mathf.Clamp01(depth / Mathf.Max(shoreWidth, 1e-4f));

                if (falloffPower != 1f) r = Mathf.Pow(r, falloffPower);

                // 只改 R，G/B/A 保留原手绘数据
                cols[i].r = r;
            }

            Mesh work = EnsureWritableMesh();
            if (work == null) return;

            work.colors = cols;
            _mf.sharedMesh = work;

#if UNITY_EDITOR
            UnityEditor.EditorUtility.SetDirty(work);
#endif
        }

        /// <summary>把网格恢复成原始版本（去掉本组件写入的顶点色）。</summary>
        public void Restore()
        {
            if (_mf == null) _mf = GetComponent<MeshFilter>();
            if (_mf != null && sourceMesh != null) _mf.sharedMesh = sourceMesh;
            bakedMesh = null;
        }

        Mesh EnsureWritableMesh()
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                if (bakedMesh != null) return bakedMesh;

                const string dir = "Assets/_Project/Meshes/Water";
                if (!UnityEditor.AssetDatabase.IsValidFolder(dir))
                {
                    string parent = System.IO.Path.GetDirectoryName(dir).Replace('\\', '/');
                    string leaf   = System.IO.Path.GetFileName(dir);
                    if (!UnityEditor.AssetDatabase.IsValidFolder(parent))
                        UnityEditor.AssetDatabase.CreateFolder("Assets", "_Project");
                    UnityEditor.AssetDatabase.CreateFolder(parent, leaf);
                }

                string path = dir + "/" + sourceMesh.name + "_ShoreVC.asset";
                Mesh existing = UnityEditor.AssetDatabase.LoadAssetAtPath<Mesh>(path);
                if (existing != null)
                {
                    UnityEditor.EditorUtility.CopySerialized(sourceMesh, existing);
                    bakedMesh = existing;
                    return bakedMesh;
                }

                Mesh clone = Instantiate(sourceMesh);
                clone.name = sourceMesh.name + "_ShoreVC";
                UnityEditor.AssetDatabase.CreateAsset(clone, path);
                bakedMesh = clone;
                return bakedMesh;
            }
#endif
            // 运行时：每个实例各用一份，避免改到共享网格
            if (bakedMesh == null) bakedMesh = Instantiate(sourceMesh);
            bakedMesh.name = sourceMesh.name + "_ShoreVC";
            return bakedMesh;
        }

        /// <summary>返回该世界 XZ 处的地面高度；找不到地面时返回很低的值（视为深水）。</summary>
        float SampleGround(Vector3 wp)
        {
            float best = float.NegativeInfinity;
            bool found = false;

            if (terrains != null)
            {
                for (int i = 0; i < terrains.Length; i++)
                {
                    Terrain t = terrains[i];
                    if (t == null || t.terrainData == null) continue;

                    Vector3 p = t.transform.position;
                    Vector3 s = t.terrainData.size;
                    if (wp.x < p.x || wp.x > p.x + s.x || wp.z < p.z || wp.z > p.z + s.z) continue;

                    float h = t.SampleHeight(new Vector3(wp.x, 0f, wp.z)) + p.y;
                    if (!found || h > best) best = h;
                    found = true;
                }
            }

            if (!found && physicsFallback)
            {
                // 从水面往上抬一点再往下打，避免起点已经在土里
                Ray ray = new Ray(new Vector3(wp.x, wp.y + 50f, wp.z), Vector3.down);
                if (Physics.Raycast(ray, out RaycastHit hit, 500f, groundMask,
                                    QueryTriggerInteraction.Ignore))
                {
                    best = hit.point.y;
                    found = true;
                }
            }

            return found ? best : -10000f;
        }
    }
}
