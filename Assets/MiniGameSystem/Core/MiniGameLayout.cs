using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 美术安全区适配（M3 骨架层）。
    ///
    /// 背景：组件 PNG 是 1920×1080 全画布透明图，里面的纸面 / 便签纸是**倾斜手绘件**，
    /// alpha 边界不是规整矩形。旧代码直接把交互区按整数坐标摆上去，结果标题压到 X 上、
    /// 主区溢出纸面、右栏比便签纸还宽。
    ///
    /// 这里的坐标全部由组件 alpha 逐行扫描实测得出（见工作日志 2026-11-24），
    /// 取「保守内接矩形」——矩形内任意点都落在美术实体上，绝不会露出纸外。
    /// CanvasScaler 用 Expand + 1920×1080，逻辑坐标恒定，所以这套值在任何分辨率下都成立。
    /// </summary>
    public static class MiniGameLayout
    {
        // ---------- 组件实测边界（原点左上，y 向下） ----------
        // 纸面.png：x 380..1516；y 140 顶边只到 878（斜角），y 200..800 才是完整宽度
        public const float PaperLeft = 380f;
        public const float PaperRight = 1516f;
        public const float PaperTopFull = 200f;     // 之上是斜角，不放交互
        public const float PaperBottomFull = 800f;  // 之下是斜角/投影

        // 关闭 X：306..452 / 48..216；回形针：1300..1370 / 86..297
        public const float CloseXRight = 452f;
        public const float ClipLeft = 1300f;
        public const float ClipRight = 1370f;
        public const float ClipBottom = 297f;

        // ---------------- 右侧便签四边形（1920×1080 概念图 alpha 实测，2026-11-24 复核） ----------------
        // 便签是「上宽下窄 + 右边向左倾」的斜四边形，不是矩形：
        //   左边 x=1517 垂直；右边 R(y)=1694.0 - 0.0218*y（y=210→1688，y=760→1676）；
        //   上边 y=205，下边 y=765。顶宽≈171、底宽≈159。
        // 之前用 1498..1685/245..760 是拿「纸背板白色遮罩 bbox」当便签，左偏 19px、顶偏 40px，
        // 导致右栏压到纸面上、槽位溢出便签。这里改为按四边形内接矩形 + 固定 8px 边缘留白。
        public const float RailQuadLeft = 1517f;
        public const float RailQuadTop = 205f;
        public const float RailQuadBottom = 765f;
        public const float RailEdgePad = 8f;                 // 只在四边形边缘留的固定像素
        public static float RailQuadRight(float y) { return 1694.0f - 0.0218f * y; }
        // 内接矩形：左边取四边形左边；右边取最窄处（底边 R(765)≈1677）；上下各缩 pad。
        public const float RailLeft = RailQuadLeft + RailEdgePad;      // 1525
        public const float RailRight = 1677f - RailEdgePad;            // 1669
        public const float RailTop = RailQuadTop + RailEdgePad;        // 213
        public const float RailBottom = RailQuadBottom - RailEdgePad;  // 757

        // ---------- 由上面反推的交互区（全部落在美术实体内） ----------

        /// <summary>标题行：纸面顶部、X 右侧、回形针左侧，避开两件手绘装饰。</summary>
        public static readonly Rect TitleRow = new Rect(
            CloseXRight + 18f,          // 460
            PaperTopFull + 4f,          // 204
            ClipLeft - CloseXRight - 48f, // 800
            52f);

        /// <summary>
        /// 主内容区（Body 的落位）。标题行下方到纸面底栏上方，左右各留 12px 安全边。
        /// </summary>
        public static readonly Rect BodyArea = new Rect(
            PaperLeft + 12f,            // 392
            PaperTopFull + 64f,         // 264
            (PaperRight - PaperLeft) - 24f, // 1112
            (PaperBottomFull - PaperTopFull) - 140f); // 460

        /// <summary>右栏便签容器：右侧色条实测范围，标题在内卡、槽在色条。</summary>
        public static readonly Rect RailArea = new Rect(
            RailLeft, RailTop, RailRight - RailLeft, RailBottom - RailTop);

        /// <summary>提示行：纸面底部，底栏文字；提示按钮放在它的右端。</summary>
        public static readonly Rect FooterArea = new Rect(
            PaperLeft + 12f,            // 392
            PaperBottomFull - 56f,      // 744
            (PaperRight - PaperLeft) - 240f, // 896（右侧留给提示按钮）
            52f);

        public static readonly Rect HintButtonArea = new Rect(
            PaperRight - 232f,          // 1284
            PaperBottomFull - 58f,      // 742
            220f, 48f);

        /// <summary>关闭 X 的点击热区（图形 306..452 / 48..216，取中心略微外扩）。</summary>
        public static readonly Rect CloseXArea = new Rect(309f, 55f, 82f, 82f);

        /// <summary>
        /// 把一段「旧美术坐标」等比缩放并居中塞进目标安全区。
        /// 用于 Body：内容仍按旧坐标系建（各 Board 不必改），只把整个容器缩放平移。
        /// </summary>
        public static Rect FitInside(Rect source, Rect target)
        {
            var scale = Mathf.Min(target.width / source.width, target.height / source.height);
            var w = source.width * scale;
            var h = source.height * scale;
            return new Rect(target.center.x - w * 0.5f, target.center.y - h * 0.5f, w, h);
        }
    }
}
