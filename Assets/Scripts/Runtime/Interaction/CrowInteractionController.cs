using UnityEngine;

namespace EggRescue
{
    public sealed class CrowInteractionController : MonoBehaviour
    {
        bool? _lastEnabled;

        void Start() { Refresh(true); }
        void Update() { Refresh(false); }

        void Refresh(bool force)
        {
            var enabled = GameState.GetBool("Crow_RoofIntroShown");
            if (!force && _lastEnabled == enabled) return;
            _lastEnabled = enabled;
            InteractionUtil.SetInteractionEnabled(gameObject, enabled);
        }
    }
}
