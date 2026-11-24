using System;
using System.Collections;
using System.Reflection;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace EggRescue.Tests.PlayMode
{
    /// <summary>
    /// T7（证词归位）错误卡回位的自动化回归测试。
    ///
    /// 背景：F7 曾经打开 M1 的 DEBUG-01（DebugBoard），它的错位设计是「留存」，
    /// 跟 T7 的「闪后回位」相反，导致肉眼测 F7 永远看不到 T7 的真实行为。
    /// 本测试直接开真正的 T7 板，用反射驱动一张卡放进错误槽，等闪烁+回位跑完，
    /// 断言卡片精确回到「拖拽前的起点」且不被判为已放置。
    ///
    /// 用反射访问 EggRescue.MiniGame 类型，避免测试程序集对 Assembly-CSharp 的编译期依赖。
    /// </summary>
    public class T7RejectReturnTests
    {
        const BindingFlags Inst = BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public;
        const BindingFlags Stat = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

        Type _tPiece, _tTarget, _tBoard, _tHost, _tRunner, _tRegistry, _tTemplate;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            _tPiece = FindType("EggRescue.MiniGame.MiniGamePiece");
            _tTarget = FindType("EggRescue.MiniGame.DropTarget");
            _tBoard = FindType("EggRescue.MiniGame.MiniGameBoard");
            _tHost = FindType("EggRescue.MiniGame.MiniGameHost");
            _tRunner = FindType("EggRescue.MiniGame.MiniGameHostRunner");
            _tRegistry = FindType("EggRescue.MiniGame.MiniGameRegistry");
            _tTemplate = FindType("EggRescue.MiniGame.MiniGameTemplate");
            Assert.IsNotNull(_tPiece, "MiniGamePiece 类型未找到");
            Assert.IsNotNull(_tHost, "MiniGameHost 类型未找到");

            // 确保没有上一局残留
            CloseAnyGame();
            yield return null;
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            CloseAnyGame();
            yield return null;
        }

        [UnityTest]
        public IEnumerator WrongCard_FlashesThenReturnsToDragOrigin()
        {
            // 1) 用 def 重载开真正的 T7 自检局（sample def 不在 Registry.Index 里）
            var def = SampleDef_Testimony();
            Assert.IsNotNull(def, "T7 sample def 为空");
            var open = _tHost.GetMethod("Open", new[] { def.GetType(), typeof(Action) });
            Assert.IsNotNull(open, "MiniGameHost.Open(def, Action) 未找到");
            var opened = (bool)open.Invoke(null, new object[] { def, null });
            Assert.IsTrue(opened, "T7 自检局打开失败");

            // 等入场动画 + board 建好
            yield return new WaitForSecondsRealtime(0.6f);
            var board = CurrentBoard();
            Assert.IsNotNull(board, "T7 board 为空");
            Assert.AreEqual("TestimonyBoard", board.GetType().Name, "F7/T7 入口没有落到 TestimonyBoard");

            // 2) 找 k1（归属 s1）与错误槽 s2
            object pieceK1 = null, targetS2 = null;
            var pieces = (IList)_tBoard.GetField("Pieces", Inst).GetValue(board);
            var targets = (IList)_tBoard.GetField("Targets", Inst).GetValue(board);
            foreach (var p in pieces)
                if (GetStr(p, "Id") == "k1") { pieceK1 = p; break; }
            foreach (var t in targets)
                if (GetStr(t, "Id") == "s2") { targetS2 = t; break; }
            Assert.IsNotNull(pieceK1, "找不到 k1");
            Assert.IsNotNull(targetS2, "找不到错误槽 s2");

            var origin = ((RectTransform)_tPiece.GetField("Rect", Inst).GetValue(pieceK1)).anchoredPosition;

            // 3) 起手 → 拖到错槽中心 → 松手
            _tBoard.GetMethod("BeginCarry", Inst).Invoke(board, new[] { pieceK1, origin });
            var dropPoint = (Vector2)_tTarget.GetField("Center", Inst).GetValue(targetS2);
            var handleObj = _tPiece.GetField("Handle", Inst).GetValue(pieceK1);
            handleObj.GetType().GetMethod("SyncTo", Inst).Invoke(handleObj, new object[] { dropPoint });
            _tBoard.GetField("_pressScreen", Inst).SetValue(board, new Vector2(-99999f, -99999f));
            _tBoard.GetMethod("ReleaseCarry", Inst).Invoke(board, new object[] { (Vector2?)dropPoint });

            // 4) 等闪烁（0.96s）+ 回位（0.22s）+ 余量
            yield return new WaitForSecondsRealtime(2.5f);

            // 5) 断言：回到起点、handle 同步、未卡在回位中、未被判为已放置
            var rect = (RectTransform)_tPiece.GetField("Rect", Inst).GetValue(pieceK1);
            var handleObj2 = _tPiece.GetField("Handle", Inst).GetValue(pieceK1);
            var rectPos = rect.anchoredPosition;
            var handlePos = ReadVector2(handleObj2, "LocalPosition");
            Assert.Less(Vector2.Distance(rectPos, origin), 0.5f,
                "错误卡没有回到拖拽前起点：rect=" + rectPos + " origin=" + origin);
            Assert.Less(Vector2.Distance(handlePos, origin), 0.5f,
                "错误卡 handle 未与起点同步：" + handlePos);
            Assert.IsFalse((bool)_tPiece.GetField("Returning", Inst).GetValue(pieceK1),
                "回位结束后 Returning 仍为 true（卡被锁死）");
            Assert.IsFalse((bool)_tPiece.GetField("Placed", Inst).GetValue(pieceK1),
                "错误卡被错误地判为已放置/留在槽里");
        }

        // ---- helpers ----

        static Type FindType(string fullName)
        {
            foreach (var asm in AppDomain.CurrentDomain.GetAssemblies())
            {
                var t = asm.GetType(fullName);
                if (t != null) return t;
            }
            return null;
        }

        object SampleDef_Testimony()
        {
            var template = Enum.Parse(_tTemplate, "Testimony");
            var sample = _tRegistry.GetMethods(Stat);
            MethodInfo sampleMi = null;
            foreach (var m in sample) if (m.Name == "Sample") { sampleMi = m; break; }
            Assert.IsNotNull(sampleMi, "MiniGameRegistry.Sample 未找到");
            var ps = sampleMi.GetParameters();
            var args = new object[ps.Length];
            args[0] = template;
            for (var i = 1; i < ps.Length; i++)
                args[i] = ps[i].ParameterType.IsValueType
                    ? Activator.CreateInstance(ps[i].ParameterType)
                    : null;
            return sampleMi.Invoke(null, args);
        }

        object CurrentBoard()
        {
            var runner = _tHost.GetProperty("Runner", Stat).GetValue(null, null);
            if (runner == null) return null;
            return _tRunner.GetField("_board", Inst).GetValue(runner);
        }

        void CloseAnyGame()
        {
            var isOpen = (bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null);
            if (!isOpen) return;
            var close = _tHost.GetMethod("Close", Stat);
            close.Invoke(null, null);
        }

        static string GetStr(object obj, string field)
        {
            var f = obj.GetType().GetField(field, Inst);
            return f != null ? f.GetValue(obj) as string : null;
        }

        static Vector2 ReadVector2(object obj, string name)
        {
            var t = obj.GetType();
            var f = t.GetField(name, Inst);
            if (f != null) return (Vector2)f.GetValue(obj);
            var p = t.GetProperty(name, Inst);
            if (p != null) return (Vector2)p.GetValue(obj, null);
            throw new MissingMemberException(t.FullName, name);
        }
    }
}
