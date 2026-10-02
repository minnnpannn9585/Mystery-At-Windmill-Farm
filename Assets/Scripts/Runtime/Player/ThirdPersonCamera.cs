using UnityEngine;

namespace EggRescue
{
    public sealed class ThirdPersonCamera : MonoBehaviour
    {
        public static ThirdPersonCamera Instance { get; private set; }

        [SerializeField] Transform target;
        [SerializeField] Vector3 offset = new Vector3(0f, 0.1f, -2.5f);
        [SerializeField] float mouseSensitivity = 2.2f;
        [SerializeField] float minPitch = -35f;
        [SerializeField] float maxPitch = 55f;
        [Tooltip("?????????(?)??? 0 = ???????????????????")]
        [SerializeField] float positionSmoothTime = 0f;

        float _yaw;
        float _pitch = 8f;
        bool _snap;
        Vector3 _posVelocity;

        /// <summary>???????? PlayerController ????????????????</summary>
        public float Yaw { get { return _yaw; } }

        public void SetTarget(Transform t)
        {
            if (t != null && PlayerController.Instance != null && t == PlayerController.Instance.transform
                && PlayerController.Instance.CameraPivot != null)
                t = PlayerController.Instance.CameraPivot;
            target = t;
            if (t != null)
                _yaw = t.eulerAngles.y;
            SnapToTarget();
        }

        public void SnapToTarget()
        {
            if (target == null) return;
            var rot = Quaternion.Euler(_pitch, _yaw, 0f);
            transform.SetPositionAndRotation(target.position + rot * offset, rot);
            _posVelocity = Vector3.zero;
            _snap = true;
        }

        void Awake()
        {
            Instance = this;
        }

        void Start()
        {
            if (target == null && PlayerController.Instance != null)
                SetTarget(PlayerController.Instance.CameraPivot != null
                    ? PlayerController.Instance.CameraPivot
                    : PlayerController.Instance.transform);
            else
                SnapToTarget();
            if (!GameEvents.InputLocked)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Cursor.visible = false;
            }
        }

        void Update()
        {
            // ? Update ??????????????????????????? GetAxis ??????????
            if (GameEvents.InputLocked) return;
            _yaw += Input.GetAxisRaw("Mouse X") * mouseSensitivity;
            _pitch -= Input.GetAxisRaw("Mouse Y") * mouseSensitivity;
            _pitch = Mathf.Clamp(_pitch, minPitch, maxPitch);
            if (_yaw > 360f) _yaw -= 360f;
            else if (_yaw < -360f) _yaw += 360f;
        }

        void LateUpdate()
        {
            if (target == null) return;

            var rot = Quaternion.Euler(_pitch, _yaw, 0f);
            var desired = target.position + rot * offset;

            if (_snap || positionSmoothTime <= 0f)
            {
                transform.SetPositionAndRotation(desired, rot);
                _posVelocity = Vector3.zero;
                _snap = false;
                return;
            }

            // SmoothDamp ???????????????? Lerp ????"???"?????????
            transform.position = Vector3.SmoothDamp(transform.position, desired, ref _posVelocity, positionSmoothTime);
            transform.rotation = rot;
        }
    }
}
