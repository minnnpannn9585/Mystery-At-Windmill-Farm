using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T2 拨开遮挡（§7）。Q10 / Q12 的前半段。
    ///
    /// 草束是「可反悔」的：拖进停放区算挪开，拖出来就复原——和 T6 的「按下即夹、松手即放」是两种性格（§7.10）。
    /// 判定以「草束中心到没到停放区」为准，不做位移阈值；弹回由骨架负责，弹回本身就是反馈，不弹文案。
    /// 目标被揭开后**还要点一下**才算查验（§7.5）：「看见」和「查验」是两个动作。
    ///
    /// 「有没有被盖住」每帧按**实际矩形相交**重算，不用「挪过哪些草」这种记账式判断：
    /// 一个目标常常同时被两三束草压着，记账式会在挪走第一束时就把它点亮，
    /// 而那时其余草还实实在在挡在上面。
    /// </summary>
    public sealed class UncoverBoard : MiniGameBoard
    {
        sealed class BundleView
        {
            public string Id;
            public RectTransform Rect;
            public MiniGamePiece Piece;
            public bool Moved;
        }

        sealed class TargetView
        {
            public MiniGameTarget Spec;
            public RectTransform Rect;
            public Button Button;
            public CanvasGroup Group;
            public RectTransform Rail;
            public bool Revealed;
            public bool Confirmed;
        }

        /// <summary>遮罩淡入淡出的时长（§7.5 的「回弹一下」在 M2 退化成 0.25s 补间）。</summary>
        const float RevealDuration = 0.25f;

        readonly List<BundleView> _bundles = new List<BundleView>();
        readonly List<TargetView> _targets = new List<TargetView>();
        string _parkId;
        int _movedCount;

        protected override string FooterText { get { return "拨开 ｜ 拖动草束 · 点击显露处"; } }

        protected override void BuildBoard()
        {
            // 目标：先隐着（alpha 0、不可点），被揭开才淡入 —— 像被掀开的东西回弹一下（§7.5）
            for (var i = 0; i < Content.Targets.Length; i++)
            {
                var spec = Content.Targets[i];
                var rect = MiniGameUIKit.Panel(Body, "Target_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.85f), 16f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), new Vector2(120f, 120f));

                var mark = MiniGameUIKit.Label(rect, "Mark", 22f, MiniGameTheme.Deep);
                MiniGameUIKit.Stretch(mark.rectTransform);
                mark.text = spec.Label;

                var group = rect.gameObject.AddComponent<CanvasGroup>();
                group.alpha = 0f;
                group.blocksRaycasts = false;

                var button = rect.gameObject.AddComponent<Button>();
                button.targetGraphic = rect.GetComponent<Image>();
                button.interactable = false;
                var captured = i;
                button.onClick.AddListener(() => OnTargetClicked(captured));

                _targets.Add(new TargetView
                {
                    Spec = spec,
                    Rect = rect,
                    Button = button,
                    Group = group,
                    Rail = AddRailSlot(spec.Label, i),
                });
            }

            // 草束：位置来自 Content.Segments（T2 借用它装草束的框）
            for (var i = 0; i < Content.Segments.Length; i++)
            {
                var seg = Content.Segments[i];
                var centerArt = new Vector2(seg.Pos.x + seg.Size.x * 0.5f, seg.Pos.y + seg.Size.y * 0.5f);
                var home = BodyPoint(centerArt.x, centerArt.y);

                var rect = MiniGameUIKit.Panel(Body, "Bundle_" + seg.Id,
                    MiniGameTheme.Alpha(new Color(0.72f, 0.62f, 0.32f), 0.95f), 14f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), home, seg.Size);

                var piece = AddPiece(seg.Id, rect, home);
                _bundles.Add(new BundleView
                {
                    Id = seg.Id,
                    Rect = rect,
                    Piece = piece,
                });
            }

            // 停放区（一局只有一个）
            if (Content.Slots.Length > 0)
            {
                var park = Content.Slots[0];
                _parkId = park.Id;

                var frame = MiniGameUIKit.Panel(Body, "Park", MiniGameTheme.Alpha(MiniGameTheme.Cream, 0.35f), 14f);
                MiniGameUIKit.Place(frame, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(park.Pos.x, park.Pos.y), park.Size);
                var hint = MiniGameUIKit.Label(frame, "Hint", 20f, MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.5f));
                MiniGameUIKit.Place(hint.rectTransform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                    new Vector2(0f, 24f), new Vector2(park.Size.x - 24f, 32f));
                hint.text = "停放区";

                AddTarget(new DropTarget
                {
                    Id = park.Id,
                    Shape = DropShape.Rect,
                    Center = new Vector2(park.Pos.x + park.Size.x * 0.5f, -park.Pos.y - park.Size.y * 0.5f),
                    Rect = new Rect(park.Pos.x, -park.Pos.y - park.Size.y, park.Size.x, park.Size.y),
                });
            }

            Judge.Total = Mathf.Max(1, _targets.Count);
            RefreshCoverage(0f);
        }

        // ---------------- 覆盖判定 ----------------

        /// <summary>两块矩形是否有**真实重叠**（边缘相切不算）。留 0.5px 容差挡住浮点噪声。</summary>
        static bool Overlaps(Vector2 centerA, Vector2 sizeA, Vector2 centerB, Vector2 sizeB)
        {
            var dx = Mathf.Abs(centerA.x - centerB.x) - (sizeA.x + sizeB.x) * 0.5f;
            var dy = Mathf.Abs(centerA.y - centerB.y) - (sizeA.y + sizeB.y) * 0.5f;
            return dx < -0.5f && dy < -0.5f;
        }

        BundleView FindCoveringBundle(TargetView target)
        {
            var ts = target.Rect.rect.size;
            var tc = (Vector2)target.Rect.anchoredPosition;
            for (var i = 0; i < _bundles.Count; i++)
            {
                var b = _bundles[i];
                if (b.Rect == null) continue;
                if (Overlaps(b.Rect.anchoredPosition, b.Rect.rect.size, tc, ts)) return b;
            }
            return null;
        }

        /// <summary>
        /// 每帧按草束**当前**位置重算：还剩任何一束压在目标上，目标就保持隐藏且不可点。
        /// 好处是「拖走 → 露出 → 再拖回来 → 重新盖住」全都自动成立，不用额外写反悔分支。
        /// </summary>
        void RefreshCoverage(float dt)
        {
            var step = dt <= 0f ? 1f : dt / RevealDuration;

            for (var t = 0; t < _targets.Count; t++)
            {
                var target = _targets[t];
                if (target.Confirmed) continue;

                var covered = FindCoveringBundle(target) != null;
                var want = !covered;

                if (want && !target.Revealed)
                {
                    target.Revealed = true;
                    target.Group.blocksRaycasts = true;
                    target.Button.interactable = true;
                }
                else if (!want && target.Revealed)
                {
                    target.Revealed = false;
                    target.Group.blocksRaycasts = false;
                    target.Button.interactable = false;
                }

                var goal = want ? 1f : 0f;
                if (!Mathf.Approximately(target.Group.alpha, goal))
                {
                    var a = Mathf.MoveTowards(target.Group.alpha, goal, step);
                    target.Group.alpha = a;
                    // 揭开时 0.92 → 1 轻微放大，盖回去时反向缩回，读起来像被掀/被盖
                    var s = Mathf.Lerp(0.92f, 1f, a);
                    target.Rect.localScale = new Vector3(s, s, 1f);
                }
            }
        }

        protected override void TickBoard(float dt)
        {
            RefreshCoverage(dt);
        }

        // ---------------- 交互 ----------------

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            if (target == null || handle == null) return false;
            if (target.Id != _parkId) return false;

            var bundle = FindBundle(handle.Id);
            if (bundle == null) return false;

            // 进停放区：按挪开顺序在框内竖排，留出实物感（草束留在画面里，不飞出）
            var slotY = 70f + _movedCount * 130f;
            var home = BodyPoint(Content.Slots[0].Pos.x + Content.Slots[0].Size.x * 0.5f,
                Content.Slots[0].Pos.y + slotY);
            bundle.Piece.HomePos = home;
            bundle.Piece.Placed = false;                // 可反悔：再拖得出来（§7.10-7）
            // 吸附到框内槽位：不吸附的话几束草会叠在各自松手的位置上
            bundle.Piece.Handle.SyncTo(home);
            if (!bundle.Moved)
            {
                bundle.Moved = true;
                _movedCount++;
            }

            RefreshCoverage(Time.unscaledDeltaTime);
            return true;
        }

        protected override JudgeResult OnJudge()
        {
            // 挪草束不计分：计分只发生在点击确认（§7.5）
            return JudgeResult.No("uncover-nudge");
        }

        void OnTargetClicked(int index)
        {
            if (index < 0 || index >= _targets.Count) return;
            var target = _targets[index];
            if (!target.Revealed || target.Confirmed) return;

            target.Confirmed = true;
            target.Button.interactable = false;
            target.Group.blocksRaycasts = false;
            target.Group.alpha = 1f;
            target.Rect.localScale = Vector3.one;
            FlashHighlight(target.Rect, MiniGameTheme.Yellow, 3);
            var image = target.Rect.GetComponent<Image>();
            if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.85f);

            MarkRailDone(target);
            Judge.Advance();
        }

        void MarkRailDone(TargetView target)
        {
            if (target.Rail == null) return;
            var label = target.Rail.GetComponentInChildren<TMP_Text>();
            if (label == null) return;
            label.text = "✓ " + target.Spec.Label;
            label.color = MiniGameTheme.DarkGreen;
        }

        BundleView FindBundle(string id)
        {
            for (var i = 0; i < _bundles.Count; i++)
                if (_bundles[i].Id == id) return _bundles[i];
            return null;
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;

            // 二级：先指出「还压着东西的那束草」，都挪开了再指未确认的目标
            for (var i = 0; i < _targets.Count; i++)
            {
                var target = _targets[i];
                if (target.Confirmed || target.Revealed) continue;
                var bundle = FindCoveringBundle(target);
                if (bundle != null)
                {
                    ShowHighlight(bundle.Rect, MiniGameTheme.Yellow, 3f);
                    return;
                }
            }
            for (var i = 0; i < _targets.Count; i++)
            {
                var target = _targets[i];
                if (!target.Revealed || target.Confirmed) continue;
                ShowHighlight(target.Rect, MiniGameTheme.Blue, 3f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            // "b1,b2|t1"
            var raw = MagnifierBoard.Csv(progress.MaskBase64);
            var parts = raw.Split('|');
            if (parts.Length > 0 && parts[0].Length > 0 && Content.Slots.Length > 0)
            {
                var moved = parts[0].Split(',');
                for (var i = 0; i < moved.Length; i++)
                {
                    var bundle = FindBundle(moved[i]);
                    if (bundle == null || bundle.Moved) continue;
                    var slotY = 70f + _movedCount * 130f;
                    var home = BodyPoint(Content.Slots[0].Pos.x + Content.Slots[0].Size.x * 0.5f,
                        Content.Slots[0].Pos.y + slotY);
                    bundle.Piece.HomePos = home;
                    bundle.Piece.Handle.SyncTo(home);
                    bundle.Moved = true;
                    _movedCount++;
                }
            }
            if (parts.Length > 1 && parts[1].Length > 0)
            {
                var confirmed = parts[1].Split(',');
                for (var i = 0; i < confirmed.Length; i++)
                {
                    for (var t = 0; t < _targets.Count; t++)
                    {
                        if (_targets[t].Spec.Id != confirmed[i]) continue;
                        var target = _targets[t];
                        target.Revealed = true;
                        target.Confirmed = true;
                        target.Group.alpha = 1f;
                        target.Group.blocksRaycasts = false;
                        target.Button.interactable = false;
                        target.Rect.localScale = Vector3.one;
                        var image = target.Rect.GetComponent<Image>();
                        if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.85f);
                        MarkRailDone(target);
                        break;
                    }
                }
            }

            // 草束归位后，剩下的显隐交给每帧的覆盖判定，不必在这里再点一遍
            RefreshCoverage(0f);
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var moved = new List<string>();
            for (var i = 0; i < _bundles.Count; i++)
                if (_bundles[i].Moved) moved.Add(_bundles[i].Id);

            var confirmed = new List<string>();
            for (var i = 0; i < _targets.Count; i++)
                if (_targets[i].Confirmed) confirmed.Add(_targets[i].Spec.Id);

            progress.MaskBase64 = MagnifierBoard.Encode(
                string.Join(",", moved.ToArray()) + "|" + string.Join(",", confirmed.ToArray()));
            return progress;
        }
    }
}
