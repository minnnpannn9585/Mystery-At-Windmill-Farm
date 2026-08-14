using UnityEngine;
using UnityEditor;
using System;
using System.IO;

public class CreateDialogueDataObjects
{
    [MenuItem("Tools/Egg Rescue/Refresh Scene DialogueData (Legacy Path)")]
    public static void CreateLegacy()
    {
        Create();
    }

    [MenuItem("Tools/Create DialogueData Objects")]
    public static void Create()
    {
        // 查找 DouyinScript 类型
        Type douyinScriptType = null;
        foreach (var asm in AppDomain.CurrentDomain.GetAssemblies())
        {
            douyinScriptType = asm.GetType("DouyinScript");
            if (douyinScriptType != null) break;
        }

        if (douyinScriptType == null)
        {
            Debug.LogError("[CreateDialogueData] 未找到 DouyinScript 类型");
            return;
        }

        // 直接用 Directory.GetFiles 扫描 .lua 文件（.lua 不是 TextAsset，是 ScriptedImporter）
        string dialogueDataPath = Path.Combine(Application.dataPath, "Data/DialogueData");
        if (!Directory.Exists(dialogueDataPath))
        {
            Debug.LogWarning("[CreateDialogueData] 目录不存在: " + dialogueDataPath);
            return;
        }

        string[] luaFiles = Directory.GetFiles(dialogueDataPath, "*.lua", SearchOption.AllDirectories);
        if (luaFiles.Length == 0)
        {
            Debug.LogWarning("[CreateDialogueData] DialogueData 目录下没有 .lua 文件");
            return;
        }

        // 查找或创建父物体
        GameObject parent = GameObject.Find("DialogueData");
        if (parent == null)
        {
            parent = new GameObject("DialogueData");
            Debug.Log("[CreateDialogueData] 创建父物体: DialogueData");
        }

        // 清空已有子物体
        while (parent.transform.childCount > 0)
        {
            UnityEngine.Object.DestroyImmediate(parent.transform.GetChild(0).gameObject);
        }

        int count = 0;
        foreach (string fullPath in luaFiles)
        {
            // 转为 Assets 相对路径
            string assetPath = "Assets" + fullPath.Replace(Application.dataPath, "").Replace("\\", "/");
            string fileName = Path.GetFileNameWithoutExtension(fullPath);

            // 加载 lua 资源（使用 UnityEngine.Object，因为不是 TextAsset）
            UnityEngine.Object luaAsset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
            if (luaAsset == null)
            {
                Debug.LogWarning("[CreateDialogueData] 无法加载: " + assetPath);
                continue;
            }

            // 创建子物体
            GameObject child = new GameObject(fileName);
            child.transform.SetParent(parent.transform);

            // 挂载 DouyinScript 组件
            Component comp = child.AddComponent(douyinScriptType);

            // 设置 ScriptAsset 字段
            SerializedObject so = new SerializedObject(comp);
            SerializedProperty scriptAssetProp = so.FindProperty("ScriptAsset");
            if (scriptAssetProp != null)
            {
                scriptAssetProp.objectReferenceValue = luaAsset;
                so.ApplyModifiedProperties();
            }
            else
            {
                Debug.LogWarning("[CreateDialogueData] 未找到 ScriptAsset 字段: " + fileName);
            }

            count++;
        }

        // 标记场景已修改
        UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(
            UnityEditor.SceneManagement.EditorSceneManager.GetActiveScene());

        Debug.Log("[CreateDialogueData] 完成! 创建了 " + count + " 个物体，父物体: DialogueData");
    }
}