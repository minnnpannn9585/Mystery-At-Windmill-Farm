using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

public static class EggRescuePublishMenu
{
    private const string EditorDialogueDir = "Assets/Editor/DialogueData";
    private const string DataDialogueDir = "Assets/Data/DialogueData";
    private const string EditorConfigDir = "Assets/Editor/EditData";
    private const string DataGlobalDir = "Assets/Data/GlobalData";

    [MenuItem("Tools/Egg Rescue/Publish Editor to Data")]
    public static void PublishEditorToData()
    {
        int dialogueCount = CopyDirectoryLuaFiles(EditorDialogueDir, DataDialogueDir, transformLua: false);
        bool npcOk = PublishConfigFile(
            $"{EditorConfigDir}/NPCData_Config.lua",
            $"{DataGlobalDir}/NPCData_Config.lua",
            isGlobalVariables: false);
        bool varsOk = PublishConfigFile(
            $"{EditorConfigDir}/GlobalVariables.lua",
            $"{DataGlobalDir}/GlobalVariables.lua",
            isGlobalVariables: true);

        AssetDatabase.Refresh();

        TouXiangLiHuiSpriteCollector.BatchWirePortraitSprites();

        Debug.Log($"[EggRescue] Publish complete. Dialogue files: {dialogueCount}, NPCData: {npcOk}, GlobalVariables: {varsOk}");
        EditorUtility.DisplayDialog(
            "Publish Editor to Data",
            $"Dialogue: {dialogueCount} files\nNPCData: {(npcOk ? "OK" : "FAILED")}\nGlobalVariables: {(varsOk ? "OK" : "FAILED")}",
            "OK");
    }

    [MenuItem("Tools/Egg Rescue/Refresh Scene DialogueData")]
    public static void RefreshSceneDialogueData()
    {
        CreateDialogueDataObjects.Create();
    }

    private static int CopyDirectoryLuaFiles(string sourceDir, string destDir, bool transformLua)
    {
        string sourceFull = Path.Combine(Directory.GetCurrentDirectory(), sourceDir);
        string destFull = Path.Combine(Directory.GetCurrentDirectory(), destDir);

        if (!Directory.Exists(sourceFull))
        {
            Debug.LogError($"[EggRescue] Source directory missing: {sourceDir}");
            return 0;
        }

        Directory.CreateDirectory(destFull);

        int count = 0;
        foreach (string sourceFile in Directory.GetFiles(sourceFull, "*.lua", SearchOption.AllDirectories))
        {
            string relativePath = Path.GetRelativePath(sourceFull, sourceFile);
            string destFile = Path.Combine(destFull, relativePath);
            string? destDirName = Path.GetDirectoryName(destFile);
            if (!string.IsNullOrEmpty(destDirName))
            {
                Directory.CreateDirectory(destDirName);
            }

            if (transformLua)
            {
                string content = File.ReadAllText(sourceFile, Encoding.UTF8);
                File.WriteAllText(destFile, TransformEditorLuaToRuntime(content), new UTF8Encoding(false));
            }
            else
            {
                File.Copy(sourceFile, destFile, overwrite: true);
            }
            count++;
        }

        return count;
    }

    private static bool PublishConfigFile(string sourceAssetPath, string destAssetPath, bool isGlobalVariables)
    {
        string sourceFull = Path.Combine(Directory.GetCurrentDirectory(), sourceAssetPath);
        if (!File.Exists(sourceFull))
        {
            Debug.LogError($"[EggRescue] Config source missing: {sourceAssetPath}");
            return false;
        }

        string content = File.ReadAllText(sourceFull, Encoding.UTF8);
        content = TransformEditorLuaToRuntime(content);

        if (!isGlobalVariables)
        {
            // Data NPCData uses global table without return (runtime DouyinScript convention).
            content = Regex.Replace(content, @"\r?\nreturn\s+NPCData\s*$", "", RegexOptions.Multiline);
        }

        string destFull = Path.Combine(Directory.GetCurrentDirectory(), destAssetPath);
        Directory.CreateDirectory(Path.GetDirectoryName(destFull)!);
        File.WriteAllText(destFull, content, new UTF8Encoding(false));
        return true;
    }

    /// <summary>
    /// Editor copies use "local Table = {" and optional "return Table"; runtime Data copies use global assignment.
    /// </summary>
    private static string TransformEditorLuaToRuntime(string content)
    {
        content = Regex.Replace(content, @"^local\s+(GlobalVariables|NPCData)\s*=\s*\{", "$1 = {", RegexOptions.Multiline);
        content = Regex.Replace(content, @"\r?\nreturn\s+GlobalVariables\s*$", "", RegexOptions.Multiline);
        return content;
    }
}
