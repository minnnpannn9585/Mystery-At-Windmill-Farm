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

        bool _pickedThisSession;

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

        void Awake()
        {
            EnsureTrigger();
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
            TryPickup();
        }

        void OnTriggerStay(Collider other)
        {
            if (!InteractionUtil.IsLocalPlayer(other)) return;
            TryPickup();
        }

        void LateUpdate()
        {
            if (_pickedThisSession || CheeseRegistry.IsPicked(Id)) return;
            var player = PlayerController.Instance;
            if (player == null) return;
            var cc = player.GetComponent<CharacterController>();
            var col = ResolveCollider();
            if (cc == null || col == null || !col.enabled) return;
            if (col.bounds.Intersects(cc.bounds))
                TryPickup();
        }

        public void EnsureTrigger()
        {
            var col = ResolveCollider();
            if (col == null)
            {
                var box = gameObject.AddComponent<BoxCollider>();
                box.size = new Vector3(0.8f, 0.8f, 0.8f);
                box.center = new Vector3(0f, 0.4f, 0f);
                col = box;
            }
            col.isTrigger = true;
            col.enabled = true;
        }

        public void TryPickup()
        {
            if (_pickedThisSession || CheeseRegistry.IsPicked(Id)) return;
            if (requiresNGPlus && !GameState.GetBool("NGPlus")) return;
            _pickedThisSession = true;
            GameState.SetInt("CheeseCount", GameState.GetInt("CheeseCount") + amount);
            CheeseRegistry.MarkPicked(Id);
            AudioDirector.PlayAudio("audio_cheese");
            PlayVfx();
            Hide(false);
        }

        public void ApplyVisibility()
        {
            var ngOk = !requiresNGPlus || GameState.GetBool("NGPlus");
            if (ngOk && !CheeseRegistry.IsPicked(Id))
            {
                _pickedThisSession = false;
                Show();
            }
            else Hide(true);
        }

        void Hide(bool hideVfx)
        {
            var vis = ResolveVisual();
            if (vis != null) vis.SetActive(false);
            var col = ResolveCollider();
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
            EnsureTrigger();
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

        Collider ResolveCollider()
        {
            var col = GetComponent<Collider>();
            if (col != null) return col;
            return GetComponentInChildren<Collider>(true);
        }

        GameObject ResolveVisual()
        {
            if (visualRoot != null) return visualRoot;
            var t = transform.Find("cheeseSingle");
            if (t == null) t = transform.Find("Visual");
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
