using UnityEngine;

namespace EggRescue
{
    public sealed class DialogueTrigger : MonoBehaviour
    {
        public string npcName;
        public int startId;
        /// <summary>
        /// 交互时是否点亮线索 VFX（粉色特效 + 隐藏交互提示）。
        /// 对已接进小游戏的点设为 false：线索是否发现由小游戏完成时决定，
        /// 中途退出不能点亮——否则交互点会提前变成「已发现」状态（用户口径：不完成就不要动）。
        /// </summary>
        [System.NonSerialized] public bool discoverOnInteract = true;

        /// <summary>
        /// 小游戏点的「结果描述」：交互那一刻不播（描述文本本身含结论，提前播会泄露答案），
        /// 由 MiniGameClueTrigger 在本局成功提交后才调用 PlayDeferredDescription 播出（19 文档 §19.3.1）。
        /// 普通描述点保持 false，交互即播、行为不变。
        /// </summary>
        [System.NonSerialized] public bool deferToMiniGame;

        Interactable _interactable;

        void Awake()
        {
            _interactable = GetComponent<Interactable>();
            if (_interactable == null) _interactable = gameObject.AddComponent<Interactable>();
            _interactable.OnInteract += StartDialogue;
        }

        void OnDestroy()
        {
            if (_interactable != null) _interactable.OnInteract -= StartDialogue;
        }

        public void StartDialogue()
        {
            // 小游戏结果描述：交互那一刻不播，等本局成功由钩子调 PlayDeferredDescription。
            if (deferToMiniGame) return;
            if (discoverOnInteract) InteractionPointVfx.DiscoverFrom(gameObject);
            if (!string.IsNullOrEmpty(npcName))
            {
                if (DialogueManager.Instance != null)
                    DialogueManager.Instance.StartNpc(npcName, startId);
                else
                    Debug.LogError("[DialogueTrigger] DialogueManager missing");
                return;
            }
            Debug.LogWarning("[DialogueTrigger] npcName empty on " + name);
        }

        /// <summary>
        /// 由小游戏钩子在本局成功后调用，播出「结果描述」。
        /// 描述文本不含额外逻辑，仅展示；不在交互时播，避免泄露结论。
        /// </summary>
        public void PlayDeferredDescription()
        {
            if (!deferToMiniGame || string.IsNullOrEmpty(npcName)) return;
            if (DialogueManager.Instance != null)
                DialogueManager.Instance.StartNpc(npcName, startId);
        }

        public static bool StartNpcDialogue(string targetNpcName, int startId)
        {
            if (DialogueManager.Instance == null) return false;
            return DialogueManager.Instance.StartNpc(targetNpcName, startId);
        }
    }
}
