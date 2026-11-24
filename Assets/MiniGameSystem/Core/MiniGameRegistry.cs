using System.Collections.Generic;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 19 局的数据表，唯一数据源（§15.1）。内容与附录 A 一一对应：
    /// 模板、目标、提交变量、计数变量、来源点。
    ///
    /// 文案（题面 + 两级提示）属于 M3 的活，这里只占位；
    /// 缺文案时 ShowHint 会在控制台留一行「M3 补文案」，不会静默失败。
    /// </summary>
    public static class MiniGameRegistry
    {
        static readonly List<MiniGameDef> Defs = Build();
        static readonly Dictionary<string, MiniGameDef> Index = BuildIndex();

        public static IReadOnlyList<MiniGameDef> All { get { return Defs; } }

        public static MiniGameDef Get(string id)
        {
            if (string.IsNullOrEmpty(id)) return null;
            MiniGameDef def;
            if (Index.TryGetValue(id, out def)) return def;
            // 自检局不进 Defs —— §15.1 那张表只放正式 19 局，多一条会污染 ByTemplate 统计。
            // 但它必须能被查出来，否则自检入口会停在「unknown def id」。
            if (id == DebugId) return DebugDef;
            return null;
        }

        public static bool Exists(string id)
        {
            return Get(id) != null;
        }

        /// <summary>M1 自检局：不进正式流程，不写任何剧情变量。</summary>
        public const string DebugId = "DEBUG-01";

        public static MiniGameDef DebugDef
        {
            get
            {
                return new MiniGameDef
                {
                    Id = DebugId,
                    Template = MiniGameTemplate.Debug,
                    Title = "自检局",
                    Objective = "把三张卡拖到三个槽里，验证开关 / 暂停 / 退出 / 续局 / 入册演出",
                    SubmitVar = null,
                    CountVar = null,
                    SourceId = "M1",
                    Hints = new[] { "随便挑一张卡，拖到上面任意一个槽。", "先拖卡 A 到最左边的槽。" },
                };
            }
        }

        public static MiniGameContent Content(MiniGameDef def)
        {
            if (def == null) return null;
            // M1：只有自检局有内容；19 局的内容在 M3 随 Data/ 一起补
            if (def.Id == DebugId) return MiniGameContent.DebugDefault();
            // M2：七个模板各有示例内容，只为「板子能单独开起来验收」，19 局真数据仍在 M3
            if (def.Id != null && def.Id.StartsWith(MiniGameSamples.Prefix))
                return MiniGameSamples.For(def.Template);
            return null;
        }

        // ---------------- M2：模板自检局 ----------------

        /// <summary>模板自检局的 id。带 suffix 的用于同模板不同模式（T6 的 Step / Count）。</summary>
        public static string SampleId(MiniGameTemplate template, string suffix = null)
        {
            return MiniGameSamples.Prefix + template + (string.IsNullOrEmpty(suffix) ? "" : "-" + suffix);
        }

        static readonly Dictionary<string, MiniGameDef> SampleDefs = new Dictionary<string, MiniGameDef>();

        /// <summary>
        /// 造一局「只验交互」的定义。不写任何剧情变量（SubmitVar / CountVar 全空），
        /// 所以开一百次也不会污染存档与线索链。
        /// </summary>
        public static MiniGameDef Sample(MiniGameTemplate template, JudgeMode mode = JudgeMode.Discrete,
            string suffix = null)
        {
            var id = SampleId(template, suffix);
            MiniGameDef cached;
            if (SampleDefs.TryGetValue(id, out cached)) return cached;

            var label = TemplateName(template) + (string.IsNullOrEmpty(suffix) ? "" : " · " + suffix);
            var def = new MiniGameDef
            {
                Id = id,
                Template = template,
                Title = "自检 · " + label,
                Objective = "M2 行为验收（判定 / 提示 / 完成 / 续局）。正式题面与文案在 M3 补。",
                Mode = mode,
                SourceId = "M2",
                Hints = new[]
                {
                    "这一局只验交互，题面文案 M3 才写。",
                    "看高亮的地方。",
                },
            };
            SampleDefs[id] = def;
            return def;
        }

        /// <summary>菜单用的顺序表：模板 + 模式 + 后缀 + 显示名。</summary>
        public static readonly MiniGameTemplate[] SampleOrder =
        {
            MiniGameTemplate.Magnifier,
            MiniGameTemplate.Uncover,
            MiniGameTemplate.Rotate,
            MiniGameTemplate.Jigsaw,
            MiniGameTemplate.Rubbing,
            MiniGameTemplate.Tweezer,
            MiniGameTemplate.Tweezer,
            MiniGameTemplate.Testimony,
        };

        public static readonly string[] SampleSuffix = { "T1", "T2", "T3", "T4", "T5", "T6", "T6-Count", "T7" };

        public static readonly JudgeMode[] SampleMode =
        {
            JudgeMode.Discrete,
            JudgeMode.Discrete,
            JudgeMode.Discrete,
            JudgeMode.Discrete,
            JudgeMode.Coverage,
            JudgeMode.Step,
            JudgeMode.Count,
            JudgeMode.Discrete,
        };

        public static string TemplateName(MiniGameTemplate template)
        {
            switch (template)
            {
                case MiniGameTemplate.Magnifier: return "T1 放大镜调查";
                case MiniGameTemplate.Uncover: return "T2 拨开遮挡";
                case MiniGameTemplate.Rotate: return "T3 翻转查验";
                case MiniGameTemplate.Jigsaw: return "T4 观察图拼合";
                case MiniGameTemplate.Rubbing: return "T5 痕迹拓印";
                case MiniGameTemplate.Tweezer: return "T6 镊取物证";
                case MiniGameTemplate.Testimony: return "T7 证词归位";
                default: return "自检";
            }
        }

        public static IEnumerable<MiniGameDef> ByTemplate(MiniGameTemplate template)
        {
            for (var i = 0; i < Defs.Count; i++)
                if (Defs[i].Template == template) yield return Defs[i];
        }

        static Dictionary<string, MiniGameDef> BuildIndex()
        {
            var map = new Dictionary<string, MiniGameDef>();
            for (var i = 0; i < Defs.Count; i++)
                map[Defs[i].Id] = Defs[i];
            return map;
        }

        static List<MiniGameDef> Build()
        {
            return new List<MiniGameDef>
            {
                // ---------------- 第一章 ----------------
                Def("Q01", MiniGameTemplate.Testimony, "2 槽 3 卡（1 干扰）", "Shufen_CommissionDone", null, "淑芬 1-A 播毕"),
                Def("Q02", MiniGameTemplate.Rotate, "2 处（炭尖 / 草上炭粉）", "E01_ViewCharcoal", "ChickTraceCount", "E01 木炭"),
                Def("Q03", MiniGameTemplate.Tweezer, "3 根", "E02_ViewFeather", "ChickTraceCount", "E02 羽毛碎片"),
                Def("Q04", MiniGameTemplate.Testimony, "3 槽 3 卡", "E03_Overheard", "ChickTraceCount", "E03 偷听 1-A 播毕"),
                Def("Q05", MiniGameTemplate.Testimony, "3 槽 3 卡", null, null, "小鸡 2-B 播毕", "ChickStatus", 2),
                Def("Q06", MiniGameTemplate.Magnifier, "2 处", "E12_ViewGreenPad", null, "E12 绿边 / 蛙 3-A 补录"),
                Def("Q07", MiniGameTemplate.Testimony, "3 槽按顺序", "Frog_WaterMonsterQueried", null, "蛙 2-D 播毕"),
                Def("Q08", MiniGameTemplate.Testimony, "3 槽 3 卡", null, null, "大黄 1-A 播毕", "DogStatus", 2),
                Def("Q09", MiniGameTemplate.Magnifier, "2 处", "E05_GrainSoakGet", null, "E05 水槽"),
                Def("Q10", MiniGameTemplate.Uncover, "拨 2 束 + 2 确认", "E07_ViewNapSpot", null, "E07 草窝"),
                Def("Q11", MiniGameTemplate.Magnifier, "2 处", "E08_ViewBurnMark", null, "E08 稻草皮毛"),
                Def("Q12", MiniGameTemplate.Uncover, "拨 3 束 + 双面 2 处", "E10_ViewWhiteStone", null, "E10 白石头"),
                Def("Q13", MiniGameTemplate.Testimony, "2 槽 3 卡（一槽多卡）", null, null, "小鸡 2-E / 2-G 播毕", "ChickStatus", 3),

                // ---------------- 第二章 ----------------
                Def("Q14", MiniGameTemplate.Magnifier, "2 处（锁扣 / 磨亮边）", "E14_ViewCatDoor", "TreeClueCount", "E14 猫门"),
                Def("Q15", MiniGameTemplate.Rotate, "2 处（碗沿 / 碗底）", "E15_ViewFoodBowl", "TreeClueCount", "E15 食碗"),
                Def("Q16", MiniGameTemplate.Tweezer, "1 撮（2 步）", "E16_ViewFur", "TreeClueCount", "E16 兽毛"),
                Def("Q17", MiniGameTemplate.Rubbing, "3 段 ≥ 80%", "E28_ViewTreeScratch", "TreeClueCount", "E28 树根"),
                Def("Q18", MiniGameTemplate.Rotate, "2 处（内部 / 桶底）", "E17_ViewEmptyBucket", null, "E17 空桶"),
                Def("Q19", MiniGameTemplate.Jigsaw, "6/6 + 朝鸡舍", "E18_ViewBootprints", null, "E18 雨靴印"),
            };
        }

        static MiniGameDef Def(string id, MiniGameTemplate template, string objective,
            string submitVar, string countVar, string source)
        {
            // 标题行 / 提示行逐字取自任务线（§12.6.1 不压缩、照搬、标点原样）。
            // 缺行时退回模板名 / 空提示，不静默吞掉——自检局与样例局不受影响。
            var titleRow = MiniGameScript.TitleRow(id);
            var hintRow = MiniGameScript.HintRow(id);
            return new MiniGameDef
            {
                Id = id,
                Template = template,
                Title = TitleOf(template),
                Objective = !string.IsNullOrEmpty(titleRow) ? titleRow : objective,
                SubmitVar = submitVar,
                CountVar = countVar,
                SourceId = source,
                ContentKey = id,
                Hints = !string.IsNullOrEmpty(hintRow) ? new[] { hintRow } : new string[0],
            };
        }

        /// <summary>Q05 / Q08 / Q13 的提交是「写整型状态」，不是写 bool。</summary>
        static MiniGameDef Def(string id, MiniGameTemplate template, string objective,
            string submitVar, string countVar, string source, string intVar, int intValue)
        {
            var def = Def(id, template, objective, submitVar, countVar, source);
            def.SubmitVar = intVar;
            def.IntSubmitValue = intValue;
            def.SubmitIsInt = true;
            return def;
        }

        static string TitleOf(MiniGameTemplate template)
        {
            switch (template)
            {
                case MiniGameTemplate.Magnifier: return "微观调查";
                case MiniGameTemplate.Uncover: return "拨开遮挡";
                case MiniGameTemplate.Rotate: return "翻转查验";
                case MiniGameTemplate.Jigsaw: return "观察图拼合";
                case MiniGameTemplate.Rubbing: return "痕迹拓印";
                case MiniGameTemplate.Tweezer: return "镊取物证";
                case MiniGameTemplate.Testimony: return "证词要点归位";
                default: return "小游戏";
            }
        }
    }
}
