using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 全局压暗 + 模糊底。进局和出局共用这一层，避免两套转场打架。
    ///
    /// 模糊的做法：**抓一帧降采样再放大**。进局时时间缩放已经归零，场景是静止的，
    /// 抓下来的那一帧不会过时，所以不需要每帧重抓，也不需要在主相机上挂 URP 的后处理 DOF
    /// （那会把模糊永久留在游戏世界里，退出后还得记得撤）。
    /// 两级降采样交叉淡入，读起来就是「模糊逐渐加大」。
    ///
    /// 层级：**自己开一张画布，排序值取负**，于是它压在 3D 场景之上、压在全部 UI 之下
    /// （HUD / 笔记本 / 暂停菜单 / 小游戏自身都在 0 以上）。做这件事之前它是小游戏画布的第一个子节点，
    /// 排序值是 400，结果连笔记本都被压在黑底下面——那显然不是想要的效果。
    ///
    /// 拍帧时要**把所有别的画布都关掉**：不关的话 HUD 和笔记本会被一起拍进模糊里，
    /// 后面淡入时就能看到一层糊掉的笔记本残影。
    /// </summary>
    public sealed class MiniGameBackdrop : MonoBehaviour
    {
        const int SoftDivisor = 6;
        const int StrongDivisor = 18;

        Canvas _canvas;
        CanvasGroup _group;
        RawImage _soft;
        RawImage _strong;
        Image _vignette;
        RenderTexture _rtSoft;
        RenderTexture _rtStrong;
        static Sprite _vignetteSprite;

        readonly List<Canvas> _hidden = new List<Canvas>();

        public float Alpha { get { return _group != null ? _group.alpha : 0f; } }

        /// <summary>
        /// 建一层黑底。**不挂在任何画布下面**——挂进去就变成子画布，排序值会被父画布吃掉。
        /// </summary>
        public static MiniGameBackdrop Create()
        {
            var go = new GameObject("MiniGameBackdrop",
                typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler));
            var canvas = go.GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.sortingOrder = MiniGameTheme.BackdropSortingOrder;

            var scaler = go.GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.Expand;
            scaler.referenceResolution = new Vector2(MiniGameTheme.RefWidth, MiniGameTheme.RefHeight);

            var rect = (RectTransform)go.transform;
            rect.anchorMin = Vector2.zero;
            rect.anchorMax = Vector2.one;
            rect.offsetMin = rect.offsetMax = Vector2.zero;

            var backdrop = go.AddComponent<MiniGameBackdrop>();
            backdrop._canvas = canvas;
            backdrop.Build();
            return backdrop;
        }

        void Build()
        {
            _group = gameObject.AddComponent<CanvasGroup>();
            _group.alpha = 0f;
            _group.blocksRaycasts = false;
            _group.interactable = false;

            // 两张都用**白色**着色：RawImage.color 是乘算，之前给了 (0.04,0.06,0.08)
            // 等于把抓来的画面乘到 4% 亮度，看着就是一整块实心黑。亮度交给 Dim 那一层管。
            _soft = MakeRaw("BlurSoft", Color.white);
            _strong = MakeRaw("BlurStrong", new Color(1f, 1f, 1f, 0f));

            // 平铺压暗：只留 20%，够把场景和 UI 拉开层次，又不至于看不见场景
            var dim = new GameObject("Dim", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            dim.transform.SetParent(transform, false);
            MiniGameUIKit.Stretch((RectTransform)dim.transform);
            var dimImage = dim.GetComponent<Image>();
            dimImage.color = new Color(0.06f, 0.08f, 0.10f, 0.20f);
            dimImage.raycastTarget = false;

            // 四周渐深：中间透一点，边缘压下去，视线自然收到中间
            var vig = new GameObject("Vignette", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            vig.transform.SetParent(transform, false);
            MiniGameUIKit.Stretch((RectTransform)vig.transform);
            _vignette = vig.GetComponent<Image>();
            _vignette.sprite = VignetteSprite();
            _vignette.type = Image.Type.Simple;
            _vignette.color = new Color(0f, 0f, 0f, 0.40f);
            _vignette.raycastTarget = false;
        }

        RawImage MakeRaw(string name, Color color)
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(RawImage));
            go.transform.SetParent(transform, false);
            var rect = (RectTransform)go.transform;
            MiniGameUIKit.Stretch(rect);
            var raw = go.GetComponent<RawImage>();
            raw.color = color;
            raw.raycastTarget = false;
            return raw;
        }

        /// <summary>进局：先拍一帧，再淡入并把模糊推上去。</summary>
        public void Begin(MonoBehaviour host, float duration = 0.45f)
        {
            if (host == null) { _group.alpha = 1f; return; }
            host.StartCoroutine(BeginRoutine(duration));
        }

        IEnumerator BeginRoutine(float duration)
        {
            // 拍帧期间把所有别的画布关掉：只要留下别人的 UI，就会被一起拍进模糊里
            HideOtherCanvases();
            yield return new WaitForEndOfFrame();
            Capture();
            ShowOtherCanvases();

            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / duration);
                _group.alpha = k;

                // 弱模糊先上、强模糊后上 —— 视觉上就是「越来越模糊」
                var strongK = Mathf.Clamp01((k - 0.25f) / 0.75f);
                if (_strong != null) _strong.color = new Color(1f, 1f, 1f, strongK);
                yield return null;
            }
            _group.alpha = 1f;
            if (_strong != null) _strong.color = Color.white;
        }

        void HideOtherCanvases()
        {
            _hidden.Clear();
            var all = Object.FindObjectsOfType<Canvas>();
            for (var i = 0; i < all.Length; i++)
            {
                var c = all[i];
                if (c == null || c == _canvas || !c.enabled) continue;
                c.enabled = false;
                _hidden.Add(c);
            }
        }

        void ShowOtherCanvases()
        {
            for (var i = 0; i < _hidden.Count; i++)
                if (_hidden[i] != null) _hidden[i].enabled = true;
            _hidden.Clear();
        }

        void Capture()
        {
            if (Screen.width <= 0 || Screen.height <= 0) return;
            try
            {
                var sw = Mathf.Max(8, Screen.width / SoftDivisor);
                var sh = Mathf.Max(8, Screen.height / SoftDivisor);
                _rtSoft = new RenderTexture(sw, sh, 0, RenderTextureFormat.ARGB32)
                {
                    filterMode = FilterMode.Bilinear,
                    name = "MiniGameBackdropSoft",
                };
                _rtSoft.Create();
                ScreenCapture.CaptureScreenshotIntoRenderTexture(_rtSoft);

                var tw = Mathf.Max(4, Screen.width / StrongDivisor);
                var th = Mathf.Max(4, Screen.height / StrongDivisor);
                _rtStrong = new RenderTexture(tw, th, 0, RenderTextureFormat.ARGB32)
                {
                    filterMode = FilterMode.Bilinear,
                    name = "MiniGameBackdropStrong",
                };
                _rtStrong.Create();
                Graphics.Blit(_rtSoft, _rtStrong);

                if (_soft != null) _soft.texture = _rtSoft;
                if (_strong != null) _strong.texture = _rtStrong;
            }
            catch (System.Exception e)
            {
                // 抓不到就退化成纯压暗：不影响进局，只是没有模糊
                Debug.LogWarning("[MiniGame] backdrop capture failed, fallback to plain dim: " + e.Message);
                if (_soft != null) _soft.gameObject.SetActive(false);
                if (_strong != null) _strong.gameObject.SetActive(false);
            }
        }

        /// <summary>出局：同一层反过来淡出，跟入册演出共用一套黑底。</summary>
        public IEnumerator FadeOut(float duration)
        {
            var from = _group != null ? _group.alpha : 1f;
            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                if (_group != null) _group.alpha = Mathf.Lerp(from, 0f, Mathf.Clamp01(t / duration));
                yield return null;
            }
            if (_group != null) _group.alpha = 0f;
        }

        /// <summary>径向渐变贴图：中心透明、边缘黑。运行时生成一次，全局共用。</summary>
        static Sprite VignetteSprite()
        {
            if (_vignetteSprite != null) return _vignetteSprite;

            const int size = 64;
            var tex = new Texture2D(size, size, TextureFormat.RGBA32, false)
            {
                name = "MiniGameVignette",
                wrapMode = TextureWrapMode.Clamp,
                filterMode = FilterMode.Bilinear,
                hideFlags = HideFlags.HideAndDontSave,
            };
            var pixels = new Color32[size * size];
            var center = new Vector2((size - 1) * 0.5f, (size - 1) * 0.5f);
            var maxDist = center.magnitude;
            for (var y = 0; y < size; y++)
            {
                for (var x = 0; x < size; x++)
                {
                    var d = Vector2.Distance(new Vector2(x, y), center) / maxDist;
                    var a = Mathf.Clamp01(Mathf.Pow(d, 2.2f));
                    pixels[y * size + x] = new Color32(255, 255, 255, (byte)(a * 255f));
                }
            }
            tex.SetPixels32(pixels);
            tex.Apply(false);
            _vignetteSprite = Sprite.Create(tex, new Rect(0, 0, size, size), new Vector2(0.5f, 0.5f), 100f);
            return _vignetteSprite;
        }

        void OnDestroy()
        {
            ShowOtherCanvases();
            if (_rtSoft != null) { _rtSoft.Release(); Destroy(_rtSoft); }
            if (_rtStrong != null) { _rtStrong.Release(); Destroy(_rtStrong); }
        }
    }
}
