using UnityEngine;

namespace EggRescue.MiniGame.Hooks
{
    /// <summary>
    /// 环境物证入口（T1–T6 用）。挂了它就别再挂 ClueTrigger，二选一。
    ///
    /// defId 留空时交互静默无动作，把现场让给原来的 ClueTrigger —— 
    /// 这样「改造清单」可以一个点一个点地换，不用一次全换（§16.3）。
    /// 注意：不能在 Awake 里因 defId 空就 enabled=false —— 运行时批量接线（WireMiniGameClue）
    /// 是 AddComponent 之后才设 defId 的，Awake 时还是空；若那时禁用，之后再设 defId 也不再生效
    /// （表现为「钩子 enabled=false、点了没反应」）。所以改为 HandleInteract 里判空静默返回。
    /// </summary>
    [DisallowMultipleComponent]
    public sealed class MiniGameClueTrigger : MonoBehaviour
    {
        [Tooltip("MiniGameRegistry 里的局 id，例如 Q11")]
        public string defId;

        [Tooltip("完成后是否点亮这个交互点的调查 VFX")]
        public bool discoverPoint = true;

        Interactable _interactable;
        EggRescue.DialogueTrigger _description;

        void Awake()
        {
            // 本点若挂了「结果描述」，查出缓存：本局成功后才播它，交互瞬间绝不播。
            _description = GetComponent<EggRescue.DialogueTrigger>();
            // 无条件订阅：defId 允许在 AddComponent 之后才被接线代码填入（WireMiniGameClue）。
            _interactable = GetComponent<Interactable>();
            if (_interactable == null) _interactable = gameObject.AddComponent<Interactable>();
            _interactable.OnInteract += HandleInteract;
        }

        void OnDestroy()
        {
            if (_interactable != null) _interactable.OnInteract -= HandleInteract;
        }

        void HandleInteract()
        {
            // defId 空 = 未接进小游戏，静默让位给原 ClueTrigger（不报错、不禁用组件）。
            if (string.IsNullOrEmpty(defId) || MiniGameHost.IsOpen) return;

            var def = MiniGameRegistry.Get(defId);
            if (def == null)
            {
                Debug.LogError("[MiniGame] " + name + " 的 defId 不存在: " + defId, this);
                return;
            }

            // 已经做过：不再开游戏，补点亮 + 重播结果描述（重复进入不发第二次线索，§15.4）
            if (MiniGameHost.IsSubmitted(def))
            {
                if (discoverPoint) InteractionPointVfx.DiscoverFrom(gameObject);
                PlayResultDescription();
                return;
            }

            MiniGameHost.Open(def, OnReturn);
        }

        void OnReturn()
        {
            var def = MiniGameRegistry.Get(defId);
            if (def == null || !MiniGameHost.IsSubmitted(def)) return;   // 中途退出：什么都不播、不点亮
            if (discoverPoint) InteractionPointVfx.DiscoverFrom(gameObject);
            PlayResultDescription();   // 成功才播结果描述
        }

        /// <summary>本局成功后播出「结果描述」（描述文本含结论，交互瞬间不能播）。</summary>
        void PlayResultDescription()
        {
            if (_description == null) _description = GetComponent<EggRescue.DialogueTrigger>();
            if (_description != null) _description.PlayDeferredDescription();
        }
    }
}
