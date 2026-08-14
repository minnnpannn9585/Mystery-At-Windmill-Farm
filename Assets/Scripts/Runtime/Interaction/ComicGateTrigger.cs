using UnityEngine;

namespace EggRescue
{
    public sealed class ComicGateTrigger : MonoBehaviour
    {
        Interactable _interactable;

        void Awake()
        {
            _interactable = GetComponent<Interactable>();
            if (_interactable == null) _interactable = gameObject.AddComponent<Interactable>();
            _interactable.OnInteract += OnComicInteract;
        }

        public void OnComicInteract()
        {
            if (GameState.GetBool("Comic_Revealed")) return;
            ClimbPathPoint.Advance("roof", 2);
            GameState.SetBool("Comic_Revealed", true);
            var ending = FindObjectOfType<EndingController>(true);
            if (ending != null)
            {
                if (!ending.gameObject.activeSelf) ending.gameObject.SetActive(true);
                ending.StartEnding();
            }
            else Debug.LogError("[ComicGate] EndingController missing");
        }
    }
}
