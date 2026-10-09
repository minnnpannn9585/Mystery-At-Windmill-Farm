using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Events;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace EggRescue
{
    /// <summary>
    /// 游戏中按 Esc 暂停。保存后回到主菜单，继续游戏会读这份存档。
    /// </summary>
    public sealed class PauseMenu : MonoBehaviour
    {
        static readonly Color Paper = new Color(0.95f, 0.91f, 0.82f, 1f);
        static readonly Color Ink = new Color(0.14f, 0.23f, 0.16f, 1f);
        static readonly Color InkSoft = new Color(0.35f, 0.40f, 0.31f, 1f);
        static readonly Color Cream = new Color(0.965f, 0.945f, 0.894f, 1f);
        static readonly Color ButtonNormal = new Color(0.18f, 0.33f, 0.22f, 1f);
        static readonly Color ButtonHighlight = new Color(0.26f, 0.45f, 0.30f, 1f);
        static readonly Color ButtonPressed = new Color(0.12f, 0.22f, 0.15f, 1f);

        static Sprite _white;

        GameObject _root;
        TMP_Text _status;
        string _statusKey;
        readonly List<BoundLabel> _labels = new List<BoundLabel>();

        sealed class BoundLabel
        {
            public TMP_Text Label;
            public string Key;
        }

        void Awake()
        {
            Build(ResolveFont());
            SetOpen(false);
        }

        void OnEnable()
        {
            GameLocale.Changed += RefreshLocale;
        }

        void OnDisable()
        {
            GameLocale.Changed -= RefreshLocale;
        }

        void OnDestroy()
        {
            if (!GameEvents.Paused) return;
            Time.timeScale = 1f;
            AudioListener.pause = false;
            GameEvents.SetPaused(false);
        }

        void Update()
        {
            if (!Input.GetKeyDown(KeyCode.Escape)) return;
            if (_root == null) return;
            SetOpen(!_root.activeSelf);
        }

        void SetOpen(bool open)
        {
            if (_root != null) _root.SetActive(open);
            GameEvents.SetPaused(open);
            Time.timeScale = open ? 0f : 1f;
            AudioListener.pause = open;
            if (open) SetStatus(null);
        }

        void SaveProgress()
        {
            SetStatus(SaveService.Save() ? "pause.saved" : "pause.save_failed");
        }

        void ReturnToMenu()
        {
            Time.timeScale = 1f;
            AudioListener.pause = false;
            GameEvents.ResetSession();
            if (_root != null) _root.SetActive(false);
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            GameSession.Pending = GameSession.Mode.Default;
            SceneManager.LoadScene(GameSession.MenuSceneName);
            if (GameBootstrap.Instance != null)
                Destroy(GameBootstrap.Instance.gameObject);
        }

        void Build(TMP_FontAsset font)
        {
            EnsureEventSystem();
            var canvasGo = new GameObject("PauseCanvas", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler), typeof(GraphicRaycaster));
            canvasGo.transform.SetParent(transform, false);
            var canvas = canvasGo.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = 300;
            var scaler = canvasGo.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920f, 1080f);
            scaler.matchWidthOrHeight = 0.5f;

            _root = new GameObject("PauseRoot", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            _root.transform.SetParent(canvasGo.transform, false);
            Stretch(_root.GetComponent<RectTransform>());
            var dim = _root.GetComponent<Image>();
            dim.color = new Color(0.05f, 0.08f, 0.06f, 0.62f);
            dim.sprite = WhiteSprite();
            dim.raycastTarget = true;

            var card = new GameObject("Paper", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            card.transform.SetParent(_root.transform, false);
            var cardRt = card.GetComponent<RectTransform>();
            cardRt.anchorMin = cardRt.anchorMax = new Vector2(0.5f, 0.5f);
            cardRt.pivot = new Vector2(0.5f, 0.5f);
            cardRt.sizeDelta = new Vector2(560f, 520f);
            var cardImage = card.GetComponent<Image>();
            cardImage.color = Paper;
            cardImage.sprite = WhiteSprite();
            cardImage.raycastTarget = true;

            AddLabel(cardRt, "pause.title", new Vector2(0f, 180f), new Vector2(480f, 64f), 42, Ink, font);
            if (!MountButtonColumn(cardRt, font))
            {
                CreateButton(cardRt, "pause.resume", new Vector2(0f, 70f), font, () => SetOpen(false));
                CreateButton(cardRt, "pause.save", new Vector2(0f, -18f), font, SaveProgress);
                CreateButton(cardRt, "pause.main_menu", new Vector2(0f, -106f), font, ReturnToMenu);
            }
            _status = AddLabel(cardRt, null, new Vector2(0f, -190f), new Vector2(480f, 40f), 22, InkSoft, font);
        }

        bool MountButtonColumn(RectTransform card, TMP_FontAsset font)
        {
            var prefab = Resources.Load<GameObject>("UI/PauseMenuColumn");
            if (prefab == null) return false;
            var instance = Instantiate(prefab, card, false);
            HookPrefabButton(instance.transform, "ResumeButton", "pause.resume", font, () => SetOpen(false));
            HookPrefabButton(instance.transform, "SaveButton", "pause.save", font, SaveProgress);
            HookPrefabButton(instance.transform, "MainMenuButton", "pause.main_menu", font, ReturnToMenu);
            return instance.GetComponent<MenuButtonColumn>() != null;
        }

        void HookPrefabButton(Transform root, string name, string key, TMP_FontAsset font, UnityAction action)
        {
            var child = root.Find(name);
            if (child == null) return;
            var button = child.GetComponent<Button>();
            var label = child.GetComponentInChildren<TMP_Text>();
            if (label != null)
            {
                if (font != null) label.font = font;
                label.text = GameLocale.T(key);
                label.ForceMeshUpdate();
                _labels.Add(new BoundLabel { Label = label, Key = key });
            }
            if (button == null) return;
            var motion = button.GetComponent<MenuButtonMotion>();
            if (motion == null) motion = button.gameObject.AddComponent<MenuButtonMotion>();
            button.onClick.AddListener(() => motion.Play(action));
        }

        void EnsureEventSystem()
        {
            if (EventSystem.current != null) return;
            var go = new GameObject("EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));
            go.transform.SetParent(transform, false);
        }

        TMP_Text AddLabel(RectTransform parent, string key, Vector2 pos, Vector2 size, float fontSize, Color color, TMP_FontAsset font)
        {
            var go = new GameObject("Label", typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = size;
            var label = go.GetComponent<TextMeshProUGUI>();
            label.fontSize = fontSize;
            label.color = color;
            label.alignment = TextAlignmentOptions.Center;
            label.enableWordWrapping = true;
            label.raycastTarget = false;
            if (font != null) label.font = font;
            if (!string.IsNullOrEmpty(key))
            {
                label.text = GameLocale.T(key);
                _labels.Add(new BoundLabel { Label = label, Key = key });
            }
            label.ForceMeshUpdate();
            return label;
        }

        Button CreateButton(RectTransform parent, string key, Vector2 pos, TMP_FontAsset font, UnityAction onClick)
        {
            var go = new GameObject(key, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image), typeof(Button));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = new Vector2(400f, 64f);
            var image = go.GetComponent<Image>();
            image.color = Color.white;
            image.sprite = WhiteSprite();
            var button = go.GetComponent<Button>();
            var colors = button.colors;
            colors.normalColor = ButtonNormal;
            colors.highlightedColor = ButtonHighlight;
            colors.pressedColor = ButtonPressed;
            colors.selectedColor = ButtonHighlight;
            colors.fadeDuration = 0.08f;
            button.colors = colors;
            button.targetGraphic = image;
            var motion = go.AddComponent<MenuButtonMotion>();
            button.onClick.AddListener(() => motion.Play(onClick));
            var label = AddLabel(rt, key, Vector2.zero, new Vector2(400f, 64f), 28f, Cream, font);
            Stretch(label.rectTransform);
            return button;
        }

        void SetStatus(string key)
        {
            _statusKey = key;
            if (_status == null) return;
            _status.text = string.IsNullOrEmpty(key) ? "" : GameLocale.T(key);
            _status.ForceMeshUpdate();
        }

        void RefreshLocale()
        {
            for (var i = 0; i < _labels.Count; i++)
            {
                var bound = _labels[i];
                if (bound.Label != null)
                {
                    bound.Label.text = GameLocale.T(bound.Key);
                    bound.Label.ForceMeshUpdate();
                }
            }
            SetStatus(_statusKey);
        }

        static void Stretch(RectTransform rt)
        {
            if (rt == null) return;
            rt.anchorMin = Vector2.zero;
            rt.anchorMax = Vector2.one;
            rt.offsetMin = Vector2.zero;
            rt.offsetMax = Vector2.zero;
            rt.pivot = new Vector2(0.5f, 0.5f);
        }

        static Sprite WhiteSprite()
        {
            if (_white != null) return _white;
            var tex = new Texture2D(1, 1, TextureFormat.RGBA32, false);
            tex.SetPixel(0, 0, Color.white);
            tex.Apply();
            tex.hideFlags = HideFlags.HideAndDontSave;
            _white = Sprite.Create(tex, new Rect(0f, 0f, 1f, 1f), new Vector2(0.5f, 0.5f), 1f);
            _white.hideFlags = HideFlags.HideAndDontSave;
            return _white;
        }

        static TMP_FontAsset ResolveFont()
        {
            return UiFontCatalog.Load();
        }
    }
}
