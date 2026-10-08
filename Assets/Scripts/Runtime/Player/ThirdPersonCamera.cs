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
        [SerializeField] float maxDropBelowPivot = 0.1f;
        [SerializeField] float collisionRadius = 0.3f;
        [SerializeField] float collisionSkin = 0.08f;

        float _yaw;
        float _pitch = 8f;
        bool _snap;
        Vector3 _posVelocity;
        static readonly RaycastHit[] Hits = new RaycastHit[24];

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
            var pivot = target.position;
            var desired = AvoidGeometry(pivot, pivot + rot * offset);

            if (_snap || positionSmoothTime <= 0f)
            {
                transform.SetPositionAndRotation(desired, rot);
                _posVelocity = Vector3.zero;
                _snap = false;
                return;
            }

            var smoothed = Vector3.SmoothDamp(transform.position, desired, ref _posVelocity, positionSmoothTime);
            transform.SetPositionAndRotation(KeepWithinArm(pivot, desired, smoothed), rot);
        }

        Vector3 AvoidGeometry(Vector3 pivot, Vector3 desired)
        {
            var floorY = pivot.y - maxDropBelowPivot;
            if (desired.y < floorY)
                desired.y = floorY;

            var delta = desired - pivot;
            var dist = delta.magnitude;
            if (dist < 0.001f) return pivot;
            var dir = delta / dist;

            var radius = collisionRadius;
            var cam = GetComponent<Camera>();
            if (cam != null)
                radius = Mathf.Max(radius, cam.nearClipPlane);

            var allowed = dist;
            var count = Physics.SphereCastNonAlloc(
                pivot, radius, dir, Hits, dist, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore);
            for (var i = 0; i < count; i++)
            {
                var hit = Hits[i];
                if (hit.collider == null || hit.collider.isTrigger) continue;
                if (IsPlayer(hit.collider)) continue;
                if (hit.distance < allowed)
                    allowed = hit.distance;
            }

            if (allowed < dist)
                allowed = Mathf.Max(0.05f, allowed - collisionSkin);
            allowed = Mathf.Min(allowed, dist);

            var pos = pivot + dir * allowed;
            if (WorldOverlap(pos, radius * 0.9f))
                pos = RetractUntilClear(pivot, dir, allowed, radius * 0.9f);
            return pos;
        }

        Vector3 RetractUntilClear(Vector3 pivot, Vector3 dir, float allowed, float radius)
        {
            var near = 0.05f;
            var far = Mathf.Max(near, allowed);
            var clear = pivot + dir * near;
            for (var i = 0; i < 6; i++)
            {
                var mid = (near + far) * 0.5f;
                var point = pivot + dir * mid;
                if (WorldOverlap(point, radius))
                    far = mid;
                else
                {
                    near = mid;
                    clear = point;
                }
            }
            return clear;
        }

        static bool WorldOverlap(Vector3 point, float radius)
        {
            return Physics.CheckSphere(point, radius, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore);
        }

        static bool IsPlayer(Collider col)
        {
            var player = PlayerController.Instance;
            if (player == null || col == null) return false;
            var root = player.transform;
            return col.transform == root || col.transform.IsChildOf(root);
        }

        static Vector3 KeepWithinArm(Vector3 pivot, Vector3 safe, Vector3 candidate)
        {
            var safeDist = (safe - pivot).magnitude;
            var cand = candidate - pivot;
            if (cand.magnitude <= safeDist + 0.001f) return candidate;
            if (safeDist < 0.001f) return pivot;
            return pivot + cand.normalized * safeDist;
        }
    }
}
