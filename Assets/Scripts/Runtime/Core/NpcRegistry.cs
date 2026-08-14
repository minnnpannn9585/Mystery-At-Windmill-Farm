using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public sealed class NpcStoryGraph
    {
        public int BranchId;
        public string ModuleName;
        public string Description;
        public List<string> MergeModules;
    }

    public sealed class NpcDef
    {
        public string Id;
        public string Name;
        public string AvatarPath;
        public int CurrentBranchId = 1;
        public readonly List<NpcStoryGraph> StoryGraphs = new List<NpcStoryGraph>();
    }

    public static class NpcRegistry
    {
        static readonly List<NpcDef> List = new List<NpcDef>();
        static readonly Dictionary<string, NpcDef> ByName = new Dictionary<string, NpcDef>();
        static readonly Dictionary<string, NpcDef> ById = new Dictionary<string, NpcDef>();

        public static IReadOnlyList<NpcDef> All { get { return List; } }

        public static void Load()
        {
            List.Clear();
            ByName.Clear();
            ById.Clear();
            var ta = Resources.Load<TextAsset>("GameData/npc_data");
            if (ta == null)
            {
                Debug.LogError("[NpcRegistry] missing Resources/GameData/npc_data.txt");
                return;
            }

            var root = JsonValue.Parse(ta.text);
            foreach (var item in root["npcList"].AsArray())
            {
                var npc = new NpcDef
                {
                    Id = item["id"].AsString(),
                    Name = item["name"].AsString(),
                    AvatarPath = item["avatarPath"].AsString(),
                    CurrentBranchId = item["currentBranchId"].AsInt(1)
                };
                foreach (var g in item["storyGraphs"].AsArray())
                {
                    var graph = new NpcStoryGraph
                    {
                        BranchId = g["branchId"].AsInt(1),
                        ModuleName = g["luaModuleName"].AsString(),
                        Description = g["storyDescription"].AsString(),
                        MergeModules = new List<string>()
                    };
                    if (string.IsNullOrEmpty(graph.ModuleName))
                    {
                        var path = g["luaAssetPath"].AsString();
                        graph.ModuleName = System.IO.Path.GetFileNameWithoutExtension(path);
                    }
                    foreach (var extra in g["mergeLuaModules"].AsArray())
                        graph.MergeModules.Add(extra.AsString());
                    npc.StoryGraphs.Add(graph);
                }
                List.Add(npc);
                if (!string.IsNullOrEmpty(npc.Name)) ByName[npc.Name] = npc;
                if (!string.IsNullOrEmpty(npc.Id)) ById[npc.Id] = npc;
            }
            ResetBranchesToStart();
            Debug.Log("[NpcRegistry] loaded " + List.Count + " npcs");
        }

        public static NpcDef GetByName(string name)
        {
            NpcDef npc;
            if (!string.IsNullOrEmpty(name) && ByName.TryGetValue(name, out npc))
                return npc;
            return null;
        }

        public static void UnlockBranch(string npcName, int branchId)
        {
            var npc = GetByName(npcName);
            if (npc == null || branchId <= 0) return;
            npc.CurrentBranchId = branchId;
        }

        public static void ResetBranchesToStart()
        {
            for (var i = 0; i < List.Count; i++)
                List[i].CurrentBranchId = 1;
        }

        public static string ResolveModuleName(NpcDef npc)
        {
            if (npc == null || npc.StoryGraphs.Count == 0) return null;
            for (var i = 0; i < npc.StoryGraphs.Count; i++)
            {
                if (npc.StoryGraphs[i].BranchId == npc.CurrentBranchId && !string.IsNullOrEmpty(npc.StoryGraphs[i].ModuleName))
                    return npc.StoryGraphs[i].ModuleName;
            }
            for (var i = 0; i < npc.StoryGraphs.Count; i++)
            {
                if (npc.StoryGraphs[i].BranchId == 1 && !string.IsNullOrEmpty(npc.StoryGraphs[i].ModuleName))
                {
                    npc.CurrentBranchId = 1;
                    return npc.StoryGraphs[i].ModuleName;
                }
            }
            npc.CurrentBranchId = npc.StoryGraphs[0].BranchId;
            return npc.StoryGraphs[0].ModuleName;
        }

        public static NpcStoryGraph ResolveGraph(NpcDef npc)
        {
            if (npc == null) return null;
            var module = ResolveModuleName(npc);
            for (var i = 0; i < npc.StoryGraphs.Count; i++)
            {
                if (npc.StoryGraphs[i].ModuleName == module)
                    return npc.StoryGraphs[i];
            }
            return null;
        }
    }
}
