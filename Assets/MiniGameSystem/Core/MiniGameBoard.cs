using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 局级状态机。严格照 §4.4 的「通用状态机」表：Enter → Play → Feedback → Complete → Exit。
    /// 表里给了进入条件与出口，这五个就是全部。
    /// </summary>
    public enum MiniGameState
    {
        Enter,      // 入场动画 0.45 s，不可跳过
        Play,       // 可操作
        Feedback,   // 无效动作，不锁输入，0.3 s 自动回 Play
        Complete,   // 锁定输入，只允许看：横幅 0.6 s → 演出 → Submit
        Exit,       // 写存档 → 关闭 → 回原交互点（不发线索）
    }

    /// <summary>
    /// 一次拖拽的子状态。§18.2.4 那条「Idle → Carry → Settle → Judge」讲的是这一层，
    /// 它发生在 Play 内部，不是局级状态。
    /// </summary>
    public enum InteractionPhase
    {
        Idle,
        Carry,
        Settle,
        Judge,
    }

    /// <summary>一块可拖的东西。T4 的图块、T7 的卡、T2 的草束都是一个 Piece。</summary>
    public sealed class MiniGamePiece
    {
        public string Id;
        public RectTransform Rect;
        public CarryHandle Handle;
        public Vector2 HomePos;
        public DropTarget Home;
        public bool Placed;

        /// <summary>热区补到 64×64（§4.4 交互下限），图形小的时候靠它。</summary>
        public float MinHitSize = 64f;
    }

    /// <summary>
    /// 模板基类。骨架（顶栏 / 目标句 / 主区 / 右栏 / 底栏 / 提示 / 退出确认）在这里建好，
    /// 子类只写主区内容 + 一个判定函数（§15.2 / §18.2.3 / §18.2.4）。
    /// </summary>
    public abstract class MiniGameBoard : MonoBehaviour
    {
        public event Action<MiniGameBoard> OnSubmit;
        public event Action<MiniGameBoard, MiniGameExit> OnExit;

        // ---------------- 数据 ----------------
        protected MiniGameDef Def;
        protected MiniGameContent Content;
        protected JudgeStep Judge;

        // ---------------- 骨架节点 ----------------
        protected RectTransform Root;
        protected RectTransform Body;
        protected RectTransform Rail;
        protected RectTransform RailSlots;
        protected RectTransform FooterRoot;
        protected TMP_Text FooterLabel;
        protected TMP_Text RailCount;

        TMP_Text _titleLabel;
        TMP_Text _objectiveLabel;
        Button _hintButton;
        TMP_Text _hintLabel;
        RectTransform _confirm;
        RectTransform _banner;
        TMP_Text _bannerLabel;
        int _hintLevel;

        // ---------------- 交互 ----------------
        protected readonly List<MiniGamePiece> Pieces = new List<MiniGamePiece>();
        protected readonly List<DropTarget> Targets = new List<DropTarget>();
        readonly List<TargetHighlight> _highlights = new List<TargetHighlight>();

        CarryHandle _carry;
        MiniGamePiece _carryPiece;
        TargetHighlight _activeHighlight;
        Vector2 _pressScreen;
        bool _pressWasInside;

        /// <summary>最近一次落位的目标与携带物，供 OnJudge 读取（OnJudge 本身不带参）。</summary>
        protected DropTarget LastTarget;
        protected CarryHandle LastHandle;

        /// <summary>
        /// 当前正被拖着的物件（没拖东西时为 null）。
        /// T7 拿走卡时要释放槽位容量、T6 的 Step 模式要在夹起时推进度、T2 要判断挪的是哪束草——
        /// 这些都需要「现在拖的是谁」，OnCarryBegin 只给了坐标。
        /// </summary>
        protected MiniGamePiece CarryingPiece { get { return _carryPiece; } }

        public MiniGameState State { get; private set; }
        public InteractionPhase Phase { get; private set; }
        public bool IsFinished { get; private set; }
        public MiniGameDef Definition { get { return Def; } }
        public string DefId { get { return Def != null ? Def.Id : null; } }

        // 子类可覆盖的骨架参数
        protected virtual float CompleteHoldSeconds { get { return MiniGameMotion.CompleteHold; } }
        protected virtual bool HasRail { get { return true; } }

        /// <summary>右栏标题。T4 的右栏放的是待拼的图块，不叫「已发现」而叫「线索集」。</summary>
        protected virtual string RailTitle { get { return "已发现"; } }

        /// <summary>
        /// 落位被拒或丢在空白处时，物件要不要弹回原位。
        /// T1 的镜片必须留在松手的地方——弹回去玩家根本点不到它（§6.3 的跟手是持续的，不是每次归位）。
        /// </summary>
        protected virtual bool ReturnHomeOnReject { get { return true; } }

        protected virtual string FooterText { get { return "拖动 ｜ 按住拖动 · 松手放下 ｜ 提示 1/2"; } }

        // ================= 初始化 =================

        bool _restoring;

        public void Initialize(MiniGameDef def, MiniGameContent content, RectTransform root)
        {
            Def = def;
            Content = content ?? new MiniGameContent();
            Root = root;
            State = MiniGameState.Enter;
            Phase = InteractionPhase.Idle;

            BuildChrome();
            BuildRail();

            var total = Content.SlotCount > 0 ? Content.SlotCount : 1;
            Judge = new JudgeStep(total, JudgeMode.Discrete);
            Judge.Changed += OnJudgeChanged;
            Judge.Completed += OnJudgeCompleted;

            BuildBoard();
            _restoring = true;
            ApplyProgress(MiniGameSave.Get(def != null ? def.Id : null));
            _restoring = false;
            RefreshRailCount();

            StartCoroutine(EnterRoutine());
        }

        /// <summary>模板实现：在 Body 里建自己的东西。</summary>
        protected abstract void BuildBoard();

        /// <summary>模板实现：把存档进度贴回 UI。</summary>
        protected abstract void ApplyProgress(MiniGameProgress progress);

        /// <summary>模板实现：导出当前进度。</summary>
        public abstract MiniGameProgress CaptureProgress();

        // ================= 骨架 =================

        void BuildChrome()
        {
            var top = MiniGameUIKit.Panel(Root, "TopBar", MiniGameTheme.Cream, 0f);
            MiniGameUIKit.PlaceArt(top, MiniGameTheme.TopBar);

            var back = MiniGameUIKit.Btn(top, "Back", "← 返回调查", MiniGameTheme.Cream, MiniGameTheme.Deep, 20f, 10f);
            MiniGameUIKit.Place((RectTransform)back.transform, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(24f, -24f), new Vector2(200f, 48f));
            back.onClick.AddListener(RequestExit);

            _titleLabel = MiniGameUIKit.Label(top, "Title", 30f, MiniGameTheme.Deep);
            MiniGameUIKit.Place(_titleLabel.rectTransform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -22f), new Vector2(900f, 52f));
            _titleLabel.text = Def != null ? Def.Title : "";

            var help = MiniGameUIKit.Label(top, "Help", 20f, MiniGameTheme.Grey);
            MiniGameUIKit.Place(help.rectTransform, new Vector2(1f, 1f), new Vector2(1f, 1f),
                new Vector2(-24f, -32f), new Vector2(200f, 32f));
            help.text = "操作帮助";

            var objective = MiniGameUIKit.Panel(Root, "Objective", MiniGameTheme.Cream);
            MiniGameUIKit.PlaceArt(objective, MiniGameTheme.Objective);
            _objectiveLabel = MiniGameUIKit.Paragraph(objective, "Text", 26f, MiniGameTheme.Deep,
                TextAlignmentOptions.Left);
            var objRect = _objectiveLabel.rectTransform;
            objRect.anchorMin = Vector2.zero;
            objRect.anchorMax = Vector2.one;
            objRect.offsetMin = new Vector2(24f, 12f);
            objRect.offsetMax = new Vector2(-24f, -12f);
            _objectiveLabel.text = Def != null ? Def.Objective : "";

            // 主操作区。裁剪 + 统一的指针坐标系（所有落点都是它的局部坐标）
            Body = MiniGameUIKit.Node(Root, "Body");
            MiniGameUIKit.PlaceArt(Body, MiniGameTheme.Body);
            Body.gameObject.AddComponent<RectMask2D>();
            var bodyBg = MiniGameUIKit.Panel(Body, "BodyBg", new Color(1f, 1f, 1f, 0.02f), 0f);
            MiniGameUIKit.Stretch(bodyBg);

            _hintButton = MiniGameUIKit.Btn(Root, "Hint", "提示 0/2", MiniGameTheme.Yellow, MiniGameTheme.Deep, 20f);
            MiniGameUIKit.PlaceArt((RectTransform)_hintButton.transform, MiniGameTheme.HintButton);
            _hintLabel = _hintButton.GetComponentInChildren<TMP_Text>();
            _hintButton.onClick.AddListener(() => ShowHint(_hintLevel + 1));

            FooterRoot = MiniGameUIKit.Panel(Root, "Footer", MiniGameTheme.Cream, 0f);
            MiniGameUIKit.PlaceArt(FooterRoot, MiniGameTheme.Footer);
            FooterLabel = MiniGameUIKit.Label(FooterRoot, "Text", 22f, MiniGameTheme.Deep, TextAlignmentOptions.Left);
            MiniGameUIKit.Place(FooterLabel.rectTransform, new Vector2(0f, 0.5f), new Vector2(0f, 0.5f),
                new Vector2(24f, 0f), new Vector2(1400f, 40f));
            FooterLabel.text = FooterText;

            BuildConfirm();
            BuildBanner();
        }

        void BuildRail()
        {
            if (!HasRail) return;
            Rail = MiniGameUIKit.Panel(Root, "Rail", MiniGameTheme.Cream);
            MiniGameUIKit.PlaceArt(Rail, MiniGameTheme.RightRail);

            var title = MiniGameUIKit.Label(Rail, "RailTitle", 24f, MiniGameTheme.Deep, TextAlignmentOptions.Left);
            MiniGameUIKit.Place(title.rectTransform, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(24f, -20f), new Vector2(240f, 34f));
            title.text = RailTitle;

            RailSlots = MiniGameUIKit.Node(Rail, "Slots");
            MiniGameUIKit.Place(RailSlots, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(24f, -70f), new Vector2(259f, 380f));

            RailCount = MiniGameUIKit.Label(Rail, "RailCount", 28f, MiniGameTheme.Orange);
            MiniGameUIKit.Place(RailCount.rectTransform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                new Vector2(0f, 22f), new Vector2(200f, 40f));
            RailCount.text = "0 / 0";
        }

        void BuildConfirm()
        {
            _confirm = MiniGameUIKit.Node(Root, "Confirm");
            MiniGameUIKit.Stretch(_confirm);
            MiniGameUIKit.Scrim(_confirm);
            var panel = MiniGameUIKit.Panel(_confirm, "Panel", MiniGameTheme.Cream);
            MiniGameUIKit.Place(panel, Vector2.one * 0.5f, Vector2.one * 0.5f,
                Vector2.zero, new Vector2(560f, 260f));

            var ask = MiniGameUIKit.Label(panel, "Ask", 26f, MiniGameTheme.Deep, TextAlignmentOptions.Top);
            MiniGameUIKit.Place(ask.rectTransform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -40f), new Vector2(480f, 90f));
            ask.text = "本局进度会保留，下次进来接着做。\n要现在退出吗？";

            var stay = MiniGameUIKit.Btn(panel, "Stay", "继续", MiniGameTheme.Yellow, MiniGameTheme.Deep, 22f);
            MiniGameUIKit.Place((RectTransform)stay.transform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                new Vector2(-130f, 40f), new Vector2(220f, 64f));
            stay.onClick.AddListener(CloseConfirm);

            var quit = MiniGameUIKit.Btn(panel, "Quit", "退出本局", MiniGameTheme.Deep, MiniGameTheme.Cream, 22f);
            MiniGameUIKit.Place((RectTransform)quit.transform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                new Vector2(130f, 40f), new Vector2(220f, 64f));
            quit.onClick.AddListener(ConfirmExit);

            _confirm.gameObject.SetActive(false);
        }

        void BuildBanner()
        {
            // §4.4：Complete 要「横幅 0.6 s」，然后才截图 / 演出 / Submit
            _banner = MiniGameUIKit.Node(Root, "Banner");
            MiniGameUIKit.Place(_banner, Vector2.one * 0.5f, Vector2.one * 0.5f,
                Vector2.zero, new Vector2(720f, 120f));
            var bar = MiniGameUIKit.Panel(_banner, "Bar", MiniGameTheme.Deep, 18f);
            MiniGameUIKit.Stretch(bar);
            _bannerLabel = MiniGameUIKit.Label(bar, "Text", 34f, MiniGameTheme.Cream);
            MiniGameUIKit.Stretch(_bannerLabel.rectTransform);
            _bannerLabel.text = "已查清";
            _banner.gameObject.SetActive(false);
        }

        // ================= 模板可用的工具 =================

        /// <summary>把「主区左上为原点、y 向下」的坐标转成 Body 内的局部坐标。</summary>
        protected Vector2 BodyPoint(float x, float y)
        {
            return new Vector2(x, -y);
        }

        /// <summary>注册一块可拖的东西。homePos 用 BodyPoint 给。</summary>
        protected MiniGamePiece AddPiece(string id, RectTransform rect, Vector2 homePos,
            DropTarget home = null, float smoothTime = MiniGameMotion.FollowSmoothTime)
        {
            var piece = new MiniGamePiece
            {
                Id = id,
                Rect = rect,
                HomePos = homePos,
                Home = home,
                Handle = new CarryHandle
                {
                    Id = id,
                    Target = rect,
                    Area = Body,
                    SmoothTime = smoothTime,
                },
            };
            rect.anchoredPosition = homePos;
            Pieces.Add(piece);
            return piece;
        }

        protected DropTarget AddTarget(DropTarget target)
        {
            if (target != null) Targets.Add(target);
            return target;
        }

        // 右栏槽的几何常量。AddRailSlot 和 T4（要把图块摆回槽里）必须共用同一份，
        // 否则两处各算一遍，改一次栏宽就会有一处算错。
        protected const float RailInnerWidth = 259f;
        protected const float RailGap = 8f;
        protected const float RailRowHeight = 118f;
        protected const float RailSlotHeight = 114f;

        /// <summary>第 index 个槽在 RailSlots 里的**左上角**（RailSlots 轴心在左上，故左上即原点）。</summary>
        protected static Vector2 RailSlotTopLeft(int index, int columns)
        {
            columns = Mathf.Max(1, columns);
            var size = RailSlotSize(columns);
            var col = index % columns;
            var row = index / columns;
            return new Vector2(col * (size.x + RailGap), -row * RailRowHeight);
        }

        protected static Vector2 RailSlotSize(int columns)
        {
            columns = Mathf.Max(1, columns);
            var slotW = (RailInnerWidth - RailGap * (columns - 1)) / columns;
            return new Vector2(slotW, RailSlotHeight);
        }

        /// <summary>
        /// 右栏一排一个槽。columns &gt; 1 时按多列排，槽宽自动均分——
        /// T4 有六块待拼图，单列会撑出栏外，两列三行刚好放得下。
        /// </summary>
        protected RectTransform AddRailSlot(string label, int index, int columns = 1)
        {
            if (RailSlots == null) return null;

            columns = Mathf.Max(1, columns);
            var size = RailSlotSize(columns);

            var slot = MiniGameUIKit.Panel(RailSlots, "Slot" + index, new Color(1f, 1f, 1f, 0.45f), 10f);
            MiniGameUIKit.Place(slot, new Vector2(0f, 1f), new Vector2(0f, 1f),
                RailSlotTopLeft(index, columns), size);

            var text = MiniGameUIKit.Label(slot, "Label", 20f, MiniGameTheme.Grey, TextAlignmentOptions.Left);
            MiniGameUIKit.Place(text.rectTransform, new Vector2(0f, 0.5f), new Vector2(0f, 0.5f),
                new Vector2(18f, 0f), new Vector2(size.x - 24f, 40f));
            text.text = label;
            return slot;
        }

        protected void RefreshRailCount()
        {
            if (RailCount != null) RailCount.text = Judge != null ? Judge.Label : "0 / 0";
        }

        protected TargetHighlight ShowHighlight(RectTransform target, Color color, float duration = 3f,
            float margin = 6f)
        {
            if (target == null) return null;
            if (_activeHighlight == null) _activeHighlight = NewHighlight();
            _activeHighlight.Show(target, color, duration, margin);
            return _activeHighlight;
        }

        protected void FlashHighlight(RectTransform target, Color color,
            int times = MiniGameMotion.HighlightFlashesOnReject)
        {
            if (target == null) return;
            // 每次单独一个实例：T4 点提示时要同时点亮全部错位格（评审 J 条）
            NewHighlight("Flash").Flash(target, color, times);
        }

        protected void HideHighlight()
        {
            if (_activeHighlight != null) _activeHighlight.Hide();
        }

        TargetHighlight NewHighlight(string name = "Highlight")
        {
            var hl = TargetHighlight.Create(Root, name);
            _highlights.Add(hl);
            return hl;
        }

        // ================= 局级状态 =================

        IEnumerator EnterRoutine()
        {
            var group = Root.GetComponent<CanvasGroup>();
            if (group == null) group = Root.gameObject.AddComponent<CanvasGroup>();
            group.alpha = 0f;
            var t = 0f;
            const float duration = 0.45f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                group.alpha = Mathf.Clamp01(t / duration);
                yield return null;
            }
            group.alpha = 1f;
            State = MiniGameState.Play;
        }

        void Update()
        {
            if (IsFinished) return;

            if (Input.GetKeyDown(KeyCode.Escape) && State == MiniGameState.Play)
            {
                if (_confirm != null && _confirm.gameObject.activeSelf) CloseConfirm();
                else RequestExit();
                return;
            }
            if (_confirm != null && _confirm.gameObject.activeSelf) return;

            // 输入只在 Play 里响应（Enter / Complete / Exit 都不吃输入），
            // 但模板自己的每帧动画不能跟着停：Feedback 那 0.3s 一停，
            // 揭盖显隐、连续出墨这类补间就会卡住再续上，看起来是一顿（§4.4 Feedback 不锁输入）。
            if (State == MiniGameState.Play) TickPointer();
            TickBoard(Time.unscaledDeltaTime);
        }

        /// <summary>模板每帧的自定义逻辑（T5 的连续出墨、T3 的惯性吸附等）。</summary>
        protected virtual void TickBoard(float dt) { }

        protected bool TryBodyPointer(out Vector2 local)
        {
            return MiniGameUIKit.TryGetLocalPoint(Body, Input.mousePosition, out local);
        }

        void TickPointer()
        {
            Vector2 local;
            var inside = TryBodyPointer(out local);

            if (_carryPiece != null && _carryPiece.Handle.Active)
            {
                Phase = InteractionPhase.Carry;
                if (inside) _carryPiece.Handle.MoveTo(local, Time.unscaledDeltaTime);
                if (!_carryPiece.Handle.RequirePress || !Input.GetMouseButton(0))
                    ReleaseCarry(inside ? (Vector2?)local : null);
                return;
            }

            if (!Input.GetMouseButtonDown(0)) return;
            _pressScreen = Input.mousePosition;

            // 起手点：默认只在主区。T4 的图块住在右栏，要把右栏也算成合法起点。
            Vector2 pick;
            var canPick = TryPickupPoint(out pick);
            _pressWasInside = canPick;
            if (canPick) TryBeginCarry(pick);
        }

        /// <summary>
        /// 起手点判定。默认要求指针落在 Body 内，返回的坐标一律是 Body 局部坐标。
        /// 需要从主区之外起手的模板（T4 从线索集拖出）覆盖它。
        /// </summary>
        protected virtual bool TryPickupPoint(out Vector2 local)
        {
            return TryBodyPointer(out local);
        }

        /// <summary>默认实现：谁在最上面就拖谁。T1 的镜片、T5 的炭条需要覆盖。</summary>
        protected virtual bool TryBeginCarry(Vector2 local)
        {
            for (var i = Pieces.Count - 1; i >= 0; i--)
            {
                var piece = Pieces[i];
                if (piece == null || piece.Rect == null) continue;
                if (piece.Placed) continue;
                if (!HitTest(piece, local)) continue;
                BeginCarry(piece, local);
                return true;
            }
            return false;
        }

        /// <summary>
        /// 「由模板自己决定抓谁」的入口。T4 的图块起手时还在右栏，
        /// 命中测试得用右栏坐标系，所以不能走默认那条按主区坐标比对的循环。
        /// </summary>
        protected void BeginCarry(MiniGamePiece piece, Vector2 local)
        {
            if (piece == null) return;
            piece.Handle.RequirePress = true;
            piece.Handle.Begin(local);
            _carryPiece = piece;
            Phase = InteractionPhase.Carry;
            SpringReturn.ScaleTo(this, piece.Rect, 1f, MiniGameMotion.PickScale,
                MiniGameMotion.PickDuration);
            OnCarryBegin(local);
        }

        /// <summary>热区判定：图形可以小，热区补到 64×64（§4.4）。</summary>
        protected bool HitTest(MiniGamePiece piece, Vector2 localPoint)
        {
            if (piece == null || piece.Rect == null) return false;
            var r = piece.Rect.rect;
            var size = r.size;
            var min = piece.MinHitSize;
            var center = piece.Rect.anchoredPosition;
            if (size.x < min || size.y < min)
            {
                var growX = Mathf.Max(0f, (min - size.x) * 0.5f);
                var growY = Mathf.Max(0f, (min - size.y) * 0.5f);
                r = new Rect(-size.x * 0.5f - growX, -size.y * 0.5f - growY,
                    size.x + growX * 2f, size.y + growY * 2f);
            }
            return r.Contains(localPoint - center);
        }

        /// <summary>松手。位移小于 8px 判为点击（§4.4）；有落点且接受 → OnDrop → OnJudge；否则弹回。</summary>
        protected void ReleaseCarry(Vector2? pointerLocal)
        {
            if (_carryPiece == null) return;
            var piece = _carryPiece;
            var handle = piece.Handle;
            var dropPoint = pointerLocal.HasValue ? pointerLocal.Value : handle.LocalPosition;
            var moved = ((Vector2)Input.mousePosition - _pressScreen).magnitude;

            handle.End();
            _carryPiece = null;

            if (moved < 8f && _pressWasInside)
            {
                Phase = InteractionPhase.Idle;
                SpringReturn.ScaleTo(this, piece.Rect, MiniGameMotion.PickScale, 1f,
                    MiniGameMotion.PickDuration);
                OnPieceClick(piece);
                return;
            }

            Phase = InteractionPhase.Settle;

            DropTarget hit = null;
            for (var i = 0; i < Targets.Count; i++)
            {
                if (Targets[i] != null && Targets[i].Accepts(handle, dropPoint)) { hit = Targets[i]; break; }
            }

            LastTarget = hit;
            LastHandle = handle;

            if (hit != null && OnDrop(hit, handle))
            {
                Phase = InteractionPhase.Judge;
                SpringReturn.ScaleTo(this, piece.Rect, MiniGameMotion.PickScale, 1f,
                    MiniGameMotion.PickDuration);
                var result = OnJudge();
                if (result.Pass) Judge.Advance();
                else EnterFeedback();
                return;
            }

            Phase = InteractionPhase.Idle;
            if (ReturnHomeOnReject)
            {
                ReturnHome(piece);
            }
            else
            {
                // 就地留下：位置保持在松手处，只把「拿起时放大的那一点」收回去。
                SpringReturn.ScaleTo(this, piece.Rect, MiniGameMotion.PickScale, 1f,
                    MiniGameMotion.PickDuration);
                piece.HomePos = piece.Rect.anchoredPosition;   // 下次归位也回这里
            }
            EnterFeedback();
            OnReject(hit, handle);
        }

        protected void ReturnHome(MiniGamePiece piece)
        {
            if (piece == null || piece.Rect == null) return;
            SpringReturn.MoveTo(this, piece.Rect, piece.Rect.anchoredPosition, piece.HomePos,
                MiniGameMotion.ReturnDuration, MiniGameMotion.ReturnOvershoot);
            SpringReturn.ScaleTo(this, piece.Rect, MiniGameMotion.PickScale, 1f,
                MiniGameMotion.PickDuration);
        }

        /// <summary>§4.4：Feedback 不锁输入，0.3 s 后自动回 Play。</summary>
        protected void EnterFeedback()
        {
            if (IsFinished) return;
            State = MiniGameState.Feedback;
            StartCoroutine(FeedbackRoutine());
        }

        IEnumerator FeedbackRoutine()
        {
            var t = 0f;
            while (t < 0.3f)
            {
                t += Time.unscaledDeltaTime;
                yield return null;
            }
            if (State == MiniGameState.Feedback) State = MiniGameState.Play;
        }

        // ================= 四个钩子（§18.2.4 的三个 + 点击） =================

        /// <summary>钩子：拿起。</summary>
        protected virtual void OnCarryBegin(Vector2 local) { }

        /// <summary>钩子：放下。返回 true 表示这次落位被接受（是否记分由 OnJudge 决定）。</summary>
        protected virtual bool OnDrop(DropTarget target, CarryHandle handle) { return false; }

        /// <summary>钩子：落位被拒。默认什么都不做。</summary>
        protected virtual void OnReject(DropTarget target, CarryHandle handle) { }

        /// <summary>钩子：点击（位移 &lt; 8px）。</summary>
        protected virtual void OnPieceClick(MiniGamePiece piece) { }

        /// <summary>钩子：判定。七个模板唯一必须自己实现的（§18.2.4）。</summary>
        protected abstract JudgeResult OnJudge();

        protected virtual void OnJudgeChanged(JudgeStep step)
        {
            RefreshRailCount();
        }

        protected virtual void OnJudgeCompleted(JudgeStep step)
        {
            if (_restoring) return;
            MarkComplete();
        }

        // ================= 完成 / 退出 =================

        protected void MarkComplete()
        {
            if (IsFinished || State == MiniGameState.Complete) return;
            State = MiniGameState.Complete;
            StartCoroutine(CompleteRoutine());
        }

        IEnumerator CompleteRoutine()
        {
            // 模板自己的停顿（T4 合体后 0.5、T5 第三段 0.10、T7 0.15）
            var t = 0f;
            while (t < CompleteHoldSeconds)
            {
                t += Time.unscaledDeltaTime;
                yield return null;
            }

            if (_banner != null)
            {
                _banner.SetAsLastSibling();
                _banner.gameObject.SetActive(true);
            }
            t = 0f;
            while (t < 0.6f)
            {
                t += Time.unscaledDeltaTime;
                yield return null;
            }
            if (_banner != null) _banner.gameObject.SetActive(false);

            RaiseSubmit();
        }

        protected void RaiseSubmit()
        {
            if (IsFinished) return;
            IsFinished = true;
            State = MiniGameState.Exit;
            if (OnSubmit != null) OnSubmit(this);
        }

        public void RequestExit()
        {
            if (IsFinished) return;
            if (_confirm != null) _confirm.gameObject.SetActive(true);
            else ConfirmExit();
        }

        void CloseConfirm()
        {
            if (_confirm != null) _confirm.gameObject.SetActive(false);
        }

        void ConfirmExit()
        {
            if (IsFinished) return;
            IsFinished = true;
            State = MiniGameState.Exit;
            if (OnExit != null) OnExit(this, MiniGameExit.Aborted);
        }

        /// <summary>Host 强制关闭（读档 / 切场景）。</summary>
        public void ForceClose()
        {
            if (IsFinished) return;
            IsFinished = true;
            State = MiniGameState.Exit;
            if (OnExit != null) OnExit(this, MiniGameExit.Forced);
        }

        // ================= 提示 =================

        protected void ShowHint(int level)
        {
            if (Def == null) return;
            _hintLevel = Mathf.Clamp(level, 1, 2);
            if (_hintLabel != null) _hintLabel.text = "提示 " + _hintLevel + "/2";
            var text = Def.Hint(_hintLevel);
            if (string.IsNullOrEmpty(text))
            {
                Debug.Log("[MiniGame] " + Def.Id + " 没有第 " + _hintLevel + " 级提示（M3 补文案）");
                return;
            }
            ApplyHint(_hintLevel, text);
        }

        /// <summary>模板实现：一级给方向，二级标位置（§4.4 交互下限）。</summary>
        protected virtual void ApplyHint(int level, string text)
        {
            Debug.Log("[MiniGame] hint " + level + ": " + text);
        }

        // ================= 进度 =================

        protected void SyncJudgeFromProgress(MiniGameProgress progress)
        {
            if (Judge == null || progress == null) return;
            if (progress.Total > 0) Judge.Total = progress.Total;
            Judge.SetDone(progress.Done);
        }

        protected MiniGameProgress NewProgress()
        {
            return new MiniGameProgress
            {
                DefId = DefId,
                Total = Judge != null ? Judge.Total : 1,
                Done = Judge != null ? Judge.Done : 0,
                InProgress = !IsFinished,
            };
        }
    }
}
