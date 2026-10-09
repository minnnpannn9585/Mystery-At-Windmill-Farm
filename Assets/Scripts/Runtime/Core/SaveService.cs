using System;
using System.Globalization;
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

        public static bool Exists()
        {
            return File.Exists(Path);
        }

        public static bool HasPose { get; private set; }
        public static Vector3 PosePosition { get; private set; }
        public static float PoseYaw { get; private set; }
        public static float PoseViewYaw { get; private set; }
        public static float PosePitch { get; private set; }

        public static void ClearPose()
        {
            HasPose = false;
        }

        public static bool Save()
        {
            try
            {
                WriteFile();
                Debug.Log("[SaveService] saved " + Path);
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError("[SaveService] save failed: " + e.Message);
                return false;
            }
        }

        public static bool WriteNewGame()
        {
            GameState.LoadDefaults();
            NpcRegistry.Load();
            CheeseRegistry.ClearPicked();
            InteractionPointVfx.ClearDiscovered();
            ClearPose();
            return Save();
        }

        static void WriteFile()
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
            sb.Append("]");
            AppendPlayer(sb);
            sb.Append("\n}\n");
            File.WriteAllText(Path, sb.ToString(), Encoding.UTF8);
        }

        static void AppendPlayer(StringBuilder sb)
        {
            var player = PlayerController.Instance;
            if (player == null) return;
            var position = player.transform.position;
            var viewYaw = player.transform.eulerAngles.y;
            var pitch = 8f;
            if (ThirdPersonCamera.Instance != null)
            {
                viewYaw = ThirdPersonCamera.Instance.Yaw;
                pitch = ThirdPersonCamera.Instance.Pitch;
            }
            sb.Append(",\n  \"player\": {");
            sb.Append("\"x\":").Append(Num(position.x));
            sb.Append(",\"y\":").Append(Num(position.y));
            sb.Append(",\"z\":").Append(Num(position.z));
            sb.Append(",\"yaw\":").Append(Num(player.transform.eulerAngles.y));
            sb.Append(",\"viewYaw\":").Append(Num(viewYaw));
            sb.Append(",\"pitch\":").Append(Num(pitch));
            sb.Append("}");
        }

        static string Num(float value)
        {
            return value.ToString("0.###", CultureInfo.InvariantCulture);
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
            ReadPose(json["player"]);
            Debug.Log("[SaveService] loaded " + Path);
            return true;
        }

        static void ReadPose(JsonValue player)
        {
            HasPose = false;
            if (player.Type != JsonValue.Kind.Object) return;
            if (player["x"].Type != JsonValue.Kind.Number) return;
            PosePosition = new Vector3(Num(player["x"]), Num(player["y"]), Num(player["z"]));
            PoseYaw = Num(player["yaw"]);
            PoseViewYaw = player["viewYaw"].Type == JsonValue.Kind.Number ? Num(player["viewYaw"]) : PoseYaw;
            PosePitch = Num(player["pitch"]);
            HasPose = true;
        }

        static float Num(JsonValue value)
        {
            if (value.Type != JsonValue.Kind.Number) return 0f;
            return (float)value.NumberValue;
        }

        static string Escape(string s)
        {
            return (s ?? "").Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
}
