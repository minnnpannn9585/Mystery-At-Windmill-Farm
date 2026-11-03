using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T5 痕迹拓印（§10）。只有 Q17 一局，但它是唯一「判定面积、不判定笔画」的模板。
    ///
    /// 三个决定都照文档来，不做「更好」的改动：
    /// ① 判定是**覆盖率 ≥ 80%**，玩家怎么涂、涂几笔、来回多少次都不管（§10.2）；
    /// ② 分母只算该段的揭露区，不算整张纸，否则三段共用纸面会永远到不了 80%；
    /// ③ 遮罩覆盖处**即时转深蓝**，不是「完成才整段亮」——每一笔都要有回报，这正是敢定 80% 的原因（§10.3）。
    ///
    /// 遮罩存成 PNG 塞进存档（MaskBase64），所以退出重进时笔触位置、粗细、走向与退出前完全一致（§10.7）。
    /// </summary>
    public sealed class RubbingBoard : MiniGameBoard
    {
        const int MaskSize = 128;
        const float BrushRadius = 28f;      // 1920 设计空间（§10.3）
        const float Threshold = 0.80f;
        const float SampleInterval = 0.1f;  // 覆盖率 0.1s 采样一次

        sealed class SegmentView
        {
            public MiniGameSegment Spec;
            public Rect Rect;           // Body 局部坐标
            public RawImage Reveal;
            public RectTransform Rail;
            public bool Done;
        }

        readonly List<SegmentView> _segments = new List<SegmentView>();
        Texture2D _tex;
        Color32[] _pixels;
        bool[] _painted;
        int[] _count;

        RectTransform _chalk;
        Vector2 _lastPaint;
        bool _hasLastPaint;
        float _sampleTimer;

        protected override string FooterText { get { return "炭条 ｜ 按住拖动 · 覆盖痕迹"; } }

        protected override void BuildBoard()
        {
            var n = Mathf.Max(1, Content.Segments.Length);
            _tex = new Texture2D(MaskSize, MaskSize * n, TextureFormat.RGBA32, false)
            {
                filterMode = FilterMode.Bilinear,
                wrapMode = TextureWrapMode.Clamp,
                name = "RubbingMask",
            };
            _pixels = new Color32[MaskSize * MaskSize * n];
            _painted = new bool[MaskSize * MaskSize * n];
            _count = new int[n];
            for (var i = 0; i < _pixels.Length; i++) _pixels[i] = new Color32(0, 0, 0, 0);
            _tex.SetPixels32(_pixels);
            _tex.Apply(false);

            for (var i = 0; i < Content.Segments.Length; i++)
            {
                var spec = Content.Segments[i];
                var rect = new Rect(spec.Pos.x, -spec.Pos.y - spec.Size.y, spec.Size.x, spec.Size.y);

                // 底痕：浅灰常驻，让玩家看得出「这里本来有痕迹」
                var baseLayer = MiniGameUIKit.Panel(Body, "Trace_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Grey, 0.22f), 10f);
                MiniGameUIKit.Place(baseLayer, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), spec.Size);

                var grain = MiniGameUIKit.Label(baseLayer, "Grain", 22f,
                    MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.30f));
                MiniGameUIKit.Stretch(grain.rectTransform);
                grain.text = "— 抓痕 · " + spec.Label + " —";

                // 显影层：RawImage + 该段自己的遮罩带
                var go = new GameObject("Reveal_" + spec.Id, typeof(RectTransform), typeof(CanvasRenderer), typeof(RawImage));
                go.transform.SetParent(Body, false);
                var reveal = (RectTransform)go.transform;
                MiniGameUIKit.Place(reveal, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), spec.Size);

                var raw = go.GetComponent<RawImage>();
                raw.texture = _tex;
                raw.raycastTarget = false;
                raw.uvRect = new Rect(0f, (float)i / n, 1f, 1f / n);

                _segments.Add(new SegmentView
                {
                    Spec = spec,
                    Rect = rect,
                    Reveal = raw,
                    Rail = AddRailSlot(spec.Label, i),
                });
            }

            // 炭条光标：进主区就跟手，按下才出墨（§10.3 / §10.5）
            // 光标挂在 Body 下、锚点用左上：位置读的是 Body 局部坐标，挂 Root 下会差一个 Body 偏移
            _chalk = MiniGameUIKit.Panel(Body, "Chalk", MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.35f), 60f);
            MiniGameUIKit.Place(_chalk, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                Vector2.zero, new Vector2(BrushRadius * 2f, BrushRadius * 2f));
            _chalk.gameObject.SetActive(false);

            Judge.Total = Mathf.Max(1, _segments.Count);
        }

        // ---------------- 涂 ----------------

        protected override void TickBoard(float dt)
        {
            Vector2 local;
            var inside = MiniGameUIKit.TryGetLocalPoint(Body, Input.mousePosition, out local);

            PositionChalk(inside, local);

            if (inside && Input.GetMouseButton(0))
            {
                if (_hasLastPaint) Stamp(_lastPaint, local);
                else Stamp(local, local);
                _lastPaint = local;
                _hasLastPaint = true;
                Flush();
            }
            else
            {
                _hasLastPaint = false;
            }

            _sampleTimer += dt;
            if (_sampleTimer < SampleInterval) return;
            _sampleTimer = 0f;
            SampleCoverage();
        }

        void PositionChalk(bool inside, Vector2 local)
        {
            if (_chalk == null) return;
            _chalk.gameObject.SetActive(inside);
            if (inside) _chalk.anchoredPosition = local;
        }

        /// <summary>胶囊形笔刷：连接上一帧与这一帧，避免快速拖动留下断续圆点（§10.3）。</summary>
        void Stamp(Vector2 from, Vector2 to)
        {
            for (var i = 0; i < _segments.Count; i++)
            {
                var seg = _segments[i];
                if (!seg.Rect.Overlaps(new Rect(
                        Mathf.Min(from.x, to.x) - BrushRadius, Mathf.Min(from.y, to.y) - BrushRadius,
                        Mathf.Abs(to.x - from.x) + BrushRadius * 2f, Mathf.Abs(to.y - from.y) + BrushRadius * 2f)))
                    continue;

                PaintSegment(i, seg, from, to);
            }
        }

        void PaintSegment(int index, SegmentView seg, Vector2 from, Vector2 to)
        {
            var band = index * MaskSize * MaskSize;

            // 把这条线段转到该段的遮罩像素坐标
            var px0 = ToMask(seg, from);
            var px1 = ToMask(seg, to);
            var radiusPx = BrushRadius / seg.Rect.width * MaskSize;

            var minX = Mathf.Max(0, Mathf.FloorToInt(Mathf.Min(px0.x, px1.x) - radiusPx));
            var maxX = Mathf.Min(MaskSize - 1, Mathf.CeilToInt(Mathf.Max(px0.x, px1.x) + radiusPx));
            var minY = Mathf.Max(0, Mathf.FloorToInt(Mathf.Min(px0.y, px1.y) - radiusPx));
            var maxY = Mathf.Min(MaskSize - 1, Mathf.CeilToInt(Mathf.Max(px0.y, px1.y) + radiusPx));

            for (var y = minY; y <= maxY; y++)
            {
                for (var x = minX; x <= maxX; x++)
                {
                    var p = new Vector2(x + 0.5f, y + 0.5f);
                    if (DistanceToSegment(p, px0, px1) > radiusPx) continue;

                    var slot = band + y * MaskSize + x;
                    if (_painted[slot]) continue;

                    _painted[slot] = true;
                    _count[index]++;
                    _pixels[slot] = new Color32(0x19, 0x4D, 0x65, 255);
                }
            }
        }

        /// <summary>Body 局部坐标 → 该段遮罩的像素坐标（原点在段的左下）。</summary>
        Vector2 ToMask(SegmentView seg, Vector2 local)
        {
            var u = (local.x - seg.Rect.xMin) / seg.Rect.width;
            var v = (local.y - seg.Rect.yMin) / seg.Rect.height;
            return new Vector2(u * (MaskSize - 1), v * (MaskSize - 1));
        }

        static float DistanceToSegment(Vector2 p, Vector2 a, Vector2 b)
        {
            var ab = b - a;
            var len = ab.sqrMagnitude;
            if (len < 0.0001f) return Vector2.Distance(p, a);
            var t = Mathf.Clamp01(Vector2.Dot(p - a, ab) / len);
            return Vector2.Distance(p, a + ab * t);
        }

        void Flush()
        {
            if (_tex == null) return;
            _tex.SetPixels32(_pixels);
            _tex.Apply(false);
        }

        void SampleCoverage()
        {
            var total = MaskSize * MaskSize;
            for (var i = 0; i < _segments.Count; i++)
            {
                var seg = _segments[i];
                if (seg.Done) continue;
                if (_count[i] / (float)total < Threshold) continue;

                seg.Done = true;
                if (seg.Rail != null)
                {
                    var label = seg.Rail.GetComponentInChildren<TMP_Text>();
                    if (label != null)
                    {
                        label.color = MiniGameTheme.Deep;   // 右栏只在这一刻变一次（§10.4）
                        label.alpha = 1f;
                    }
                }
                FlashHighlight(seg.Reveal.rectTransform, MiniGameTheme.Yellow, 2);
                Judge.Advance();
            }
        }

        protected override JudgeResult OnJudge()
        {
            // T5 没有落位：进度由覆盖率轮询直接写入 Judge
            return JudgeResult.No("rubbing-uses-coverage");
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;
            for (var i = 0; i < _segments.Count; i++)
            {
                if (_segments[i].Done) continue;
                ShowHighlight(_segments[i].Reveal.rectTransform, MiniGameTheme.Blue, 3f, 10f);
                return;
            }
        }

        // ---------------- 进度：遮罩整张存 PNG ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            byte[] png;
            try { png = System.Convert.FromBase64String(progress.MaskBase64); }
            catch { return; }
            if (png == null || png.Length == 0) return;

            _tex.LoadImage(png);
            _pixels = _tex.GetPixels32();

            var total = MaskSize * MaskSize;
            for (var i = 0; i < _segments.Count; i++)
            {
                var band = i * total;
                var count = 0;
                for (var p = 0; p < total; p++)
                {
                    if (_pixels[band + p].a < 128) continue;
                    _painted[band + p] = true;
                    count++;
                }
                _count[i] = count;
                var done = count / (float)total >= Threshold;
                _segments[i].Done = done;
                if (done && _segments[i].Rail != null)
                {
                    var label = _segments[i].Rail.GetComponentInChildren<TMP_Text>();
                    if (label != null)
                    {
                        label.color = MiniGameTheme.Deep;
                        label.alpha = 1f;
                    }
                }
            }
            Flush();
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            try
            {
                var png = _tex.EncodeToPNG();
                progress.MaskBase64 = System.Convert.ToBase64String(png);
            }
            catch
            {
                progress.MaskBase64 = null;
            }
            return progress;
        }
    }
}
