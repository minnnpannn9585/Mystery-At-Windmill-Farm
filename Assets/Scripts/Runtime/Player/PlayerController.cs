using UnityEngine;

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

        public Transform CameraPivot { get { return cameraPivot; } }

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
        }

        void Update()
        {
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

            var cam = Camera.main;
            var yaw = cam != null
                ? cam.transform.eulerAngles.y
                : (cameraPivot != null ? cameraPivot.eulerAngles.y : transform.eulerAngles.y);
            var yawRot = Quaternion.Euler(0f, yaw, 0f);
            var wish = yawRot * new Vector3(input.x, 0f, input.y);
            var speed = moveSpeed * (Input.GetKey(KeyCode.LeftShift) ? sprintMultiplier : 1f);
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
