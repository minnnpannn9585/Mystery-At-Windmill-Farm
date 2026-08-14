using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    public sealed class EndingController : MonoBehaviour
    {
        public GameObject[] panels;
        public Button clickArea;
        public float fadeDuration = 1f;
        public GameObject[] hideOnEnding;

        string _phase = "idle";
        float _elapsed;
        string _fadeKind;
        int _panelIndex;
        bool _finalized;
        bool _bgLocked;
        Image _bg;
        bool _advanceBound;
        GameObject _crossFrom;
        GameObject _crossTo;
        GameObject _fadeInTarget;
        GameObject _fadeOutPanel;
        float _preRemain;
        struct HudState { public GameObject Go; public bool WasActive; }
        HudState[] _hidden;

        const float PreFallback = 2f;

        void Start()
        {
            BindClick();
            if (_phase == "idle") EnsureHidden();
        }

        public void StartEnding()
        {
            if (_phase != "idle" && _phase != "done") return;
            _finalized = false;
            _panelIndex = 0;
            _fadeKind = null;
            _fadeInTarget = null;
            _fadeOutPanel = null;
            _crossFrom = null;
            _crossTo = null;
            _preRemain = 0f;
            _phase = "fadeBg";
            BindClick();
            HidePanels();
            SetClick(false);
            HideHud();
            _bgLocked = false;
            SetRaycast(true);
            AudioDirector.StopBGM();
            AudioDirector.PlayAudio("audio_preEnding");
            var len = AudioDirector.GetClipLength("audio_preEnding");
            if (len <= 0f) len = PreFallback;
            _preRemain = len;
            gameObject.SetActive(true);
            SetBg(0f);
            _fadeKind = "bg";
            _elapsed = 0f;
        }

        void Update()
        {
            var dt = Time.deltaTime;
            if ((_phase == "fadeBg" || _phase == "waitPreEnding") && _preRemain > 0f)
            {
                _preRemain -= dt;
                if (_preRemain < 0f) _preRemain = 0f;
            }
            if (_phase == "waitPreEnding")
            {
                if (_preRemain <= 0f) BeginFirst();
                return;
            }
            if (string.IsNullOrEmpty(_fadeKind)) return;
            var duration = fadeDuration <= 0f ? 1f : fadeDuration;
            _elapsed += dt;
            var p = Mathf.Clamp01(_elapsed / duration);
            var eased = p * p * (3f - 2f * p);
            if (_fadeKind == "bg") SetBg(eased);
            else if (_fadeKind == "in") SetVisual(_fadeInTarget, eased);
            else if (_fadeKind == "crossfade")
            {
                SetVisual(_crossFrom, 1f - eased);
                SetVisual(_crossTo, eased);
            }
            else if (_fadeKind == "outPanel") SetVisual(_fadeOutPanel, 1f - eased);
            else if (_fadeKind == "fadeOutBg") SetBg(1f - eased);
            if (p >= 1f)
            {
                _fadeKind = null;
                OnFadeComplete();
            }
        }

        void OnFadeComplete()
        {
            if (_phase == "fadeBg")
            {
                LockBg();
                if (_preRemain > 0f) _phase = "waitPreEnding";
                else BeginFirst();
                return;
            }
            if (_phase == "fadeIn")
            {
                SetVisual(_fadeInTarget, 1f);
                _fadeInTarget = null;
                if (PanelCount() == 0) HoldBlack();
                else { _phase = "waitClick"; SetClick(true); }
                return;
            }
            if (_phase == "crossfade")
            {
                if (_crossFrom != null) _crossFrom.SetActive(false);
                SetVisual(_crossTo, 1f);
                _crossFrom = null;
                _crossTo = null;
                _phase = "waitClick";
                SetClick(true);
                return;
            }
            if (_phase == "fadeOutPanel")
            {
                if (_fadeOutPanel != null) _fadeOutPanel.SetActive(false);
                _fadeOutPanel = null;
                HoldBlack();
                return;
            }
            if (_phase == "fadeOutBg")
            {
                SetBg(0f);
                Finish();
            }
        }

        void BeginFirst()
        {
            LockBg();
            AudioDirector.PlayMusic("audio_endingLoop");
            _panelIndex = 1;
            var go = panels != null && panels.Length > 0 ? panels[0] : null;
            if (go != null)
            {
                _phase = "fadeIn";
                _fadeInTarget = go;
                go.SetActive(true);
                SetVisual(go, 0f);
                _fadeKind = "in";
                _elapsed = 0f;
            }
            else HoldBlack();
        }

        void HoldBlack()
        {
            _phase = "holdBlack";
            LockBg();
            GameState.SetBool("NGPlus", true);
            if (LevelTeleport.Instance != null) LevelTeleport.Instance.ResetPosition();
            else
            {
                var spawn = GameObject.Find("PlayerSpawn");
                if (spawn != null) LevelTeleport.TeleportTo(spawn.transform);
            }
            _phase = "fadeOutBg";
            _bgLocked = false;
            SetClick(false);
            SetBg(1f);
            _fadeKind = "fadeOutBg";
            _elapsed = 0f;
        }

        void Finish()
        {
            if (_finalized) return;
            _finalized = true;
            _phase = "done";
            SetClick(false);
            SetRaycast(false);
            AudioDirector.StopBGM();
            AudioDirector.PlayBGM();
            RestoreHud();
            gameObject.SetActive(false);
        }

        void OnAdvance()
        {
            if (_phase != "waitClick") return;
            GameObject prev = null;
            if (panels != null && _panelIndex >= 1 && _panelIndex <= panels.Length)
                prev = panels[_panelIndex - 1];
            _panelIndex++;
            if (_panelIndex <= PanelCount())
            {
                var next = panels[_panelIndex - 1];
                _phase = "crossfade";
                _crossFrom = prev;
                _crossTo = next;
                SetClick(false);
                if (next != null) { next.SetActive(true); SetVisual(next, 0f); }
                SetVisual(prev, 1f);
                _fadeKind = "crossfade";
                _elapsed = 0f;
            }
            else
            {
                _phase = "fadeOutPanel";
                _fadeOutPanel = prev;
                LockBg();
                SetClick(false);
                _fadeKind = "outPanel";
                _elapsed = 0f;
            }
        }

        void BindClick()
        {
            if (_advanceBound) return;
            _advanceBound = true;
            if (clickArea != null)
            {
                clickArea.onClick.AddListener(OnAdvance);
                return;
            }
            var btn = GetComponent<Button>();
            if (btn == null) btn = gameObject.AddComponent<Button>();
            btn.onClick.AddListener(OnAdvance);
            clickArea = btn;
        }

        int PanelCount() { return panels == null ? 0 : panels.Length; }

        void HidePanels()
        {
            if (panels == null) return;
            for (var i = 0; i < panels.Length; i++)
                if (panels[i] != null) panels[i].SetActive(false);
        }

        void EnsureHidden()
        {
            HidePanels();
            SetBg(0f);
            gameObject.SetActive(false);
        }

        Image Bg()
        {
            if (_bg == null) _bg = GetComponent<Image>();
            return _bg;
        }

        void SetBg(float a)
        {
            if (_bgLocked && a < 1f) return;
            var img = Bg();
            if (img == null) return;
            var c = img.color;
            c.a = a;
            img.color = c;
        }

        void LockBg()
        {
            _bgLocked = true;
            SetBg(1f);
        }

        static void SetVisual(GameObject go, float a)
        {
            if (go == null) return;
            var img = go.GetComponent<Image>();
            if (img != null)
            {
                var c = img.color;
                c.a = a;
                img.color = c;
                return;
            }
            var txt = go.GetComponent<Text>();
            if (txt != null)
            {
                var c = txt.color;
                c.a = a;
                txt.color = c;
            }
        }

        void SetClick(bool on)
        {
            if (clickArea != null) clickArea.interactable = on;
        }

        void SetRaycast(bool on)
        {
            var img = Bg();
            if (img != null) img.raycastTarget = on;
        }

        void HideHud()
        {
            if (hideOnEnding == null) return;
            _hidden = new HudState[hideOnEnding.Length];
            for (var i = 0; i < hideOnEnding.Length; i++)
            {
                var go = hideOnEnding[i];
                if (go == null) continue;
                _hidden[i] = new HudState { Go = go, WasActive = go.activeSelf };
                go.SetActive(false);
            }
        }

        void RestoreHud()
        {
            if (_hidden == null) return;
            for (var i = 0; i < _hidden.Length; i++)
                if (_hidden[i].Go != null) _hidden[i].Go.SetActive(_hidden[i].WasActive);
            _hidden = null;
        }
    }
}
