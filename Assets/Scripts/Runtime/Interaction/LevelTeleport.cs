using UnityEngine;

namespace EggRescue
{
    public sealed class LevelTeleport : MonoBehaviour
    {
        public static LevelTeleport Instance { get; private set; }
        public Transform targetObject;

        void Awake()
        {
            Instance = this;
        }

        public void ResetPosition()
        {
            var target = targetObject != null ? targetObject : transform;
            if (PlayerController.Instance != null)
                PlayerController.Instance.Teleport(target.position, target.rotation);
        }

        public static void TeleportTo(Transform target)
        {
            if (target == null || PlayerController.Instance == null) return;
            PlayerController.Instance.Teleport(target.position, target.rotation);
        }
    }
}
