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

        public static GameObject FindByName(string name)
        {
            if (string.IsNullOrEmpty(name)) return null;
            var all = Object.FindObjectsOfType<Transform>(true);
            for (var i = 0; i < all.Length; i++)
            {
                if (all[i] != null && all[i].name == name)
                    return all[i].gameObject;
            }
            return null;
        }

        public static GameObject FindChildOrWorld(Transform root, string name)
        {
            if (string.IsNullOrEmpty(name)) return null;
            if (root != null)
            {
                var direct = root.Find(name);
                if (direct != null) return direct.gameObject;
                var children = root.GetComponentsInChildren<Transform>(true);
                for (var i = 0; i < children.Length; i++)
                {
                    if (children[i] == null || children[i] == root) continue;
                    if (children[i].name == name)
                        return children[i].gameObject;
                }
            }
            return FindByName(name);
        }

        public static void SetCollidersEnabled(GameObject go, bool enabled, bool includeInactive = false)
        {
            if (go == null) return;
            var cols = go.GetComponentsInChildren<Collider>(includeInactive);
            for (var i = 0; i < cols.Length; i++)
                cols[i].enabled = enabled;
        }

        public static void SetSpotEnabled(GameObject pointGo, bool enabled, bool playHideVfx = true)
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
                if (playHideVfx)
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
