using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T6 镊取物证（§11）。Q03（3 根黄绒毛）/ Q16（1 撮兽毛，两步）。
    ///
    /// 手势与其它模板不同：**按下即夹、松手即放**，中间没有「夹着东西想一想」的缓冲（§11.2）。
    /// 空夹只在按下的那一帧判一次——按住不放把夹子移到目标上也不会夹起，
    /// 否则会出现「拖着找目标、路过自动夹住」的黏滞感。
    ///
    /// 两局的计数口径不一样，靠 Def.Mode 分流，不硬塞一套公式（§11.3）：
    /// Step（Q16）：夹起 1/2 → 放入 2/2，盘外松手退回 0/2；
    /// Count（Q03）：只有放入才计分，夹起不动计数。
    /// </summary>
    public sealed class TweezerBoard : MiniGameBoard
    {
        sealed class ItemView
        {
            public MiniGameTarget Spec;
            public RectTransform Rect;
            public MiniGamePiece Piece;
            public Vector2 Home;
            public bool Inside;
        }

        static readonly Vector2 ItemSize = new Vector2(96f, 72f);

        readonly List<ItemView> _items = new List<ItemView>();
        Rect _dish;
        Vector2 _dishCenter;
        string _dishId;

        RectTransform _tweezer;
        RectTransform _dishRect;
        float _tweezerAngle;
        float _lastPointerX;
        bool _emptyShown;
        float _emptyUntil;

        JudgeMode Mode { get { return Def != null ? Def.Mode : JudgeMode.Discrete; } }

        protected override string FooterText
        {
            get
            {
                return Mode == JudgeMode.Step
                    ? "镊取 ｜ 按住夹起 · 松手放入"
                    : "镊取 ｜ 按住夹起 · 松手放入 · 放入才算";
            }
        }

        protected override void BuildBoard()
        {
            // 观察盘（§11.5）：虚线圆的感觉用低透明度圆角块近似
            if (Content.Slots.Length > 0)
            {
                var dish = Content.Slots[0];
                _dishId = dish.Id;
                _dish = new Rect(dish.Pos.x, -dish.Pos.y - dish.Size.y, dish.Size.x, dish.Size.y);
                _dishCenter = new Vector2(dish.Pos.x + dish.Size.x * 0.5f, -dish.Pos.y - dish.Size.y * 0.5f);

                var plate = MiniGameUIKit.Panel(Body, "Dish", MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.28f), 100f);
                _dishRect = plate;
                MiniGameUIKit.Place(plate, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(dish.Pos.x, dish.Pos.y), dish.Size);
                var hint = MiniGameUIKit.Label(plate, "Hint", 22f, MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.55f));
                MiniGameUIKit.Stretch(hint.rectTransform);
                hint.text = dish.Label;

                AddTarget(new DropTarget
                {
                    Id = dish.Id,
                    Shape = DropShape.Rect,
                    Center = _dishCenter,
                    // 擦到盘边外沿也算放入（§11.5 的宽容）
                    Rect = new Rect(_dish.xMin - 12f, _dish.yMin - 12f, _dish.width + 24f, _dish.height + 24f),
                });
            }

            for (var i = 0; i < Content.Targets.Length; i++)
            {
                var spec = Content.Targets[i];
                var home = BodyPoint(spec.Pos.x, spec.Pos.y);

                var rect = MiniGameUIKit.Panel(Body, "Item_" + spec.Id,
                    MiniGameTheme.Alpha(new Color(0.86f, 0.72f, 0.42f), 1f), 36f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), home, ItemSize);
                var label = MiniGameUIKit.Label(rect, "Text", 18f, MiniGameTheme.Deep);
                MiniGameUIKit.Stretch(label.rectTransform);
                label.text = spec.Label;

                var piece = AddPiece(spec.Id, rect, home, null, 0.04f);
                piece.Handle.MaxTilt = 6f;          // 挂在镊尖上的 ±6° 摆动（§11.4）
                piece.Handle.TiltPerVelocity = 0.05f;
                piece.MinHitSize = 64f;

                _items.Add(new ItemView { Spec = spec, Rect = rect, Piece = piece, Home = home });
                AddRailSlot(spec.Label, i);
            }

            // 镊子：按住才出现，不是常驻光标（§11.4）
            _tweezer = MiniGameUIKit.Node(Body, "Tweezer");
            MiniGameUIKit.Place(_tweezer, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                Vector2.zero, new Vector2(70f, 70f));
            var armL = MiniGameUIKit.Panel(_tweezer, "ArmL", MiniGameTheme.Deep, 4f);
            MiniGameUIKit.Place(armL, new Vector2(0.5f, 0.5f), new Vector2(1f, 0f),
                new Vector2(-2f, 0f), new Vector2(44f, 4f));
            armL.localEulerAngles = new Vector3(0f, 0f, 28f);
            var armR = MiniGameUIKit.Panel(_tweezer, "ArmR", MiniGameTheme.Deep, 4f);
            MiniGameUIKit.Place(armR, new Vector2(0.5f, 0.5f), new Vector2(1f, 1f),
                new Vector2(-2f, 0f), new Vector2(44f, 4f));
            armR.localEulerAngles = new Vector3(0f, 0f, -28f);
            _tweezer.gameObject.SetActive(false);

            Judge.Total = Mode == JudgeMode.Step ? 2 : Mathf.Max(1, _items.Count);
        }

        // ---------------- 手势 ----------------

        protected override void OnCarryBegin(Vector2 local)
        {
            _tweezer.gameObject.SetActive(true);
            _tweezer.anchoredPosition = local;
            _lastPointerX = Input.mousePosition.x;

            // Step 模式：夹起就是 1/2
            if (Mode == JudgeMode.Step) Judge.SetDone(1);
        }

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            if (target == null || handle == null) return false;
            if (target.Id != _dishId) return false;

            var item = FindItem(handle.Id);
            if (item == null) return false;

            // 落入盘心：多件按索引错开，任意放不要求对应位置（§11.5）
            var index = PlacedCount();
            var offset = (index - 1) * 46f;
            var home = _dishCenter + new Vector2(offset, 0f);
            item.Home = home;
            item.Inside = true;
            item.Piece.HomePos = home;
            item.Piece.Placed = true;
            item.Piece.Handle.SyncTo(home);

            if (Mode == JudgeMode.Step) Judge.SetDone(2);
            else Judge.Advance();

            PaintRail(item, true);
            return true;
        }

        protected override void OnReject(DropTarget target, CarryHandle handle)
        {
            // 盘外松手：Step 模式退回 0/2；Count 模式该件作废、不计分（§11.3 / §11.5）
            if (Mode == JudgeMode.Step) Judge.SetDone(0);
            var item = FindItem(handle != null ? handle.Id : null);
            if (item != null)
            {
                item.Inside = false;
                item.Piece.Placed = false;
                PaintRail(item, false);
            }
        }

        protected override void TickBoard(float dt)
        {
            // 镊子跟随指针
            Vector2 local;
            var inside = MiniGameUIKit.TryGetLocalPoint(Body, Input.mousePosition, out local);
            if (inside)
            {
                _tweezer.anchoredPosition = local;
                var dx = Input.mousePosition.x - _lastPointerX;
                _lastPointerX = Input.mousePosition.x;
                var target = Mathf.Clamp(-dx * 0.6f, -6f, 6f);
                _tweezerAngle = Mathf.Lerp(_tweezerAngle, target, 0.2f);
                _tweezer.localEulerAngles = new Vector3(0f, 0f, _tweezerAngle);
            }

            // 空夹：按下那一帧没夹到东西 → 夹子出现 0.15s 后淡出，本次按住不再尝试（§11.4）
            if (Input.GetMouseButtonDown(0) && CarryingPiece == null && inside && !ItemUnder(local))
            {
                _tweezer.gameObject.SetActive(true);
                _tweezer.anchoredPosition = local;
                _emptyShown = true;
                _emptyUntil = Time.unscaledTime + 0.15f;
            }

            if (_emptyShown && Time.unscaledTime >= _emptyUntil && CarryingPiece == null)
            {
                _emptyShown = false;
                _tweezer.gameObject.SetActive(false);
            }

            // 松手后夹子随即消失，直到下一次按下
            if (CarryingPiece == null && !Input.GetMouseButton(0) && !_emptyShown)
                _tweezer.gameObject.SetActive(false);
        }

        bool ItemUnder(Vector2 local)
        {
            for (var i = 0; i < _items.Count; i++)
            {
                var item = _items[i];
                if (item.Piece.Placed) continue;
                if (Vector2.Distance(local, item.Piece.Rect.anchoredPosition) <= 70f) return true;
            }
            return false;
        }

        int PlacedCount()
        {
            var n = 0;
            for (var i = 0; i < _items.Count; i++)
                if (_items[i].Inside) n++;
            return n;
        }

        ItemView FindItem(string id)
        {
            for (var i = 0; i < _items.Count; i++)
                if (_items[i].Piece.Id == id) return _items[i];
            return null;
        }

        void PaintRail(ItemView item, bool done)
        {
            var index = _items.IndexOf(item);
            if (RailSlots == null || index < 0 || index >= RailSlots.childCount) return;
            var label = RailSlots.GetChild(index).GetComponentInChildren<TMP_Text>();
            if (label == null) return;
            label.text = done ? "✓ " + item.Spec.Label : item.Spec.Label;
            label.color = done ? MiniGameTheme.DarkGreen : MiniGameTheme.Grey;
        }

        protected override JudgeResult OnJudge()
        {
            // 能走到这里的落位已经过 OnDrop 校验
            return JudgeResult.Yes(LastHandle != null ? LastHandle.Id : null);
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;

            // 分阶段给：没夹起就点亮目标，夹起了就点亮观察盘（§11.7）
            if (CarryingPiece != null)
            {
                ShowHighlight(_dishRect, MiniGameTheme.Blue, 3f, 10f);
                return;
            }

            for (var i = 0; i < _items.Count; i++)
            {
                if (_items[i].Inside) continue;
                ShowHighlight(_items[i].Rect, MiniGameTheme.Yellow, 3f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            var ids = MagnifierBoard.Csv(progress.MaskBase64).Split(',');
            for (var i = 0; i < ids.Length; i++)
            {
                var item = FindItem(ids[i]);
                if (item == null) continue;
                var index = PlacedCount();
                var home = _dishCenter + new Vector2((index - 1) * 46f, 0f);
                item.Home = home;
                item.Inside = true;
                item.Piece.HomePos = home;
                item.Piece.Placed = true;
                item.Piece.Handle.SyncTo(home);
                PaintRail(item, true);
            }
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var ids = new List<string>();
            for (var i = 0; i < _items.Count; i++)
                if (_items[i].Inside) ids.Add(_items[i].Piece.Id);
            progress.MaskBase64 = MagnifierBoard.Encode(string.Join(",", ids.ToArray()));
            return progress;
        }
    }
}
