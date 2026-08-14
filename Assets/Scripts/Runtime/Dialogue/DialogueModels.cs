using System.Collections.Generic;

namespace EggRescue
{
    public sealed class ConditionExpr
    {
        public string VarName;
        public string VarType = "bool";
        public string Op = "==";
        public string Value;
        public int TrueNext = int.MinValue;
        public int FalseNext = int.MinValue;
        public int Next = int.MinValue;

        public static ConditionExpr FromJson(JsonValue json)
        {
            if (json == null || json.IsNull) return null;
            var c = new ConditionExpr();
            c.VarName = json["VarName"].AsString(json["varName"].AsString());
            c.VarType = json.Has("VarType") ? json["VarType"].AsString("bool") : json["varType"].AsString("bool");
            c.Op = json.Has("Op") ? json["Op"].AsString("==") : "==";
            if (json.Has("Value")) c.Value = json["Value"].AsString();
            else if (json.Has("value")) c.Value = json["value"].AsString();
            if (json.Has("TrueNext")) c.TrueNext = json["TrueNext"].AsInt();
            if (json.Has("FalseNext")) c.FalseNext = json["FalseNext"].AsInt();
            if (json.Has("Next")) c.Next = json["Next"].AsInt();
            return c;
        }
    }

    public sealed class SetVariableOp
    {
        public string VarName;
        public string VarType = "bool";
        public string Value;

        public static SetVariableOp FromJson(JsonValue json)
        {
            var op = new SetVariableOp();
            op.VarName = json["VarName"].AsString(json["varName"].AsString());
            op.VarType = json.Has("VarType") ? json["VarType"].AsString("bool") : json["varType"].AsString("bool");
            op.Value = json.Has("Value") ? json["Value"].AsString() : json["value"].AsString();
            return op;
        }
    }

    public sealed class UnlockBranchOp
    {
        public string NpcName;
        public int BranchId;

        public static UnlockBranchOp FromJson(JsonValue json)
        {
            var op = new UnlockBranchOp();
            op.NpcName = json["NpcName"].AsString(json["npcName"].AsString());
            op.BranchId = json.Has("BranchId") ? json["BranchId"].AsInt() : json["branchId"].AsInt();
            return op;
        }
    }

    public sealed class ChainDialogueOp
    {
        public string NpcName;
        public int StartId;

        public static ChainDialogueOp FromJson(JsonValue json)
        {
            if (json == null || json.IsNull || json.Type != JsonValue.Kind.Object) return null;
            var op = new ChainDialogueOp();
            op.NpcName = json["NpcName"].AsString(json["npcName"].AsString());
            op.StartId = json.Has("StartId") ? json["StartId"].AsInt() : json["startId"].AsInt();
            return op;
        }
    }

    public sealed class DialogueOption
    {
        public string Text;
        public int Next = -1;
        public string ShopAction;
        public string BranchFlag;
        public readonly List<ConditionExpr> DisplayConditions = new List<ConditionExpr>();
        public readonly List<ConditionExpr> DisplayAnyConditions = new List<ConditionExpr>();
        public readonly List<ConditionExpr> ConditionBranches = new List<ConditionExpr>();

        public static DialogueOption FromJson(JsonValue json)
        {
            var o = new DialogueOption();
            o.Text = json["Text"].AsString();
            o.Next = json.Has("Next") ? json["Next"].AsInt(-1) : -1;
            o.ShopAction = json["ShopAction"].AsString();
            o.BranchFlag = json["BranchFlag"].AsString();
            foreach (var c in json["DisplayConditions"].AsArray())
            {
                var expr = ConditionExpr.FromJson(c);
                if (expr != null) o.DisplayConditions.Add(expr);
            }
            foreach (var c in json["DisplayAnyConditions"].AsArray())
            {
                var expr = ConditionExpr.FromJson(c);
                if (expr != null) o.DisplayAnyConditions.Add(expr);
            }
            foreach (var c in json["ConditionBranches"].AsArray())
            {
                var expr = ConditionExpr.FromJson(c);
                if (expr != null) o.ConditionBranches.Add(expr);
            }
            return o;
        }
    }

    public sealed class DialogueNode
    {
        public int Id;
        public string Type = "Normal";
        public string NpcName;
        public string NpcSprite;
        public string Dialogue;
        public int Next = -1;
        public string DocTag;
        public int UnlockBranchId;
        public int MenuCap = 4;
        public bool MenuCapSpecified;
        public readonly List<DialogueOption> Options = new List<DialogueOption>();
        public readonly List<ConditionExpr> ConditionBranches = new List<ConditionExpr>();
        public readonly List<SetVariableOp> SetVariables = new List<SetVariableOp>();
        public readonly List<UnlockBranchOp> UnlockBranches = new List<UnlockBranchOp>();
        public readonly List<int> RotatePool = new List<int>();
        public ChainDialogueOp ChainDialogue;

        public static DialogueNode FromJson(JsonValue json)
        {
            var n = new DialogueNode();
            n.Id = json["id"].AsInt();
            n.Type = json["Type"].AsString("Normal");
            n.NpcName = json["NpcName"].AsString();
            n.NpcSprite = json["NpcSprite"].AsString();
            n.Dialogue = json["Dialogue"].AsString();
            n.Next = json.Has("Next") ? json["Next"].AsInt(-1) : -1;
            n.DocTag = json["DocTag"].AsString();
            n.UnlockBranchId = json["UnlockBranchId"].AsInt();
            if (json.Has("MenuCap"))
            {
                n.MenuCapSpecified = true;
                n.MenuCap = json["MenuCap"].AsInt(4);
            }
            foreach (var o in json["Options"].AsArray())
                n.Options.Add(DialogueOption.FromJson(o));
            foreach (var c in json["ConditionBranches"].AsArray())
            {
                var expr = ConditionExpr.FromJson(c);
                if (expr != null) n.ConditionBranches.Add(expr);
            }
            foreach (var s in json["SetVariables"].AsArray())
                n.SetVariables.Add(SetVariableOp.FromJson(s));
            foreach (var u in json["UnlockBranches"].AsArray())
                n.UnlockBranches.Add(UnlockBranchOp.FromJson(u));
            foreach (var r in json["RotatePool"].AsArray())
                n.RotatePool.Add(r.AsInt());
            n.ChainDialogue = ChainDialogueOp.FromJson(json["ChainDialogue"]);
            return n;
        }
    }

    public sealed class DialogueGraph
    {
        public string Module;
        public readonly Dictionary<int, DialogueNode> Nodes = new Dictionary<int, DialogueNode>();

        public DialogueNode Get(int id)
        {
            DialogueNode node;
            return Nodes.TryGetValue(id, out node) ? node : null;
        }

        public static DialogueGraph FromJson(JsonValue json)
        {
            var g = new DialogueGraph();
            g.Module = json["module"].AsString();
            foreach (var n in json["nodes"].AsArray())
            {
                var node = DialogueNode.FromJson(n);
                g.Nodes[node.Id] = node;
            }
            return g;
        }
    }
}
