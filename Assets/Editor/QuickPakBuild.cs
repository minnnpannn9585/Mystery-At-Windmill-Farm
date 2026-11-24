using System;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

// One-shot batchmode build: Windows x64 player -> C:\Users\Administrator\Desktop\pak
public static class QuickPakBuild
{
    const string Output = @"C:\Users\Administrator\Desktop\pak\Mystery at Windmill Farm.exe";
    const string ResultLog = "Logs/quick-pak-build-result.txt";

    public static void Build()
    {
        Directory.CreateDirectory("Logs");
        var sb = new StringBuilder();
        sb.AppendLine("Quick PAK build (batchmode)");
        sb.AppendLine("Started UTC: " + DateTime.UtcNow.ToString("O"));
        sb.AppendLine("Output: " + Path.GetFullPath(Output));
        try
        {
            var scenes = EditorBuildSettings.scenes.Where(s => s.enabled).Select(s => s.path).ToArray();
            if (scenes.Length == 0)
                throw new BuildFailedException("No enabled scenes in Build Settings.");
            sb.AppendLine("Scenes: " + string.Join(" | ", scenes));

            Directory.CreateDirectory(Path.GetDirectoryName(Output));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
            {
                scenes = scenes,
                locationPathName = Output,
                target = BuildTarget.StandaloneWindows64,
                options = BuildOptions.None
            });

            if (report == null)
                throw new BuildFailedException("BuildPipeline returned null report.");
            sb.AppendLine("Result: " + report.summary.result);
            sb.AppendLine("SizeBytes: " + report.summary.totalSize);
            sb.AppendLine("Errors: " + report.summary.totalErrors);
            sb.AppendLine("Warnings: " + report.summary.totalWarnings);
            sb.AppendLine("Duration: " + report.summary.totalTime);
            sb.AppendLine("Status: " + (report.summary.result == BuildResult.Succeeded ? "Succeeded" : "Failed"));
            if (report.summary.result != BuildResult.Succeeded)
                throw new BuildFailedException("Build result: " + report.summary.result);
            Debug.Log("[QuickPakBuild] OK -> " + Path.GetFullPath(Output));
        }
        catch (Exception e)
        {
            sb.AppendLine("Status: Failed");
            sb.AppendLine(e.ToString());
            Debug.LogError("[QuickPakBuild] " + e);
            throw;
        }
        finally
        {
            sb.AppendLine("Finished UTC: " + DateTime.UtcNow.ToString("O"));
            File.WriteAllText(ResultLog, sb.ToString());
        }
    }
}
