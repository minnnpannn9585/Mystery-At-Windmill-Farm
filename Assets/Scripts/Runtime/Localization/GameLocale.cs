using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Localization;
using UnityEngine.Localization.Settings;
using UnityEngine.Localization.Tables;

namespace EggRescue
{
    /// <summary>
    /// 中英文切换。优先读 Unity Localization 当前语言的字符串表，表还没载入时用 catalog。
    /// </summary>
    public static class GameLocale
    {
        public const string Chinese = "zh-Hans";
        public const string English = "en";
        const string PrefKey = "egg.locale";

        public static event Action Changed;

        public static string Code { get; private set; }
        public static bool IsEnglish { get { return Code != null && Code.StartsWith("en"); } }

        static StringTable _ui;
        static StringTable _lines;
        static bool _applyQueued;
        static Runner _runner;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        static void Boot()
        {
            Code = PlayerPrefs.GetString(PrefKey, Chinese);
            if (string.IsNullOrEmpty(Code)) Code = Chinese;
            LocaleCatalog.EnsureLoaded();
            var go = new GameObject("GameLocale");
            UnityEngine.Object.DontDestroyOnLoad(go);
            _runner = go.AddComponent<Runner>();
        }

        public static void Set(string code)
        {
            if (string.IsNullOrEmpty(code)) code = Chinese;
            Code = code;
            PlayerPrefs.SetString(PrefKey, code);
            PlayerPrefs.Save();
            _ui = null;
            _lines = null;
            ApplySelectedLocale();
            if (Changed != null) Changed();
            if (_runner != null && LocalizationSettings.HasSettings && LocalizationSettings.InitializationOperation.IsDone)
                _runner.StartCoroutine(ReloadTables());
        }

        public static string T(string key)
        {
            var fromTable = FromTable(_ui, key);
            if (!string.IsNullOrEmpty(fromTable)) return fromTable;
            return LocaleCatalog.Ui(key, IsEnglish);
        }

        public static string Line(string source)
        {
            if (string.IsNullOrEmpty(source) || !IsEnglish) return source;
            var fromTable = FromTable(_lines, source);
            if (!string.IsNullOrEmpty(fromTable)) return fromTable;
            return LocaleCatalog.Line(source, true);
        }

        public static string Name(string source)
        {
            if (string.IsNullOrEmpty(source) || !IsEnglish) return source;
            var fromTable = FromTable(_ui, "name." + source);
            if (!string.IsNullOrEmpty(fromTable)) return fromTable;
            return LocaleCatalog.Name(source, true);
        }

        static string FromTable(StringTable table, string key)
        {
            if (table == null || string.IsNullOrEmpty(key)) return null;
            try
            {
                var entry = table.GetEntry(key);
                if (entry == null || string.IsNullOrEmpty(entry.Value)) return null;
                return entry.Value;
            }
            catch (Exception)
            {
                return null;
            }
        }

        static void ApplySelectedLocale()
        {
            if (!LocalizationSettings.HasSettings) return;
            if (!LocalizationSettings.InitializationOperation.IsDone)
            {
                _applyQueued = true;
                return;
            }
            var locale = LocalizationSettings.AvailableLocales.GetLocale(new LocaleIdentifier(Code));
            if (locale != null) LocalizationSettings.SelectedLocale = locale;
        }

        static IEnumerator Initialize()
        {
            yield return LocalizationSettings.InitializationOperation;
            ApplySelectedLocale();
            _applyQueued = false;
            yield return ReloadTables();
        }

        static IEnumerator ReloadTables()
        {
            if (!LocalizationSettings.HasSettings) yield break;
            var ui = LocalizationSettings.StringDatabase.GetTableAsync("UI");
            var lines = LocalizationSettings.StringDatabase.GetTableAsync("Dialogue");
            yield return ui;
            yield return lines;
            if (ui.IsDone && ui.Status == UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded)
                _ui = ui.Result;
            if (lines.IsDone && lines.Status == UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded)
                _lines = lines.Result;
            if (Changed != null) Changed();
        }

        sealed class Runner : MonoBehaviour
        {
            void OnEnable()
            {
                LocalizationSettings.SelectedLocaleChanged += OnLocaleChanged;
            }

            void OnDisable()
            {
                LocalizationSettings.SelectedLocaleChanged -= OnLocaleChanged;
            }

            void Start()
            {
                StartCoroutine(Initialize());
            }

            void OnLocaleChanged(Locale locale)
            {
                if (locale == null) return;
                if (_applyQueued) return;
                if (locale.Identifier.Code == Code) return;
                Set(locale.Identifier.Code);
            }
        }
    }
}
