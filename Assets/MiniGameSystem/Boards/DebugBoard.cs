using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// M1 自检局。它不是七个模板里的任何一个，专门用来验证框架的整条链：
    /// 开 → 入场 → 拖拽 / 点击阈值 → 落位判定 → 提示两级 → 完成横幅 → 入册演出 → 关；
    /// 以及「退出 → 续局」这条支线（§18.1 M1 验收：开关、暂停、退出、续局、演出全链路通）。
    ///
    /// 玩法：三张卡拖进三个槽，卡号与槽号对上才算数，错了留在槽里等下再调（和 T4 的错位留存同款）。
    /// </summary>
    public sealed class DebugBoard : MiniGameBoard
    {
        sealed class SlotView
        {
            public string Id;
            public RectTransform Rect;
            public DropTarget Target;
            public TMP_Text Index;
            public TMP_Text RailLabel;
            public int Number;
            public bool Filled;
        }

        readonly List<SlotView> _slots = new List<SlotView>();
        readonly List<MiniGamePiece> _cards = new List<MiniGamePiece>();

        static readonly Vector2 SlotSize = new Vector2(220f, 160f);
        static readonly Vector2 CardSize = new Vector2(200f, 120f);
        static readonly float CardRowY = 470f;

        protected override bool HasRail { get { return true; } }

        protected override string FooterText
        {
            get { return "拖动 ｜ 按住卡拖动 · 松手放下 ｜ 提示 1/2"; }
        }

        protected override void BuildBoard()
        {
            var targets = Content.Targets;
            for (var i = 0; i < targets.Length; i++)
            {
                var t = targets[i];
                var center = BodyPoint(t.Pos.x, t.Pos.y);

                var slotRect = MiniGameUIKit.Panel(Body, "Slot_" + t.Id, MiniGameTheme.Cream, 12f, true);
                MiniGameUIKit.Place(slotRect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                    center, SlotSize);

                var index = MiniGameUIKit.Label(slotRect, "Index", 26f,
                    MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.5f));
                MiniGameUIKit.Stretch(index.rectTransform);
                index.text = (i + 1).ToString();

                var target = new DropTarget
                {
                    Id = t.Id,
                    Shape = DropShape.Slot,
                    Center = center,
                    Rect = new Rect(center.x - SlotSize.x * 0.5f, center.y - SlotSize.y * 0.5f,
                        SlotSize.x, SlotSize.y),
                    // 宽容吸附带 12px（§4.4）
                    PredictRatio = 0f,
                };
                ExtendRect(target, 12f);
                AddTarget(target);

                var rail = AddRailSlot(t.Label, i);

                _slots.Add(new SlotView
                {
                    Id = t.Id,
                    Rect = slotRect,
                    Target = target,
                    Index = index,
                    RailLabel = rail != null ? rail.GetComponentInChildren<TMP_Text>() : null,
                    Number = i + 1,
                });
            }

            var labels = Content.Labels;
            for (var i = 0; i < labels.Length; i++)
            {
                var cardRect = MiniGameUIKit.Panel(Body, "Card_" + i, MiniGameTheme.Yellow, 14f, true);
                var center = BodyPoint(200f + i * 442f, CardRowY);
                MiniGameUIKit.Place(cardRect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                    center, CardSize);

                var text = MiniGameUIKit.Label(cardRect, "Text", 28f, MiniGameTheme.Deep);
                MiniGameUIKit.Stretch(text.rectTransform);
                text.text = labels[i];

                _cards.Add(AddPiece("c" + (i + 1), cardRect, center));
            }
        }

        static void ExtendRect(DropTarget target, float pad)
        {
            var r = target.Rect;
            target.Rect = new Rect(r.xMin - pad, r.yMin - pad, r.width + pad * 2f, r.height + pad * 2f);
        }

        // ---------------- 判定 ----------------

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            // 任何卡都接受落位——对不对由 OnJudge 说，这样「错位留存」这条路也走得到
            return target != null && !string.IsNullOrEmpty(target.Id);
        }

        protected override JudgeResult OnJudge()
        {
            if (LastTarget == null || LastHandle == null) return JudgeResult.No();

            var slot = FindSlot(LastTarget.Id);
            if (slot == null) return JudgeResult.No();

            var card = FindCard(LastHandle.Id);
            if (card == null) return JudgeResult.No();

            var cardNumber = _cards.IndexOf(card) + 1;
            if (cardNumber != slot.Number)
            {
                // 错位：留在槽里、橙闪一下，但**不标 Placed** ——
                // Placed 会挡住 TryBeginCarry，标了就再也拿不起来，三槽永远凑不齐。
                // 「留存」靠的是把 HomePos 改成这个槽：下次丢到空白处它会自己回到槽里。
                card.Placed = false;
                SnapTo(card, slot);
                FlashHighlight(card.Rect, MiniGameTheme.Orange);
                return JudgeResult.No("mismatch");
            }

            card.Placed = true;
            SnapTo(card, slot);
            slot.Filled = true;
            if (slot.Index != null) slot.Index.text = "✓";
            if (slot.RailLabel != null) slot.RailLabel.text = slot.Id + " 已确认";
            return JudgeResult.Yes(slot.Id);
        }

        void SnapTo(MiniGamePiece card, SlotView slot)
        {
            // HomePos 记的是「槽」而不是「松手那一刻的位置」：
            // 错位卡会被后续拖拽带回这里，差几像素的偏移会越积越明显。
            card.HomePos = slot.Rect.anchoredPosition;
            card.Handle.SyncTo(slot.Rect.anchoredPosition);
        }

        SlotView FindSlot(string id)
        {
            for (var i = 0; i < _slots.Count; i++)
                if (_slots[i].Id == id) return _slots[i];
            return null;
        }

        MiniGamePiece FindCard(string id)
        {
            for (var i = 0; i < _cards.Count; i++)
                if (_cards[i].Id == id) return _cards[i];
            return null;
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            Debug.Log("[DebugBoard] hint " + level + ": " + text);
            if (level == 1) return;

            // 二级提示：点亮一张还没归位的卡 + 它该去的槽
            for (var i = 0; i < _cards.Count; i++)
            {
                if (_cards[i].Placed && IsCorrectlyPlaced(_cards[i])) continue;
                var slot = _slots.Count > i ? _slots[i] : null;
                ShowHighlight(_cards[i].Rect, MiniGameTheme.Yellow, 3f);
                if (slot != null) ShowHighlight(slot.Rect, MiniGameTheme.Blue, 3f);
                return;
            }
        }

        bool IsCorrectlyPlaced(MiniGamePiece card)
        {
            var index = _cards.IndexOf(card);
            return index >= 0 && index < _slots.Count && _slots[index].Filled;
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || progress.Done <= 0) return;
            SyncJudgeFromProgress(progress);

            for (var i = 0; i < _slots.Count && i < progress.Done; i++)
            {
                var slot = _slots[i];
                slot.Filled = true;
                if (slot.Index != null) slot.Index.text = "✓";
                if (slot.RailLabel != null) slot.RailLabel.text = slot.Id + " 已确认";
                if (i < _cards.Count)
                {
                    _cards[i].Placed = true;
                    _cards[i].Handle.SyncTo(slot.Rect.anchoredPosition);
                }
            }
            RefreshRailCount();
        }

        public override MiniGameProgress CaptureProgress()
        {
            return NewProgress();
        }
    }
}
