using System;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 一局的进度快照。字段刻意保持扁平——它要能原样塞进现有存档，
    /// 不引新的序列化框架（§14.1 数据流不新增 API）。
    /// </summary>
    [Serializable]
    public sealed class MiniGameProgress
    {
        public string DefId;
        public int Done;
        public int Total = 1;
        public bool InProgress;

        /// <summary>T5 的遮罩：烘到 RenderTexture 后转 PNG 字节再 Base64（§10.7）。M1 只占位不写。</summary>
        public string MaskBase64;

        public bool IsEmpty
        {
            get { return !InProgress && Done <= 0 && string.IsNullOrEmpty(MaskBase64); }
        }
    }

    /// <summary>
    /// 局内进度的存取。只做三件事：内存里的字典、写进主存档、读回来。
    /// 存档结构见 §15.5。
    /// </summary>
    public static class MiniGameSave
    {
        static readonly Dictionary<string, MiniGameProgress> Map =
            new Dictionary<string, MiniGameProgress>(StringComparer.Ordinal);

        public static MiniGameProgress Get(string defId)
        {
            if (string.IsNullOrEmpty(defId)) return new MiniGameProgress();
            MiniGameProgress p;
            if (!Map.TryGetValue(defId, out p))
            {
                p = new MiniGameProgress { DefId = defId };
                Map[defId] = p;
            }
            return p;
        }

        public static bool Has(string defId)
        {
            MiniGameProgress p;
            return !string.IsNullOrEmpty(defId) && Map.TryGetValue(defId, out p) && p.InProgress;
        }

        public static void Capture(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.DefId)) return;
            Map[progress.DefId] = progress;
        }

        /// <summary>完成后清掉局内进度——线索已发，重进不应该再给一次。</summary>
        public static void Clear(string defId)
        {
            if (!string.IsNullOrEmpty(defId)) Map.Remove(defId);
        }

        public static void ResetAll()
        {
            Map.Clear();
        }

        // ---------------- 存档编解码 ----------------

        /// <summary>由 SaveService 在写盘时调用，输出一个合法的 JSON 数组。</summary>
        public static void AppendJson(StringBuilder sb)
        {
            if (sb == null) return;
            sb.Append("[");
            var first = true;
            foreach (var kv in Map)
            {
                var p = kv.Value;
                if (p == null || p.IsEmpty) continue;
                if (!first) sb.Append(", ");
                first = false;
                sb.Append("{\"id\":\"").Append(Escape(p.DefId)).Append("\"");
                sb.Append(",\"done\":").Append(p.Done);
                sb.Append(",\"total\":").Append(p.Total);
                sb.Append(",\"inProgress\":").Append(p.InProgress ? "true" : "false");
                if (!string.IsNullOrEmpty(p.MaskBase64))
                    sb.Append(",\"mask\":\"").Append(p.MaskBase64).Append("\"");
                sb.Append("}");
            }
            sb.Append("]");
        }

        /// <summary>由 SaveService 在读盘时调用。</summary>
        public static void Read(JsonValue node)
        {
            Map.Clear();
            if (node == null || node.Type != JsonValue.Kind.Array) return;
            foreach (var item in node.AsArray())
            {
                if (item == null || item.Type != JsonValue.Kind.Object) continue;
                var id = item["id"].AsString();
                if (string.IsNullOrEmpty(id)) continue;
                var p = new MiniGameProgress
                {
                    DefId = id,
                    Done = item["done"].AsInt(),
                    Total = Mathf.Max(1, item["total"].AsInt(1)),
                    InProgress = item["inProgress"].AsBool(),
                    MaskBase64 = item["mask"].AsString(),
                };
                Map[id] = p;
            }
        }

        static string Escape(string s)
        {
            return string.IsNullOrEmpty(s) ? "" : s.Replace("\\", "\\\\").Replace("\"", "\\\"");
        }
    }
}
