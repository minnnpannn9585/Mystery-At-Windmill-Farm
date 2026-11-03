using System.Collections.Generic;
using TMPro;
using UnityEngine;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T7 证词归位（§12）。六局里用得最多的模板：Q01 / Q04 / Q05 / Q07 / Q08 / Q13。
    ///
    /// 判定比整数，不做语义理解：卡自带 SlotId，槽的 Id 与之一致就是对的（§12.4）。
    /// 排序题（Q07）只是把槽名换成「第一段 / 第二段 / 第三段」，判定同一条路，不写第二套。
    /// 干扰卡 SlotId 为空，拖进任何槽都弹回（§12.5）；一槽多卡由槽的 Capacity 决定。
    /// </summary>
    public sealed class TestimonyBoard : MiniGameBoard
    {
        sealed class SlotView
        {
            public MiniGameSlot Spec;
            public RectTransform Rect;
            public TMP_Text Name;
            public TMP_Text Mark;
            public readonly List<string> Cards = new List<string>();
            public bool Full { get { return Cards.Count >= Mathf.Max(1, Spec.Capacity); } }
        }

        static readonly Vector2 CardSize = new Vector2(320f, 240f);
        const float CardRowY = 460f;
        const float CardGap = 28f;

        readonly List<SlotView> _slots = new List<SlotView>();
        readonly Dictionary<string, RectTransform> _cardRect = new Dictionary<string, RectTransform>();
        readonly Dictionary<string, string> _slotOf = new Dictionary<string, string>();

        protected override string FooterText { get { return "归位 ｜ 拖动要点 · 放入对应位置"; } }

        // ---------------- 建板 ----------------

        protected override void BuildBoard()
        {
            for (var i = 0; i < Content.Slots.Length; i++)
            {
                var spec = Content.Slots[i];
                var rect = MiniGameUIKit.Panel(Body, "Slot_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Cream, 0.94f), 12f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), spec.Size);

                var name = MiniGameUIKit.Label(rect, "Name", 22f, MiniGameTheme.Grey);
                MiniGameUIKit.Place(name.rectTransform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                    new Vector2(0f, -30f), new Vector2(spec.Size.x - 32f, 36f));
                name.text = spec.Label;

                var mark = MiniGameUIKit.Label(rect, "Mark", 30f, MiniGameTheme.Yellow);
                MiniGameUIKit.Stretch(mark.rectTransform);
                mark.text = "";

                AddTarget(new DropTarget
                {
                    Id = spec.Id,
                    Shape = DropShape.Slot,
                    Center = BodyPoint(spec.Pos.x + spec.Size.x * 0.5f, spec.Pos.y + spec.Size.y * 0.5f),
                    Rect = ArtRect(spec.Pos, spec.Size),
                });

                var rail = AddRailSlot(spec.Label, i);
                _slots.Add(new SlotView
                {
                    Spec = spec,
                    Rect = rect,
                    Name = name,
                    Mark = mark,
                    // 右栏的勾复用 Name 的颜色变化，不另建节点
                });
                if (rail != null) rail.name = "Rail_" + spec.Id;
            }

            BuildCards();

            // 判定总数 = 有效卡张数（不含干扰卡），不是槽数——一槽多卡时槽数会少一个
            Judge.Total = Mathf.Max(1, CountRealCards());
        }

        void BuildCards()
        {
            var cards = Content.Cards;
            var n = cards.Length;
            if (n == 0) return;

            var total = n * CardSize.x + (n - 1) * CardGap;
            var startX = (MiniGameTheme.Body.width - total) * 0.5f;

            for (var i = 0; i < n; i++)
            {
                var card = cards[i];
                var cx = startX + i * (CardSize.x + CardGap) + CardSize.x * 0.5f;
                var center = BodyPoint(cx, CardRowY);

                var rect = MiniGameUIKit.Panel(Body, "Card_" + card.Id, MiniGameTheme.Cream, 12f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), center, CardSize);

                // 图标位（M3 换真图）：这里用一枚色块代替，保证卡面不是纯文字
                var icon = MiniGameUIKit.Panel(rect, "Icon", MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.85f), 10f);
                MiniGameUIKit.Place(icon, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                    new Vector2(0f, 46f), new Vector2(96f, 96f));

                var text = MiniGameUIKit.Paragraph(rect, "Text", 22f, MiniGameTheme.Deep,
                    TextAlignmentOptions.Center);
                MiniGameUIKit.Place(text.rectTransform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                    new Vector2(0f, 26f), new Vector2(CardSize.x - 32f, 96f));
                text.text = card.Text;

                AddPiece(card.Id, rect, center);
                _cardRect[card.Id] = rect;
            }
        }

        static Rect ArtRect(Vector2 pos, Vector2 size)
        {
            return new Rect(pos.x, -pos.y - size.y, size.x, size.y);
        }

        int CountRealCards()
        {
            var n = 0;
            for (var i = 0; i < Content.Cards.Length; i++)
                if (!string.IsNullOrEmpty(Content.Cards[i].SlotId)) n++;
            return n;
        }

        // ---------------- 交互 ----------------

        protected override void OnCarryBegin(Vector2 local)
        {
            // 从槽里拿起来 → 释放该槽的容量（否则挪来挪去会把槽占满）
            var piece = CarryingPiece;
            if (piece == null) return;
            string slotId;
            if (!_slotOf.TryGetValue(piece.Id, out slotId)) return;

            var slot = FindSlot(slotId);
            if (slot != null)
            {
                slot.Cards.Remove(piece.Id);
                PaintSlot(slot);
            }
            _slotOf.Remove(piece.Id);
        }

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            var card = Content.Card(handle != null ? handle.Id : null);
            if (card == null || target == null) return false;

            // 干扰卡：没有归属槽，拖到哪都弹回（§12.5）。不要求玩家主动丢弃。
            if (string.IsNullOrEmpty(card.SlotId)) return false;

            // 放错槽：弹回 + 抖一下，无文案（§12.3）
            if (card.SlotId != target.Id)
            {
                var rect = RectOf(card.Id);
                if (rect != null) FlashHighlight(rect, MiniGameTheme.Orange, 2);
                return false;
            }

            var slot = FindSlot(target.Id);
            if (slot == null) return false;
            if (slot.Full)
            {
                var rect = RectOf(card.Id);
                if (rect != null) FlashHighlight(rect, MiniGameTheme.Orange, 2);
                return false;
            }

            slot.Cards.Add(card.Id);
            _slotOf[card.Id] = slot.Spec.Id;
            PaintSlot(slot);

            // 吸附进槽：多卡时按放入顺序横排（§12.5）
            var index = slot.Cards.Count - 1;
            var span = slot.Spec.Size.x / Mathf.Max(1, slot.Spec.Capacity);
            var cx = slot.Spec.Pos.x + span * (index + 0.5f);
            var cy = slot.Spec.Pos.y + slot.Spec.Size.y * 0.5f;
            var piece = FindPiece(card.Id);
            if (piece != null)
            {
                var home = BodyPoint(cx, cy);
                piece.HomePos = home;
                piece.Handle.SyncTo(home);
                piece.Placed = slot.Full;
                if (slot.Full) SpringReturn.ScaleTo(this, piece.Rect, 1f, 1f, 0.12f);
            }

            return true;
        }

        protected override JudgeResult OnJudge()
        {
            // 能走到这里的落位已经过了 OnDrop 的校验，直接算一步
            return JudgeResult.Yes(LastHandle != null ? LastHandle.Id : null);
        }

        MiniGamePiece FindPiece(string id)
        {
            for (var i = 0; i < Pieces.Count; i++)
                if (Pieces[i] != null && Pieces[i].Id == id) return Pieces[i];
            return null;
        }

        RectTransform RectOf(string cardId)
        {
            RectTransform rect;
            return _cardRect.TryGetValue(cardId, out rect) ? rect : null;
        }

        SlotView FindSlot(string id)
        {
            for (var i = 0; i < _slots.Count; i++)
                if (_slots[i].Spec.Id == id) return _slots[i];
            return null;
        }

        void PaintSlot(SlotView slot)
        {
            if (slot == null) return;
            var filled = slot.Cards.Count > 0;
            var done = slot.Full;
            slot.Name.color = done ? MiniGameTheme.Deep : MiniGameTheme.Grey;
            slot.Mark.text = done ? "✓" : "";
            if (slot.Rect != null)
            {
                var image = slot.Rect.GetComponent<UnityEngine.UI.Image>();
                if (image != null)
                    image.color = done
                        ? MiniGameTheme.Alpha(MiniGameTheme.Green, 0.30f)
                        : filled
                            ? MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.22f)
                            : MiniGameTheme.Alpha(MiniGameTheme.Cream, 0.94f);
            }
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;

            // 二级：高亮一张还没归位的卡 + 它该去的槽（§6.8 复用）
            for (var i = 0; i < Content.Cards.Length; i++)
            {
                var card = Content.Cards[i];
                if (string.IsNullOrEmpty(card.SlotId)) continue;
                string placed;
                if (_slotOf.TryGetValue(card.Id, out placed) && placed == card.SlotId) continue;

                var rect = RectOf(card.Id);
                if (rect != null) ShowHighlight(rect, MiniGameTheme.Yellow, 3f);
                var slot = FindSlot(card.SlotId);
                if (slot != null) ShowHighlight(slot.Rect, MiniGameTheme.Blue, 3f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            // 存档形如 "k1>s1;k2>s2"，重进时把卡贴回槽里，玩家看到的和退出前一致
            var pairs = System.Text.Encoding.UTF8.GetString(
                System.Convert.FromBase64String(progress.MaskBase64)).Split(';');
            for (var i = 0; i < pairs.Length; i++)
            {
                if (string.IsNullOrEmpty(pairs[i])) continue;
                var kv = pairs[i].Split('>');
                if (kv.Length != 2) continue;
                var slot = FindSlot(kv[1]);
                var piece = FindPiece(kv[0]);
                if (slot == null || piece == null) continue;

                slot.Cards.Add(kv[0]);
                _slotOf[kv[0]] = slot.Spec.Id;
                PaintSlot(slot);

                var index = slot.Cards.Count - 1;
                var span = slot.Spec.Size.x / Mathf.Max(1, slot.Spec.Capacity);
                var home = BodyPoint(slot.Spec.Pos.x + span * (index + 0.5f),
                    slot.Spec.Pos.y + slot.Spec.Size.y * 0.5f);
                piece.HomePos = home;
                piece.Handle.SyncTo(home);
                piece.Placed = slot.Full;
            }
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var sb = new System.Text.StringBuilder();
            foreach (var kv in _slotOf)
            {
                if (sb.Length > 0) sb.Append(';');
                sb.Append(kv.Key).Append('>').Append(kv.Value);
            }
            progress.MaskBase64 = System.Convert.ToBase64String(
                System.Text.Encoding.UTF8.GetBytes(sb.ToString()));
            return progress;
        }
    }
}
