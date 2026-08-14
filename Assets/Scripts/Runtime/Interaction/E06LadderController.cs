using UnityEngine;

namespace EggRescue
{
    public sealed class E06LadderController : MonoBehaviour
    {
        public GameObject barnLadder;
        public GameObject e06PlacedLadder;
        public int discoveryDialogueId = 8;
        public int placedDialogueId = 31;
        public string textDiscover = "这里上面有个通道";
        public string textPlaceLadder = "摆放梯子";

        const string PointName = "E06 · 发现缺少梯子";
        const string PlacedChild = "E06_placed_ladder";

        bool? _lastBarn;
        bool? _lastPlaced;
        bool? _lastInteract;
        Interactable _interactable;

        bool IsE06Point { get { return gameObject.name == PointName; } }

        void Awake()
        {
            _interactable = GetComponent<Interactable>();
            if (_interactable == null) _interactable = gameObject.AddComponent<Interactable>();
            _interactable.OnInteract += OnE06Interact;
        }

        void Start()
        {
            var ladder = ResolveBarnLadder();
            if (ladder != null)
            {
                if (ladder.transform.parent != null && ladder.transform.parent.name == "dogdrunkp" && ladder.transform.parent.parent != null)
                    ladder.transform.SetParent(ladder.transform.parent.parent, true);
                barnLadder = ladder;
            }
            if (IsE06Point)
            {
                var placed = ResolvePlaced();
                if (placed != null && placed != ladder) placed.SetActive(false);
            }
            Refresh(true);
        }

        void Update() { Refresh(false); }

        void Refresh(bool force)
        {
            var borrowed = GameState.GetBool("E06_LadderBorrowed");
            var placed = GameState.GetBool("E06_LadderPlaced");
            var dogStatus = GameState.GetInt("DogStatus", 1);
            var barnGo = ResolveBarnLadder();
            var showBarn = !borrowed && dogStatus < 4;
            if (barnGo != null && (force || _lastBarn != showBarn))
            {
                _lastBarn = showBarn;
                barnGo.SetActive(showBarn);
            }
            if (!IsE06Point) return;
            var placedGo = ResolvePlaced();
            if (placedGo != null && placedGo != barnGo && (force || _lastPlaced != placed))
            {
                _lastPlaced = placed;
                placedGo.SetActive(placed);
            }
            bool enabled;
            string label;
            ComputeInteract(out enabled, out label);
            if (force || _lastInteract != enabled)
            {
                _lastInteract = enabled;
                InteractionUtil.SetCollidersEnabled(gameObject, enabled);
                if (_interactable != null) _interactable.SetInteractionEnabled(enabled);
            }
            if (enabled && !string.IsNullOrEmpty(label) && _interactable != null)
                _interactable.Prompt = label;
        }

        void ComputeInteract(out bool enabled, out string label)
        {
            var borrowed = GameState.GetBool("E06_LadderBorrowed");
            var placed = GameState.GetBool("E06_LadderPlaced");
            var viewNeed = GameState.GetBool("E06_ViewNeedLadder");
            if (placed) { enabled = false; label = null; return; }
            if (borrowed) { enabled = true; label = textPlaceLadder; return; }
            if (!viewNeed) { enabled = true; label = textDiscover; return; }
            enabled = false;
            label = null;
        }

        void OnE06Interact()
        {
            if (GameState.GetBool("E06_LadderPlaced")) return;
            if (GameState.GetBool("E06_LadderBorrowed"))
            {
                PlaceLadder();
                return;
            }
            if (!GameState.GetBool("E06_ViewNeedLadder"))
            {
                GameState.SetBool("E06_ViewNeedLadder", true);
                InteractionPointVfx.DiscoverFrom(gameObject);
                StartMiaosu(discoveryDialogueId);
                Refresh(true);
            }
        }

        void PlaceLadder()
        {
            if (!GameState.GetBool("E06_LadderBorrowed") || GameState.GetBool("E06_LadderPlaced")) return;
            GameState.SetBool("E06_LadderPlaced", true);
            Refresh(true);
            ClimbPathPoint.Refresh("barn");
            StartMiaosu(placedDialogueId);
        }

        void StartMiaosu(int id)
        {
            var graph = DialogueDatabase.Get("miaosu");
            if (graph == null || DialogueManager.Instance == null) return;
            DialogueManager.Instance.StartWithData(graph, id);
        }

        GameObject ResolveBarnLadder()
        {
            if (barnLadder != null) return barnLadder;
            var dh = GameObject.Find("大黄");
            if (dh != null)
            {
                var t = dh.transform.Find("pingmuti") ?? dh.transform.Find("dogdrunkp/pingmuti");
                if (t != null) return t.gameObject;
            }
            return GameObject.Find("pingmuti");
        }

        GameObject ResolvePlaced()
        {
            if (e06PlacedLadder != null) return e06PlacedLadder;
            var child = transform.Find(PlacedChild);
            if (child != null) return child.gameObject;
            return GameObject.Find(PlacedChild);
        }
    }
}
