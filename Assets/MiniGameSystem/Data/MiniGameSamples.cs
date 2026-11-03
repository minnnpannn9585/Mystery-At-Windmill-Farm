using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// M2 的七份示例内容。作用只有一个：**让每块板子都能单独开起来做行为验收**，
    /// 不必等 M3 的真实文案与美术。真实数据（19 局）在 M3 走 Data/ 的配置表，
    /// 板子本身不区分「示例」和「正式」——它只认识 MiniGameContent。
    ///
    /// 坐标全部是主区美术坐标（左上原点、y 向下，主区 1285×637）。
    /// 槽 / 段的 Pos 是**左上角**，卡 / 图块的位置是**中心**。
    /// </summary>
    public static class MiniGameSamples
    {
        public const string Prefix = "SAMPLE-";

        public static MiniGameContent For(MiniGameTemplate template)
        {
            switch (template)
            {
                case MiniGameTemplate.Magnifier: return Magnifier();
                case MiniGameTemplate.Uncover: return Uncover();
                case MiniGameTemplate.Rotate: return Rotate();
                case MiniGameTemplate.Jigsaw: return Jigsaw();
                case MiniGameTemplate.Rubbing: return Rubbing();
                case MiniGameTemplate.Tweezer: return Tweezer();
                case MiniGameTemplate.Testimony: return Testimony();
                default: return MiniGameContent.DebugDefault();
            }
        }

        // ---------------- T1 放大镜：两处痕迹，拖镜片对准后点一下 ----------------

        static MiniGameContent Magnifier()
        {
            return new MiniGameContent
            {
                Key = "sample-magnifier",
                SlotCount = 2,
                Targets = new[]
                {
                    new MiniGameTarget("t1", "卷毛", new Vector2(420f, 300f), 76f),
                    new MiniGameTarget("t2", "爪印", new Vector2(880f, 340f), 76f),
                },
            };
        }

        // ---------------- T2 拨开：三束草盖住两处目标，草挪到左侧停放区 ----------------

        static MiniGameContent Uncover()
        {
            return new MiniGameContent
            {
                Key = "sample-uncover",
                SlotCount = 2,
                Targets = new[]
                {
                    new MiniGameTarget("t1", "凹陷轮廓", new Vector2(672f, 300f), 70f),
                    new MiniGameTarget("t2", "深色细毛", new Vector2(936f, 300f), 70f),
                },
                Segments = new[]
                {
                    // T2 复用 Segments 装「草束」：Pos 左上、Size 即草束尺寸
                    new MiniGameSegment("b1", "草束 1", new Vector2(600f, 190f), new Vector2(144f, 220f)),
                    new MiniGameSegment("b2", "草束 2", new Vector2(744f, 190f), new Vector2(144f, 220f)),
                    new MiniGameSegment("b3", "草束 3", new Vector2(864f, 190f), new Vector2(144f, 220f)),
                },
                // 停放区：一个 260×420 的虚线框
                Slots = new[]
                {
                    new MiniGameSlot("park", "停放区", new Vector2(100f, 130f), new Vector2(260f, 420f)),
                },
            };
        }

        // ---------------- T3 翻转：一个对象两个面，各一处目标 ----------------

        static MiniGameContent Rotate()
        {
            return new MiniGameContent
            {
                Key = "sample-rotate",
                SlotCount = 2,
                Targets = new[]
                {
                    new MiniGameTarget("fa", "正面痕迹", new Vector2(560f, 300f), 66f),
                    new MiniGameTarget("fb", "背面痕迹", new Vector2(720f, 330f), 66f),
                },
                Faces = new[]
                {
                    new MiniGameFace("a", "正面", false, new[] { "fa" }),
                    new MiniGameFace("b", "背面", true, new[] { "fb" }),
                },
            };
        }

        // ---------------- T4 拼合：3×2 六格，错位留存，拼完选方向 ----------------

        static MiniGameContent Jigsaw()
        {
            var cells = new MiniGameSlot[6];
            var cellLabels = new[] { "左上", "中上", "右上", "左下", "中下", "右下" };
            const float w = 200f, h = 160f, gap = 8f, ox = 120f, oy = 70f;
            for (var i = 0; i < 6; i++)
            {
                var col = i % 3;
                var row = i / 3;
                cells[i] = new MiniGameSlot("c" + (i + 1), cellLabels[i],
                    new Vector2(ox + col * (w + gap), oy + row * (h + gap)), new Vector2(w, h));
            }

            return new MiniGameContent
            {
                Key = "sample-jigsaw",
                SlotCount = 6,
                Slots = cells,
                Labels = new[] { "块 1", "块 2", "块 3", "块 4", "块 5", "块 6" },
            };
        }

        // ---------------- T5 拓印：横向三段痕迹 ----------------

        static MiniGameContent Rubbing()
        {
            return new MiniGameContent
            {
                Key = "sample-rubbing",
                SlotCount = 3,
                Segments = new[]
                {
                    new MiniGameSegment("g1", "上段", new Vector2(150f, 80f), new Vector2(980f, 140f)),
                    new MiniGameSegment("g2", "中段", new Vector2(150f, 250f), new Vector2(980f, 140f)),
                    new MiniGameSegment("g3", "下段", new Vector2(150f, 420f), new Vector2(980f, 140f)),
                },
                Labels = new[] { "上段", "中段", "下段" },
            };
        }

        // ---------------- T6 镊取：三件毛，放到右侧圆盘 ----------------

        static MiniGameContent Tweezer()
        {
            return new MiniGameContent
            {
                Key = "sample-tweezer",
                SlotCount = 3,
                Targets = new[]
                {
                    new MiniGameTarget("m1", "毛 1", new Vector2(300f, 460f), 56f),
                    new MiniGameTarget("m2", "毛 2", new Vector2(470f, 510f), 56f),
                    new MiniGameTarget("m3", "毛 3", new Vector2(640f, 450f), 56f),
                },
                // 观察盘：Pos 左上、Size 即内切方形（§11.5 的 140×140 概念，这里放大到 200 便于验收）
                Slots = new[]
                {
                    new MiniGameSlot("dish", "观察区", new Vector2(1000f, 160f), new Vector2(200f, 200f)),
                },
            };
        }

        // ---------------- T7 证词：三槽三卡，含一张干扰卡 ----------------

        static MiniGameContent Testimony()
        {
            return new MiniGameContent
            {
                Key = "sample-testimony",
                SlotCount = 3,
                Slots = new[]
                {
                    new MiniGameSlot("s1", "寻找的东西", new Vector2(32f, 70f), new Vector2(380f, 180f)),
                    new MiniGameSlot("s2", "他说的去向", new Vector2(452f, 70f), new Vector2(380f, 180f)),
                    new MiniGameSlot("s3", "他说的时间", new Vector2(872f, 70f), new Vector2(380f, 180f)),
                },
                Cards = new[]
                {
                    new MiniGameCard("k1", "窝里的蛋", "s1"),
                    new MiniGameCard("k2", "西边谷仓", "s2"),
                    new MiniGameCard("k3", "今早天没亮", "s3"),
                    // 干扰卡：SlotId 留空，拖进任何槽都弹回
                    new MiniGameCard("k4", "普通的蛋", null),
                },
            };
        }
    }
}
