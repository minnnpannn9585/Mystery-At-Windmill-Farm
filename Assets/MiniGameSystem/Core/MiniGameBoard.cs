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
        /// <summary>本次拖拽开始前的真实位置。拒绝落位时回到这里——「回到没拖之前」的语义。</summary>
        public Vector2 DragOrigin;
        public DropTarget Home;
        public bool Placed;
        /// <summary>拒绝回位动画期间为 true：不接受起手，避免新拖拽与回位补间抢同一个 rect。</summary>
        public bool Returning;

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
        MiniGameReplay _replay;

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
        /// 「落进了某个目标、但判定被拒」时，物件要不要回位。
        /// 注意：丢在空白处（hit == null）一律就地留下、不回原位——玩家要像在桌上摆线索那样
        /// 把组件放到屏幕任意一处，这条路径不受本开关影响（2026-11-24 用户口径）。
        /// T1 的镜片、T4 的图块即使落进目标被拒也不回位，弹回去玩家根本点不到它。
        /// </summary>
        protected virtual bool ReturnHomeOnReject { get { return true; } }

        /// <summary>拒绝落位时用「渐入回位」代替弹性回位。T7 错误卡专用（柔和、不弹跳）。</summary>
        protected virtual bool RejectUsesFade { get { return false; } }

        /// <summary>
        /// 拒绝回位前的延迟秒数。默认 0（立即回位）。
        /// T7 设为闪烁时长，保证「闪烁播完 → 才回位」的严格顺序。
        /// </summary>
        protected virtual float RejectReturnDelay { get { return 0f; } }

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
            // ============ M3 骨架层：组件 PNG 原稿 ============
            // 三层纸 + 回形针 + X 都是 1920×1080 透明图，1:1 贴满画布即还原 UI 标准。
            // 纸背板按模板染成七色便签；纸面盖在背板上，露出右侧便签条与投影。
            var template = Def != null ? Def.Template : MiniGameTemplate.Debug;
            MiniGameUIKit.SpriteArt(Root, "PaperStack", MiniGameTheme.ArtPaperStack, Color.white);
            // 七色便签纸逐色预染成 PNG，不做 color 乘算（乘算会把青绿/蓝压暗失真）
            MiniGameUIKit.SpriteArt(Root, "PaperBack", MiniGameTheme.ArtPaperBack(template), Color.white);
            MiniGameUIKit.SpriteArt(Root, "PaperFace", MiniGameTheme.ArtPaperFace, Color.white);
            MiniGameUIKit.SpriteArt(Root, "PaperClip", MiniGameTheme.ArtPaperClip, Color.white);

            // X 关闭：PNG 图形 + 透明热区（热区略大于图形，保证点得到）
            MiniGameUIKit.SpriteArt(Root, "CloseXArt", MiniGameTheme.ArtCloseX, Color.white);
            var closeGo = new GameObject("CloseX", typeof(RectTransform), typeof(CanvasRenderer),
                typeof(Image), typeof(Button));
            closeGo.transform.SetParent(Root, false);
            var closeImg = closeGo.GetComponent<Image>();
            closeImg.color = new Color(1f, 1f, 1f, 0f);   // 透明：只做热区，图形由 CloseXArt 显示
            closeImg.raycastTarget = true;
            var closeBtn = closeGo.GetComponent<Button>();
            closeBtn.targetGraphic = closeImg;
            closeBtn.navigation = new Navigation { mode = Navigation.Mode.None };
            MiniGameUIKit.PlaceArt((RectTransform)closeGo.transform, MiniGameLayout.CloseXArea);
            closeBtn.onClick.AddListener(RequestExit);

            // ============ 标题行 / 提示行：项目字体 + 任务线文案 ============
            // 文字层无底板（纸面由 PNG 提供），墨蓝左对齐，坐标按 §2.2 纸面口径。
            // MiniGameUIKit.Label 用 MiniGameTheme.Font = 项目已装 MiSans（TMP）。
            _titleLabel = MiniGameUIKit.Label(Root, "TitleRow", 30f, MiniGameTheme.Deep, TextAlignmentOptions.Left);
            MiniGameUIKit.PlaceArt(_titleLabel.rectTransform, MiniGameLayout.TitleRow);
            _titleLabel.text = Def != null && !string.IsNullOrEmpty(Def.Objective) ? Def.Objective :
                               (Def != null ? Def.Title : "");

            // 提示行 = 任务线一级提示（§12.6.1 照搬原文），底栏只作承载、不再画 Cream 底板。
            // FooterText 是模板的操作说明，接在提示行前面，保持各模板的可用性。
            FooterRoot = MiniGameUIKit.Node(Root, "Footer");
            MiniGameUIKit.PlaceArt(FooterRoot, MiniGameLayout.FooterArea);
            FooterLabel = MiniGameUIKit.Label(FooterRoot, "Text", 22f, MiniGameTheme.Deep, TextAlignmentOptions.Left);
            FooterLabel.enableWordWrapping = true;
            FooterLabel.overflowMode = TextOverflowModes.Overflow;
            var footerRect = FooterLabel.rectTransform;
            footerRect.anchorMin = Vector2.zero;
            footerRect.anchorMax = Vector2.one;
            footerRect.offsetMin = new Vector2(12f, 10f);
            footerRect.offsetMax = new Vector2(-12f, -10f);
            // 底栏开局只显示模板操作说明，不显示提示文字。
            // 提示必须玩家点「提示」按钮后才出现（ShowHint 里再拼进去），
            // 不能在建骨架时就写死一级提示——那样等于没点就泄露了第一段提示。
            FooterLabel.text = FooterText;

            // ============ 交互层：坐标保持旧口径，等 M3 逐项换算内容 ============
            _objectiveLabel = MiniGameUIKit.Label(Root, "ObjectiveLegacy", 1f, MiniGameTheme.Deep);
            _objectiveLabel.gameObject.SetActive(false);   // 保留字段兼容，不再显示

            // 主操作区。裁剪 + 统一的指针坐标系（所有落点都是它的局部坐标）
            Body = MiniGameUIKit.Node(Root, "Body");
            // 逻辑尺寸仍是旧 Body（1285×637，各 Board 的坐标不用改），
            // 但整块等比缩放 + 平移到纸面插图安全区，内容再也不会溢出纸外。
            MiniGameUIKit.PlaceArtFit(Body, MiniGameTheme.Body, MiniGameLayout.BodyArea);
            // 不启用 RectMask2D：玩家要能把卡片/镜片等拖到屏幕任意位置，像在桌面上摆线索。
            // 之前开启它会把移出 Body 的组件裁掉（表现为「拖到边缘被切一半」）。
            var bodyBg = MiniGameUIKit.Panel(Body, "BodyBg", new Color(1f, 1f, 1f, 0.02f), 0f);
            MiniGameUIKit.Stretch(bodyBg);

            // 主区底图（概念图/正式图）：Content.BackgroundResource 有值就铺一张，
            // 层级在物件之下（BuildBoard 之后建的物件天然盖在它上面）。资源缺失静默跳过。
            if (Content != null && !string.IsNullOrEmpty(Content.BackgroundResource) &&
                Resources.Load<Sprite>(Content.BackgroundResource) != null)
            {
                var bgArt = MiniGameUIKit.SpriteArt(Body, "BodyBackdrop", Content.BackgroundResource, Color.white);
                MiniGameUIKit.Stretch(bgArt);
                bgArt.SetAsFirstSibling();   // 贴在最底，BodyBg 之下也不影响（BodyBg 近乎全透明）
            }

            _hintButton = MiniGameUIKit.Btn(Root, "Hint", "提示 0/2", MiniGameTheme.Yellow, MiniGameTheme.Deep, 20f);
            MiniGameUIKit.PlaceArt((RectTransform)_hintButton.transform, MiniGameLayout.HintButtonArea);
            _hintLabel = _hintButton.GetComponentInChildren<TMP_Text>();
            _hintButton.onClick.AddListener(() => ShowHint(_hintLevel + 1));

            // 提示按钮左侧灯泡图标（美术文档 G-20b）：用概念图 HintBulb_G20B，
            // 资源缺失时静默跳过、按钮只剩文字（不阻塞）。
            if (Resources.Load<Sprite>("MiniGameArt/HintBulb_G20B") != null)
            {
                var bulb = MiniGameUIKit.SpriteArt(_hintButton.transform, "HintBulb",
                    "MiniGameArt/HintBulb_G20B", Color.white);
                MiniGameUIKit.Place(bulb, new Vector2(0f, 0.5f), new Vector2(0.5f, 0.5f),
                    new Vector2(28f, 0f), new Vector2(40f, 40f));
                // 文字右移给灯泡腾位
                if (_hintLabel != null)
                {
                    var lr = _hintLabel.rectTransform;
                    lr.offsetMin = new Vector2(50f, lr.offsetMin.y);
                    _hintLabel.alignment = TextAlignmentOptions.Left;
                }
            }

            // ============ T7 重听（§12.6）：只有配了 ReplayModule 的证词局才有 ============
            // 按钮放在底栏右端、提示按钮左边，避开底栏文字；不改 UI 规格常量。
            var replayModule = Content != null ? Content.ReplayModule : null;
            if (!string.IsNullOrEmpty(replayModule))
            {
                var replayBtn = MiniGameUIKit.Btn(Root, "Replay", "重听", MiniGameTheme.NoteColor(
                    Def != null ? Def.Template : MiniGameTemplate.Testimony), MiniGameTheme.Cream, 18f);
                var hintArt = MiniGameLayout.HintButtonArea;
                MiniGameUIKit.PlaceArt((RectTransform)replayBtn.transform,
                    new Rect(hintArt.x - 116f, hintArt.y, 104f, hintArt.height));
                _replay = new MiniGameReplay(Root);
                var module = replayModule;
                var tag = Content.ReplayTag;
                replayBtn.onClick.AddListener(() => _replay.Open(module, tag));
            }

            BuildConfirm();
            BuildBanner();
        }

        void BuildRail()
        {
            if (!HasRail) return;
            // M3 骨架：便签内卡半透明白，透出底下的七色纸背板。
            //
            // 之前用 PlaceArtFit 把旧 RightRail（307×518）等比塞进细长便签区（144×544），
            // 按宽度缩放只有 0.47 倍 => 高度缩到 243，内卡只占便签上半截、下面露出一大条粉色。
            // 现在逻辑尺寸直接等于便签内接矩形，localScale=1，铺满整条便签。
            //
            // 便签内卡改成上宽下窄的梯形（P5 不规则 UI），不再用白色矩形——
            // 白色太跳会盖掉便签本来的样子。改用当前模板便签色向墨色压暗的同色深版，
            // 既和便签一体、又在深底上托得住浅色文字。
            var noteDeep = MiniGameTheme.NoteDeep(Def != null ? Def.Template : MiniGameTemplate.Debug);
            Rail = MiniGameUIKit.TrapezoidPanel(Root, "Rail", noteDeep, 0f, RailSlopeInset);
            MiniGameUIKit.PlaceArt(Rail, MiniGameLayout.RailArea);

            var title = MiniGameUIKit.Label(Rail, "RailTitle", 17f, MiniGameTheme.NoteInk, TextAlignmentOptions.Left);
            MiniGameUIKit.Place(title.rectTransform, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(10f, -8f), new Vector2(124f, 28f));
            title.text = RailTitle;

            RailSlots = MiniGameUIKit.Node(Rail, "Slots");
            MiniGameUIKit.Place(RailSlots, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(10f, -52f), new Vector2(RailInnerWidth, RailSlotsHeight));

            RailCount = MiniGameUIKit.Label(Rail, "RailCount", 20f, MiniGameTheme.NoteInk);
            MiniGameUIKit.Place(RailCount.rectTransform, new Vector2(0.5f, 0f), new Vector2(0.5f, 0f),
                new Vector2(0f, 10f), new Vector2(124f, 32f));
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
                    // 可移到屏幕任意处：不再把携带物 clamp 在 Body 内（桌面摆线索的手感）。
                    ClampToArea = false,
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
        // 便签内卡铺满后是 144 宽 × 544 高，RailSlots 内区 124×440，单行槽按窄栏重排。
        protected const float RailInnerWidth = 124f;
        protected const float RailGap = 6f;
        protected const float RailRowHeight = 106f;
        protected const float RailSlotHeight = 100f;
        /// <summary>外层 Rail 的右斜边内收比例。内部 widget 只按行收宽，不各自切成梯形。</summary>
        protected const float RailSlopeInset = 0.12f;
        /// <summary>RailSlots 内区高度，用于把行号映射成斜边内收比例。</summary>
        protected const float RailSlotsHeight = 440f;

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
        protected RectTransform AddRailSlot(string label, int index, int columns = 1,
            bool hiddenUntilFound = false)
        {
            if (RailSlots == null) return null;

            columns = Mathf.Max(1, columns);
            var baseSize = RailSlotSize(columns);

            // 用户口径：按钮本身不做成单个梯形。外层 Rail 已经是整块上宽下窄的梯形，
            // 内部 widget 保持矩形，只让「每一行的右边界」跟着外层斜边收窄。
            // 这样整片槽位凑在一起看是同一条斜边，而不是一堆各自斜切的小块。
            var row = Mathf.Max(0, index / columns);
            var rowTop = row * RailRowHeight;
            var slope = 1f - RailSlopeInset * Mathf.Clamp01(rowTop / RailSlotsHeight);
            var size = new Vector2(baseSize.x * slope, baseSize.y);

            // 底色取便签主色向纸白提亮一档，比深内卡浅、但仍是同色系。
            var noteSoft = Color.Lerp(
                MiniGameTheme.NoteColor(Def != null ? Def.Template : MiniGameTemplate.Debug),
                MiniGameTheme.Cream, 0.42f);
            var slot = MiniGameUIKit.Panel(RailSlots, "Slot" + index, noteSoft, 4f);
            MiniGameUIKit.Place(slot, new Vector2(0f, 1f), new Vector2(0f, 1f),
                RailSlotTopLeft(index, columns), size);

            // 便签内卡只有 124 宽，两列时单槽约 59：字号与留白跟着缩，别再溢出槽外。
            var text = MiniGameUIKit.Label(slot, "Label", 15f, MiniGameTheme.Deep, TextAlignmentOptions.Left);
            MiniGameUIKit.Place(text.rectTransform, new Vector2(0f, 0.5f), new Vector2(0f, 0.5f),
                new Vector2(7f, 0f), new Vector2(size.x - 10f, 32f));
            text.text = label;

            // 已发现线索槽：开局隐藏，玩家发现对应线索后才渐显（用户口径）。
            // T4 线索集/ T7 槽位是操作元素、不隐藏（调用方不传 hiddenUntilFound）。
            if (hiddenUntilFound)
            {
                var group = slot.gameObject.AddComponent<CanvasGroup>();
                group.alpha = 0f;
                group.interactable = false;
                group.blocksRaycasts = false;
            }
            return slot;
        }

        /// <summary>发现线索后渐显对应的右栏槽（底+字一起）。重复调用不叠加。</summary>
        protected void RevealRail(RectTransform slot)
        {
            if (slot == null) return;
            var group = slot.GetComponent<CanvasGroup>();
            if (group == null || group.alpha >= 1f || RevealingRails.Contains(slot)) return;
            StartCoroutine(RevealRailRoutine(slot, group));
        }

        readonly HashSet<RectTransform> RevealingRails = new HashSet<RectTransform>();

        System.Collections.IEnumerator RevealRailRoutine(RectTransform slot, CanvasGroup group)
        {
            RevealingRails.Add(slot);
            const float duration = 0.45f;
            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                group.alpha = Mathf.Clamp01(t / duration);
                yield return null;
            }
            group.alpha = 1f;
            RevealingRails.Remove(slot);
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
            int times = MiniGameMotion.HighlightFlashesOnReject, bool restoreOnEnd = true)
        {
            if (target == null) return;
            // 每次单独一个实例：T4 点提示时要同时点亮全部错位格（评审 J 条）
            NewHighlight("Flash").Flash(target, color, times, restoreOnEnd: restoreOnEnd);
        }

        /// <summary>
        /// 错误落位后的「渐入回位」：边淡出边平滑滑回原位，到位后恢复不透明。
        /// 与 ReturnHome 的弹性回位不同——错误反馈要柔和，不能弹跳（T7 反馈第 3 点）。
        /// </summary>
        readonly Dictionary<string, Coroutine> _fadeReturns = new Dictionary<string, Coroutine>();
        readonly Dictionary<string, Coroutine> _rejectDelays = new Dictionary<string, Coroutine>();

        /// <summary>
        /// 确定性的拒绝回位：锁定该件 → 回到本次拖拽前的真实位置（DragOrigin）→ 同步 Handle 内部坐标 → 解锁。
        /// 供子类在「闪烁播完」之后调用，保证顺序是「先闪后回」，且回位途中不接受新的起手。
        /// </summary>
        protected void ReturnHomeFade(MiniGamePiece piece)
        {
            if (piece == null || piece.Rect == null) return;
            // 按 piece 停：连续拖错同一张卡时，前一条回位还在跑就先停掉，
            // 但不要影响别的卡的回位动画。
            Coroutine prev;
            if (_fadeReturns.TryGetValue(piece.Id, out prev) && prev != null) StopCoroutine(prev);
            _fadeReturns[piece.Id] = StartCoroutine(ReturnHomeFadeRoutine(piece));
        }

        /// <summary>
        /// 拒绝回位的统一入口：从松手那一刻就锁定该件，等闪烁播完，再交给 ReturnHomeFade 做确定性回位。
        /// 同一件连续出错时先停掉旧协程，避免两条补间抢同一个 rect。
        /// </summary>
        IEnumerator DelayedRejectReturn(MiniGamePiece piece)
        {
            piece.Returning = true;
            if (RejectReturnDelay > 0f)
                yield return new WaitForSecondsRealtime(RejectReturnDelay);

            _rejectDelays.Remove(piece.Id);
            // 回位目标在松手瞬间已定；这里无条件交给 ReturnHomeFade（内部解锁）。
            ReturnHomeFade(piece);
        }

        IEnumerator ReturnHomeFadeRoutine(MiniGamePiece piece)
        {
            // src 不能是 Rect 当前位置：闪烁期间若发生任何位移，from 会被污染。
            // 用 CarryHandle 的未旋转中心作为「松手处的真实位置」。
            var from = piece.Handle != null ? piece.Handle.LocalPosition : piece.Rect.anchoredPosition;
            // 终点固定为「这次拖拽开始前」的位置，不能用 HomePos（成功吸附时被改写过）。
            var to = piece.DragOrigin;

            piece.Returning = true;                       // 回位期间不接受起手，杜绝与下一拖拽打架

            var group = piece.Rect.GetComponent<CanvasGroup>();
            if (group == null) group = piece.Rect.gameObject.AddComponent<CanvasGroup>();
            group.alpha = 1f;
            piece.Rect.anchoredPosition = from;

            var dur = MiniGameMotion.ReturnDuration;
            for (var t = 0f; t < dur; t += Time.unscaledDeltaTime)
            {
                var k = Mathf.Clamp01(t / dur);
                var e = k * k * (3f - 2f * k);            // smoothstep：无过冲
                var pos = Vector2.Lerp(from, to, e);
                piece.Rect.anchoredPosition = pos;
                if (piece.Handle != null) piece.Handle.SyncTo(pos);   // 内部坐标同步，防止下次起手跳变
                group.alpha = Mathf.Lerp(1f, 0.35f, Mathf.Sin(k * Mathf.PI));
                yield return null;
            }

            // 强制钉死到终点：协程被时间切片截断时也不会停在槽位半路。
            piece.Rect.anchoredPosition = to;
            if (piece.Handle != null) piece.Handle.SyncTo(to);
            group.alpha = 1f;
            piece.HomePos = to;                            // 下次的默认家也回到起手处
            piece.Returning = false;
            _fadeReturns.Remove(piece.Id);
            SpringReturn.ScaleTo(this, piece.Rect, MiniGameMotion.PickScale, 1f,
                MiniGameMotion.PickDuration);
        }

        /// <summary>闪烁时长：period × (次数 × 2 次明暗)。与 TargetHighlight.Flash 保持一致。</summary>
        protected const float RejectFlashPeriod = 0.24f;
        protected static float RejectFlashDuration(int times)
        {
            return RejectFlashPeriod * Mathf.Max(1, times) * 2f;
        }

        protected void HideHighlight()
        {
            if (_activeHighlight != null) _activeHighlight.Hide();
        }

        protected TargetHighlight NewHighlight(string name = "Highlight")
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
                if (_replay != null && _replay.IsOpen) _replay.Close();
                else if (_confirm != null && _confirm.gameObject.activeSelf) CloseConfirm();
                else RequestExit();
                return;
            }
            if (_confirm != null && _confirm.gameObject.activeSelf) return;
            // 重听浮层打开时不吃主区输入：这是一份阅读记录，不是可操作状态。
            if (_replay != null && _replay.IsOpen) return;

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
            // 携带中只换算坐标，不再要求指针留在 Body 内；纸外、屏幕边缘都继续跟手。
            var hasLocal = TryCarryPoint(out local);

            if (_carryPiece != null && _carryPiece.Handle.Active)
            {
                Phase = InteractionPhase.Carry;
                if (hasLocal) _carryPiece.Handle.MoveTo(local, Time.unscaledDeltaTime);
                if (!_carryPiece.Handle.RequirePress || !Input.GetMouseButton(0))
                    ReleaseCarry(hasLocal ? (Vector2?)local : null);
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
        /// 携带中的跟手坐标换算。返回坐标一律是 Body 局部。
        /// 用户口径（2026-11-24）：所有可拖组件都能移到屏幕任意一处，像在桌上摆线索。
        /// 所以这里**不做 Rect.Contains 判定**——旧版 TryBodyPointer 一旦指针离开 Body
        /// 就返回 false，卡片会冻在纸边，表现为「拖不出主范围 / 到边缘被切住」。
        /// 起手判定仍走 TryPickupPoint（必须点在组件上），那是另一回事。
        /// </summary>
        protected virtual bool TryCarryPoint(out Vector2 local)
        {
            return MiniGameUIKit.ScreenToLocal(Body, Input.mousePosition, out local);
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
                if (piece.Returning) continue;     // 错误回位动画中，别让新拖拽把它从半路又抓走
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
            // 记下「拖拽前」的位置。拒绝落位必须回这里，不能用 HomePos——
            // HomePos 在成功吸附到槽后会被改写成槽位，拿起来再放错就回不到发牌位了。
            piece.DragOrigin = piece.Rect != null ? piece.Rect.anchoredPosition : piece.HomePos;
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
            // 用户口径（2026-11-24）：丢在空白处 = 把线索摆在桌上任意位置，就地留下、不回原位。
            // 只有「落进了槽位/目标，但判定被拒」才按模板规则回位（T7 即闪红后回拖拽前位置）。
            // 因此这里第一步先看 hit 是否为 null，null 直接就地留下，不再进入任何回位代码路径。
            if (hit != null && ReturnHomeOnReject)
            {
                if (RejectReturnDelay > 0f || RejectUsesFade)
                {
                    Coroutine oldDelay;
                    if (_rejectDelays.TryGetValue(piece.Id, out oldDelay) && oldDelay != null)
                        StopCoroutine(oldDelay);
                    _rejectDelays[piece.Id] = StartCoroutine(DelayedRejectReturn(piece));
                }
                else
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
            // 与 ReturnHomeFade 同语义：回本次拖拽前的真实位置。
            SpringReturn.MoveTo(this, piece.Rect, piece.Rect.anchoredPosition, piece.DragOrigin,
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

            // 底栏的提示文字只在点按钮后出现，且**两级共用同一段一级提示**：
            // Row(id,2)（二级文本）是写给开发看的动作说明（「先出现转动箭头，再高亮…」），
            // 不是给玩家的文案——二级点击只改按钮计数并触发 ApplyHint 视觉动作，不改文字。
            var displayText = Def.Hint(1);
            if (FooterLabel != null && !string.IsNullOrEmpty(displayText))
                FooterLabel.text = string.IsNullOrEmpty(FooterText) ? displayText : (FooterText + "　｜　" + displayText);

            var actionText = Def.Hint(_hintLevel);
            ApplyHint(_hintLevel, actionText);
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
