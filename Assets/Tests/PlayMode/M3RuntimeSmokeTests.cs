using System;
using System.Collections;
using System.Linq;
using System.Reflection;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace EggRescue.Tests.PlayMode
{
    /// <summary>
    /// M3 运行时冒烟：用正式 Def（不是 Sample）逐模板打开一局，
    /// 确认 MiniGameHost 能拿到 Content、Board 能消费它并建成、Judge.Total 正确。
    /// 这是「数据在但板子吃不下」这类问题的最后一道闸。
    ///
    /// 每个模板挑一局代表：
    ///   T1=Q06  T2=Q10  T3=Q02  T4=Q19  T5=Q17  T6=Q03(Count)/Q16(Step)  T7=Q01
    /// 外加 Q12 两段（Q12 拨草 → Q12B 翻转）。
    /// </summary>
    public class M3RuntimeSmokeTests
    {
        const BindingFlags Inst = BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public;
        const BindingFlags Stat = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

        Type _tHost, _tRunner, _tRegistry, _tBoard, _tJudge;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            _tHost = FindType("EggRescue.MiniGame.MiniGameHost");
            _tRunner = FindType("EggRescue.MiniGame.MiniGameHostRunner");
            _tRegistry = FindType("EggRescue.MiniGame.MiniGameRegistry");
            _tBoard = FindType("EggRescue.MiniGame.MiniGameBoard");
            _tJudge = FindType("EggRescue.MiniGame.JudgeStep");
            Assert.IsNotNull(_tHost, "MiniGameHost 未找到");
            Assert.IsNotNull(_tRegistry, "MiniGameRegistry 未找到");
            yield return CloseAnyGame();
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            yield return CloseAnyGame();
        }

        [UnityTest]
        public IEnumerator EveryTemplate_CanOpenOfficialDef()
        {
            // (defId, 期望 Board 类型名, 期望 Judge.Total)
            var cases = new[]
            {
                new object[] { "Q06", "MagnifierBoard", 2 },
                new object[] { "Q10", "UncoverBoard", 2 },
                new object[] { "Q02", "RotateBoard", 2 },
                new object[] { "Q19", "JigsawBoard", 6 },
                new object[] { "Q17", "RubbingBoard", 3 },
                new object[] { "Q03", "TweezerBoard", 3 },
                new object[] { "Q16", "TweezerBoard", 2 },
                new object[] { "Q01", "TestimonyBoard", 2 },
            };

            foreach (var c in cases)
            {
                var id = (string)c[0];
                var boardType = (string)c[1];
                var total = (int)c[2];
                yield return OpenAndCheck(id, boardType, total);
            }
        }

        [UnityTest]
        public IEnumerator Q12_TwoStages_CanOpen()
        {
            // 前半：拨 3 束草，1 个目标
            yield return OpenAndCheck("Q12", "UncoverBoard", 1);
            // 后半（续段）：翻转双面，2 个目标
            yield return OpenContinuationAndCheck("Q12B", "RotateBoard", 2);
        }

        // ---------------- helpers ----------------

        IEnumerator OpenAndCheck(string defId, string boardTypeName, int expectedTotal)
        {
            yield return EnsureClosed();
            var def = _tRegistry.GetMethod("Get", Stat, null, new[] { typeof(string) }, null)
                .Invoke(null, new object[] { defId });
            Assert.IsNotNull(def, "Def 未找到：" + defId);

            var open = _tHost.GetMethod("Open", new[] { def.GetType(), typeof(Action) });
            Assert.IsTrue((bool)open.Invoke(null, new object[] { def, null }), "打开失败：" + defId + "（Content 可能缺失）");
            yield return new WaitForSecondsRealtime(0.5f);

            var board = CurrentBoard();
            Assert.IsNotNull(board, defId + " 的 board 为空");
            Assert.AreEqual(boardTypeName, board.GetType().Name, defId + " Board 类型不符");
            CheckJudgeTotal(board, expectedTotal, defId);
        }

        IEnumerator OpenContinuationAndCheck(string id, string boardTypeName, int expectedTotal)
        {
            yield return EnsureClosed();
            var def = _tRegistry.GetProperty("Q12Continuation", Stat).GetValue(null, null);
            Assert.AreEqual(id, def.GetType().GetField("Id").GetValue(def));

            var open = _tHost.GetMethod("Open", new[] { def.GetType(), typeof(Action) });
            Assert.IsTrue((bool)open.Invoke(null, new object[] { def, null }), "Q12B 打开失败");
            yield return new WaitForSecondsRealtime(0.5f);

            var board = CurrentBoard();
            Assert.IsNotNull(board, "Q12B board 为空");
            Assert.AreEqual(boardTypeName, board.GetType().Name, "Q12B Board 类型不符");
            CheckJudgeTotal(board, expectedTotal, "Q12B");
        }

        void CheckJudgeTotal(object board, int expected, string label)
        {
            var judgeField = _tBoard.GetField("Judge", Inst);
            Assert.IsNotNull(judgeField, "Judge 字段未找到");
            var judge = judgeField.GetValue(board);
            Assert.IsNotNull(judge, label + " Judge 为空");
            var totalField = judge.GetType().GetField("Total", Inst); // Inst 已含 Public
            Assert.IsNotNull(totalField, label + " Judge.Total 未找到");
            Assert.AreEqual(expected, Convert.ToInt32(totalField.GetValue(judge)),
                label + " 的 Judge.Total 与 Content 目标数不符");
        }

        IEnumerator EnsureClosed()
        {
            var isOpen = (bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null);
            if (!isOpen) yield break;
            _tHost.GetMethod("Close", Stat).Invoke(null, null);
            var wait = 0f;
            while ((bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null) && wait < 3f)
            {
                wait += 0.05f;
                yield return new WaitForSecondsRealtime(0.05f);
            }
        }

        IEnumerator CloseAnyGame()
        {
            yield return EnsureClosed();
        }

        object CurrentBoard()
        {
            var runner = _tHost.GetProperty("Runner", Stat).GetValue(null, null);
            return runner == null ? null : _tRunner.GetField("_board", Inst).GetValue(runner);
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
