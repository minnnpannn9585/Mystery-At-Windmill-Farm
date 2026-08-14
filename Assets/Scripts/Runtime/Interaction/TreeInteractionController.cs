using UnityEngine;

namespace EggRescue
{
    public sealed class TreeInteractionController : MonoBehaviour
    {
        public GameObject forceZone;
        public GameObject clickZone;
        bool? _lastForce;
        bool? _lastClick;

        void Awake() { AutoBind(); Refresh(true); }
        void Start() { AutoBind(); Refresh(true); }

        void AutoBind()
        {
            if (forceZone == null)
            {
                var t = transform.Find("TreeForceZone");
                forceZone = t != null ? t.gameObject : null;
            }
            if (clickZone == null)
            {
                var t = transform.Find("TreeClickZone");
                clickZone = t != null ? t.gameObject : null;
            }
        }
        void Update() { Refresh(false); }

        void Refresh(bool force)
        {
            var closed = GameState.GetBool("Dog_BlackCatSummoned") || GameState.GetBool("BlackCat_TreeShakeStarted");
            var hard = GameState.GetBool("BlackCat_TreeHardShown");
            var forceEnabled = !closed && !hard;
            var clickEnabled = !closed && hard;
            if (!force && _lastForce == forceEnabled && _lastClick == clickEnabled) return;
            _lastForce = forceEnabled;
            _lastClick = clickEnabled;
            InteractionUtil.SetSpotEnabled(clickZone, clickEnabled);
            if (forceZone != null && forceZone.activeSelf != forceEnabled)
                forceZone.SetActive(forceEnabled);
        }
    }
}
