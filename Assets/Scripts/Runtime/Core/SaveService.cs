using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;

namespace EggRescue
{
    public static class SaveService
    {
        const string FileName = "windmill_farm_save.json";

        public static string Path
        {
            get { return System.IO.Path.Combine(Application.persistentDataPath, FileName); }
        }

        public static void Save()
        {
            var sb = new StringBuilder();
            sb.Append("{\n");
            sb.Append("  \"variables\": {\n");
            var first = true;
            foreach (var kv in GameState.All)
            {
                if (!first) sb.Append(",\n");
                first = false;
                sb.Append("    \"").Append(Escape(kv.Key)).Append("\": ");
                if (kv.Value.Type == VarType.Bool)
                    sb.Append(kv.Value.BoolValue ? "true" : "false");
                else
                    sb.Append(kv.Value.IntValue.ToString());
            }
            sb.Append("\n  },\n");
            sb.Append("  \"npcBranches\": {\n");
            first = true;
            foreach (var npc in NpcRegistry.All)
            {
                if (!first) sb.Append(",\n");
                first = false;
                sb.Append("    \"").Append(Escape(npc.Name)).Append("\": ").Append(npc.CurrentBranchId);
            }
            sb.Append("\n  },\n");
            sb.Append("  \"cheesePicked\": [");
            first = true;
            foreach (var id in CheeseRegistry.PickedIds)
            {
                if (!first) sb.Append(", ");
                first = false;
                sb.Append("\"").Append(Escape(id)).Append("\"");
            }
            sb.Append("],\n");
            sb.Append("  \"branchFlags\": [");
            first = true;
            foreach (var flag in GameState.BranchFlagKeys)
            {
                if (!first) sb.Append(", ");
                first = false;
                sb.Append("\"").Append(Escape(flag)).Append("\"");
            }
            sb.Append("],\n");
            sb.Append("  \"discoveredPoints\": [");
            first = true;
            foreach (var id in InteractionPointVfx.DiscoveredIds)
            {
                if (!first) sb.Append(", ");
                first = false;
                sb.Append("\"").Append(Escape(id)).Append("\"");
            }
            sb.Append("]\n}\n");
            File.WriteAllText(Path, sb.ToString(), Encoding.UTF8);
            Debug.Log("[SaveService] saved " + Path);
        }

        public static bool Load()
        {
            if (!File.Exists(Path)) return false;
            var json = JsonValue.Parse(File.ReadAllText(Path, Encoding.UTF8));
            var vars = json["variables"];
            if (vars.Type == JsonValue.Kind.Object && vars.ObjectValue != null)
            {
                foreach (var kv in vars.ObjectValue)
                {
                    if (GameState.GetVarType(kv.Key) == VarType.Int)
                        GameState.SetInt(kv.Key, kv.Value.AsInt());
                    else
                        GameState.SetBool(kv.Key, kv.Value.AsBool());
                }
            }
            var branches = json["npcBranches"];
            if (branches.Type == JsonValue.Kind.Object && branches.ObjectValue != null)
            {
                foreach (var kv in branches.ObjectValue)
                    NpcRegistry.UnlockBranch(kv.Key, kv.Value.AsInt(1));
            }
            CheeseRegistry.ClearPicked();
            foreach (var id in json["cheesePicked"].AsArray())
                CheeseRegistry.MarkPicked(id.AsString());
            InteractionPointVfx.ClearDiscovered();
            foreach (var id in json["discoveredPoints"].AsArray())
                InteractionPointVfx.MarkDiscovered(id.AsString());
            foreach (var flag in json["branchFlags"].AsArray())
                GameState.SaveBranchFlag(flag.AsString());
            Debug.Log("[SaveService] loaded " + Path);
            return true;
        }

        static string Escape(string s)
        {
            return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
}
