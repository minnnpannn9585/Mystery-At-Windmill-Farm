// 天空云场：所有云朵的父物体，提供"出生点"，并把球心（固定坐标）下发给 shader。
//
// 球心：显式坐标 skyCenter，或勾选 useSelfAsCenter 用本物体位置。整个云系统
// 绕这个固定点做球面弯曲，不跟随相机。
//
// 为什么要把球心下发给 shader：CloudCard.shader 需要以球心为原点把卡片顶点
// 投到天球面上做弧度。这里用全局属性 _SkyCenter，所有材质共用一份，零额外开销。
//
// 注意：根物体请保持 scale=1、不旋转——云朵的 distance/azimuth/height 都是
// 按"父物体位置 + 世界 Y 轴"算的。安装菜单建出来的根物体满足这个条件。
using UnityEngine;

namespace WindmillFarm.Visual
{
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public sealed class SkyCloudField : MonoBehaviour
    {
        static readonly int SkyCenterId = Shader.PropertyToID("_SkyCenter");

        [Tooltip("球心坐标（世界空间）。整个云系统绕这个点做球面弯曲")]
        public Vector3 skyCenter = Vector3.zero;

        [Tooltip("用本物体（天空云根节点）的位置作为球心。勾选后忽略上面的坐标")]
        public bool useSelfAsCenter = true;

        void Update()
        {
            // 球心：优先用本物体位置，否则用显式坐标。编辑态也要下发，
            // 否则在场景里摆机位时弧度是错的。
            var c = useSelfAsCenter ? transform.position : skyCenter;
            Shader.SetGlobalVector(SkyCenterId, new Vector4(c.x, c.y, c.z, 0f));
        }

        void OnDrawGizmosSelected()
        {
            // 画出球心参考：一个小十字（黄色）+ 球面示意（青）
            var c = useSelfAsCenter ? transform.position : skyCenter;
            const float s = 8f;
            Gizmos.color = new Color(1f, 0.9f, 0.5f, 0.9f);
            Gizmos.DrawLine(c - Vector3.right * s, c + Vector3.right * s);
            Gizmos.DrawLine(c - Vector3.forward * s, c + Vector3.forward * s);
            Gizmos.DrawLine(c - Vector3.up * s, c + Vector3.up * s);
        }
    }
}
