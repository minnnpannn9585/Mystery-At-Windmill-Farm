using UnityEngine;

namespace EggRescue
{
    public sealed class ShuFenController : MonoBehaviour
    {
        public GameObject commissionSpot;
        public GameObject hubSpot;
        public GameObject ngPlusSpot;
        public Collider gateBlockCollider;

        string _lastKey;

        void Start() { AutoBind(); Check(); }

        void AutoBind()
        {
            if (commissionSpot == null) commissionSpot = FindSpot("淑芬", false);
            if (hubSpot == null) hubSpot = FindSpot("淑芬2", true) ?? FindSpot("淑芬 2", true);
            if (ngPlusSpot == null) ngPlusSpot = FindSpot("淑芬3", true) ?? FindSpot("淑芬 3", true);
        }

        GameObject FindSpot(string name, bool skipSelf)
        {
            var t = transform.Find(name);
            if (t != null) return t.gameObject;
            var go = GameObject.Find(name);
            if (go == null) return null;
            if (skipSelf && go == gameObject) return null;
            return go;
        }
        void Update() { Check(); }

        void Check()
        {
            var done = GameState.GetBool("Shufen_CommissionDone");
            var ng = GameState.GetBool("NGPlus");
            var key = ng ? "ngplus" : (done ? "hub" : "commission");
            if (gateBlockCollider != null) gateBlockCollider.enabled = !done;
            if (_lastKey == key) return;
            _lastKey = key;
            InteractionUtil.SetSpotEnabled(commissionSpot, key == "commission");
            InteractionUtil.SetSpotEnabled(hubSpot, key == "hub");
            InteractionUtil.SetSpotEnabled(ngPlusSpot, key == "ngplus");
        }
    }
}
