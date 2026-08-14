using UnityEngine;

namespace EggRescue
{
    public sealed class ClueTrigger : MonoBehaviour
    {
        public string varName1;
        public string varType1 = "bool";
        public bool varValue1 = true;
        public int varIntValue1;
        public bool varIsAdd1;

        public string varName2;
        public string varType2 = "bool";
        public bool varValue2 = true;
        public int varIntValue2;
        public bool varIsAdd2;

        Interactable _interactable;

        void Awake()
        {
            _interactable = GetComponent<Interactable>();
            if (_interactable == null) _interactable = gameObject.AddComponent<Interactable>();
            _interactable.OnInteract += SetClue;
        }

        void OnDestroy()
        {
            if (_interactable != null) _interactable.OnInteract -= SetClue;
        }

        public void SetClue()
        {
            SetVariable(varName1, varType1, varValue1, varIntValue1, varIsAdd1);
            SetVariable(varName2, varType2, varValue2, varIntValue2, varIsAdd2);
            InteractionPointVfx.DiscoverFrom(gameObject);
        }

        static void SetVariable(string name, string type, bool boolValue, int intValue, bool isAdd)
        {
            if (string.IsNullOrEmpty(name)) return;
            var detected = GameState.Has(name) ? GameState.GetVarType(name) : (type == "int" ? VarType.Int : VarType.Bool);
            if (detected == VarType.Int)
            {
                var finalValue = intValue;
                if (isAdd) finalValue = GameState.GetInt(name) + intValue;
                GameState.SetInt(name, finalValue);
            }
            else
            {
                GameState.SetBool(name, boolValue);
            }
        }
    }
}
