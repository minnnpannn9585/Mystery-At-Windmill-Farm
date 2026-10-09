using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace EggRescue
{
    /// <summary>
    /// 主菜单：开始新游戏、继续存档、音量与鼠标灵敏度、退出。进入 Mechanics_Code。
    /// </summary>
    public sealed class StartMenuController : MonoBehaviour
    {
        static readonly Color Meadow = new Color(0.13f, 0.22f, 0.16f, 1f);
        static readonly Color Paper = new Color(0.95f, 0.91f, 0.82f, 1f);
        static readonly Color Ink = new Color(0.14f, 0.23f, 0.16f, 1f);
        static readonly Color InkSoft = new Color(0.35f, 0.40f, 0.31f, 1f);
        static readonly Color Cream = new Color(0.965f, 0.945f, 0.894f, 1f);
        static readonly Color ButtonNormal = new Color(0.18f, 0.33f, 0.22f, 1f);
        static readonly Color ButtonHighlight = new Color(0.26f, 0.45f, 0.30f, 1f);
        static readonly Color ButtonPressed = new Color(0.12f, 0.22f, 0.15f, 1f);

        const float ButtonWidth = 400f;
        const float ButtonHeight = 64f;

        static Sprite _white;
        static Sprite _panelSprite;
        static bool _panelSliced;

        Button _start;
        Button _load;
        Button _settings;
        Button _quit;
        TMP_Text _hint;
        Button _langZh;
        Button _langEn;
        GameObject _settingsRoot;
        GameObject _confirmRoot;
        Slider _volumeSlider;
        Slider _sensitivitySlider;
        TMP_Text _volumeValue;
        TMP_Text _sensitivityValue;
        bool _entering;
        readonly List<BoundLabel> _labels = new List<BoundLabel>();

        sealed class BoundLabel
        {
            public TMP_Text Label;
            public string Key;
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void EnsureOnMenu()
        {
            if (SceneManager.GetActiveScene().name != GameSession.MenuSceneName) return;
            if (FindObjectOfType<StartMenuController>() != null) return;
            var canvas = GameObject.Find("Canvas");
            if (canvas == null) return;
            canvas.AddComponent<StartMenuController>();
        }

        void Awake()
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
            GameSettings.Load();
            CachePanelSprite();
            var font = ResolveFont();
            Arrange(font);
            BuildSettings(font);
            BuildConfirm(font);
            Wire();
            RefreshSaveState();
        }

        void OnEnable()
        {
            GameLocale.Changed += RefreshLocale;
        }

        void OnDisable()
        {
            GameLocale.Changed -= RefreshLocale;
        }

        void Start()
        {
            if (EventSystem.current != null && _start != null)
                EventSystem.current.SetSelectedGameObject(_start.gameObject);
        }

        void Update()
        {
            if (!Input.GetKeyDown(KeyCode.Escape)) return;
            if (_confirmRoot != null && _confirmRoot.activeSelf) SetOpen(_confirmRoot, false);
            else if (_settingsRoot != null && _settingsRoot.activeSelf) SetOpen(_settingsRoot, false);
        }

        void Arrange(TMP_FontAsset font)
        {
            var bg = transform.Find("Background");
            if (bg == null) bg = transform.Find("Image");
            if (bg != null)
            {
                bg.name = "Background";
                Stretch(bg.GetComponent<RectTransform>());
                var image = bg.GetComponent<Image>();
                if (image != null)
                {
                    image.color = Meadow;
                    image.raycastTarget = false;
                    if (image.sprite == null)
                        image.sprite = WhiteSprite();
                }
            }

            EnsureCard();
            EnsureLabel("Title", "menu.title", new Vector2(0f, 268f), new Vector2(560f, 90f), 64f, Ink, font, 8f);
            EnsureLabel("Subtitle", "menu.subtitle", new Vector2(0f, 168f), new Vector2(560f, 40f), 26f, InkSoft, font, 2f);
            _start = LayoutButton("StartButton", "menu.start", 72f, font);
            _load = LayoutButton("LoadButton", "menu.continue", -16f, font);
            _settings = LayoutButton("SettingButton", "menu.settings", -104f, font);
            _quit = LayoutButton("QuitButton", "menu.quit", -192f, font);
            _hint = EnsureLabel("Hint", null, new Vector2(0f, -278f), new Vector2(520f, 36f), 22f, InkSoft, font, 0f);
            EnsureLabel("Controls", "menu.controls", new Vector2(0f, -340f), new Vector2(540f, 32f), 18f, InkSoft, font, 1f);
        }

        void EnsureCard()
        {
            var existing = transform.Find("MenuCard");
            RectTransform rt;
            Image image;
            if (existing == null)
            {
                var go = new GameObject("MenuCard", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
                go.transform.SetParent(transform, false);
                go.transform.SetSiblingIndex(1);
                rt = go.GetComponent<RectTransform>();
                image = go.GetComponent<Image>();
            }
            else
            {
                rt = existing.GetComponent<RectTransform>();
                image = existing.GetComponent<Image>();
            }
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = new Vector2(0f, -10f);
            rt.sizeDelta = new Vector2(620f, 780f);
            if (image == null) return;
            image.color = Paper;
            image.raycastTarget = false;
            if (image.sprite == null)
                ApplyPanelSprite(image);
        }

        TMP_Text EnsureLabel(string name, string key, Vector2 pos, Vector2 size, float fontSize, Color color, TMP_FontAsset font, float spacing)
        {
            var existing = transform.Find(name);
            TMP_Text label;
            RectTransform rt;
            if (existing == null)
            {
                var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
                go.transform.SetParent(transform, false);
                label = go.GetComponent<TextMeshProUGUI>();
                rt = go.GetComponent<RectTransform>();
            }
            else
            {
                rt = existing.GetComponent<RectTransform>();
                label = existing.GetComponent<TMP_Text>();
                if (label == null) label = existing.gameObject.AddComponent<TextMeshProUGUI>();
            }
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = size;
            label.fontSize = fontSize;
            label.color = color;
            label.alignment = TextAlignmentOptions.Center;
            label.characterSpacing = spacing;
            label.raycastTarget = false;
            label.enableWordWrapping = true;
            if (font != null) label.font = font;
            Bind(label, key);
            return label;
        }

        Button LayoutButton(string name, string key, float y, TMP_FontAsset font)
        {
            var go = GameObject.Find(name);
            if (go == null) return null;
            var button = go.GetComponent<Button>();
            var rt = go.GetComponent<RectTransform>();
            if (rt != null)
            {
                rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
                rt.pivot = new Vector2(0.5f, 0.5f);
                rt.anchoredPosition = new Vector2(0f, y);
                rt.sizeDelta = new Vector2(ButtonWidth, ButtonHeight);
            }
            if (button != null)
            {
                var colors = button.colors;
                colors.normalColor = ButtonNormal;
                colors.highlightedColor = ButtonHighlight;
                colors.pressedColor = ButtonPressed;
                colors.selectedColor = ButtonHighlight;
                colors.disabledColor = new Color(ButtonNormal.r, ButtonNormal.g, ButtonNormal.b, 0.35f);
                colors.fadeDuration = 0.08f;
                button.colors = colors;
            }
            var label = go.GetComponentInChildren<TMP_Text>();
            if (label != null)
            {
                label.fontSize = 30f;
                label.color = Cream;
                label.alignment = TextAlignmentOptions.Center;
                label.raycastTarget = false;
                if (font != null) label.font = font;
                Bind(label, key);
            }
            return button;
        }

        void Wire()
        {
            if (_start != null) _start.onClick.AddListener(OnStart);
            if (_load != null) _load.onClick.AddListener(OnContinue);
            if (_settings != null) _settings.onClick.AddListener(OpenSettings);
            if (_quit != null) _quit.onClick.AddListener(QuitGame);
        }

        void RefreshSaveState()
        {
            var hasSave = SaveService.Exists();
            if (_load != null) _load.interactable = hasSave;
            if (_hint == null) return;
            _hint.text = GameLocale.T(hasSave ? "menu.save_ready" : "menu.no_save");
        }

        void OnStart()
        {
            if (SaveService.Exists())
            {
                SetOpen(_confirmRoot, true);
                return;
            }
            EnterGame(GameSession.Mode.NewGame);
        }

        void OnContinue()
        {
            if (!SaveService.Exists())
            {
                RefreshSaveState();
                return;
            }
            EnterGame(GameSession.Mode.Continue);
        }

        void EnterGame(GameSession.Mode mode)
        {
            if (_entering) return;
            if (!Application.CanStreamedLevelBeLoaded(GameSession.GameSceneName))
            {
                SetOpen(_confirmRoot, false);
                if (_hint != null) _hint.text = GameLocale.T("menu.missing_scene");
                Debug.LogError("[StartMenu] Build Settings 缺少 " + GameSession.GameSceneName);
                return;
            }
            _entering = true;
            GameSession.Pending = mode;
            SceneManager.LoadScene(GameSession.GameSceneName);
        }

        void OpenSettings()
        {
            if (_volumeSlider != null) _volumeSlider.SetValueWithoutNotify(GameSettings.MasterVolume);
            if (_sensitivitySlider != null) _sensitivitySlider.SetValueWithoutNotify(GameSettings.MouseSensitivity);
            RefreshSettingLabels();
            SetOpen(_settingsRoot, true);
        }

        void QuitGame()
        {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit();
#endif
        }

        void BuildSettings(TMP_FontAsset font)
        {
            _settingsRoot = CreateOverlay("SettingsOverlay");
            var card = CreatePaper(_settingsRoot.transform, new Vector2(640f, 520f));
            AddLabel(card, "menu.settings_title", new Vector2(0f, 190f), new Vector2(480f, 60f), 40f, Ink, font);
            AddLabel(card, "menu.volume", new Vector2(-150f, 110f), new Vector2(160f, 36f), 24f, Ink, font);
            AddLabel(card, "menu.sensitivity", new Vector2(-150f, 10f), new Vector2(220f, 36f), 24f, Ink, font);
            AddLabel(card, "menu.language", new Vector2(-150f, -90f), new Vector2(160f, 36f), 24f, Ink, font);
            _volumeValue = AddLabel(card, null, new Vector2(220f, 110f), new Vector2(80f, 36f), 22f, InkSoft, font);
            _sensitivityValue = AddLabel(card, null, new Vector2(220f, 10f), new Vector2(80f, 36f), 22f, InkSoft, font);
            _volumeSlider = CreateSlider(card, new Vector2(40f, 68f), 0f, 1f, GameSettings.MasterVolume);
            _sensitivitySlider = CreateSlider(card, new Vector2(40f, -32f), 0.6f, 5f, GameSettings.MouseSensitivity);
            _volumeSlider.onValueChanged.AddListener(value =>
            {
                GameSettings.SetMasterVolume(value);
                RefreshSettingLabels();
            });
            _sensitivitySlider.onValueChanged.AddListener(value =>
            {
                GameSettings.SetMouseSensitivity(value);
                RefreshSettingLabels();
            });
            _langZh = CreateButton(card, "menu.lang_zh", new Vector2(-90f, -140f), new Vector2(160f, 52f), font);
            _langEn = CreateButton(card, "menu.lang_en", new Vector2(90f, -140f), new Vector2(160f, 52f), font);
            _langZh.onClick.AddListener(() => GameLocale.Set(GameLocale.Chinese));
            _langEn.onClick.AddListener(() => GameLocale.Set(GameLocale.English));
            var back = CreateButton(card, "menu.back", new Vector2(0f, -210f), new Vector2(220f, 56f), font);
            back.onClick.AddListener(() => SetOpen(_settingsRoot, false));
            RefreshSettingLabels();
            RefreshLanguageButtons();
        }

        void BuildConfirm(TMP_FontAsset font)
        {
            _confirmRoot = CreateOverlay("ConfirmOverlay");
            var card = CreatePaper(_confirmRoot.transform, new Vector2(640f, 360f));
            AddLabel(card, "menu.confirm_title", new Vector2(0f, 90f), new Vector2(520f, 56f), 36f, Ink, font);
            AddLabel(card, "menu.confirm_body", new Vector2(0f, 20f), new Vector2(520f, 72f), 22f, InkSoft, font);
            var ok = CreateButton(card, "menu.confirm_ok", new Vector2(-120f, -100f), new Vector2(180f, 56f), font);
            var cancel = CreateButton(card, "menu.confirm_cancel", new Vector2(120f, -100f), new Vector2(180f, 56f), font);
            ok.onClick.AddListener(() => EnterGame(GameSession.Mode.NewGame));
            cancel.onClick.AddListener(() => SetOpen(_confirmRoot, false));
        }

        void RefreshSettingLabels()
        {
            if (_volumeValue != null)
                _volumeValue.text = Mathf.RoundToInt(GameSettings.MasterVolume * 100f) + "%";
            if (_sensitivityValue != null)
                _sensitivityValue.text = GameSettings.MouseSensitivity.ToString("0.0");
        }

        void SetOpen(GameObject panel, bool open)
        {
            if (panel == null) return;
            panel.SetActive(open);
            if (open) panel.transform.SetAsLastSibling();
        }

        GameObject CreateOverlay(string name)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(transform, false);
            Stretch(go.GetComponent<RectTransform>());
            var image = go.GetComponent<Image>();
            image.color = new Color(0.05f, 0.08f, 0.06f, 0.62f);
            image.sprite = WhiteSprite();
            image.type = Image.Type.Simple;
            go.SetActive(false);
            return go;
        }

        static RectTransform CreatePaper(Transform parent, Vector2 size)
        {
            var go = new GameObject("Paper", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.sizeDelta = size;
            var image = go.GetComponent<Image>();
            image.color = Paper;
            ApplyPanelSprite(image);
            return rt;
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
            label.raycastTarget = false;
            label.enableWordWrapping = true;
            if (font != null) label.font = font;
            Bind(label, key);
            return label;
        }

        Button CreateButton(RectTransform parent, string key, Vector2 pos, Vector2 size, TMP_FontAsset font)
        {
            var go = new GameObject(key, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image), typeof(Button));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = size;
            var image = go.GetComponent<Image>();
            image.color = Color.white;
            ApplyPanelSprite(image);
            var button = go.GetComponent<Button>();
            var colors = button.colors;
            colors.normalColor = ButtonNormal;
            colors.highlightedColor = ButtonHighlight;
            colors.pressedColor = ButtonPressed;
            colors.selectedColor = ButtonHighlight;
            colors.fadeDuration = 0.08f;
            button.colors = colors;
            button.targetGraphic = image;
            var labelGo = new GameObject("Text", typeof(RectTransform), typeof(CanvasRenderer), typeof(TextMeshProUGUI));
            labelGo.transform.SetParent(go.transform, false);
            Stretch(labelGo.GetComponent<RectTransform>());
            var label = labelGo.GetComponent<TextMeshProUGUI>();
            label.fontSize = 26f;
            label.color = Cream;
            label.alignment = TextAlignmentOptions.Center;
            label.raycastTarget = false;
            if (font != null) label.font = font;
            Bind(label, key);
            return button;
        }

        void Bind(TMP_Text label, string key)
        {
            if (label == null || string.IsNullOrEmpty(key)) return;
            label.text = GameLocale.T(key);
            _labels.Add(new BoundLabel { Label = label, Key = key });
        }

        void RefreshLocale()
        {
            for (var i = 0; i < _labels.Count; i++)
            {
                var bound = _labels[i];
                if (bound.Label != null) bound.Label.text = GameLocale.T(bound.Key);
            }
            RefreshSaveState();
            RefreshLanguageButtons();
        }

        void RefreshLanguageButtons()
        {
            StyleLanguageButton(_langZh, !GameLocale.IsEnglish);
            StyleLanguageButton(_langEn, GameLocale.IsEnglish);
        }

        static void StyleLanguageButton(Button button, bool selected)
        {
            if (button == null) return;
            var colors = button.colors;
            colors.normalColor = selected ? ButtonHighlight : ButtonNormal;
            colors.selectedColor = colors.normalColor;
            button.colors = colors;
        }

        static Slider CreateSlider(RectTransform parent, Vector2 pos, float min, float max, float value)
        {
            var go = new GameObject("Slider", typeof(RectTransform));
            go.transform.SetParent(parent, false);
            var rt = go.GetComponent<RectTransform>();
            rt.anchorMin = rt.anchorMax = new Vector2(0.5f, 0.5f);
            rt.pivot = new Vector2(0.5f, 0.5f);
            rt.anchoredPosition = pos;
            rt.sizeDelta = new Vector2(360f, 24f);

            var background = CreateImage(go.transform, "Background", new Color(0.75f, 0.70f, 0.58f, 1f));
            Stretch(background.rectTransform);

            var fillArea = new GameObject("Fill Area", typeof(RectTransform));
            fillArea.transform.SetParent(go.transform, false);
            var fillAreaRt = fillArea.GetComponent<RectTransform>();
            Stretch(fillAreaRt);
            fillAreaRt.offsetMin = new Vector2(6f, 5f);
            fillAreaRt.offsetMax = new Vector2(-6f, -5f);
            var fill = CreateImage(fillArea.transform, "Fill", ButtonNormal);
            Stretch(fill.rectTransform);

            var handleArea = new GameObject("Handle Slide Area", typeof(RectTransform));
            handleArea.transform.SetParent(go.transform, false);
            var handleAreaRt = handleArea.GetComponent<RectTransform>();
            Stretch(handleAreaRt);
            handleAreaRt.offsetMin = new Vector2(10f, 0f);
            handleAreaRt.offsetMax = new Vector2(-10f, 0f);
            var handle = CreateImage(handleArea.transform, "Handle", Cream);
            handle.rectTransform.sizeDelta = new Vector2(18f, 28f);

            var slider = go.AddComponent<Slider>();
            slider.fillRect = fill.rectTransform;
            slider.handleRect = handle.rectTransform;
            slider.targetGraphic = handle;
            slider.direction = Slider.Direction.LeftToRight;
            slider.minValue = min;
            slider.maxValue = max;
            slider.value = value;
            return slider;
        }

        static Image CreateImage(Transform parent, string name, Color color)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            var image = go.GetComponent<Image>();
            image.color = color;
            ApplyPanelSprite(image);
            return image;
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

        void CachePanelSprite()
        {
            var images = GetComponentsInChildren<Image>(true);
            for (var i = 0; i < images.Length; i++)
            {
                var sprite = images[i] != null ? images[i].sprite : null;
                if (sprite == null) continue;
                _panelSprite = sprite;
                _panelSliced = sprite.border.sqrMagnitude > 0.01f;
                return;
            }
            _panelSprite = WhiteSprite();
            _panelSliced = false;
        }

        static void ApplyPanelSprite(Image image)
        {
            if (image == null) return;
            image.sprite = _panelSprite != null ? _panelSprite : WhiteSprite();
            image.type = _panelSliced ? Image.Type.Sliced : Image.Type.Simple;
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
            var texts = FindObjectsOfType<TMP_Text>(true);
            for (var i = 0; i < texts.Length; i++)
            {
                if (texts[i] != null && texts[i].font != null)
                    return texts[i].font;
            }
            return TMP_Settings.defaultFontAsset;
        }
    }
}
