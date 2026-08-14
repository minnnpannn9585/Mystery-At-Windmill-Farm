using UnityEngine;

namespace EggRescue
{
    public sealed class CheesePickup : MonoBehaviour
    {
        public string pickupId;
        public int amount = 1;
        public bool requiresNGPlus;
        public GameObject visualRoot;
        public GameObject pickupVfx;

        string Id
        {
            get
            {
                if (!string.IsNullOrEmpty(pickupId)) return pickupId;
                var parent = transform.parent;
                if (parent != null && parent.parent != null && parent.parent.name == "奶酪散点")
                    return parent.name;
                return gameObject.name;
            }
        }

        void Start()
        {
            CheeseRegistry.Register(Id, amount, requiresNGPlus);
            ApplyVisibility();
        }

        void OnDestroy()
        {
            CheeseRegistry.Unregister(Id);
        }

        void OnTriggerEnter(Collider other)
        {
            if (!InteractionUtil.IsLocalPlayer(other)) return;
            AudioDirector.PlayAudio("audio_cheese");
            TryPickup();
        }

        public void TryPickup()
        {
            if (CheeseRegistry.IsPicked(Id)) return;
            if (requiresNGPlus && !GameState.GetBool("NGPlus")) return;
            GameState.SetInt("CheeseCount", GameState.GetInt("CheeseCount") + amount);
            CheeseRegistry.MarkPicked(Id);
            PlayVfx();
            Hide(false);
        }

        public void ApplyVisibility()
        {
            var ngOk = !requiresNGPlus || GameState.GetBool("NGPlus");
            if (ngOk && !CheeseRegistry.IsPicked(Id)) Show();
            else Hide(true);
        }

        void Hide(bool hideVfx)
        {
            var vis = ResolveVisual();
            if (vis != null) vis.SetActive(false);
            var col = GetComponent<Collider>();
            if (col != null) col.enabled = false;
            if (hideVfx)
            {
                var vfx = ResolveVfx();
                if (vfx != null) vfx.SetActive(false);
            }
        }

        void Show()
        {
            var vis = ResolveVisual();
            if (vis != null) vis.SetActive(true);
            var col = GetComponent<Collider>();
            if (col != null) col.enabled = true;
            var vfx = ResolveVfx();
            if (vfx != null)
            {
                vfx.SetActive(true);
                var systems = vfx.GetComponentsInChildren<ParticleSystem>(true);
                var stop = ParticleSystemStopBehavior.StopEmittingAndClear;
                for (var i = 0; i < systems.Length; i++) systems[i].Stop(true, stop);
            }
        }

        void PlayVfx()
        {
            var vfx = ResolveVfx();
            if (vfx == null) return;
            vfx.SetActive(true);
            var systems = vfx.GetComponentsInChildren<ParticleSystem>(true);
            for (var i = 0; i < systems.Length; i++)
            {
                systems[i].Clear(true);
                systems[i].Play(true);
            }
        }

        GameObject ResolveVisual()
        {
            if (visualRoot != null) return visualRoot;
            var t = transform.Find("cheeseSingle");
            return t != null ? t.gameObject : null;
        }

        GameObject ResolveVfx()
        {
            if (pickupVfx != null) return pickupVfx;
            var t = transform.Find("vfx_interact");
            return t != null ? t.gameObject : null;
        }
    }
}
