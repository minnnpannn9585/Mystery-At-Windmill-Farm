using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

public class EditorMeshCountChecker : MonoBehaviour
{
    [Header("要检查的根物体。如果不填，就默认检查当前选中的物体")]
    public GameObject targetRoot;

    [Header("是否包含未激活物体")]
    public bool includeInactive = true;

    [Header("是否包含关闭的 Renderer")]
    public bool includeDisabledRenderers = true;

    [ContextMenu("Count Meshes In Editor")]
    public void CountMeshesInEditor()
    {
#if UNITY_EDITOR
        GameObject root = targetRoot;

        if (root == null)
        {
            root = Selection.activeGameObject;
        }

        if (root == null)
        {
            EditorUtility.DisplayDialog(
                "统计失败",
                "请先在 Target Root 里拖入一个 GameObject，或者在 Hierarchy 里选中一个 GameObject。",
                "OK"
            );

            Debug.LogError("请先指定 targetRoot，或者在 Hierarchy 里选中一个 GameObject。", this);
            return;
        }

        int staticMeshObjectCount = 0;
        int skinnedMeshObjectCount = 0;

        int validStaticMeshCount = 0;
        int validSkinnedMeshCount = 0;

        long totalVertexCount = 0;
        long totalTriangleCount = 0;

        MeshFilter[] meshFilters = root.GetComponentsInChildren<MeshFilter>(includeInactive);

        foreach (MeshFilter meshFilter in meshFilters)
        {
            if (meshFilter == null)
                continue;

            MeshRenderer meshRenderer = meshFilter.GetComponent<MeshRenderer>();

            if (meshRenderer == null)
                continue;

            if (!includeDisabledRenderers && !meshRenderer.enabled)
                continue;

            staticMeshObjectCount++;

            Mesh mesh = meshFilter.sharedMesh;

            if (mesh == null)
                continue;

            validStaticMeshCount++;

            totalVertexCount += mesh.vertexCount;
            totalTriangleCount += GetTriangleCount(mesh);
        }

        SkinnedMeshRenderer[] skinnedMeshRenderers =
            root.GetComponentsInChildren<SkinnedMeshRenderer>(includeInactive);

        foreach (SkinnedMeshRenderer skinnedRenderer in skinnedMeshRenderers)
        {
            if (skinnedRenderer == null)
                continue;

            if (!includeDisabledRenderers && !skinnedRenderer.enabled)
                continue;

            skinnedMeshObjectCount++;

            Mesh mesh = skinnedRenderer.sharedMesh;

            if (mesh == null)
                continue;

            validSkinnedMeshCount++;

            totalVertexCount += mesh.vertexCount;
            totalTriangleCount += GetTriangleCount(mesh);
        }

        string result =
            $"检查对象：{root.name}\n\n" +
            $"Static Mesh Object 数量：{staticMeshObjectCount}\n" +
            $"有效 Static Mesh 数量：{validStaticMeshCount}\n\n" +
            $"Skinned Mesh Object 数量：{skinnedMeshObjectCount}\n" +
            $"有效 Skinned Mesh 数量：{validSkinnedMeshCount}\n\n" +
            $"总 Mesh 数量：{validStaticMeshCount + validSkinnedMeshCount}\n" +
            $"总顶点数：{totalVertexCount}\n" +
            $"总三角面数：{totalTriangleCount}";

        Debug.Log(result, root);

        EditorUtility.DisplayDialog(
            "Mesh 统计结果",
            result,
            "OK"
        );
#else
        Debug.LogError("这个方法只能在 Unity Editor 里运行。");
#endif
    }

    private long GetTriangleCount(Mesh mesh)
    {
        if (mesh == null)
            return 0;

        long triangleCount = 0;

        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            triangleCount += mesh.GetIndexCount(i) / 3;
        }

        return triangleCount;
    }
}

#if UNITY_EDITOR

[CustomEditor(typeof(EditorMeshCountChecker))]
public class EditorMeshCountCheckerInspector : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(10);

        EditorMeshCountChecker checker = (EditorMeshCountChecker)target;

        if (GUILayout.Button("Count Meshes In Editor", GUILayout.Height(34)))
        {
            checker.CountMeshesInEditor();
        }

        EditorGUILayout.HelpBox(
            "如果 Target Root 不填，会默认统计 Hierarchy 当前选中的 GameObject。",
            MessageType.Info
        );
    }
}

#endif