using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 标记「会与水面接触」的物体。把它的水平足迹（有向矩形）每帧推给水体着色器，
    /// 水面就会在该物体水线处生成一圈白色浮沫。
    ///
    /// 用几何足迹而不是场景深度，是因为 _CameraDepthTexture 的可用性依赖渲染器配置
    /// （深度预通道 / 手动 Camera.Render / 某些 SRP Feature 都会让它变成黑图），
    /// 而足迹法只依赖自己写入的全局数组，任何管线配置下都稳定。
    ///
    /// 用法：把本组件挂到石柱、岩石、木桩等会插进水里的物体上即可，无需其它设置。
    /// </summary>
    [DisallowMultipleComponent]
    [ExecuteAlways]
    public class WaterContactSource : MonoBehaviour
    {
        [Tooltip("水平半尺寸（本地空间）。勾选 Auto From Bounds 时自动从渲染器取。")]
        public Vector2 halfExtents = new Vector2(0.3f, 0.3f);

        [Tooltip("浮沫带宽（世界单位）。物体越大可以给越宽。")]
        [Range(0.02f, 2f)]
        public float foamWidth = 0.40f;

        [Tooltip("从渲染器的本地包围盒自动推算 halfExtents（旋转不影响）")]
        public bool autoFromBounds = true;

        [Tooltip("关掉后这个物体不再在水面产生浮沫")]
        public bool contributing = true;

        /// <summary>着色器一次最多处理的接触物数量，与 shader 里的数组长度保持一致</summary>
        public const int MaxContacts = 8;

        static readonly List<WaterContactSource> s_all = new List<WaterContactSource>();
        static readonly Vector4[] s_a = new Vector4[MaxContacts];
        static readonly Vector4[] s_b = new Vector4[MaxContacts];
        static bool s_hooked;

        void OnEnable()
        {
            if (!s_all.Contains(this)) s_all.Add(this);
            Hook();
            if (autoFromBounds) RecalcFromBounds();
        }

        void OnDisable()
        {
            s_all.Remove(this);
            PushAll();
        }

        void OnValidate()
        {
            if (autoFromBounds) RecalcFromBounds();
        }

        void LateUpdate()
        {
            PushAll();
        }

        /// <summary>从渲染器本地包围盒推 halfExtents —— 用 localBounds 所以不受旋转影响</summary>
        public void RecalcFromBounds()
        {
            var r = GetComponent<Renderer>();
            if (r == null) return;
            Vector3 e = r.localBounds.extents;
            Vector3 s = transform.lossyScale;
            halfExtents = new Vector2(
                Mathf.Max(0.01f, e.x * Mathf.Abs(s.x)),
                Mathf.Max(0.01f, e.z * Mathf.Abs(s.z)));
        }

        static void Hook()
        {
            if (s_hooked) return;
            s_hooked = true;
            RenderPipelineManager.beginCameraRendering += OnBeginCamera;
        }

        static void OnBeginCamera(ScriptableRenderContext ctx, Camera cam)
        {
            PushAll();
        }

        /// <summary>把当前所有接触物的足迹写进全局数组（离水面最近的优先）</summary>
        public static void PushAll()
        {
            int n = 0;
            for (int i = 0; i < s_all.Count && n < MaxContacts; i++)
            {
                var c = s_all[i];
                if (c == null || !c.isActiveAndEnabled || !c.contributing) continue;

                float yaw = c.transform.eulerAngles.y * Mathf.Deg2Rad;
                Vector3 p = c.transform.position;

                s_a[n] = new Vector4(p.x, p.z,
                                     Mathf.Max(c.halfExtents.x, 1e-3f),
                                     Mathf.Max(c.halfExtents.y, 1e-3f));
                s_b[n] = new Vector4(Mathf.Cos(yaw), Mathf.Sin(yaw),
                                     Mathf.Max(c.foamWidth, 1e-3f), 1f);
                n++;
            }

            for (int i = n; i < MaxContacts; i++)
            {
                s_a[i] = Vector4.zero;
                s_b[i] = Vector4.zero;
            }

            Shader.SetGlobalVectorArray("_IW_ContactA", s_a);
            Shader.SetGlobalVectorArray("_IW_ContactB", s_b);
        }
    }
}
