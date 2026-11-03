using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 程序化建 UI 的工厂。七个模板全部用代码构建，不落地预制体——
    /// 这样换模板不需要美术先出图，也不会在场景里留一堆绑定（§15.1）。
    /// </summary>
    public static class MiniGameUIKit
    {
        // ---------------- 画布 ----------------

        /// <summary>
        /// 建一个独立的全屏 Overlay 画布。与 3D 场景的光照 / 雾 / 后处理完全隔离（§19 风险 6）。
        /// </summary>
        public static Canvas CreateCanvas(string name, int sortingOrder = MiniGameTheme.CanvasSortingOrder)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(Canvas),
                typeof(CanvasScaler), typeof(GraphicRaycaster));
            var canvas = go.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = sortingOrder;
            var scaler = go.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            // 用 Expand 而不是 MatchWidthOrHeight 0.5（§4.1 写的是 0.5）：
            // 设计稿的六个区域是 1920×1080 的绝对美术坐标，顶栏贴 0、底栏贴 1058。
            // 窗口一旦比 16:9 更宽（超宽 Game 视图很常见），0.5 会让画布高度不足 1080，
            // 顶栏和底栏各被裁掉一截。Expand 取宽高缩放的较小值，保证整块 UI 永远完整；
            // 16:9 下它与 0.5 完全等价，只是超宽时会多出左右留白。
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.Expand;
            scaler.referenceResolution = new Vector2(MiniGameTheme.RefWidth, MiniGameTheme.RefHeight);
            return canvas;
        }

        // ---------------- 基础件 ----------------

        public static RectTransform Node(Transform parent, string name)
        {
            var go = new GameObject(name, typeof(RectTransform));
            go.transform.SetParent(parent, false);
            return (RectTransform)go.transform;
        }

        /// <summary>纯色 / 圆角面板。radius &lt;= 0 时不套九宫格圆角。</summary>
        public static RectTransform Panel(Transform parent, string name, Color color,
            float radius = MiniGameTheme.PanelRadius, bool raycast = false)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            var image = go.GetComponent<Image>();
            image.color = color;
            image.raycastTarget = raycast;
            if (radius > 0f) HudPaperStyle.ApplyShape(image, radius);
            return (RectTransform)go.transform;
        }

        public static TMP_Text Label(Transform parent, string name, float size, Color color,
            TextAlignmentOptions align = TextAlignmentOptions.Center)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(TextMeshProUGUI));
            go.transform.SetParent(parent, false);
            var text = go.GetComponent<TextMeshProUGUI>();
            var font = MiniGameTheme.Font;
            if (font != null) text.font = font;
            text.fontSize = size;
            text.alignment = align;
            text.color = color;
            text.enableWordWrapping = false;
            text.raycastTarget = false;
            return text;
        }

        /// <summary>可换行正文（重听浮层、提示文案用）。</summary>
        public static TMP_Text Paragraph(Transform parent, string name, float size, Color color,
            TextAlignmentOptions align = TextAlignmentOptions.TopLeft)
        {
            var text = Label(parent, name, size, color, align);
            text.enableWordWrapping = true;
            text.overflowMode = TextOverflowModes.Overflow;
            return text;
        }

        public static Button Btn(Transform parent, string name, string caption, Color fill, Color ink,
            float fontSize = 22f, float radius = MiniGameTheme.ButtonRadius)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer),
                typeof(Image), typeof(Button));
            go.transform.SetParent(parent, false);
            var image = go.GetComponent<Image>();
            image.color = fill;
            HudPaperStyle.ApplyShape(image, radius);
            image.raycastTarget = true;

            var button = go.GetComponent<Button>();
            button.targetGraphic = image;
            button.navigation = new Navigation { mode = Navigation.Mode.None };
            var colors = button.colors;
            colors.normalColor = Color.white;
            colors.highlightedColor = new Color(1f, 0.97f, 0.90f);
            colors.pressedColor = new Color(0.90f, 0.85f, 0.75f);
            colors.disabledColor = new Color(1f, 1f, 1f, 0.4f);
            button.colors = colors;

            if (!string.IsNullOrEmpty(caption))
            {
                var label = Label(go.transform, "Caption", fontSize, ink);
                Stretch(label.rectTransform);
                label.text = caption;
            }
            return button;
        }

        // ---------------- 布局 ----------------

        /// <summary>
        /// 把「美术坐标」（原点左上、y 向下）落到画面上。
        /// 换算见附录 B：anchoredPosition = (X左 − 960, 540 − Y上) —— 这个式子算的是
        /// **相对画面中心**的偏移，所以锚点必须是中心 (0.5, 0.5)。
        ///
        /// 曾经把锚点写成左上 (0,1)、却仍套这条中心式，等于每个元素又被多推了半个参考屏
        /// （左 960 / 上 540），整块 UI 会挤到屏幕左上角并且大半跑到画面外。
        /// 锚点用中心还有个好处：不管 CanvasScaler 实际把画布算成多少单位，
        /// 中心永远对齐屏幕中心，只有「离中心多远」受缩放影响。
        /// </summary>
        public static void PlaceArt(RectTransform rect, Rect art)
        {
            if (rect == null) return;
            rect.anchorMin = rect.anchorMax = new Vector2(0.5f, 0.5f);
            rect.pivot = new Vector2(0f, 1f);
            rect.anchoredPosition = new Vector2(art.x - MiniGameTheme.RefWidth * 0.5f,
                MiniGameTheme.RefHeight * 0.5f - art.y);
            rect.sizeDelta = new Vector2(art.width, art.height);
            rect.localScale = Vector3.one;
        }

        public static void Place(RectTransform rect, Vector2 anchor, Vector2 pivot,
            Vector2 position, Vector2 size)
        {
            if (rect == null) return;
            rect.anchorMin = rect.anchorMax = anchor;
            rect.pivot = pivot;
            rect.anchoredPosition = position;
            rect.sizeDelta = size;
            rect.localScale = Vector3.one;
        }

        public static void Stretch(RectTransform rect)
        {
            if (rect == null) return;
            rect.anchorMin = Vector2.zero;
            rect.anchorMax = Vector2.one;
            rect.offsetMin = rect.offsetMax = Vector2.zero;
        }

        // ---------------- 小工具 ----------------

        /// <summary>整块矩形遮罩用的全屏压暗层。</summary>
        public static RectTransform Scrim(Transform parent, string name = "Scrim")
        {
            var rt = Panel(parent, name, MiniGameTheme.Scrim, 0f, true);
            Stretch(rt);
            return rt;
        }

        /// <summary>按屏幕坐标算指针在本矩形内的局部点；不在矩形内返回 false。</summary>
        public static bool TryGetLocalPoint(RectTransform area, Vector2 screenPoint, out Vector2 local)
        {
            local = Vector2.zero;
            if (area == null) return false;
            var cam = GetCanvasCamera(area);
            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(area, screenPoint, cam, out local))
                return false;
            var r = area.rect;
            return r.Contains(local);
        }

        public static Camera GetCanvasCamera(RectTransform rect)
        {
            var canvas = rect != null ? rect.GetComponentInParent<Canvas>() : null;
            if (canvas == null || canvas.renderMode == RenderMode.ScreenSpaceOverlay) return null;
            return canvas.worldCamera;
        }

        /// <summary>
        /// 只做坐标换算，不要求点落在矩形内。
        /// T4 的拼图块住在右栏、要拖进主区，起手那一帧指针还在栏里，
        /// 需要把「栏里的点」也换成一个可比较的局部坐标。
        /// </summary>
        public static bool ScreenToLocal(RectTransform area, Vector2 screenPoint, out Vector2 local)
        {
            local = Vector2.zero;
            if (area == null) return false;
            return RectTransformUtility.ScreenPointToLocalPointInRectangle(
                area, screenPoint, GetCanvasCamera(area), out local);
        }

        /// <summary>把某个世界 / 屏幕位置换算到目标矩形内的局部坐标，用于入册演出的落点。</summary>
        public static Vector2 WorldToLocal(RectTransform area, Vector3 worldPosition)
        {
            if (area == null) return Vector2.zero;
            var cam = GetCanvasCamera(area);
            var canvas = area.GetComponentInParent<Canvas>();
            var screen = RectTransformUtility.WorldToScreenPoint(canvas != null && canvas.renderMode != RenderMode.ScreenSpaceOverlay ? canvas.worldCamera : null, worldPosition);
            Vector2 local;
            RectTransformUtility.ScreenPointToLocalPointInRectangle(area, screen, cam, out local);
            return local;
        }
    }
}
