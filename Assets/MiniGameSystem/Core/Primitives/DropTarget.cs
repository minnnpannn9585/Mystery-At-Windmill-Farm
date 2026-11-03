using System;
using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>落点形状。七模板里出现过的五种，统一到这里，不再各写一套包含判定。</summary>
    public enum DropShape
    {
        /// <summary>T2 停放区：矩形，外扩 20px 容错。</summary>
        Rect,

        /// <summary>T6 观察盘 / T1 镜片：圆形。</summary>
        Circle,

        /// <summary>T4 拼合格：矩形 + 预判半径 ±35% 格宽。</summary>
        GridCell,

        /// <summary>T3 角度档：只看角度是否落在容差内。</summary>
        AngleNotch,

        /// <summary>T7 槽：矩形，可一槽多卡。</summary>
        Slot,
    }

    /// <summary>
    /// 落点。§18.2.3 的第二个原语，服务 T2 / T3 / T4 / T6 / T7。
    /// 只管「这个点算不算进」，判定正确与否由 Board 的 OnDrop / OnJudge 决定。
    /// </summary>
    public sealed class DropTarget
    {
        public string Id;

        /// <summary>期望的携带物 id。为 null 时退化为「任何携带物都接受」。</summary>
        public string AcceptId;

        public DropShape Shape = DropShape.Slot;

        /// <summary>局部坐标（相对 Area 矩形）的落点框。Slot / Rect / GridCell 用。</summary>
        public Rect Rect;

        public Vector2 Center;
        public float Radius = 100f;

        /// <summary>AngleNotch 用：目标角度与容差（度）。</summary>
        public float Angle;
        public float AngleTolerance = 18f;

        /// <summary>GridCell 的预判比例（±0.35 格宽），其余形状靠 Rect 自身外扩。</summary>
        public float PredictRatio = 0.35f;

        /// <summary>自定义接受条件；给了它就不再看 AcceptId。</summary>
        public Func<CarryHandle, bool> Accept;

        public bool Contains(Vector2 point)
        {
            switch (Shape)
            {
                case DropShape.Circle:
                    return (point - Center).sqrMagnitude <= Radius * Radius;

                case DropShape.GridCell:
                {
                    var pad = Mathf.Min(Rect.width, Rect.height) * PredictRatio;
                    var grown = new Rect(Rect.xMin - pad, Rect.yMin - pad,
                        Rect.width + pad * 2f, Rect.height + pad * 2f);
                    return grown.Contains(point);
                }

                case DropShape.AngleNotch:
                    // 角度档不看位置（位置由携带物自己贴着物件走），恒为 true，
                    // 真正的判定在 Matches 里做。
                    return true;

                default:
                    return Rect.Contains(point);
            }
        }

        /// <summary>是否接受这个携带物落在 point。先过形状，再过谓词 / id。</summary>
        public bool Accepts(CarryHandle handle, Vector2 point)
        {
            if (!Contains(point)) return false;
            if (Shape == DropShape.AngleNotch)
            {
                var delta = Mathf.DeltaAngle(handle != null ? handle.Tilt : 0f, Angle);
                if (Mathf.Abs(delta) > AngleTolerance) return false;
            }
            if (Accept != null) return Accept(handle);
            if (string.IsNullOrEmpty(AcceptId)) return true;
            var carried = handle != null ? handle.Id : null;
            return carried == AcceptId;
        }

        /// <summary>从 UI 矩形建落点。anchor 左上、pivot 左上的元素可以直接给。</summary>
        public static DropTarget FromRect(RectTransform rect, RectTransform area, string id, DropShape shape)
        {
            var target = new DropTarget { Id = id, Shape = shape };
            if (rect == null || area == null) return target;
            var center = (Vector2)area.InverseTransformPoint(rect.TransformPoint(rect.rect.center));
            var size = rect.rect.size;
            target.Rect = new Rect(center.x - size.x * 0.5f, center.y - size.y * 0.5f, size.x, size.y);
            target.Center = center;
            target.Radius = Mathf.Min(size.x, size.y) * 0.5f;
            return target;
        }

        public static DropTarget FromCircle(Vector2 center, float radius, string id)
        {
            return new DropTarget { Id = id, Shape = DropShape.Circle, Center = center, Radius = radius };
        }
    }
}
