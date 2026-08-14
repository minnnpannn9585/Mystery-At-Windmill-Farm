using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Formats.Fbx.Exporter;
#endif

public enum ReplaceOriginalMode
{
    None,
    DisableOriginal,
    DeleteOriginal
}

public class MergeModelToFbxExporter : MonoBehaviour
{
    [Header("要合并的目标根物体")]
    public GameObject targetRoot;

    [Header("FBX保存文件夹，必须在Assets目录下")]
    public string saveFolder = "Assets/ExportedFBX";

    [Header("是否包含未激活物体")]
    public bool includeInactive = true;

    [Header("是否包含关闭的Renderer")]
    public bool includeDisabledRenderers = true;

    [Header("如果填写，则所有模型强制使用这个材质；如果不填，则自动保留原来的多个材质")]
    public Material overrideMaterial;

    [Header("导出后是否自动替换场景中的原模型")]
    public ReplaceOriginalMode replaceOriginalMode = ReplaceOriginalMode.DisableOriginal;

    [Header("是否保留临时合并物体")]
    public bool keepGeneratedObjectInScene = false;

    [Header("替换后是否自动选中新模型")]
    public bool selectNewObject = true;

    [Header("是否重新计算法线。一般建议关闭，避免破坏原模型法线")]
    public bool recalculateNormals = false;

#if UNITY_EDITOR
    private List<Material> lastUsedMaterials = new List<Material>();
#endif

    [ContextMenu("Merge And Export FBX")]
    public void MergeAndExportToFbx()
    {
#if UNITY_EDITOR
        if (targetRoot == null)
        {
            Debug.LogError("没有指定 targetRoot，请先拖入一个要合并的 GameObject。", this);
            return;
        }

        string folder = NormalizeFolderPath(saveFolder);

        if (!folder.StartsWith("Assets/"))
        {
            Debug.LogError("saveFolder 必须在 Assets 目录下，例如：Assets/ExportedFBX", this);
            return;
        }

        EnsureFolderExists(folder);

        lastUsedMaterials.Clear();

        GameObject mergedObject = CreateMergedObject(targetRoot);

        if (mergedObject == null)
        {
            Debug.LogError("合并失败：目标物体下面没有找到可合并的 Mesh。", this);
            return;
        }

        string fileName = SanitizeFileName(targetRoot.name);
        string fbxPath = GetUniqueFbxPath(folder, fileName);

        MergedFbxImportMaterialBlocker.SetTargetPath(fbxPath);

        try
        {
            ModelExporter.ExportObject(fbxPath, mergedObject);

            AssetDatabase.ImportAsset(
                fbxPath,
                ImportAssetOptions.ForceSynchronousImport | ImportAssetOptions.ForceUpdate
            );

            DisableMaterialImportForFbx(fbxPath);

            AssetDatabase.Refresh();

            Debug.Log($"模型合并并导出成功：{fbxPath}", this);

            if (replaceOriginalMode != ReplaceOriginalMode.None)
            {
                ReplaceOriginalWithExportedFbx(fbxPath);
            }

            if (keepGeneratedObjectInScene)
            {
                ApplyMaterialsToAllRenderers(mergedObject, lastUsedMaterials);
            }
            else
            {
                DestroyImmediate(mergedObject);
            }
        }
        finally
        {
            MergedFbxImportMaterialBlocker.ClearTargetPath();
        }
#else
        Debug.LogError("FBX导出只能在Unity Editor里执行，不能在运行后的游戏中执行。");
#endif
    }

#if UNITY_EDITOR

    private class MaterialCombineGroup
    {
        public Material material;
        public List<CombineInstance> combineInstances = new List<CombineInstance>();

        public MaterialCombineGroup(Material material)
        {
            this.material = material;
        }
    }

    private GameObject CreateMergedObject(GameObject root)
    {
        List<MaterialCombineGroup> materialGroups = new List<MaterialCombineGroup>();

        List<Mesh> tempBakedMeshes = new List<Mesh>();
        List<Mesh> tempGroupedMeshes = new List<Mesh>();

        Matrix4x4 rootWorldToLocal = root.transform.worldToLocalMatrix;

        MeshRenderer[] meshRenderers = root.GetComponentsInChildren<MeshRenderer>(includeInactive);

        foreach (MeshRenderer meshRenderer in meshRenderers)
        {
            if (meshRenderer == null)
                continue;

            if (!includeDisabledRenderers && !meshRenderer.enabled)
                continue;

            MeshFilter meshFilter = meshRenderer.GetComponent<MeshFilter>();

            if (meshFilter == null || meshFilter.sharedMesh == null)
                continue;

            Mesh sourceMesh = meshFilter.sharedMesh;
            Material[] sourceMaterials = meshRenderer.sharedMaterials;

            Matrix4x4 matrix =
                rootWorldToLocal * meshFilter.transform.localToWorldMatrix;

            AddMeshSubMeshesByMaterial(
                sourceMesh,
                sourceMaterials,
                matrix,
                materialGroups
            );
        }

        SkinnedMeshRenderer[] skinnedMeshRenderers =
            root.GetComponentsInChildren<SkinnedMeshRenderer>(includeInactive);

        foreach (SkinnedMeshRenderer skinnedRenderer in skinnedMeshRenderers)
        {
            if (skinnedRenderer == null)
                continue;

            if (!includeDisabledRenderers && !skinnedRenderer.enabled)
                continue;

            Mesh bakedMesh = new Mesh();
            bakedMesh.name = skinnedRenderer.name + "_BakedMesh";
            bakedMesh.indexFormat = IndexFormat.UInt32;

            skinnedRenderer.BakeMesh(bakedMesh);

            if (bakedMesh.vertexCount == 0)
            {
                DestroyImmediate(bakedMesh);
                continue;
            }

            tempBakedMeshes.Add(bakedMesh);

            Material[] sourceMaterials = skinnedRenderer.sharedMaterials;

            Matrix4x4 matrix =
                rootWorldToLocal * skinnedRenderer.transform.localToWorldMatrix;

            AddMeshSubMeshesByMaterial(
                bakedMesh,
                sourceMaterials,
                matrix,
                materialGroups
            );
        }

        if (materialGroups.Count == 0)
        {
            DestroyTempMeshes(tempBakedMeshes);
            return null;
        }

        List<CombineInstance> finalCombineInstances = new List<CombineInstance>();
        lastUsedMaterials.Clear();

        for (int i = 0; i < materialGroups.Count; i++)
        {
            MaterialCombineGroup group = materialGroups[i];

            if (group.combineInstances.Count == 0)
                continue;

            Mesh groupedMesh = new Mesh();
            groupedMesh.name = "Merged_Group_" + i;
            groupedMesh.indexFormat = IndexFormat.UInt32;

            // 这里先把同一个材质的所有SubMesh压成一个SubMesh。
            groupedMesh.CombineMeshes(
                group.combineInstances.ToArray(),
                true,
                true
            );

            groupedMesh.RecalculateBounds();

            if (recalculateNormals)
            {
                groupedMesh.RecalculateNormals();
            }

            tempGroupedMeshes.Add(groupedMesh);

            CombineInstance finalCombine = new CombineInstance();
            finalCombine.mesh = groupedMesh;
            finalCombine.subMeshIndex = 0;
            finalCombine.transform = Matrix4x4.identity;

            finalCombineInstances.Add(finalCombine);

            // 材质顺序必须和最终SubMesh顺序一致。
            lastUsedMaterials.Add(group.material);
        }

        if (finalCombineInstances.Count == 0)
        {
            DestroyTempMeshes(tempBakedMeshes);
            DestroyTempMeshes(tempGroupedMeshes);
            return null;
        }

        Mesh mergedMesh = new Mesh();
        mergedMesh.name = root.name + "_MergedMesh";
        mergedMesh.indexFormat = IndexFormat.UInt32;

        // 重点：
        // mergeSubMeshes = false
        // 这样不同材质组会保留为不同SubMesh。
        mergedMesh.CombineMeshes(
            finalCombineInstances.ToArray(),
            false,
            false
        );

        mergedMesh.RecalculateBounds();

        if (recalculateNormals)
        {
            mergedMesh.RecalculateNormals();
        }

        GameObject mergedObject = new GameObject(root.name + "_Merged");

        mergedObject.transform.position = root.transform.position;
        mergedObject.transform.rotation = root.transform.rotation;
        mergedObject.transform.localScale = root.transform.lossyScale;

        MeshFilter newMeshFilter = mergedObject.AddComponent<MeshFilter>();
        newMeshFilter.sharedMesh = mergedMesh;

        MeshRenderer newMeshRenderer = mergedObject.AddComponent<MeshRenderer>();

        // 这里先挂上原始材质数组，保证导出FBX时SubMesh结构正确。
        // 导入FBX时会禁止生成新材质，替换到场景后再重新赋同一组原材质。
        newMeshRenderer.sharedMaterials = lastUsedMaterials.ToArray();

        DestroyTempMeshes(tempBakedMeshes);
        DestroyTempMeshes(tempGroupedMeshes);

        return mergedObject;
    }

    private void AddMeshSubMeshesByMaterial(
        Mesh sourceMesh,
        Material[] sourceMaterials,
        Matrix4x4 matrix,
        List<MaterialCombineGroup> materialGroups)
    {
        if (sourceMesh == null)
            return;

        int subMeshCount = Mathf.Max(1, sourceMesh.subMeshCount);

        for (int subMeshIndex = 0; subMeshIndex < subMeshCount; subMeshIndex++)
        {
            Material material = GetMaterialForSubMesh(sourceMaterials, subMeshIndex);

            MaterialCombineGroup group = GetOrCreateMaterialGroup(materialGroups, material);

            CombineInstance combine = new CombineInstance();
            combine.mesh = sourceMesh;
            combine.subMeshIndex = subMeshIndex;
            combine.transform = matrix;

            group.combineInstances.Add(combine);
        }
    }

    private Material GetMaterialForSubMesh(Material[] sourceMaterials, int subMeshIndex)
    {
        if (overrideMaterial != null)
        {
            return overrideMaterial;
        }

        if (sourceMaterials == null || sourceMaterials.Length == 0)
        {
            return null;
        }

        if (subMeshIndex >= 0 && subMeshIndex < sourceMaterials.Length)
        {
            return sourceMaterials[subMeshIndex];
        }

        // 如果SubMesh数量比材质槽多，Unity一般会用最后一个材质兜底。
        return sourceMaterials[sourceMaterials.Length - 1];
    }

    private MaterialCombineGroup GetOrCreateMaterialGroup(
        List<MaterialCombineGroup> materialGroups,
        Material material)
    {
        for (int i = 0; i < materialGroups.Count; i++)
        {
            if (materialGroups[i].material == material)
            {
                return materialGroups[i];
            }
        }

        MaterialCombineGroup newGroup = new MaterialCombineGroup(material);
        materialGroups.Add(newGroup);

        return newGroup;
    }

    private void ReplaceOriginalWithExportedFbx(string fbxPath)
    {
        if (targetRoot == null)
        {
            Debug.LogError("替换失败：targetRoot 为空。", this);
            return;
        }

        if (!fbxPath.StartsWith("Assets/"))
        {
            Debug.LogError("替换失败：FBX必须保存在Assets目录下。", this);
            return;
        }

        GameObject fbxAsset = AssetDatabase.LoadAssetAtPath<GameObject>(fbxPath);

        if (fbxAsset == null)
        {
            Debug.LogError($"替换失败：无法从路径加载导出的 FBX：{fbxPath}", this);
            return;
        }

        GameObject originalObject = targetRoot;

        Transform originalParent = originalObject.transform.parent;
        int originalSiblingIndex = originalObject.transform.GetSiblingIndex();

        Vector3 originalLocalPosition = originalObject.transform.localPosition;
        Quaternion originalLocalRotation = originalObject.transform.localRotation;
        Vector3 originalLocalScale = originalObject.transform.localScale;

        string originalName = originalObject.name;
        int originalLayer = originalObject.layer;
        string originalTag = originalObject.tag;
        bool originalActiveState = originalObject.activeSelf;

        GameObject newObject = PrefabUtility.InstantiatePrefab(fbxAsset) as GameObject;

        if (newObject == null)
        {
            Debug.LogError("替换失败：实例化导出的 FBX 失败。", this);
            return;
        }

        Undo.RegisterCreatedObjectUndo(newObject, "Create Merged FBX Replacement");

        newObject.name = originalName;

        newObject.transform.SetParent(originalParent, false);
        newObject.transform.SetSiblingIndex(originalSiblingIndex);

        newObject.transform.localPosition = originalLocalPosition;
        newObject.transform.localRotation = originalLocalRotation;
        newObject.transform.localScale = originalLocalScale;

        newObject.SetActive(originalActiveState);

        SetLayerRecursively(newObject, originalLayer);

        try
        {
            newObject.tag = originalTag;
        }
        catch
        {
            Debug.LogWarning($"新模型无法设置 Tag：{originalTag}。可能是该 Tag 不存在。", this);
        }

        // 重点：
        // FBX导入后，不使用FBX自带材质，而是把原模型收集到的材质数组重新赋回去。
        ApplyMaterialsToAllRenderers(newObject, lastUsedMaterials);

        if (replaceOriginalMode == ReplaceOriginalMode.DisableOriginal)
        {
            originalObject.name = originalName + "_Original";
            originalObject.SetActive(false);
        }
        else if (replaceOriginalMode == ReplaceOriginalMode.DeleteOriginal)
        {
            Undo.DestroyObjectImmediate(originalObject);
        }

        targetRoot = newObject;

        if (selectNewObject)
        {
            Selection.activeGameObject = newObject;
        }

        Debug.Log($"已自动替换场景模型：{originalName}", this);
    }

    private void ApplyMaterialsToAllRenderers(GameObject obj, List<Material> materials)
    {
        if (obj == null || materials == null || materials.Count == 0)
            return;

        Renderer[] renderers = obj.GetComponentsInChildren<Renderer>(true);

        foreach (Renderer renderer in renderers)
        {
            if (renderer == null)
                continue;

            renderer.sharedMaterials = materials.ToArray();
        }
    }

    private void DisableMaterialImportForFbx(string fbxPath)
    {
        ModelImporter modelImporter = AssetImporter.GetAtPath(fbxPath) as ModelImporter;

        if (modelImporter == null)
            return;

        modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;

        modelImporter.SaveAndReimport();
    }

    private void SetLayerRecursively(GameObject obj, int layer)
    {
        obj.layer = layer;

        foreach (Transform child in obj.transform)
        {
            SetLayerRecursively(child.gameObject, layer);
        }
    }

    private string NormalizeFolderPath(string folder)
    {
        if (string.IsNullOrWhiteSpace(folder))
            folder = "Assets/ExportedFBX";

        folder = folder.Replace("\\", "/");

        return folder;
    }

    private void EnsureFolderExists(string folder)
    {
        if (!Directory.Exists(folder))
        {
            Directory.CreateDirectory(folder);
        }
    }

    private string GetUniqueFbxPath(string folder, string baseFileName)
    {
        string path = Path.Combine(folder, baseFileName + ".fbx").Replace("\\", "/");

        if (!File.Exists(path))
            return path;

        int index = 1;

        while (true)
        {
            string newPath = Path.Combine(folder, baseFileName + index + ".fbx").Replace("\\", "/");

            if (!File.Exists(newPath))
                return newPath;

            index++;
        }
    }

    private string SanitizeFileName(string fileName)
    {
        foreach (char invalidChar in Path.GetInvalidFileNameChars())
        {
            fileName = fileName.Replace(invalidChar, '_');
        }

        return fileName;
    }

    private void DestroyTempMeshes(List<Mesh> meshes)
    {
        if (meshes == null)
            return;

        foreach (Mesh mesh in meshes)
        {
            if (mesh != null)
            {
                DestroyImmediate(mesh);
            }
        }
    }

#endif
}

#if UNITY_EDITOR

public class MergedFbxImportMaterialBlocker : AssetPostprocessor
{
    private const string TargetPathKey = "MergeModelToFbxExporter_TargetFbxPath";

    public static void SetTargetPath(string path)
    {
        EditorPrefs.SetString(TargetPathKey, path);
    }

    public static void ClearTargetPath()
    {
        EditorPrefs.DeleteKey(TargetPathKey);
    }

    private void OnPreprocessModel()
    {
        string targetPath = EditorPrefs.GetString(TargetPathKey, "");

        if (string.IsNullOrEmpty(targetPath))
            return;

        if (assetPath != targetPath)
            return;

        ModelImporter modelImporter = assetImporter as ModelImporter;

        if (modelImporter == null)
            return;

        // 禁止这个FBX导入材质，避免每次生成新的材质。
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
    }
}

[CustomEditor(typeof(MergeModelToFbxExporter))]
public class MergeModelToFbxExporterEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(10);

        MergeModelToFbxExporter exporter = (MergeModelToFbxExporter)target;

        GUI.enabled = exporter.targetRoot != null;

        if (GUILayout.Button("Merge And Export FBX", GUILayout.Height(36)))
        {
            exporter.MergeAndExportToFbx();
        }

        GUI.enabled = true;
    }
}

#endif