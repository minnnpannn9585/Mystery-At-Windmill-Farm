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

        [Tooltip("游泳时的入水比例：0.45 = 身体 45% 沉在水面以下。主角是鸭子，0.4~0.5 观感最佳")]
        [Range(0.2f, 0.75f)]
        [SerializeField] float swimSubmergeRatio = 0.45f;

        [Tooltip("竖直速度平滑，避免入水/出水时抖")]
        [SerializeField] float swimVerticalSmoothing = 10.0f;

        [Header("Dive / 下潜")]
        [Tooltip("允许按住 diveKey 下潜。关掉之后玩家只能浮在浮位线上，永远进不了水下（水下效果也就看不到）")]
        [SerializeField] bool enableDive = true;

        [Tooltip("下潜键")]
        [SerializeField] KeyCode diveKey = KeyCode.LeftControl;

        [Tooltip("主动下潜速度（米/秒）")]
        [SerializeField] float diveSpeed = 2.2f;

        [Tooltip("松开下潜键后自动浮回浮位线的速度（米/秒），鸭子有浮力")]
        [SerializeField] float buoyancySpeed = 1.2f;

        [Tooltip("浮位线死区（米）：贴线时不做升降，避免浮力与沉降互相打架抖成 10Hz")]
        [SerializeField] float floatLineDeadZone = 0.06f;

        [Header("Swim Exit / 蹬岸上岸")]
        [Tooltip("水里贴岸时，按住空格 + 朝岸移动可以蹬上岸。\n" +
                 "★ 这不是跳跃：Swim 态仍然不能起跳，只是把身体挪到岸边可站立的面上")]
        [SerializeField] bool swimExitAssist = true;

        [Tooltip("朝岸探测距离（米）")]
        [SerializeField] float swimExitProbeDistance = 0.85f;

        [Tooltip("能蹬上去的最大岸高差（米），超过就判定为爬不上去")]
        [SerializeField] float swimExitMaxClimb = 1.0f;

        [Tooltip("蹬岸动作时长（秒）")]
        [SerializeField] float swimExitDuration = 0.32f;

        [Tooltip("开场自动把 PlayerFoam 泡沫特效挂到玩家身上（资源在 Resources/Water/PlayerFoam）")]
        [SerializeField] bool autoMountPlayerFoam = true;

        [Tooltip("场景里已经摆好的泡沫特效（PlayerFoam）。留空则运行时按名字自动找；再找不到才用 Resources 里的默认预制体")]
        [SerializeField] Transform playerFoam;

        [Tooltip("找不到 playerFoam 时按这个名字在场景里找")]
        [SerializeField] string playerFoamObjectName = "PlayerFoam";

        [Tooltip("玩家泡沫特效的缩放倍率（1 = 原始尺寸）。默认 1/3 —— VFX_Ripple 原尺寸对鸭子来说太大")]
        [SerializeField, Range(0.05f, 2f)] float playerFoamScale = 1f / 3f;

        CharacterController _cc;
        Animator _animator;
        Vector3 _velocity;
        bool _grounded;
        float _jumpAnimLock;
        bool _prevFrameInWater;

        // 蹬岸动作：期间关闭 CharacterController，用脚本位移走过去（避免撞墙滑动/反复触发）
        bool _swimExitActive;
        float _swimExitTimer;
        float _swimExitCooldown;
        Vector3 _swimExitFrom;
        Vector3 _swimExitTo;
        static readonly Collider[] ExitOverlap = new Collider[16];

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
            CancelSwimExit();
            _velocity = Vector3.zero;
            if (_cc != null) _cc.enabled = false;
            transform.SetPositionAndRotation(position, Quaternion.Euler(0f, yaw, 0f));
            if (_cc != null) _cc.enabled = true;
        }

        /// <summary>传送/读档时打断蹬岸动作，避免脚本位移把玩家又拖回岸边。</summary>
        void CancelSwimExit()
        {
            if (!_swimExitActive) return;
            _swimExitActive = false;
            _swimExitTimer = 0f;
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
            // 蹬岸途中被禁用会把 CC 永远留在关闭状态，这里兜底恢复
            CancelSwimExit();
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
            foam.driveScale = false;              // 不接管缩放：保持场景里调好的比例
            foam.autoScaleToBounds = false;
            foam.surfaceOffset = 0.02f;
            foam.scaleMultiplier = playerFoamScale;   // 只按倍率缩，粒子参数一个字不动

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
            // 蹬岸是脚本化位移，途中不接管输入，也不被锁输入打断
            if (_swimExitActive)
            {
                TickSwimExit();
                return;
            }
            if (_swimExitCooldown > 0f) _swimExitCooldown -= Time.deltaTime;

            // ---- 环境采样放在最前：任何分支（含 InputLocked）都要知道「我现在是不是在水里」----
            // 用 CharacterController 的实际包围盒当身体，不要用 transform.position（center 不一定在高度一半）
            Bounds body = _cc.bounds;
            float feetY = body.min.y;

            float waterY = 0f;   // swimmingEnabled 为 false 时 TrySample 被短路，这里必须有初值
            bool hasWater = swimmingEnabled && WaterSurface.TrySample(transform.position, out waterY);

            bool inWater = hasWater && feetY <= waterY + 0.02f;
            bool wasInWater = _prevFrameInWater;

            IsSwimming = inWater;
            _prevFrameInWater = inWater;
            _grounded = _cc.isGrounded;

#if UNITY_EDITOR || DEVELOPMENT_BUILD
            if (inWater != wasInWater)
            {
                Debug.Log(string.Format(
                    "[Swim] {0}  feetY={1:F2}  headY={2:F2}  waterY={3:F2}  grounded={4}",
                    inWater ? "入水" : "出水", feetY, body.max.y, waterY, _grounded));
            }
#endif
            // 入水首帧同时钳上下两端：
            //   下 —— 吃掉自由落体速度，否则会以十几米每秒先砸到池底；
            //   上 —— 吃掉起跳冲量，否则起跳入水会先被顶出水面、再落回、再被顶出去，来回荡。
            if (inWater && !wasInWater)
                _velocity.y = Mathf.Clamp(_velocity.y, -sinkSpeed, 0f);

            // ---- 输入锁：按「当前状态」收敛，水里锁输入就停在水里，绝不能继续下沉 ----
            if (GameEvents.InputLocked)
            {
                _velocity.x = 0f;
                _velocity.z = 0f;
                if (inWater) _velocity.y = 0f;
                else ApplyGravity();
                _cc.Move(_velocity * Time.deltaTime);
                _grounded = _cc.isGrounded;
                UpdateAnimator();
                return;
            }

            if (!inWater && _grounded && _velocity.y < 0f)
                _velocity.y = -2f;

            var input = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
            if (input.sqrMagnitude > 1f) input.Normalize();

            // 移动方向的朝向源只能是相机 Yaw —— 玩家 transform 的 yaw 由本类自己写，
            // 拿它算方向会形成「转身→换向」的正反馈。
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

            if (inWater)
            {
                // 水里没有跳跃：空格只负责上浮 / 贴岸蹬出
                // 浮位线 = 水面下方 body.size.y * swimSubmergeRatio（鸭子半身入水）
                SwimStep(wish, waterY, waterY - body.size.y * swimSubmergeRatio);
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

        /// <summary>
        /// 水中移动：
        ///   · 水平按 swimMoveSpeed 走；
        ///   · 按住空格 → 以 ascendSpeed 上浮，接近浮位线（水面下 N% 身高）时精确停住；
        ///   · 松开空格 → 以 sinkSpeed 缓慢下沉；
        ///   · 贴岸 + 朝岸 + 空格 → 触发蹬岸（不是跳跃）。
        /// waterY 由 Update 算好传进来，不再重复采样（重复采样可能得到不同值，且失败时的兜底是错的）。
        /// floatFeetY 是浮位线，也就是双脚最终停在的世界高度。
        /// </summary>
        void SwimStep(Vector3 wish, float waterY, float floatFeetY)
        {
            var planarSwim = Vector3.ClampMagnitude(wish, 1f) * swimMoveSpeed;
            _velocity.x = planarSwim.x;
            _velocity.z = planarSwim.z;

            bool holdJump = Input.GetKey(KeyCode.Space) || Input.GetButton("Jump");

            // 贴岸蹬出：只在水里、朝岸、按住空格、岸面在可攀范围内才触发
            if (holdJump && swimExitAssist && wish.sqrMagnitude > 0.01f
                && TryBeginSwimExit(wish.normalized, waterY))
                return;

            float feetY = _cc.bounds.min.y;
            float toFloatLine = floatFeetY - feetY;
            bool diveHeld = enableDive && Input.GetKey(diveKey);

            // 优先级：空格上浮 > 下潜键 > 浮位线死区 > 浮力/沉降
            // 死区是必须的：贴着浮位线时「沉降」和「浮力」会互相打架，产生 5~10Hz 的高频抖动。
            float targetVy;
            if (holdJump)
            {
                if (toFloatLine > 0f)
                {
                    // 还差多少 / 一帧，夹到 ascendSpeed：离得远就全速上浮，接近浮位线时刚好一帧走完，
                    // 绝不越过、也不会「按了没反应」
                    float maxRise = toFloatLine / Mathf.Max(Time.deltaTime, 1e-4f);
                    targetVy = Mathf.Clamp(maxRise, 0f, ascendSpeed);
                }
                else
                {
                    targetVy = 0f;                     // 已经到浮位线（或更浅），按空格也不再往上顶
                }
            }
            else if (diveHeld)
            {
                targetVy = -diveSpeed;                 // 主动下潜，可以一直沉到水底
            }
            else if (Mathf.Abs(toFloatLine) <= floatLineDeadZone)
            {
                targetVy = 0f;                         // 浮位线上的死区：不抖
            }
            else if (toFloatLine > 0f)
            {
                targetVy = buoyancySpeed;              // 比浮位线深：鸭子自己有浮力，慢慢浮回来
            }
            else
            {
                // 已经在浮位线之上（起跳入水、被地形顶出水面、浅水踩底）：主动沉回浮位线。
                // 以前这里按 holdJump 给 0，结果角色卡在水面入口高度「漂」着不下沉，
                // 看着像没入水却已经是游泳态。离得越远沉得越快（0.8m 落差约 1.6 m/s）。
                float settle = Mathf.Clamp(-toFloatLine * 2f, sinkSpeed, ascendSpeed);
                targetVy = -settle;
            }

            _velocity.y = Mathf.MoveTowards(_velocity.y, targetVy, swimVerticalSmoothing * Time.deltaTime);
            _cc.Move(_velocity * Time.deltaTime);
        }

        /// <summary>
        /// 水里「蹬岸上岸」的入口：不是跳跃，只是把身体挪到岸边可站立的面上。
        /// 触发条件全满足才放行：①按住空格 ②有朝岸的水平输入 ③前方泳ExitProbeDistance 内有墙
        /// ④墙顶有可站面 ⑤岸面不低于水面 ⑥高差 ≤ swimExitMaxClimb ⑦落点头顶有空间。
        /// </summary>
        bool TryBeginSwimExit(Vector3 dir, float waterY)
        {
            if (_swimExitCooldown > 0f) return false;

            Bounds body = _cc.bounds;
            Vector3 probeOrigin = new Vector3(transform.position.x, body.min.y + 0.6f, transform.position.z);

            RaycastHit wall;
            if (!Physics.Raycast(probeOrigin, dir, out wall, swimExitProbeDistance,
                                 Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore))
                return false;
            if (IsPlayerCollider(wall.collider)) return false;

            Vector3 downOrigin = wall.point + dir * 0.45f + Vector3.up * (swimExitMaxClimb + 0.3f);
            RaycastHit ground;
            if (!Physics.Raycast(downOrigin, Vector3.down, out ground, swimExitMaxClimb + 0.6f,
                                 Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore))
                return false;
            if (IsPlayerCollider(ground.collider)) return false;
            if (Vector3.Angle(ground.normal, Vector3.up) > 55f) return false;

            float ledgeY = ground.point.y;
            float climb = ledgeY - body.min.y;
            // 岸面必须不低于水面：低于水面等于还在水里，落地会立刻重新判成入水（死循环）
            if (ledgeY < waterY) return false;
            if (climb < -0.05f || climb > swimExitMaxClimb) return false;

            Vector3 target = new Vector3(ground.point.x, ledgeY + 0.04f, ground.point.z) + dir * 0.12f;
            if (HasBlockingOverlap(target, body)) return false;

            _swimExitActive = true;
            _swimExitTimer = 0f;
            _swimExitFrom = transform.position;
            _swimExitTo = target;
            _velocity = Vector3.zero;
            _cc.enabled = false;
            return true;
        }

        /// <summary>
        /// 蹬岸落点有没有「站得住」的空间。
        /// 只测胸口高度的球形，不测整根胶囊 —— 斜坡岸面会跟胶囊底球相交，
        /// 用整根胶囊判会把正常岸边也判成堵死，结果永远上不了岸。
        /// </summary>
        bool HasBlockingOverlap(Vector3 feetPosition, Bounds body)
        {
            float radius = Mathf.Max(0.05f, _cc.radius * 0.9f);
            float height = Mathf.Max(radius * 2f, body.size.y);
            Vector3 chest = feetPosition + Vector3.up * (height * 0.6f);

            int count = Physics.OverlapSphereNonAlloc(chest, radius, ExitOverlap,
                Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore);
            for (int i = 0; i < count; i++)
            {
                var col = ExitOverlap[i];
                if (col == null) continue;
                if (IsPlayerCollider(col)) continue;
                if (col.GetComponentInParent<WaterSurface>() != null) continue;   // 水面不是障碍
                return true;
            }
            return false;
        }

        bool IsPlayerCollider(Collider col)
        {
            return col != null && col.GetComponentInParent<PlayerController>() != null;
        }

        void TickSwimExit()
        {
            _swimExitTimer += Time.deltaTime / Mathf.Max(0.05f, swimExitDuration);
            float k = Mathf.SmoothStep(0f, 1f, Mathf.Clamp01(_swimExitTimer));
            transform.position = Vector3.Lerp(_swimExitFrom, _swimExitTo, k);

            if (_swimExitTimer < 1f)
            {
                UpdateAnimator();
                return;
            }

            _swimExitActive = false;
            _velocity = Vector3.zero;
            _cc.enabled = true;
            IsSwimming = false;
            _prevFrameInWater = false;
            _grounded = true;
            _swimExitCooldown = 0.45f;   // 别在岸线上反复触发
            UpdateAnimator();
        }

        void UpdateAnimator()
        {
            if (_animator == null) return;
            if (_jumpAnimLock > 0f) _jumpAnimLock -= Time.deltaTime;

            // duck.controller 只有 idle / walk / jump 三个状态，没有游泳态：
            //   · 喂真实水平速度 → 水里一直播 walk 循环（带方向键入水就是这个现象）
            //   · 喂 Grounded=false  → 一旦进过 jump 就出不来（jump→idle / jump→walk 都要求 Grounded=true）
            // 暂时按 idle 处理：不再循环走路，也不会卡在跳跃态。有游泳 clip 后再换成专用参数。
            if (IsSwimming)
            {
                _animator.SetFloat(SpeedId, 0f);
                _animator.SetBool(GroundedId, true);
                return;
            }

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
            CancelSwimExit();
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
