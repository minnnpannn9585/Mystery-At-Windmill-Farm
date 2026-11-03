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

        // ---------------- 层级（§4.1 / §19 风险 6） ----------------
        public const int CanvasSortingOrder = 400;

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
