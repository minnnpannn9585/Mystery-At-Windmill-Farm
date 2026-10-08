using UnityEngine;

namespace EggRescue
{
    public sealed class Interactable : MonoBehaviour
    {
        [SerializeField] string prompt = "E 交互";
        [SerializeField] float maxDistance = 3.2f;
        [SerializeField] bool enabledInteraction = true;

        public string Prompt { get { return prompt; } set { prompt = value; } }
        public float MaxDistance { get { return maxDistance; } }
        public bool InteractionEnabled { get { return enabledInteraction && isActiveAndEnabled; } }

        public System.Action OnInteract;

        void Awake()
        {
            EnsureCollider();
        }

        public void EnsureCollider()
        {
            var existing = GetComponentsInChildren<Collider>(true);
            for (var i = 0; i < existing.Length; i++)
            {
                if (existing[i] != null && existing[i].gameObject.activeInHierarchy)
                    return;
            }
            var sphere = gameObject.AddComponent<SphereCollider>();
            sphere.isTrigger = true;
            sphere.radius = 1.15f;
            sphere.center = new Vector3(0f, 0.6f, 0f);
        }

        public void SetInteractionEnabled(bool enabled)
        {
            enabledInteraction = enabled;
        }

        public void Interact()
        {
            if (!InteractionEnabled) return;
            if (OnInteract != null) OnInteract();
        }
    }
}
