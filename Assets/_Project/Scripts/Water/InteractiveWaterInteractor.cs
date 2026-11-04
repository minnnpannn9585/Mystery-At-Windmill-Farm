using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 把自身世界坐标 / 半径写入全局 shader 变量，供 Custom/StylizedInteractiveWater 做剪裁。
    /// 对应原教程中负责 Shader.SetGlobalVector 的 C# 脚本。
    /// 全局量同一时刻只描述一个交互体；场景内多个交互体请用 InteractiveWaterGroup 调度。
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public class InteractiveWaterInteractor : MonoBehaviour
    {
        [Tooltip("球形剪裁半径")]
        public float radius = 1.0f;

        [Tooltip("向下延伸条带的半径（洞下方继续挖空的宽度）")]
        public float topDownRadius = 1.0f;

        [Tooltip("条带向下延伸长度；<= 0 表示一直延伸到底")]
        public float tailLength = 0f;

        [Tooltip("关掉后水面不再被挖洞")]
        public bool enableInteraction = true;

        static readonly int PositionId = Shader.PropertyToID("_IW_ObjectPosition");
        static readonly int ParamsId   = Shader.PropertyToID("_IW_Params");

        void OnEnable()  { Push(); }
        void OnValidate(){ Push(); }
        void Update()    { Push(); }

        void OnDisable()
        {
            // 被关闭时立刻清掉，避免残留挖洞
            Shader.SetGlobalVector(ParamsId, Vector4.zero);
        }

        /// <summary>立即上报一次，供外部（如生成器脚本）在编辑器非运行态下强制刷新。</summary>
        public void Push()
        {
            Shader.SetGlobalVector(PositionId, transform.position);
            Shader.SetGlobalVector(ParamsId, new Vector4(
                Mathf.Max(radius, 0.0001f),
                Mathf.Max(topDownRadius, 0.0001f),
                tailLength,
                (enableInteraction && isActiveAndEnabled) ? 1f : 0f));
        }

        void OnDrawGizmosSelected()
        {
            Gizmos.color = new Color(0.4f, 0.9f, 1f, 0.8f);
            Gizmos.DrawWireSphere(transform.position, radius);

            Gizmos.color = new Color(1f, 0.6f, 0.2f, 0.5f);
            Vector3 a = transform.position + Vector3.down * (tailLength > 0f ? tailLength : 50f);
            Gizmos.DrawWireCube(
                new Vector3(transform.position.x, (transform.position.y + a.y) * 0.5f, transform.position.z),
                new Vector3(topDownRadius * 2f, Mathf.Abs(a.y - transform.position.y), topDownRadius * 2f));
        }
    }
}
