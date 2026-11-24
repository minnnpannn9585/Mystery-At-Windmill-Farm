using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 让「任何插在水里的物体」都产生岸边泡沫 + 向外扩散的涟漪 ——
    /// 荷叶片、石头、木桩、玩家都可以用同一个组件。
    ///
    /// 实现方式是复用第三方水体包自带的 VFX_Ripple 预制体
    /// （内部就是 Foam + Ripple 两套粒子，正是 demo 里角色脚下那圈东西）。
    ///
    /// ★ 设计要点（上一版踩过的坑，别再退回去）：
    ///   特效是**编辑器里就摆好的真实子物体**（`foamInstance`），不是运行时才生成、
    ///   也不是靠 HideFlags 藏的预览实例。这样：
    ///     · 不按 Play 也能直接看到、直接调；
    ///     · 不依赖 WaterSurface 是否注册成功 —— 查不到水面就拿物体自身高度兜底；
    ///     · 不会被 SetActive(false) 静默藏掉。
    ///
    ///   荷叶这类有自身缩放的父物体，子物体要**抵消父级缩放**才能保持世界尺寸，
    ///   否则一片 0.33 缩放的叶子会把特效压成一条线（这也是上一版「看不到」的原因之一）。
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Water Foam Emitter")]
    public class WaterFoamEmitter : MonoBehaviour
    {
        [Tooltip("特效实例（VFX_Ripple 的子物体）。用菜单 Tools/Water/Foam/Add Emitter ... 会自动建好")]
        public Transform foamInstance;

        [Tooltip("运行时兜底用的预制体（玩家这类运行时才生成的物体需要）。留空则用 Resources/Water/PlayerFoam")]
        public GameObject foamPrefab;

        [Tooltip("实例相对水面的高度偏移，给一点点避免穿模")]
        public float surfaceOffset = 0.02f;

        [Tooltip("自动缩放时，目标直径占包围盒最大水平尺寸的比例")]
        [Range(0.2f, 3f)]
        public float autoScaleFactor = 1f;

        [Tooltip("算包围盒用的 Renderer。留空 = 自己身上的 Renderer。LODGroup 根节点填它的 LOD0")]
        public Renderer boundsSource;

        [Tooltip("勾上后由组件接管子物体的缩放（按包围盒自动算直径）。\n" +
                 "如果是场景里已经摆好、自己调过缩放的特效（比如 PlayerFoam），取消勾选，原样保留")]
        public bool driveScale = true;

        [Tooltip("勾上后按包围盒自动决定特效直径；不勾则用固定 scale")]
        public bool autoScaleToBounds = true;

        [Tooltip("不勾 autoScaleToBounds 时使用的世界直径（米）")]
        public float scale = 1f;

        [Tooltip("特效整体缩放倍率（1 = 保持原始尺寸，0.333 ≈ 三分之一）。\n" +
                 "非 1 时只改子物体的 localScale，不动粒子参数；对「已摆好的场景特效」同样生效")]
        [Range(0.05f, 4f)]
        public float scaleMultiplier = 1f;

        [Tooltip("只在物体位于水面以下时才显示（玩家用，出水立刻消失）")]
        public bool visibleOnlyWhenInWater;

        [Tooltip("离水面超过这个距离就隐藏特效。默认关掉 —— 别再让「判定不对」变成「什么都看不见」")]
        public bool hideWhenOutOfWater;

        [Tooltip("hideWhenOutOfWater 的判定距离（米）")]
        public float hideDistance = 3f;

        [Tooltip("运行时生成的实例名")]
        public string instanceName = "WaterFoam";

        [Tooltip("粒子发射率（个/秒）。★ 包里的 VFX_Ripple 预制体本身 rateOverTime = 0、也没有 burst，" +
                 "实例化出来是**空的**，必须靠这个值把发射打开。觉得泡沫太密/太稀就调它")]
        public float emissionRate = 8f;

        public const string DefaultResourcePath = "Water/PlayerFoam";

        // 查不到水面时用自身高度兜底是预期行为（小游戏 / 无水面场景），
        // 每个 emitter 各报一条、换场景/重进 Play 又报一遍会淹没 Console。
        // 改成整个会话只报一次，保留「场景本该有水却没检测到」的诊断价值。
        static bool s_warnedNoWater;
        bool _triedSpawn;
        CharacterController _cc;

        // 原始 localScale 必须序列化：本组件是 [ExecuteAlways]，
        // 不存下来的话每次域重载都会把「已缩小的值」当成原始值，越缩越小。
        [SerializeField, HideInInspector] Vector3 baseLocalScale = Vector3.one;
        [SerializeField, HideInInspector] bool baseScaleCaptured;

        void OnEnable()
        {
            _triedSpawn = false;
            if (_cc == null) _cc = GetComponent<CharacterController>();
            ApplyEmissionRate();
        }

        /// <summary>
        /// 把特效下所有粒子系统的发射率打开。
        /// VFX_Ripple 原样是 rateOverTime = 0 的空壳，不设这个就什么都看不到。
        /// </summary>
        public void ApplyEmissionRate()
        {
            if (foamInstance == null) return;

            float want = Mathf.Max(0f, emissionRate);
            var systems = foamInstance.GetComponentsInChildren<ParticleSystem>(true);
            for (int i = 0; i < systems.Length; i++)
            {
                var em = systems[i].emission;
                if (!em.enabled) continue;

                // 只补「本来就没在发射」的（VFX_Ripple 默认 rateOverTime = 0）。
                // 已经调好发射率的场景特效，一个字节都不动，保持原封不动。
                if (em.rateOverTime.constant > 0f) continue;

                em.rateOverTime = new ParticleSystem.MinMaxCurve(want);
            }
        }

        void LateUpdate()
        {
            if (foamInstance == null && Application.isPlaying && !_triedSpawn)
            {
                _triedSpawn = true;
                SpawnAtRuntime();
            }
            if (foamInstance == null) return;

            UpdatePlacement();
        }

        void SpawnAtRuntime()
        {
            GameObject prefab = foamPrefab != null ? foamPrefab : Resources.Load<GameObject>(DefaultResourcePath);
            if (prefab == null)
            {
                Debug.LogWarning("[WaterFoamEmitter] " + name + " 找不到特效预制体（" + DefaultResourcePath + "），跳过。", this);
                return;
            }

            GameObject go = Instantiate(prefab, transform);
            go.name = string.IsNullOrEmpty(instanceName) ? "WaterFoam" : instanceName;
            foamInstance = go.transform;
            foamInstance.rotation = Quaternion.identity;
            ApplyEmissionRate();
        }

        void UpdatePlacement()
        {
            Vector3 p = transform.position;

            // 查不到水面就用物体自身高度兜底（荷叶本来就浮在水面上）。
            // 注意不能先赋初值再 out —— TrySample 失败时会把 out 写成 0，兜底值会被冲掉。
            float waterY;
            bool hasWater = WaterSurface.TrySample(p, out waterY);
            if (!hasWater)
            {
                waterY = p.y;
                WarnNoWaterOnce();
            }

            // 只在水中显示：判定必须和 PlayerController 的入水判定同源（脚底 vs 水面）。
            // 用 transform.position（胶囊中心）会漏：玩家半身入水时中心已在水面之上。
            if (_cc == null) _cc = GetComponent<CharacterController>();
            bool submerged = _cc != null ? _cc.bounds.min.y < waterY : p.y < waterY;
            if (visibleOnlyWhenInWater && !(hasWater && submerged))
            {
                if (foamInstance.gameObject.activeSelf) foamInstance.gameObject.SetActive(false);
                return;
            }

            if (hideWhenOutOfWater && Mathf.Abs(p.y - waterY) > Mathf.Max(0.01f, hideDistance))
            {
                if (foamInstance.gameObject.activeSelf) foamInstance.gameObject.SetActive(false);
                return;
            }
            if (!foamInstance.gameObject.activeSelf) foamInstance.gameObject.SetActive(true);

            // 值没变就别写 transform —— 编辑态每帧改 transform 会把场景一路标脏
            Vector3 target = new Vector3(p.x, waterY + surfaceOffset, p.z);
            if ((foamInstance.position - target).sqrMagnitude > 1e-8f)
                foamInstance.position = target;

            ApplyWorldScale();
        }

        /// <summary>
        /// 记下子物体「原始」localScale，供 scaleMultiplier 换算用。
        /// 只抓一次并序列化：之后怎么调倍率都是「原始尺寸 × 倍率」，不会累积。
        /// </summary>
        void CaptureBaseScale()
        {
            if (baseScaleCaptured) return;
            baseLocalScale = foamInstance.localScale;
            baseScaleCaptured = true;
        }

        /// <summary>把子物体缩放到「世界直径 = 目标直径」，抵消父级缩放。</summary>
        void ApplyWorldScale()
        {
            if (!driveScale)
            {
                // 不接管缩放（场景里已摆好的特效 / 玩家 PlayerFoam）：
                // 只在倍率不是 1 时，按「第一次看到的 localScale」乘一下，其余参数一个字不动。
                if (Mathf.Approximately(scaleMultiplier, 1f)) return;

                CaptureBaseScale();
                Vector3 wantFixed = baseLocalScale * scaleMultiplier;
                if ((foamInstance.localScale - wantFixed).sqrMagnitude > 1e-8f)
                    foamInstance.localScale = wantFixed;
                return;
            }

            float diameter = Mathf.Max(0.01f, scale);
            if (autoScaleToBounds)
            {
                Renderer r = boundsSource != null ? boundsSource : GetComponent<Renderer>();
                if (r != null)
                {
                    Vector3 sz = r.bounds.size;
                    diameter = Mathf.Max(0.01f, Mathf.Max(sz.x, sz.z) * Mathf.Max(0.01f, autoScaleFactor));
                }
            }
            // 倍率放在最后乘：自动按包围盒算直径时才不会把倍率吃掉
            diameter *= Mathf.Max(0.01f, scaleMultiplier);

            Vector3 ls = transform.lossyScale;
            Vector3 want = new Vector3(
                diameter / Mathf.Max(1e-4f, Mathf.Abs(ls.x)),
                diameter / Mathf.Max(1e-4f, Mathf.Abs(ls.y)),
                diameter / Mathf.Max(1e-4f, Mathf.Abs(ls.z)));

            if ((foamInstance.localScale - want).sqrMagnitude > 1e-8f)
                foamInstance.localScale = want;
        }

        void WarnNoWaterOnce()
        {
            if (!Application.isPlaying) return;

            // 分清两种情况，别把「站岸上」误报成「没注册水面」：
            //   1) 场景里一片 WaterSurface 都没有 —— 才是真的异常，提示一次；
            //   2) 已经注册了水面，只是当前 XZ 不在任何水面范围内（玩家出生在岸上）——
            //      这是正常状态，UpdatePlacement 已经用物体自身高度兜底，不需要警告。
            if (WaterSurface.All.Count > 0) return;
            if (s_warnedNoWater) return;
            s_warnedNoWater = true;
            Debug.LogWarning("[WaterFoamEmitter] " + name + " 在 " + transform.position +
                " 查不到水面：当前没有任何 WaterSurface 注册（注册数 = 0），已改用物体自身高度兜底。此提示整个会话只报一次。", this);
        }

        void OnValidate()
        {
            scale = Mathf.Max(0.01f, scale);
            ApplyEmissionRate();
        }
    }
}
