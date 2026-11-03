using UnityEngine;

namespace EggRescue.MiniGame.Hooks
{
    /// <summary>
    /// 证词局入口（T7 用）。走方案 B：对话末节点 Next=-1，本组件轮询
    /// DialogueManager.IsDialogueActive 由真变假的那一刻开一局，关掉后可选跳回 hub。
    ///
    /// 已知限制（M2 要补）：对话系统目前没有「本段对话属于谁」的回调，
    /// 所以同一时刻只应该有一个 Hook 处于待命状态。若要同时挂多个，
    /// 需要 DialogueManager 在 EndDialogue 时广播 NPC 名（§16.2 方案 A 的内容）。
    /// </summary>
    [DisallowMultipleComponent]
    public sealed class MiniGameDialogueHook : MonoBehaviour
    {
        [Tooltip("MiniGameRegistry 里的局 id，例如 Q01")]
        public string defId;

        [Tooltip("可选：对话结束后跳回的 hub 节点 id，-1 表示不跳")]
        public int hubNodeId = -1;

        [Tooltip("完成后是否还跳 hub；关掉就只留在原地")]
        public bool jumpToHubOnClose = true;

        bool _seenActive;
        bool _fired;

        void Update()
        {
            if (string.IsNullOrEmpty(defId) || _fired) return;
            var dm = DialogueManager.Instance;
            if (dm == null) return;

            if (dm.IsDialogueActive)
            {
                _seenActive = true;
                return;
            }
            if (!_seenActive) return;

            // 对话刚结束
            _seenActive = false;
            _fired = true;

            var def = MiniGameRegistry.Get(defId);
            if (def == null)
            {
                Debug.LogError("[MiniGame] " + name + " 的 defId 不存在: " + defId, this);
                return;
            }

            if (MiniGameHost.IsSubmitted(def))
            {
                JumpToHub();
                return;
            }

            MiniGameHost.Open(def, () =>
            {
                if (jumpToHubOnClose) JumpToHub();
            });
        }

        void JumpToHub()
        {
            if (hubNodeId < 0 || !jumpToHubOnClose) return;
            var dm = DialogueManager.Instance;
            if (dm != null) dm.JumpToNode(hubNodeId);
        }

        /// <summary>允许外部在重新播下一段对话前复位。</summary>
        public void Rearm()
        {
            _fired = false;
            _seenActive = false;
        }
    }
}
