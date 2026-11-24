using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using NUnit.Framework;
using UnityEngine;
using UnityEngine.TestTools;

namespace EggRescue.Tests.PlayMode
{
    /// <summary>
    /// T7 桌面堆叠 + 落位规则的回归测试。
    /// 覆盖：7 卡的错落堆叠（间距递减 / 投影 / 随机旋转）、悬浮置顶与还原、
    /// Debug 增减卡、以及「丢在空白处就地留下、不回原位」。
    /// 同样用反射访问 Assembly-CSharp，避免测试程序集引用难题。
    /// </summary>
    public class T7StackAndDropTests
    {
        const BindingFlags Inst = BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public;
        const BindingFlags Stat = BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public;

        Type _tBoard, _tHost, _tRunner, _tRegistry, _tTemplate, _tPiece;
        object _board;

        [UnitySetUp]
        public IEnumerator SetUp()
        {
            _tBoard = FindType("EggRescue.MiniGame.MiniGameBoard");
            _tHost = FindType("EggRescue.MiniGame.MiniGameHost");
            _tRunner = FindType("EggRescue.MiniGame.MiniGameHostRunner");
            _tRegistry = FindType("EggRescue.MiniGame.MiniGameRegistry");
            _tTemplate = FindType("EggRescue.MiniGame.MiniGameTemplate");
            _tPiece = FindType("EggRescue.MiniGame.MiniGamePiece");
            Assert.IsNotNull(_tBoard, "MiniGameBoard 类型未找到");
            Assert.IsNotNull(_tHost, "MiniGameHost 类型未找到");
            yield return CloseAnyGame();
        }

        [UnityTearDown]
        public IEnumerator TearDown()
        {
            yield return CloseAnyGame();
        }

        [UnityTest]
        public IEnumerator SevenCards_StackWithShadowAndRandomTilt()
        {
            yield return OpenT7();
            var t = _board.GetType();
            // T7 样例自带 4 张（k1~k3 + 干扰卡 k4）
            Assert.AreEqual(4, CardCount(t), "初始应是 4 张卡");

            var add = t.GetMethod("DebugAddCard");
            Assert.IsNotNull(add, "DebugAddCard 未找到");
            for (var i = 0; i < 3; i++) add.Invoke(_board, null);
            Assert.AreEqual(7, CardCount(t), "加到 7 张失败");
            yield return null;

            var cards = CardRects(t);
            Assert.AreEqual(7, cards.Count);

            // 每张卡有投影层
            foreach (var r in cards)
                Assert.IsNotNull(r.Find("Shadow"), "卡片缺少投影层：" + r.name);

            // 堆叠也要横向铺开：卡心跨度应在 800~1000，而不是挤成中间一小撮
            var minX = cards.Min(r => r.anchoredPosition.x);
            var maxX = cards.Max(r => r.anchoredPosition.x);
            var centerSpan = maxX - minX;
            Assert.Greater(centerSpan, 800f, "7 张堆叠卡又缩成中间一小撮，卡心跨度=" + centerSpan);
            Assert.Less(centerSpan, 1100f, "7 张堆叠卡跨度异常，卡心跨度=" + centerSpan);

            // 随机轻微旋转：多数卡有非零倾角
            var tilted = cards.Count(r => Mathf.Abs(r.localEulerAngles.z) > 0.5f);
            Assert.Greater(tilted, 4, "堆叠卡缺少随机倾角，只有 " + tilted + " 张倾斜");
        }

        [UnityTest]
        public IEnumerator FourCards_FlatAcrossArea_NoStack()
        {
            yield return OpenT7();
            var t = _board.GetType();
            Assert.AreEqual(4, CardCount(t), "T7 样例应是 4 张卡");

            var stackedProp = t.GetProperty("IsStacked");
            Assert.IsNotNull(stackedProp, "IsStacked 属性未找到");
            Assert.IsFalse((bool)stackedProp.GetValue(_board, null), "4 张卡不应进入堆叠");

            var cards = CardRects(t);
            var minX = cards.Min(r => r.anchoredPosition.x);
            var maxX = cards.Max(r => r.anchoredPosition.x);
            // anchoredPosition 是卡心；加回一张卡宽才是视觉上的铺排跨度。
            var span = maxX - minX + 320f;
            Assert.Greater(span, 1150f, "4 张卡没有横向铺满区域，跨度=" + span);
            Assert.LessOrEqual(span, 1285f + 0.01f, "平铺卡超出了 Body 宽度，跨度=" + span);
            foreach (var r in cards)
                Assert.Less(Mathf.Abs(r.localEulerAngles.z), 0.5f, "平铺卡不应有随机倾角：" + r.name);
        }

        [UnityTest]
        public IEnumerator FiveCards_StillFlatAndFillFullWidth()
        {
            yield return OpenT7();
            var t = _board.GetType();
            t.GetMethod("DebugAddCard").Invoke(_board, null);
            Assert.AreEqual(5, CardCount(t));

            var stackedProp = t.GetProperty("IsStacked");
            Assert.IsFalse((bool)stackedProp.GetValue(_board, null),
                "5 张卡应继续平铺，不能一到 5 张就缩成一团");

            var cards = CardRects(t);
            var span = cards.Max(r => r.anchoredPosition.x) - cards.Min(r => r.anchoredPosition.x) + 320f;
            Assert.Greater(span, 1200f, "5 张卡没有铺满主区，视觉跨度=" + span);
            Assert.LessOrEqual(span, 1285f + 0.01f, "5 张卡超出 Body 宽度，视觉跨度=" + span);
        }

        [UnityTest]
        public IEnumerator DebugAddRemoveCard_ChangesCount()
        {
            yield return OpenT7();
            var t = _board.GetType();
            var add = t.GetMethod("DebugAddCard");
            var remove = t.GetMethod("DebugRemoveCard");
            Assert.IsNotNull(add);
            Assert.IsNotNull(remove);

            add.Invoke(_board, null);
            Assert.AreEqual(5, CardCount(t));
            remove.Invoke(_board, null);
            Assert.AreEqual(4, CardCount(t), "删卡后没有回到原始张数");
        }

        [UnityTest]
        public IEnumerator Hover_BringsCardToFrontAndRestores()
        {
            yield return OpenT7();
            var t = _board.GetType();
            var add = t.GetMethod("DebugAddCard");
            for (var i = 0; i < 3; i++) add.Invoke(_board, null);

            var stack = (IList)t.GetField("_stackCards", Inst).GetValue(_board);
            var first = (RectTransform)stack[0];
            var last = (RectTransform)stack[stack.Count - 1];
            var baseIndex = first.GetSiblingIndex();

            var setHover = t.GetMethod("SetHover", Inst);
            var animate = t.GetMethod("AnimateHover", Inst);
            Assert.IsNotNull(setHover);
            Assert.IsNotNull(animate);

            setHover.Invoke(_board, new object[] { first });
            Assert.Greater(first.GetSiblingIndex(), baseIndex, "悬浮卡没有置顶");
            Assert.Greater(first.GetSiblingIndex(), last.GetSiblingIndex(), "悬浮卡仍在别的卡下面");
            animate.Invoke(_board, new object[] { 0.2f });   // 0.2s > 0.12s 入场
            Assert.Greater(first.localScale.x, 1.05f, "悬浮卡没有放大");

            t.GetMethod("ClearHover", Inst).Invoke(_board, null);
            Assert.AreEqual(baseIndex, first.GetSiblingIndex(), "离开后没有恢复原始层级");
            Assert.Less(Mathf.Abs(first.localScale.x - 1f), 0.01f, "离开后没有恢复缩放");
        }

        [UnityTest]
        public IEnumerator DropOnEmptySpace_StaysWhereReleased()
        {
            yield return OpenT7();

            // 清空落点：这次松手必然 hit == null（丢在桌面空白处）
            var targets = (IList)_tBoard.GetField("Targets", Inst).GetValue(_board);
            targets.Clear();

            var pieces = (IList)_tBoard.GetField("Pieces", Inst).GetValue(_board);
            object k1 = null;
            foreach (var p in pieces)
                if (GetStr(p, "Id") == "k1") { k1 = p; break; }
            Assert.IsNotNull(k1, "找不到 k1");

            var rect = (RectTransform)_tPiece.GetField("Rect", Inst).GetValue(k1);
            var origin = rect.anchoredPosition;
            var blank = new Vector2(1150f, -560f);

            _tBoard.GetMethod("BeginCarry", Inst).Invoke(_board, new[] { k1, origin });
            var handle = _tPiece.GetField("Handle", Inst).GetValue(k1);
            handle.GetType().GetMethod("SyncTo", Inst).Invoke(handle, new object[] { blank });
            // 让 ReleaseCarry 认为这是一次真正的拖拽（位移 >= 8px）
            _tBoard.GetField("_pressScreen", Inst).SetValue(_board, new Vector2(-99999f, -99999f));
            _tBoard.GetMethod("ReleaseCarry", Inst).Invoke(_board, new object[] { (Vector2?)blank });

            yield return new WaitForSecondsRealtime(0.6f);
            Assert.Less(Vector2.Distance(rect.anchoredPosition, blank), 0.5f,
                "丢在空白处应就地留下：rect=" + rect.anchoredPosition + " blank=" + blank);
            Assert.Greater(Vector2.Distance(rect.anchoredPosition, origin), 100f,
                "卡片被错误地送回了拖拽前的位置");
        }

        // ---- helpers ----

        IEnumerator OpenT7()
        {
            // 上一局的退出走黑底淡出协程，真实关闭要等 ~0.3s；不等待就 Open 会被拒。
            var wait = 0f;
            while ((bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null) && wait < 3f)
            {
                wait += 0.05f;
                yield return new WaitForSecondsRealtime(0.05f);
            }
            Assert.IsFalse((bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null),
                "上一局没有关闭，无法开始新的 T7");

            var template = Enum.Parse(_tTemplate, "Testimony");
            var sampleMi = _tRegistry.GetMethods(Stat).First(m => m.Name == "Sample");
            var ps = sampleMi.GetParameters();
            var args = new object[ps.Length];
            args[0] = template;
            for (var i = 1; i < ps.Length; i++)
                args[i] = ps[i].ParameterType.IsValueType ? Activator.CreateInstance(ps[i].ParameterType) : null;
            var def = sampleMi.Invoke(null, args);
            Assert.IsNotNull(def, "T7 sample def 为空");

            var open = _tHost.GetMethod("Open", new[] { def.GetType(), typeof(Action) });
            Assert.IsTrue((bool)open.Invoke(null, new object[] { def, null }), "T7 打开失败");
            yield return new WaitForSecondsRealtime(0.6f);
            _board = CurrentBoard();
            Assert.IsNotNull(_board, "T7 board 为空");
            Assert.AreEqual("TestimonyBoard", _board.GetType().Name);
        }

        int CardCount(Type t)
        {
            return (int)t.GetProperty("CardCount").GetValue(_board, null);
        }

        List<RectTransform> CardRects(Type t)
        {
            var dict = (IDictionary)t.GetField("_cardRect", Inst).GetValue(_board);
            return dict.Values.Cast<RectTransform>().ToList();
        }

        object CurrentBoard()
        {
            var runner = _tHost.GetProperty("Runner", Stat).GetValue(null, null);
            return runner == null ? null : _tRunner.GetField("_board", Inst).GetValue(runner);
        }

        IEnumerator CloseAnyGame()
        {
            if ((bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null))
            {
                _tHost.GetMethod("Close", Stat).Invoke(null, null);
                var wait = 0f;
                while ((bool)_tHost.GetProperty("IsOpen", Stat).GetValue(null, null) && wait < 3f)
                {
                    wait += 0.05f;
                    yield return new WaitForSecondsRealtime(0.05f);
                }
            }
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

        static string GetStr(object obj, string field)
        {
            var f = obj.GetType().GetField(field, Inst);
            return f != null ? f.GetValue(obj) as string : null;
        }
    }
}
