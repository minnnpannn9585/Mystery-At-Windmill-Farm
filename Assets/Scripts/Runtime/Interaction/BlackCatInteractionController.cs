using UnityEngine;

namespace EggRescue
{
    public sealed class BlackCatInteractionController : MonoBehaviour
    {
        public GameObject catModel;
        bool? _lastEnabled;

        void Start()
        {
            if (catModel == null && transform.childCount > 0)
                catModel = transform.GetChild(0).gameObject;
            Refresh(true);
        }

        void Update() { Refresh(false); }

        void Refresh(bool force)
        {
            var enabled = ShouldEnable();
            if (!force && _lastEnabled == enabled) return;
            _lastEnabled = enabled;
            InteractionUtil.SetInteractionEnabled(gameObject, enabled);
            if (catModel != null)
            {
                AudioDirector.PlayParticle("vfx_characterChange", catModel.transform.position);
                catModel.SetActive(enabled);
            }
        }

        static bool ShouldEnable()
        {
            if (GameState.GetBool("NGPlus"))
                return GameState.GetBool("Dog_BlackCatSummoned");
            if (!GameState.GetBool("Dog_BlackCatSummoned")) return false;
            if (!GameState.GetBool("BlackCat_Entered")) return true;
            return GameState.GetBool("Comic_Revealed") && !GameState.GetBool("BlackCat_StoneRevealShown");
        }
    }
}
