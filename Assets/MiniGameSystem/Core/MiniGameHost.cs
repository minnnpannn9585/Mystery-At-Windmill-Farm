using System;
using UnityEngine;
using UnityEngine.EventSystems;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 门面。外部只认这三个：<see cref="Open"/>、<see cref="Close"/>、<see cref="IsOpen"/>。
    /// 真正的活由 <see cref="MiniGameHostRunner"/> 干（§15.3）。
    /// </summary>
    public static class MiniGameHost
    {
        static MiniGameHostRunner _runner;

        public static bool IsOpen
        {
            get { return _runner != null && _runner.IsOpen; }
        }

        public static string CurrentId
        {
            get { return _runner != null ? _runner.CurrentId : null; }
        }

        /// <summary>
        /// 打开一局。找不到 Id 直接返回 false，不抛异常——
        /// 场景入口配错时应该是「没反应 + 一行报错」，不是整个流程崩掉。
        /// </summary>
        public static bool Open(string defId, Action onReturn = null)
        {
            var def = MiniGameRegistry.Get(defId);
            if (def == null)
            {
                Debug.LogError("[MiniGame] unknown def id: " + defId);
                return false;
            }
            return Open(def, onReturn);
        }

        public static bool Open(MiniGameDef def, Action onReturn = null)
        {
            if (def == null) { Debug.LogError("[MiniGame] null def"); return false; }
            if (IsOpen)
            {
                Debug.LogWarning("[MiniGame] already open, ignore " + def.Id);
                return false;
            }
            var content = MiniGameRegistry.Content(def);
            if (content == null)
            {
                // M1 只有自检局有内容，19 局的 Data/ 要到 M3 才补。
                // 这期间入口若先被触发，宁可「不打开 + 一行说明」，也不要拿空内容去建板子。
                Debug.LogWarning("[MiniGame] content not ready: " + def.Id + "（M3 补 Data/ 后才有）");
                return false;
            }
            // 注册表 / 样例返回的是共享内容。模板运行时会改写 Cards（T7 的 Debug 增减卡），
            // 不隔离的话上一局的改动会带进下一局。每局拿自己那份浅拷贝。
            content = content.Clone();
            var ok = Runner.OpenDef(def, content, onReturn);
            // 开局成败各留一行：M1 自检全靠这行判断「按了键到底有没有开起来」，
            // 只报错不报成功的话，失败和「键没生效」在控制台里长得一模一样。
            if (ok) Debug.Log("[MiniGame] opened " + def.Id + " (" + def.Template + ")");
            else Debug.LogError("[MiniGame] OpenDef failed: " + def.Id);
            return ok;
        }

        /// <summary>这一局是否已经完成过（提交变量已写）。入口用它决定「开游戏」还是「直接补点亮」。</summary>
        public static bool IsSubmitted(MiniGameDef def)
        {
            return MiniGameHostRunner.IsSubmitted(def);
        }

        public static bool IsSubmitted(string defId)
        {
            return MiniGameHostRunner.IsSubmitted(MiniGameRegistry.Get(defId));
        }

        /// <summary>强制关闭（读档 / 切场景 / 回主菜单）。正常流程不要调。</summary>
        public static void Close()
        {
            if (_runner != null) _runner.ForceClose();
        }

        internal static MiniGameHostRunner Runner
        {
            get
            {
                if (_runner == null)
                {
                    var go = new GameObject("MiniGameHost");
                    UnityEngine.Object.DontDestroyOnLoad(go);
                    _runner = go.AddComponent<MiniGameHostRunner>();
                }
                return _runner;
            }
        }
    }

    /// <summary>
    /// Host 实体：一间局一间局地建 / 拆，不复用对象池。
    /// 一批小游戏的生命周期以秒计，重建比维护复用状态省心（§15.3）。
    /// </summary>
    public sealed class MiniGameHostRunner : MonoBehaviour
    {
        Canvas _canvas;
        RectTransform _root;
        MiniGameBoard _board;
        MiniGameBackdrop _backdrop;
        Action _onReturn;
        float _prevTimeScale = 1f;
        bool _closing;

        public bool IsOpen { get { return _board != null; } }
        public string CurrentId { get { return _board != null ? _board.DefId : null; } }

        void Awake()
        {
            EnsureEventSystem();
            var canvas = MiniGameUIKit.CreateCanvas("MiniGameCanvas");
            canvas.transform.SetParent(transform, false);
            _canvas = canvas;

            _root = MiniGameUIKit.Node(canvas.transform, "Root");
            MiniGameUIKit.Stretch(_root);
            _root.gameObject.SetActive(false);
        }

        static void EnsureEventSystem()
        {
            if (EventSystem.current != null) return;
            if (FindObjectOfType<EventSystem>() != null) return;
            var go = new GameObject("EventSystem");
            go.AddComponent<EventSystem>();
            go.AddComponent<StandaloneInputModule>();
        }

        public bool OpenDef(MiniGameDef def, MiniGameContent content, Action onReturn)
        {
            if (_board != null) return false;

            var go = new GameObject("Board_" + def.Id, typeof(RectTransform));
            var rect = (RectTransform)go.transform;
            rect.SetParent(_root, false);
            MiniGameUIKit.Stretch(rect);

            var board = go.AddComponent(TypeOf(def.Template)) as MiniGameBoard;
            if (board == null)
            {
                Debug.LogError("[MiniGame] no board type for " + def.Template);
                Destroy(go);
                return false;
            }

            _board = board;
            _onReturn = onReturn;
            _closing = false;

            board.OnSubmit += HandleSubmit;
            board.OnExit += HandleExit;

            _root.gameObject.SetActive(true);

            // 黑底 + 模糊：自己开一张负排序值的画布，压在场景之上、全部 UI 之下。
            // 拍帧要关掉其它所有画布（HUD / 笔记本也关），时机放在板子 Initialize 之前最省事。
            _backdrop = MiniGameBackdrop.Create();
            _backdrop.Begin(this);

            EnterLock();

            board.Initialize(def, content, rect);
            return true;
        }

        /// <summary>模板 → 板子（§18.1 M2：七块板一一落地，不再回落 Debug）。</summary>
        static Type TypeOf(MiniGameTemplate template)
        {
            switch (template)
            {
                case MiniGameTemplate.Magnifier: return typeof(Boards.MagnifierBoard);
                case MiniGameTemplate.Uncover: return typeof(Boards.UncoverBoard);
                case MiniGameTemplate.Rotate: return typeof(Boards.RotateBoard);
                case MiniGameTemplate.Jigsaw: return typeof(Boards.JigsawBoard);
                case MiniGameTemplate.Rubbing: return typeof(Boards.RubbingBoard);
                case MiniGameTemplate.Tweezer: return typeof(Boards.TweezerBoard);
                case MiniGameTemplate.Testimony: return typeof(Boards.TestimonyBoard);
                case MiniGameTemplate.Debug:
                default:
                    return typeof(Boards.DebugBoard);
            }
        }

        void EnterLock()
        {
            _prevTimeScale = Time.timeScale;
            Time.timeScale = 0f;
            GameEvents.SetPaused(true);
        }

        void ReleaseLock()
        {
            Time.timeScale = _prevTimeScale <= 0f ? 1f : _prevTimeScale;
            GameEvents.SetPaused(false);
        }

        // ---------------- 提交 ----------------

        void HandleSubmit(MiniGameBoard board)
        {
            var def = board.Definition;
            WriteSubmit(def);
            MiniGameSave.Clear(def.Id);
            SaveService.Save();

            MiniGameResultFlight.Play(_canvas, board, () => Teardown(true));
        }

        /// <summary>
        /// 写提交变量。只在「第一次完成」时写，并顺带 +1 计数——
        /// 重复进入已完成的局不应该再发一次线索（§15.4 / 18 局自检第 4 条）。
        /// </summary>
        static void WriteSubmit(MiniGameDef def)
        {
            if (def == null) return;
            var firstTime = !IsSubmitted(def);

            if (!string.IsNullOrEmpty(def.SubmitVar))
            {
                if (def.SubmitIsInt) GameState.SetInt(def.SubmitVar, def.IntSubmitValue);
                else GameState.SetBool(def.SubmitVar, true);
            }

            if (firstTime && !string.IsNullOrEmpty(def.CountVar))
                GameState.SetInt(def.CountVar, GameState.GetInt(def.CountVar) + 1);
        }

        public static bool IsSubmitted(MiniGameDef def)
        {
            if (def == null || string.IsNullOrEmpty(def.SubmitVar)) return false;
            if (def.SubmitIsInt) return GameState.GetInt(def.SubmitVar) == def.IntSubmitValue;
            return GameState.GetBool(def.SubmitVar);
        }

        // ---------------- 退出 ----------------

        void HandleExit(MiniGameBoard board, MiniGameExit exit)
        {
            var def = board.Definition;
            if (exit != MiniGameExit.Completed)
            {
                // 退出要留档：进度保留，线索不发（§4.4 Exit 行）
                MiniGameSave.Capture(board.CaptureProgress());
                SaveService.Save();
            }
            Teardown(exit == MiniGameExit.Completed);
        }

        void Teardown(bool submitted)
        {
            if (_closing) return;
            _closing = true;

            // 出局走和入册演出同一套黑底：先淡出，再拆板子
            if (_backdrop != null && isActiveAndEnabled)
                StartCoroutine(TeardownRoutine(submitted));
            else
                FinishTeardown(submitted);
        }

        System.Collections.IEnumerator TeardownRoutine(bool submitted)
        {
            if (_backdrop != null) yield return _backdrop.FadeOut(0.28f);
            FinishTeardown(submitted);
        }

        void FinishTeardown(bool submitted)
        {
            if (_board != null)
            {
                _board.OnSubmit -= HandleSubmit;
                _board.OnExit -= HandleExit;
                Destroy(_board.gameObject);
                _board = null;
            }

            if (_backdrop != null)
            {
                Destroy(_backdrop.gameObject);
                _backdrop = null;
            }

            if (_root != null) _root.gameObject.SetActive(false);
            ReleaseLock();

            var callback = _onReturn;
            _onReturn = null;
            _closing = false;
            if (callback != null) callback();
        }

        public void ForceClose()
        {
            if (_board != null) _board.ForceClose();
            else Teardown(false);
        }

        void OnDestroy()
        {
            if (_board != null) ReleaseLock();
        }
    }
}
