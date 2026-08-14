using UnityEngine;

namespace EggRescue
{
    public sealed class SecondFloorWindowController : MonoBehaviour
    {
        public GameObject closedPoint;
        public GameObject openPoint;
        bool? _lastOpen;

        void OnEnable() { GameEvents.BlackCatEntered += OnEntered; }
        void OnDisable() { GameEvents.BlackCatEntered -= OnEntered; }

        void Start() { Refresh(true); }
        void Update() { Refresh(false); }
        void OnEntered() { Refresh(true); }

        public void Refresh(bool force)
        {
            if (closedPoint == null)
            {
                var t = transform.Find("E19 · 关闭二层窗");
                closedPoint = t != null ? t.gameObject : null;
            }
            if (openPoint == null)
            {
                var t = transform.Find("E20 · 打开二层窗");
                openPoint = t != null ? t.gameObject : null;
            }
            var open = GameState.GetBool("BlackCat_Entered");
            if (!force && _lastOpen == open) return;
            _lastOpen = open;
            InteractionUtil.SetSpotEnabled(closedPoint, !open);
            InteractionUtil.SetSpotEnabled(openPoint, open);
            if (open) ClimbPathPoint.Refresh("roof");
        }
    }
}
