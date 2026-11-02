using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    // Run after the third-person camera's LateUpdate so the label stays attached while turning.
    [DefaultExecutionOrder(200)]
    public sealed class WorldInteractionPrompt : MonoBehaviour
    {
        Interactable _target;
        Canvas _canvas;
        RectTransform _card;
        TMP_Text _action;

        public void SetTarget(Interactable target)
        {
            _target = target;
            if (target == null) Hide();
        }

        public static bool CanPresent(Interactable target, Camera camera)
        {
            if (target == null || !target.PromptVisible || camera == null) return false;
            var anchor = target.PromptWorldPosition;
            var viewport = camera.WorldToViewportPoint(anchor);
            if (viewport.z <= camera.nearClipPlane || viewport.x <= 0f || viewport.x >= 1f
                || viewport.y <= 0f || viewport.y >= 1f) return false;

            return true;
        }

        void LateUpdate()
        {
            var camera = Camera.main;
            if (GameEvents.InputLocked || !CanPresent(_target, camera))
            {
                Hide();
                return;
            }
            if (_canvas == null) Build();
            var text = string.IsNullOrEmpty(_target.Prompt)
                ? GameLocale.T("prompt.interact") : GameLocale.Line(_target.Prompt);
            // Existing localized prompts can contain an E prefix; the key now has its own keycap.
            if (text.Length > 1 && text[0] == 'E' && char.IsWhiteSpace(text[1]))
                text = text.Substring(1).TrimStart();
            if (_action.text != text)
            {
                _action.text = text;
                _card.sizeDelta = new Vector2(Mathf.Clamp(_action.GetPreferredValues(text).x + 88f, 150f, 560f), 56f);
            }

            var screen = camera.WorldToScreenPoint(_target.PromptWorldPosition);
            var safe = Screen.safeArea;
            var halfWidth = _card.sizeDelta.x * _canvas.scaleFactor * 0.5f;
            var height = (_card.sizeDelta.y + 8f) * _canvas.scaleFactor;
            // Never pin an offscreen prompt to an unrelated screen edge.
            if (screen.x - halfWidth < safe.xMin || screen.x + halfWidth > safe.xMax
                || screen.y < safe.yMin || screen.y + height > safe.yMax)
            {
                Hide();
                return;
            }
            Vector2 local;
            RectTransformUtility.ScreenPointToLocalPointInRectangle((RectTransform)_canvas.transform,
                screen, null, out local);
            _card.anchoredPosition = local + Vector2.up * 8f;
            _card.gameObject.SetActive(true);
        }

        void Build()
        {
            var root = new GameObject("WorldInteractionPromptCanvas", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler));
            _canvas = root.GetComponent<Canvas>();
            _canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            _canvas.sortingOrder = 10;
            var scaler = root.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.referenceResolution = new Vector2(1920f, 1080f);
            scaler.matchWidthOrHeight = 0.5f;

            _card = Rect("InteractionPrompt", root.transform, new Vector2(180f, 56f));
            _card.pivot = new Vector2(0.5f, 0f);
            var background = _card.gameObject.AddComponent<Image>();
            HudPaperStyle.Apply(background);
            background.raycastTarget = false;
            var shadow = _card.gameObject.AddComponent<Shadow>();
            shadow.effectColor = new Color(0f, 0f, 0f, 0.28f);
            shadow.effectDistance = new Vector2(0f, -3f);

            var tip = Rect("AnchorTip", _card, new Vector2(10f, 10f));
            tip.anchorMin = tip.anchorMax = new Vector2(0.5f, 0f);
            tip.localRotation = Quaternion.Euler(0f, 0f, 45f);
            var tipImage = tip.gameObject.AddComponent<Image>();
            tipImage.color = background.color;
            tipImage.raycastTarget = false;

            var key = Rect("Keycap", _card, new Vector2(38f, 38f));
            key.anchorMin = key.anchorMax = new Vector2(0f, 0.5f);
            key.anchoredPosition = new Vector2(29f, 0f);
            var keyImage = key.gameObject.AddComponent<Image>();
            HudPaperStyle.Apply(keyImage, true);
            keyImage.raycastTarget = false;
            var font = UiFontCatalog.Load();
            var keyText = Label("Key", key, font, 24f, HudPaperStyle.Ink);
            keyText.text = "E";
            keyText.fontStyle = FontStyles.Bold;
            keyText.alignment = TextAlignmentOptions.Center;

            _action = Label("Action", _card, font, 23f, HudPaperStyle.Ink);
            _action.alignment = TextAlignmentOptions.MidlineLeft;
            _action.enableWordWrapping = false;
            _action.enableAutoSizing = true;
            _action.fontSizeMin = 18f;
            _action.fontSizeMax = 23f;
            _action.overflowMode = TextOverflowModes.Ellipsis;
            _action.rectTransform.offsetMin = new Vector2(62f, 0f);
            _action.rectTransform.offsetMax = new Vector2(-16f, 0f);
        }

        static RectTransform Rect(string name, Transform parent, Vector2 size)
        {
            var rect = new GameObject(name, typeof(RectTransform)).GetComponent<RectTransform>();
            rect.SetParent(parent, false);
            rect.anchorMin = rect.anchorMax = new Vector2(0.5f, 0.5f);
            rect.sizeDelta = size;
            return rect;
        }

        static TMP_Text Label(string name, Transform parent, TMP_FontAsset font, float size, Color color)
        {
            var rect = Rect(name, parent, Vector2.zero);
            rect.anchorMin = Vector2.zero;
            rect.anchorMax = Vector2.one;
            var label = rect.gameObject.AddComponent<TextMeshProUGUI>();
            if (font != null) label.font = font;
            label.fontSize = size;
            label.color = color;
            label.raycastTarget = false;
            return label;
        }

        void Hide()
        {
            if (_card != null) _card.gameObject.SetActive(false);
        }

        void OnDisable()
        {
            _target = null;
            Hide();
        }

        void OnDestroy()
        {
            if (_canvas != null) Destroy(_canvas.gameObject);
        }
    }
}
