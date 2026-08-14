using UnityEngine;

namespace EggRescue
{
    public sealed class DialogueAreaTrigger : MonoBehaviour
    {
        public string npcName;
        public int startNodeId = 1;
        public string requireVarName;
        public bool requireVarMustBe = true;
        public string blockVarName;
        public bool blockWhenTrue = true;
        public bool disableColliderAfterFire = true;
        public bool skipIfDialogueActive = true;

        bool _fired;
        bool _playerInside;

        void Update()
        {
            if (_fired || !_playerInside) return;
            TryFire();
        }

        void OnTriggerEnter(Collider other)
        {
            if (!InteractionUtil.IsLocalPlayer(other)) return;
            _playerInside = true;
            TryFire();
        }

        void OnTriggerExit(Collider other)
        {
            if (!InteractionUtil.IsLocalPlayer(other)) return;
            _playerInside = false;
        }

        void TryFire()
        {
            if (_fired) return;
            if (skipIfDialogueActive && GameEvents.DialogueActive) return;
            if (!ConditionsMet()) return;
            _fired = true;
            if (disableColliderAfterFire)
            {
                var col = GetComponent<Collider>();
                if (col != null) col.enabled = false;
            }
            DialogueTrigger.StartNpcDialogue(npcName, startNodeId);
        }

        bool ConditionsMet()
        {
            if (!string.IsNullOrEmpty(requireVarName))
            {
                if (GameState.GetBool(requireVarName) != requireVarMustBe)
                    return false;
            }
            if (!string.IsNullOrEmpty(blockVarName))
            {
                var blocked = GameState.GetBool(blockVarName);
                if (blockWhenTrue && blocked) return false;
                if (!blockWhenTrue && !blocked) return false;
            }
            return true;
        }
    }
}
