using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    public sealed class CheeseHud : MonoBehaviour
    {
        public Text countText;
        const float BounceDuration = 0.4f;
        const float BouncePeak = 1.5f;

        GameObject _root;
        Vector3 _baseScale;
        bool _bounce;
        float _elapsed;
        bool _unlocked;
        int _lastCount;

        void OnEnable() { GameEvents.CheeseCountChanged += OnCountChanged; }
        void OnDisable() { GameEvents.CheeseCountChanged -= OnCountChanged; }

        void Start()
        {
            _lastCount = GameState.GetInt("CheeseCount");
            var root = ResolveRoot();
            if (_lastCount > 0) Reveal(false);
            else if (root != null)
            {
                root.SetActive(false);
                _unlocked = false;
                Refresh();
            }
            else Refresh();
        }

        void Update()
        {
            if (!_bounce) return;
            var root = ResolveRoot();
            if (root == null) { _bounce = false; return; }
            _elapsed += Time.deltaTime;
            var progress = _elapsed / BounceDuration;
            if (progress >= 1f)
            {
                root.transform.localScale = _baseScale;
                _bounce = false;
                return;
            }
            var s = 1f + (BouncePeak - 1f) * Mathf.Sin(progress * Mathf.PI);
            root.transform.localScale = _baseScale * s;
        }

        void OnCountChanged()
        {
            var count = GameState.GetInt("CheeseCount");
            var gained = count > _lastCount;
            _lastCount = count;
            Refresh();
            if (!gained) return;
            if (!_unlocked) Reveal(true);
            else PlayBounce();
        }

        void Refresh()
        {
            if (countText != null) countText.text = GameState.GetInt("CheeseCount").ToString();
        }

        void Reveal(bool anim)
        {
            if (_unlocked)
            {
                Refresh();
                return;
            }
            var root = ResolveRoot();
            if (root == null) return;
            _unlocked = true;
            root.SetActive(true);
            Refresh();
            if (anim) PlayBounce();
        }

        void PlayBounce()
        {
            if (ResolveRoot() == null) return;
            _bounce = true;
            _elapsed = 0f;
        }

        GameObject ResolveRoot()
        {
            if (_root != null) return _root;
            if (countText == null || countText.transform.parent == null) return null;
            _root = countText.transform.parent.gameObject;
            _baseScale = _root.transform.localScale;
            return _root;
        }
    }
}
