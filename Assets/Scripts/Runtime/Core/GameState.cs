using System;
using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public enum VarType
    {
        Bool,
        Int
    }

    public sealed class VarRecord
    {
        public VarType Type;
        public int IntValue;
        public bool BoolValue;

        public object Boxed
        {
            get { return Type == VarType.Bool ? (object)BoolValue : IntValue; }
        }
    }

    public static class GameState
    {
        static readonly Dictionary<string, VarRecord> Vars = new Dictionary<string, VarRecord>();
        static readonly Dictionary<string, bool> BranchFlags = new Dictionary<string, bool>();
        static bool _dispatching;

        public static IEnumerable<string> BranchFlagKeys
        {
            get { return BranchFlags.Keys; }
        }

        public static IReadOnlyDictionary<string, VarRecord> All { get { return Vars; } }

        public static void LoadDefaults()
        {
            Vars.Clear();
            BranchFlags.Clear();
            var ta = Resources.Load<TextAsset>("GameData/global_variables");
            if (ta == null)
            {
                Debug.LogError("[GameState] missing Resources/GameData/global_variables.txt");
                return;
            }

            var root = JsonValue.Parse(ta.text);
            foreach (var item in root.AsArray())
            {
                var name = item["name"].AsString();
                if (string.IsNullOrEmpty(name)) continue;
                var typeName = item["type"].AsString("bool");
                var rec = new VarRecord();
                if (typeName == "int")
                {
                    rec.Type = VarType.Int;
                    rec.IntValue = item["value"].AsInt();
                }
                else
                {
                    rec.Type = VarType.Bool;
                    rec.BoolValue = item["value"].AsBool();
                }
                Vars[name] = rec;
            }
            Debug.Log("[GameState] loaded " + Vars.Count + " variables");
        }

        public static void ResetToDefaults()
        {
            LoadDefaults();
            NpcRegistry.ResetBranchesToStart();
        }

        public static object Get(string name)
        {
            VarRecord rec;
            if (string.IsNullOrEmpty(name) || !Vars.TryGetValue(name, out rec))
                return null;
            return rec.Boxed;
        }

        public static bool GetBool(string name, bool fallback = false)
        {
            VarRecord rec;
            if (string.IsNullOrEmpty(name) || !Vars.TryGetValue(name, out rec))
                return fallback;
            if (rec.Type == VarType.Bool) return rec.BoolValue;
            return rec.IntValue != 0;
        }

        public static int GetInt(string name, int fallback = 0)
        {
            VarRecord rec;
            if (string.IsNullOrEmpty(name) || !Vars.TryGetValue(name, out rec))
                return fallback;
            if (rec.Type == VarType.Int) return rec.IntValue;
            return rec.BoolValue ? 1 : 0;
        }

        public static VarType GetVarType(string name)
        {
            VarRecord rec;
            if (Vars.TryGetValue(name, out rec))
                return rec.Type;
            return VarType.Bool;
        }

        public static bool Has(string name)
        {
            return !string.IsNullOrEmpty(name) && Vars.ContainsKey(name);
        }

        public static void Set(string name, object value, string typeHint = null)
        {
            if (string.IsNullOrEmpty(name)) return;
            VarRecord rec;
            if (!Vars.TryGetValue(name, out rec))
            {
                rec = new VarRecord();
                rec.Type = typeHint == "int" ? VarType.Int : VarType.Bool;
                Vars[name] = rec;
            }

            if (rec.Type == VarType.Bool)
                rec.BoolValue = ToBool(value);
            else
                rec.IntValue = ToInt(value);

            DispatchSideEffects(name, rec);
        }

        public static void SetBool(string name, bool value)
        {
            Set(name, value, "bool");
        }

        public static void SetInt(string name, int value)
        {
            Set(name, value, "int");
        }

        public static void SaveBranchFlag(string flag)
        {
            if (string.IsNullOrEmpty(flag)) return;
            BranchFlags[flag] = true;
        }

        public static bool CheckBranchFlag(string flag)
        {
            bool v;
            return !string.IsNullOrEmpty(flag) && BranchFlags.TryGetValue(flag, out v) && v;
        }

        public static Dictionary<string, object> CaptureSave()
        {
            var dict = new Dictionary<string, object>();
            foreach (var kv in Vars)
                dict[kv.Key] = kv.Value.Boxed;
            foreach (var kv in BranchFlags)
                dict["Branch_" + kv.Key] = kv.Value;
            return dict;
        }

        public static void RestoreSave(Dictionary<string, JsonValue> data)
        {
            if (data == null) return;
            foreach (var kv in data)
            {
                if (kv.Key.StartsWith("Branch_", StringComparison.Ordinal))
                {
                    BranchFlags[kv.Key.Substring("Branch_".Length)] = kv.Value.AsBool();
                    continue;
                }
                VarRecord rec;
                if (!Vars.TryGetValue(kv.Key, out rec)) continue;
                if (rec.Type == VarType.Bool) rec.BoolValue = kv.Value.AsBool();
                else rec.IntValue = kv.Value.AsInt();
            }
        }

        static bool ToBool(object value)
        {
            if (value is bool) return (bool)value;
            if (value is int) return (int)value != 0;
            if (value is string)
            {
                var s = (string)value;
                return s == "true" || s == "1";
            }
            return false;
        }

        static int ToInt(object value)
        {
            if (value is int) return (int)value;
            if (value is bool) return (bool)value ? 1 : 0;
            if (value is string)
            {
                int n;
                if (int.TryParse((string)value, out n)) return n;
            }
            if (value is double) return (int)(double)value;
            if (value is float) return (int)(float)value;
            return 0;
        }

        static void DispatchSideEffects(string name, VarRecord rec)
        {
            if (_dispatching) return;
            _dispatching = true;
            try
            {
                GameEvents.RaiseVariableChanged(name);
                if (name == "CheeseCount" && rec.Type == VarType.Int)
                    GameEvents.RaiseCheeseCountChanged();
                if (name != null && name.StartsWith("Mouse_", StringComparison.Ordinal))
                    GameEvents.RaiseMouseFlagsNeedRefresh();
                if (name == "NGPlus" && rec.Type == VarType.Bool && rec.BoolValue)
                    GameEvents.RaiseNGPlusActivated();
                if (name == "BlackCat_Entered")
                    GameEvents.RaiseBlackCatEntered();
                if (name == "E05_GrainSoakGet")
                    GameEvents.RaiseE05GrainSoakGot();
            }
            finally
            {
                _dispatching = false;
            }
        }
    }
}
