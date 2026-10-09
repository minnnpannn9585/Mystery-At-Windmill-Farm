using UnityEngine;
using UnityEngine.UI;

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

        CharacterController _cc;
        Vector3 _velocity;
        bool _grounded;
#if UNITY_EDITOR || DEVELOPMENT_BUILD
        const float DebugMoveMultiplier = 3f;
        static bool _debugMoveEnabled = true;
        Text _debugLabel;
#endif

        public Transform CameraPivot { get { return cameraPivot; } }

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
            if (cameraPivot == null)
            {
                var pivot = new GameObject("CameraPivot");
                pivot.transform.SetParent(transform, false);
                pivot.transform.localPosition = new Vector3(0f, 1.15f, 0f);
                cameraPivot = pivot.transform;
            }
            gameObject.tag = "Player";
#if UNITY_EDITOR || DEVELOPMENT_BUILD
            EnsureDebugLabel();
#endif
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

            if (_grounded && Input.GetButtonDown("Jump"))
                _velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);

            _velocity.x = planar.x;
            _velocity.z = planar.z;
            ApplyGravity();
            _cc.Move(_velocity * Time.deltaTime);
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
            Font font = null;
            try { font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf"); }
            catch (System.Exception) { font = null; }
            if (font == null)
            {
                try { font = Resources.GetBuiltinResource<Font>("Arial.ttf"); }
                catch (System.Exception) { font = null; }
            }
            if (font == null)
                font = Font.CreateDynamicFontFromOSFont("Microsoft YaHei", 18);
            return font;
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
