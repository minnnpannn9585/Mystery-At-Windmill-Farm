using System.Collections.Generic;

namespace EggRescue.MiniGame.Hooks
{
    /// <summary>
    /// 证词局「节点级拦截点」（19 文档 §19.3.2）。
    ///
    /// 为什么不用 MiniGameDialogueHook 的「对白由真变假」方案：
    ///   · Q05/Q07/Q13 的末节点 Next 不是 -1 而是回 hub（182/205），对白不会在那结束；
    ///   · 变量在对白节点**进入时**就写（DialogueManager.ApplySetVariables），
    ///     等对白结束再开小游戏，线索早已发——违反 §19.8「成功前不发线索」。
    ///
    /// 正确时机：末节点对白照常播完 → 玩家点「下一句」准备离开时拦截 → 开小游戏 →
    /// 成功才执行该节点原有 SetVariables 并走原出口；未完成则关对白、不发变量。
    ///
    /// 用「模块名 + 节点 id」精确定位，不改任何对话 JSON（FROM_DOC 数据保持权威）。
    /// </summary>
    public sealed class MiniGameDialogueGate
    {
        public readonly string Module;
        public readonly int NodeId;
        public readonly string DefId;

        /// <summary>Q04 专用：恢复前若该 int 变量 ≥ 阈值，作废未结算的偷听记录（§19.3.2）。</summary>
        public readonly string VoidIfVar;
        public readonly int VoidIfValue;

        public MiniGameDialogueGate(string module, int nodeId, string defId,
            string voidIfVar = null, int voidIfValue = 0)
        {
            Module = module;
            NodeId = nodeId;
            DefId = defId;
            VoidIfVar = voidIfVar;
            VoidIfValue = voidIfValue;
        }
    }

    public static class MiniGameDialogueGates
    {
        static readonly Dictionary<string, MiniGameDialogueGate> Index = Build();

        static Dictionary<string, MiniGameDialogueGate> Build()
        {
            var map = new Dictionary<string, MiniGameDialogueGate>();
            Add(map, new MiniGameDialogueGate("shufang_01_FROM_DOC", 201, "Q01"));                 // 1-A#13b → Shufen_CommissionDone
            Add(map, new MiniGameDialogueGate("xiaojiZTT_e03_FROM_DOC", 7, "Q04", "ChickStatus", 3));// 1-A#7 → E03_Overheard（作废规则）
            Add(map, new MiniGameDialogueGate("xiaojiZTT_01_FROM_DOC", 44, "Q05"));                 // 2-B#21 → ChickStatus=2
            Add(map, new MiniGameDialogueGate("qingwa_01_FROM_DOC", 39, "Q07"));                    // 2-D#16 → Frog_WaterMonsterQueried
            Add(map, new MiniGameDialogueGate("dahuang_01_FROM_DOC", 10, "Q08"));                   // 1-A#10 → DogStatus=2
            Add(map, new MiniGameDialogueGate("xiaojiZTT_01_FROM_DOC", 110, "Q13"));                // 2-E#37 → ChickStatus=3（入口 A）
            Add(map, new MiniGameDialogueGate("xiaojiZTT_01_FROM_DOC", 216, "Q13"));                // 2-G#17 → ChickStatus=3（入口 B 补漏）
            Add(map, new MiniGameDialogueGate("qingwa_01_FROM_DOC", 423, "Q06"));                   // 3-A#supplement#set → E12 补录
            return map;
        }

        static void Add(Dictionary<string, MiniGameDialogueGate> map, MiniGameDialogueGate gate)
        {
            map[Key(gate.Module, gate.NodeId)] = gate;
        }

        static string Key(string module, int nodeId)
        {
            return (module ?? string.Empty) + ":" + nodeId;
        }

        public static MiniGameDialogueGate Find(string module, int nodeId)
        {
            MiniGameDialogueGate gate;
            return Index.TryGetValue(Key(module, nodeId), out gate) ? gate : null;
        }
    }
}
