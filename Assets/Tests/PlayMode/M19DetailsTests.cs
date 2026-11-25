using System;
using System.Collections.Generic;
using System.Reflection;
using NUnit.Framework;

namespace EggRescue.Tests.PlayMode
{
    /// <summary>
    /// 19 文档细节验收：架构沿用技术文档，细节以 19-关键线索调查解谜.md 为准。
    /// 覆盖：
    ///   · 19 局均有两级提示，一级/二级逐字取自 19 文档（不为空、两段不同）。
    ///   · 六个证词局的 ReplayModule / ReplayTag 定位正确，且原文可从对话表取到。
    ///   · Q12 的 ContinuationId 指向 Q12B；Q12B 可按 id 查到。
    /// 纯数据断言，用反射访问 Assembly-CSharp（与 M3ContentTests 同一策略）。
    /// </summary>
    public class M19DetailsTests
    {
        const BindingFlags Stat = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

        Type _tReg, _tScript, _tContents, _tDb, _tGraph;

        [SetUp]
        public void SetUp()
        {
            _tReg = FindType("EggRescue.MiniGame.MiniGameRegistry");
            _tScript = FindType("EggRescue.MiniGame.MiniGameScript");
            _tContents = FindType("EggRescue.MiniGame.MiniGameContents");
            _tDb = FindType("EggRescue.DialogueDatabase");
            _tGraph = FindType("EggRescue.DialogueGraph");
            Assert.IsNotNull(_tReg, "MiniGameRegistry 未找到");
            Assert.IsNotNull(_tScript, "MiniGameScript 未找到");
            Assert.IsNotNull(_tContents, "MiniGameContents 未找到");
        }

        [Test]
        public void EveryDef_HasTwoDistinctHints()
        {
            var all = (System.Collections.IEnumerable)_tReg.GetProperty("All", Stat).GetValue(null, null);
            var n = 0;
            foreach (var def in all)
            {
                var id = GetStr(def, "Id");
                var hints = (string[])GetVal(def, "Hints");
                Assert.IsNotNull(hints, id + " Hints 为空");
                Assert.AreEqual(2, hints.Length, id + " 应有两级提示");
                Assert.IsFalse(string.IsNullOrEmpty(hints[0]), id + " 一级提示为空");
                Assert.IsFalse(string.IsNullOrEmpty(hints[1]), id + " 二级提示为空");
                Assert.AreNotEqual(hints[0], hints[1], id + " 两级提示不应相同");
                n++;
            }
            Assert.AreEqual(19, n);
        }

        // 六局：局 id → (模块, DocTag 前缀, 期望至少几句)
        static readonly string[][] ReplayJobs =
        {
            new[] { "Q01", "shufang_01_FROM_DOC",   "1-A", "10" },
            new[] { "Q04", "xiaojiZTT_e03_FROM_DOC","1-A", "5"  },
            new[] { "Q05", "xiaojiZTT_01_FROM_DOC", "2-B", "10" },
            new[] { "Q07", "qingwa_01_FROM_DOC",    "2-D", "10" },
            new[] { "Q08", "dahuang_01_FROM_DOC",   "1-A", "8"  },
            new[] { "Q13", "xiaojiZTT_01_FROM_DOC", "2-E", "10" },
        };

        [Test]
        public void TestimonyDefs_HaveReplayLocation()
        {
            foreach (var job in ReplayJobs)
            {
                var content = Call(_tContents, "For", job[0]);
                Assert.IsNotNull(content, job[0] + " 无 Content");
                Assert.AreEqual(job[1], GetStr(content, "ReplayModule"), job[0] + " ReplayModule 不符");
                Assert.AreEqual(job[2], GetStr(content, "ReplayTag"), job[0] + " ReplayTag 不符");
            }
        }

        [Test]
        public void ReplayLocation_CanFetchOriginalLines()
        {
            // 对话表由 GameBootstrap 载入；这里只验证按 (模块, DocTag 前缀) 能取到原文。
            Call(_tDb, "LoadAll");
            foreach (var job in ReplayJobs)
            {
                var graph = Call(_tDb, "Get", job[1]);
                Assert.IsNotNull(graph, "对话模块 " + job[1] + " 未载入");
                var nodes = GetVal(graph, "Nodes") as System.Collections.IDictionary;
                Assert.IsNotNull(nodes, job[1] + " Nodes 为空");

                var prefix = job[2] + "#";
                var found = 0;
                foreach (System.Collections.DictionaryEntry kv in nodes)
                {
                    var node = kv.Value;
                    var tag = GetStr(node, "DocTag");
                    if (!string.IsNullOrEmpty(tag) && tag.StartsWith(prefix)) found++;
                }
                Assert.GreaterOrEqual(found, int.Parse(job[3]),
                    job[0] + " 原文句数不足：" + found);
            }
        }

        [Test]
        public void Q12_HasContinuationToQ12B()
        {
            var all = (System.Collections.IEnumerable)_tReg.GetProperty("All", Stat).GetValue(null, null);
            object q12 = null;
            foreach (var def in all) if (GetStr(def, "Id") == "Q12") q12 = def;
            Assert.IsNotNull(q12, "Q12 未找到");
            Assert.AreEqual("Q12B", GetStr(q12, "ContinuationId"), "Q12 应接 Q12B");

            var byId = Call(_tReg, "Get", "Q12B");
            Assert.IsNotNull(byId, "按 id 查不到 Q12B");
            Assert.AreEqual("Q12B", GetStr(byId, "Id"));
        }

        // ---------------- 反射辅助 ----------------

        static Type FindType(string name)
        {
            foreach (var a in AppDomain.CurrentDomain.GetAssemblies())
            {
                var t = a.GetType(name, false);
                if (t != null) return t;
            }
            return null;
        }

        static object GetVal(object obj, string field)
        {
            if (obj == null) return null;
            var t = obj.GetType();
            var f = t.GetField(field, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            if (f != null) return f.GetValue(obj);
            var p = t.GetProperty(field, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
            return p != null ? p.GetValue(obj, null) : null;
        }

        static string GetStr(object obj, string field)
        {
            var v = GetVal(obj, field);
            return v == null ? null : v.ToString();
        }

        static object Call(Type type, string method, params object[] args)
        {
            var argTypes = new Type[args.Length];
            for (var i = 0; i < args.Length; i++) argTypes[i] = args[i] == null ? typeof(object) : args[i].GetType();
            var m = type.GetMethod(method, Stat, null, argTypes, null);
            if (m == null)
                foreach (var mi in type.GetMethods(Stat))
                    if (mi.Name == method && mi.GetParameters().Length == args.Length) { m = mi; break; }
            Assert.IsNotNull(m, "方法未找到: " + type.Name + "." + method);
            return m.Invoke(null, args);
        }
    }
}
