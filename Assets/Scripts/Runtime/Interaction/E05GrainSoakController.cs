using UnityEngine;

namespace EggRescue
{
    public sealed class E05GrainSoakController : MonoBehaviour
    {
        public GameObject grainSoakModel;
        bool _pendingClose;
        bool? _lastClosed;

        void OnEnable()
        {
            GameEvents.E05GrainSoakGot += OnGot;
        }

        void OnDisable()
        {
            GameEvents.E05GrainSoakGot -= OnGot;
        }

        void Start() { Refresh(true); }

        void Update()
        {
            if (_pendingClose && !GameEvents.DialogueActive)
            {
                _pendingClose = false;
                ApplyClosed(true, true);
            }
        }

        void OnGot() { Refresh(false); }

        public void Refresh(bool forceImmediate)
        {
            var got = GameState.GetBool("E05_GrainSoakGet");
            if (!got)
            {
                _pendingClose = false;
                ApplyClosed(false, forceImmediate);
                return;
            }
            if (forceImmediate || !GameEvents.DialogueActive)
            {
                _pendingClose = false;
                ApplyClosed(true, forceImmediate);
                return;
            }
            _pendingClose = true;
        }

        void ApplyClosed(bool closed, bool force)
        {
            if (!force && _lastClosed == closed) return;
            _lastClosed = closed;
            InteractionUtil.SetInteractionEnabled(gameObject, !closed);
            var model = grainSoakModel != null ? grainSoakModel : (transform.Find("guwupaoshui") != null ? transform.Find("guwupaoshui").gameObject : null);
            if (model != null && model.activeSelf == closed)
                model.SetActive(!closed);
        }
    }
}
