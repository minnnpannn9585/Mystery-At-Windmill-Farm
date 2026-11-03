using System;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 七种交互模板。编号与设计文档 §5 一致，运行时不做反射，便于切分支。
    /// </summary>
    public enum MiniGameTemplate
    {
        Magnifier = 0,   // T1 放大镜调查
        Uncover = 1,     // T2 拨开遮挡
        Rotate = 2,      // T3 翻转查验
        Jigsaw = 3,      // T4 观察图拼合
        Rubbing = 4,     // T5 痕迹拓印
        Tweezer = 5,     // T6 镊取物证
        Testimony = 6,   // T7 证词要点归位
        Debug = 90,      // M1 自检用，不进正式流程
    }

    /// <summary>出局原因。Completed 才写提交变量。</summary>
    public enum MiniGameExit
    {
        Completed,
        Aborted,   // 玩家点「返回调查」
        Forced,    // 被外部（读档 / 场景切换）关掉
    }

    /// <summary>
    /// 一局的定义。纯数据，不引用场景对象；19 局由 <see cref="MiniGameRegistry"/> 统一给。
    /// 字段对应文档 §15.2。
    /// </summary>
    [Serializable]
    public sealed class MiniGameDef
    {
        public string Id;
        public MiniGameTemplate Template = MiniGameTemplate.Debug;
        public string Title;
        public string Objective;
        public string EnterVar;
        public string SubmitVar;
        public string CountVar;
        public string ContentKey;
        public string SourceId;

        /// <summary>
        /// 有些局提交的不是 bool 而是整型状态（Q05 / Q08 写 ChickStatus=2、DogStatus=2，
        /// Q13 写 ChickStatus=3）。置 true 时写 <see cref="IntSubmitValue"/>。
        /// </summary>
        public bool SubmitIsInt;
        public int IntSubmitValue;

        /// <summary>
        /// 判定模式。大多数局是 Discrete（命中一处算一步），
        /// 只有 T6 要分：Q16 用 Step（夹起 1/2、放入 2/2、盘外松手退回），Q03 用 Count（放入才算数）。
        /// 刻意不做成「一套公式兼容两局」——那会在「夹起第一根该显示 1/3 还是 0/3」上出歧义（§11.3）。
        /// </summary>
        public JudgeMode Mode = JudgeMode.Discrete;

        /// <summary>两级提示文案：0 = 一级（给方向），1 = 二级（标位置）。</summary>
        public string[] Hints = new string[0];

        public string Hint(int level)
        {
            if (Hints == null || Hints.Length == 0) return null;
            var i = Mathf.Clamp(level - 1, 0, Hints.Length - 1);
            var text = Hints[i];
            return string.IsNullOrEmpty(text) ? null : text;
        }

        public bool IsValid
        {
            get { return !string.IsNullOrEmpty(Id); }
        }
    }
}
