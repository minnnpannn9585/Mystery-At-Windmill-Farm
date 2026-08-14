using UnityEngine;

namespace EggRescue
{
    /// <summary>
    /// 淑芬三地点切换，对齐 ShuFen.lua：
    /// !NGPlus && !Shufen_CommissionDone → 淑芬1（委托，挡农场大门）
    /// !NGPlus && Shufen_CommissionDone  → 淑芬2（农场内 hub）
    /// NGPlus                            → 淑芬3
    /// 只切换三个 Spot 的显隐，不关 parent。
    /// </summary>
    public sealed class ShuFenController : MonoBehaviour
    {
        public GameObject commissionSpot;
        public GameObject hubSpot;
        public GameObject ngPlusSpot;
        public Collider gateBlockCollider;

        string _lastKey;
        bool? _lastCommissionDone;

        void Awake()
        {
            AutoBind();
            Check();
        }

        void Update()
        {
            Check();
        }

        void AutoBind()
        {
            if (commissionSpot == null)
            {
                commissionSpot = FindSpot("淑芬1");
                if (commissionSpot == null || commissionSpot == gameObject)
                {
                    var legacy = FindSpot("淑芬");
                    if (legacy != null && legacy != gameObject)
                        commissionSpot = legacy;
                }
            }
            if (hubSpot == null)
                hubSpot = FindSpot("淑芬2") ?? FindSpot("淑芬 2");
            if (ngPlusSpot == null)
                ngPlusSpot = FindSpot("淑芬3") ?? FindSpot("淑芬 3");

            if (gateBlockCollider == null)
            {
                var gate = FindSpot("HenQuestBlock");
                if (gate != null) gateBlockCollider = gate.GetComponent<Collider>();
            }
        }

        GameObject FindSpot(string name)
        {
            if (gameObject.name == name) return gameObject;
            return InteractionUtil.FindChildOrWorld(transform, name);
        }

        void Check()
        {
            var done = GameState.GetBool("Shufen_CommissionDone");
            var ng = GameState.GetBool("NGPlus");
            var key = ng ? "ngplus" : (done ? "hub" : "commission");

            if (!_lastCommissionDone.HasValue || _lastCommissionDone.Value != done)
            {
                _lastCommissionDone = done;
                if (gateBlockCollider != null)
                    gateBlockCollider.enabled = !done;
            }

            if (_lastKey == key) return;
            var firstApply = _lastKey == null;
            _lastKey = key;
            InteractionUtil.SetSpotEnabled(commissionSpot, key == "commission", !firstApply);
            InteractionUtil.SetSpotEnabled(hubSpot, key == "hub", !firstApply);
            InteractionUtil.SetSpotEnabled(ngPlusSpot, key == "ngplus", !firstApply);
        }
    }
}
