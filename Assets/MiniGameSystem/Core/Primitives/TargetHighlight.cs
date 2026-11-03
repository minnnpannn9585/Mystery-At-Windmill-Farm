using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 目标高亮。§18.2.3 的第三个原语，七个模板的二级提示全用它，只是形状与颜色不同：
    /// 椭圆描边（T3）/ 矩形描边（T1、T4）/ 整段高亮（T5）/ 整撮高亮（T6）/ 卡 + 槽（T7）。
    /// T4 的错位格红闪也是它（评审 J 条）。
    ///
    /// 描边用九宫格圆角矩形近似——正式素材在 M4 换（§18.3 遗留项 4）。
    /// </summary>
    public sealed class TargetHighlight : MonoBehaviour
    {
        Image _ring;
        RectTransform _ringRect;
        Color _color = MiniGameTheme.Yellow;
        float _elapsed;
        float _life;
        int _flashes;
        int _flashesLeft;
        bool _playing;
        bool _pulse = true;

        public static TargetHighlight Create(Transform parent, string name = "Highlight")
        {
            var go = new GameObject(name, typeof(RectTransform), typeof(CanvasRenderer), typeof(Image));
            go.transform.SetParent(parent, false);
            var image = go.GetComponent<Image>();
            image.raycastTarget = false;
            image.type = Image.Type.Sliced;
            HudPaperStyle.ApplyShape(image, 24f);
            var highlight = go.AddComponent<TargetHighlight>();
            highlight._ring = image;
            highlight._ringRect = (RectTransform)go.transform;
            go.SetActive(false);
            return highlight;
        }

        /// <summary>常驻脉冲高亮，套在目标上。margin 为外扩像素。</summary>
        public void Show(RectTransform target, Color color, float duration = 0f, float margin = 6f,
            bool pulse = true)
        {
            if (target == null) return;
            _color = color;
            _pulse = pulse;
            _flashes = 0;
            _flashesLeft = 0;
            _elapsed = 0f;
            _life = duration;
            _playing = true;
            Attach(target, margin);
            gameObject.SetActive(true);
            ApplyAlpha(1f);
        }

        /// <summary>闪烁 N 次后停在描边态（T4 错位格：红闪 2 次）。</summary>
        public void Flash(RectTransform target, Color color, int times, float period = 0.24f, float margin = 6f)
        {
            if (target == null) return;
            _color = color;
            _pulse = false;
            _flashes = Mathf.Max(1, times);
            _flashesLeft = _flashes * 2;   // 一亮一灭算一次
            _elapsed = 0f;
            _life = period * _flashesLeft;
            _playing = true;
            _ringRect = (RectTransform)transform;
            Attach(target, margin);
            gameObject.SetActive(true);
            ApplyAlpha(1f);
        }

        public void Hide()
        {
            _playing = false;
            if (this != null) gameObject.SetActive(false);
        }

        void Attach(RectTransform target, float margin)
        {
            _ringRect.SetParent(target, false);
            _ringRect.anchorMin = Vector2.zero;
            _ringRect.anchorMax = Vector2.one;
            _ringRect.pivot = new Vector2(0.5f, 0.5f);
            _ringRect.offsetMin = new Vector2(-margin, -margin);
            _ringRect.offsetMax = new Vector2(margin, margin);
            _ringRect.localScale = Vector3.one;
            _ringRect.SetAsLastSibling();
        }

        void Update()
        {
            if (!_playing) return;
            _elapsed += Time.unscaledDeltaTime;

            if (_flashes > 0)
            {
                var period = _life / Mathf.Max(1, _flashesLeft);
                var phase = Mathf.Repeat(_elapsed, period);
                ApplyAlpha(phase < period * 0.5f ? 1f : 0f);
                if (_elapsed >= _life)
                {
                    // 闪完停在描边态，让玩家回头还能找到它
                    _flashes = 0;
                    _playing = false;
                    ApplyAlpha(1f);
                }
                return;
            }

            if (_pulse)
            {
                var k = 0.5f + 0.5f * Mathf.Sin(_elapsed / Mathf.Max(0.01f, MiniGameMotion.HighlightPeriod)
                    * Mathf.PI * 2f);
                ApplyAlpha(Mathf.Lerp(MiniGameMotion.HighlightAlphaMin, 1f, k));
            }
            else
            {
                ApplyAlpha(1f);
            }

            if (_life > 0f && _elapsed >= _life) Hide();
        }

        void ApplyAlpha(float a)
        {
            if (_ring == null) return;
            var c = _color;
            c.a = _color.a * a;
            _ring.color = c;
        }
    }
}
