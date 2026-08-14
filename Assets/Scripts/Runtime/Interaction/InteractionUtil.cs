using UnityEngine;

namespace EggRescue
{
    public static class InteractionUtil
    {
        public static bool IsLocalPlayer(Collider other)
        {
            if (other == null) return false;
            if (other.CompareTag("Player")) return true;
            return other.GetComponentInParent<PlayerController>() != null;
        }

        public static void SetCollidersEnabled(GameObject go, bool enabled, bool includeInactive = false)
        {
            if (go == null) return;
            var cols = go.GetComponentsInChildren<Collider>(includeInactive);
            for (var i = 0; i < cols.Length; i++)
                cols[i].enabled = enabled;
        }

        public static void SetSpotEnabled(GameObject pointGo, bool enabled)
        {
            if (pointGo == null) return;
            var interactable = pointGo.GetComponentInChildren<Interactable>(true);
            if (enabled)
            {
                if (!pointGo.activeSelf) pointGo.SetActive(true);
                SetCollidersEnabled(pointGo, true);
                if (interactable != null) interactable.SetInteractionEnabled(true);
                return;
            }

            if (interactable != null) interactable.SetInteractionEnabled(false);
            SetCollidersEnabled(pointGo, false, true);
            if (pointGo.activeSelf)
            {
                AudioDirector.PlayParticle("vfx_characterChange", pointGo.transform.position);
                pointGo.SetActive(false);
            }
        }

        public static void SetInteractionEnabled(GameObject go, bool enabled)
        {
            if (go == null) return;
            var interactable = go.GetComponentInChildren<Interactable>(true);
            if (enabled)
            {
                SetCollidersEnabled(go, true);
                if (interactable != null) interactable.SetInteractionEnabled(true);
            }
            else
            {
                if (interactable != null) interactable.SetInteractionEnabled(false);
                SetCollidersEnabled(go, false, true);
            }
        }
    }
}
