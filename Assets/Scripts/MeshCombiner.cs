using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Rendering;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Formats.Fbx.Exporter;
#endif

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class MeshCombiner : MonoBehaviour
{
    [Header("FBX export folder under Assets")]
    public string saveFolder = "Assets/ExportedFBX";

    [Header("Export merged result as FBX after combine")]
    public bool exportCombinedResultAsFbx = true;

    [Header("Select the exported FBX asset after export")]
    public bool selectExportedAsset = true;

    [ContextMenu("Combine Child Meshes Permanently")]
    public void CombineChildMeshesPermanently()
    {
        MeshFilter parentMeshFilter = GetComponent<MeshFilter>();
        MeshRenderer parentMeshRenderer = GetComponent<MeshRenderer>();

        MeshFilter[] allMeshFilters = GetComponentsInChildren<MeshFilter>(true);
        List<CombineInstance> combineInstances = new List<CombineInstance>();
        Material firstMaterial = null;

        for (int i = 0; i < allMeshFilters.Length; i++)
        {
            MeshFilter meshFilter = allMeshFilters[i];

            if (meshFilter == parentMeshFilter)
            {
                continue;
            }

            if (meshFilter.sharedMesh == null)
            {
                continue;
            }

            MeshRenderer childRenderer = meshFilter.GetComponent<MeshRenderer>();
            if (childRenderer == null)
            {
                continue;
            }

            if (firstMaterial == null)
            {
                firstMaterial = childRenderer.sharedMaterial;
            }

            CombineInstance combineInstance = new CombineInstance
            {
                mesh = meshFilter.sharedMesh,
                subMeshIndex = 0,
                transform = transform.worldToLocalMatrix * meshFilter.transform.localToWorldMatrix
            };

            combineInstances.Add(combineInstance);
        }

        if (combineInstances.Count == 0)
        {
            Debug.LogWarning("No child meshes found to combine.", this);
            return;
        }

        Mesh combinedMesh = new Mesh
        {
            name = gameObject.name + "_CombinedMesh",
            indexFormat = IndexFormat.UInt32
        };

        combinedMesh.CombineMeshes(combineInstances.ToArray(), true, true);
        combinedMesh.RecalculateBounds();

        parentMeshFilter.sharedMesh = combinedMesh;

        if (firstMaterial != null)
        {
            parentMeshRenderer.sharedMaterial = firstMaterial;
        }

        List<GameObject> childrenToDelete = new List<GameObject>();
        for (int i = transform.childCount - 1; i >= 0; i--)
        {
            childrenToDelete.Add(transform.GetChild(i).gameObject);
        }

        for (int i = 0; i < childrenToDelete.Count; i++)
        {
#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                DestroyImmediate(childrenToDelete[i]);
            }
            else
            {
                Destroy(childrenToDelete[i]);
            }
#else
            Destroy(childrenToDelete[i]);
#endif
        }

#if UNITY_EDITOR
        if (exportCombinedResultAsFbx)
        {
            ExportCombinedResultToFbx();
        }
#endif
    }

#if UNITY_EDITOR
    [ContextMenu("Export Combined Result To FBX")]
    public void ExportCombinedResultToFbx()
    {
        MeshFilter parentMeshFilter = GetComponent<MeshFilter>();

        if (parentMeshFilter.sharedMesh == null)
        {
            Debug.LogError("Cannot export FBX because the combined mesh is empty.", this);
            return;
        }

        string folder = NormalizeFolderPath(saveFolder);
        if (!folder.StartsWith("Assets/"))
        {
            Debug.LogError("saveFolder must be under Assets, for example: Assets/ExportedFBX", this);
            return;
        }

        EnsureFolderExists(folder);

        string fileName = SanitizeFileName(gameObject.name);
        string fbxPath = GetUniqueFbxPath(folder, fileName);

        CombinedFbxImportMaterialConfigurator.SetTargetPath(fbxPath);

        try
        {
            ModelExporter.ExportObject(fbxPath, gameObject);

            AssetDatabase.ImportAsset(
                fbxPath,
                ImportAssetOptions.ForceSynchronousImport | ImportAssetOptions.ForceUpdate
            );

            ConfigureMaterialImportForFbx(fbxPath);
            RemapImportedMaterials(fbxPath);
            AssetDatabase.Refresh();

            if (selectExportedAsset)
            {
                Object exportedAsset = AssetDatabase.LoadMainAssetAtPath(fbxPath);
                if (exportedAsset != null)
                {
                    Selection.activeObject = exportedAsset;
                    EditorGUIUtility.PingObject(exportedAsset);
                }
            }

            Debug.Log($"Combined mesh exported to FBX: {fbxPath}", this);
        }
        finally
        {
            CombinedFbxImportMaterialConfigurator.ClearTargetPath();
        }
    }

    private void ConfigureMaterialImportForFbx(string fbxPath)
    {
        ModelImporter modelImporter = AssetImporter.GetAtPath(fbxPath) as ModelImporter;
        if (modelImporter == null)
        {
            return;
        }

        modelImporter.materialImportMode = ModelImporterMaterialImportMode.ImportStandard;
        modelImporter.SaveAndReimport();
    }

    private void RemapImportedMaterials(string fbxPath)
    {
        MeshRenderer sourceRenderer = GetComponent<MeshRenderer>();
        if (sourceRenderer == null)
        {
            return;
        }

        ModelImporter modelImporter = AssetImporter.GetAtPath(fbxPath) as ModelImporter;
        if (modelImporter == null)
        {
            return;
        }

        Material[] sourceMaterials = sourceRenderer.sharedMaterials;
        if (sourceMaterials == null || sourceMaterials.Length == 0)
        {
            return;
        }

        bool changed = false;

        foreach (AssetImporter.SourceAssetIdentifier identifier in modelImporter.GetExternalObjectMap().Keys)
        {
            if (identifier.type != typeof(Material))
            {
                continue;
            }

            Material matchedMaterial = FindMaterialByName(sourceMaterials, identifier.name);
            if (matchedMaterial == null)
            {
                matchedMaterial = sourceMaterials[0];
            }

            modelImporter.AddRemap(identifier, matchedMaterial);
            changed = true;
        }

        if (changed)
        {
            modelImporter.SaveAndReimport();
        }
    }

    private Material FindMaterialByName(Material[] materials, string materialName)
    {
        for (int i = 0; i < materials.Length; i++)
        {
            Material material = materials[i];
            if (material != null && material.name == materialName)
            {
                return material;
            }
        }

        return null;
    }

    private string NormalizeFolderPath(string folder)
    {
        if (string.IsNullOrWhiteSpace(folder))
        {
            folder = "Assets/ExportedFBX";
        }

        return folder.Replace("\\", "/");
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
        {
            return path;
        }

        int index = 1;
        while (true)
        {
            string newPath = Path.Combine(folder, baseFileName + index + ".fbx").Replace("\\", "/");
            if (!File.Exists(newPath))
            {
                return newPath;
            }

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
#endif
}

#if UNITY_EDITOR
public class CombinedFbxImportMaterialConfigurator : AssetPostprocessor
{
    private const string TargetPathKey = "MeshCombiner_TargetFbxPath";

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
        if (string.IsNullOrEmpty(targetPath) || assetPath != targetPath)
        {
            return;
        }

        ModelImporter modelImporter = assetImporter as ModelImporter;
        if (modelImporter == null)
        {
            return;
        }

        modelImporter.materialImportMode = ModelImporterMaterialImportMode.ImportStandard;
    }
}

[CustomEditor(typeof(MeshCombiner))]
public class MeshCombinerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        EditorGUILayout.Space(10);

        MeshCombiner combiner = (MeshCombiner)target;

        if (GUILayout.Button("Combine Child Meshes Permanently", GUILayout.Height(32)))
        {
            combiner.CombineChildMeshesPermanently();
        }

        if (GUILayout.Button("Export Combined Result To FBX", GUILayout.Height(32)))
        {
            combiner.ExportCombinedResultToFbx();
        }
    }
}
#endif
