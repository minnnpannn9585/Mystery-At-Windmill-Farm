// 物体旋转行为：让一个目标物体绕指定轴匀速旋转。
//
// 作为 SceneObjectManager 的可插拔行为之一（实现 ISceneObjectBehaviour）。
// 挂到 SceneObjectManager 的任意子节点上，引用要旋转的目标 Transform 即可。
//
// 控制项：
//   - 速度 degreesPerSecond：每秒转过的角度（负值反向）。
//   - 轴向 rotationAxis：绕哪根轴转（通常风车扇叶绕本地 Z 或 X 轴，视模型而定）。
//   - 空间 space：本地轴（Self）还是世界轴（World）。
//
// 用法（风车扇叶）：
//   把本组件挂到 SceneObjectManager 下，target 指向场景里的 SM_WindMillCore 节点，
//   轴向按风车扇叶实际朝向设成其「向前」轴（一般 Z），速度给个正值即可看到转动。
using UnityEngine;

namespace WindmillFarm.Scheduling
{
    [DisallowMultipleComponent]
    public sealed class RotateObject : MonoBehaviour, ISceneObjectBehaviour
    {
        [Header("目标")]
        [Tooltip("要旋转的目标物体。留空则旋转本组件所在物体。")]
        [SerializeField] Transform target;

        [Header("旋转参数")]
        [Tooltip("每秒转过的角度（度）。负值为反向旋转。")]
        [SerializeField] float degreesPerSecond = 30f;

        [Tooltip("绕哪根轴旋转。风车扇叶通常是其「向前」轴（本地 Z）。")]
        [SerializeField] Vector3 rotationAxis = Vector3.forward;

        [Tooltip("旋转空间：Self = 绕目标自身坐标轴，World = 绕世界坐标轴。")]
        [SerializeField] Space space = Space.Self;

        [Header("开关")]
        [Tooltip("是否启用旋转。")]
        [SerializeField] bool enabled = true;

        /// <summary>实际旋转的目标（target 为空时退回本物体）。</summary>
        Transform Target => target != null ? target : transform;

        /// <summary>是否启用（供管理器 tick 判断）。</summary>
        public bool IsActive => enabled && isActiveAndEnabled;

        /// <summary>运行期读写：每秒角度（度）。</summary>
        public float DegreesPerSecond
        {
            get => degreesPerSecond;
            set => degreesPerSecond = value;
        }

        /// <summary>运行期读写：旋转轴。负向量等于反向。</summary>
        public Vector3 RotationAxis
        {
            get => rotationAxis;
            set => rotationAxis = value;
        }

        /// <summary>运行期启停。</summary>
        public void SetEnabled(bool value) => enabled = value;

        public void Tick(float deltaTime)
        {
            if (Target == null) return;

            float step = degreesPerSecond * deltaTime;
            if (Mathf.Approximately(step, 0f)) return;

            Target.Rotate(rotationAxis, step, space);
        }
    }
}
