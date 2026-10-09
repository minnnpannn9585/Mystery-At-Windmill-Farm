using UnityEngine;

namespace EggRescue
{
    /// <summary>
    /// 主菜单决定这次进农场是新游戏还是继续。场景切换后由 GameBootstrap 消费。
    /// </summary>
    public static class GameSession
    {
        public const string MenuSceneName = "StartMenu";
        public const string GameSceneName = "Mechanics_Code";

        public enum Mode
        {
            Default,
            NewGame,
            Continue
        }

        public static Mode Pending = Mode.Default;

        public static bool ShouldLoadSave()
        {
            if (Pending == Mode.Continue) return true;
            if (Pending == Mode.NewGame) return false;
            return !Application.isEditor;
        }

        public static void Consume()
        {
            Pending = Mode.Default;
        }
    }
}
