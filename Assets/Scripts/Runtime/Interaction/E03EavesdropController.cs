using UnityEngine;

namespace EggRescue
{
    public sealed class E03EavesdropController : MonoBehaviour
    {
        bool? _lastEnabled;

        void Start() { Refresh(true); }
        void Update() { Refresh(false); }

        void Refresh(bool force)
        {
            var enabled = !GameState.GetBool("E03_Overheard") && GameState.GetInt("ChickStatus") < 3;
            if (!force && _lastEnabled == enabled) return;
            _lastEnabled = enabled;
            InteractionUtil.SetInteractionEnabled(gameObject, enabled);
        }
    }
}
