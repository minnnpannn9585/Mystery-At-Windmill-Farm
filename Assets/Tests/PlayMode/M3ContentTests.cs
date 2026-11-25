using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using NUnit.Framework;

namespace EggRescue.Tests.PlayMode
{
    /// <summary>
    /// M3 数据验收：19 局 + Q12 续段的内容完整性，逐条对齐技术文档附录 A。
    /// 纯数据断言，不打开小游戏、不进 Play 交互，用反射访问 Assembly-CSharp。
    ///
    /// 覆盖：
    ///   · 20 份 Content（19 局 + Q12B）全部可取、字段不空。
    ///   · 每局模板与内容形状匹配（放大镜有目标、T7 有槽有卡、T3 有面…）。
    ///   · Mode：Q03=Count、Q16=Step、Q17=Coverage、其余 Discrete。
    ///   · 附录 A 提交变量：bool 局 / 整型状态局 / 计数变量逐条核对。
    ///   · Q12 两段：主表无提交变量，提交挂 Q12B。
    /// </summary>
    public class M3ContentTests
    {
        const BindingFlags Inst = BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public;
        const BindingFlags Stat = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

        Type _tReg, _tContents, _tMode, _tContent;

        [SetUp]
        public void SetUp()
        {
            _tReg = FindType("EggRescue.MiniGame.MiniGameRegistry");
            _tContents = FindType("EggRescue.MiniGame.MiniGameContents");
            _tMode = FindType("EggRescue.MiniGame.JudgeMode");
            _tContent = FindType("EggRescue.MiniGame.MiniGameContent");
            Assert.IsNotNull(_tReg, "MiniGameRegistry 未找到");
            Assert.IsNotNull(_tContents, "MiniGameContents 未找到");
            Assert.IsNotNull(_tMode, "JudgeMode 未找到");
        }

        // ---------------- 内容完整性 ----------------

        [Test]
        public void AllNineteenDefs_HaveContent()
        {
            var all = (System.Collections.IEnumerable)_tReg.GetProperty("All", Stat).GetValue(null, null);
            var count = 0;
            foreach (var def in all)
            {
                var id = GetStr(def, "Id");
                var content = Call(_tReg, "Content", new[] { typeof(object) }, def);
                Assert.IsNotNull(content, "局 " + id + " 取不到 Content");
                Assert.AreEqual(id, GetStr(content, "Key"), "局 " + id + " 的 Content.Key 不匹配");
                count++;
            }
            Assert.AreEqual(19, count, "正式局数量应为 19");
        }

        [Test]
        public void Q12Continuation_HasRotateContent()
        {
            var def = _tReg.GetProperty("Q12Continuation", Stat).GetValue(null, null);
            Assert.IsNotNull(def, "Q12Continuation 未找到");
            Assert.AreEqual("Q12B", GetStr(def, "Id"));
            var content = Call(_tReg, "Content", new[] { typeof(object) }, def);
            Assert.IsNotNull(content, "Q12B 取不到 Content");
            // T3 续段：两面、两目标、无槽无卡
            Assert.AreEqual(2, Arr(content, "Faces").Length, "Q12B 应有两面");
            Assert.AreEqual(2, Arr(content, "Targets").Length, "Q12B 应有两处目标");
        }

        [Test]
        public void EveryContent_HasExpectedShape()
        {
            // 局 → (目标数, 槽数, 卡数, 面数, 段数)
            var shape = new Dictionary<string, int[]>
            {
                { "Q01", new[] { 0, 2, 3, 0, 0 } },
                { "Q02", new[] { 2, 0, 0, 2, 0 } },
                { "Q03", new[] { 3, 1, 0, 0, 0 } },
                { "Q04", new[] { 0, 3, 3, 0, 0 } },
                { "Q05", new[] { 0, 3, 3, 0, 0 } },
                { "Q06", new[] { 2, 0, 0, 0, 0 } },
                { "Q07", new[] { 0, 3, 3, 0, 0 } },
                { "Q08", new[] { 0, 3, 3, 0, 0 } },
                { "Q09", new[] { 2, 0, 0, 0, 0 } },
                { "Q10", new[] { 2, 1, 0, 0, 2 } },
                { "Q11", new[] { 2, 0, 0, 0, 0 } },
                { "Q12", new[] { 1, 1, 0, 0, 3 } },
                { "Q13", new[] { 0, 2, 3, 0, 0 } },
                { "Q14", new[] { 2, 0, 0, 0, 0 } },
                { "Q15", new[] { 2, 0, 0, 2, 0 } },
                { "Q16", new[] { 1, 1, 0, 0, 0 } },
                { "Q17", new[] { 0, 0, 0, 0, 3 } },
                { "Q18", new[] { 2, 0, 0, 2, 0 } },
                { "Q19", new[] { 0, 6, 0, 0, 0 } },
                { "Q12B", new[] { 2, 0, 0, 2, 0 } },
            };

            foreach (var kv in shape)
            {
                var content = Call(_tContents, "For", new[] { typeof(string) }, kv.Key);
                Assert.IsNotNull(content, kv.Key + " 无 Content");
                var want = kv.Value;
                Assert.AreEqual(want[0], Arr(content, "Targets").Length, kv.Key + " Targets 数量");
                Assert.AreEqual(want[1], Arr(content, "Slots").Length, kv.Key + " Slots 数量");
                Assert.AreEqual(want[2], Arr(content, "Cards").Length, kv.Key + " Cards 数量");
                Assert.AreEqual(want[3], Arr(content, "Faces").Length, kv.Key + " Faces 数量");
                Assert.AreEqual(want[4], Arr(content, "Segments").Length, kv.Key + " Segments 数量");
            }
        }

        // ---------------- 判定模式 ----------------

        [Test]
        public void JudgeModes_ArePerDef()
        {
            var expect = new Dictionary<string, string>
            {
                { "Q03", "Count" }, { "Q16", "Step" }, { "Q17", "Coverage" },
            };
            foreach (var kv in expect)
            {
                var def = Call(_tReg, "Get", new[] { typeof(string) }, kv.Key);
                Assert.IsNotNull(def, kv.Key + " Def 未找到");
                var mode = GetField(def, "Mode");
                Assert.IsNotNull(mode, kv.Key + " Mode 未找到");
                Assert.AreEqual(kv.Value, mode.ToString(), kv.Key + " 判定模式");
            }
            // 抽查一局默认 Discrete
            var q01 = Call(_tReg, "Get", new[] { typeof(string) }, "Q01");
            Assert.AreEqual("Discrete", GetField(q01, "Mode").ToString(), "Q01 应为 Discrete");
        }

        // ---------------- 附录 A：提交变量逐条核对 ----------------

        [Test]
        public void SubmitVars_MatchAppendixA()
        {
            // id → (SubmitVar, SubmitIsInt, IntValue, CountVar)
            var book = new Dictionary<string, string[]>
            {
                { "Q01", new[] { "Shufen_CommissionDone", "False", "0", "" } },
                { "Q02", new[] { "E01_ViewCharcoal", "False", "0", "ChickTraceCount" } },
                { "Q03", new[] { "E02_ViewFeather", "False", "0", "ChickTraceCount" } },
                { "Q04", new[] { "E03_Overheard", "False", "0", "ChickTraceCount" } },
                { "Q05", new[] { "ChickStatus", "True", "2", "" } },
                { "Q06", new[] { "E12_ViewGreenPad", "False", "0", "" } },
                { "Q07", new[] { "Frog_WaterMonsterQueried", "False", "0", "" } },
                { "Q08", new[] { "DogStatus", "True", "2", "" } },
                { "Q09", new[] { "E05_GrainSoakGet", "False", "0", "" } },
                { "Q10", new[] { "E07_ViewNapSpot", "False", "0", "" } },
                { "Q11", new[] { "E08_ViewBurnMark", "False", "0", "" } },
                { "Q12", new[] { "", "False", "0", "" } }, // 提交挪到 Q12B
                { "Q13", new[] { "ChickStatus", "True", "3", "" } },
                { "Q14", new[] { "E14_ViewCatDoor", "False", "0", "TreeClueCount" } },
                { "Q15", new[] { "E15_ViewFoodBowl", "False", "0", "TreeClueCount" } },
                { "Q16", new[] { "E16_ViewFur", "False", "0", "TreeClueCount" } },
                { "Q17", new[] { "E28_ViewTreeScratch", "False", "0", "TreeClueCount" } },
                { "Q18", new[] { "E17_ViewEmptyBucket", "False", "0", "" } },
                { "Q19", new[] { "E18_ViewBootprints", "False", "0", "" } },
            };

            foreach (var kv in book)
            {
                var def = Call(_tReg, "Get", new[] { typeof(string) }, kv.Key);
                Assert.IsNotNull(def, kv.Key + " Def 未找到");
                Assert.AreEqual(kv.Value[0], GetStr(def, "SubmitVar") ?? "", kv.Key + " SubmitVar");
                Assert.AreEqual(kv.Value[1], GetField(def, "SubmitIsInt").ToString(), kv.Key + " SubmitIsInt");
                Assert.AreEqual(kv.Value[2], GetField(def, "IntSubmitValue").ToString(), kv.Key + " IntSubmitValue");
                Assert.AreEqual(kv.Value[3], GetStr(def, "CountVar") ?? "", kv.Key + " CountVar");
            }

            var q12b = _tReg.GetProperty("Q12Continuation", Stat).GetValue(null, null);
            Assert.AreEqual("E10_ViewWhiteStone", GetStr(q12b, "SubmitVar"), "Q12B 应提交 E10_ViewWhiteStone");
        }

        // ---------------- 原文要点抽查 ----------------

        [Test]
        public void T7_CardTexts_AreVerbatim()
        {
            // Q07 排序题：三句隐语原文，标点照搬（§12.6.1）
            var q07 = Call(_tContents, "For", new[] { typeof(string) }, "Q07");
            var cards = Arr(q07, "Cards");
            var texts = cards.Cast<object>().Select(c => GetStr(c, "Text")).ToArray();
            Assert.Contains("纯净，第一个死去。", texts);
            Assert.Contains("冰冷的器皿来了。生命之源在枯竭。", texts);
            Assert.Contains("一个黑色的恶魔……它带走了宝珠。", texts);

            // Q01 干扰卡 SlotId 必须为空
            var q01 = Call(_tContents, "For", new[] { typeof(string) }, "Q01");
            var plain = Arr(q01, "Cards").Cast<object>().First(c => GetStr(c, "Text") == "普通的蛋");
            Assert.IsNull(GetStr(plain, "SlotId"), "普通的蛋应为干扰卡，SlotId 留空");

            // Q13 第一槽容量 2（一槽多卡）
            var q13 = Call(_tContents, "For", new[] { typeof(string) }, "Q13");
            var firstSlot = Arr(q13, "Slots").GetValue(0);
            Assert.AreEqual(2, Convert.ToInt32(GetField(firstSlot, "Capacity")), "Q13 第一槽应容纳 2 张卡");
        }

        // ---------------- 反射工具 ----------------

        static object Call(Type type, string method, Type[] sig, params object[] args)
        {
            // 这些工厂/查询方法都没有重载；按名字取即可，避免签名写死 typeof(object) 与实际参数类型不符。
            var m = type.GetMethod(method, Stat);
            Assert.IsNotNull(m, type.Name + "." + method + " 未找到");
            return m.Invoke(null, args);
        }

        static object GetField(object obj, string name)
        {
            var f = obj.GetType().GetField(name, Inst);
            Assert.IsNotNull(f, obj.GetType().Name + "." + name + " 字段未找到");
            return f.GetValue(obj);
        }

        static string GetStr(object obj, string name)
        {
            var f = obj.GetType().GetField(name, Inst);
            return f == null ? null : f.GetValue(obj) as string;
        }

        static Array Arr(object obj, string name)
        {
            var f = obj.GetType().GetField(name, Inst);
            Assert.IsNotNull(f, obj.GetType().Name + "." + name + " 字段未找到");
            return (Array)f.GetValue(obj);
        }

        static Type FindType(string fullName)
        {
            foreach (var asm in AppDomain.CurrentDomain.GetAssemblies())
            {
                var t = asm.GetType(fullName);
                if (t != null) return t;
            }
            return null;
        }
    }
}
