using UnityEngine;

namespace EggRescue
{
    public sealed class ThirdPersonCamera : MonoBehaviour
    {
        [SerializeField] Transform target;
        [SerializeField] Vector3 offset = new Vector3(0f, 0.1f, -4f);
        [SerializeField] float mouseSensitivity = 2.2f;
        [SerializeField] float minPitch = -35f;
        [SerializeField] float maxPitch = 55f;
        [SerializeField] float followLerp = 12f;

        float _yaw;
        float _pitch = 8f;
        bool _snap;

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
            _snap = true;
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

        void LateUpdate()
        {
            if (target == null) return;
            if (!GameEvents.InputLocked)
            {
                _yaw += Input.GetAxis("Mouse X") * mouseSensitivity;
                _pitch -= Input.GetAxis("Mouse Y") * mouseSensitivity;
                _pitch = Mathf.Clamp(_pitch, minPitch, maxPitch);
            }

            var rot = Quaternion.Euler(_pitch, _yaw, 0f);
            var desired = target.position + rot * offset;
            if (_snap)
            {
                transform.SetPositionAndRotation(desired, rot);
                _snap = false;
                return;
            }
            transform.position = Vector3.Lerp(transform.position, desired, 1f - Mathf.Exp(-followLerp * Time.deltaTime));
            transform.rotation = rot;
        }
    }
}
