using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 上宽下窄的梯形面板（P5 那种不规则 UI 切片）。
    /// 直接按 RectTransform 的 rect 生成 mesh，不依赖九宫格 sprite——
    /// 一旦套回 Sliced Image，四角会被拉回矩形，斜边就没了。
    ///
    /// 顶边满宽，底边左右各按 inset 比例内收。便签本身是「左边垂直、右边向左倾」，
    /// 所以默认 LeftInset=0 / RightInset>0，斜边方向与美术便签一致。
    /// 颜色走 Graphic.color，随模板便签色加深即可保持色调统一。
    /// </summary>
    public sealed class TrapezoidGraphic : MaskableGraphic
    {
        [Range(0f, 0.5f)] public float LeftInset = 0f;
        [Range(0f, 0.5f)] public float RightInset = 0.14f;

        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();
            var r = GetPixelAdjustedRect();
            var w = Mathf.Max(0f, r.width);
            var bl = r.xMin + w * Mathf.Clamp01(LeftInset);
            var br = r.xMax - w * Mathf.Clamp01(RightInset);

            var v = UIVertex.simpleVert;
            v.color = color;

            v.position = new Vector3(r.xMin, r.yMax);
            v.uv0 = new Vector2(0f, 1f);
            vh.AddVert(v);                                   // 0 顶左

            v.position = new Vector3(r.xMax, r.yMax);
            v.uv0 = new Vector2(1f, 1f);
            vh.AddVert(v);                                   // 1 顶右

            v.position = new Vector3(br, r.yMin);
            v.uv0 = new Vector2(1f, 0f);
            vh.AddVert(v);                                   // 2 底右（内收）

            v.position = new Vector3(bl, r.yMin);
            v.uv0 = new Vector2(0f, 0f);
            vh.AddVert(v);                                   // 3 底左（内收）

            vh.AddTriangle(0, 1, 2);
            vh.AddTriangle(0, 2, 3);
        }
    }
}
