using System;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>一个可拖 / 可看的目标点。坐标是主操作区的局部坐标。</summary>
    [Serializable]
    public sealed class MiniGameTarget
    {
        public string Id;
        public string Label;
        public Vector2 Pos;
        public float Radius = 60f;

        public MiniGameTarget() { }

        public MiniGameTarget(string id, string label, Vector2 pos, float radius = 60f)
        {
            Id = id;
            Label = label;
            Pos = pos;
            Radius = radius;
        }
    }

    /// <summary>一个槽（T7 的归类槽 / T4 的格）。坐标同样是主区美术坐标。</summary>
    [Serializable]
    public sealed class MiniGameSlot
    {
        public string Id;
        public string Label;
        public Vector2 Pos;
        public Vector2 Size = new Vector2(380f, 180f);

        /// <summary>一个槽允许放几张卡。Q13 的「一槽多卡」是 2，其余都是 1。</summary>
        public int Capacity = 1;

        public MiniGameSlot() { }

        public MiniGameSlot(string id, string label, Vector2 pos, Vector2 size, int capacity = 1)
        {
            Id = id;
            Label = label;
            Pos = pos;
            Size = size;
            Capacity = capacity;
        }
    }

    /// <summary>一张卡（T7 的证词卡）。SlotId 为空 = 干扰卡，拖进任何槽都弹回（§12.5）。</summary>
    [Serializable]
    public sealed class MiniGameCard
    {
        public string Id;
        public string Text;
        public string SlotId;
        /// <summary>排序题的序号（Q07）；归类题填 0。</summary>
        public int Order;

        public MiniGameCard() { }

        public MiniGameCard(string id, string text, string slotId, int order = 0)
        {
            Id = id;
            Text = text;
            SlotId = slotId;
            Order = order;
        }
    }

    /// <summary>T5 的一段揭露区。覆盖率只在 Rect 内统计（§10.2）。</summary>
    [Serializable]
    public sealed class MiniGameSegment
    {
        public string Id;
        public string Label;
        public Vector2 Pos;
        public Vector2 Size;

        public MiniGameSegment() { }

        public MiniGameSegment(string id, string label, Vector2 pos, Vector2 size)
        {
            Id = id;
            Label = label;
            Pos = pos;
            Size = size;
        }
    }

    /// <summary>T3 的一个观察面（正面 / 背面）。TargetIds 是这一面上的目标。</summary>
    [Serializable]
    public sealed class MiniGameFace
    {
        public string Id;
        public string Label;
        public bool Back;
        public string[] TargetIds = new string[0];

        public MiniGameFace() { }

        public MiniGameFace(string id, string label, bool back, string[] targetIds)
        {
            Id = id;
            Label = label;
            Back = back;
            TargetIds = targetIds ?? new string[0];
        }
    }

    /// <summary>
    /// T3 多物体翻转框架里的一个可翻转 / 可遮挡物件（§8.10）。
    ///
    /// 旧模型只有一层 Faces（一个物体的正反面），无法表达 19-文档 Q02 的
    /// 「木炭压在草叶上 / 背侧草叶遮住炭粉 / 另有两片绿叶+石子干扰」这类重叠关系。
    /// 一个 FlipObject 就是一个独立可翻转的物件：有自己的两面、自己的坐标尺寸、自己的层级。
    /// </summary>
    [Serializable]
    public sealed class MiniGameFlipObject
    {
        public string Id;
        public string Label;
        /// <summary>物件中心，主区美术坐标（左上原点、y 向下，同 MiniGameTarget.Pos）。</summary>
        public Vector2 Pos;
        public Vector2 Size = new Vector2(460f, 400f);
        /// <summary>可选：Resources 下的 Sprite 路径；留空则用 Shape + Color 程序化画。</summary>
        public string SpritePath;
        public Color Color = Color.white;
        /// <summary>程序化形状，供无贴图时区分炭块 / 叶片 / 石子。</summary>
        public FlipShape Shape = FlipShape.Rect;

        /// <summary>这一物件正反面。干扰物可留空。</summary>
        public MiniGameFace[] Faces = new MiniGameFace[0];

        /// <summary>渲染层级：数字越大越靠前（遮挡数字小的）。Q02：底草叶 0 &lt; 木炭 1 &lt; 遮挡草叶 2。</summary>
        public int SortOrder;

        /// <summary>true = 纯背景干扰物，不可翻转、不可点、不参与判定（绿叶 / 小石子）。</summary>
        public bool IsDecoy;

        /// <summary>false = 固定不动（如垫在木炭下的草叶）；true = 可水平拖动翻转。</summary>
        public bool Flippable = true;

        /// <summary>
        /// 本物件在背面时会遮挡住哪个物件的目标（被遮目标的所属物件 Id）。
        /// Q02：遮挡草叶在背面挡住 charcoal 的 leaf_powder。留空 = 不遮挡任何目标。
        /// </summary>
        public string OccludesObjectId;

        public MiniGameFlipObject() { }

        public MiniGameFlipObject(string id, string label, Vector2 pos, Vector2 size, int sortOrder)
        {
            Id = id;
            Label = label;
            Pos = pos;
            Size = size;
            SortOrder = sortOrder;
        }
    }

    /// <summary>程序化形状（无贴图时的占位；有 SpritePath 时忽略）。</summary>
    public enum FlipShape
    {
        Rect,
        Ellipse,
        /// <summary>细长叶片：椭圆旋转一个角度。</summary>
        Leaf,
    }

    /// <summary>
    /// 单局的内容数据：文案、卡面、目标坐标、资源引用。
    /// 模板代码只认这份数据，换局 = 换一份 Content + 一条 Def，不写新代码（§15.4 / §18.1 M3）。
    /// </summary>
    [Serializable]
    public sealed class MiniGameContent
    {
        public string Key;
        public string BackgroundKey;

        /// <summary>
        /// T7 重听用的对话节点定位（§12.6 / §12.6.1）：只存模块名 + 语义节点前缀（DocTag），
        /// 运行时从 DialogueDatabase 取原文逐句显示，Content 里绝不存台词副本（会与原表不同步）。
        /// 用前缀而非 id 区间，是因为对话表里有插入的分支句（如 1-A#6b 的 id 是 200），
        /// 连续区间会漏；运行时按 DocTag 前缀取、按 id 排序即可完整还原该段。
        /// ReplayModule 为空表示该局不提供重听（非证词局）。
        /// </summary>
        public string ReplayModule;
        public string ReplayTag;

        /// <summary>
        /// 主区底图：Resources 下的 sprite 路径（相对 Resources，如 "MiniGameArt/ConceptB01_Haystack"）。
        /// 概念图/正式图到位后填这里，MiniGameBoard 在 Body 里统一铺一张、层级在可交互物之下。
        /// 空则不贴图（沿用透明 BodyBg）。资源缺失时静默跳过，不阻塞玩法。
        /// </summary>
        public string BackgroundResource;

        /// <summary>
        /// 主区里的目标点。Pos 用「主区左上为原点、y 向下」的美术坐标（§4.1），
        /// 由 MiniGameBoard.BodyPoint 换算，不要在这里混用中心坐标。
        /// </summary>
        public MiniGameTarget[] Targets = new MiniGameTarget[0];

        /// <summary>卡面 / 图块文字（T7 的要点、T4 的块名）。</summary>
        public string[] Labels = new string[0];

        /// <summary>T5 的分段数、T4 的格数这类纯数量约束。</summary>
        public int SlotCount;

        // ---------------- M2：七模板各自需要的形状 ----------------

        /// <summary>T7 的槽 / T4 的格。</summary>
        public MiniGameSlot[] Slots = new MiniGameSlot[0];

        /// <summary>T7 的卡。</summary>
        public MiniGameCard[] Cards = new MiniGameCard[0];

        /// <summary>T5 的三段揭露区。</summary>
        public MiniGameSegment[] Segments = new MiniGameSegment[0];

        /// <summary>T3 的两个观察面（单物体简写；多物体局改用 FlipObjects）。</summary>
        public MiniGameFace[] Faces = new MiniGameFace[0];

        /// <summary>
        /// T3 多物体翻转布局（§8.10）。非空时 RotateBoard 走多物体路径；
        /// 空数组时走旧的单物体 Faces 路径，Q12 / Q15 / Q18 不受影响。
        /// </summary>
        public MiniGameFlipObject[] FlipObjects = new MiniGameFlipObject[0];

        public MiniGameTarget Target(string id)
        {
            if (Targets == null) return null;
            for (var i = 0; i < Targets.Length; i++)
                if (Targets[i] != null && Targets[i].Id == id) return Targets[i];
            return null;
        }

        public MiniGameSlot Slot(string id)
        {
            if (Slots == null) return null;
            for (var i = 0; i < Slots.Length; i++)
                if (Slots[i] != null && Slots[i].Id == id) return Slots[i];
            return null;
        }

        public MiniGameCard Card(string id)
        {
            if (Cards == null) return null;
            for (var i = 0; i < Cards.Length; i++)
                if (Cards[i] != null && Cards[i].Id == id) return Cards[i];
            return null;
        }

        /// <summary>
        /// 浅拷贝一份供单局专用。注册表 / 样例里的内容是共享的，
        /// 模板运行时（尤其 Debug 增减卡）会改写 Cards，不隔离就会污染下一局。
        /// 数组元素本身在运行时不被改写，浅拷贝足够。
        /// </summary>
        public MiniGameContent Clone()
        {
            return new MiniGameContent
            {
                Key = Key,
                BackgroundKey = BackgroundKey,
                ReplayModule = ReplayModule,
                ReplayTag = ReplayTag,
                BackgroundResource = BackgroundResource,
                Targets = (MiniGameTarget[])Targets.Clone(),
                Labels = (string[])Labels.Clone(),
                SlotCount = SlotCount,
                Slots = (MiniGameSlot[])Slots.Clone(),
                Cards = (MiniGameCard[])Cards.Clone(),
                Segments = (MiniGameSegment[])Segments.Clone(),
                Faces = (MiniGameFace[])Faces.Clone(),
                FlipObjects = (MiniGameFlipObject[])FlipObjects.Clone(),
            };
        }

        /// <summary>M1 自检用的最小内容：三张卡、三个槽。</summary>
        public static MiniGameContent DebugDefault()
        {
            return new MiniGameContent
            {
                Key = "debug",
                SlotCount = 3,
                Labels = new[] { "卡 A", "卡 B", "卡 C" },
                Targets = new[]
                {
                    new MiniGameTarget("s1", "槽 1", new Vector2(200f, 160f), 110f),
                    new MiniGameTarget("s2", "槽 2", new Vector2(642f, 160f), 110f),
                    new MiniGameTarget("s3", "槽 3", new Vector2(1085f, 160f), 110f),
                },
            };
        }
    }
}
