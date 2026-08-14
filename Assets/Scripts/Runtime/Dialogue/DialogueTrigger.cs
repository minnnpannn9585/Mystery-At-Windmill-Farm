using UnityEngine;

namespace EggRescue
{
    public sealed class DialogueTrigger : MonoBehaviour
    {
        public string npcName;
        public int startId;

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
            InteractionPointVfx.DiscoverFrom(gameObject);
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

        public static bool StartNpcDialogue(string targetNpcName, int startId)
        {
            if (DialogueManager.Instance == null) return false;
            return DialogueManager.Instance.StartNpc(targetNpcName, startId);
        }
    }
}
