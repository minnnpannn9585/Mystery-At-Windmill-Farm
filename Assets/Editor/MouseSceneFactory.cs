using System;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// 老鼠兄弟墙缝交互点、E39 吆喝区、奶酪散点生成器（空 Transform 落点 + 运行时刷 prefab）。
/// 菜单：EggRescue / Mouse / Spawn Mouse Scene Objects
/// </summary>
public static class MouseSceneFactory
{
    private const string ScenePath = "Assets/Scenes/Mechanics_Code.unity";
    private const string ParentName = "InteractionPoint";
    private const string TemplateName = "E01 · 短木炭";

    private const string DialogueTriggerGuid = "dbdfa9057e4e5a347b4a500a3d30bd57";
    private const string DouyinInteractorGuid = "0a6b2e5dd40d0804b81a27cdfccd5ba5";
    private const string DialogueAreaTriggerGuid = "f7e8d9c0b1a24365869708090a0b1c2d";

    private struct CheeseSpec
    {
        public string Id;
        public Vector3 LocalPos;
    }

    private static readonly CheeseSpec[] CheeseSpecs =
    {
        new CheeseSpec { Id = "C01_001", LocalPos = new Vector3(15.998564f, 8.382972f, -17.426425f) },
        new CheeseSpec { Id = "C01_002", LocalPos = new Vector3(13.780564f, 8.382972f, -13.701425f) },
        new CheeseSpec { Id = "C01_003", LocalPos = new Vector3(10.150564f, 8.704972f, -31.436425f) },
        new CheeseSpec { Id = "C01_004", LocalPos = new Vector3(4.638564f, 8.486972f, -19.483425f) },
        new CheeseSpec { Id = "C01_005", LocalPos = new Vector3(10.978564f, 8.687972f, -15.436425f) },
        new CheeseSpec { Id = "C01_006", LocalPos = new Vector3(4.543564f, 8.486972f, -22.412425f) },
        new CheeseSpec { Id = "C01_007", LocalPos = new Vector3(5.908564f, 8.422972f, -28.808425f) },
        new CheeseSpec { Id = "C01_008", LocalPos = new Vector3(-7.073436f, 5.268972f, -22.347425f) },
        new CheeseSpec { Id = "C01_009", LocalPos = new Vector3(-15.135436f, 5.268972f, -30.552425f) },
        new CheeseSpec { Id = "C01_010", LocalPos = new Vector3(-3.715436f, 6.004972f, -36.338425f) },
        new CheeseSpec { Id = "C01_011", LocalPos = new Vector3(0.453564f, 8.477972f, -34.874425f) },
        new CheeseSpec { Id = "C01_012", LocalPos = new Vector3(-14.235436f, 5.592972f, -36.713425f) },
        new CheeseSpec { Id = "C01_013", LocalPos = new Vector3(-8.752436f, 5.592972f, -43.056425f) },
        new CheeseSpec { Id = "C01_014", LocalPos = new Vector3(-13.324436f, 6.681972f, -44.150425f) },
        new CheeseSpec { Id = "C01_015", LocalPos = new Vector3(-8.870436f, 9.758972f, -44.874425f) },
        new CheeseSpec { Id = "C01_016", LocalPos = new Vector3(-11.554436f, 9.275972f, -42.214425f) },
        new CheeseSpec { Id = "C01_017", LocalPos = new Vector3(-7.542436f, 9.201972f, -39.749425f) },
        new CheeseSpec { Id = "C01_018", LocalPos = new Vector3(-4.012436f, 7.665972f, -44.594425f) },
        new CheeseSpec { Id = "C01_019", LocalPos = new Vector3(-7.559436f, 6.486972f, -35.848425f) },
        new CheeseSpec { Id = "C01_020", LocalPos = new Vector3(-15.588436f, 5.263972f, -32.814425f) },
        new CheeseSpec { Id = "C01_021", LocalPos = new Vector3(-18.512436f, 6.478972f, -39.157425f) },
        new CheeseSpec { Id = "C01_022", LocalPos = new Vector3(-16.071436f, 7.033972f, -35.387425f) },
        new CheeseSpec { Id = "C01_023", LocalPos = new Vector3(-18.504436f, 8.144972f, -45.130425f) },
        new CheeseSpec { Id = "C01_024", LocalPos = new Vector3(-18.256436f, 10.290972f, -37.792425f) },
        new CheeseSpec { Id = "C01_025", LocalPos = new Vector3(-15.930436f, 10.399972f, -33.114425f) },
        new CheeseSpec { Id = "C01_026", LocalPos = new Vector3(-21.591436f, 14.077972f, -35.398425f) },
        new CheeseSpec { Id = "C01_027", LocalPos = new Vector3(-20.372436f, 17.880972f, -34.265425f) },
        new CheeseSpec { Id = "C01_028", LocalPos = new Vector3(6.674564f, 5.329972f, -10.322425f) },
        new CheeseSpec { Id = "C01_029", LocalPos = new Vector3(-11.092436f, 5.329972f, -5.790425f) },
        new CheeseSpec { Id = "C01_030", LocalPos = new Vector3(-8.935436f, 6.887972f, -1.822425f) },
        new CheeseSpec { Id = "C01_031", LocalPos = new Vector3(-21.599436f, 5.384972f, 0.048575f) },
        new CheeseSpec { Id = "C01_032", LocalPos = new Vector3(-29.775436f, 5.449972f, -13.532425f) },
        new CheeseSpec { Id = "C01_033", LocalPos = new Vector3(-13.029436f, 5.239972f, 11.463575f) },
        new CheeseSpec { Id = "C01_034", LocalPos = new Vector3(1.284564f, 5.336972f, 4.957575f) },
        new CheeseSpec { Id = "C01_035", LocalPos = new Vector3(-16.996436f, 5.594972f, -24.225425f) },
        new CheeseSpec { Id = "C01_036", LocalPos = new Vector3(-29.285436f, 5.236972f, 6.217575f) },
        new CheeseSpec { Id = "C01_037", LocalPos = new Vector3(16.255563f, 8.382972f, -29.336425f) },
    };

    [MenuItem("EggRescue/Mouse/Spawn Mouse Scene Objects")]
    [MenuItem("Tools/Egg Rescue/Mouse/Spawn Mouse Scene Objects")]
    public static void SpawnMouseSceneObjects()
    {
        SpawnMouseSceneObjectsInternal(showDialog: true);
    }

    public static void BatchSpawnMouseSceneObjects()
    {
        SpawnMouseSceneObjectsInternal(showDialog: false);
    }

    private static void SpawnMouseSceneObjectsInternal(bool showDialog)
    {
        if (!EnsureSceneOpen())
        {
            return;
        }

        Transform parent = FindChild(null, ParentName);
        if (parent == null)
        {
            Debug.LogError("[MouseSceneFactory] 未找到 InteractionPoint 父节点");
            return;
        }

        GameObject cheesePrefab = CheesePrefabFactory.EnsureCheesePickupPrefab();

        int created = 0;
        created += EnsureWallSeam(parent);
        created += EnsureE39Zone(parent);
        created += EnsureCheeseSpawner(parent, cheesePrefab);
        created += RemoveLegacyCheesePickups(parent);

        EditorSceneManager.MarkSceneDirty(SceneManager.GetActiveScene());
        string msg = $"老鼠场景物体：新建/更新 {created} 项";
        Debug.Log("[MouseSceneFactory] " + msg);
        if (showDialog)
        {
            EditorUtility.DisplayDialog("Mouse Scene Factory", msg, "OK");
        }
    }

    private static int EnsureWallSeam(Transform parent)
    {
        const string goName = "老鼠兄弟 · 墙缝";
        Transform template = parent.Find(TemplateName);
        GameObject go;
        Transform existing = parent.Find(goName);
        if (existing != null)
        {
            go = existing.gameObject;
        }
        else if (template != null)
        {
            go = UnityEngine.Object.Instantiate(template.gameObject, parent);
            go.name = goName;
            go.transform.localPosition = new Vector3(-28f, 6f, 12f);
        }
        else
        {
            go = new GameObject(goName);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = new Vector3(-28f, 6f, 12f);
        }

        EnsureBoxCollider(go, new Vector3(1.2f, 1.5f, 0.8f), false);
        RemoveClueBindings(go);
        RemoveDouyinScript(go, "Assets/luaScripts/MouseBrotherController.lua");

        Component dialogue = FindDouyinScriptByGuid(go, DialogueTriggerGuid);
        if (dialogue == null)
        {
            dialogue = EnsureDouyinScript(go, "Assets/luaScripts/DialogueTrigger.lua");
        }

        if (dialogue != null)
        {
            InteractionPointFactoryHelpers.SetStringBinding(dialogue, "npcname", "老鼠兄弟");
            InteractionPointFactoryHelpers.SetIntBinding(dialogue, "ID", 0);
        }

        Component interactor = FindDouyinScriptByGuid(go, DouyinInteractorGuid);
        if (interactor != null && dialogue != null)
        {
            InteractionPointFactoryHelpers.WireInteractorActions(interactor, dialogue, null, "StartDialogue", null);
            InteractionPointFactoryHelpers.SetInteractorButtonText(interactor, "墙缝黑市");
        }

        return dialogue != null ? 1 : 0;
    }

    private static int EnsureE39Zone(Transform parent)
    {
        const string goName = "E39 · 墙缝外围吆喝区";
        GameObject go = FindOrCreate(parent, goName, new Vector3(-26f, 4f, 8f));
        BoxCollider box = EnsureBoxCollider(go, new Vector3(14f, 6f, 14f), true);

        Component area = EnsureDouyinScript(go, "Assets/luaScripts/DialogueAreaTrigger.lua");
        if (area != null)
        {
            InteractionPointFactoryHelpers.SetStringBinding(area, "npcName", "老鼠兄弟");
            InteractionPointFactoryHelpers.SetIntBinding(area, "startNodeId", 1);
            InteractionPointFactoryHelpers.SetStringBinding(area, "blockVarName", "Mouse_AreaCalloutShown");
            InteractionPointFactoryHelpers.SetBoolBinding(area, "blockWhenTrue", true);
            InteractionPointFactoryHelpers.SetBoolBinding(area, "disableColliderAfterFire", true);
        }

        return area != null ? 1 : 0;
    }

    private static int EnsureCheeseSpawner(Transform parent, GameObject cheesePrefab)
    {
        const string spawnerName = "奶酪散点";
        GameObject spawnerGo = FindOrCreate(parent, spawnerName, Vector3.zero);
        Transform spawner = spawnerGo.transform;

        Component spawnerScript = EnsureDouyinScript(spawnerGo, "Assets/luaScripts/CheeseSpawner.lua");
        if (spawnerScript != null && cheesePrefab != null)
        {
            InteractionPointFactoryHelpers.SetObjectBinding(spawnerScript, "cheesePrefab", cheesePrefab);
        }

        EnsureDouyinScript(spawnerGo, "Assets/luaScripts/MouseBrotherController.lua");
        EnsureDouyinScript(spawnerGo, "Assets/luaScripts/CheeseRefreshManager.lua");

        int count = spawnerScript != null ? 1 : 0;
        foreach (CheeseSpec spec in CheeseSpecs)
        {
            if (spawner.Find(spec.Id) != null)
            {
                continue;
            }

            GameObject marker = new GameObject(spec.Id);
            marker.transform.SetParent(spawner, false);
            marker.transform.localPosition = spec.LocalPos;
            marker.transform.localRotation = Quaternion.identity;
            marker.transform.localScale = Vector3.one;
            count++;
        }

        return count;
    }

    private static int RemoveLegacyCheesePickups(Transform parent)
    {
        int removed = 0;
        for (int i = parent.childCount - 1; i >= 0; i--)
        {
            Transform child = parent.GetChild(i);
            if (child.name.StartsWith("奶酪碎 · ", StringComparison.Ordinal))
            {
                UnityEngine.Object.DestroyImmediate(child.gameObject);
                removed++;
            }
        }

        return removed;
    }

    private static void RemoveDouyinScript(GameObject go, string assetPath)
    {
        string guid = AssetDatabase.AssetPathToGUID(assetPath);
        if (string.IsNullOrEmpty(guid))
        {
            return;
        }

        Component comp = FindDouyinScriptByGuid(go, guid);
        if (comp != null)
        {
            UnityEngine.Object.DestroyImmediate(comp);
        }
    }

    private static void RemoveClueBindings(GameObject go)
    {
        foreach (Component comp in go.GetComponents<Component>())
        {
            if (comp == null)
            {
                continue;
            }

            string path = AssetDatabase.GetAssetPath(GetScriptAsset(comp));
            string guid = string.IsNullOrEmpty(path) ? "" : AssetDatabase.AssetPathToGUID(path);
            if (guid == "2090c1a586d0445408748c8c4e87103f")
            {
                UnityEngine.Object.DestroyImmediate(comp);
            }
        }
    }

    private static UnityEngine.Object GetScriptAsset(Component comp)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty scriptAsset = so.FindProperty("ScriptAsset");
        return scriptAsset != null ? scriptAsset.objectReferenceValue : null;
    }

    private static GameObject FindOrCreate(Transform parent, string name, Vector3 localPos)
    {
        Transform existing = parent.Find(name);
        if (existing != null)
        {
            return existing.gameObject;
        }

        GameObject go = new GameObject(name);
        go.transform.SetParent(parent, false);
        go.transform.localPosition = localPos;
        go.transform.localRotation = Quaternion.identity;
        go.transform.localScale = Vector3.one;
        return go;
    }

    private static BoxCollider EnsureBoxCollider(GameObject go, Vector3 size, bool isTrigger)
    {
        BoxCollider box = go.GetComponent<BoxCollider>();
        if (box == null)
        {
            box = go.AddComponent<BoxCollider>();
        }

        box.isTrigger = isTrigger;
        box.size = size;
        box.center = new Vector3(0f, size.y * 0.5f, 0f);
        return box;
    }

    private static Component EnsureDouyinScript(GameObject go, string assetPath)
    {
        UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
        if (asset == null)
        {
            Debug.LogError("[MouseSceneFactory] 未找到脚本: " + assetPath);
            return null;
        }

        string guid = AssetDatabase.AssetPathToGUID(assetPath);
        Component existing = FindDouyinScriptByGuid(go, guid);
        if (existing != null)
        {
            return existing;
        }

        Type douyinScriptType = FindDouyinScriptType();
        if (douyinScriptType == null)
        {
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

            UnityEngine.Object asset = GetScriptAsset(comp);
            if (asset == null)
            {
                continue;
            }

            string path = AssetDatabase.GetAssetPath(asset);
            if (AssetDatabase.AssetPathToGUID(path) == scriptGuid)
            {
                return comp;
            }
        }

        return null;
    }

    private static Transform FindChild(Transform parent, string name)
    {
        if (parent == null)
        {
            GameObject root = GameObject.Find(name);
            return root != null ? root.transform : null;
        }

        return parent.Find(name);
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

/// <summary>DouyinScript Inspector 绑定辅助（与 InteractionPointFactory 同构）。</summary>
public static class InteractionPointFactoryHelpers
{
    public static void SetStringBinding(Component comp, string varKey, string value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey) continue;
            dataProp.stringValue = value;
            so.ApplyModifiedProperties();
            return;
        }
    }

    public static void SetIntBinding(Component comp, string varKey, int value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey) continue;
            dataProp.intValue = value;
            so.ApplyModifiedProperties();
            return;
        }
    }

    public static void SetBoolBinding(Component comp, string varKey, bool value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey) continue;
            dataProp.boolValue = value;
            so.ApplyModifiedProperties();
            return;
        }
    }

    public static void SetObjectBinding(Component comp, string varKey, UnityEngine.Object value)
    {
        SerializedObject so = new SerializedObject(comp);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varNameProp = data.FindPropertyRelative("varName");
            SerializedProperty dataProp = data.FindPropertyRelative("Data");
            if (varNameProp == null || dataProp == null || varNameProp.stringValue != varKey) continue;
            dataProp.objectReferenceValue = value;
            so.ApplyModifiedProperties();
            return;
        }
    }

    public static void WireInteractorActions(
        Component interactor, Component primary, Component secondary,
        string primaryMethod, string secondaryMethod)
    {
        SerializedObject so = new SerializedObject(interactor);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varName = data.FindPropertyRelative("varName");
            if (varName == null || varName.stringValue != "ButtonConfigs") continue;
            SerializedProperty buttonData = data.FindPropertyRelative("Data");
            if (buttonData == null || !buttonData.isArray || buttonData.arraySize == 0) continue;
            SerializedProperty firstButton = buttonData.GetArrayElementAtIndex(0);
            SerializedProperty actions = firstButton.FindPropertyRelative("ButtonActions");
            if (actions == null) continue;
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
        if (dataRef != null) dataRef.objectReferenceValue = target;
        SerializedProperty method = action.FindPropertyRelative("methodName");
        if (method != null) method.stringValue = methodName;
    }

    public static void SetInteractorButtonText(Component interactor, string text)
    {
        SerializedObject so = new SerializedObject(interactor);
        SerializedProperty refIds = GetRefIds(so);
        if (refIds == null) return;
        for (int i = 0; i < refIds.arraySize; i++)
        {
            SerializedProperty data = refIds.GetArrayElementAtIndex(i).FindPropertyRelative("data");
            if (data == null) continue;
            SerializedProperty varName = data.FindPropertyRelative("varName");
            if (varName == null || varName.stringValue != "ButtonConfigs") continue;
            SerializedProperty buttonData = data.FindPropertyRelative("Data");
            if (buttonData == null || !buttonData.isArray || buttonData.arraySize == 0) continue;
            SerializedProperty textProp = buttonData.GetArrayElementAtIndex(0).FindPropertyRelative("Text");
            if (textProp != null)
            {
                textProp.stringValue = text;
                so.ApplyModifiedProperties();
            }
            return;
        }
    }

    private static SerializedProperty GetRefIds(SerializedObject so)
    {
        return so.FindProperty("references")?.FindPropertyRelative("RefIds");
    }
}
