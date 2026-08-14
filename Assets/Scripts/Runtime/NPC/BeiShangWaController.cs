using UnityEngine;

namespace EggRescue
{
    public sealed class BeiShangWaController : MonoBehaviour
    {
        public GameObject beforeSpot;
        public GameObject afterSpot;
        public GameObject cushionSpot;

        string _lastKey;

        void Start() { AutoBind(); Check(); }

        void AutoBind()
        {
            if (beforeSpot == null) beforeSpot = FindSpot("悲伤蛙");
            if (afterSpot == null) afterSpot = FindSpot("悲伤蛙2") ?? FindSpot("悲伤蛙 2");
            if (cushionSpot == null)
            {
                var all = FindObjectsOfType<Transform>(true);
                for (var i = 0; i < all.Length; i++)
                {
                    if (all[i].name.StartsWith("E12")) { cushionSpot = all[i].gameObject; break; }
                }
            }
        }

        GameObject FindSpot(string name)
        {
            var t = transform.Find(name);
            if (t != null) return t.gameObject;
            return GameObject.Find(name);
        }
        void Update() { Check(); }

        void Check()
        {
            var got = GameState.GetBool("MintFish_Obtained");
            var key = got ? "after" : "before";
            if (_lastKey == key) return;
            _lastKey = key;
            InteractionUtil.SetSpotEnabled(beforeSpot, !got);
            InteractionUtil.SetSpotEnabled(afterSpot, got);
            InteractionUtil.SetSpotEnabled(cushionSpot, !got);
        }
    }
}
