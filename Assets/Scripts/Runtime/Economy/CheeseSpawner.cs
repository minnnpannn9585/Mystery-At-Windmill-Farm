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
            if (cheesePrefab == null)
            {
#if UNITY_EDITOR
                cheesePrefab = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>("Assets/Prefabs/CheesePickup.prefab");
#endif
            }
            SpawnAll();
        }

        public void SpawnAll()
        {
            if (cheesePrefab == null)
            {
                Debug.LogWarning("[CheeseSpawner] prefab missing");
                return;
            }
            for (var i = 0; i < transform.childCount; i++)
                EnsureMarker(transform.GetChild(i));
        }

        void EnsureMarker(Transform marker)
        {
            var existing = marker.Find(ChildName);
            if (existing != null)
            {
                var pickup = existing.GetComponent<CheesePickup>();
                if (pickup != null) pickup.ApplyVisibility();
                return;
            }
            if (CheeseRegistry.IsPicked(marker.name)) return;
            var go = Instantiate(cheesePrefab, marker);
            go.name = ChildName;
            go.transform.localPosition = Vector3.zero;
            go.transform.localRotation = Quaternion.identity;
            go.transform.localScale = Vector3.one;
        }
    }
}
