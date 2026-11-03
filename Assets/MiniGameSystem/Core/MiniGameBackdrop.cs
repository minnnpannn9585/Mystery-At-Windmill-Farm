using System.Collections;
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
    /// </summary>
    public sealed class MiniGameBackdrop : MonoBehaviour
    {
        const int SoftDivisor = 6;
        const int StrongDivisor = 18;

        CanvasGroup _group;
        RawImage _soft;
        RawImage _strong;
        Image _vignette;
        RenderTexture _rtSoft;
        RenderTexture _rtStrong;
        static Sprite _vignetteSprite;

        public float Alpha { get { return _group != null ? _group.alpha : 0f; } }

        public static MiniGameBackdrop Create(RectTransform parent)
        {
            var go = new GameObject("Backdrop", typeof(RectTransform));
            var rect = (RectTransform)go.transform;
            rect.SetParent(parent, false);
            MiniGameUIKit.Stretch(rect);

            var backdrop = go.AddComponent<MiniGameBackdrop>();
            backdrop.Build();
            rect.SetAsFirstSibling();     // 永远在所有面板下面
            return backdrop;
        }

        void Build()
        {
            _group = gameObject.AddComponent<CanvasGroup>();
            _group.alpha = 0f;
            _group.blocksRaycasts = false;
            _group.interactable = false;

            _soft = MakeRaw("BlurSoft", new Color(0.04f, 0.06f, 0.08f, 0.75f));
            _strong = MakeRaw("BlurStrong", new Color(0.03f, 0.05f, 0.07f, 0f));

            // 平铺压暗：模糊底之外再压一层，保证文字在亮画面上也看得清
            var dim = new GameObject("Dim", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            dim.transform.SetParent(transform, false);
            MiniGameUIKit.Stretch((RectTransform)dim.transform);
            var dimImage = dim.GetComponent<Image>();
            dimImage.color = new Color(0.06f, 0.08f, 0.10f, 0.42f);
            dimImage.raycastTarget = false;

            // 四周渐深：中间透一点，边缘压下去，视线自然收到中间
            var vig = new GameObject("Vignette", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            vig.transform.SetParent(transform, false);
            MiniGameUIKit.Stretch((RectTransform)vig.transform);
            _vignette = vig.GetComponent<Image>();
            _vignette.sprite = VignetteSprite();
            _vignette.type = Image.Type.Simple;
            _vignette.color = new Color(0f, 0f, 0f, 0.55f);
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

        /// <summary>进局：先拍一帧，再淡入并把模糊推上去。需要关掉小游戏画布拍，否则拍到自己。</summary>
        public void Begin(MonoBehaviour host, Canvas canvas, float duration = 0.45f)
        {
            if (host == null) { _group.alpha = 1f; return; }
            host.StartCoroutine(BeginRoutine(host, canvas, duration));
        }

        IEnumerator BeginRoutine(MonoBehaviour host, Canvas canvas, float duration)
        {
            var canvasWasOn = canvas != null && canvas.enabled;
            if (canvas != null) canvas.enabled = false;
            yield return new WaitForEndOfFrame();
            Capture();
            if (canvas != null) canvas.enabled = canvasWasOn;

            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / duration);
                _group.alpha = k;

                // 弱模糊先上、强模糊后上 —— 视觉上就是「越来越模糊」
                var strongK = Mathf.Clamp01((k - 0.25f) / 0.75f);
                if (_strong != null) _strong.color = new Color(0.03f, 0.05f, 0.07f, strongK);
                yield return null;
            }
            _group.alpha = 1f;
            if (_strong != null) _strong.color = new Color(0.03f, 0.05f, 0.07f, 1f);
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
            if (_rtSoft != null) { _rtSoft.Release(); Destroy(_rtSoft); }
            if (_rtStrong != null) { _rtStrong.Release(); Destroy(_rtStrong); }
        }
    }
}
