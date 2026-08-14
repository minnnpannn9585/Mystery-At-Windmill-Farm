using System.Globalization;

namespace EggRescue
{
    public static class ConditionEvaluator
    {
        public static int? NextFromBranches(System.Collections.Generic.List<ConditionExpr> branches)
        {
            if (branches == null || branches.Count == 0) return null;
            for (var i = 0; i < branches.Count; i++)
            {
                var cb = branches[i];
                if (cb == null || string.IsNullOrEmpty(cb.VarName)) continue;
                if (cb.VarType == "bool")
                {
                    var val = GameState.GetBool(cb.VarName);
                    if (val && cb.TrueNext != int.MinValue) return cb.TrueNext;
                    if (!val && cb.FalseNext != int.MinValue) return cb.FalseNext;
                }
                else if (MatchInt(cb) && cb.Next != int.MinValue)
                {
                    return cb.Next;
                }
            }
            return null;
        }

        public static bool OptionVisible(DialogueOption option)
        {
            if (option == null) return true;
            var hasAnd = option.DisplayConditions.Count > 0;
            var hasOr = option.DisplayAnyConditions.Count > 0;
            if (!hasAnd && !hasOr) return true;
            if (hasAnd)
            {
                for (var i = 0; i < option.DisplayConditions.Count; i++)
                {
                    if (!Eval(option.DisplayConditions[i])) return false;
                }
            }
            if (hasOr)
            {
                var any = false;
                for (var i = 0; i < option.DisplayAnyConditions.Count; i++)
                {
                    if (Eval(option.DisplayAnyConditions[i])) { any = true; break; }
                }
                if (!any) return false;
            }
            return true;
        }

        public static bool Eval(ConditionExpr cond)
        {
            if (cond == null || string.IsNullOrEmpty(cond.VarName)) return true;
            if (cond.VarType == "bool")
            {
                var expected = true;
                if (!string.IsNullOrEmpty(cond.Value))
                    expected = cond.Value == "true" || cond.Value == "1";
                var actual = GameState.GetBool(cond.VarName);
                if (cond.Op == "!=") return actual != expected;
                return actual == expected;
            }
            return MatchInt(cond);
        }

        static bool MatchInt(ConditionExpr cond)
        {
            int cmp;
            if (!int.TryParse(cond.Value, NumberStyles.Integer, CultureInfo.InvariantCulture, out cmp))
                cmp = 0;
            var val = GameState.GetInt(cond.VarName);
            switch (cond.Op)
            {
                case "!=": return val != cmp;
                case ">": return val > cmp;
                case "<":
                case "lt": return val < cmp;
                case ">=": return val >= cmp;
                case "<=": return val <= cmp;
                default: return val == cmp;
            }
        }

        public static bool EvalUnlockString(string condition)
        {
            if (string.IsNullOrEmpty(condition)) return false;
            var orGroups = condition.Split('|');
            for (var i = 0; i < orGroups.Length; i++)
            {
                var orGroup = orGroups[i].Trim();
                if (orGroup.Length == 0) continue;
                var andOk = true;
                var andParts = orGroup.Split('&');
                for (var j = 0; j < andParts.Length; j++)
                {
                    var part = andParts[j].Trim();
                    if (part.Length == 0) continue;
                    if (!EvalSingle(part)) { andOk = false; break; }
                }
                if (andOk) return true;
            }
            return false;
        }

        static bool EvalSingle(string expr)
        {
            string name;
            string op;
            string raw;
            if (!Split(expr, out name, out op, out raw)) return false;
            bool boolExpected;
            if (raw == "true" || raw == "false")
            {
                boolExpected = raw == "true";
                var actual = GameState.GetBool(name);
                return op == "!=" ? actual != boolExpected : actual == boolExpected;
            }
            int cmp;
            if (!int.TryParse(raw, NumberStyles.Integer, CultureInfo.InvariantCulture, out cmp))
                return false;
            var val = GameState.GetInt(name);
            switch (op)
            {
                case ">=": return val >= cmp;
                case "<=": return val <= cmp;
                case ">": return val > cmp;
                case "<": return val < cmp;
                case "!=": return val != cmp;
                default: return val == cmp;
            }
        }

        static bool Split(string expr, out string name, out string op, out string raw)
        {
            name = null; op = null; raw = null;
            var ops = new[] { ">=", "<=", "!=", "==", ">", "<" };
            for (var i = 0; i < ops.Length; i++)
            {
                var idx = expr.IndexOf(ops[i], System.StringComparison.Ordinal);
                if (idx <= 0) continue;
                name = expr.Substring(0, idx).Trim();
                op = ops[i];
                raw = expr.Substring(idx + ops[i].Length).Trim();
                return name.Length > 0;
            }
            return false;
        }
    }
}
