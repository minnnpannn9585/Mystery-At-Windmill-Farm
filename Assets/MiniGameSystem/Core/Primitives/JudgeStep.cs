using System;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 计数模式。四值来自 §18.2.3——T6 的两套计数不是合并，而是分流：
    /// Step 是「步骤」（Q16：1/2 → 2/2，盘外松手退回 0/2），
    /// Count 是「件数」（Q03：3/3，放入才算分）。
    /// </summary>
    public enum JudgeMode
    {
        /// <summary>T1 / T2 / T3 / T4 / T7：命中一处算一步，1/2 → 2/2。</summary>
        Discrete,

        /// <summary>T6-Q16：两阶段，取消当前阶段会退回上一步。</summary>
        Step,

        /// <summary>T6-Q03：只数放进去的件数，不记「拿起」。</summary>
        Count,

        /// <summary>T5：由覆盖率轮询外部写入，不是离散判定。</summary>
        Coverage,
    }

    /// <summary>一次子目标判定的结果。</summary>
    public struct JudgeResult
    {
        public bool Pass;
        public string Tag;

        public static JudgeResult No(string tag = null)
        {
            return new JudgeResult { Pass = false, Tag = tag };
        }

        public static JudgeResult Yes(string tag = null)
        {
            return new JudgeResult { Pass = true, Tag = tag };
        }
    }

    /// <summary>
    /// 判定步进。§18.2.3 的第五个原语，七个模板全用：
    /// 一次「子目标达成」推进一格，推满即完成，完成才走 §13 入册。
    /// </summary>
    public sealed class JudgeStep
    {
        public JudgeMode Mode = JudgeMode.Discrete;
        public int Total = 1;

        int _done;

        /// <summary>进度变化（含回退）。</summary>
        public event Action<JudgeStep> Changed;

        /// <summary>刚好推满的那一刻，只触发一次。</summary>
        public event Action<JudgeStep> Completed;

        public int Done { get { return _done; } }
        public bool IsComplete { get { return _done >= Total && Total > 0; } }
        public string Label { get { return _done + " / " + Total; } }

        public JudgeStep(int total, JudgeMode mode = JudgeMode.Discrete)
        {
            Total = Mathf.Max(1, total);
            Mode = mode;
        }

        /// <summary>推进一步。返回 true 表示这一步让进度刚好满了（用于「这一次完成」的演出）。</summary>
        public bool Advance(int n = 1)
        {
            if (Total <= 0) return false;
            var before = _done;
            _done = Mathf.Clamp(_done + Mathf.Max(1, n), 0, Total);
            if (_done != before) Notify();
            return before < Total && _done >= Total;
        }

        /// <summary>回退。只有 Step 模式用（Q16 在盘外松手退回 0/2）。</summary>
        public void Rollback(int n = 1)
        {
            if (Mode != JudgeMode.Step && Mode != JudgeMode.Count) return;
            var before = _done;
            _done = Mathf.Clamp(_done - Mathf.Max(1, n), 0, Total);
            if (_done != before) Notify();
        }

        /// <summary>覆盖率外部轮询写入（T5）。不会触发 Completed 之外的语义差异。</summary>
        public void SetDone(int done)
        {
            var before = _done;
            _done = Mathf.Clamp(done, 0, Total);
            if (_done != before) Notify();
        }

        public void Reset()
        {
            if (_done == 0) return;
            _done = 0;
            Notify();
        }

        void Notify()
        {
            if (Changed != null) Changed(this);
            if (_done >= Total && Completed != null) Completed(this);
        }
    }
}
