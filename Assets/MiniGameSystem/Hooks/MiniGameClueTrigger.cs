using UnityEngine;

namespace EggRescue.MiniGame.Hooks
{
    /// <summary>
    /// 环境物证入口（T1–T6 用）。挂了它就别再挂 ClueTrigger，二选一。
    ///
    /// defId 留空时自行禁用，把现场让给原来的 ClueTrigger —— 
    /// 这样「改造清单」可以一个点一个点地换，不用一次全换（§16.3）。
    /// </summary>
    [DisallowMultipleComponent]
    public sealed class MiniGameClueTrigger : MonoBehaviour
    {
        [Tooltip("MiniGameRegistry 里的局 id，例如 Q11")]
        public string defId;

        [Tooltip("完成后是否点亮这个交互点的调查 VFX")]
        public bool discoverPoint = true;

        Interactable _interactable;

        void Awake()
        {
            if (string.IsNullOrEmpty(defId))
            {
                Debug.Log("[MiniGame] " + name + " 未配 defId，回落到原 ClueTrigger 行为", this);
                enabled = false;
                return;
            }
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
            if (MiniGameHost.IsOpen) return;

            var def = MiniGameRegistry.Get(defId);
            if (def == null)
            {
                Debug.LogError("[MiniGame] " + name + " 的 defId 不存在: " + defId, this);
                return;
            }

            // 已经做过：不再开游戏，直接补点亮（重复进入不发第二次线索，§15.4）
            if (MiniGameHost.IsSubmitted(def))
            {
                if (discoverPoint) InteractionPointVfx.DiscoverFrom(gameObject);
                return;
            }

            MiniGameHost.Open(def, OnReturn);
        }

        void OnReturn()
        {
            var def = MiniGameRegistry.Get(defId);
            if (discoverPoint && def != null && MiniGameHost.IsSubmitted(def))
                InteractionPointVfx.DiscoverFrom(gameObject);
        }
    }
}
