using System;
using System.Reflection;
using UnityEngine;

namespace EggRescue
{
    /// <summary>
    /// 读取 Steam「这个游戏」的当前语言，不是 Steam 客户端界面语言。
    /// 尚未接入 Steamworks 时读不到，游戏保持现有默认。
    /// 接入后二选一：
    /// 1. SteamAPI 初始化成功时调用 <see cref="Bind"/>。
    /// 2. 使用 Steamworks.NET 或 Facepunch.Steamworks，并在本类查询前完成 Init。本类会自己找已加载的 API。
    /// </summary>
    public static class SteamLanguage
    {
        static Func<string> _reader;

        public static event Action Ready;

        public static bool IsBound { get { return _reader != null; } }

        /// <summary>
        /// reader 返回 Steam 语言名，例如 english、schinese。Steam 还没起来时返回 null。
        /// Steamworks.NET：<c>() =&gt; Steamworks.SteamAPI.IsSteamRunning() ? Steamworks.SteamApps.GetCurrentGameLanguage() : null</c>
        /// </summary>
        public static void Bind(Func<string> reader)
        {
            _reader = reader;
            if (Ready != null) Ready();
        }

        public static bool TryGetLocale(out string code)
        {
            code = null;
            var steamName = ReadSteamName();
            if (string.IsNullOrEmpty(steamName)) return false;
            code = SteamLocaleMap.ToGameLocale(steamName);
            return !string.IsNullOrEmpty(code);
        }

        static string ReadSteamName()
        {
            if (_reader != null)
            {
                try
                {
                    var bound = _reader();
                    if (!string.IsNullOrEmpty(bound)) return bound;
                }
                catch (Exception e)
                {
                    Debug.LogWarning("[Locale] Steam language reader failed: " + e.Message);
                }
            }
            try
            {
                return ReadLoadedSteamApi();
            }
            catch (Exception e)
            {
                Debug.LogWarning("[Locale] Steam language lookup failed: " + e.Message);
                return null;
            }
        }

        static string ReadLoadedSteamApi()
        {
            var assemblies = AppDomain.CurrentDomain.GetAssemblies();
            for (var i = 0; i < assemblies.Length; i++)
            {
                var asm = assemblies[i];
                var apps = asm.GetType("Steamworks.SteamApps");
                if (apps == null) continue;
                var api = asm.GetType("Steamworks.SteamAPI");
                if (api != null && IsReady(api))
                {
                    var name = InvokeLanguage(apps);
                    if (!string.IsNullOrEmpty(name)) return name;
                }
                var client = asm.GetType("Steamworks.SteamClient");
                if (client != null && IsReady(client))
                {
                    var name = InvokeLanguage(apps);
                    if (!string.IsNullOrEmpty(name)) return name;
                }
            }
            return null;
        }

        static bool IsReady(Type type)
        {
            const BindingFlags flags = BindingFlags.Public | BindingFlags.Static;
            var running = type.GetMethod("IsSteamRunning", flags, null, Type.EmptyTypes, null);
            if (running != null)
            {
                var value = running.Invoke(null, null);
                return value is bool && (bool)value;
            }
            var valid = type.GetProperty("IsValid", flags) ?? type.GetProperty("Valid", flags);
            if (valid == null) return false;
            var ready = valid.GetValue(null, null);
            return ready is bool && (bool)ready;
        }

        static string InvokeLanguage(Type apps)
        {
            const BindingFlags flags = BindingFlags.Public | BindingFlags.Static;
            var method = apps.GetMethod("GetCurrentGameLanguage", flags, null, Type.EmptyTypes, null);
            if (method != null) return method.Invoke(null, null) as string;
            var prop = apps.GetProperty("GameLanguage", flags);
            if (prop == null) return null;
            return prop.GetValue(null, null) as string;
        }
    }
}
