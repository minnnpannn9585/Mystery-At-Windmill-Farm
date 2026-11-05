using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T4 观察图拼合（§9）。只有 Q19 一局，但它有两段：拼图 → 选方向。
    ///
    /// 判定比整数：图块与格各带 index，直接比，不做图像相似度（§9.3）。
    /// 错位**允许留存**（评审 J 条），代价是点提示时所有错位格红闪两次把错处指出来。
    /// 正确的块拖到被错位块占着的格子上，错位块自动退回线索集——不做交换动画，
    /// 交换会让玩家分不清哪块进了哪格。
    ///
    /// 三处和别的模板不一样，都是这一局特有的：
    /// ① 图块**住在右栏**（线索集），不是主区。玩家从右栏把块拖进主区的格子里，
    ///    所以起手判定要把右栏也算成合法起点（覆盖 TryPickupPoint / TryBeginCarry），
    ///    抓到手上时把块从右栏挂到主区、并放大到格子尺寸——「抽出来」这个动作要看得见。
    /// ② 主区的格子不再用内容里的坐标，而是按主区尺寸重新排成**铺满**的方阵。
    ///    内容只提供格子数量与顺序（§9.1 的格号），位置由这里算。
    /// ③ 右栏标题是「线索集」不是「已发现」：拼图块是待用素材，不是调查结论。
    /// </summary>
    public sealed class JigsawBoard : MiniGameBoard
    {
        sealed class TileView
        {
            public int Index;
            public RectTransform Rect;
            public MiniGamePiece Piece;
            /// <summary>在线索集里的位置（RailSlots 局部坐标）。</summary>
            public Vector2 RailPos;
            public int Cell = -1;
            public bool Locked;
        }

        sealed class CellView
        {
            public int Index;
            public RectTransform Rect;
            public Vector2 Center;
            public bool Filled;
            public TMP_Text RailLabel;
        }

        /// <summary>格间距。拼图要「块与块之间有缝」，缝同时也是对位不齐的容忍带。</summary>
        const float CellGap = 8f;

        /// <summary>主区四周留白：格子方阵在留白之内取最大。</summary>
        const float BoardPadding = 24f;

        /// <summary>线索集里图块的边长（与格子的正方形比例一致，缩略图不失真）。</summary>
        const float ThumbSide = 84f;

        const int RailColumns = 2;

        readonly List<TileView> _tiles = new List<TileView>();
        readonly List<CellView> _cells = new List<CellView>();
        bool _phase2;
        RectTransform _choiceRoot;

        /// <summary>放入格子后的图块尺寸（= 一个格子的大小，铺满，不留边框）。</summary>
        Vector2 _tileFull = new Vector2(200f, 200f);

        protected override string FooterText { get { return "拼合 ｜ 从线索集拖出图块 · 放进正确位置"; } }

        /// <summary>这一局的右栏装的是待拼的素材，不叫「已发现」。</summary>
        protected override string RailTitle { get { return "线索集"; } }

        /// <summary>
        /// 图块的「家」在右栏，不在主区。基类那条弹回主区坐标的补间会把块送回画外，
        /// 所以关掉它，改在 OnReject 里自己挂回槽位。
        /// </summary>
        protected override bool ReturnHomeOnReject { get { return false; } }

        // ---------------- 构建 ----------------

        protected override void BuildBoard()
        {
            BuildCells();
            BuildTiles();
            Judge.Total = Mathf.Max(1, _cells.Count);
        }

        void BuildCells()
        {
            var n = Content.Slots.Length;
            if (n == 0) return;

            int cols, rows;
            float side;
            FitGrid(n, out cols, out rows, out side);
            _tileFull = new Vector2(side, side);

            var gridW = cols * side + (cols - 1) * CellGap;
            var gridH = rows * side + (rows - 1) * CellGap;
            var ox = (MiniGameTheme.Body.width - gridW) * 0.5f;
            var oy = (MiniGameTheme.Body.height - gridH) * 0.5f;

            for (var i = 0; i < n; i++)
            {
                var spec = Content.Slots[i];
                var col = i % cols;
                var row = i / cols;
                var x = ox + col * (side + CellGap);
                var y = oy + row * (side + CellGap);

                var rect = MiniGameUIKit.Panel(Body, "Cell_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.10f), 6f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0f, 1f),
                    BodyPoint(x, y), new Vector2(side, side));

                var center = BodyPoint(x + side * 0.5f, y + side * 0.5f);
                AddTarget(new DropTarget
                {
                    Id = spec.Id,
                    Shape = DropShape.GridCell,
                    Center = center,
                    Rect = new Rect(x, -y - side, side, side),
                    PredictRatio = 0.35f,
                });

                var mark = MiniGameUIKit.Label(rect, "Num", 24f, MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.28f));
                MiniGameUIKit.Stretch(mark.rectTransform);
                mark.text = (i + 1).ToString();

                // 右栏槽：块拿走后这里显示线索名，放对了打钩
                var slot = AddRailSlot(spec.Label, i, RailColumns);
                var railLabel = slot != null ? slot.Find("Label") : null;
                var railText = railLabel != null ? railLabel.GetComponent<TMP_Text>() : null;

                // 槽里上半部分要让给图块，线索名压到槽底那一条
                if (railLabel != null)
                {
                    var slotSize = RailSlotSize(RailColumns);
                    if (railText != null) railText.fontSize = 17f;
                    MiniGameUIKit.Place((RectTransform)railLabel, new Vector2(0f, 0f), new Vector2(0f, 0f),
                        new Vector2(6f, 2f), new Vector2(slotSize.x - 10f, 22f));
                }

                _cells.Add(new CellView
                {
                    Index = i,
                    Rect = rect,
                    Center = center,
                    RailLabel = railText,
                });
            }
        }

        /// <summary>
        /// 在主区里找一个「格子尽量大、且是正方形」的行列组合。
        /// 正方形是硬要求：拼图块的真实素材是照片，非正方格子会把照片压扁，
        /// 而线索集里的缩略图是按同一比例缩的，压扁就对不上。
        /// </summary>
        void FitGrid(int n, out int cols, out int rows, out float side)
        {
            var w = MiniGameTheme.Body.width - BoardPadding * 2f;
            var h = MiniGameTheme.Body.height - BoardPadding * 2f;

            cols = n;
            rows = 1;
            side = 0f;
            var best = float.MinValue;

            for (var c = 1; c <= n; c++)
            {
                var r = (n + c - 1) / c;
                var sx = (w - CellGap * (c - 1)) / c;
                var sy = (h - CellGap * (r - 1)) / r;
                var s = Mathf.Min(sx, sy);
                if (s <= 0f) continue;

                // 空格子要扣分：同样大的情况下，优先能刚好排满的组合
                var score = s - (c * r - n) * 20f;
                if (score <= best) continue;

                best = score;
                cols = c;
                rows = r;
            }

            // best 里混进了扣分项，最后按选中的组合重算一次真实边长
            side = Mathf.Min((w - CellGap * (cols - 1)) / cols,
                (h - CellGap * (rows - 1)) / rows);
            side = Mathf.Max(48f, Mathf.Floor(side));
        }

        void BuildTiles()
        {
            // 块数跟着格子走：一个格子必须正好有一块，少一块这局就拼不完
            var n = _cells.Count;
            if (n == 0) return;

            var slotSize = RailSlotSize(RailColumns);
            var thumb = new Vector2(ThumbSide, ThumbSide);

            for (var i = 0; i < n; i++)
            {
                var topLeft = RailSlotTopLeft(i, RailColumns);
                // 块贴槽顶，槽底留出一条给线索名
                var railPos = new Vector2(topLeft.x + slotSize.x * 0.5f,
                    topLeft.y - 6f - ThumbSide * 0.5f);

                var rect = MiniGameUIKit.Panel(RailSlots, "Tile_" + i, MiniGameTheme.Yellow, 6f, true);
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), railPos, thumb);

                var label = MiniGameUIKit.Label(rect, "Text", 22f, MiniGameTheme.Deep);
                MiniGameUIKit.Stretch(label.rectTransform);
                label.text = i < Content.Labels.Length ? Content.Labels[i] : ("块 " + (i + 1));

                var piece = AddPiece("t" + i, rect, railPos);   // 起手就在槽里
                piece.MinHitSize = 64f;

                _tiles.Add(new TileView
                {
                    Index = i,
                    Rect = rect,
                    Piece = piece,
                    RailPos = railPos,
                });
            }
        }

        // ---------------- 起手：从线索集把块抽出来 ----------------

        /// <summary>指针落在主区或右栏都算合法起点（右栏里才有待拼的块）。</summary>
        protected override bool TryPickupPoint(out Vector2 local)
        {
            return PointerInBodyOrRail(out local);
        }

        /// <summary>拖出过程中同样认右栏，否则指针还在栏里那一段携带物会冻住。</summary>
        protected override bool TryCarryPoint(out Vector2 local)
        {
            return PointerInBodyOrRail(out local);
        }

        /// <summary>
        /// 主区 ∪ 右栏，返回的坐标**一律是 Body 局部**。
        ///
        /// 之前栏内分支直接返回 `RailSlots` 的局部坐标，却被当作主区坐标去钳制——
        /// 栏坐标只有 0~259 × 0~−380，落到主区里就是左上角那一块，
        /// 所以图块一抓起来就跑去了主区角上，要等指针进主区才开始跟手。
        /// </summary>
        bool PointerInBodyOrRail(out Vector2 local)
        {
            if (TryBodyPointer(out local)) return true;

            Vector2 rail;
            if (!MiniGameUIKit.ScreenToLocal(RailSlots, Input.mousePosition, out rail)) return false;
            if (RailSlots == null || !RailSlots.rect.Contains(rail)) return false;
            return MiniGameUIKit.ScreenToLocal(Body, Input.mousePosition, out local);
        }

        protected override bool TryBeginCarry(Vector2 bodyLocal)
        {
            // ① 主区里的块（放错过、还能再拿的）
            for (var i = _tiles.Count - 1; i >= 0; i--)
            {
                var tile = _tiles[i];
                if (tile.Locked || tile.Rect.parent != Body) continue;
                if (!HitTest(tile.Piece, bodyLocal)) continue;
                PickUp(tile, bodyLocal);
                return true;
            }

            // ② 线索集里的块：命中测试要换到右栏坐标系
            Vector2 railLocal;
            if (!MiniGameUIKit.ScreenToLocal(RailSlots, Input.mousePosition, out railLocal)) return false;
            for (var i = _tiles.Count - 1; i >= 0; i--)
            {
                var tile = _tiles[i];
                if (tile.Locked || tile.Rect.parent == Body) continue;
                if (!HitTest(tile.Piece, railLocal)) continue;
                PickUp(tile, bodyLocal);
                return true;
            }
            return false;
        }

        void PickUp(TileView tile, Vector2 bodyLocal)
        {
            tile.Cell = -1;
            tile.Locked = false;
            DragToBody(tile);
            BeginCarry(tile.Piece, bodyLocal);   // 起手点用指针，块会自己滑到手上
        }

        /// <summary>把块从线索集挂到主区，并放大成格子大小——「抽出来」这个动作得看得见。</summary>
        void DragToBody(TileView tile)
        {
            var rect = tile.Rect;
            var world = rect.position;
            rect.SetParent(Body, false);
            rect.anchorMin = rect.anchorMax = new Vector2(0f, 1f);
            rect.pivot = new Vector2(0.5f, 0.5f);
            rect.sizeDelta = _tileFull;
            rect.localScale = Vector3.one;
            rect.position = world;
            tile.Piece.Handle.Area = Body;
            tile.Piece.Handle.SmoothTime = MiniGameMotion.FollowSmoothTimeJigsaw;
            Paint(tile, MiniGameTheme.Yellow);
        }

        /// <summary>挂回线索集的原槽位。</summary>
        void DragToRail(TileView tile)
        {
            var rect = tile.Rect;
            rect.SetParent(RailSlots, false);
            rect.anchorMin = rect.anchorMax = new Vector2(0f, 1f);
            rect.pivot = new Vector2(0.5f, 0.5f);
            rect.sizeDelta = new Vector2(ThumbSide, ThumbSide);
            rect.anchoredPosition = tile.RailPos;
            rect.localScale = Vector3.one;
            rect.localEulerAngles = Vector3.zero;
            Paint(tile, MiniGameTheme.Yellow);
        }

        static void Paint(TileView tile, Color color)
        {
            var image = tile.Rect.GetComponent<Image>();
            if (image != null) image.color = color;
        }

        // ---------------- 落位 ----------------

        protected override bool OnDrop(DropTarget target, CarryHandle handle)
        {
            // 任何格都接受——对不对由 OnJudge 说，这样「错位留存」这条路才走得到
            return target != null && CellIndexOf(target.Id) >= 0;
        }

        protected override JudgeResult OnJudge()
        {
            if (LastTarget == null || LastHandle == null) return JudgeResult.No();

            var cellIndex = CellIndexOf(LastTarget.Id);
            var tile = FindTile(LastHandle.Id);
            if (tile == null || cellIndex < 0) return JudgeResult.No();

            var cell = _cells[cellIndex];
            var correct = tile.Index == cellIndex;

            if (!correct)
            {
                // 「错了也留着」：降饱和 + 橙闪，格边留个空位说明它没归位（§9.3）
                LeaveInCell(tile, cell, false);
                FlashHighlight(tile.Rect, MiniGameTheme.Orange, 2);
                return JudgeResult.No("jigsaw-mismatch");
            }

            // 挤让：正确的块来到被错位块占着的格子 → 错位块退回线索集
            var squatter = TileInCell(cellIndex);
            if (squatter != null && squatter != tile) SendHome(squatter);

            LeaveInCell(tile, cell, true);
            cell.Filled = true;
            var label = cell.Rect.Find("Num");
            if (label != null)
            {
                var text = label.GetComponent<TMP_Text>();
                if (text != null) text.text = "✓";
            }
            if (cell.RailLabel != null)
            {
                cell.RailLabel.text = "✓ " + Content.Slots[cellIndex].Label;
                cell.RailLabel.color = MiniGameTheme.DarkGreen;
            }
            RefreshRailCount();
            return JudgeResult.Yes(LastTarget.Id);
        }

        void LeaveInCell(TileView tile, CellView cell, bool locked)
        {
            tile.Cell = cell.Index;
            tile.Locked = locked;
            tile.Piece.HomePos = cell.Center;
            tile.Piece.Placed = locked;
            tile.Piece.Handle.SyncTo(cell.Center);
            Paint(tile, locked
                ? MiniGameTheme.Alpha(MiniGameTheme.Green, 0.45f)
                : MiniGameTheme.Alpha(MiniGameTheme.Grey, 0.55f));
        }

        void SendHome(TileView tile)
        {
            tile.Cell = -1;
            tile.Locked = false;
            tile.Piece.Placed = false;
            DragToRail(tile);
        }

        /// <summary>
        /// 原地点击（位移不到 8px）不算「拖出来」，块要回线索集。
        /// 不这么做的话，在线索集上点一下会把块抽到主区右边缘挂着，玩家会以为它卡住了。
        /// </summary>
        protected override void OnPieceClick(MiniGamePiece piece)
        {
            if (piece == null) return;
            var tile = FindTile(piece.Id);
            if (tile == null || tile.Locked) return;
            SendHome(tile);
        }

        /// <summary>松手没落到任何格子上：块回线索集，格子空着等下一块。</summary>
        protected override void OnReject(DropTarget target, CarryHandle handle)
        {
            if (handle == null) return;
            var tile = FindTile(handle.Id);
            if (tile == null || tile.Locked) return;
            SendHome(tile);
        }

        TileView TileInCell(int cellIndex)
        {
            for (var i = 0; i < _tiles.Count; i++)
                if (_tiles[i].Cell == cellIndex) return _tiles[i];
            return null;
        }

        int CellIndexOf(string id)
        {
            for (var i = 0; i < _cells.Count; i++)
                if (Content.Slots[i].Id == id) return i;
            return -1;
        }

        TileView FindTile(string id)
        {
            if (string.IsNullOrEmpty(id)) return null;
            for (var i = 0; i < _tiles.Count; i++)
                if (_tiles[i].Piece.Id == id) return _tiles[i];
            return null;
        }

        // ---------------- 第二阶段：方向选择 ----------------

        protected override void OnJudgeCompleted(JudgeStep step)
        {
            if (IsFinished) return;
            if (_phase2)
            {
                MarkComplete();
                return;
            }
            StartCoroutine(PhaseTwoRoutine());
        }

        System.Collections.IEnumerator PhaseTwoRoutine()
        {
            // 停一拍，让玩家看清自己拼出来的东西（§9.4：这一拍必须留）
            var t = 0f;
            while (t < 0.5f)
            {
                t += Time.unscaledDeltaTime;
                yield return null;
            }

            BuildChoice();
            _phase2 = true;
        }

        void BuildChoice()
        {
            _choiceRoot = MiniGameUIKit.Node(Root, "Choice");
            MiniGameUIKit.Stretch(_choiceRoot);

            var scrim = MiniGameUIKit.Panel(_choiceRoot, "Scrim", MiniGameTheme.Alpha(MiniGameTheme.Cream, 0.82f), 0f);
            MiniGameUIKit.Stretch(scrim);

            var ask = MiniGameUIKit.Label(_choiceRoot, "Ask", 30f, MiniGameTheme.Deep);
            MiniGameUIKit.Place(ask.rectTransform, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                new Vector2(0f, 150f), new Vector2(900f, 48f));
            ask.text = "脚印朝哪边走？";

            MakeCard("往鸡舍", -180f, true);
            MakeCard("往红顶屋", 180f, false);
        }

        void MakeCard(string caption, float x, bool correct)
        {
            var card = MiniGameUIKit.Btn(_choiceRoot, "Dir_" + caption, caption,
                MiniGameTheme.Cream, MiniGameTheme.Deep, 26f, 14f);
            MiniGameUIKit.Place((RectTransform)card.transform, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                new Vector2(x, 20f), new Vector2(300f, 140f));
            card.onClick.AddListener(() =>
            {
                if (correct)
                {
                    if (_choiceRoot != null) _choiceRoot.gameObject.SetActive(false);
                    MarkComplete();
                }
                else
                {
                    FlashHighlight((RectTransform)card.transform, MiniGameTheme.Orange, 2);
                }
            });
        }

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;

            // 所有错位格红闪 2 次（§9.3 的「留存的代价与补偿」）
            for (var i = 0; i < _tiles.Count; i++)
            {
                var tile = _tiles[i];
                if (tile.Cell < 0 || tile.Locked) continue;
                FlashHighlight(_cells[tile.Cell].Rect, MiniGameTheme.Orange, 2);
            }

            // 再点亮一块未归位的图 + 它该去的格
            for (var i = 0; i < _tiles.Count; i++)
            {
                if (_tiles[i].Locked) continue;
                ShowHighlight(_tiles[i].Rect, MiniGameTheme.Yellow, 3f);
                ShowHighlight(_cells[_tiles[i].Index].Rect, MiniGameTheme.Blue, 3f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            // "0>0,1>2|1" —— 前半段是「块>格」，后半段是第二阶段是否已过
            var raw = MagnifierBoard.Csv(progress.MaskBase64);
            var parts = raw.Split('|');
            if (parts.Length > 0 && parts[0].Length > 0)
            {
                var pairs = parts[0].Split(',');
                for (var i = 0; i < pairs.Length; i++)
                {
                    var kv = pairs[i].Split('>');
                    if (kv.Length != 2) continue;
                    int tileIndex, cellIndex;
                    if (!int.TryParse(kv[0], out tileIndex) || !int.TryParse(kv[1], out cellIndex)) continue;
                    if (tileIndex < 0 || tileIndex >= _tiles.Count) continue;
                    if (cellIndex < 0 || cellIndex >= _cells.Count) continue;

                    var tile = _tiles[tileIndex];
                    var cell = _cells[cellIndex];
                    if (tile.Rect.parent != Body) DragToBody(tile);   // 从线索集挪进主区
                    LeaveInCell(tile, cell, tile.Index == cellIndex);
                    if (tile.Locked) cell.Filled = true;
                }
            }
            if (parts.Length > 1 && parts[1] == "1")
            {
                _phase2 = true;
                MarkComplete();
            }
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var pairs = new List<string>();
            for (var i = 0; i < _tiles.Count; i++)
            {
                var tile = _tiles[i];
                if (tile.Cell >= 0) pairs.Add(tile.Index + ">" + tile.Cell);
            }
            progress.MaskBase64 = MagnifierBoard.Encode(
                string.Join(",", pairs.ToArray()) + "|" + (_phase2 ? "1" : "0"));
            return progress;
        }
    }
}
