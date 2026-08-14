using UnityEngine;

namespace EggRescue
{
    public sealed class CheeseSpawner : MonoBehaviour
    {
        public GameObject cheesePrefab;
        const string ChildName = "Pickup";
        public static CheeseSpawner Instance { get; private set; }

        void Awake() { Instance = this; }

        void Start()
        {
            ResolvePrefab();
            SpawnAll();
        }

        public void SpawnAll()
        {
            ResolvePrefab();
            if (cheesePrefab == null)
            {
                Debug.LogWarning("[CheeseSpawner] prefab missing");
                return;
            }
            for (var i = 0; i < transform.childCount; i++)
                EnsureMarker(transform.GetChild(i));
        }

        void ResolvePrefab()
        {
            if (cheesePrefab != null) return;
            cheesePrefab = Resources.Load<GameObject>("CheesePickup");
#if UNITY_EDITOR
            if (cheesePrefab == null)
                cheesePrefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Prefabs/CheesePickup.prefab");
#endif
        }

        void EnsureMarker(Transform marker)
        {
            var existing = marker.Find(ChildName);
            if (existing != null)
            {
                WirePickup(existing.gameObject, marker.name);
                return;
            }
            if (CheeseRegistry.IsPicked(marker.name)) return;
            var go = Instantiate(cheesePrefab, marker);
            go.name = ChildName;
            go.transform.localPosition = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
            WirePickup(go, marker.name);
        }

        static void WirePickup(GameObject go, string markerName)
        {
            if (go == null) return;
            DisableDouyin(go);
            var pickup = go.GetComponent<CheesePickup>();
            if (pickup == null) pickup = go.AddComponent<CheesePickup>();
            if (string.IsNullOrEmpty(pickup.pickupId))
                pickup.pickupId = markerName;
            if (markerName != null && markerName.StartsWith("C02"))
                pickup.requiresNGPlus = true;
            pickup.EnsureTrigger();
            pickup.ApplyVisibility();
        }

        static void DisableDouyin(GameObject go)
        {
            var behaviours = go.GetComponentsInChildren<MonoBehaviour>(true);
            for (var i = 0; i < behaviours.Length; i++)
            {
                var mb = behaviours[i];
                if (mb != null && mb.GetType().Name == "DouyinScript")
                    mb.enabled = false;
            }
        }
    }
}
