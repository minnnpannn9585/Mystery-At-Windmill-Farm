using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public sealed class MouseBrotherShop : MonoBehaviour
    {
        public static MouseBrotherShop Instance { get; private set; }

        const int HubId = 100;
        const int HubRevisitId = 95;
        const int NgPlusHubId = 910;

        static readonly int[] CheapIntel = { 0, 500, 510, 520, 530, 540, 550, 560, 570, 580, 590 };
        static readonly int[] PremiumIntel = { 0, 600, 610, 620, 630, 640, 650, 660, 670 };

        bool _refreshing;

        void Awake() { Instance = this; }

        void OnEnable() { GameEvents.MouseFlagsNeedRefresh += RefreshDerivedFlags; }
        void OnDisable() { GameEvents.MouseFlagsNeedRefresh -= RefreshDerivedFlags; }

        void Start() { RefreshDerivedFlags(); }

        void Update()
        {
            if (Time.frameCount % 120 == 0) RefreshDerivedFlags();
        }

        public static bool HandleAction(string action, DialogueOption option)
        {
            if (Instance != null) Instance.RefreshDerivedFlags();
            if (action == "cheap")
            {
                var node = PickCheap();
                if (!node.HasValue) { GoToHub(); return true; }
                if (!TrySpend(1)) { GoToHub(); return true; }
                if (Instance != null) Instance.RefreshDerivedFlags();
                Jump(node.Value);
                return true;
            }
            if (action == "premium")
            {
                var node = PickPremium();
                if (!node.HasValue) { GoToHub(); return true; }
                if (!TrySpend(5)) { GoToHub(); return true; }
                if (Instance != null) Instance.RefreshDerivedFlags();
                Jump(node.Value);
                return true;
            }
            if (action == "pay8_mint" || action == "pay8_frog")
            {
                if (!TrySpend(8))
                {
                    Jump(260);
                    return true;
                }
                GameState.SetBool("Mouse_MintFishPaid", true);
                GameState.SetBool("Mouse_PremiumPoolUnlocked", true);
                if (Instance != null) Instance.RefreshDerivedFlags();
                if (option != null && option.Next > 0) Jump(option.Next);
                else GoToHub();
                return true;
            }
            return false;
        }

        public static bool TrySpend(int amount)
        {
            var cur = GameState.GetInt("CheeseCount");
            if (cur < amount) return false;
            GameState.SetInt("CheeseCount", cur - amount);
            return true;
        }

        public void RefreshDerivedFlags()
        {
            if (_refreshing) return;
            _refreshing = true;
            GameState.SetBool("Mouse_CheapPoolAvailable", CheapAvailable());
            GameState.SetBool("Mouse_PremiumPoolAvailable", PremiumAvailable());
            GameState.SetBool("Mouse_CanAffordMint8InGame", CheeseRemainingTotal() >= 8);
            _refreshing = false;
        }

        static bool CheapAvailable()
        {
            for (var i = 1; i <= 10; i++)
                if (!Sold("Mouse_CheapSold_" + i.ToString("00"))) return true;
            return false;
        }

        static bool PremiumAvailable()
        {
            var limit = GameState.GetBool("Mouse_PremiumPoolUnlocked") ? 8 : 2;
            for (var i = 1; i <= limit; i++)
                if (!Sold("Mouse_PremiumSold_" + i.ToString("00"))) return true;
            return false;
        }

        static bool Sold(string name) { return GameState.GetBool(name); }

        static int? PickCheap()
        {
            var available = new List<int>();
            for (var i = 1; i <= 10; i++)
                if (!Sold("Mouse_CheapSold_" + i.ToString("00"))) available.Add(CheapIntel[i]);
            if (available.Count == 0) return null;
            return available[Random.Range(0, available.Count)];
        }

        static int? PickPremium()
        {
            var limit = GameState.GetBool("Mouse_PremiumPoolUnlocked") ? 8 : 2;
            var available = new List<int>();
            for (var i = 1; i <= limit; i++)
                if (!Sold("Mouse_PremiumSold_" + i.ToString("00"))) available.Add(PremiumIntel[i]);
            if (available.Count == 0) return null;
            return available[Random.Range(0, available.Count)];
        }

        static int CheeseRemainingTotal()
        {
            return GameState.GetInt("CheeseCount") + CheeseRegistry.UnpickedAmount(GameState.GetBool("NGPlus"));
        }

        static void GoToHub()
        {
            if (GameState.GetBool("NGPlus")) Jump(NgPlusHubId);
            else if (GameState.GetBool("Mouse_FirstGreetShown")) Jump(HubRevisitId);
            else Jump(HubId);
        }

        static void Jump(int nodeId)
        {
            if (DialogueManager.Instance != null)
                DialogueManager.Instance.JumpToNode(nodeId);
        }
    }
}
