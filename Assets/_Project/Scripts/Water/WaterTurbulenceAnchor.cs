using System.Collections.Generic;
using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 驱动第三方水体包（FullOpaqueWater&Waterfall）S_Water 里的两处湍流细节：
    ///
    ///   ① 瀑布落点向外扩散的同心涟漪（WaterfallImpact）
    ///      shader 里的实现是：
    ///        sm   = sphereMask(center = _WaterfallTurbulencePose(x, z), hardness = 1 - _WaterfallTurbulenceSize)
    ///        ring = sm * pow(saturate(sin((sqrt(sm) + TIME * _WaterfallTurbulenceSpeed)
    ///                                          * _WaterfallTurbulenceWaves)), 4)
    ///      sqrt(sm) 就是「到落点的归一化径向距离」，拿它当相位再推进 TIME 就得到向外扩散的环。
    ///
    ///   ② 角色在水面拖出的泡沫尾迹（CharacterTrail）
    ///        d    = P2 - P1                       // P2 = 0.2s 前的位置
    ///        proj = sat(dot(PosW - P1, d) / dot(d, d))
    ///        foam = sat(1 - step(_TargetTurbulenceStep,
    ///                            softLight(len((PosW - P1) - proj * d) + proj, 噪声)))
    ///
    /// 为什么搬到别的场景就没了：
    ///   `_WaterfallTurbulencePose` 是**材质上的固定世界坐标**，值就是 demo 场景里那个瀑布落点
    ///   (13.87, -21.07)。把水复制到别的地图后，落点在别的坐标，球遮罩中心还留在 demo 那边，
    ///   于是 sm≈0、ring=0，看上去「这个细节丢了」。
    ///   角色拖尾同理：它靠 `VFX/TargetPosition` 脚本每帧写全局量，脚本没一起搬过去，
    ///   P1/P2 就一直是材质里那个旧值。
    ///
    /// 用法：
    ///   · 在瀑布落点放一个空物体，挂本组件，mode = WaterfallImpact；
    ///   · 在角色身上挂一个，mode = CharacterTrail；
    ///   · waterRenderers 留空会自动找场景里材质带 `_WaterfallTurbulencePose` 的水面。
    /// 值通过 MaterialPropertyBlock 写，**不改材质资产**，所以 demo 场景不会受影响。
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Water Turbulence Anchor")]
    public class WaterTurbulenceAnchor : MonoBehaviour
    {
        public enum Mode
        {
            WaterfallImpact,
            CharacterTrail
        }

        public Mode mode = Mode.WaterfallImpact;

        [Tooltip("要驱动的水面 Renderer。留空则自动收集场景里材质带 _WaterfallTurbulencePose 的 Renderer")]
        public Renderer[] waterRenderers;

        [Tooltip("落点相对本物体世界 XZ 的偏移，用来微调环心（一般留 0）")]
        public Vector2 impactOffset = Vector2.zero;

        [Tooltip("CharacterTrail 用：历史采样时长，越大拖尾越长")]
        [Range(0.02f, 1f)]
        public float historySeconds = 0.2f;

        [Tooltip("同时写入同名全局量（兼容材质里没有该属性、只吃全局的情况）")]
        public bool alsoSetGlobal = true;

        static readonly int IdWaterfall = Shader.PropertyToID("_WaterfallTurbulencePose");
        static readonly int IdTarget    = Shader.PropertyToID("_TargetTurbulencePose");
        static readonly int IdTarget2   = Shader.PropertyToID("_TargetTurbulencePose2");

        readonly Dictionary<Renderer, MaterialPropertyBlock> _blocks = new Dictionary<Renderer, MaterialPropertyBlock>();
        readonly Dictionary<(Renderer, int), Vector4> _last = new Dictionary<(Renderer, int), Vector4>();
        readonly Queue<(float t, Vector3 p)> _history = new Queue<(float, Vector3)>();

        void OnEnable()
        {
            _history.Clear();
            if (waterRenderers == null || waterRenderers.Length == 0)
                waterRenderers = FindWaterRenderers();
        }

        void OnValidate()
        {
            _blocks.Clear();
            _last.Clear();
            if (waterRenderers == null || waterRenderers.Length == 0)
                waterRenderers = FindWaterRenderers();
        }

        void Update()
        {
            if (waterRenderers == null || waterRenderers.Length == 0) return;

            if (mode == Mode.WaterfallImpact) ApplyImpact();
            else ApplyTrail();
        }

        void ApplyImpact()
        {
            Vector3 p = transform.position;
            var v = new Vector4(p.x + impactOffset.x, p.z + impactOffset.y, 0f, 0f);

            for (int i = 0; i < waterRenderers.Length; i++)
                Write(waterRenderers[i], IdWaterfall, v);

            if (alsoSetGlobal) Shader.SetGlobalVector(IdWaterfall, v);
        }

        void ApplyTrail()
        {
            float now = Time.realtimeSinceStartup;
            Vector3 current = transform.position;

            _history.Enqueue((now, current));

            Vector3 past = current;
            while (_history.Count > 0)
            {
                var (t, pos) = _history.Peek();
                if (now - t > historySeconds) _history.Dequeue();
                else { past = pos; break; }
            }

            var vCur  = new Vector4(current.x, current.y, current.z, 0f);
            var vPast = new Vector4(past.x, past.y, past.z, 0f);

            for (int i = 0; i < waterRenderers.Length; i++)
            {
                Write(waterRenderers[i], IdTarget, vCur);
                Write(waterRenderers[i], IdTarget2, vPast);
            }

            if (alsoSetGlobal)
            {
                Shader.SetGlobalVector(IdTarget, vCur);
                Shader.SetGlobalVector(IdTarget2, vPast);
            }
        }

        void Write(Renderer r, int id, Vector4 v)
        {
            if (r == null) return;

            var key = (r, id);
            if (_last.TryGetValue(key, out Vector4 prev) &&
                (prev - v).sqrMagnitude < 1e-8f) return;

            if (!_blocks.TryGetValue(r, out MaterialPropertyBlock mpb))
            {
                mpb = new MaterialPropertyBlock();
                r.GetPropertyBlock(mpb);
                _blocks[r] = mpb;
            }

            mpb.SetVector(id, v);
            r.SetPropertyBlock(mpb);
            _last[key] = v;
        }

        /// <summary>找出场景里材质带 _WaterfallTurbulencePose 的面 Renderer。</summary>
        public static Renderer[] FindWaterRenderers()
        {
            var found = new List<Renderer>();
            foreach (Renderer r in Object.FindObjectsOfType<Renderer>())
            {
                if (r is ParticleSystemRenderer || r is SpriteRenderer) continue;
                Material[] mats = r.sharedMaterials;
                for (int i = 0; i < mats.Length; i++)
                {
                    if (mats[i] != null && mats[i].HasProperty(IdWaterfall))
                    {
                        found.Add(r);
                        break;
                    }
                }
            }
            return found.ToArray();
        }
    }
}
