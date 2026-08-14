using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public sealed class InteractionPointVfx : MonoBehaviour
    {
        public string pointId;
        public GameObject targetVfx;

        static readonly Dictionary<string, InteractionPointVfx> Discoverers = new Dictionary<string, InteractionPointVfx>();
        static readonly HashSet<string> Discovered = new HashSet<string>();

        public static IEnumerable<string> DiscoveredIds { get { return Discovered; } }

        string Id
        {
            get { return string.IsNullOrEmpty(pointId) ? gameObject.name : pointId; }
        }

        void Start()
        {
            Discoverers[Id] = this;
            SetVisible(!Discovered.Contains(Id));
        }

        void OnDestroy()
        {
            InteractionPointVfx existing;
            if (Discoverers.TryGetValue(Id, out existing) && existing == this)
                Discoverers.Remove(Id);
        }

        public void Discover()
        {
            Discovered.Add(Id);
            SetVisible(false);
        }

        public static void DiscoverFrom(GameObject go)
        {
            if (go == null) return;
            var id = go.name;
            InteractionPointVfx ctrl;
            if (Discoverers.TryGetValue(id, out ctrl) && ctrl != null)
            {
                ctrl.Discover();
                return;
            }
            if (Discovered.Contains(id)) return;
            var yellow = go.transform.Find("VFX_InteractionPoint");
            var pink = go.transform.Find("VFX_InteractionPoint_Pink");
            var vfx = yellow != null ? yellow.gameObject : (pink != null ? pink.gameObject : null);
            if (vfx != null)
            {
                vfx.SetActive(false);
                Discovered.Add(id);
            }
            var self = go.GetComponent<InteractionPointVfx>();
            if (self != null) self.Discover();
        }

        public static void MarkDiscovered(string id)
        {
            if (!string.IsNullOrEmpty(id)) Discovered.Add(id);
        }

        public static void ClearDiscovered()
        {
            Discovered.Clear();
        }

        void SetVisible(bool visible)
        {
            var vfx = targetVfx;
            if (vfx == null)
            {
                var yellow = transform.Find("VFX_InteractionPoint");
                var pink = transform.Find("VFX_InteractionPoint_Pink");
                vfx = yellow != null ? yellow.gameObject : (pink != null ? pink.gameObject : null);
            }
            if (vfx == null) return;
            vfx.SetActive(visible);
            if (!visible) return;
            var systems = vfx.GetComponentsInChildren<ParticleSystem>(true);
            for (var i = 0; i < systems.Length; i++)
            {
                systems[i].Clear(true);
                systems[i].Play(true);
            }
        }
    }
}
