using System;
using System.Collections;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 弹性回位与区间补间。§18.2.3 的第四个原语：
    /// T2 松手、T3 松手、T4 错格、T7 卡弹回全部走这一条曲线，只是参数不同。
    /// </summary>
    public static class SpringReturn
    {
        /// <summary>easeOutBack：末段过冲后回落，是「弹回去」而不是「滑回去」。</summary>
        public static float EaseOutBack(float t, float overshoot)
        {
            t = Mathf.Clamp01(t);
            var s = Mathf.Max(1f, overshoot) - 1f;
            var u = t - 1f;
            return 1f + u * u * ((s + 1f) * u + s);
        }

        public static float EaseOutCubic(float t)
        {
            t = Mathf.Clamp01(t);
            var u = 1f - t;
            return 1f - u * u * u;
        }

        public static float EaseInOutCubic(float t)
        {
            t = Mathf.Clamp01(t);
            return t < 0.5f ? 4f * t * t * t : 1f - Mathf.Pow(-2f * t + 2f, 3f) * 0.5f;
        }

        /// <summary>位置回弹。到点后回调，便于串下一次判定。</summary>
        public static Coroutine MoveTo(MonoBehaviour host, RectTransform rect, Vector2 from, Vector2 to,
            float duration = MiniGameMotion.ReturnDuration,
            float overshoot = MiniGameMotion.ReturnOvershoot,
            Action done = null)
        {
            if (host == null || rect == null) return null;
            return host.StartCoroutine(MoveRoutine(rect, from, to, duration, overshoot, done));
        }

        static IEnumerator MoveRoutine(RectTransform rect, Vector2 from, Vector2 to,
            float duration, float overshoot, Action done)
        {
            if (duration <= 0f)
            {
                rect.anchoredPosition = to;
                if (done != null) done();
                yield break;
            }
            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = EaseOutBack(Mathf.Clamp01(t / duration), overshoot);
                if (rect != null)
                    rect.anchoredPosition = Vector2.LerpUnclamped(from, to, k);
                yield return null;
            }
            if (rect != null) rect.anchoredPosition = to;
            if (done != null) done();
        }

        /// <summary>缩放补间（拿起 1.04 / 放下 1.00）。</summary>
        public static Coroutine ScaleTo(MonoBehaviour host, Transform target, float from, float to,
            float duration, Action done = null)
        {
            if (host == null || target == null) return null;
            return host.StartCoroutine(ScaleRoutine(target, from, to, duration, done));
        }

        static IEnumerator ScaleRoutine(Transform target, float from, float to, float duration, Action done)
        {
            if (duration <= 0f)
            {
                if (target != null) target.localScale = Vector3.one * to;
                if (done != null) done();
                yield break;
            }
            var t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = EaseOutCubic(t / duration);
                if (target != null) target.localScale = Vector3.one * Mathf.LerpUnclamped(from, to, k);
                yield return null;
            }
            if (target != null) target.localScale = Vector3.one * to;
            if (done != null) done();
        }

        /// <summary>通用补间：每帧把 0→1 的进度喂给回调，用于透明度、数字滚动等。</summary>
        public static Coroutine Progress(MonoBehaviour host, float duration, Action<float> step,
            Action done = null, bool useUnscaledTime = true)
        {
            if (host == null) return null;
            return host.StartCoroutine(ProgressRoutine(duration, step, done, useUnscaledTime));
        }

        static IEnumerator ProgressRoutine(float duration, Action<float> step, Action done, bool unscaled)
        {
            var t = 0f;
            while (t < duration)
            {
                t += unscaled ? Time.unscaledDeltaTime : Time.deltaTime;
                if (step != null) step(Mathf.Clamp01(t / duration));
                yield return null;
            }
            if (step != null) step(1f);
            if (done != null) done();
        }
    }
}
