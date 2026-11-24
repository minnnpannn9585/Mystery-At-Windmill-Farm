using System;
using System.IO;
using System.Reflection;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using EggRescue.MiniGame;
using EggRescue.MiniGame.Boards;

namespace EggRescue.MiniGame.EditorTools
{
    /// <summary>
    /// T7 错误卡回位的「真实运行时」自动验证（不关编辑器、不抢工程锁）。
    /// 用法：在项目根放一个空文件 tmp/t7_verify_trigger.txt，脚本会自动进 Play、
    /// 开一局 T7、用反射驱动一张卡放错槽、等回位跑完、把断言结果写到
    /// tmp/t7_verify_result.txt。读完自动删除触发文件，可重复触发。
    /// </summary>
    [InitializeOnLoad]
    static class MiniGameT7RejectRuntimeVerify
    {
        const string TriggerName = "t7_verify_trigger.txt";
        const string ResultName = "t7_verify_result.txt";

        static string Root
        {
            get
            {
                var d = new DirectoryInfo(Application.dataPath);
                return d.Parent != null ? d.Parent.FullName : Application.dataPath;
            }
        }
        static string TriggerPath { get { return Path.Combine(Root, "tmp", TriggerName); } }
        static string ResultPath { get { return Path.Combine(Root, "tmp", ResultName); } }

        enum Step { None, WaitPlay, OpenGame, WaitBoard, DriveReject, WaitReturn, Done }
        static Step _step = Step.None;
        static float _t0;
        static readonly List<string> _log = new List<string>();

        static MiniGameT7RejectRuntimeVerify()
        {
            EditorApplication.update += Tick;
        }

        /// <summary>batchmode 入口：-executeMethod ...RunBatch。只放触发文件，验证完自动 Exit。</summary>
        public static void RunBatch()
        {
            Directory.CreateDirectory(Path.Combine(Root, "tmp"));
            if (File.Exists(ResultPath)) { try { File.Delete(ResultPath); } catch { } }
            File.WriteAllText(TriggerPath, "run");
            Debug.Log("[T7Verify] RunBatch 已放触发文件，等待 update 状态机");
        }

        static void WriteLog(string s)
        {
            _log.Add(s);
            Debug.Log("[T7Verify] " + s);
        }

        static void Tick()
        {
            if (_step == Step.None)
            {
                if (!File.Exists(TriggerPath)) return;
                try { File.Delete(TriggerPath); } catch { }
                _log.Clear();
                if (File.Exists(ResultPath)) { try { File.Delete(ResultPath); } catch { } }
                WriteLog("触发，开始运行时验证");
                if (!EditorApplication.isPlaying)
                {
                    _step = Step.WaitPlay;
                    EditorApplication.isPlaying = true;
                    WriteLog("请求进入 Play 模式");
                }
                else _step = Step.OpenGame;
                return;
            }

            switch (_step)
            {
                case Step.WaitPlay:
                    if (EditorApplication.isPlaying && EditorApplication.isPlayingOrWillChangePlaymode)
                    {
                        _t0 = Time.realtimeSinceStartup;
                        _step = Step.OpenGame;
                        WriteLog("已进入 Play");
                    }
                    break;

                case Step.OpenGame:
                    // 等一帧让 Play 完全就绪
                    if (Time.realtimeSinceStartup - _t0 < 0.5f) break;
                    try
                    {
                        var id = MiniGameRegistry.SampleId(MiniGameTemplate.Testimony, "__verify");
                        MiniGameSave.Clear(id);
                        if (!MiniGameHost.Open(id))
                        {
                            Finish(false, "MiniGameHost.Open 失败: " + id);
                            return;
                        }
                        WriteLog("已开 T7 自检局 " + id);
                        _t0 = Time.realtimeSinceStartup;
                        _step = Step.WaitBoard;
                    }
                    catch (Exception e) { Finish(false, "OpenGame 异常: " + e); }
                    break;

                case Step.WaitBoard:
                    if (Time.realtimeSinceStartup - _t0 < 0.4f) break;
                    try { DriveReject(); }
                    catch (Exception e) { Finish(false, "DriveReject 异常: " + e); }
                    break;

                case Step.WaitReturn:
                    // 闪烁 0.96 + 回位 0.22 + 余量，给足 2.5 秒真实时间
                    if (Time.realtimeSinceStartup - _t0 < 2.5f) break;
                    try { VerifyAndFinish(); }
                    catch (Exception e) { Finish(false, "Verify 异常: " + e); }
                    break;
            }
        }

        static object GetField(object obj, string name)
        {
            var t = obj.GetType();
            while (t != null)
            {
                var f = t.GetField(name, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                if (f != null) return f.GetValue(obj);
                t = t.BaseType;
            }
            return null;
        }

        static MethodInfo GetMethod(object obj, string name)
        {
            var t = obj.GetType();
            while (t != null)
            {
                var m = t.GetMethod(name, BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
                if (m != null) return m;
                t = t.BaseType;
            }
            return null;
        }

        static MiniGamePiece _piece;
        static Vector2 _origin;
        static string _wrongSlotId;

        static void DriveReject()
        {
            // Runner 是 internal，跨程序集用反射取
            var runnerProp = typeof(MiniGameHost).GetProperty("Runner",
                BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public);
            var runner = runnerProp != null ? runnerProp.GetValue(null, null) : null;
            if (runner == null) { Finish(false, "Runner 为空"); return; }
            var board = GetField(runner, "_board") as MiniGameBoard;
            if (board == null) { Finish(false, "board 为空"); return; }

            var pieces = GetField(board, "Pieces") as List<MiniGamePiece>;
            var targets = GetField(board, "Targets") as List<DropTarget>;
            if (pieces == null || targets == null) { Finish(false, "Pieces/Targets 反射失败"); return; }

            // 选一张有归属槽的卡
            MiniGamePiece pick = null;
            foreach (var p in pieces)
            {
                var card = ContentCard(board, p.Id);
                if (card != null && !string.IsNullOrEmpty(card.SlotId)) { pick = p; break; }
            }
            if (pick == null) { Finish(false, "没有有效卡"); return; }
            _piece = pick;

            var cardSpec = ContentCard(board, pick.Id);
            // 找一个与卡归属不同的槽（错误槽）
            DropTarget wrong = null;
            foreach (var t in targets)
            {
                if (t != null && t.Id != cardSpec.SlotId) { wrong = t; break; }
            }
            if (wrong == null) { Finish(false, "没有错误槽可选"); return; }
            _wrongSlotId = wrong.Id;

            _origin = pick.Rect.anchoredPosition;   // 拖拽前的真实位置
            WriteLog($"卡 {pick.Id} 归属 {cardSpec.SlotId}，错误槽 {wrong.Id}，起点 {_origin}");

            // 1) 起手：记录 DragOrigin（BeginCarry 内部会做）
            var begin = GetMethod(board, "BeginCarry");
            begin.Invoke(board, new object[] { pick, _origin });

            // 2) 把携带物移到错误槽中心（模拟拖过去）
            var dropPoint = wrong.Center;
            pick.Handle.SyncTo(dropPoint);

            // 3) 让 moved 判定通过（_pressScreen 设到很远），再松手触发 reject
            var pressField = typeof(MiniGameBoard).GetField("_pressScreen", BindingFlags.Instance | BindingFlags.NonPublic);
            pressField.SetValue(board, new Vector2(-99999f, -99999f));
            var release = GetMethod(board, "ReleaseCarry");
            release.Invoke(board, new object[] { (Vector2?)dropPoint });

            WriteLog("已驱动错误拖放，等待闪烁+回位");
            _t0 = Time.realtimeSinceStartup;
            _step = Step.WaitReturn;
        }

        static MiniGameCard ContentCard(MiniGameBoard board, string id)
        {
            var content = GetField(board, "Content") as MiniGameContent;
            if (content == null || content.Cards == null) return null;
            foreach (var c in content.Cards) if (c != null && c.Id == id) return c;
            return null;
        }

        static void VerifyAndFinish()
        {
            var rectPos = _piece.Rect.anchoredPosition;
            var handlePos = _piece.Handle.LocalPosition;
            var dx = Mathf.Abs(rectPos.x - _origin.x);
            var dy = Mathf.Abs(rectPos.y - _origin.y);
            var hx = Mathf.Abs(handlePos.x - _origin.x);
            var hy = Mathf.Abs(handlePos.y - _origin.y);
            bool atOrigin = dx < 0.5f && dy < 0.5f;
            bool handleSynced = hx < 0.5f && hy < 0.5f;
            bool unlocked = !_piece.Returning;
            bool notPlaced = !_piece.Placed;

            WriteLog($"回位后 rect={rectPos} handle={handlePos} origin={_origin}");
            WriteLog($"atOrigin={atOrigin} handleSynced={handleSynced} unlocked={unlocked} notPlaced={notPlaced}");

            bool pass = atOrigin && handleSynced && unlocked && notPlaced;
            string detail = $"卡 {_piece.Id} 故意放入错误槽 {_wrongSlotId}\n"
                          + $"拖拽前位置={_origin}\n"
                          + $"回位后 rect={rectPos}（偏差 {dx:F3},{dy:F3}）\n"
                          + $"回位后 handle={handlePos}（偏差 {hx:F3},{hy:F3}）\n"
                          + $"回到拖拽前位置: {atOrigin}\n"
                          + $"Handle 同步: {handleSynced}\n"
                          + $"回位解锁: {unlocked}\n"
                          + $"卡片未留在槽位(Placed=false): {notPlaced}";
            Finish(pass, detail);
        }

        static void Finish(bool pass, string detail)
        {
            var sb = new System.Text.StringBuilder();
            sb.AppendLine(pass ? "RESULT=PASS" : "RESULT=FAIL");
            sb.AppendLine(detail);
            sb.AppendLine("---- process log ----");
            foreach (var l in _log) sb.AppendLine(l);
            try { File.WriteAllText(ResultPath, sb.ToString()); } catch (Exception e) { Debug.LogError("[T7Verify] 写结果失败 " + e); }
            Debug.Log("[T7Verify] " + (pass ? "PASS" : "FAIL") + " 结果已写 " + ResultPath);
            _step = Step.None;

            // 自动关掉自检局，恢复编辑器
            try { if (MiniGameHost.IsOpen) MiniGameHost.Close(); } catch { }

            // batchmode 下验证完自动退出；编辑器里不退出
            if (Application.isBatchMode)
            {
                EditorApplication.delayCall += () => EditorApplication.Exit(pass ? 0 : 2);
            }
        }
    }
}
