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
        const float CardRowY = 460f;               // 平铺时的卡片中心 y（美术坐标，y 向下）
        /// <summary>卡片横向铺排的可用宽度 = Body 全宽，别自己先留一刀边距。</summary>
        const float CardLayoutWidth = 1285f;
        /// <summary>平铺时允许的最大正间隙：2 张卡不要被推到纸的两头。</summary>
        const float MaxCardGap = 240f;
        /// <summary>
        /// 平铺时允许的最小间隙（负值 = 交叠）。5 张卡需要 -78.75 就能铺满全宽，
        /// 所以必须放得到 -96；只有连这个值都不够（6 张起）才切换到堆叠。
        /// </summary>
        const float MinCardGap = -96f;
        /// <summary>堆叠时卡心的最大步长。按可用宽度反推，避免又挤成中间一小撮。</summary>
        const float MaxStackStep = 140f;
        const float MinStackStep = 24f;
        const float StackCenterX = 642f;           // 堆叠中心 x（Body 内容坐标）
        const float StackCenterY = 468f;           // 堆叠中心 y

        readonly List<SlotView> _slots = new List<SlotView>();
        readonly Dictionary<string, RectTransform> _cardRect = new Dictionary<string, RectTransform>();
        readonly Dictionary<string, string> _slotOf = new Dictionary<string, string>();

        // ---------- 桌面堆叠（概念图：错落白卡 + 投影 + 悬浮置顶） ----------
        readonly List<RectTransform> _stackCards = new List<RectTransform>();
        readonly Dictionary<RectTransform, string> _rectToId = new Dictionary<RectTransform, string>();
        readonly Dictionary<string, float> _baseAngle = new Dictionary<string, float>();
        readonly Dictionary<string, Vector2> _basePos = new Dictionary<string, Vector2>();
        RectTransform _hoverCard;
        float _hoverT;
        int _stackBaseSibling = -1;
        int _debugSerial;
        MiniGameCard[] _originalCards;
        bool _stacked;

        /// <summary>当前卡数（Debug 菜单读它显示状态）。</summary>
        public int CardCount { get { return _stackCards.Count; } }

        /// <summary>当前是否处于错落堆叠（Debug 菜单文案与测试共用同一份判定）。</summary>
        public bool IsStacked { get { return _stacked; } }

        /// <summary>把 total 张卡平铺铺满全宽时所需的间隙。</summary>
        static float FlatGap(int total)
        {
            return total > 1 ? (CardLayoutWidth - total * CardSize.x) / (total - 1) : 0f;
        }

        /// <summary>
        /// 只有「铺满全宽所需的间隙比 MinCardGap 还小」才堆叠 ——
        /// 5 张需要 -78.75，大于 -96，所以继续平铺；6 张需要 -127，才收成堆叠。
        /// 阈值从卡数改成由几何推导，不再出现「一到 5 张就啪地缩成一团」。
        /// </summary>
        static bool ShouldStack(int total)
        {
            return total > 1 && FlatGap(total) < MinCardGap;
        }

        protected override string FooterText { get { return "归位 ｜ 拖动要点 · 放入对应位置"; } }

        /// <summary>T7 错误卡用柔和的渐入回位，不用弹性弹跳。</summary>
        protected override bool RejectUsesFade { get { return true; } }

        /// <summary>先闪红、闪烁完整播完才开始回位——严格「先闪后回」。</summary>
        protected override float RejectReturnDelay { get { return RejectFlashDuration(2); } }

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
            // Debug 菜单会改写 Content.Cards，先留一份原始引用，退出本局时还原，避免污染下一局
            _originalCards = cards != null ? (MiniGameCard[])cards.Clone() : null;
            var n = cards != null ? cards.Length : 0;
            if (n == 0) return;

            _stacked = ShouldStack(n);
            for (var i = 0; i < n; i++) CreateCard(cards[i], i, n);
            if (_stackCards.Count > 0) _stackBaseSibling = _stackCards[0].GetSiblingIndex();
        }

        /// <summary>建一张卡：投影在最底层，卡面图标 / 文字在上；位置与角度走堆叠布局。</summary>
        void CreateCard(MiniGameCard card, int index, int total)
        {
            var rect = MiniGameUIKit.Panel(Body, "Card_" + card.Id, MiniGameTheme.Cream, 12f, true);

            // 投影：子物体先建 => 渲染在最底，卡面 Image 盖住内部，只露出偏移出去的一圈阴影。
            var shadow = MiniGameUIKit.Panel(rect, "Shadow", new Color(0f, 0f, 0f, 0.22f), 12f);
            MiniGameUIKit.Place(shadow, Vector2.one * 0.5f, Vector2.one * 0.5f,
                new Vector2(8f, -10f), CardSize);
            var shadowImage = shadow.GetComponent<UnityEngine.UI.Image>();
            if (shadowImage != null) shadowImage.raycastTarget = false;

            // 图标位：有正式卡面图标（T7-01~18）就铺 sprite，否则退回黄色色块占位。
            RectTransform icon;
            if (!string.IsNullOrEmpty(card.IconPath) && Resources.Load<Sprite>(card.IconPath) != null)
            {
                icon = MiniGameUIKit.SpriteArt(rect, "Icon", card.IconPath, Color.white);
                MiniGameUIKit.Place(icon, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                    new Vector2(0f, 46f), new Vector2(96f, 96f));
            }
            else
            {
                icon = MiniGameUIKit.Panel(rect, "Icon", MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.85f), 10f);
                MiniGameUIKit.Place(icon, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                    new Vector2(0f, 46f), new Vector2(96f, 96f));
            }

            var text = MiniGameUIKit.Paragraph(rect, "Text", 22f, MiniGameTheme.Deep,
                TextAlignmentOptions.Center);
            MiniGameUIKit.Place(text.rectTransform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                new Vector2(0f, 26f), new Vector2(CardSize.x - 32f, 96f));
            text.text = card.Text;

            var center = CardSlotPosition(index, total);
            MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), center, CardSize);
            var angle = BaseAngle(index, total);
            rect.localEulerAngles = new Vector3(0f, 0f, angle);
            _baseAngle[card.Id] = angle;
            _basePos[card.Id] = center;

            AddPiece(card.Id, rect, center);
            _cardRect[card.Id] = rect;
            _rectToId[rect] = card.Id;
            _stackCards.Add(rect);
        }

        /// <summary>
        /// 第 index 张卡的位置。自适应策略（用户口径）：
        ///   · 平铺时用 Body 全宽，间隙按卡数连续收缩，5 张仍铺满整片主区；
        ///   · 只有所需间隙小于 MinCardGap（6 张起）才切成错落堆叠；
        ///   · 堆叠也按可用宽度反推步长，绝不缩回中间一小撮。
        /// </summary>
        Vector2 CardSlotPosition(int index, int total)
        {
            if (!_stacked)
            {
                var gap = Mathf.Clamp(FlatGap(total), MinCardGap, MaxCardGap);
                var row = total * CardSize.x + (total - 1) * gap;
                var startX = (MiniGameTheme.Body.width - row) * 0.5f;
                var cx = startX + index * (CardSize.x + gap) + CardSize.x * 0.5f;
                return BodyPoint(cx, CardRowY);
            }

            // 卡心可用跨度 = 全宽 - 一张卡宽；按卡数均分，再钳到 [24, 140]。
            // 7 张时 step≈140、中心跨度 840，整片卡宽约 1160，仍能看清卡面。
            var centerSpan = Mathf.Max(0f, CardLayoutWidth - CardSize.x);
            var step = Mathf.Clamp(centerSpan / Mathf.Max(1, total - 1), MinStackStep, MaxStackStep);
            var dx = (index - (total - 1) * 0.5f) * step;
            var jitterX = Noise(index, 3, -5f, 5f);
            var jitterY = Noise(index, 7, -3f, 6f);
            return BodyPoint(StackCenterX + dx + jitterX, StackCenterY + index * 2.5f + jitterY);
        }

        /// <summary>确定性伪随机：同一组卡每次重排得到同样的错落，便于回归测试。</summary>
        static float Noise(int index, int seed, float min, float max)
        {
            var v = Mathf.PerlinNoise(index * 2.71f + seed * 11.3f, seed * 5.17f + 0.37f);
            return Mathf.Lerp(min, max, v);
        }

        float BaseAngle(int index, int total)
        {
            // 平铺时卡要整齐摆放，随机错乱只在堆叠局出现。
            return _stacked ? Noise(index, total + 17, -7f, 7f) : 0f;
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

        // ---------------- 堆叠的悬浮置顶 / 离开动画 ----------------

        protected override void TickBoard(float dt)
        {
            // 只有堆叠局、Play 态、手里没拿东西时才做悬浮；其余情况收掉悬浮态
            if (!_stacked || State != MiniGameState.Play || CarryingPiece != null)
            {
                ClearHover();
                return;
            }

            Vector2 local;
            // 不要求指针在 Body 内：桌面摆件可能已经拖到纸外，移回去也要能悬浮
            if (!MiniGameUIKit.ScreenToLocal(Body, Input.mousePosition, out local))
            {
                ClearHover();
                return;
            }

            // 从最上层往下找（渲染层级 = sibling index），命中第一张未归位的卡
            RectTransform hit = null;
            for (var i = Body.childCount - 1; i >= 0; i--)
            {
                var r = Body.GetChild(i) as RectTransform;
                if (r == null || !_rectToId.ContainsKey(r)) continue;
                var piece = FindPiece(_rectToId[r]);
                if (piece == null || piece.Placed || piece.Returning) continue;
                if (r.rect.Contains(local - r.anchoredPosition)) { hit = r; break; }
            }

            if (hit != _hoverCard) SetHover(hit);
            AnimateHover(dt);
        }

        void SetHover(RectTransform next)
        {
            if (_hoverCard != null)
            {
                RestoreCardLook(_hoverCard);
                RestoreStackOrder();
            }
            _hoverCard = next;
            _hoverT = 0f;
            // 鼠标移到哪张，哪张就绘制到最上层（离开时按创建顺序还原）
            if (next != null) next.SetAsLastSibling();
        }

        void ClearHover()
        {
            if (_hoverCard != null) SetHover(null);
        }

        void RestoreCardLook(RectTransform rect)
        {
            if (rect == null) return;
            rect.localScale = Vector3.one;
            string id;
            if (_rectToId.TryGetValue(rect, out id) && _baseAngle.ContainsKey(id))
                rect.localEulerAngles = new Vector3(0f, 0f, _baseAngle[id]);
        }

        void RestoreStackOrder()
        {
            if (_stackBaseSibling < 0) return;
            for (var i = 0; i < _stackCards.Count; i++)
            {
                var r = _stackCards[i];
                var index = _stackBaseSibling + i;
                if (r != null && r.parent == Body && index < Body.childCount)
                    r.SetSiblingIndex(index);
            }
        }

        void AnimateHover(float dt)
        {
            // 其他卡缓慢回到各自的基准角度 / 缩放
            for (var i = 0; i < _stackCards.Count; i++)
            {
                var r = _stackCards[i];
                if (r == null || r == _hoverCard) continue;
                string id;
                if (!_rectToId.TryGetValue(r, out id) || !_baseAngle.ContainsKey(id)) continue;
                r.localScale = Vector3.one * Mathf.MoveTowards(r.localScale.x, 1f, dt * 6f);
                var a = Mathf.MoveTowardsAngle(r.localEulerAngles.z, _baseAngle[id], dt * 120f);
                r.localEulerAngles = new Vector3(0f, 0f, a);
            }

            if (_hoverCard == null) return;
            _hoverT = Mathf.Clamp01(_hoverT + dt / 0.12f);
            var e = 1f - (1f - _hoverT) * (1f - _hoverT);
            _hoverCard.localScale = Vector3.one * Mathf.Lerp(1f, 1.075f, e);
            string hoverId;
            if (_rectToId.TryGetValue(_hoverCard, out hoverId) && _baseAngle.ContainsKey(hoverId))
            {
                // 悬浮时轻微旋转抖动，像手指碰了一下纸卡
                var wobble = Mathf.Sin(Time.unscaledTime * 17f) * 1.9f * e;
                _hoverCard.localEulerAngles = new Vector3(0f, 0f, _baseAngle[hoverId] + wobble);
            }
        }

        // ---------------- Debug：增减卡片（编辑器菜单调用） ----------------

        /// <summary>加一张混淆卡（无归属槽），并整体重排堆叠。</summary>
        public void DebugAddCard()
        {
            if (Content == null) return;
            ClearHover();
            _debugSerial++;
            var card = new MiniGameCard("dbg" + _debugSerial,
                "混淆线索 " + _debugSerial, null);
            var list = new List<MiniGameCard>(Content.Cards ?? new MiniGameCard[0]);
            list.Add(card);
            Content.Cards = list.ToArray();

            var total = list.Count;
            _stacked = ShouldStack(total);
            CreateCard(card, total - 1, total);
            ReflowStack();
        }

        /// <summary>删掉最后一张卡，并整体重排堆叠。至少保留 1 张。</summary>
        public void DebugRemoveCard()
        {
            if (Content == null || Content.Cards == null || Content.Cards.Length <= 1) return;
            if (_stackCards.Count <= 1) return;
            ClearHover();

            var last = Content.Cards[Content.Cards.Length - 1];
            var rect = RectOf(last.Id);
            if (rect != null)
            {
                _rectToId.Remove(rect);
                _stackCards.Remove(rect);
                Destroy(rect.gameObject);
            }
            _cardRect.Remove(last.Id);
            _baseAngle.Remove(last.Id);
            _basePos.Remove(last.Id);

            var piece = FindPiece(last.Id);
            if (piece != null) Pieces.Remove(piece);
            string placedSlot;
            if (_slotOf.TryGetValue(last.Id, out placedSlot))
            {
                var slot = FindSlot(placedSlot);
                if (slot != null) slot.Cards.Remove(last.Id);
                _slotOf.Remove(last.Id);
            }

            var list = new List<MiniGameCard>(Content.Cards);
            list.RemoveAt(list.Count - 1);
            Content.Cards = list.ToArray();
            _stacked = ShouldStack(list.Count);
            ReflowStack();
        }

        /// <summary>按新的卡数重新计算每张未归位卡的位置 / 角度。</summary>
        void ReflowStack()
        {
            var n = _stackCards.Count;
            for (var i = 0; i < n; i++)
            {
                var r = _stackCards[i];
                string id;
                if (r == null || !_rectToId.TryGetValue(r, out id)) continue;
                var piece = FindPiece(id);
                if (piece == null || piece.Placed) continue;

                var pos = CardSlotPosition(i, n);
                var angle = BaseAngle(i, n);
                _basePos[id] = pos;
                _baseAngle[id] = angle;
                piece.HomePos = pos;
                piece.Handle.SyncTo(pos);
                r.anchoredPosition = pos;
                r.localEulerAngles = new Vector3(0f, 0f, angle);
                r.localScale = Vector3.one;
            }
        }

        void OnDestroy()
        {
            // Debug 改的是注册表里那份 Content，出局时还原，下一局还是原始卡序
            if (_originalCards != null && Content != null) Content.Cards = _originalCards;
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
                // 从槽里拿起来了：把「家」从槽位改回拖拽前的真实位置，
                // 这样放错时（无论走 ReturnHome 还是渐入回位）都回得到起手处。
                piece.HomePos = piece.DragOrigin;
            }
            _slotOf.Remove(piece.Id);
        }

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            var card = Content.Card(handle != null ? handle.Id : null);
            if (card == null || target == null) return false;

            var rect = RectOf(card.Id);

            // 干扰卡：没有归属槽，拖到哪都弹回（§12.5）。不要求玩家主动丢弃。
            if (string.IsNullOrEmpty(card.SlotId))
            {
                if (rect != null) FlashHighlight(rect, MiniGameTheme.Orange, 2, restoreOnEnd: true);
                return false;
            }

            // 放错槽：闪红后复原 + 渐入回原位（§12.3）
            if (card.SlotId != target.Id)
            {
                if (rect != null) FlashHighlight(rect, MiniGameTheme.Orange, 2, restoreOnEnd: true);
                return false;
            }

            var slot = FindSlot(target.Id);
            if (slot == null) return false;

            // 槽里已经有卡（无论对错）就不许再放：拒绝 + 闪红 + 渐入回原位，杜绝重叠。
            // 之前只看 slot.Full，一槽多卡或重复拖同一槽时仍会叠加，这里改成「非空即拒」。
            if (slot.Cards.Count > 0)
            {
                if (rect != null) FlashHighlight(rect, MiniGameTheme.Orange, 2, restoreOnEnd: true);
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
                // 槽位是梯形 TrapezoidGraphic（非 Image），按 Graphic 基类染色才能生效。
                // 完成 / 填充态在便签主色上叠绿、黄，保持同色系而不是回到白底。
                var graphic = slot.Rect.GetComponent<UnityEngine.UI.Graphic>();
                var baseColor = Color.Lerp(
                    MiniGameTheme.NoteColor(Def != null ? Def.Template : MiniGameTemplate.Debug),
                    MiniGameTheme.Cream, 0.42f);
                if (graphic != null)
                    graphic.color = done
                        ? Color.Lerp(baseColor, MiniGameTheme.Green, 0.42f)
                        : filled
                            ? Color.Lerp(baseColor, MiniGameTheme.Yellow, 0.34f)
                            : baseColor;
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
