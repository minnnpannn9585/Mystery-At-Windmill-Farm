using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// M3：19 局正式内容 + Q12 跨模板拆出的续段 Q12B（共 20 份 Content）。
    ///
    /// 权威来源：MissingEggDoc-main/docs/19-关键线索调查解谜.md §19.4 / §19.5
    /// 各局「初始物件／目标／干扰」「正确答案」「提示」逐字照搬（§12.6.1：不压缩、标点原样）。
    /// 坐标沿用旧 Body 美术口径（1285×637、左上原点、y 向下），由 MiniGameUIKit.PlaceArtFit
    /// 统一适配到 1920×1080 安全区 —— 与 M2 七份样例同一套口径，板子代码不用改。
    ///
    /// 约定：
    ///   · Targets/槽 的 Pos 是左上角，卡/图块位置由 Board 自动排布，数据里不写死。
    ///   · Q12 原文要求「拨开＋翻转同一局」，但框架是「一 Def 一模板」。
    ///     M3 拆成 Q12（T2 前半，主表仍 19 局）+ Q12B（T3 续段，不进主表）。
    ///     提交变量 E10_ViewWhiteStone 挂在 Q12B —— 两段都完成才写，流程侧需在 Q12 成功后接 Q12B。
    /// </summary>
    public static class MiniGameContents
    {
        // ---------------- 取数 ----------------

        public static MiniGameContent For(string key)
        {
            if (string.IsNullOrEmpty(key)) return null;
            switch (key)
            {
                case "Q01": return Q01();
                case "Q02": return Q02();
                case "Q03": return Q03();
                case "Q04": return Q04();
                case "Q05": return Q05();
                case "Q06": return Q06();
                case "Q07": return Q07();
                case "Q08": return Q08();
                case "Q09": return Q09();
                case "Q10": return Q10();
                case "Q11": return Q11();
                case "Q12": return Q12();
                case "Q12B": return Q12B();
                case "Q13": return Q13();
                case "Q14": return Q14();
                case "Q15": return Q15();
                case "Q16": return Q16();
                case "Q17": return Q17();
                case "Q18": return Q18();
                case "Q19": return Q19();
                default: return null;
            }
        }

        /// <summary>供 M3 验收：19 局 + Q12B 是否都有内容。</summary>
        public static bool Has(string key) { return For(key) != null; }

        // ---------------- 构造小工具 ----------------

        static MiniGameTarget T(string id, string label, float x, float y, float radius = 76f)
        {
            return new MiniGameTarget(id, label, new Vector2(x, y), radius);
        }

        static MiniGameSlot S(string id, string label, float x, float y, float w, float h, int capacity = 1)
        {
            return new MiniGameSlot(id, label, new Vector2(x, y), new Vector2(w, h), capacity);
        }

        static MiniGameSegment G(string id, string label, float x, float y, float w, float h)
        {
            return new MiniGameSegment(id, label, new Vector2(x, y), new Vector2(w, h));
        }

        static MiniGameCard K(string id, string text, string slotId, int order = 0)
        {
            return new MiniGameCard(id, text, slotId, order);
        }

        static MiniGameContent New(string key, string bg)
        {
            return new MiniGameContent { Key = key, BackgroundKey = bg };
        }

        // ---------------- T1 放大镜调查：Q06 / Q09 / Q11 / Q14 ----------------

        /// <summary>E12 绿垫：露边材质色块 + 垫高轮廓。镜心判定，两处相隔一段距离。</summary>
        static MiniGameContent Q06()
        {
            var c = New("Q06", "E12_PondPad");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("pad_edge", "与荷叶不同的绿色垫边", 438f, 288f, 82f),
                T("pad_lift", "垫在身下形成的隆起", 872f, 352f, 82f),
            };
            return c;
        }

        /// <summary>E05 泡水谷粒：谷粒群共用一个宽松目标区，另一处是浑浊液体。</summary>
        static MiniGameContent Q09()
        {
            var c = New("Q09", "E05_Trough");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("soaked_grain", "浮着的胀谷粒", 452f, 284f, 92f),
                T("murky_water", "浑浊液体", 880f, 360f, 88f),
            };
            return c;
        }

        /// <summary>E08 焦痕：草尖焦黑 + 毛尖燎卷。</summary>
        static MiniGameContent Q11()
        {
            var c = New("Q11", "E08_Straw");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("burnt_tip", "草尖焦黑", 422f, 276f, 78f),
                T("curl_fur", "毛尖燎卷", 868f, 348f, 78f),
            };
            return c;
        }

        /// <summary>E14 猫门：右上小锁扣 + 下沿磨亮边缘，相隔至少一枚镜片。</summary>
        static MiniGameContent Q14()
        {
            var c = New("Q14", "E14_CatDoor");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("latch", "细小锁扣", 842f, 244f, 76f),
                T("worn_edge", "磨亮边缘", 446f, 424f, 82f),
            };
            return c;
        }

        // ---------------- T2 拨开遮挡：Q10 / Q12 前半 ----------------

        /// <summary>E07 草窝：前缘 2 束浮草盖住凹陷轮廓与深色细毛，拖进左侧停放区。</summary>
        static MiniGameContent Q10()
        {
            var c = New("Q10", "E07_NapNest");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("dent", "凹陷轮廓", 668f, 296f, 96f),
                T("fine_hair", "边缘深色细毛", 936f, 316f, 86f),
            };
            c.Segments = new[]
            {
                G("grass_l", "浮草左束", 580f, 188f, 180f, 236f),
                G("grass_r", "浮草右束", 826f, 188f, 180f, 236f),
            };
            c.Slots = new[] { S("park", "停放区", 96f, 130f, 260f, 430f) };
            return c;
        }

        /// <summary>E10 白石·前半：3 束巢草盖住爱心面轮廓。留在主表 Q12，完成后续 Q12B。</summary>
        static MiniGameContent Q12()
        {
            var c = New("Q12", "E10_NestStone");
            c.SlotCount = 1;
            c.Targets = new[]
            {
                T("heart_face", "爱心面轮廓", 722f, 300f, 110f),
            };
            c.Segments = new[]
            {
                G("nest_l", "巢草左束", 522f, 178f, 156f, 244f),
                G("nest_m", "巢草中束", 706f, 158f, 156f, 250f),
                G("nest_r", "巢草右束", 890f, 182f, 156f, 242f),
            };
            c.Slots = new[] { S("park", "停放区", 88f, 120f, 258f, 440f) };
            return c;
        }

        // ---------------- T3 翻转查验：Q02 / Q15 / Q18 / Q12B 后半 ----------------

        /// <summary>
        /// E01 短木炭（19 文档 §19.4 Q02）：两处可交互目标，均靠翻转显现（§8.11）。
        /// 交互结构（用户手绘定稿）：碳条放在背景图层的树叶上（底图，程序不管），
        ///   ① 碳条尖尖初始朝右 → 玩家翻转碳条使尖尖朝向玩家 → 点磨平端 flat_tip；
        ///   ② 碳条尾部盖着一片可交互树叶 → 翻转这片树叶 → 露出炭迹 leaf_powder。
        /// 除这两个可交互目标外，其余（背景树叶 / 两片绿叶 / 小石子）都是底图，
        /// 程序不建对象、美术不单列素材（用户强规则）。
        /// 原型一律最简形状 + 文档色值占位，spritePath 留空；正式图到位填编号路径即可。
        /// 成功阈值 2/2。
        /// </summary>
        static MiniGameContent Q02()
        {
            var c = New("Q02", "E01_Charcoal");
            c.BackgroundResource = "MiniGameArt/ConceptB01_Haystack";  // B-01 稻草堆概念图（美术效果预览）
            c.SlotCount = 2;
            // 主区 1285×637。碳条横向居中偏右、尖尖朝右；尾叶盖在碳条左端（尾部）。
            c.Targets = new[]
            {
                T("flat_tip", "磨平的炭尖", 800f, 280f, 76f),     // 碳条右端（尖尖处）
                T("leaf_powder", "蹭在草叶上的炭粉", 430f, 330f, 76f), // 尾叶背面
            };
            // 兼容单物体路径的简写（多物体局实际走 FlipObjects）
            c.Faces = new[]
            {
                new MiniGameFace("front", "正面", false, new[] { "flat_tip" }),
                new MiniGameFace("back", "背面", true, new[] { "leaf_powder" }),
            };

            // M-04 规格色：炭 #6E6A66 / 磨亮斜面 #9A968F；T3-02 炭粉 #4A4642。
            var coalColor = new Color(110f/255f, 106f/255f, 102f/255f, 1f);   // #6E6A66
            var leafColor = new Color(143f/255f, 168f/255f, 106f/255f, 1f);   // #8FA86A 尾叶占位

            c.FlipObjects = new[]
            {
                // ① M-04 短木炭：细长矩形，尖尖初始朝右。目标挂背面 = 翻转后才可点。
                new MiniGameFlipObject("charcoal", "短木炭 M-04", new Vector2(650f, 285f),
                    new Vector2(460f, 150f), 1)
                {
                    Shape = FlipShape.Rect,
                    Color = coalColor,
                    Faces = new[]
                    {
                        new MiniGameFace("coal_side", "尖尖朝右（侧视）", false, new string[0]),
                        new MiniGameFace("coal_face", "尖尖朝向玩家（磨平面）", true, new[] { "flat_tip" }),
                    },
                    Flippable = true,
                },
                // ② M-15 尾部可交互树叶：盖在碳条尾部；翻转后露炭迹（第二处目标）
                new MiniGameFlipObject("tail_leaf", "尾部树叶 M-15", new Vector2(430f, 330f),
                    new Vector2(220f, 140f), 2)
                {
                    Shape = FlipShape.Ellipse,
                    Color = leafColor,
                    Faces = new[]
                    {
                        new MiniGameFace("leaf_front", "叶背（盖着）", false, new string[0]),
                        new MiniGameFace("leaf_back", "叶面（炭迹）", true, new[] { "leaf_powder" }),
                    },
                    Flippable = true,
                },
            };
            return c;
        }

        /// <summary>E15 食碗：碗沿爪印 + 内底余渣。垂直翻转 0°/55°。</summary>
        static MiniGameContent Q15()
        {
            var c = New("Q15", "E15_FoodBowl");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("rim_paw", "碗沿爪印", 528f, 278f, 66f),
                T("bowl_dregs", "碗底余渣", 756f, 316f, 66f),
            };
            c.Faces = new[]
            {
                new MiniGameFace("front", "正面", false, new[] { "rim_paw" }),
                new MiniGameFace("back", "背面", true, new[] { "bowl_dregs" }),
            };
            return c;
        }

        /// <summary>E17 空桶：桶里是空的 + 外底湿泥细沙。水平翻转 0°/180°。</summary>
        static MiniGameContent Q18()
        {
            var c = New("Q18", "E17_Bucket");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("empty_inside", "桶里是空的", 548f, 288f, 70f),
                T("mud_bottom", "外底粘着湿泥细沙", 736f, 320f, 70f),
            };
            c.Faces = new[]
            {
                new MiniGameFace("front", "正面", false, new[] { "empty_inside" }),
                new MiniGameFace("back", "背面", true, new[] { "mud_bottom" }),
            };
            return c;
        }

        /// <summary>
        /// E10 白石·后半：爱心面 + 鬼脸面。实心圆石轮廓强制（翻转时宽度压扁、换面）。
        /// 提交变量 E10_ViewWhiteStone 挂这段 —— 双面 2/2 才写。
        /// </summary>
        static MiniGameContent Q12B()
        {
            var c = New("Q12B", "E10_NestStone");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("heart", "爱心", 548f, 290f, 76f),
                T("ghost", "鬼脸", 736f, 318f, 76f),
            };
            c.Faces = new[]
            {
                new MiniGameFace("front", "正面", false, new[] { "heart" }),
                new MiniGameFace("back", "背面", true, new[] { "ghost" }),
            };
            return c;
        }

        // ---------------- T4 观察图拼合：Q19 ----------------

        /// <summary>E18 雨靴印：3 列 × 2 行六格，六块图固定朝向；拼完选「朝鸡舍」（方向第二阶段由 Board 负责）。</summary>
        static MiniGameContent Q19()
        {
            var c = New("Q19", "E18_Bootprints");
            c.SlotCount = 6;
            const float w = 200f, h = 160f, gap = 8f;
            const float ox = 334f, oy = 154f; // (1285-616)/2, (637-328)/2 —— 六格在主区居中
            var names = new[] { "左上", "中上", "右上", "左下", "中下", "右下" };
            var slots = new MiniGameSlot[6];
            for (var i = 0; i < 6; i++)
            {
                var col = i % 3;
                var row = i / 3;
                slots[i] = S("cell" + (i + 1), names[i],
                    ox + col * (w + gap), oy + row * (h + gap), w, h);
            }
            c.Slots = slots;
            c.Labels = new[] { "鞋尖纹", "宽鞋底纹", "地面边界", "鞋跟纹", "斜向轮廓", "地面色块" };
            return c;
        }

        // ---------------- T5 痕迹拓印：Q17 ----------------

        /// <summary>E28 树根抓痕：取样纸下三段揭露区，每段独立统计覆盖 ≥80%。</summary>
        static MiniGameContent Q17()
        {
            var c = New("Q17", "E28_TreeScratch");
            c.SlotCount = 3;
            c.Segments = new[]
            {
                G("trace_top", "上段", 158f, 84f, 968f, 148f),
                G("trace_mid", "中段", 158f, 252f, 968f, 148f),
                G("trace_low", "下段", 158f, 420f, 968f, 148f),
            };
            c.Labels = new[] { "上段", "中段", "下段" };
            return c;
        }

        // ---------------- T6 镊取物证：Q03（Count）/ Q16（Step） ----------------

        /// <summary>E02 三根黄绒毛：左下/中央/右上；观察盘 3 个宽松落点（同一盘，任意顺序）。</summary>
        static MiniGameContent Q03()
        {
            var c = New("Q03", "E02_Feathers");
            c.SlotCount = 3;
            c.Targets = new[]
            {
                T("fluff_1", "黄绒毛（左下）", 304f, 462f, 58f),
                T("fluff_2", "黄绒毛（中央）", 610f, 302f, 58f),
                T("fluff_3", "黄绒毛（右上）", 906f, 188f, 58f),
            };
            c.Slots = new[] { S("dish", "观察盘", 986f, 126f, 262f, 262f) };
            return c;
        }

        /// <summary>E16 一撮深蓝黑兽毛：整撮作为一个对象；观察区 1 个宽松落点，进度两步。</summary>
        static MiniGameContent Q16()
        {
            var c = New("Q16", "E16_BlackFur");
            c.SlotCount = 2;
            c.Targets = new[]
            {
                T("fur_tuft", "细软兽毛", 468f, 402f, 84f),
            };
            c.Slots = new[] { S("dish", "观察区", 986f, 126f, 262f, 262f) };
            return c;
        }

        // ---------------- T7 证词归位：Q01 / Q04 / Q05 / Q07 / Q08 / Q13 ----------------

        /// <summary>Q01 委托：2 槽 3 卡，普通蛋是干扰卡留在待选区。重听淑芬 1-A。</summary>
        static MiniGameContent Q01()
        {
            var c = New("Q01", "Q01_Commission");
            c.ReplayModule = "shufang_01_FROM_DOC";
            c.ReplayTag = "1-A";
            c.SlotCount = 2;
            c.Slots = new[]
            {
                S("wanted", "寻找的东西", 148f, 70f, 440f, 210f),
                S("when", "发现不见的时间", 716f, 70f, 440f, 210f),
            };
            c.Cards = new[]
            {
                K("heart_egg", "画着爱心的蛋", "wanted"),
                K("this_morning", "今天早上", "when"),
                K("plain_egg", "普通的蛋", null), // 干扰
            };
            return c;
        }

        /// <summary>Q04 偷听：3 槽 3 卡，逐字保留猜测与转述语气。重听小鸡 E03 偷听 1-A。</summary>
        static MiniGameContent Q04()
        {
            var c = New("Q04", "Q04_Eavesdrop");
            c.ReplayModule = "xiaojiZTT_e03_FROM_DOC";
            c.ReplayTag = "1-A";
            c.SlotCount = 3;
            c.Slots = new[]
            {
                S("guess", "他们猜测的响动", 32f, 70f, 380f, 200f),
                S("frog_said", "他们提到青蛙说过的事", 452f, 70f, 380f, 200f),
                S("public_line", "他们准备对外说的话", 872f, 70f, 380f, 200f),
            };
            c.Cards = new[]
            {
                K("noise_guess", "昨晚外面那声音……肯定是水怪干的", "guess"),
                K("bead_sank", "宝珠沉下去了", "frog_said"),
                K("public", "就说……水怪。从池塘来的。把蛋叼走了……", "public_line"),
            };
            return c;
        }

        /// <summary>Q05 水怪说：3 槽 3 卡，标题引号强调是待核实证词。重听小鸡 2-B。</summary>
        static MiniGameContent Q05()
        {
            var c = New("Q05", "Q05_WaterMonster");
            c.ReplayModule = "xiaojiZTT_01_FROM_DOC";
            c.ReplayTag = "2-B";
            c.SlotCount = 3;
            c.Slots = new[]
            {
                S("shape", "他们形容的外形", 32f, 70f, 380f, 200f),
                S("origin", "他们说的来处", 452f, 70f, 380f, 200f),
                S("next", "下一位求证对象", 872f, 70f, 380f, 200f),
            };
            c.Cards = new[]
            {
                K("three_heads", "三个脑袋！浑身绿色！", "shape"),
                K("from_pond", "从池塘爬上来！", "origin"),
                K("pond_frog", "池塘那只青蛙", "next"),
            };
            return c;
        }

        /// <summary>Q07 排序：3 槽 3 卡，Order 记原顺序，卡面只写隐语原文。重听悲伤蛙 2-D。</summary>
        static MiniGameContent Q07()
        {
            var c = New("Q07", "Q07_FrogWords");
            c.ReplayModule = "qingwa_01_FROM_DOC";
            c.ReplayTag = "2-D";
            c.SlotCount = 3;
            c.Slots = new[]
            {
                S("p1", "第一段", 32f, 70f, 380f, 200f),
                S("p2", "第二段", 452f, 70f, 380f, 200f),
                S("p3", "第三段", 872f, 70f, 380f, 200f),
            };
            c.Cards = new[]
            {
                K("pure", "纯净，第一个死去。", "p1", 1),
                K("vessel", "冰冷的器皿来了。生命之源在枯竭。", "p2", 2),
                K("demon", "一个黑色的恶魔……它带走了宝珠。", "p3", 3),
            };
            return c;
        }

        /// <summary>Q08 大黄目击：3 槽 3 卡，明确归属于大黄的说法。重听大黄 1-A。</summary>
        static MiniGameContent Q08()
        {
            var c = New("Q08", "Q08_DogEyewitness");
            c.ReplayModule = "dahuang_01_FROM_DOC";
            c.ReplayTag = "1-A";
            c.SlotCount = 3;
            c.Slots = new[]
            {
                S("taker", "他说的叼走者", 32f, 70f, 380f, 200f),
                S("where", "他说的去向", 452f, 70f, 380f, 200f),
                S("chase", "他自己的追赶结果", 872f, 70f, 380f, 200f),
            };
            c.Cards = new[]
            {
                K("crow", "乌鸦……叼走了", "taker"),
                K("barn_roof", "往谷仓屋顶飞了", "where"),
                K("air", "只咬到一嘴空气", "chase"),
            };
            return c;
        }

        /// <summary>Q13 分清两次事件：前两卡同槽（Capacity=2），第三卡入第二槽。重听小鸡 2-E 招供段。</summary>
        static MiniGameContent Q13()
        {
            var c = New("Q13", "Q13_TwoEvents");
            c.ReplayModule = "xiaojiZTT_01_FROM_DOC";
            c.ReplayTag = "2-E";
            c.SlotCount = 3;
            c.Slots = new[]
            {
                S("fake_stone", "白石假蛋那次", 148f, 70f, 440f, 210f, 2),
                S("real_egg", "昨晚真蛋失踪", 716f, 70f, 440f, 210f),
            };
            c.Cards = new[]
            {
                K("push_back", "白石画成假蛋，真蛋带出去又推回窝", "fake_stone", 1),
                K("crow_took", "假石扔进草丛，后来被乌鸦叼走", "fake_stone", 2),
                K("last_night", "弟弟是昨晚才不见的！跟那一趟不是一回事！", "real_egg", 3),
            };
            return c;
        }
    }
}
