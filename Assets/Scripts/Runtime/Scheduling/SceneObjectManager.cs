// 场景物体调度管理器（SceneObjectManager）。
//
// 职责：作为场景里唯一的「调度中枢」，统一驱动挂载在本物体上的各种
// 物体调度/变化/动画行为（旋转、浮动、缩放、开关显示、材质切换等）。
//
// 设计原则：
// 1. 管理器本身不写死任何具体行为 —— 它只负责在 Update 里遍历并 tick
//    所有实现了 ISceneObjectBehaviour 接口的行为组件。
// 2. 每个具体行为（如风车旋转）是一个独立、可复用的组件，挂在本物体下
//    的任意子节点上即可。想加新行为 = 新增一个实现该接口的组件，不动管理器。
// 3. 支持编辑态预览（ExecuteAlways），在场景里调参能立刻看到效果。
//
// 用法：
//   - 在场景里创建一个空物体，命名 SceneObjectManager，挂本脚本。
//   - 在其子节点（或任意位置）挂具体行为组件，本管理器会自动收集并驱动。
//
// 注意：为避免与其它 Manager 的 Update 顺序耦合，本类不依赖任何框架，
// 仅用标准 MonoBehaviour 生命周期。
using System;
using System.Collections.Generic;
using UnityEngine;

namespace WindmillFarm.Scheduling
{
    /// <summary>
    /// 所有可被 SceneObjectManager 调度的行为都必须实现此接口。
    /// 管理器在 Update 里对每个行为调用一次 Tick(deltaTime)。
    /// </summary>
    public interface ISceneObjectBehaviour
    {
        /// <summary>该行为当前是否启用（由组件自身或外部控制）。</summary>
        bool IsActive { get; }

        /// <summary>每帧推进。deltaTime 为未缩放时间（Time.deltaTime）。</summary>
        void Tick(float deltaTime);
    }

    /// <summary>
    /// 场景物体调度管理器。挂到场景里的 SceneObjectManager 物体上。
    /// </summary>
    [ExecuteAlways]
    [DisallowMultipleComponent]
    public sealed class SceneObjectManager : MonoBehaviour
    {
        [Header("调度")]
        [Tooltip("是否整体暂停所有被调度的行为。关闭后所有行为停止推进，但保留当前状态。")]
        [SerializeField] bool paused = false;

        [Tooltip("是否使用未缩放时间（Time.unscaledDeltaTime）。勾选后游戏暂停（timeScale=0）时行为仍会推进，适合 UI 或菜单装饰。")]
        [SerializeField] bool useUnscaledTime = false;

        /// <summary>当前被收集到的行为列表（每帧刷新，防止子物体增删后失效）。</summary>
        readonly List<ISceneObjectBehaviour> behaviours = new List<ISceneObjectBehaviour>();

        /// <summary>整体暂停开关，运行期可读写。</summary>
        public bool Paused
        {
            get => paused;
            set => paused = value;
        }

        void Update()
        {
            if (paused) return;

            float dt = useUnscaledTime ? Time.unscaledDeltaTime : Time.deltaTime;
            if (dt <= 0f) return;

            // 每帧重新收集：支持编辑器里动态增删行为组件/子物体。
            CollectBehaviours();

            for (int i = 0; i < behaviours.Count; i++)
            {
                var b = behaviours[i];
                if (b == null || !b.IsActive) continue;
                b.Tick(dt);
            }
        }

        void CollectBehaviours()
        {
            behaviours.Clear();
            // 收集本物体及其所有子物体上的行为组件。
            GetComponentsInChildren<ISceneObjectBehaviour>(true, behaviours);
        }
    }
}
