using System;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 创建奶酪碎占位 Box Prefab（后续可替换美术）。
/// 菜单：EggRescue / Mouse / Create Cheese Pickup Prefab
/// </summary>
public static class CheesePrefabFactory
{
    public const string PrefabPath = "Assets/Prefabs/CheesePickupPlaceholder.prefab";
    private const string LuaPath = "Assets/luaScripts/CheesePickup.lua";

    [MenuItem("EggRescue/Mouse/Create Cheese Pickup Prefab")]
    [MenuItem("Tools/Egg Rescue/Mouse/Create Cheese Pickup Prefab")]
    public static void CreateCheesePickupPrefab()
    {
        CreateCheesePickupPrefabInternal(showDialog: true);
    }

    public static GameObject EnsureCheesePickupPrefab()
    {
        GameObject existing = AssetDatabase.LoadAssetAtPath<GameObject>(PrefabPath);
        if (existing != null)
        {
            return existing;
        }

        return CreateCheesePickupPrefabInternal(showDialog: false);
    }

    private static GameObject CreateCheesePickupPrefabInternal(bool showDialog)
    {
        var root = new GameObject("CheesePickupPlaceholder");
        var visual = GameObject.CreatePrimitive(PrimitiveType.Cube);
        visual.name = "Visual";
        visual.transform.SetParent(root.transform, false);
        visual.transform.localPosition = new Vector3(0f, 0.25f, 0f);
        visual.transform.localScale = new Vector3(0.35f, 0.35f, 0.35f);
        UnityEngine.Object.DestroyImmediate(visual.GetComponent<Collider>());

        var trigger = root.AddComponent<BoxCollider>();
        trigger.isTrigger = true;
        trigger.size = new Vector3(0.8f, 0.8f, 0.8f);
        trigger.center = new Vector3(0f, 0.4f, 0f);

        Component pickup = AddDouyinScript(root, LuaPath);
        if (pickup != null)
        {
            InteractionPointFactoryHelpers.SetIntBinding(pickup, "amount", 1);
            InteractionPointFactoryHelpers.SetBoolBinding(pickup, "requiresNGPlus", false);
            InteractionPointFactoryHelpers.SetObjectBinding(pickup, "visualRoot", visual);
        }

        if (!AssetDatabase.IsValidFolder("Assets/Prefabs"))
        {
            AssetDatabase.CreateFolder("Assets", "Prefabs");
        }

        GameObject prefab = PrefabUtility.SaveAsPrefabAsset(root, PrefabPath);
        UnityEngine.Object.DestroyImmediate(root);

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        string msg = "已创建占位 Prefab: " + PrefabPath;
        Debug.Log("[CheesePrefabFactory] " + msg);
        if (showDialog)
        {
            EditorUtility.DisplayDialog("Cheese Prefab Factory", msg, "OK");
        }

        return prefab;
    }

    private static Component AddDouyinScript(GameObject go, string assetPath)
    {
        UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (asset == null)
        {
            Debug.LogError("[CheesePrefabFactory] 未找到脚本: " + assetPath);
            return null;
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
            Debug.LogError("[CheesePrefabFactory] 未找到 DouyinScript 类型");
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
}
