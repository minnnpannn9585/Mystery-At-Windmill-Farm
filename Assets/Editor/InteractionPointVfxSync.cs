using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 为点击式检视 E 点批量挂载首次检视粒子（黄=入笔记本，粉=其他）。
/// 菜单：EggRescue / Interaction Points / Sync Inspect VFX
/// </summary>
public static class InteractionPointVfxSync
{
    private const string ScenePath = "Assets/Scenes/Mechanics_Code.unity";
    private const string ParentName = "InteractionPoint";
    private const string YellowPrefabPath = "Assets/Res/vfx/prefabs/VFX_InteractionPoint.prefab";
    private const string PinkPrefabPath = "Assets/Res/vfx/prefabs/VFX_InteractionPoint_Pink.prefab";
    private const string ControllerLuaPath = "Assets/luaScripts/InteractionPointVfxController.lua";
    private const string ControllerGuid = "b7c4e2a91f5d4e6a8b0c1d2e3f4a5b6c";
    private const string DouyinInteractorGuid = "0a6b2e5dd40d0804b81a27cdfccd5ba5";
    private const string YellowChildName = "VFX_InteractionPoint";
    private const string PinkChildName = "VFX_InteractionPoint_Pink";
    private const string DiscoverMethod = "Discover";

    private enum VfxKind
    {
        YellowNotebook,
        PinkOther,
    }

    private struct VfxSpec
    {
        public string GoName;
        public VfxKind Kind;
    }

    // 显式清单：入笔记本用黄，其余点击检视用粉；排除 E20 / E35–E39。
    private static readonly VfxSpec[] Specs =
    {
        new VfxSpec { GoName = "E01 · 短木炭", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E02 · 散落羽毛", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E03 · 身后偷听点", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E05 · 谷物泡水", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E06 · 发现缺少梯子", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E07 · 午睡点", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E08 · 焦黑稻草", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E09 · 动物爪印", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E10 · 乌鸦巢白石头（假蛋）", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E11 · 狗窝旁旧木桶", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E12 · 悲伤蛙身下绿垫", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E13 · 紧闭大门", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E14 · 精美猫门", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E15 · 门外陶瓷碗", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E16 · 门边兽毛", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E17 · 空水桶", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E18 · 雨靴泥脚印", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E19 · 关闭二层窗", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E21 · 窗台下爪痕", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E22 · 狗窝空窝", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E23 · 池塘岸边蹚水痕迹", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E24 · 压平稻草", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E25 · 池塘边小鸡脚印", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E26 · 发酵苹果渣", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E27 · 谷仓高处彩色反光", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E28 · 大橡树根抓痕", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E29 · 窗缝暖黄灯", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E30 · 鸡羽毛", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E30 · 狗毛", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E30 · 鼠毛", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E30 · 黑色细毛", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E31 · 旧蛋壳碎片", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E32 · Flash宽叶", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E33 · 泥里松果", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E34 · 玻璃珠", Kind = VfxKind.YellowNotebook },
        new VfxSpec { GoName = "E34 · 瓶盖", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E34 · 发卡", Kind = VfxKind.PinkOther },
        new VfxSpec { GoName = "E34 · 奶糖", Kind = VfxKind.PinkOther },
    };

    [MenuItem("EggRescue/Interaction Points/Sync Inspect VFX")]
    public static void SyncInspectVfx()
    {
        SyncInspectVfxInternal(showDialog: true);
    }

    /// <summary>供 Unity -batchmode -executeMethod 调用</summary>
    public static void BatchSyncInspectVfx()
    {
        SyncInspectVfxInternal(showDialog: false);
    }

    private static void SyncInspectVfxInternal(bool showDialog)
    {
        if (!EnsureSceneOpen())
        {
            return;
        }

        Transform parent = FindChildTransform(null, ParentName);
        if (parent == null)
        {
            Debug.LogError("[InteractionPointVfxSync] 未找到 InteractionPoint 父节点");
            return;
        }

        GameObject yellowPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(YellowPrefabPath);
        GameObject pinkPrefab = AssetDatabase.LoadAssetAtPath<GameObject>(PinkPrefabPath);
        if (yellowPrefab == null || pinkPrefab == null)
        {
            Debug.LogError("[InteractionPointVfxSync] 未找到黄/粉 VFX prefab");
            return;
        }

        int synced = 0;
        int skippedMissing = 0;
        int alreadyOk = 0;

        foreach (VfxSpec spec in Specs)
        {
            Transform point = FindChildTransform(parent, spec.GoName);
            if (point == null)
            {
                Debug.LogWarning("[InteractionPointVfxSync] 场景中不存在，跳过: " + spec.GoName);
                skippedMissing++;
                continue;
            }

            bool changed = SyncPoint(point.gameObject, spec, yellowPrefab, pinkPrefab);
            if (changed)
            {
                synced++;
            }
            else
            {
                alreadyOk++;
            }
        }

        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        EditorSceneManager.SaveScene(SceneManager.GetActiveScene());

        string msg = $"同步完成。更新 {synced}，已就绪 {alreadyOk}，缺失 {skippedMissing}。";
        Debug.Log("[InteractionPointVfxSync] " + msg);
        if (showDialog)
        {
            EditorUtility.DisplayDialog("Interaction Point VFX Sync", msg, "OK");
        }
    }

    private static bool SyncPoint(GameObject point, VfxSpec spec, GameObject yellowPrefab, GameObject pinkPrefab)
    {
        bool changed = false;
        string expectedName = spec.Kind == VfxKind.YellowNotebook ? YellowChildName : PinkChildName;
        GameObject prefab = spec.Kind == VfxKind.YellowNotebook ? yellowPrefab : pinkPrefab;

        RemoveWrongVfxChildren(point.transform, expectedName, ref changed);
        GameObject vfxGo = EnsureVfxChild(point.transform, expectedName, prefab, ref changed);
        Component controller = EnsureController(point, spec.GoName, vfxGo, ref changed);
        Component interactor = FindDouyinScriptByGuid(point, DouyinInteractorGuid);
        if (interactor != null && controller != null)
        {
            if (AppendDiscoverAction(interactor, controller))
            {
                changed = true;
            }
        }
        else if (interactor == null)
        {
            Debug.LogWarning("[InteractionPointVfxSync] 无 DouyinInteractor，跳过动作接线: " + spec.GoName);
        }

        return changed;
    }

    private static void RemoveWrongVfxChildren(Transform point, string expectedName, ref bool changed)
    {
        for (int i = point.childCount - 1; i >= 0; i--)
        {
            Transform child = point.GetChild(i);
            if (child.name != YellowChildName && child.name != PinkChildName)
            {
                continue;
            }

            if (child.name == expectedName)
            {
                continue;
            }

            Undo.DestroyObjectImmediate(child.gameObject);
            changed = true;
        }
    }

    private static GameObject EnsureVfxChild(Transform point, string expectedName, GameObject prefab, ref bool changed)
    {
        Transform existing = point.Find(expectedName);
        if (existing != null)
        {
            PrefabInstanceStatus status = PrefabUtility.GetPrefabInstanceStatus(existing.gameObject);
            if (status == PrefabInstanceStatus.Connected || status == PrefabInstanceStatus.MissingAsset)
            {
                if (existing.localPosition != Vector3.zero
                    || existing.localRotation != Quaternion.identity
                    || existing.localScale != Vector3.one)
                {
                    // 保留用户微调；不强制重置
                }

                return existing.gameObject;
            }
        }

        if (existing != null)
        {
            Undo.DestroyObjectImmediate(existing.gameObject);
        }

        GameObject instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab, point);
        instance.name = expectedName;
        instance.transform.localPosition = Vector3.zero;
        instance.transform.localRotation = Quaternion.identity;
        instance.transform.localScale = Vector3.one;
        Undo.RegisterCreatedObjectUndo(instance, "Add Inspect VFX");
        changed = true;
        return instance;
    }

    private static Component EnsureController(GameObject point, string pointId, GameObject vfxGo, ref bool changed)
    {
        Component controller = FindDouyinScriptByGuid(point, ControllerGuid);
        if (controller == null)
        {
            controller = AddDouyinScript(point, ControllerLuaPath);
            if (controller == null)
            {
                return null;
            }

            changed = true;
        }

        InteractionPointFactoryHelpers.SetStringBinding(controller, "pointId", pointId);
        InteractionPointFactoryHelpers.SetObjectBinding(controller, "targetVfx", vfxGo);
        return controller;
    }

    private static bool AppendDiscoverAction(Component interactor, Component controller)
    {
        SerializedObject so = new SerializedObject(interactor);
        SerializedProperty refIds = so.FindProperty("references")?.FindPropertyRelative("RefIds");
        if (refIds == null)
        {
            return false;
        }

        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null)
            {
                continue;
            }

            SerializedProperty varName = data.FindPropertyRelative("varName");
            if (varName == null || varName.stringValue != "ButtonConfigs")
            {
                continue;
            }

            SerializedProperty buttonData = data.FindPropertyRelative("Data");
            if (buttonData == null || !buttonData.isArray || buttonData.arraySize == 0)
            {
                continue;
            }

            SerializedProperty actions = buttonData.GetArrayElementAtIndex(0).FindPropertyRelative("ButtonActions");
            if (actions == null)
            {
                continue;
            }

            for (int a = 0; a < actions.arraySize; a++)
            {
                SerializedProperty action = actions.GetArrayElementAtIndex(a);
                SerializedProperty method = action.FindPropertyRelative("methodName");
                SerializedProperty target = action.FindPropertyRelative("Data");
                if (method != null
                    && method.stringValue == DiscoverMethod
                    && target != null
                    && target.objectReferenceValue == controller)
                {
                    return false;
                }
            }

            int newIndex = actions.arraySize;
            actions.InsertArrayElementAtIndex(newIndex);
            SerializedProperty newAction = actions.GetArrayElementAtIndex(newIndex);
            SerializedProperty dataRef = newAction.FindPropertyRelative("Data");
            SerializedProperty methodName = newAction.FindPropertyRelative("methodName");
            SerializedProperty varNameProp = newAction.FindPropertyRelative("varName");
            if (dataRef == null || methodName == null)
            {
                Debug.LogWarning("[InteractionPointVfxSync] ButtonActions 元素结构异常，跳过 Discover 接线");
                return false;
            }

            if (varNameProp != null)
            {
                varNameProp.stringValue = "";
            }

            dataRef.objectReferenceValue = controller;
            methodName.stringValue = DiscoverMethod;
            so.ApplyModifiedProperties();
            EditorUtility.SetDirty(interactor);
            return true;
        }

        Debug.LogWarning("[InteractionPointVfxSync] 未找到 ButtonConfigs，Discover 依赖运行时 ClueTrigger/DialogueTrigger 钩子");
        return false;
    }

    private static Component AddDouyinScript(GameObject go, string assetPath)
    {
        UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (asset == null)
        {
            Debug.LogError("[InteractionPointVfxSync] 未找到脚本: " + assetPath);
            return null;
        }

        Type douyinScriptType = FindDouyinScriptType();
        if (douyinScriptType == null)
        {
            Debug.LogError("[InteractionPointVfxSync] 未找到 DouyinScript 类型");
            return null;
        }

        Component comp = Undo.AddComponent(go, douyinScriptType);
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty scriptAsset = so.FindProperty("ScriptAsset");
        if (scriptAsset != null)
        {
            scriptAsset.objectReferenceValue = asset;
            so.ApplyModifiedProperties();
        }

        // 触发 Douyin 绑定槽生成（若 SDK 在赋值 ScriptAsset 后填充）
        so.Update();
        EditorUtility.SetDirty(comp);
        return comp;
    }

    private static Type FindDouyinScriptType()
    {
        foreach (var asm in AppDomain.CurrentDomain.GetAssemblies())
        {
            Type t = asm.GetType("DouyinScript");
            if (t != null)
            {
                return t;
            }
        }

        return null;
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

    private static Transform FindChildTransform(Transform parent, string name)
    {
        if (parent == null)
        {
            GameObject root = GameObject.Find(ParentName);
            if (root == null)
            {
                return null;
            }

            return name == ParentName ? root.transform : root.transform.Find(name);
        }

        return parent.Find(name);
    }
}
