using UnityEngine;
using UnityEngine.UI;
using WindmillFarm.Water;

namespace EggRescue
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class PlayerController : MonoBehaviour
    {
        public static PlayerController Instance { get; private set; }

        [SerializeField] float moveSpeed = 5.5f;
        [SerializeField] float sprintMultiplier = 1.45f;
        [SerializeField] float jumpHeight = 1.4f;
        [SerializeField] float gravity = -22f;
        [SerializeField] Transform cameraPivot;

        [Header("Swimming / 游泳")]
        [Tooltip("总开关")]
        [SerializeField] bool swimmingEnabled = true;

        [Tooltip("水中水平移动速度")]
        [SerializeField] float swimMoveSpeed = 3.0f;

        [Tooltip("按住空格时的上浮速度上限（米/秒）")]
        [SerializeField] float ascendSpeed = 2.2f;

        [Tooltip("松开空格后的缓慢下沉速度（米/秒）")]
        [SerializeField] float sinkSpeed = 0.55f;

        [Tooltip("上浮到离水面还差多少米就停住 —— 这就是「上浮高度可控」的落点，越大身体露出水面越少")]
        [SerializeField] float floatDepthBelowSurface = 0.15f;

        [Tooltip("竖直速度平滑，避免入水/出水时抖")]
        [SerializeField] float swimVerticalSmoothing = 10.0f;

        [Tooltip("开场自动把 PlayerFoam 泡沫特效挂到玩家身上（资源在 Resources/Water/PlayerFoam）")]
        [SerializeField] bool autoMountPlayerFoam = true;

        [Tooltip("场景里已经摆好的泡沫特效（PlayerFoam）。留空则运行时按名字自动找；再找不到才用 Resources 里的默认预制体")]
        [SerializeField] Transform playerFoam;

        [Tooltip("找不到 playerFoam 时按这个名字在场景里找")]
        [SerializeField] string playerFoamObjectName = "PlayerFoam";

        CharacterController _cc;
        Animator _animator;
        Vector3 _velocity;
        bool _grounded;
        float _jumpAnimLock;
        static readonly int SpeedId = Animator.StringToHash("Speed");
        static readonly int GroundedId = Animator.StringToHash("Grounded");
        static readonly int JumpId = Animator.StringToHash("Jump");
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        const float DebugMoveMultiplier = 3f;
        static bool _debugMoveEnabled = true;
        Text _debugLabel;
#endif

        public Transform CameraPivot { get { return cameraPivot; } }

        public void Teleport(Vector3 position, float yaw)
        {
            _velocity = Vector3.zero;
            if (_cc != null) _cc.enabled = false;
            transform.SetPositionAndRotation(position, Quaternion.Euler(0f, yaw, 0f));
            if (_cc != null) _cc.enabled = true;
        }

        void OnEnable()
        {
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            GameLocale.Changed += RefreshDebugLabel;
#endif
        }

        void OnDisable()
        {
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            GameLocale.Changed -= RefreshDebugLabel;
#endif
        }

        void Awake()
        {
            Instance = this;
            _cc = GetComponent<CharacterController>();
            _animator = GetComponentInChildren<Animator>();
            if (cameraPivot == null)
            {
                var pivot = new GameObject("CameraPivot");
                pivot.transform.SetParent(transform, false);
                pivot.transform.localPosition = new Vector3(0f, 1.15f, 0f);
                cameraPivot = pivot.transform;
            }
            gameObject.tag = "Player";
            if (GetComponent<PlayerWalkDust>() == null)
                gameObject.AddComponent<PlayerWalkDust>();

            // 开场把 PlayerFoam（VFX_Ripple 的副本）挂到玩家身上，入水时自动贴水面显示
            if (autoMountPlayerFoam) MountPlayerFoam();
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            var sceneName = UnityEngine.SceneManagement.SceneManager.GetActiveScene().name;
            if (!sceneName.StartsWith("ArtTest"))
                EnsureDebugLabel();
#endif
        }

        /// <summary>
        /// 把场景里已经摆好的 PlayerFoam **原封不动**挂到玩家身上：
        /// 不改缩放、不改粒子参数，只做三件事 ——
        ///   1) 挂成玩家的子物体，跟着玩家动；
        ///   2) 每帧贴到水面高度；
        ///   3) 入水显示、出水隐藏。
        /// 场景里找不到才回落到 Resources/Water/PlayerFoam 预制体。
        /// </summary>
        void MountPlayerFoam()
        {
            if (playerFoam == null && !string.IsNullOrEmpty(playerFoamObjectName))
            {
                var found = GameObject.Find(playerFoamObjectName);
                if (found != null) playerFoam = found.transform;
            }
            if (playerFoam == null && !string.IsNullOrEmpty(playerFoamObjectName))
            {
                // GameObject.Find 找不到未激活的，这里补一次（含未激活）
                var all = FindObjectsOfType<Transform>(true);
                for (int i = 0; i < all.Length; i++)
                {
                    if (all[i].parent == null && all[i].name == playerFoamObjectName)
                    { playerFoam = all[i]; break; }
                }
            }

            var foam = GetComponent<WaterFoamEmitter>();
            if (foam == null) foam = gameObject.AddComponent<WaterFoamEmitter>();

            foam.instanceName = "PlayerFoam";
            foam.visibleOnlyWhenInWater = true;   // 出水立刻看不到
            foam.driveScale = false;              // 原封不动：不接管缩放
            foam.autoScaleToBounds = false;
            foam.surfaceOffset = 0.02f;

            if (playerFoam != null)
            {
                playerFoam.SetParent(transform, true);   // 保留世界变换
                foam.foamInstance = playerFoam;
            }
        }

        void Update()
        {
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (Input.GetKeyDown(KeyCode.F8))
            {
                _debugMoveEnabled = !_debugMoveEnabled;
                RefreshDebugLabel();
            }
#endif
            if (GameEvents.InputLocked)
            {
                _velocity.x = 0f;
                _velocity.z = 0f;
                ApplyGravity();
                _cc.Move(_velocity * Time.deltaTime);
                _grounded = _cc.isGrounded;
                UpdateAnimator();
                return;
            }

            _grounded = _cc.isGrounded;
            if (_grounded && _velocity.y < 0f)
                _velocity.y = -2f;

            var input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            if (input.sqrMagnitude > 1f) input.Normalize();

            // ??????????? yaw???? LateUpdate ?? transform?
            // ????? Camera.main.transform ????????????????????????
            float yaw;
            if (ThirdPersonCamera.Instance != null)
                yaw = ThirdPersonCamera.Instance.Yaw;
            else
            {
                var cam = Camera.main;
                yaw = cam != null
                    ? cam.transform.eulerAngles.y
                    : (cameraPivot != null ? cameraPivot.eulerAngles.y : transform.eulerAngles.y);
            }
            var yawRot = Quaternion.Euler(0f, yaw, 0f);
            var wish = yawRot * new Vector3(input.x, 0f, input.y);
            var speed = moveSpeed * CurrentMoveMultiplier();
            var planar = wish * speed;

            if (planar.sqrMagnitude > 0.01f)
            {
                var look = Quaternion.LookRotation(planar.normalized, Vector3.up);
                transform.rotation = Quaternion.Slerp(transform.rotation, look, 12f * Time.deltaTime);
            }

            // ---- 游泳：接触到水面就算入水，完全在水面下也算在水里 ----
            // 用 CharacterController 的实际包围盒当身体，不要用 transform.position（center 不一定在高度一半）
            Bounds body = _cc.bounds;
            float feetY = body.min.y;

            float waterY = 0f;   // swimmingEnabled 为 false 时 TrySample 被短路，这里必须有初值
            bool hasWater = swimmingEnabled && WaterSurface.TrySample(transform.position, out waterY);

            bool inWater = hasWater && feetY <= waterY + 0.02f;

            IsSwimming = inWater;

#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (inWater != _wasSwimming)
            {
                _wasSwimming = inWater;
                Debug.Log(string.Format(
                    "[Swim] {0}  feetY={1:F2}  headY={2:F2}  waterY={3:F2}  grounded={4}",
                    inWater ? "入水" : "出水", feetY, body.max.y, waterY, _grounded));
            }
#endif

            if (inWater)
            {
                // 水里没有跳跃：空格只负责上浮
                SwimStep(wish, waterY);
                _grounded = false;
                UpdateAnimator();
                return;
            }

            if (_grounded && (Input.GetKeyDown(KeyCode.Space) || Input.GetButtonDown("Jump")))
            {
                _velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
                _jumpAnimLock = 0.12f;
                if (_animator != null) _animator.SetTrigger(JumpId);
            }

            _velocity.x = planar.x;
            _velocity.z = planar.z;
            ApplyGravity();
            _cc.Move(_velocity * Time.deltaTime);
            _grounded = _cc.isGrounded;
            UpdateAnimator();
        }

        /// <summary>当前是否在水里（供动画 / 其它系统查询）。</summary>
        public bool IsSwimming { get; private set; }

#if UNITY_EDITOR || DEVELOPMENT_BUILD
        bool _wasSwimming;
#endif

        /// <summary>
        /// 水中移动：
        ///   · 水平按 swimMoveSpeed 走；
        ///   · 按住空格 -> 以 ascendSpeed 上浮，接近「水面下方 floatDepthBelowSurface」时精确停住；
        ///   · 松开空格 -> 以 sinkSpeed 缓慢下沉。
        /// waterY 由 Update 算好传进来，不再重复采样（重复采样可能得到不同值，且失败时的兜底是错的）。
        /// </summary>
        void SwimStep(Vector3 wish, float waterY)
        {
            var planarSwim = Vector3.ClampMagnitude(wish, 1f) * swimMoveSpeed;
            _velocity.x = planarSwim.x;
            _velocity.z = planarSwim.z;

            // 双脚最终要停的高度：水面往下 floatDepthBelowSurface
            float feetY = _cc.bounds.min.y;
            float holdY = waterY - floatDepthBelowSurface;
            float toSurface = holdY - feetY;

            bool holdJump = Input.GetKey(KeyCode.Space) || Input.GetButton("Jump");

            float targetVy;
            if (holdJump)
            {
                // 还差多少 / 一帧，夹到 ascendSpeed：
                // 离得远就全速上浮，接近水面时刚好一帧走完，绝不越过、也不会「按了没反应」
                float maxRise = toSurface / Mathf.Max(Time.deltaTime, 1e-4f);
                targetVy = Mathf.Clamp(maxRise, 0f, ascendSpeed);
            }
            else
            {
                targetVy = -sinkSpeed;
            }

            _velocity.y = Mathf.MoveTowards(_velocity.y, targetVy, swimVerticalSmoothing * Time.deltaTime);
            _cc.Move(_velocity * Time.deltaTime);
        }

        void UpdateAnimator()
        {
            if (_animator == null) return;
            if (_jumpAnimLock > 0f) _jumpAnimLock -= Time.deltaTime;
            var speed = new Vector2(_velocity.x, _velocity.z).magnitude;
            _animator.SetFloat(SpeedId, speed);
            _animator.SetBool(GroundedId, _grounded && _jumpAnimLock <= 0f);
        }

        float CurrentMoveMultiplier()
        {
            if (!Input.GetKey(KeyCode.LeftShift) && !Input.GetKey(KeyCode.RightShift))
                return 1f;
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (_debugMoveEnabled) return DebugMoveMultiplier;
#endif
            return sprintMultiplier;
        }

#if UNITY_EDITOR || DEVELOPMENT_BUILD
        void EnsureDebugLabel()
        {
            if (_debugLabel != null) return;
            var canvasGo = new GameObject("DebugMoveCanvas");
            canvasGo.transform.SetParent(transform, false);
            var canvas = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 80;
            var textGo = new GameObject("DebugMoveLabel");
            textGo.transform.SetParent(canvasGo.transform, false);
            _debugLabel = textGo.AddComponent<Text>();
            _debugLabel.font = ResolveDebugFont();
            _debugLabel.fontSize = 18;
            _debugLabel.alignment = TextAnchor.UpperLeft;
            _debugLabel.color = new Color(1f, 0.86f, 0.25f, 0.95f);
            _debugLabel.horizontalOverflow = HorizontalWrapMode.Overflow;
            _debugLabel.verticalOverflow = VerticalWrapMode.Overflow;
            var rt = _debugLabel.rectTransform;
            rt.anchorMin = new Vector2(0f, 1f);
            rt.anchorMax = new Vector2(0f, 1f);
            rt.pivot = new Vector2(0f, 1f);
            rt.anchoredPosition = new Vector2(16f, -12f);
            rt.sizeDelta = new Vector2(480f, 28f);
            RefreshDebugLabel();
        }

        void RefreshDebugLabel()
        {
            if (_debugLabel == null) return;
            _debugLabel.text = _debugMoveEnabled
                ? GameLocale.T("debug.speed_on")
                : GameLocale.T("debug.speed_off");
        }

        static Font ResolveDebugFont()
        {
            var candidates = new[] { "Microsoft YaHei", "SimHei", "SimSun", "PingFang SC" };
            for (var i = 0; i < candidates.Length; i++)
            {
                var os = Font.CreateDynamicFontFromOSFont(candidates[i], 18);
                if (os != null) return os;
            }
            try { return Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf"); }
            catch (System.Exception) { return null; }
        }
#endif

        void ApplyGravity()
        {
            _velocity.y += gravity * Time.deltaTime;
        }

        public void Teleport(Vector3 position, Quaternion rotation)
        {
            _cc.enabled = false;
            transform.SetPositionAndRotation(position, FlattenYaw(rotation));
            _velocity = Vector3.zero;
            _cc.enabled = true;
        }

        static Quaternion FlattenYaw(Quaternion rotation)
        {
            var forward = rotation * Vector3.forward;
            forward.y = 0f;
            if (forward.sqrMagnitude < 0.0001f) return Quaternion.identity;
            return Quaternion.LookRotation(forward.normalized, Vector3.up);
        }
    }
}
