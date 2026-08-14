using UnityEditor;
using UnityEngine;

namespace EggRescue.Editor
{
    public static class PcRuntimeSetup
    {
        [MenuItem("Tools/Egg Rescue/PC/Setup Scene For PC Runtime")]
        public static void SetupScene()
        {
            EnsureBuildSettings();
            EnsureSpawn();
            EnsureBootstrap();
            WireDialoguePortraits();
            WireNotebookAndHud();
            DouyinComponentMigrator.MigrateQuiet();
            DisableDouyinScripts();
            EditorUtility.DisplayDialog("Egg Rescue PC", "已写入 Build Settings、PlayerSpawn、GameBootstrap，迁移 C# 组件并禁用 DouyinScript。", "OK");
        }

        [MenuItem("Tools/Egg Rescue/PC/Disable Douyin Scripts In Open Scene")]
        public static void DisableDouyinScriptsMenu()
        {
            var n = DisableDouyinScripts();
            EditorUtility.DisplayDialog("Egg Rescue PC", "已禁用 DouyinScript 组件: " + n, "OK");
        }

        static void EnsureBuildSettings()
        {
            var scene = "Assets/Scenes/Mechanics_Code.unity";
            var list = new System.Collections.Generic.List<EditorBuildSettingsScene>(EditorBuildSettings.scenes);
            for (var i = 0; i < list.Count; i++)
                if (list[i].path == scene) return;
            list.Insert(0, new EditorBuildSettingsScene(scene, true));
            EditorBuildSettings.scenes = list.ToArray();
        }

        static void EnsureSpawn()
        {
            var spawn = GameObject.Find("PlayerSpawn");
            if (spawn == null)
            {
                spawn = new GameObject("PlayerSpawn");
                Undo.RegisterCreatedObjectUndo(spawn, "Create PlayerSpawn");
            }
            var shufen = GameObject.Find("淑芬");
            if (shufen != null)
            {
                var toChicken = shufen.transform.forward;
                if (toChicken.sqrMagnitude < 0.01f) toChicken = Vector3.forward;
                toChicken.y = 0f;
                toChicken.Normalize();
                spawn.transform.position = shufen.transform.position + toChicken * 2.2f + Vector3.up * 0.5f;
                spawn.transform.rotation = Quaternion.LookRotation((shufen.transform.position - spawn.transform.position).normalized, Vector3.up);
            }
            else if (spawn.transform.position.sqrMagnitude < 0.01f)
            {
                spawn.transform.position = Vector3.up;
            }
            PlaceMainCameraBehindSpawn(spawn.transform);
        }

        static void PlaceMainCameraBehindSpawn(Transform spawn)
        {
            var cam = Camera.main;
            if (cam == null || spawn == null) return;
            var lookHeight = Vector3.up * 1.4f;
            var lookAt = spawn.position + lookHeight;
            var back = -spawn.forward;
            if (back.sqrMagnitude < 0.01f) back = Vector3.back;
            back.y = 0f;
            back.Normalize();
            var pos = lookAt + back * 6.5f + Vector3.up * 1.2f;
            Undo.RecordObject(cam.transform, "Place Main Camera behind PlayerSpawn");
            cam.transform.SetPositionAndRotation(pos, Quaternion.LookRotation(lookAt - pos, Vector3.up));
            EditorUtility.SetDirty(cam.transform);
        }

        static void EnsureBootstrap()
        {
            if (Object.FindObjectOfType<GameBootstrap>() != null) return;
            var go = new GameObject("EggRescue_Runtime");
            var boot = go.AddComponent<GameBootstrap>();
            var spawn = GameObject.Find("PlayerSpawn");
            if (spawn != null) boot.playerSpawn = spawn.transform;
            go.AddComponent<AudioDirector>();
            Undo.RegisterCreatedObjectUndo(go, "Create GameBootstrap");
        }

        static void WireDialoguePortraits()
        {
            var dmGo = GameObject.Find("DialogueManager");
            if (dmGo == null) return;
            var dm = dmGo.GetComponent<DialogueManager>();
            if (dm == null) dm = dmGo.AddComponent<DialogueManager>();
            var keys = new[]
            {
                "守望","护雏","团聚","醉倒","执勤","振奋","丧","介入","兜售","八卦","发怵",
                "装酷","心虚","愧疚","背对","得意","吝啬","叫嚣","高傲","审视","炸毛","待机","闪电蜗牛"
            };
            var folders = new[]
            {
                "Assets/Res/Model/TouXiang_LiHui/Hen",
                "Assets/Res/Model/TouXiang_LiHui/Dog",
                "Assets/Res/Model/TouXiang_LiHui/Frog",
                "Assets/Res/Model/TouXiang_LiHui/Mouse",
                "Assets/Res/Model/TouXiang_LiHui/Chicken",
                "Assets/Res/Model/TouXiang_LiHui/WuYa",
                "Assets/Res/Model/TouXiang_LiHui/Cat",
                "Assets/Res/Model/TouXiang_LiHui/Snail"
            };
            var sprites = new Sprite[keys.Length];
            for (var i = 0; i < keys.Length; i++)
            {
                for (var f = 0; f < folders.Length; f++)
                {
                    var guids = AssetDatabase.FindAssets(keys[i] + " t:Sprite", new[] { folders[f] });
                    if (guids == null || guids.Length == 0) continue;
                    sprites[i] = AssetDatabase.LoadAssetAtPath<Sprite>(AssetDatabase.GUIDToAssetPath(guids[0]));
                    if (sprites[i] != null) break;
                }
            }
            dm.SetPortraits(keys, sprites);
            EditorUtility.SetDirty(dm);
        }

        static void WireNotebookAndHud()
        {
            var notebook = GameObject.Find("Notebook");
            if (notebook != null && notebook.GetComponent<BookController>() == null)
                notebook.AddComponent<BookController>();
            var texts = Object.FindObjectsOfType<UnityEngine.UI.Text>(true);
            for (var i = 0; i < texts.Length; i++)
            {
                if (texts[i].name.IndexOf("Cheese", System.StringComparison.OrdinalIgnoreCase) < 0
                    && texts[i].gameObject.name.IndexOf("Cheese", System.StringComparison.OrdinalIgnoreCase) < 0)
                    continue;
                var hud = texts[i].GetComponentInParent<CheeseHud>();
                if (hud == null) hud = texts[i].gameObject.AddComponent<CheeseHud>();
                hud.countText = texts[i];
                break;
            }
        }

        public static int DisableDouyinScripts()
        {
            var count = 0;
            var behaviours = Object.FindObjectsOfType<MonoBehaviour>(true);
            for (var i = 0; i < behaviours.Length; i++)
            {
                var mb = behaviours[i];
                if (mb == null) continue;
                var typeName = mb.GetType().Name;
                if (typeName != "DouyinScript") continue;
                mb.enabled = false;
                count++;
            }
            return count;
        }
    }
}
