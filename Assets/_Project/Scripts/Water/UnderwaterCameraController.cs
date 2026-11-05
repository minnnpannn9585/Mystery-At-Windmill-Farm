using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水下状态中心：挂在主相机上。
    ///
    /// 职责只有三件：
    ///   1. 判定「相机此刻在水面下多深」（滞回 + 平滑），输出 0~1 的 Submerge；
    ///   2. 用这个 0~1 驱动一份**运行时创建的水下调色 Volume**（复用现有后处理组件，不新写着色器）；
    ///   3. 把 0~1 和太阳方向下发给着色器全局（水面下表面 Shell / 全屏雾 / 浮游颗粒都读它们）。
    ///
    /// 为什么不把调色做成 .asset：这个工程是运行时生成玩家的，水下调色和「状态」强绑定，
    /// 参数放 Inspector 上比藏在资产里更好调；也不需要手改 YAML。
    /// </summary>
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Underwater Camera Controller")]
    public sealed class UnderwaterCameraController : MonoBehaviour
    {
        public static UnderwaterCameraController Instance { get; private set; }

        public static readonly int IdUnderwaterAmount = Shader.PropertyToID("_UnderwaterAmount");
        public static readonly int IdUnderwaterSunDir = Shader.PropertyToID("_UnderwaterSunDir");

        [Header("检测 / Detection")]
        [Tooltip("相机沉到水面下多少米才算入水（进入阈值）")]
        public float enterDepth = 0.15f;

        [Tooltip("相机升到水面下多少米以内算出水（退出阈值，必须小于进入阈值，形成滞回）")]
        public float exitDepth = 0.04f;

        [Tooltip("状态切换的平滑时长（秒）。0 = 硬切")]
        public float blendTime = 0.35f;

        [Header("调色 / Grading（水下值，水上由原有 Global Volume 负责）")]
        public bool applyGrading = true;

        [Tooltip("曝光补偿")]
        public float postExposure = -0.25f;

        [Tooltip("对比度（负值更柔）")]
        public float contrast = -12f;

        [Tooltip("饱和度")]
        public float saturation = -2f;

        [Tooltip("整体染色（Alpha 即强度）")]
        public Color colorFilter = new Color(0.56f, 0.83f, 0.90f, 0.18f);

        [Tooltip("白平衡：温度（负 = 更冷）")]
        public float temperature = -10f;

        [Tooltip("白平衡：色调（正 = 偏青绿）")]
        public float tint = 5f;

        [Tooltip("暗角强度")]
        public float vignetteIntensity = 0.30f;

        [Tooltip("色差（只做极轻的介质暗示，别超过 0.2）")]
        public float chromaticAberration = 0.12f;

        [Tooltip("Bloom 阈值（水下调高，只让亮斑溢出）")]
        public float bloomThreshold = 1.15f;

        [Tooltip("Bloom 强度")]
        public float bloomIntensity = 0.26f;

        [Tooltip("阴影偏冷：RGB 乘子（1,1,1 = 不变）")]
        public Vector3 shadowTint = new Vector3(0.93f, 1.00f, 1.08f);

        [Tooltip("高光压暖：RGB 乘子（1,1,1 = 不变）")]
        public Vector3 highlightTint = new Vector3(1.02f, 1.00f, 0.98f);

        /// <summary>相机此刻是否在水下（已含滞回）。</summary>
        public bool IsUnderwater { get; private set; }

        /// <summary>0~1 的浸没程度，所有水下表现层都读它。</summary>
        public float Submerge { get; private set; }

        Volume _volume;
        VolumeProfile _profile;

        void Awake()
        {
            Instance = this;
            BuildGrading();
            PushSunDirection();
        }

        void OnDestroy()
        {
            if (_volume != null) Destroy(_volume.gameObject);
            if (_profile != null) Destroy(_profile);
            if (Instance == this) Instance = null;
            Shader.SetGlobalFloat(IdUnderwaterAmount, 0f);
        }

        void Update()
        {
            float waterY;
            bool hasWater = WaterSurface.TrySample(ProbePosition(), out waterY);
            float depth = hasWater ? waterY - transform.position.y : -1000f;

            // 滞回：已经在水里就用更低的退出阈值，避免贴着水面抖
            bool inside = IsUnderwater ? depth > exitDepth : depth > enterDepth;
            IsUnderwater = inside;

            float target = inside ? 1f : 0f;
            if (blendTime <= 0.0001f) Submerge = target;
            else Submerge = Mathf.MoveTowards(Submerge, target, Time.deltaTime / blendTime);

            if (Submerge < 0.001f) Submerge = 0f;

            if (_volume != null) _volume.weight = Submerge;
            Shader.SetGlobalFloat(IdUnderwaterAmount, Submerge);
            PushSunDirection();
        }

        /// <summary>
        /// 用「玩家所在的 XZ + 相机的高度」去采样水面。
        ///
        /// 直接用相机位置会有一个必然出问题的情况：第三人称相机吊在玩家身后 2.5m，
        /// 玩家潜到池子边缘时相机还在岸上外侧，XZ 落在水面范围之外 → 水下一秒有一秒没有。
        /// 高度必须用相机的（决定"镜头是不是在水面下"），XZ 必须用玩家的（决定"在不在这片水里"）。
        /// </summary>
        Vector3 ProbePosition()
        {
            if (_player == null && Time.unscaledTime >= _nextPlayerSearch)
            {
                _nextPlayerSearch = Time.unscaledTime + 1f;
                var go = GameObject.FindGameObjectWithTag("Player");
                if (go != null) _player = go.transform;
            }

            if (_player == null) return transform.position;
            return new Vector3(_player.position.x, transform.position.y, _player.position.z);
        }

        Transform _player;
        float _nextPlayerSearch;

        void PushSunDirection()
        {
            var sun = RenderSettings.sun;
            Vector3 dir = sun != null
                ? (-sun.transform.forward).normalized           // 指向太阳
                : new Vector3(0.35f, 0.85f, 0.25f).normalized;
            Shader.SetGlobalVector(IdUnderwaterSunDir, new Vector4(dir.x, dir.y, dir.z, 0f));
        }

        /// <summary>运行时拼一份 VolumeProfile：只覆盖需要的组件，其它沿用全局 Volume。</summary>
        void BuildGrading()
        {
            if (!applyGrading) return;

            var go = new GameObject("[UnderwaterVolume]");
            // 相机的 Volume LayerMask 在这个工程里只勾了 layer 0，Global Volume 也在 layer 0。
            // 这里必须显式钉死 0，否则相机换层时调色会静默失效。
            go.layer = 0;
            go.hideFlags = HideFlags.DontSave;

            _volume = go.AddComponent<Volume>();
            _volume.isGlobal = true;
            _volume.priority = 30f;               // 高于场景里的 Global Volume(0)
            _volume.weight = 0f;

            _profile = ScriptableObject.CreateInstance<VolumeProfile>();
            _profile.hideFlags = HideFlags.DontSave;
            _volume.sharedProfile = _profile;

            var ca = _profile.Add<ColorAdjustments>(true);
            ca.active = true;
            ca.postExposure.Override(postExposure);
            ca.contrast.Override(contrast);
            ca.saturation.Override(saturation);
            ca.colorFilter.Override(colorFilter);

            var wb = _profile.Add<WhiteBalance>(true);
            wb.active = true;
            wb.temperature.Override(temperature);
            wb.tint.Override(tint);

            var vig = _profile.Add<Vignette>(true);
            vig.active = true;
            vig.intensity.Override(vignetteIntensity);
            vig.smoothness.Override(0.7f);
            vig.color.Override(new Color(0.07f, 0.23f, 0.29f, 1f));

            var ab = _profile.Add<ChromaticAberration>(true);
            ab.active = true;
            ab.intensity.Override(chromaticAberration);

            var smh = _profile.Add<ShadowsMidtonesHighlights>(true);
            smh.active = true;
            smh.shadows.Override(new Vector4(shadowTint.x, shadowTint.y, shadowTint.z, 0f));
            smh.highlights.Override(new Vector4(highlightTint.x, highlightTint.y, highlightTint.z, 0f));

            var bloom = _profile.Add<Bloom>(true);
            bloom.active = true;
            bloom.threshold.Override(bloomThreshold);
            bloom.intensity.Override(bloomIntensity);
        }

        /// <summary>调试用：在 Scene 视图画出判定线。</summary>
        void OnDrawGizmosSelected()
        {
            float waterY;
            if (!WaterSurface.TrySample(transform.position, out waterY)) return;
            Gizmos.color = new Color(0.3f, 0.9f, 1f, 0.5f);
            Gizmos.DrawLine(new Vector3(transform.position.x - 3f, waterY, transform.position.z),
                            new Vector3(transform.position.x + 3f, waterY, transform.position.z));
        }
    }
}
