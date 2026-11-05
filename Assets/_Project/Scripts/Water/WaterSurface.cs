using System.Collections.Generic;
using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水面体。挂在任何「水面」物体上（Pool / TrailWater / 瀑布下的水池……），
    /// 提供一个全局可查询的接口：某个世界坐标下面有没有水、水面高度是多少。
    ///
    /// 之所以要这层：荷叶片、玩家、任何漂浮物都需要知道「我此刻在不在水里、水线在哪」，
    /// 而第三方水体包的 shader 是封闭的 ShaderGraph，没法从着色器里反查。
    ///
    /// 水面高度默认取 Renderer 世界包围盒的顶面（水面网格一般是水平面），
    /// 也可以用 overrideSurfaceY 手动指定，或者用 surfaceMask 从上方打射线取真实水面。
    /// </summary>
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Water Surface")]
    public class WaterSurface : MonoBehaviour
    {
        public enum SurfaceMode
        {
            RendererBounds,
            Raycast,
            Explicit
        }

        [Tooltip("水面高度取法。RendererBounds = 取水面网格包围盒顶面（水面是一张水平面时最省事）；" +
                 "Raycast = 从上方打射线；Explicit = 纯手填高度")]
        public SurfaceMode mode = SurfaceMode.RendererBounds;

        [Tooltip("留空则用本物体上的 Renderer")]
        public Renderer targetRenderer;

        [Tooltip("mode = Explicit 时使用的水面世界 Y")]
        public float overrideSurfaceY;

        [Tooltip("水面高度修正（正数抬高），用于包围盒比真实水面高一点的情况")]
        public float surfaceOffset;

        [Tooltip("mode = Raycast 时，从上方往下打射线要找的地面层")]
        public LayerMask surfaceMask = ~0;

        [Tooltip("XZ 判定时向外扩一点，避免边缘物体被判成不在水里")]
        public float edgePadding = 0.15f;

        [Tooltip("是否参与「水下水面下表面」渲染。瀑布这类竖直水体请取消勾选 —— 它的「水面」是包围盒顶，会糊住整个区域")]
        public bool underwaterShell = true;

        static readonly List<WaterSurface> s_all = new List<WaterSurface>();
        public static IReadOnlyList<WaterSurface> All { get { return s_all; } }

        static readonly HashSet<int> s_waterColliderIds = new HashSet<int>();

        /// <summary>
        /// 把 Collider 登记成「水」。相机避让必须跳过它：
        /// Physics.IgnoreCollision 只影响两个碰撞体之间的碰撞解算，**不影响 Raycast / SphereCast 查询**，
        /// 所以玩家能穿过水面，相机的 SphereCast 照样被水面挡住，臂长瞬间缩到 0（贴脸）。
        /// </summary>
        public static void RegisterWaterCollider(Collider c)
        {
            if (c != null) s_waterColliderIds.Add(c.GetInstanceID());
        }

        public static bool IsWaterCollider(Collider c)
        {
            return c != null && s_waterColliderIds.Contains(c.GetInstanceID());
        }

        Renderer _r;

        Renderer GetRenderer()
        {
            if (targetRenderer != null) return targetRenderer;
            if (_r == null) _r = GetComponent<Renderer>();
            return _r;
        }

        void OnEnable()
        {
            if (!s_all.Contains(this)) s_all.Add(this);
            RegisterOwnColliders();
        }

        /// <summary>把这片水身上的 Collider 登记给相机避让用（自身 + 子级 + 父级都覆盖）。</summary>
        void RegisterOwnColliders()
        {
            var self = GetComponent<Collider>();
            if (self != null) RegisterWaterCollider(self);

            var cols = GetComponentsInChildren<Collider>(true);
            for (int i = 0; i < cols.Length; i++) RegisterWaterCollider(cols[i]);

            // 水面模型把 Collider 挂在父级空物体上的情况很常见
            if (transform.parent != null)
            {
                var parentCol = transform.parent.GetComponent<Collider>();
                if (parentCol != null) RegisterWaterCollider(parentCol);
            }
        }

        void OnDisable()
        {
            s_all.Remove(this);
        }

        /// <summary>水面世界高度。</summary>
        public float GetSurfaceY(Vector3 worldPos)
        {
            switch (mode)
            {
                case SurfaceMode.Explicit:
                    return overrideSurfaceY + surfaceOffset;

                case SurfaceMode.Raycast:
                {
                    Ray ray = new Ray(new Vector3(worldPos.x, worldPos.y + 200f, worldPos.z), Vector3.down);
                    if (Physics.Raycast(ray, out RaycastHit hit, 400f, surfaceMask, QueryTriggerInteraction.Ignore))
                        return hit.point.y + surfaceOffset;
                    break;
                }
            }

            Renderer r = GetRenderer();
            if (r == null) return overrideSurfaceY + surfaceOffset;
            return r.bounds.max.y + surfaceOffset;
        }

        /// <summary>该世界坐标是否落在这片水的水平范围内（XZ 判定）。</summary>
        public bool Contains(Vector3 worldPos)
        {
            Renderer r = GetRenderer();
            if (r == null) return true;

            float pad = Mathf.Max(0f, edgePadding);
            Bounds b = r.bounds;
            return worldPos.x >= b.min.x - pad && worldPos.x <= b.max.x + pad
                && worldPos.z >= b.min.z - pad && worldPos.z <= b.max.z + pad;
        }

        /// <summary>
        /// 查询某点的水面高度。
        /// 多片水重叠时取**离查询点最近**的那片 —— 取最高会让瀑布这类包围盒顶面最高的水把整片区域
        /// 都判成深水，玩家站在旁边干地上也会进游泳态、吃掉跳跃输入。
        /// </summary>
        public static bool TrySample(Vector3 worldPos, out float surfaceY)
        {
            AutoRegisterIfNeeded();

            bool found = false;
            float bestY = 0f;
            float bestDist = float.PositiveInfinity;

            for (int i = 0; i < s_all.Count; i++)
            {
                WaterSurface w = s_all[i];
                if (w == null || !w.isActiveAndEnabled) continue;
                if (!w.Contains(worldPos)) continue;

                float y = w.GetSurfaceY(worldPos);
                float dist = Mathf.Abs(y - worldPos.y);
                if (!found || dist < bestDist) { bestY = y; bestDist = dist; found = true; }
            }

            surfaceY = found ? bestY : 0f;
            return found;
        }

        static bool s_autoScanDone;
        static float s_nextAutoScan;
        static readonly int WaterProbeId = Shader.PropertyToID("_WaterfallTurbulencePose");

        /// <summary>
        /// 场景里一片 WaterSurface 都没有时，自动给所有「水体包的水面」补上组件。
        /// 这样即使忘了手动挂，游泳 / 泡沫 / 碰撞过滤也能正常工作。
        /// </summary>
        static void AutoRegisterIfNeeded()
        {
            if (s_all.Count > 0) return;
            if (s_autoScanDone && Time.unscaledTime < s_nextAutoScan) return;

            s_autoScanDone = true;
            s_nextAutoScan = Time.unscaledTime + 1f;

            int added = 0;
            foreach (Renderer r in Object.FindObjectsOfType<Renderer>())
            {
                if (r is ParticleSystemRenderer || r is SpriteRenderer) continue;
                if (r.GetComponent<WaterSurface>() != null) continue;

                Material[] mats = r.sharedMaterials;
                bool isWater = false;
                for (int i = 0; i < mats.Length; i++)
                {
                    if (mats[i] != null && mats[i].HasProperty(WaterProbeId)) { isWater = true; break; }
                }
                if (isWater)
                {
                    var ws = r.gameObject.AddComponent<WaterSurface>();
                    // 编辑态下 Unity 不会给普通 MonoBehaviour 触发 OnEnable，这里手动补登记，
                    // 否则每次查询都会重新全场景扫一遍
                    if (!s_all.Contains(ws)) s_all.Add(ws);
                    added++;
                }
            }

            if (added > 0)
                Debug.Log("[WaterSurface] 自动注册了 " + added + " 片水面（材质带 _WaterfallTurbulencePose 的 Renderer）。");
            else if (s_all.Count == 0)
                Debug.LogWarning("[WaterSurface] 场景里没找到任何水面：没有任何 Renderer 的材质带 _WaterfallTurbulencePose。游泳 / 泡沫都不会生效。");
        }

        /// <summary>查询某点是否在水面以下（真正泡在水里）。</summary>
        public static bool IsUnderwater(Vector3 worldPos, float tolerance = 0f)
        {
            float y;
            if (!TrySample(worldPos, out y)) return false;
            return worldPos.y < y - tolerance;
        }

        /// <summary>找该点的水面体（离查询点最近的那片）。</summary>
        public static WaterSurface Find(Vector3 worldPos)
        {
            AutoRegisterIfNeeded();

            WaterSurface best = null;
            float bestDist = float.PositiveInfinity;

            for (int i = 0; i < s_all.Count; i++)
            {
                WaterSurface w = s_all[i];
                if (w == null || !w.isActiveAndEnabled) continue;
                if (!w.Contains(worldPos)) continue;

                float dist = Mathf.Abs(w.GetSurfaceY(worldPos) - worldPos.y);
                if (best == null || dist < bestDist) { best = w; bestDist = dist; }
            }
            return best;
        }

        void OnDrawGizmosSelected()
        {
            Renderer r = GetRenderer();
            if (r == null) return;
            Bounds b = r.bounds;
            Gizmos.color = new Color(0.2f, 0.8f, 1f, 0.35f);
            Gizmos.DrawWireCube(new Vector3(b.center.x, GetSurfaceY(b.center), b.center.z),
                                new Vector3(b.size.x, 0.01f, b.size.z));
        }
    }
}
