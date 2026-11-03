using System;
using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 「已记入侦探笔记」入册演出。§13.2 的四阶段 + 文案浮层，总时长 2.05 s：
    /// 定格 0.30 → 纸化起弧 0.55 → 加速飞入 0.30 → 收纳 0.13 → 文案 0.77。
    ///
    /// 评审意见 G：**不碰笔记本图标**——放大、发光、压扁、回弹全部交给现有的
    /// PlayIconBounce / UpdateRedDot，这里只负责把纸片送到图标处并消失。
    /// 纸片源图（把本局 UI 拍成一张纸）是 M2/M4 的活，这里先用一个奶油白圆角块占位。
    /// </summary>
    public sealed class MiniGameResultFlight : MonoBehaviour
    {
        const float HoldDuration = 0.30f;
        const float ArcDuration = 0.55f;
        const float FlyDuration = 0.30f;
        const float FoldDuration = 0.13f;
        const float ToastDuration = 0.77f;

        Canvas _canvas;
        RectTransform _paper;
        CanvasGroup _paperGroup;
        Action _onDone;

        public static void Play(Canvas canvas, MiniGameBoard board, Action onDone)
        {
            if (canvas == null)
            {
                if (onDone != null) onDone();
                return;
            }

            var go = new GameObject("ResultFlight", typeof(RectTransform));
            go.transform.SetParent(canvas.transform, false);
            var flight = go.AddComponent<MiniGameResultFlight>();
            flight.Begin(canvas, board, onDone);
        }

        void Begin(Canvas canvas, MiniGameBoard board, Action onDone)
        {
            _canvas = canvas;
            _onDone = onDone;

            var root = (RectTransform)transform;
            root.anchorMin = root.anchorMax = new Vector2(0.5f, 0.5f);
            root.pivot = new Vector2(0.5f, 0.5f);

            _paper = MiniGameUIKit.Panel(root, "Paper", MiniGameTheme.Cream, 14f);
            MiniGameUIKit.Place(_paper, Vector2.one * 0.5f, Vector2.one * 0.5f,
                Vector2.zero, new Vector2(360f, 220f));
            _paperGroup = _paper.gameObject.AddComponent<CanvasGroup>();
            _paperGroup.blocksRaycasts = false;

            var label = MiniGameUIKit.Label(_paper, "Mark", 30f, MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.35f));
            MiniGameUIKit.Stretch(label.rectTransform);
            label.text = "调查记录";

            StartCoroutine(Run(board));
        }

        IEnumerator Run(MiniGameBoard board)
        {
            var root = (RectTransform)transform;
            var from = StartPoint(board, root);
            var to = NotebookPoint(root);
            var control = PaperFlyPath.ControlPoint(from, to);

            _paper.anchoredPosition = from;
            _paper.localScale = Vector3.one;

            // 阶段 0：定格
            yield return Wait(HoldDuration);

            // 阶段 1：起弧（走完 72% 的路径）
            var t = 0f;
            while (t < ArcDuration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / ArcDuration);
                var eased = SpringReturn.EaseOutCubic(k) * 0.72f;
                _paper.anchoredPosition = PaperFlyPath.Sample(from, control, to, eased);
                var s = Mathf.Lerp(1f, 0.9f, k);
                _paper.localScale = new Vector3(s, s, 1f);
                _paper.localEulerAngles = new Vector3(0f, 0f,
                    Mathf.Lerp(0f, -8f, k));
                yield return null;
            }

            // 阶段 2：加速飞入（剩下 28%，同时缩到 0.45）
            t = 0f;
            while (t < FlyDuration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / FlyDuration);
                var eased = Mathf.Lerp(0.72f, 1f, SpringReturn.EaseInOutCubic(k));
                _paper.anchoredPosition = PaperFlyPath.Sample(from, control, to, eased);
                var s = Mathf.Lerp(0.9f, 0.45f, k);
                _paper.localScale = new Vector3(s, s, 1f);
                _paper.localEulerAngles = new Vector3(0f, 0f, Mathf.Lerp(-8f, -22f, k));
                yield return null;
            }

            // 阶段 3：收纳
            t = 0f;
            while (t < FoldDuration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / FoldDuration);
                var s = Mathf.Lerp(0.45f, 0.12f, k);
                _paper.localScale = new Vector3(s, s * 0.6f, 1f);
                _paperGroup.alpha = 1f - k;
                yield return null;
            }
            _paper.gameObject.SetActive(false);

            // 阶段 4：文案浮层
            var toast = MiniGameUIKit.Label(root, "Toast", 30f, MiniGameTheme.Deep);
            MiniGameUIKit.Place(toast.rectTransform, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                new Vector2(0f, -260f), new Vector2(720f, 60f));
            toast.text = "已记入侦探笔记";
            toast.alpha = 0f;
            t = 0f;
            while (t < ToastDuration)
            {
                t += Time.unscaledDeltaTime;
                var k = Mathf.Clamp01(t / ToastDuration);
                toast.alpha = k < 0.2f ? Mathf.Lerp(0f, 1f, k / 0.2f)
                    : k > 0.75f ? Mathf.Lerp(1f, 0f, (k - 0.75f) / 0.25f) : 1f;
                yield return null;
            }

            if (_onDone != null) _onDone();
            Destroy(gameObject);
        }

        static IEnumerator Wait(float seconds)
        {
            var t = 0f;
            while (t < seconds)
            {
                t += Time.unscaledDeltaTime;
                yield return null;
            }
        }

        /// <summary>纸片起点：本局面板的中心。§13 的「把小游戏 UI 拍成一张纸」最终要换成截图。</summary>
        Vector2 StartPoint(MiniGameBoard board, RectTransform root)
        {
            if (board == null) return Vector2.zero;
            var canvas = _canvas != null ? _canvas : board.GetComponentInParent<Canvas>();
            var canvasRect = canvas != null ? canvas.transform as RectTransform : null;
            if (canvasRect == null) return Vector2.zero;
            return MiniGameUIKit.WorldToLocal(root, board.transform.position);
        }

        /// <summary>纸片终点：笔记本图标的屏幕位置。找不到就飞右上角，不阻塞流程。</summary>
        Vector2 NotebookPoint(RectTransform root)
        {
            var book = FindObjectOfType<BookController>();
            if (book != null && book.open != null)
                return MiniGameUIKit.WorldToLocal(root, book.open.transform.position);

            var canvasRect = root != null ? root : (RectTransform)transform;
            return new Vector2(canvasRect.rect.width * 0.5f - 120f, canvasRect.rect.height * 0.5f - 120f);
        }
    }
}
