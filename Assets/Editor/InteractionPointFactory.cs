using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 批量生成缺失 E 点占位交互物体（以「短木炭」为模板）。
/// 菜单：EggRescue / Interaction Points / Spawn Missing E-Points
/// </summary>
public static class InteractionPointFactory
{
    private const string ScenePath = "Assets/Scenes/Mechanics_Code.unity";
    private const string TemplateName = "E01 · 短木炭";
    private const string ParentName = "InteractionPoint";

    private const string ClueTriggerGuid = "2090c1a586d0445408748c8c4e87103f";
    private const string DialogueTriggerGuid = "dbdfa9057e4e5a347b4a500a3d30bd57";
    private const string DouyinInteractorGuid = "0a6b2e5dd40d0804b81a27cdfccd5ba5";
    private const string ComicGateGuid = "a8b3c4d5e6f7489012345678abcdef01";
    private const string SecondFloorWindowControllerGuid = "c7d8e9f0a1b2436589012345678def03";
    private const string DialogueAreaTriggerGuid = "f7e8d9c0b1a24365869708090a0b1c2d";
    private const string E19Name = "E19 · 关闭二层窗";
    private const string E20Name = "E20 · 打开二层窗";
    private const string E35Name = "E35 · 攀爬放狠话·B-1";
    private const string E37Name = "E37 · 攻顶喊话·F-1";
    private const string E38Name = "E38 · 攻顶喊话·F-2";

    private struct EPointSpec
    {
        public string GoName;
        public string NpcName;
        public int StartId;
        public string ClueVar1;
        public string ClueVar2;
        public bool ClueVar2IntAdd;
        public Vector3 LocalPos;
        public bool IsComicGate;
    }

    private static readonly EPointSpec[] Specs =
    {
        new EPointSpec { GoName = "E11 · 狗窝旁旧木桶", NpcName = "描述", StartId = 36, LocalPos = new Vector3(12f, 8.4f, -22f) },
        new EPointSpec { GoName = "E19 · 关闭二层窗", NpcName = "描述", StartId = 54, LocalPos = new Vector3(-30f, 12f, 14f) },
        new EPointSpec { GoName = "E20 · 打开二层窗", IsComicGate = true, LocalPos = new Vector3(-29f, 12.5f, 15f) },
        new EPointSpec { GoName = "E21 · 窗台下爪痕", NpcName = "描述", StartId = 55, LocalPos = new Vector3(-27f, 6f, 13f) },
        new EPointSpec { GoName = "E22 · 狗窝空窝", NpcName = "描述", StartId = 320, LocalPos = new Vector3(10f, 8.2f, -20f) },
        new EPointSpec { GoName = "E24 · 压平稻草", NpcName = "描述", StartId = 47, LocalPos = new Vector3(15f, 8.3f, -25f) },
        new EPointSpec { GoName = "E26 · 发酵苹果渣", NpcName = "描述", StartId = 48, LocalPos = new Vector3(-6f, 5.5f, -38f) },
        new EPointSpec { GoName = "E29 · 窗缝暖黄灯", NpcName = "描述", StartId = 58, LocalPos = new Vector3(-26f, 6.5f, 11f) },
        new EPointSpec { GoName = "E30 · 鸡羽毛", NpcName = "描述", StartId = 42, LocalPos = new Vector3(-0.5f, 5.6f, -26.5f) },
        new EPointSpec { GoName = "E30 · 狗毛", NpcName = "描述", StartId = 43, LocalPos = new Vector3(0.3f, 5.6f, -26.8f) },
        new EPointSpec { GoName = "E30 · 鼠毛", NpcName = "描述", StartId = 44, LocalPos = new Vector3(-0.2f, 5.55f, -27.1f) },
        new EPointSpec { GoName = "E30 · 黑色细毛", NpcName = "描述", StartId = 45, ClueVar1 = "E30_BlackFurSeen", LocalPos = new Vector3(0.6f, 5.58f, -27.4f) },
        new EPointSpec { GoName = "E31 · 旧蛋壳碎片", NpcName = "描述", StartId = 49, LocalPos = new Vector3(16f, 8.4f, -26f) },
        new EPointSpec { GoName = "E32 · Flash宽叶", NpcName = "描述", StartId = 51, LocalPos = new Vector3(-18f, 5.5f, 5f) },
        new EPointSpec { GoName = "E33 · 泥里松果", NpcName = "描述", StartId = 52, LocalPos = new Vector3(-8f, 5.4f, -8f) },
        new EPointSpec { GoName = "E34 · 瓶盖", NpcName = "描述", StartId = 39, LocalPos = new Vector3(-1.3f, 5.55f, -27.5f) },
        new EPointSpec { GoName = "E34 · 发卡", NpcName = "描述", StartId = 40, LocalPos = new Vector3(-1.6f, 5.55f, -27.2f) },
        new EPointSpec { GoName = "E34 · 奶糖", NpcName = "描述", StartId = 41, LocalPos = new Vector3(-1.9f, 5.55f, -27.8f) },
        new EPointSpec { GoName = "E37 · 攻顶喊话·F-1", NpcName = "黑猫", StartId = 170, LocalPos = new Vector3(-25f, 9f, 10f) },
        new EPointSpec { GoName = "E38 · 攻顶喊话·F-2", NpcName = "黑猫", StartId = 180, LocalPos = new Vector3(-28f, 11f, 13f) },
    };

    [MenuItem("EggRescue/Interaction Points/Spawn Missing E-Points")]
    public static void SpawnMissingEPoints()
    {
        SpawnMissingEPointsInternal(showDialog: true);
    }

    /// <summary>供 Unity -batchmode -executeMethod 调用</summary>
    public static void BatchSpawnMissingEPoints()
    {
        SpawnMissingEPointsInternal(showDialog: false);
    }

    /// <summary>
    /// E37/E38：改为进范围强制播（同 E35/E36）；需 BlackCat_Entered，播完写 Shown 一次性。
    /// 菜单：EggRescue / Interaction Points / Wire E37 E38 Area Taunts
    /// </summary>
    [MenuItem("EggRescue/Interaction Points/Wire E37 E38 Area Taunts")]
    public static void WireE37E38AreaTaunts()
    {
        WireE37E38AreaTauntsInternal(showDialog: true);
    }

    public static void BatchWireE37E38AreaTaunts()
    {
        WireE37E38AreaTauntsInternal(showDialog: false);
    }

    private static void WireE37E38AreaTauntsInternal(bool showDialog)
    {
        if (!EnsureSceneOpen())
        {
            return;
        }

        Transform parent = FindChildTransform(null, ParentName);
        if (parent == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到 InteractionPoint 父节点");
            return;
        }

        Transform e35 = FindChildTransform(parent, E35Name);
        Component areaTemplate = e35 != null
            ? FindDouyinScriptByGuid(e35.gameObject, DialogueAreaTriggerGuid)
            : null;
        if (areaTemplate == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到 E35 DialogueAreaTrigger 模板");
            return;
        }

        int wired = 0;
        wired += ConfigureRoofTauntArea(
            parent, E37Name, 170, "E37_BlackCatTauntShown", areaTemplate) ? 1 : 0;
        wired += ConfigureRoofTauntArea(
            parent, E38Name, 180, "E38_BlackCatTauntShown", areaTemplate) ? 1 : 0;

        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        EditorSceneManager.SaveScene(SceneManager.GetActiveScene());
        string msg = $"已接线攻顶喊话 AreaTrigger：{wired}/2（需 BlackCat_Entered + 一次性 Shown）";
        Debug.Log("[InteractionPointFactory] " + msg);
        if (showDialog)
        {
            EditorUtility.DisplayDialog("Wire E37/E38", msg, "OK");
        }
    }

    private static bool ConfigureRoofTauntArea(
        Transform parent,
        string goName,
        int startNodeId,
        string shownVar,
        Component areaTemplate)
    {
        Transform t = FindChildTransform(parent, goName);
        if (t == null)
        {
            Debug.LogWarning("[InteractionPointFactory] 未找到: " + goName);
            return false;
        }

        GameObject go = t.gameObject;

        DestroyDouyinScriptByGuid(go, ClueTriggerGuid);
        DestroyDouyinScriptByGuid(go, DialogueTriggerGuid);
        DestroyDouyinScriptByGuid(go, DouyinInteractorGuid);

        Component area = FindDouyinScriptByGuid(go, DialogueAreaTriggerGuid);
        if (area == null)
        {
            Type douyinScriptType = FindDouyinScriptType();
            if (douyinScriptType == null)
            {
                Debug.LogError("[InteractionPointFactory] 未找到 DouyinScript 类型");
                return false;
            }

            area = go.AddComponent(douyinScriptType);
            EditorUtility.CopySerialized(areaTemplate, area);
        }

        SetStringBinding(area, "npcName", "黑猫");
        SetIntBinding(area, "startNodeId", startNodeId);
        SetStringBinding(area, "requireVarName", "BlackCat_Entered");
        SetBoolBinding(area, "requireVarMustBe", true);
        SetStringBinding(area, "blockVarName", shownVar);
        SetBoolBinding(area, "blockWhenTrue", true);
        SetBoolBinding(area, "disableColliderAfterFire", true);
        SetBoolBinding(area, "skipIfDialogueActive", true);

        BoxCollider box = go.GetComponent<BoxCollider>();
        if (box == null)
        {
            box = go.AddComponent<BoxCollider>();
        }

        box.isTrigger = true;
        if (box.size.sqrMagnitude < 0.01f)
        {
            box.size = new Vector3(2f, 2.5f, 2f);
            box.center = new Vector3(0f, 1f, 0f);
        }

        Debug.Log("[InteractionPointFactory] 已接线 AreaTrigger: " + goName);
        return true;
    }

    private static void DestroyDouyinScriptByGuid(GameObject go, string scriptGuid)
    {
        Component comp = FindDouyinScriptByGuid(go, scriptGuid);
        if (comp != null)
        {
            UnityEngine.Object.DestroyImmediate(comp);
        }
    }

    private static void SpawnMissingEPointsInternal(bool showDialog)
    {
        if (!EnsureSceneOpen())
        {
            return;
        }

        Transform parent = FindChildTransform(null, ParentName);
        if (parent == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到 InteractionPoint 父节点");
            return;
        }

        Transform template = FindChildTransform(parent, TemplateName);
        if (template == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到模板物体: " + TemplateName);
            return;
        }

        int created = 0;
        int skipped = 0;

        foreach (EPointSpec spec in Specs)
        {
            if (FindChildTransform(parent, spec.GoName) != null)
            {
                Debug.Log("[InteractionPointFactory] 已存在，跳过: " + spec.GoName);
                skipped++;
                continue;
            }

            GameObject clone = UnityEngine.Object.Instantiate(template.gameObject, parent);
            clone.name = spec.GoName;
            clone.transform.localPosition = spec.LocalPos;
            clone.transform.localRotation = Quaternion.identity;
            clone.transform.localScale = Vector3.one;

            EnsureBoxCollider(clone);

            if (spec.IsComicGate)
            {
                ConfigureComicGate(clone);
            }
            else
            {
                ConfigureStandardPoint(clone, spec);
            }

            created++;
            Debug.Log("[InteractionPointFactory] 已创建: " + spec.GoName);
        }

        EnsureSecondFloorWindowController(parent);

        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        Debug.Log($"[InteractionPointFactory] 完成。新建 {created}，跳过 {skipped}。");
        if (showDialog)
        {
            EditorUtility.DisplayDialog(
                "Interaction Point Factory",
                $"新建 {created} 个占位 E 点\n跳过 {skipped} 个已存在",
                "OK");
        }
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
            return root != null ? root.transform.Find(name) : null;
        }

        return parent.Find(name);
    }

    private static void EnsureBoxCollider(GameObject go)
    {
        BoxCollider box = go.GetComponent<BoxCollider>();
        if (box == null)
        {
            box = go.AddComponent<BoxCollider>();
        }

        box.isTrigger = false;
        box.size = new Vector3(1.5f, 1.5f, 1.5f);
        box.center = new Vector3(0f, 0.75f, 0f);
    }

    private static void ConfigureStandardPoint(GameObject go, EPointSpec spec)
    {
        Component clue = FindDouyinScriptByGuid(go, ClueTriggerGuid);
        Component dialogue = FindDouyinScriptByGuid(go, DialogueTriggerGuid);
        Component interactor = FindDouyinScriptByGuid(go, DouyinInteractorGuid);

        if (dialogue != null)
        {
            SetStringBinding(dialogue, "npcname", spec.NpcName);
            SetIntBinding(dialogue, "ID", spec.StartId);
        }

        if (clue != null)
        {
            ClearClueBindings(clue);
            if (!string.IsNullOrEmpty(spec.ClueVar1))
            {
                SetStringBinding(clue, "varName1", spec.ClueVar1);
                SetStringBinding(clue, "varType1", "bool");
                SetBoolBinding(clue, "varValue1", true);
            }

            if (!string.IsNullOrEmpty(spec.ClueVar2))
            {
                SetStringBinding(clue, "varName2", spec.ClueVar2);
                SetStringBinding(clue, "varType2", "int");
                SetIntBinding(clue, "varIntValue2", 1);
                SetBoolBinding(clue, "varIsAdd2", spec.ClueVar2IntAdd);
            }
        }

        if (interactor != null && clue != null && dialogue != null)
        {
            WireInteractorActions(interactor, dialogue, clue, "StartDialogue", "SetClue");
            SetInteractorButtonText(interactor, spec.GoName);
        }
    }

    private static void ConfigureComicGate(GameObject go)
    {
        Component dialogue = FindDouyinScriptByGuid(go, DialogueTriggerGuid);
        if (dialogue != null)
        {
            UnityEngine.Object.DestroyImmediate(dialogue);
        }

        Type douyinScriptType = FindDouyinScriptType();
        if (douyinScriptType == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到 DouyinScript 类型");
            return;
        }

        UnityEngine.Object comicAsset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(
            "Assets/luaScripts/ComicGateTrigger.lua");
        if (comicAsset == null)
        {
            Debug.LogError("[InteractionPointFactory] 未找到 ComicGateTrigger.lua");
            return;
        }

        Component comic = go.AddComponent(douyinScriptType);
        SerializedObject comicSo = new SerializedObject(comic);
        SerializedProperty scriptAsset = comicSo.FindProperty("ScriptAsset");
        if (scriptAsset != null)
        {
            scriptAsset.objectReferenceValue = comicAsset;
            comicSo.ApplyModifiedProperties();
        }

        Component clue = FindDouyinScriptByGuid(go, ClueTriggerGuid);
        if (clue != null)
        {
            UnityEngine.Object.DestroyImmediate(clue);
        }

        Component interactor = FindDouyinScriptByGuid(go, DouyinInteractorGuid);
        if (interactor != null)
        {
            WireInteractorActions(interactor, comic, null, "OnComicInteract", null);
            SetInteractorButtonText(interactor, "进入阁楼的窗子");
        }

        go.SetActive(false);
    }

    private static void EnsureSecondFloorWindowController(Transform parent)
    {
        if (parent == null)
        {
            return;
        }

        Transform openWindow = parent.Find(E20Name);
        if (openWindow != null && openWindow.gameObject.activeSelf)
        {
            openWindow.gameObject.SetActive(false);
        }

        if (FindDouyinScriptByGuid(parent.gameObject, SecondFloorWindowControllerGuid) != null)
        {
            return;
        }

        Type douyinScriptType = FindDouyinScriptType();
        if (douyinScriptType == null)
        {
            Debug.LogWarning("[InteractionPointFactory] 未找到 DouyinScript 类型，跳过二层窗控制器");
            return;
        }

        UnityEngine.Object controllerAsset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(
            "Assets/luaScripts/SecondFloorWindowController.lua");
        if (controllerAsset == null)
        {
            Debug.LogWarning("[InteractionPointFactory] 未找到 SecondFloorWindowController.lua");
            return;
        }

        Component controller = parent.gameObject.AddComponent(douyinScriptType);
        SerializedObject controllerSo = new SerializedObject(controller);
        SerializedProperty scriptAsset = controllerSo.FindProperty("ScriptAsset");
        if (scriptAsset != null)
        {
            scriptAsset.objectReferenceValue = controllerAsset;
            controllerSo.ApplyModifiedProperties();
        }

        Debug.Log("[InteractionPointFactory] 已挂载 SecondFloorWindowController 至 InteractionPoint");
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

    private static void ClearClueBindings(Component clue)
    {
        SetStringBinding(clue, "varName1", "");
        SetStringBinding(clue, "varName2", "");
        SetStringBinding(clue, "varType2", "");
        SetIntBinding(clue, "varIntValue2", 0);
        SetBoolBinding(clue, "varIsAdd2", false);
    }

    private static bool SetStringBinding(Component comp, string varKey, string value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
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

            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey)
            {
                continue;
            }

            if (dataProp.propertyType == SerializedPropertyType.String)
            {
                dataProp.stringValue = value ?? "";
            }

            so.ApplyModifiedProperties();
            return true;
        }

        return false;
    }

    private static bool SetIntBinding(Component comp, string varKey, int value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
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

            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey)
            {
                continue;
            }

            dataProp.intValue = value;
            so.ApplyModifiedProperties();
            return true;
        }

        return false;
    }

    private static bool SetBoolBinding(Component comp, string varKey, bool value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
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

            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey)
            {
                continue;
            }

            dataProp.boolValue = value;
            so.ApplyModifiedProperties();
            return true;
        }

        return false;
    }

    private static SerializedProperty GetRefIds(SerializedObject so)
    {
        SerializedProperty refs = so.FindProperty("references");
        return refs?.FindPropertyRelative("RefIds");
    }

    private static void WireInteractorActions(
        Component interactor,
        Component primary,
        Component secondary,
        string primaryMethod,
        string secondaryMethod)
    {
        SerializedObject so = new SerializedObject(interactor);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null)
        {
            return;
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

            SerializedProperty firstButton = buttonData.GetArrayElementAtIndex(0);
            SerializedProperty actions = firstButton.FindPropertyRelative("ButtonActions");
            if (actions == null)
            {
                continue;
            }

            actions.arraySize = secondary != null && !string.IsNullOrEmpty(secondaryMethod) ? 2 : 1;

            SetButtonAction(actions.GetArrayElementAtIndex(0), primary, primaryMethod);
            if (actions.arraySize > 1 && secondary != null)
            {
                SetButtonAction(actions.GetArrayElementAtIndex(1), secondary, secondaryMethod);
            }

            so.ApplyModifiedProperties();
            return;
        }
    }

    private static void SetButtonAction(SerializedProperty action, Component target, string methodName)
    {
        SerializedProperty dataRef = action.FindPropertyRelative("Data");
        if (dataRef != null)
        {
            dataRef.objectReferenceValue = target;
        }

        SerializedProperty method = action.FindPropertyRelative("methodName");
        if (method != null)
        {
            method.stringValue = methodName;
        }
    }

    private static void SetInteractorButtonText(Component interactor, string text)
    {
        SerializedObject so = new SerializedObject(interactor);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null)
        {
            return;
        }

        foreach (SerializedProperty entry in IterateRefIds(refIds))
        {
            SerializedProperty data = entry.FindPropertyRelative("data");
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

            SerializedProperty textProp = buttonData.GetArrayElementAtIndex(0).FindPropertyRelative("Text");
            if (textProp != null)
            {
                textProp.stringValue = text;
                so.ApplyModifiedProperties();
            }

            return;
        }
    }

    private static IEnumerable<SerializedProperty> IterateRefIds(SerializedProperty refIds)
    {
        for (int i = 0; i < refIds.arraySize; i++)
        {
            yield return refIds.GetArrayElementAtIndex(i);
        }
    }
}
