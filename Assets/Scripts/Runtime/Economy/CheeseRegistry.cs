using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public static class CheeseRegistry
    {
        public struct Info
        {
            public int Amount;
            public bool RequiresNGPlus;
        }

        static readonly Dictionary<string, bool> Picked = new Dictionary<string, bool>();
        static readonly Dictionary<string, Info> Registry = new Dictionary<string, Info>();

        public static IEnumerable<string> PickedIds { get { return Picked.Keys; } }

        public static void Register(string id, int amount, bool requiresNgPlus)
        {
            if (string.IsNullOrEmpty(id)) return;
            Registry[id] = new Info { Amount = amount, RequiresNGPlus = requiresNgPlus };
        }

        public static void Unregister(string id)
        {
            if (!string.IsNullOrEmpty(id)) Registry.Remove(id);
        }

        public static bool IsPicked(string id)
        {
            return !string.IsNullOrEmpty(id) && Picked.ContainsKey(id) && Picked[id];
        }

        public static void MarkPicked(string id)
        {
            if (!string.IsNullOrEmpty(id)) Picked[id] = true;
        }

        public static void ClearPicked()
        {
            Picked.Clear();
        }

        public static int UnpickedAmount(bool ngPlus)
        {
            var sum = 0;
            foreach (var kv in Registry)
            {
                if (IsPicked(kv.Key)) continue;
                if (kv.Value.RequiresNGPlus && !ngPlus) continue;
                sum += kv.Value.Amount;
            }
            return sum;
        }
    }
}
