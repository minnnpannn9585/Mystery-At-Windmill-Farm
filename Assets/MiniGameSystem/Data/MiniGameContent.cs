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
    /// 单局的内容数据：文案、卡面、目标坐标、资源引用。
    /// 模板代码只认这份数据，换局 = 换一份 Content + 一条 Def，不写新代码（§15.4 / §18.1 M3）。
    /// </summary>
    [Serializable]
    public sealed class MiniGameContent
    {
        public string Key;
        public string BackgroundKey;

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

        /// <summary>T3 的两个观察面。</summary>
        public MiniGameFace[] Faces = new MiniGameFace[0];

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
