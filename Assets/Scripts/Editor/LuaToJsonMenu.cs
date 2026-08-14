using System.Diagnostics;
using UnityEditor;
using UnityEngine;

namespace EggRescue.Editor
{
    public static class LuaToJsonMenu
    {
        [MenuItem("Tools/Egg Rescue/PC/Convert Lua Data To JSON")]
        public static void Convert()
        {
            var root = System.IO.Path.GetFullPath(System.IO.Path.Combine(Application.dataPath, ".."));
            var project = System.IO.Path.Combine(root, "MissingEggDoc-main", "scripts", "LuaToJson", "LuaToJson.csproj");
            if (!System.IO.File.Exists(project))
            {
                EditorUtility.DisplayDialog("Egg Rescue PC", "找不到 LuaToJson.csproj", "OK");
                return;
            }
            var psi = new ProcessStartInfo
            {
                FileName = "dotnet",
                Arguments = "run --project \"" + project + "\"",
                WorkingDirectory = root,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true
            };
            var p = Process.Start(psi);
            var stdout = p.StandardOutput.ReadToEnd();
            var stderr = p.StandardError.ReadToEnd();
            p.WaitForExit();
            UnityEngine.Debug.Log("[LuaToJson] " + stdout + stderr);
            AssetDatabase.Refresh();
            EditorUtility.DisplayDialog("Egg Rescue PC", p.ExitCode == 0 ? "JSON 已写入 Assets/Resources/GameData" : "转换失败，见 Console", "OK");
        }
    }
}
