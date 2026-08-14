using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace EggRescue.Editor
{
    public static class DouyinComponentMigrator
    {
        static readonly Dictionary<string, Type> LuaToType = new Dictionary<string, Type>(StringComparer.OrdinalIgnoreCase)
        {
            { "DialogueTrigger.lua", typeof(DialogueTrigger) },
            { "DialogueAreaTrigger.lua", typeof(DialogueAreaTrigger) },
            { "ClueTrigger.lua", typeof(ClueTrigger) },
            { "DaHuang.lua", typeof(DaHuangController) },
            { "ShuFen.lua", typeof(ShuFenController) },
            { "BeiShangWa.lua", typeof(BeiShangWaController) },
            { "MouseBrotherController.lua", typeof(MouseBrotherShop) },
            { "BookController.lua", typeof(BookController) },
            { "CheeseHud.lua", typeof(CheeseHud) },
            { "CheesePickup.lua", typeof(CheesePickup) },
            { "CheeseSpawner.lua", typeof(CheeseSpawner) },
            { "CheeseRefreshManager.lua", typeof(CheeseRefreshManager) },
            { "EndingController.lua", typeof(EndingController) },
            { "CrowInteractionController.lua", typeof(CrowInteractionController) },
            { "BlackCatInteractionController.lua", typeof(BlackCatInteractionController) },
            { "TreeInteractionController.lua", typeof(TreeInteractionController) },
            { "E03EavesdropController.lua", typeof(E03EavesdropController) },
            { "E05GrainSoakController.lua", typeof(E05GrainSoakController) },
            { "E06LadderController.lua", typeof(E06LadderController) },
            { "ClimbPathPoint.lua", typeof(ClimbPathPoint) },
            { "SecondFloorWindowController.lua", typeof(SecondFloorWindowController) },
            { "ComicGateTrigger.lua", typeof(ComicGateTrigger) },
            { "LevelTeleport.lua", typeof(LevelTeleport) },
            { "InteractionPointVfxController.lua", typeof(InteractionPointVfx) },
            { "NpcDialogueManager.lua", typeof(DialogueManager) },
        };

        static readonly Dictionary<string, string> FieldAlias = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            { "npcname", "npcName" },
            { "ID", "startId" },
        };

        [MenuItem("Tools/Egg Rescue/PC/Migrate Douyin Interactors To C#")]
        public static void Migrate()
        {
            int added, copied, disabled;
            Run(out added, out copied, out disabled);
            EditorUtility.DisplayDialog("Egg Rescue PC",
                "已按 lua 脚本名迁移 C# 组件并抄 Inspector 绑定。新增/复用组件: " + added
                + "，字段: " + copied + "，禁用 DouyinScript: " + disabled, "OK");
        }

        public static void MigrateQuiet()
        {
            int added, copied, disabled;
            Run(out added, out copied, out disabled);
        }

        static void Run(out int added, out int copied, out int disabled)
        {
            added = 0;
            copied = 0;
            var behaviours = UnityEngine.Object.FindObjectsOfType<MonoBehaviour>(true);
            for (var i = 0; i < behaviours.Length; i++)
            {
                var mb = behaviours[i];
                if (mb == null) continue;
                if (mb.GetType().Name != "DouyinScript") continue;
                var go = mb.gameObject;
                var luaName = GetLuaFileName(mb);
                Type mapped;
                if (!string.IsNullOrEmpty(luaName) && LuaToType.TryGetValue(luaName, out mapped))
                {
                    var existing = go.GetComponent(mapped);
                    if (existing == null) existing = go.AddComponent(mapped);
                    copied += CopyBindings(mb, existing);
                    added++;
                }
                if (NeedsInteractable(luaName) && go.GetComponent<Interactable>() == null)
                {
                    go.AddComponent<Interactable>();
                    added++;
                }
            }
            disabled = PcRuntimeSetup.DisableDouyinScripts();
        }

        static bool NeedsInteractable(string luaName)
        {
            if (string.IsNullOrEmpty(luaName)) return true;
            return luaName.IndexOf("DialogueTrigger", StringComparison.OrdinalIgnoreCase) >= 0
                   || luaName.IndexOf("ClueTrigger", StringComparison.OrdinalIgnoreCase) >= 0
                   || luaName.IndexOf("ComicGate", StringComparison.OrdinalIgnoreCase) >= 0
                   || luaName.IndexOf("E06", StringComparison.OrdinalIgnoreCase) >= 0;
        }

        static string GetLuaFileName(Component douyin)
        {
            var so = new SerializedObject(douyin);
            var scriptAsset = so.FindProperty("ScriptAsset");
            if (scriptAsset == null || scriptAsset.objectReferenceValue == null) return null;
            var path = AssetDatabase.GetAssetPath(scriptAsset.objectReferenceValue);
            return string.IsNullOrEmpty(path) ? null : System.IO.Path.GetFileName(path);
        }

        static int CopyBindings(Component from, Component to)
        {
            if (from == null || to == null) return 0;
            var so = new SerializedObject(from);
            var refIds = so.FindProperty("references");
            if (refIds != null) refIds = refIds.FindPropertyRelative("RefIds");
            if (refIds == null) return 0;
            var n = 0;
            var flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
            for (var i = 0; i < refIds.arraySize; i++)
            {
                var data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
                if (data == null) continue;
                var varNameProp = data.FindPropertyRelative("varName");
                var dataProp = data.FindPropertyRelative("Data");
                if (varNameProp == null || dataProp == null) continue;
                var key = varNameProp.stringValue;
                if (string.IsNullOrEmpty(key)) continue;
                string mapped;
                if (FieldAlias.TryGetValue(key, out mapped)) key = mapped;
                var field = to.GetType().GetField(key, flags);
                if (field == null) continue;
                if (ApplyValue(field, to, dataProp)) n++;
            }
            return n;
        }

        static bool ApplyValue(FieldInfo field, Component target, SerializedProperty dataProp)
        {
            try
            {
                var ft = field.FieldType;
                if (ft == typeof(string) && dataProp.propertyType == SerializedPropertyType.String)
                    field.SetValue(target, dataProp.stringValue);
                else if ((ft == typeof(int) || ft == typeof(int?)) && dataProp.propertyType == SerializedPropertyType.Integer)
                    field.SetValue(target, dataProp.intValue);
                else if (ft == typeof(bool) && dataProp.propertyType == SerializedPropertyType.Boolean)
                    field.SetValue(target, dataProp.boolValue);
                else if (ft == typeof(float) && dataProp.propertyType == SerializedPropertyType.Float)
                    field.SetValue(target, dataProp.floatValue);
                else if (typeof(UnityEngine.Object).IsAssignableFrom(ft) && dataProp.propertyType == SerializedPropertyType.ObjectReference)
                    field.SetValue(target, dataProp.objectReferenceValue);
                else if (ft.IsArray && dataProp.isArray)
                {
                    var elemType = ft.GetElementType();
                    var arr = Array.CreateInstance(elemType, dataProp.arraySize);
                    for (var i = 0; i < dataProp.arraySize; i++)
                    {
                        var el = dataProp.GetArrayElementAtIndex(i);
                        if (typeof(UnityEngine.Object).IsAssignableFrom(elemType))
                            arr.SetValue(el.objectReferenceValue, i);
                    }
                    field.SetValue(target, arr);
                }
                else return false;
                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
