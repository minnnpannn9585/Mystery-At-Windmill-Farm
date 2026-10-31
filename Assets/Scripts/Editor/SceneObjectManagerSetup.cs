// 编辑器菜单：一键创建 SceneObjectManager 并配置风车旋转。
//
// 菜单「Tools/Scene/创建场景调度管理器」会在当前场景里：
//   1. 创建（或复用）一个名为 SceneObjectManager 的空物体，挂 SceneObjectManager。
//   2. 在其下创建子物体「Windmill Rotator」，挂 RotateObject，并自动查找场景里的
//      SM_WindMillCore 节点填入 target。
//
// 这样不用手动拖拽，点一下菜单即可让风车转起来（默认绕本地 Z 轴 30°/秒）。
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using WindmillFarm.Scheduling;

namespace WindmillFarm.EditorTools
{
    public static class SceneObjectManagerSetup
    {
        const string ManagerName = "SceneObjectManager";
        const string WindmillTargetName = "SM_WindMillCore (1)";

        [MenuItem("Tools/Scene/创建场景调度管理器", false, 60)]
        public static void CreateSceneObjectManager()
        {
            // 1. 创建 / 复用管理器物体
            var managerGo = GameObject.Find(ManagerName);
            if (managerGo == null)
            {
                managerGo = new GameObject(ManagerName);
                Undo.RegisterCreatedObjectUndo(managerGo, "Create SceneObjectManager");
            }

            var manager = managerGo.GetComponent<SceneObjectManager>();
            if (manager == null)
                manager = Undo.AddComponent<SceneObjectManager>(managerGo);

            // 2. 创建风车旋转子物体
            const string rotatorName = "Windmill Rotator";
            Transform rotator = managerGo.transform.Find(rotatorName);
            if (rotator == null)
            {
                var rotatorGo = new GameObject(rotatorName);
                rotatorGo.transform.SetParent(managerGo.transform, false);
                Undo.RegisterCreatedObjectUndo(rotatorGo, "Create Windmill Rotator");
                rotator = rotatorGo.transform;
            }

            var rotate = rotator.GetComponent<RotateObject>();
            if (rotate == null)
                rotate = Undo.AddComponent<RotateObject>(rotator.gameObject);

            // 3. 自动查找风车核心节点填入 target
            var target = FindWindmillCore();
            if (target != null)
            {
                var so = new SerializedObject(rotate);
                so.FindProperty("target").objectReferenceValue = target;
                so.ApplyModifiedPropertiesWithoutUndo();
            }

            // 选中管理器，方便用户在 Inspector 里看到结果
            Selection.activeGameObject = managerGo;
            EditorSceneManager.MarkSceneDirty(managerGo.scene);

            Debug.Log($"[SceneObjectManager] 已创建管理器与风车旋转器" +
                      (target != null ? $"，目标风车核心：{target.name}" : "（未找到 SM_WindMillCore，请手动指定 target）"));
        }

        static Transform FindWindmillCore()
        {
            // 场景里风车核心是 PrefabInstance 名 SM_WindMillCore (1)，也可能有 windmillcore。
            foreach (var go in Object.FindObjectsOfType<Transform>(true))
            {
                if (go.name == WindmillTargetName || go.name == "windmillcore")
                    return go;
            }
            return null;
        }
    }
}
