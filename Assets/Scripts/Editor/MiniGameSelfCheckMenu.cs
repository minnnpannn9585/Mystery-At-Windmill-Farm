using UnityEditor;
using UnityEngine;

namespace EggRescue.MiniGame.EditorTools
{
    /// <summary>
    /// 自检入口。不占键位的第二通道——Play 里按 F7 也行，但键位随时可能被别的系统占用，
    /// 菜单项不受输入焦点影响，验收时更可靠。
    /// M2 起多一层「模板自检」：七块板各能单独开一局，不需要等 M3 的真实文案。
    /// </summary>
    static class MiniGameSelfCheckMenu
    {
        const string Root = "Tools/小游戏/";

        [MenuItem(Root + "开一局自检局（M1 骨架）")]
        static void OpenDebugGame()
        {
            Open(MiniGameRegistry.DebugId);
        }

        // ---------------- M2：七模板 ----------------

        [MenuItem(Root + "模板自检/T1 放大镜调查")]
        static void OpenT1() { OpenSample(0); }

        [MenuItem(Root + "模板自检/T2 拨开遮挡")]
        static void OpenT2() { OpenSample(1); }

        [MenuItem(Root + "模板自检/T3 翻转查验")]
        static void OpenT3() { OpenSample(2); }

        [MenuItem(Root + "模板自检/T4 观察图拼合")]
        static void OpenT4() { OpenSample(3); }

        [MenuItem(Root + "模板自检/T5 痕迹拓印")]
        static void OpenT5() { OpenSample(4); }

        [MenuItem(Root + "模板自检/T6 镊取物证（Step 两步）")]
        static void OpenT6Step() { OpenSample(5); }

        [MenuItem(Root + "模板自检/T6 镊取物证（Count 件数）")]
        static void OpenT6Count() { OpenSample(6); }

        [MenuItem(Root + "模板自检/T7 证词归位")]
        static void OpenT7() { OpenSample(7); }

        [MenuItem(Root + "关掉当前局面板")]
        static void CloseGame()
        {
            if (!Application.isPlaying) return;
            MiniGameHost.Close();
        }

        [MenuItem(Root + "清掉自检局进度")]
        static void ClearSampleProgress()
        {
            MiniGameSave.Clear(MiniGameRegistry.DebugId);
            for (var i = 0; i < MiniGameRegistry.SampleOrder.Length; i++)
            {
                var id = MiniGameRegistry.SampleId(
                    MiniGameRegistry.SampleOrder[i], MiniGameRegistry.SampleSuffix[i]);
                MiniGameSave.Clear(id);
            }
            Debug.Log("[MiniGame] 自检进度已清（Debug + 7 模板）。");
        }

        // ---------------- 公共 ----------------

        static void OpenSample(int index)
        {
            if (index < 0 || index >= MiniGameRegistry.SampleOrder.Length) return;
            var def = MiniGameRegistry.Sample(
                MiniGameRegistry.SampleOrder[index], MiniGameRegistry.SampleMode[index],
                MiniGameRegistry.SampleSuffix[index]);
            Open(def);
        }

        static void Open(string defId)
        {
            if (!Application.isPlaying)
            {
                Debug.LogWarning("[MiniGame] 自检局要在 Play 模式下开——局内进度依赖运行时存档与暂停状态。");
                return;
            }
            if (!MiniGameHost.Open(defId))
                Debug.LogWarning("[MiniGame] 没开起来，看控制台上一条 [MiniGame] 的输出。");
        }

        static void Open(MiniGameDef def)
        {
            if (!Application.isPlaying)
            {
                Debug.LogWarning("[MiniGame] 自检局要在 Play 模式下开——局内进度依赖运行时存档与暂停状态。");
                return;
            }
            if (!MiniGameHost.Open(def))
                Debug.LogWarning("[MiniGame] 没开起来，看控制台上一条 [MiniGame] 的输出。");
        }
    }
}
