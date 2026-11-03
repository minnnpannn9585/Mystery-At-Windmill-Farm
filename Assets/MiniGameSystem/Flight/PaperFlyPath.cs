using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 纸片飞行路径。二次贝塞尔 + 采样（§13.3）。
    /// 单独立出来是因为美术要在这条线上加拖尾和倾斜，单独一个类改起来方便。
    /// </summary>
    public static class PaperFlyPath
    {
        /// <summary>控制点：起点上方偏右，让弧线先抬起来再落下去。</summary>
        public static Vector2 ControlPoint(Vector2 from, Vector2 to)
        {
            var mid = Vector2.Lerp(from, to, 0.5f);
            var lift = Mathf.Clamp(Vector2.Distance(from, to) * 0.35f, 60f, 260f);
            return new Vector2(mid.x + lift * 0.25f, mid.y + lift);
        }

        public static Vector2 Sample(Vector2 from, Vector2 control, Vector2 to, float t)
        {
            t = Mathf.Clamp01(t);
            var u = 1f - t;
            return u * u * from + 2f * u * t * control + t * t * to;
        }

        /// <summary>切线方向，用来让纸片沿着弧线轻微旋转（M4 加，先留着接口）。</summary>
        public static float Angle(Vector2 from, Vector2 control, Vector2 to, float t)
        {
            var p0 = Sample(from, control, to, Mathf.Clamp01(t - 0.01f));
            var p1 = Sample(from, control, to, Mathf.Clamp01(t + 0.01f));
            var d = p1 - p0;
            return d.sqrMagnitude < 0.0001f ? 0f : Mathf.Atan2(d.y, d.x) * Mathf.Rad2Deg;
        }
    }
}
