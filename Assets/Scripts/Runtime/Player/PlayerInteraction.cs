using TMPro;
using UnityEngine;

namespace EggRescue
{
    public sealed class PlayerInteraction : MonoBehaviour
    {
        [SerializeField] float rayDistance = 3.5f;
        [SerializeField] LayerMask mask = ~0;
        [SerializeField] TMP_Text promptText;

        Interactable _current;
        WorldInteractionPrompt _worldPrompt;

        // Keep older scene/prefab bindings compatible, but retire their bottom-screen label.
        public void SetPromptLabel(TMP_Text label)
        {
            if (promptText != null) promptText.gameObject.SetActive(false);
            promptText = label;
            if (promptText != null) promptText.gameObject.SetActive(false);
        }

        void Awake()
        {
            SetPromptLabel(promptText);
            _worldPrompt = GetComponent<WorldInteractionPrompt>();
            if (_worldPrompt == null) _worldPrompt = gameObject.AddComponent<WorldInteractionPrompt>();
        }

        void OnDisable()
        {
            SetCurrent(null);
        }

        void Update()
        {
            if (GameEvents.InputLocked)
            {
                SetCurrent(null);
                return;
            }

            var camera = Camera.main;
            var hit = RaycastInteractable(camera);
            if (hit == null) hit = ProximityInteractable(camera);
            SetCurrent(hit);

            if (_current != null && Input.GetKeyDown(KeyCode.E))
                _current.Interact();
        }

        Interactable RaycastInteractable(Camera camera)
        {
            var ray = camera != null
                ? camera.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f))
                : new Ray(transform.position + Vector3.up, transform.forward);
            var hits = Physics.RaycastAll(ray, rayDistance, mask, QueryTriggerInteraction.Collide);
            Interactable best = null;
            var bestDist = float.MaxValue;
            for (var i = 0; i < hits.Length; i++)
            {
                var col = hits[i].collider;
                if (col == null) continue;
                if (col.GetComponentInParent<PlayerController>() != null) continue;
                var interactable = col.GetComponentInParent<Interactable>();
                if (interactable == null || !interactable.InteractionEnabled) continue;
                if (Vector3.Distance(transform.position, hits[i].point) > interactable.MaxDistance) continue;
                if (hits[i].distance >= bestDist) continue;
                bestDist = hits[i].distance;
                best = interactable;
            }
            return best;
        }

        Interactable ProximityInteractable(Camera camera)
        {
            var origin = transform.position + Vector3.up * 0.9f;
            var cols = Physics.OverlapSphere(origin, rayDistance, mask, QueryTriggerInteraction.Collide);
            Interactable best = null;
            var bestScore = float.MaxValue;
            var cam = camera != null ? camera.transform : transform;
            for (var i = 0; i < cols.Length; i++)
            {
                var col = cols[i];
                if (col == null) continue;
                if (col.GetComponentInParent<PlayerController>() != null) continue;
                var interactable = col.GetComponentInParent<Interactable>();
                if (interactable == null || !interactable.InteractionEnabled) continue;
                var to = interactable.transform.position - origin;
                var dist = to.magnitude;
                if (dist > interactable.MaxDistance) continue;
                var dir = dist > 0.01f ? to / dist : cam.forward;
                if (Vector3.Dot(cam.forward, dir) < 0.25f) continue;
                if (dist >= bestScore) continue;
                bestScore = dist;
                best = interactable;
            }
            return best;
        }

        void SetCurrent(Interactable next)
        {
            _current = next;
            if (promptText != null) promptText.gameObject.SetActive(false);
            if (_worldPrompt != null) _worldPrompt.SetTarget(next);
        }
    }
}
