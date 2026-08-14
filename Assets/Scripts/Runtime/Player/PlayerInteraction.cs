using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    public sealed class PlayerInteraction : MonoBehaviour
    {
        [SerializeField] float rayDistance = 3.5f;
        [SerializeField] LayerMask mask = ~0;
        [SerializeField] Text promptText;

        Interactable _current;

        public void SetPromptLabel(Text label) { promptText = label; }

        void Update()
        {
            if (GameEvents.InputLocked)
            {
                SetCurrent(null);
                return;
            }

            var hit = RaycastInteractable();
            if (hit == null) hit = ProximityInteractable();
            SetCurrent(hit);

            if (_current != null && (Input.GetKeyDown(KeyCode.E) || Input.GetMouseButtonDown(0)))
                _current.Interact();
        }

        Interactable RaycastInteractable()
        {
            var ray = Camera.main != null
                ? Camera.main.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f))
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

        Interactable ProximityInteractable()
        {
            var origin = transform.position + Vector3.up * 0.9f;
            var cols = Physics.OverlapSphere(origin, rayDistance, mask, QueryTriggerInteraction.Collide);
            Interactable best = null;
            var bestScore = float.MaxValue;
            var cam = Camera.main != null ? Camera.main.transform : transform;
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
            if (promptText == null) return;
            if (next == null)
            {
                promptText.gameObject.SetActive(false);
            }
            else
            {
                promptText.gameObject.SetActive(true);
                promptText.text = string.IsNullOrEmpty(next.Prompt) ? "E 交互" : next.Prompt;
            }
        }
    }
}
