using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// 将场景 UI「CheeseCount」文本接入 CheeseHud.lua。
/// 菜单：Tools / Egg Rescue / Wire Cheese Count HUD
/// </summary>
public static class CheeseHudWireFactory
{
    private const string ScenePath = "Assets/Scenes/Mechanics_Code.unity";
    private const string NotebookName = "Notebook";
    private const string CountTextName = "CheeseCount";
    private const string HudLuaPath = "Assets/luaScripts/CheeseHud.lua";

    [MenuItem("EggRescue/Mouse/Wire Cheese Count HUD")]
    [MenuItem("Tools/Egg Rescue/Wire Cheese Count HUD")]
    public static void WireCheeseCountHud()
    {
        WireCheeseCountHudInternal(showDialog: true);
    }

    public static void BatchWireCheeseCountHud()
    {
        WireCheeseCountHudInternal(showDialog: false);
    }

    private static void WireCheeseCountHudInternal(bool showDialog)
    {
        if (!EnsureSceneOpen())
        {
            return;
        }

        GameObject notebook = GameObject.Find(NotebookName);
        if (notebook == null)
        {
            Debug.LogError("[CheeseHudWireFactory] 未找到 " + NotebookName);
            return;
        }

        Text countText = FindCountText(notebook.transform);
        if (countText == null)
        {
            Debug.LogError("[CheeseHudWireFactory] 未找到 UI 文本: " + CountTextName);
            return;
        }

        countText.text = "0";

        Component hud = EnsureDouyinScript(notebook, HudLuaPath);
        if (hud == null)
        {
            return;
        }

        InteractionPointFactoryHelpers.SetObjectBinding(hud, "countText", countText);

        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        string msg = "已接入 CheeseCount HUD → " + GetHierarchyPath(countText.transform);
        Debug.Log("[CheeseHudWireFactory] " + msg);
        if (showDialog)
        {
            EditorUtility.DisplayDialog("Cheese HUD", msg, "OK");
        }
    }

    private static Text FindCountText(Transform notebookRoot)
    {
        Text[] texts = notebookRoot.GetComponentsInChildren<Text>(true);
        foreach (Text text in texts)
        {
            if (text.gameObject.name == CountTextName)
            {
                return text;
            }
        }

        return null;
    }

    private static string GetHierarchyPath(Transform t)
    {
        string path = t.name;
        while (t.parent != null)
        {
            t = t.parent;
            path = t.name + "/" + path;
        }

        return path;
    }

    private static Component EnsureDouyinScript(GameObject go, string assetPath)
    {
        UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (asset == null)
        {
            Debug.LogError("[CheeseHudWireFactory] 未找到脚本: " + assetPath);
            return null;
        }

        string guid = AssetDatabase.AssetPathToGUID(assetPath);
        Component existing = FindDouyinScriptByGuid(go, guid);
        if (existing != null)
        {
            return existing;
        }

        Type douyinScriptType = null;
        foreach (var asm in AppDomain.CurrentDomain.GetAssemblies())
        {
            douyinScriptType = asm.GetType("DouyinScript");
            if (douyinScriptType != null)
            {
                break;
            }
        }

        if (douyinScriptType == null)
        {
            Debug.LogError("[CheeseHudWireFactory] 未找到 DouyinScript 类型");
            return null;
        }

        Component comp = go.AddComponent(douyinScriptType);
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty scriptAsset = so.FindProperty("ScriptAsset");
        if (scriptAsset != null)
        {
            scriptAsset.objectReferenceValue = asset;
            so.ApplyModifiedProperties();
        }

        return comp;
    }

    private static Component FindDouyinScriptByGuid(GameObject go, string scriptGuid)
    {
        foreach (Component comp in go.GetComponents<Component>())
        {
            if (comp == null)
            {
                continue;
            }

            SerializedObject so = new SerializedObject(comp);
            SerializedProperty scriptAsset = so.FindProperty("ScriptAsset");
            if (scriptAsset == null || scriptAsset.objectReferenceValue == null)
            {
                continue;
            }

            string path = AssetDatabase.GetAssetPath(scriptAsset.objectReferenceValue);
            if (AssetDatabase.AssetPathToGUID(path) == scriptGuid)
            {
                return comp;
            }
        }

        return null;
    }

    private static bool EnsureSceneOpen()
    {
        Scene active = SceneManager.GetActiveScene();
        if (active.path == ScenePath)
        {
            return true;
        }

        if (Application.isBatchMode)
        {
            EditorSceneManager.OpenScene(ScenePath);
            return true;
        }

        if (EditorSceneManager.SaveCurrentModifiedScenesIfUserWantsTo())
        {
            EditorSceneManager.OpenScene(ScenePath);
            return true;
        }

        return false;
    }
}
