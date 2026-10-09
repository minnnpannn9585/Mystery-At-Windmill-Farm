using System;

namespace EggRescue
{
    /// <summary>
    /// Steam 语言名（ISteamApps::GetCurrentGameLanguage）和游戏内部语言码的对照。
    /// 游戏只发一份包，中英文都在 catalog 里，不按语言拆 Depot。
    /// </summary>
    public static class SteamLocaleMap
    {
        /// <summary>
        /// 把 Steam 语言名或启动参数收成 zh-Hans / en。
        /// 没有繁体表时，tchinese 先用简体。Steam 上暂时没有的语言用英文。
        /// </summary>
        public static string ToGameLocale(string steamOrCode)
        {
            if (string.IsNullOrEmpty(steamOrCode)) return null;
            switch (steamOrCode.Trim().ToLowerInvariant())
            {
                case "english":
                case "en":
                case "en-us":
                case "en-gb":
                    return GameLocale.English;
                case "schinese":
                case "tchinese":
                case "zh":
                case "zh-cn":
                case "zh-hans":
                case "zh-tw":
                case "zh-hant":
                    return GameLocale.Chinese;
                default:
                    return GameLocale.English;
            }
        }

        /// <summary>
        /// 读启动参数 <c>-language english</c> / <c>-language schinese</c>。
        /// Steam 启动选项可以带这个参数，编辑器里也能用来验对照表。
        /// </summary>
        public static string FromLaunchOption()
        {
            var args = Environment.GetCommandLineArgs();
            for (var i = 0; i < args.Length - 1; i++)
            {
                if (args[i] != "-language" && args[i] != "--language") continue;
                return ToGameLocale(args[i + 1]);
            }
            return null;
        }
    }
}
