using UnityEngine;

namespace EggRescue
{
    public sealed class Interactable : MonoBehaviour
    {
        [SerializeField] string prompt = "E 交互";
        [SerializeField] float maxDistance = 3.2f;
        [SerializeField] bool enabledInteraction = true;
        [Tooltip("Optional world-space attachment for the interaction prompt, for example above an NPC's head.")]
        [SerializeField] Transform promptAnchor;
        [Tooltip("World-space offset above the anchor or automatic object bounds.")]
        [SerializeField] Vector3 promptOffset = new Vector3(0f, 0.25f, 0f);

        Renderer[] _promptRenderers;
        Collider[] _promptColliders;

        public string Prompt { get { return prompt; } set { prompt = value; } }
        public float MaxDistance { get { return maxDistance; } }
        public bool InteractionEnabled { get { return enabledInteraction && isActiveAndEnabled; } }

        // Multi-stage interactions may offer a new action after their initial clue was inspected.
        public bool ShowPromptAfterDiscovery { get; set; }
        public bool PromptVisible
        {
            get { return InteractionEnabled && (ShowPromptAfterDiscovery || !InteractionPointVfx.IsDiscoveredFrom(gameObject)); }
        }

        public Vector3 PromptWorldPosition
        {
            get
            {
                if (promptAnchor != null) return promptAnchor.position + promptOffset;
                if (_promptRenderers == null) CachePromptBounds();
                var bounds = new Bounds();
                var hasBounds = false;
                for (var i = 0; i < _promptRenderers.Length; i++)
                {
                    var renderer = _promptRenderers[i];
                    // Particle effects are discovery markers, not the interaction point itself.
                    if (renderer == null || !renderer.enabled || !renderer.gameObject.activeInHierarchy
                        || (!(renderer is MeshRenderer) && !(renderer is SkinnedMeshRenderer)
                            && !(renderer is SpriteRenderer))) continue;
                    if (!hasBounds) bounds = renderer.bounds;
                    else bounds.Encapsulate(renderer.bounds);
                    hasBounds = true;
                }
                if (!hasBounds)
                {
                    for (var i = 0; i < _promptColliders.Length; i++)
                    {
                        var collider = _promptColliders[i];
                        if (collider == null || !collider.enabled || !collider.gameObject.activeInHierarchy) continue;
                        if (!hasBounds) bounds = collider.bounds;
                        else bounds.Encapsulate(collider.bounds);
                        hasBounds = true;
                    }
                }
                var position = transform.position;
                if (hasBounds)
                {
                    // Tall trees and large trigger volumes still need a reachable, readable label.
                    position.x = Mathf.Clamp(bounds.center.x, position.x - 1f, position.x + 1f);
                    position.z = Mathf.Clamp(bounds.center.z, position.z - 1f, position.z + 1f);
                    position.y = Mathf.Clamp(bounds.max.y, position.y + 0.25f, position.y + 2f);
                }
                else position += Vector3.up * 0.8f;
                return position + promptOffset;
            }
        }

        public System.Action OnInteract;

        void Awake()
        {
            EnsureCollider();
        }

        void OnTransformChildrenChanged()
        {
            _promptRenderers = null;
        }

        void CachePromptBounds()
        {
            _promptRenderers = GetComponentsInChildren<Renderer>(true);
            _promptColliders = GetComponentsInChildren<Collider>(true);
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
