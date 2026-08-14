using UnityEngine;

namespace EggRescue
{
    public sealed class CheeseRefreshManager : MonoBehaviour
    {
        void OnEnable() { GameEvents.NGPlusActivated += RefreshAll; }
        void OnDisable() { GameEvents.NGPlusActivated -= RefreshAll; }

        void Start()
        {
        }

        void RefreshAll()
        {
            CheeseRegistry.ClearPicked();
            if (CheeseSpawner.Instance != null) CheeseSpawner.Instance.SpawnAll();
            var pickups = FindObjectsOfType<CheesePickup>(true);
            for (var i = 0; i < pickups.Length; i++) pickups[i].ApplyVisibility();
        }
    }
}
