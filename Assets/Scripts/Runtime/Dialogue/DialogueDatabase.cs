using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public static class DialogueDatabase
    {
        static readonly Dictionary<string, DialogueGraph> Graphs = new Dictionary<string, DialogueGraph>();

        public static void LoadAll()
        {
            Graphs.Clear();
            var assets = Resources.LoadAll<TextAsset>("GameData/Dialogue");
            if (assets == null || assets.Length == 0)
            {
                Debug.LogError("[DialogueDatabase] no JSON in Resources/GameData/Dialogue");
                return;
            }
            for (var i = 0; i < assets.Length; i++)
            {
                var graph = DialogueGraph.FromJson(JsonValue.Parse(assets[i].text));
                var key = string.IsNullOrEmpty(graph.Module) ? assets[i].name : graph.Module;
                Graphs[key] = graph;
            }
            Debug.Log("[DialogueDatabase] loaded " + Graphs.Count + " modules");
        }

        public static DialogueGraph Get(string module)
        {
            DialogueGraph g;
            if (!string.IsNullOrEmpty(module) && Graphs.TryGetValue(module, out g))
                return g;
            return null;
        }

        public static DialogueGraph LoadNpc(string npcName)
        {
            var npc = NpcRegistry.GetByName(npcName);
            if (npc == null)
            {
                Debug.LogError("[DialogueLoad] unknown npc " + npcName);
                return null;
            }
            var graphMeta = NpcRegistry.ResolveGraph(npc);
            if (graphMeta == null)
            {
                Debug.LogError("[DialogueLoad] no graph for " + npcName);
                return null;
            }
            var graph = Get(graphMeta.ModuleName);
            if (graph == null)
            {
                Debug.LogError("[DialogueLoad] missing module " + graphMeta.ModuleName);
                return null;
            }
            if (graphMeta.MergeModules == null || graphMeta.MergeModules.Count == 0)
                return graph;
            var copy = new DialogueGraph { Module = graph.Module };
            foreach (var kv in graph.Nodes)
                copy.Nodes[kv.Key] = kv.Value;
            for (var i = 0; i < graphMeta.MergeModules.Count; i++)
            {
                var extra = Get(graphMeta.MergeModules[i]);
                if (extra == null) continue;
                foreach (var kv in extra.Nodes)
                    copy.Nodes[kv.Key] = kv.Value;
            }
            return copy;
        }
    }
}
