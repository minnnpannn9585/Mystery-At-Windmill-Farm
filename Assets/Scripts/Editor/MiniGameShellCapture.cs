#if UNITY_EDITOR
using EggRescue.MiniGame;
using UnityEditor;
using UnityEngine;

/// <summary>
/// 骨架层资源验收：batchmode 下同步检查组件 PNG 能否 Resources.Load<Sprite>，
/// 并检查 19 局标题/提示文案是否接进 Def。用 -executeMethod MiniGameShellCapture.Run 调用。
/// </summary>
public static class MiniGameShellCapture
{
    [MenuItem("EggRescue/MiniGame/骨架层资源验收")]
    public static void Run()
    {
        var ok = true;

        // 1. 组件 PNG 加载
        var paths = new[]
        {
            MiniGameTheme.ArtPaperStack,
            MiniGameTheme.ArtPaperFace,
            MiniGameTheme.ArtPaperClip,
            MiniGameTheme.ArtCloseX,
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Magnifier),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Uncover),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Rotate),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Jigsaw),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Rubbing),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Tweezer),
            MiniGameTheme.ArtPaperBack(MiniGameTemplate.Testimony),
        };
        foreach (var p in paths)
        {
            var sp = Resources.Load<Sprite>(p);
            if (sp == null) { Debug.LogError("[ShellCapture] 加载失败: " + p); ok = false; }
            else Debug.Log("[ShellCapture] OK " + p + "  " + sp.rect.width + "x" + sp.rect.height);
        }

        // 2. 字体
        var font = MiniGameTheme.Font;
        if (font == null) { Debug.LogError("[ShellCapture] 字体加载失败"); ok = false; }
        else Debug.Log("[ShellCapture] Font OK " + font.name);

        // 3. 19 局文案逐字核对
        foreach (var def in MiniGameRegistry.All)
        {
            var title = MiniGameScript.TitleRow(def.Id);
            var hint = MiniGameScript.HintRow(def.Id);
            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(hint) || def.Objective != title)
            {
                Debug.LogError("[ShellCapture] 文案缺失/不一致: " + def.Id);
                ok = false;
            }
        }
        var q01 = MiniGameRegistry.Get("Q01");
        Debug.Log("[ShellCapture] Q01 标题行=" + (q01 != null ? q01.Objective : "<null>") +
                  " | 提示行=" + (q01 != null ? MiniGameScript.HintRow(q01.Id) : "<null>"));

        Debug.Log(ok ? "[ShellCapture] RESULT=PASS" : "[ShellCapture] RESULT=FAIL");
        EditorApplication.Exit(ok ? 0 : 1);
    }
}
#endif
