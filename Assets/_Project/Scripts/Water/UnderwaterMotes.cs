using UnityEngine;
using UnityEngine.Rendering;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 水下浮游颗粒：跟随相机的粒子盒，给水下提供「体积参照物」。
    ///
    /// 为什么必须要有这一层：只有雾和调色时，画面是"变青了"，但读不出"水"这种介质；
    /// 颗粒提供了尺度与运动，是吉卜力式"空气里飘着东西"直接对应到水下的做法
    /// （风格指南 §1.5：少量、慢速、有明暗差异）。
    ///
    /// 粒子材质是程序化软圆点（Resources/Shaders/UnderwaterMote），不需要贴图资产。
    /// </summary>
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Underwater Motes")]
    public sealed class UnderwaterMotes : MonoBehaviour
    {
        [Tooltip("跟随的相机。留空则取 Camera.main")]
        public Transform follow;

        [Tooltip("粒子盒尺寸（米）：宽 / 高 / 深")]
        public Vector3 boxSize = new Vector3(12f, 7f, 12f);

        [Tooltip("粒子盒中心沿相机前方的偏移")]
        public float forwardOffset = 4f;

        [Tooltip("最大粒子数")]
        public int maxParticles = 160;

        [Tooltip("发射率（个/秒）")]
        public float emissionRate = 12f;

        [Tooltip("两种交替的颗粒色（暖冷交替才有笔触感）")]
        public Color warmColor = new Color(0.965f, 0.949f, 0.886f, 0.55f);
        public Color coolColor = new Color(0.749f, 0.890f, 0.925f, 0.45f);

        [Tooltip("单个颗粒尺寸范围（米）")]
        public Vector2 sizeRange = new Vector2(0.015f, 0.05f);

        [Tooltip("寿命范围（秒）")]
        public Vector2 lifetimeRange = new Vector2(6f, 12f);

        [Tooltip("留空则运行时用 Resources/Shaders/UnderwaterMote 建一个")]
        public Material material;

        ParticleSystem _ps;
        ParticleSystemRenderer _renderer;
        Material _runtimeMaterial;
        float _nextRebind;

        void Awake()
        {
            BuildMaterial();
            BuildParticles();
        }

        void Start()
        {
            if (follow == null && Camera.main != null) follow = Camera.main.transform;
        }

        void OnDestroy()
        {
            if (_runtimeMaterial != null) Destroy(_runtimeMaterial);
        }

        void Update()
        {
            if (follow == null)
            {
                if (Time.unscaledTime < _nextRebind) return;
                _nextRebind = Time.unscaledTime + 1f;
                if (Camera.main != null) follow = Camera.main.transform;
                if (follow == null) return;
            }

            float amount = UnderwaterCameraController.Instance != null
                ? UnderwaterCameraController.Instance.Submerge
                : 0f;
            bool want = amount > 0.01f;

            var emission = _ps.emission;
            bool emitting = emission.enabled;
            if (emitting != want) emission.enabled = want;
            if (_renderer != null && _renderer.enabled != want) _renderer.enabled = want;

            if (!want) return;

            // 盒子跟着相机走（simulationSpace = Local，所以粒子会整体跟过来）
            transform.position = follow.position + follow.forward * forwardOffset;
        }

        void BuildParticles()
        {
            _ps = gameObject.AddComponent<ParticleSystem>();
            _ps.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);

            var main = _ps.main;
            main.duration = 5f;
            main.loop = true;
            main.playOnAwake = true;
            main.startLifetime = new ParticleSystem.MinMaxCurve(lifetimeRange.x, lifetimeRange.y);
            main.startSpeed = new ParticleSystem.MinMaxCurve(0.01f, 0.05f);
            main.startSize = new ParticleSystem.MinMaxCurve(sizeRange.x, sizeRange.y);
            main.startColor = new ParticleSystem.MinMaxGradient(warmColor, coolColor);
            main.startRotation = new ParticleSystem.MinMaxCurve(0f, Mathf.PI * 2f);
            main.maxParticles = Mathf.Max(8, maxParticles);
            main.simulationSpace = ParticleSystemSimulationSpace.Local;
            main.scalingMode = ParticleSystemScalingMode.Hierarchy;
            main.gravityModifier = 0f;

            var emission = _ps.emission;
            emission.enabled = false;
            emission.rateOverTime = Mathf.Max(0.1f, emissionRate);

            var shape = _ps.shape;
            shape.enabled = true;
            shape.shapeType = ParticleSystemShapeType.Box;
            shape.scale = boxSize;

            var velocity = _ps.velocityOverLifetime;
            velocity.enabled = true;
            velocity.space = ParticleSystemSimulationSpace.Local;
            velocity.x = new ParticleSystem.MinMaxCurve(-0.02f, 0.02f);
            velocity.y = new ParticleSystem.MinMaxCurve(0.02f, 0.08f);   // 缓慢上浮
            velocity.z = new ParticleSystem.MinMaxCurve(-0.02f, 0.02f);

            var noise = _ps.noise;
            noise.enabled = true;
            noise.strength = 0.06f;
            noise.frequency = 0.25f;
            noise.scrollSpeed = 0.1f;

            var colorOverLifetime = _ps.colorOverLifetime;
            colorOverLifetime.enabled = true;
            var gradient = new Gradient();
            gradient.SetKeys(
                new[] { new GradientColorKey(Color.white, 0f), new GradientColorKey(Color.white, 1f) },
                new[]
                {
                    new GradientAlphaKey(0f, 0f),
                    new GradientAlphaKey(1f, 0.22f),
                    new GradientAlphaKey(1f, 0.78f),
                    new GradientAlphaKey(0f, 1f)
                });
            colorOverLifetime.color = new ParticleSystem.MinMaxGradient(gradient);

            _renderer = GetComponent<ParticleSystemRenderer>();
            _renderer.renderMode = ParticleSystemRenderMode.Billboard;
            if (material != null) _renderer.material = material;
            _renderer.shadowCastingMode = ShadowCastingMode.Off;
            _renderer.receiveShadows = false;
            _renderer.enabled = false;

            _ps.Play();
        }

        void BuildMaterial()
        {
            if (material != null) return;

            var shader = Resources.Load<Shader>("Shaders/UnderwaterMote");
            if (shader == null) shader = Shader.Find("WindmillFarm/Underwater Mote");
            if (shader == null)
            {
                Debug.LogWarning("[UnderwaterMotes] 找不到 WindmillFarm/Underwater Mote 着色器，浮游颗粒不会显示。", this);
                return;
            }

            _runtimeMaterial = new Material(shader) { hideFlags = HideFlags.DontSave };
            _runtimeMaterial.name = "UnderwaterMote (Runtime)";
            material = _runtimeMaterial;
        }
    }
}
