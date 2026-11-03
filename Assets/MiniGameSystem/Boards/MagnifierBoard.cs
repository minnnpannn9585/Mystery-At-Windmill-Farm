using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T1 放大镜调查（§6）。Q06 / Q09 / Q11 / Q14。
    ///
    /// 判定用**镜心到目标的距离**，不用整圆相交——玩家的心理模型是「我把镜片中心对准了它」（§6.4）。
    /// 手势沿用骨架的 8px / 点击分支：拖动只移动，原地松手才算一次「调查」。
    /// 没命中不报错，弹一句「好像没什么特别的……」，这是告诉玩家动作有效、只是这儿没有（§6.6）。
    /// </summary>
    public sealed class MagnifierBoard : MiniGameBoard
    {
        sealed class TargetView
        {
            public MiniGameTarget Spec;
            public RectTransform Dot;
            public RectTransform Rail;
            public bool Confirmed;
        }

        static readonly Vector2 LensSize = new Vector2(240f, 240f);

        readonly List<TargetView> _targets = new List<TargetView>();
        MiniGamePiece _lens;
        float _lastMissAt = -10f;

        protected override string FooterText { get { return "调查 ｜ 拖动镜片 · 对准后点一下"; } }

        /// <summary>
        /// 镜片是「工具」不是「零件」：松手就该留在原地，弹回起点的话玩家没法在原地补一次点击
        /// ——而 T1 的判定恰恰是「原地松手 = 调查」。
        /// </summary>
        protected override bool ReturnHomeOnReject { get { return false; } }

        protected override void BuildBoard()
        {
            // 痕迹点：M2 用色块占位，M3 换成素材（每处 20–30px，热区另算）
            for (var i = 0; i < Content.Targets.Length; i++)
            {
                var spec = Content.Targets[i];
                var dot = MiniGameUIKit.Panel(Body, "Target_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.45f), 24f);
                MiniGameUIKit.Place(dot, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), new Vector2(36f, 36f));

                _targets.Add(new TargetView
                {
                    Spec = spec,
                    Dot = dot,
                    Rail = AddRailSlot(spec.Label, i),
                });
            }

            // 镜片：一个可拖的圆，起手放在主区底部中间
            var lens = MiniGameUIKit.Panel(Body, "Lens",
                MiniGameTheme.Alpha(MiniGameTheme.Blue, 0.18f), 120f, true);
            var home = BodyPoint(MiniGameTheme.Body.width * 0.5f, MiniGameTheme.Body.height - 130f);
            MiniGameUIKit.Place(lens, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), home, LensSize);
            var rim = MiniGameUIKit.Label(lens, "Rim", 20f, MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.5f));
            MiniGameUIKit.Stretch(rim.rectTransform);
            rim.text = "镜片";

            _lens = AddPiece("lens", lens, home);
            _lens.MinHitSize = 96f;

            Judge.Total = Mathf.Max(1, _targets.Count);
        }

        // ---------------- 交互 ----------------

        /// <summary>
        /// T1 没有「落位」这一步——判定发生在点击（Investigate）里，进度也是那里推进的。
        /// 这里的实现只为满足基类契约，正常流程走不到。
        /// </summary>
        protected override JudgeResult OnJudge()
        {
            return JudgeResult.No("magnifier-uses-click");
        }

        protected override void OnPieceClick(MiniGamePiece piece)
        {
            if (piece == null || piece != _lens) return;
            Investigate(piece.Handle.LocalPosition);
        }

        /// <summary>留在原地之后要兜一手：镜心必须还在主区内，否则玩家再也拿不到它。</summary>
        protected override void OnReject(DropTarget target, CarryHandle handle)
        {
            ClampLens();
        }

        void ClampLens()
        {
            if (_lens == null || _lens.Rect == null) return;
            var area = Body.rect;
            const float inset = 24f;
            var p = _lens.Rect.anchoredPosition;
            p.x = Mathf.Clamp(p.x, area.xMin + inset, area.xMax - inset);
            p.y = Mathf.Clamp(p.y, area.yMin + inset, area.yMax - inset);
            _lens.Rect.anchoredPosition = p;
            _lens.HomePos = p;
        }

        void Investigate(Vector2 lensCenter)
        {
            TargetView best = null;
            var bestD = float.MaxValue;

            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                if (t.Confirmed) continue;
                var d = Vector2.Distance(lensCenter, BodyPoint(t.Spec.Pos.x, t.Spec.Pos.y));
                if (d <= t.Spec.Radius && d < bestD)
                {
                    bestD = d;
                    best = t;
                }
            }

            if (best == null)
            {
                Miss(lensCenter);
                return;
            }
            Confirm(best);
        }

        void Confirm(TargetView target)
        {
            target.Confirmed = true;

            // ① 描边闪烁 ② 目标点转亮 ③ 右栏刷新 ④ 计数滚动（§6.5 的 M2 简化版）
            FlashHighlight(target.Dot, MiniGameTheme.Yellow, 3);
            var image = target.Dot.GetComponent<UnityEngine.UI.Image>();
            if (image != null) image.color = MiniGameTheme.Yellow;

            if (target.Rail != null)
            {
                var label = target.Rail.GetComponentInChildren<TMP_Text>();
                if (label != null)
                {
                    label.text = "✓ " + target.Spec.Label;
                    label.color = MiniGameTheme.DarkGreen;
                }
            }

            Judge.Advance();
        }

        /// <summary>未命中反馈。同一句 3s 内不重复弹（§6.6 防连点刷屏）。</summary>
        void Miss(Vector2 lensCenter)
        {
            if (Time.unscaledTime - _lastMissAt < 3f) return;
            _lastMissAt = Time.unscaledTime;

            var toast = MiniGameUIKit.Label(Body, "Miss", 20f, MiniGameTheme.Deep,
                TextAlignmentOptions.Center);
            toast.enableWordWrapping = false;
            MiniGameUIKit.Place(toast.rectTransform, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                lensCenter + new Vector2(0f, LensSize.y * 0.5f + 40f), new Vector2(420f, 44f));
            toast.text = "好像没什么特别的……";

            var bg = MiniGameUIKit.Panel(toast.transform.parent, "MissBg",
                MiniGameTheme.Alpha(MiniGameTheme.Cream, 0.92f), 12f);
            bg.SetSiblingIndex(toast.transform.GetSiblingIndex());
            MiniGameUIKit.Place(bg, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                lensCenter + new Vector2(0f, LensSize.y * 0.5f + 40f), new Vector2(420f, 52f));

            StartCoroutine(FadeOut(toast.gameObject, bg.gameObject, 0.9f));
        }

        System.Collections.IEnumerator FadeOut(GameObject text, GameObject bg, float life)
        {
            var group = text.AddComponent<CanvasGroup>();
            var bgGroup = bg.AddComponent<CanvasGroup>();
            var t = 0f;
            while (t < life)
            {
                t += Time.unscaledDeltaTime;
                var a = t < life * 0.55f ? 1f : 1f - (t - life * 0.55f) / (life * 0.45f);
                group.alpha = a;
                bgGroup.alpha = a;
                yield return null;
            }
            Destroy(bg);
            Destroy(text);
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;
            for (var i = 0; i < _targets.Count; i++)
            {
                if (_targets[i].Confirmed) continue;
                ShowHighlight(_targets[i].Dot, MiniGameTheme.Yellow, 3f, 14f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            var ids = Csv(progress.MaskBase64).Split(',');
            for (var i = 0; i < ids.Length; i++)
            {
                if (string.IsNullOrEmpty(ids[i])) continue;
                for (var j = 0; j < _targets.Count; j++)
                {
                    if (_targets[j].Spec.Id != ids[i]) continue;
                    var t = _targets[j];
                    t.Confirmed = true;
                    var image = t.Dot.GetComponent<UnityEngine.UI.Image>();
                    if (image != null) image.color = MiniGameTheme.Yellow;
                    if (t.Rail != null)
                    {
                        var label = t.Rail.GetComponentInChildren<TMP_Text>();
                        if (label != null)
                        {
                            label.text = "✓ " + t.Spec.Label;
                            label.color = MiniGameTheme.DarkGreen;
                        }
                    }
                    break;
                }
            }
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var ids = new List<string>();
            for (var i = 0; i < _targets.Count; i++)
                if (_targets[i].Confirmed) ids.Add(_targets[i].Spec.Id);
            progress.MaskBase64 = Encode(string.Join(",", ids.ToArray()));
            return progress;
        }

        internal static string Encode(string text)
        {
            return System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(text));
        }

        internal static string Csv(string base64)
        {
            if (string.IsNullOrEmpty(base64)) return "";
            try { return System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(base64)); }
            catch { return ""; }
        }
    }
}
