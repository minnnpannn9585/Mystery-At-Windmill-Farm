using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    /// <summary>Compact exploration HUD. Keeps the prefab's bindings and artwork intact.</summary>
    public sealed class GameplayHud : MonoBehaviour
    {
        RectTransform _root;
        CanvasGroup _group;
        TMP_Text _title;
        TMP_Text _cheeseTitle;
        Rect _safeArea;
        Vector2 _parentSize;

        public static GameplayHud Install(BookController book)
        {
            var hud = book.GetComponent<GameplayHud>();
            if (hud == null) hud = book.gameObject.AddComponent<GameplayHud>();
            hud.Build(book);
            return hud;
        }

        void Build(BookController book)
        {
            if (_root != null || book.open == null) return;
            _root = transform.Find("LeftHUD") as RectTransform;
            if (_root == null) return;
            // Retain LeftHUD's name and children: notebook hiding and CheeseHud use them.
            var layout = _root.GetComponent<LayoutGroup>();
            if (layout != null) layout.enabled = false;
            _root.anchorMin = _root.anchorMax = Vector2.one;
            _root.pivot = Vector2.one;
            _root.localScale = Vector3.one;
            _root.sizeDelta = new Vector2(272f, 144f);
            _group = _root.GetComponent<CanvasGroup>();
            if (_group == null) _group = _root.gameObject.AddComponent<CanvasGroup>();

            var button = book.open;
            Place(button.transform as RectTransform, new Vector2(1f, 1f),
                new Vector2(1f, 1f), Vector2.zero, new Vector2(128f, 144f));
            var background = button.GetComponent<Image>();
            if (background == null) background = button.gameObject.AddComponent<Image>();
            HudPaperStyle.Apply(background);
            background.raycastTarget = true;
            button.targetGraphic = background;
            button.navigation = new Navigation { mode = Navigation.Mode.None };
            var colors = button.colors;
            colors.normalColor = Color.white;
            colors.highlightedColor = new Color(1f, 0.97f, 0.90f);
            colors.pressedColor = new Color(0.90f, 0.85f, 0.75f);
            button.colors = colors;

            var icon = button.transform.Find("NoteImage") as RectTransform;
            if (icon != null)
                Place(icon, Vector2.one * 0.5f, Vector2.one * 0.5f,
                    new Vector2(0f, 17f), new Vector2(88f, 92f));
            var key = Panel(button.transform, "ShortcutKey", HudPaperStyle.KeyPaper);
            HudPaperStyle.Apply(key.GetComponent<Image>(), true);
            Place(key, Vector2.one * 0.5f, Vector2.one * 0.5f,
                new Vector2(-41f, -51f), new Vector2(22f, 24f));
            var keyLabel = Label(key, "Key", 17f, HudPaperStyle.Ink);
            Stretch(keyLabel.rectTransform);
            keyLabel.text = "N";
            _title = Label(button.transform, "NotebookLabel", 18f, HudPaperStyle.Ink);
            Place(_title.rectTransform, Vector2.one * 0.5f, Vector2.one * 0.5f,
                new Vector2(16f, -51f), new Vector2(84f, 26f));
            if (book.openRedDot != null)
            {
                Place(book.openRedDot.transform as RectTransform, Vector2.one, Vector2.one * 0.5f,
                    new Vector2(-12f, -12f), new Vector2(16f, 16f));
                book.openRedDot.transform.SetAsLastSibling();
            }

            var cheese = _root.Find("Cheese") as RectTransform;
            if (cheese != null)
            {
                Place(cheese, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    Vector2.zero, new Vector2(128f, 144f));
                var cheeseImage = cheese.GetComponent<Image>();
                if (cheeseImage != null)
                {
                    var art = Panel(cheese, "CheeseIcon", Color.white);
                    art.GetComponent<Image>().sprite = cheeseImage.sprite;
                    art.GetComponent<Image>().preserveAspect = true;
                    Place(art, Vector2.one * 0.5f, Vector2.one * 0.5f,
                        new Vector2(0f, 17f), new Vector2(88f, 92f));
                    HudPaperStyle.Apply(cheeseImage);
                    cheeseImage.raycastTarget = false;
                }
                var count = CheeseHud.FindCountText(cheese);
                _cheeseTitle = Label(cheese, "CheeseLabel", 18f, HudPaperStyle.Ink);
                Place(_cheeseTitle.rectTransform, Vector2.one * 0.5f, Vector2.one * 0.5f,
                    new Vector2(0f, -51f), new Vector2(104f, 26f));
                if (count != null)
                {
                    var badge = Panel(cheese, "CountBadge", HudPaperStyle.KeyPaper);
                    HudPaperStyle.Apply(badge.GetComponent<Image>(), true);
                    Place(badge, Vector2.one, Vector2.one,
                        new Vector2(-8f, -8f), new Vector2(44f, 24f));
                    // Keep the count under Cheese: CheeseHud uses its parent as the visibility root.
                    Place(count.rectTransform, Vector2.one, Vector2.one,
                        new Vector2(-8f, -8f), new Vector2(44f, 24f));
                    count.fontSize = 16;
                    count.resizeTextForBestFit = true;
                    count.resizeTextMinSize = 12;
                    count.resizeTextMaxSize = 16;
                    count.alignment = TextAnchor.MiddleCenter;
                    count.color = HudPaperStyle.Ink;
                    count.raycastTarget = false;
                    count.transform.SetAsLastSibling();
                }
            }

            RefreshLabels();
            FitSafeArea();
        }

        void OnEnable() { GameLocale.Changed += RefreshLabels; }
        void OnDisable() { GameLocale.Changed -= RefreshLabels; }

        void LateUpdate()
        {
            if (_root == null) return;
            var visible = !GameEvents.InputLocked;
            _group.alpha = visible ? 1f : 0f;
            _group.interactable = visible;
            _group.blocksRaycasts = visible;
            var parent = _root.parent as RectTransform;
            if (Screen.safeArea != _safeArea || (parent != null && parent.rect.size != _parentSize))
                FitSafeArea();
        }

        void RefreshLabels()
        {
            if (_title != null) _title.text = GameLocale.IsEnglish ? "Notebook" : "笔记本";
            if (_cheeseTitle != null) _cheeseTitle.text = GameLocale.IsEnglish ? "Cheese" : "奶酪";
        }

        void FitSafeArea()
        {
            var parent = _root.parent as RectTransform;
            if (parent == null) return;
            _safeArea = Screen.safeArea;
            _parentSize = parent.rect.size;
            var canvas = _root.GetComponentInParent<Canvas>();
            var camera = canvas != null && canvas.renderMode != RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : null;
            Vector2 corner;
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(parent, _safeArea.max, camera, out corner))
                _root.anchoredPosition = corner - parent.rect.max - new Vector2(32f, 32f);
        }

        static RectTransform Panel(Transform parent, string name, Color color)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            var image = go.GetComponent<Image>();
            image.color = color;
            image.raycastTarget = false;
            return (RectTransform)go.transform;
        }

        static TMP_Text Label(Transform parent, string name, float size, Color color)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(TextMeshProUGUI));
            go.transform.SetParent(parent, false);
            var text = go.GetComponent<TextMeshProUGUI>();
            var font = UiFontCatalog.Load();
            if (font != null) text.font = font;
            text.fontSize = size;
            text.alignment = TextAlignmentOptions.Center;
            text.color = color;
            text.enableWordWrapping = false;
            text.raycastTarget = false;
            return text;
        }

        static void Place(RectTransform rect, Vector2 anchor, Vector2 pivot, Vector2 position, Vector2 size)
        {
            if (rect == null) return;
            rect.anchorMin = rect.anchorMax = anchor;
            rect.pivot = pivot;
            rect.anchoredPosition = position;
            rect.sizeDelta = size;
            rect.localScale = Vector3.one;
        }

        static void Stretch(RectTransform rect)
        {
            rect.anchorMin = Vector2.zero;
            rect.anchorMax = Vector2.one;
            rect.offsetMin = rect.offsetMax = Vector2.zero;
        }
    }
}
