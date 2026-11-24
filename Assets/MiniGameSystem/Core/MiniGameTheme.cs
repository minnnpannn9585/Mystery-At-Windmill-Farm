using TMPro;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 色板、字体、区域坐标与动效常量的唯一来源。
    /// 色值取自 19-文档 §19.7；区域坐标取自本文档 §4.1「美术坐标」表。
    /// 所有 UI 规格都只对齐概念图，正式效果待美术接入（§1.1 效力声明）。
    /// </summary>
    public static class MiniGameTheme
    {
        // ---------------- 色板（19-文档 §19.7） ----------------
        public static readonly Color Deep = Hex(0x19, 0x4D, 0x65);   // 深蓝：主文字 / 描边
        public static readonly Color Cream = Hex(0xFF, 0xF8, 0xDE);  // 奶白：面板底 / 卡面
        public static readonly Color Yellow = Hex(0xFF, 0xD4, 0x47); // 亮黄：高亮 / 主按钮
        public static readonly Color Orange = Hex(0xEF, 0x78, 0x49); // 橙：强调 / 进度
        public static readonly Color Blue = Hex(0x26, 0xA9, 0xFF);   // 蓝：可交互提示
        public static readonly Color Green = Hex(0x65, 0xD4, 0x43);  // 绿：完成
        public static readonly Color DarkGreen = Hex(0x24, 0xA3, 0x48);
        public static readonly Color Ink = Hex(0x24, 0x2A, 0x30);    // 正文墨色
        public static readonly Color Grey = Hex(0x6B, 0x72, 0x80);   // 次要文字
        public static readonly Color Scrim = new Color(0f, 0f, 0f, 0.72f); // 全屏压暗（§12.6 重听）

        public static Color Hex(int r, int g, int b)
        {
            return new Color(r / 255f, g / 255f, b / 255f, 1f);
        }

        public static Color Alpha(Color c, float a)
        {
            c.a = a;
            return c;
        }

        static TMP_FontAsset _font;

        /// <summary>与现有 HUD 同一套 MiSans，避免新做字体资产。</summary>
        public static TMP_FontAsset Font
        {
            get
            {
                if (_font == null) _font = UiFontCatalog.Load();
                return _font;
            }
        }

        // ---------------- 参考分辨率（§4.1） ----------------
        public const float RefWidth = 1920f;
        public const float RefHeight = 1080f;

        // 美术坐标（原点左上、y 向下），由 MiniGameUIKit.PlaceArt 换算成 anchoredPosition
        public static readonly Rect TopBar = new Rect(0f, 0f, 1920f, 96f);
        public static readonly Rect Objective = new Rect(115f, 96f, 1285f, 72f);
        public static readonly Rect Body = new Rect(115f, 216f, 1285f, 637f);
        public static readonly Rect RightRail = new Rect(1498f, 238f, 307f, 518f);
        public static readonly Rect HintButton = new Rect(1610f, 900f, 290f, 44f);
        public static readonly Rect Footer = new Rect(115f, 950f, 1805f, 108f);

        // ---------------- M3 骨架层：纸面板新坐标（§2.2，组件原稿 1:1） ----------------
        // 这五个区域是概念图 / 图 2-1 锁定的最终口径。旧的 Body / RightRail / Footer
        // 保留给尚未换图的交互层，等 19 局内容逐项换算完再切过去。
        public static readonly Rect PaperFull = new Rect(0f, 0f, 1920f, 1080f);   // 组件 PNG 是全画布透明图
        public static readonly Rect PaperTitleRow = new Rect(430f, 96f, 1037f, 80f);
        public static readonly Rect PaperIllustration = new Rect(430f, 181f, 1037f, 583f);
        public static readonly Rect PaperRail = new Rect(1518f, 209f, 170f, 663f);
        public static readonly Rect PaperFooter = new Rect(408f, 772f, 1080f, 104f);
        public static readonly Rect PaperCloseX = new Rect(309f, 55f, 82f, 82f);

        /// <summary>纸背板原稿色（组件 PNG 里的 (250,116,71)），乘算染色时要除掉它。</summary>
        public static readonly Color PaperBackBase = Hex(0xFA, 0x74, 0x47);

        /// <summary>
        /// 七色便签卡（美术文档 §色卡），索引 = (int)MiniGameTemplate。
        /// 全案是黄绿色调的吉卜力风：七色统一降饱和、偏暖偏灰，靠色相与明度轻微错开区分，
        /// 不再用高彩橙红 / 荧光粉紫，避免便签在纸面上跳出来。
        /// </summary>
        public static Color NoteColor(MiniGameTemplate template)
        {
            switch (template)
            {
                case MiniGameTemplate.Magnifier: return Hex(0xC0, 0x8A, 0x67); // T1 暖赭
                case MiniGameTemplate.Uncover:   return Hex(0xC7, 0xB4, 0x74); // T2 麦黄
                case MiniGameTemplate.Rotate:    return Hex(0xA2, 0xB5, 0x7A); // T3 苔绿
                case MiniGameTemplate.Jigsaw:    return Hex(0x8B, 0xA8, 0x9C); // T4 灰青
                case MiniGameTemplate.Rubbing:   return Hex(0x8A, 0xA2, 0xB1); // T5 雾蓝
                case MiniGameTemplate.Tweezer:   return Hex(0x9E, 0x94, 0xA6); // T6 灰紫（低饱和，不突兀）
                case MiniGameTemplate.Testimony: return Hex(0xC0, 0x93, 0x90); // T7 陶粉（灰粉，不跳）
                default: return PaperBackBase;
            }
        }

        /// <summary>
        /// 便签内卡 / widget 的底色：取便签主色向暖灰墨色压暗，保持同一色系。
        /// 白色内卡太跳、会盖掉便签本来的样子；深版要像便签自己的折页，
        /// 不能像叠了一块蓝黑色（旧版向 Deep 墨蓝 Lerp 会把粉紫压成脏紫）。
        /// </summary>
        public static Color NoteDeep(MiniGameTemplate template)
        {
            var c = NoteColor(template);
            var warmInk = new Color(0.24f, 0.25f, 0.23f, 1f);
            return new Color(Mathf.Lerp(c.r, warmInk.r, 0.42f),
                Mathf.Lerp(c.g, warmInk.g, 0.42f),
                Mathf.Lerp(c.b, warmInk.b, 0.42f), 1f);
        }

        /// <summary>便签内的文字色：在深底上用接近纸白的浅色，保证可读又不刺眼。</summary>
        public static readonly Color NoteInk = new Color(0.98f, 0.96f, 0.90f, 1f);

        // ---------------- 组件资源路径（Resources.Load，不带扩展名） ----------------
        public const string ArtPaperStack = "MiniGameArt/PaperStack";
        public const string ArtPaperFace = "MiniGameArt/PaperFace";
        public const string ArtPaperClip = "MiniGameArt/PaperClip";
        public const string ArtCloseX = "MiniGameArt/CloseX";

        /// <summary>纸背板七色版，索引 = (int)MiniGameTemplate，逐色预染好的组件 PNG。</summary>
        public static string ArtPaperBack(MiniGameTemplate template)
        {
            var i = (int)template;
            if (i < 0 || i > 6) i = 6;
            return "MiniGameArt/PaperBack_" + i;
        }

        // ---------------- 层级（§4.1 / §19 风险 6） ----------------
        public const int CanvasSortingOrder = 400;

        /// <summary>
        /// 黑底模糊层的排序值。**必须是负的**：它要压在 3D 场景之上、压在全部 UI 之下。
        /// 现有 Overlay 画布的排序值：小游戏 400 / 暂停菜单 300 / 玩家 80 / 世界提示 10 /
        /// HUD 与笔记本 0（场景内预制体默认值）。取负就天然低于以上全部。
        /// </summary>
        public const int BackdropSortingOrder = -100;

        // ---------------- 通用尺寸 ----------------
        public const float ButtonRadius = 12f;
        public const float PanelRadius = 16f;
        public const float HintHeight = 44f;
    }

    /// <summary>
    /// 动效与手感常量。§18.2.5「音效与动效的合并清单」里定下的统一值，
    /// 需要保留差异的地方在各 Board 里显式覆盖，不在这里加分支。
    /// </summary>
    public static class MiniGameMotion
    {
        /// <summary>跟手平滑。T1 镜片用 0.12（要「重」）、T4 图块用 0.05（要「准」）。</summary>
        public const float FollowSmoothTime = 0.06f;
        public const float FollowSmoothTimeMagnifier = 0.12f;
        public const float FollowSmoothTimeJigsaw = 0.05f;

        /// <summary>T2 草束的角度滞后（比位置慢，产生甩动）。</summary>
        public const float TiltSmoothTime = 0.09f;
        public const float TiltMaxDegrees = 10f;
        public const float TweenTiltMaxDegrees = 6f;   // T6 毛挂镊尖

        /// <summary>拿起 / 放下。</summary>
        public const float PickScale = 1.04f;
        public const float PickDuration = 0.08f;

        /// <summary>弹性回位。T3 翻面展开 0.26、T2 松手 0.35 + 两次衰减摆动。</summary>
        public const float ReturnDuration = 0.22f;
        public const float ReturnOvershoot = 1.06f;
        public const float FlipExpandDuration = 0.26f;
        public const float FlipExpandOvershoot = 1.04f;
        public const float UncoverReturnDuration = 0.35f;

        /// <summary>高亮脉冲（M1 建议值，实机再定，见 §18.3 遗留项 5）。</summary>
        public const float HighlightPeriod = 0.9f;
        public const float HighlightAlphaMin = 0.35f;
        public const int HighlightFlashesOnReject = 2;

        /// <summary>完成停顿。T4 合体后 0.5、T5 第三段 0.10。</summary>
        public const float CompleteHold = 0.15f;
        public const float CompleteHoldJigsaw = 0.5f;
        public const float CompleteHoldRubbing = 0.10f;

        /// <summary>入册演出总时长（§13.2：0.30 + 0.55 + 0.30 + 0.13 + 0.77）。</summary>
        public const float FlightTotal = 2.05f;
    }
}
