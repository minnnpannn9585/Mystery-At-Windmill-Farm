using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    public sealed class DialogueManager : MonoBehaviour
    {
        public static DialogueManager Instance { get; private set; }

        [SerializeField] GameObject dialoguePanel;
        [SerializeField] GameObject playerNamePanel;
        [SerializeField] GameObject npcNamePanel;
        [SerializeField] Text npcName;
        [SerializeField] Image npcSprite;
        [SerializeField] Image playerSprite;
        [SerializeField] GameObject playerExclamation;
        [SerializeField] GameObject playerQuestion;
        [SerializeField] Text npcDialogueText;
        [SerializeField] Button next;
        [SerializeField] GameObject playerPanel;
        [SerializeField] Button playerPanelBtn;
        [SerializeField] Sprite[] portraitSprites;
        [SerializeField] string[] portraitKeys;

        const float TypingSpeed = 0.05f;
        const float OptionAnimSpeed = 0.2f;

        int _currentId = -1;
        DialogueGraph _graph;
        DialogueNode _current;
        bool _waitingChoice;
        bool _typing;
        float _typingTimer;
        int _typingIndex;
        string _fullText = "";
        bool _animatingOptions;
        float _optionAnimTimer;
        int _optionAnimIndex;
        DialogueOption _selectedOption;
        bool _waitingNextAfterOption;
        readonly HashSet<string> _unlockedCache = new HashSet<string>();
        string _lastPortraitKey;
        readonly List<DialogueOption> _options = new List<DialogueOption>();
        readonly List<GameObject> _optionButtons = new List<GameObject>();
        readonly Dictionary<string, Sprite> _portraits = new Dictionary<string, Sprite>();
        static readonly HashSet<string> PlayerPortraitKeys = new HashSet<string> { "正常", "惊讶", "疑惑" };


        public bool IsDialogueActive
        {
            get { return _currentId >= 0 || (dialoguePanel != null && dialoguePanel.activeSelf); }
        }

        void Awake()
        {
            Instance = this;
            BindMissingUi();
            RebuildPortraitMap();
            if (dialoguePanel != null) dialoguePanel.SetActive(false);
            if (playerPanel != null) playerPanel.SetActive(false);
            if (playerNamePanel != null) playerNamePanel.SetActive(false);
            if (next != null)
            {
                next.onClick.AddListener(OnNextClick);
                next.gameObject.SetActive(false);
            }
            if (dialoguePanel != null)
            {
                var btn = dialoguePanel.GetComponent<Button>();
                if (btn == null) btn = dialoguePanel.AddComponent<Button>();
                btn.onClick.AddListener(OnNextClick);
            }
            if (playerPanelBtn != null) playerPanelBtn.gameObject.SetActive(false);
        }

        public void BindUi(
            GameObject panel, GameObject playerName, GameObject npcNameGo, Text nameLabel,
            Image npcImg, Image playerImg, GameObject exclaim, GameObject question,
            Text body, Button nextBtn, GameObject optionRoot, Button optionTemplate)
        {
            dialoguePanel = panel;
            playerNamePanel = playerName;
            npcNamePanel = npcNameGo;
            npcName = nameLabel;
            npcSprite = npcImg;
            playerSprite = playerImg;
            playerExclamation = exclaim;
            playerQuestion = question;
            npcDialogueText = body;
            next = nextBtn;
            playerPanel = optionRoot;
            playerPanelBtn = optionTemplate;
        }

        public void SetPortraits(string[] keys, Sprite[] sprites)
        {
            portraitKeys = keys;
            portraitSprites = sprites;
            RebuildPortraitMap();
        }

        void RebuildPortraitMap()
        {
            _portraits.Clear();
            if (portraitKeys == null || portraitSprites == null) return;
            var n = Mathf.Min(portraitKeys.Length, portraitSprites.Length);
            for (var i = 0; i < n; i++)
            {
                if (!string.IsNullOrEmpty(portraitKeys[i]) && portraitSprites[i] != null)
                    _portraits[portraitKeys[i]] = portraitSprites[i];
            }
        }

        public bool StartNpc(string npcNameKey, int startId)
        {
            var graph = DialogueDatabase.LoadNpc(npcNameKey);
            if (graph == null) return false;
            StartWithData(graph, startId);
            return true;
        }

        public void StartWithData(DialogueGraph graph, int startId)
        {
            _graph = graph;
            _lastPortraitKey = null;
            HideAllPortraits();
            SetPlayerNamePanel(false);
            var actual = startId;
            if (GetNode(actual) == null)
            {
                foreach (var kv in graph.Nodes)
                {
                    actual = kv.Key;
                    break;
                }
            }
            if (GetNode(actual) == null) return;
            _currentId = actual;
            if (dialoguePanel != null) dialoguePanel.SetActive(true);
            GameEvents.RaiseDialogueStarted();
            AudioDirector.PlayAudio("audio_hello");
            UpdateDialogueUi();
        }

        public bool JumpToNode(int nodeId)
        {
            if (GetNode(nodeId) == null) return false;
            _waitingChoice = false;
            _waitingNextAfterOption = false;
            _selectedOption = null;
            _typing = false;
            _animatingOptions = false;
            SetPlayerNamePanel(false);
            _currentId = nodeId;
            if (dialoguePanel != null) dialoguePanel.SetActive(true);
            GameEvents.RaiseDialogueStarted();
            UpdateDialogueUi();
            return true;
        }

        DialogueNode GetNode(int id)
        {
            return _graph != null ? _graph.Get(id) : null;
        }

        void OnNextClick()
        {
            if (_animatingOptions) { CompleteOptionAnimation(); return; }
            if (_waitingChoice) return;
            if (_typing) { CompleteTyping(); return; }
            if (_waitingNextAfterOption && _selectedOption != null)
            {
                var opt = _selectedOption;
                _selectedOption = null;
                _waitingNextAfterOption = false;
                PerformOptionJump(opt, false);
                return;
            }
            var data = GetNode(_currentId);
            if (data == null) { EndDialogue(); return; }
            var nextId = ConditionEvaluator.NextFromBranches(data.ConditionBranches);
            if (!nextId.HasValue) nextId = data.Next;
            AdvanceTo(nextId.Value);
        }

        void AdvanceTo(int nextId)
        {
            if (nextId == -1) { EndDialogue(); return; }
            if (GetNode(nextId) == null) { EndDialogue(); return; }
            _currentId = nextId;
            AudioDirector.PlayAudio("audio_nextSentence");
            UpdateDialogueUi();
        }

        void UpdateDialogueUi()
        {
            var guard = 0;
            while (guard++ < 48)
            {
                var data = GetNode(_currentId);
                if (data == null) { EndDialogue(); return; }
                if (data.RotatePool.Count > 0)
                {
                    var pick = Random.Range(0, data.RotatePool.Count);
                    var poolStart = data.RotatePool[pick];
                    if (GetNode(poolStart) != null)
                    {
                        ApplyNodeSideEffects(data);
                        _currentId = poolStart;
                        continue;
                    }
                    break;
                }
                if (string.IsNullOrEmpty(data.Dialogue) && data.Type != "Question")
                {
                    ApplyNodeSideEffects(data);
                    var nextId = ConditionEvaluator.NextFromBranches(data.ConditionBranches);
                    if (!nextId.HasValue) nextId = data.Next;
                    if (nextId.Value == -1) { EndDialogue(); return; }
                    if (GetNode(nextId.Value) == null) { EndDialogue(); return; }
                    _currentId = nextId.Value;
                    continue;
                }
                break;
            }

            _current = GetNode(_currentId);
            if (_current == null) { EndDialogue(); return; }
            ApplyNodeSideEffects(_current);
            if (next != null) next.gameObject.SetActive(false);
            if (playerPanel != null) playerPanel.SetActive(false);
            ClearOptionButtons();
            UpdateNpcInfo(_current);
        }

        void ApplyNodeSideEffects(DialogueNode data)
        {
            UnlockBranches(data);
            ApplySetVariables(data);
        }

        void ApplySetVariables(DialogueNode data)
        {
            if (data == null) return;
            for (var i = 0; i < data.SetVariables.Count; i++)
            {
                var sv = data.SetVariables[i];
                if (string.IsNullOrEmpty(sv.VarName)) continue;
                if (sv.VarType == "int") GameState.SetInt(sv.VarName, ParseInt(sv.Value));
                else GameState.SetBool(sv.VarName, sv.Value == "true" || sv.Value == "1");
            }
        }

        void UnlockBranches(DialogueNode data)
        {
            if (data == null) return;
            for (var i = 0; i < data.UnlockBranches.Count; i++)
            {
                var entry = data.UnlockBranches[i];
                var key = _currentId + "_" + entry.NpcName;
                if (_unlockedCache.Contains(key)) continue;
                NpcRegistry.UnlockBranch(entry.NpcName, entry.BranchId);
                _unlockedCache.Add(key);
            }
            if (data.UnlockBranchId > 0 && !string.IsNullOrEmpty(data.NpcName))
            {
                var key = _currentId + "_" + data.NpcName;
                if (!_unlockedCache.Contains(key))
                {
                    NpcRegistry.UnlockBranch(data.NpcName, data.UnlockBranchId);
                    _unlockedCache.Add(key);
                }
            }
        }

        void UpdateNpcInfo(DialogueNode data)
        {
            var speaker = data.NpcName ?? "";
            var dialogue = data.Dialogue ?? "";
            var display = speaker;
            if (dialogue.StartsWith("（")) display = "描述";
            ApplyNamePanel(display);
            string spriteKey = null;
            if (display == "玩家") spriteKey = ResolvePlayerPortrait(data);
            else
            {
                spriteKey = ResolvePortrait(data);
                if (string.IsNullOrEmpty(spriteKey) && display == "描述")
                    spriteKey = _lastPortraitKey;
            }
            if (!ApplyPortrait(spriteKey, display) && display != "描述" && display != "玩家")
                HideAllPortraits();
            else if (display == "玩家")
                PlayPlayerEmotionSfx(spriteKey);

            if (npcDialogueText == null) return;
            _fullText = data.Dialogue ?? "";
            if (data.Type == "Question" && _fullText.Length == 0)
            {
                if (!string.IsNullOrEmpty(npcDialogueText.text))
                    _fullText = npcDialogueText.text;
                _typing = false;
                npcDialogueText.text = _fullText;
                ShowQuestionUi(data);
            }
            else StartTyping();
        }

        void StartTyping()
        {
            _typing = true;
            _typingTimer = 0f;
            _typingIndex = 0;
            if (npcDialogueText != null) npcDialogueText.text = "";
        }

        void CompleteTyping()
        {
            _typing = false;
            if (npcDialogueText != null) npcDialogueText.text = _fullText;
            if (_waitingNextAfterOption)
            {
                SetPlayerNamePanel(true);
                if (npcName != null) npcName.text = "玩家";
                if (next != null)
                {
                    next.gameObject.SetActive(true);
                    next.interactable = true;
                }
                return;
            }
            if (_current == null) return;
            if (_current.Type == "Question") ShowQuestionUi(_current);
            else ShowNpcConversationUi();
        }

        void ShowNpcConversationUi()
        {
            _waitingChoice = false;
            if (playerPanel != null) playerPanel.SetActive(false);
            ClearOptionButtons();
            ApplyNamePanel(_current != null ? _current.NpcName : null);
            if (next != null)
            {
                next.gameObject.SetActive(true);
                next.interactable = true;
            }
        }

        void ShowQuestionUi(DialogueNode data)
        {
            _waitingChoice = true;
            if (next != null) next.gameObject.SetActive(false);
            if (playerPanel != null) playerPanel.SetActive(true);
            ApplyNamePanel(data != null ? data.NpcName : null);
            _options.Clear();
            if (data != null)
            {
                for (var i = 0; i < data.Options.Count; i++)
                {
                    if (ConditionEvaluator.OptionVisible(data.Options[i]))
                        _options.Add(data.Options[i]);
                }
            }
            ApplyHubCap(data);
            if (_options.Count == 0) { EndDialogue(); return; }
            GenerateOptionButtons();
        }

        void ApplyHubCap(DialogueNode data)
        {
            var cap = 4;
            if (data != null && data.MenuCapSpecified)
            {
                if (data.MenuCap == 0) return;
                cap = data.MenuCap;
            }
            if (_options.Count <= cap) return;
            var capped = new List<DialogueOption> { _options[0], _options[1], _options[2], _options[_options.Count - 1] };
            _options.Clear();
            _options.AddRange(capped);
        }

        void GenerateOptionButtons()
        {
            ClearOptionButtons();
            if (playerPanel == null || playerPanelBtn == null) return;
            var templateRect = playerPanelBtn.GetComponent<RectTransform>();
            var buttonHeight = templateRect != null ? templateRect.rect.height : 80f;
            var total = _options.Count * buttonHeight;
            var startY = total / 2f - buttonHeight / 2f;
            for (var i = 0; i < _options.Count; i++)
            {
                var option = _options[i];
                var go = Instantiate(playerPanelBtn.gameObject, playerPanel.transform);
                go.SetActive(false);
                var label = go.GetComponentInChildren<Text>();
                if (label != null) label.text = option.Text;
                var rect = go.GetComponent<RectTransform>();
                if (rect != null) rect.anchoredPosition = new Vector2(0f, startY - i * buttonHeight);
                var btn = go.GetComponent<Button>();
                if (btn != null)
                {
                    var captured = option;
                    btn.onClick.AddListener(() => OnOptionSelected(captured));
                }
                _optionButtons.Add(go);
            }
            _animatingOptions = true;
            _optionAnimTimer = 0f;
            _optionAnimIndex = 0;
        }

        void CompleteOptionAnimation()
        {
            _animatingOptions = false;
            for (var i = 0; i < _optionButtons.Count; i++)
            {
                if (_optionButtons[i] != null) _optionButtons[i].SetActive(true);
            }
        }

        void ClearOptionButtons()
        {
            for (var i = 0; i < _optionButtons.Count; i++)
            {
                if (_optionButtons[i] != null) Destroy(_optionButtons[i]);
            }
            _optionButtons.Clear();
        }

        void OnOptionSelected(DialogueOption option)
        {
            if (!_waitingChoice) return;
            _waitingChoice = false;
            if (playerPanel != null) playerPanel.SetActive(false);
            ClearOptionButtons();
            if (next != null) next.gameObject.SetActive(false);
            if (IsPlayerFirstAfterOption(option))
            {
                PerformOptionJump(option, true);
                return;
            }
            _selectedOption = option;
            _waitingNextAfterOption = true;
            SetPlayerNamePanel(true);
            if (npcName != null) npcName.text = "玩家";
            _fullText = option.Text;
            var key = ClassifyPlayerPortrait(option.Text);
            ApplyPortrait(key, "玩家");
            PlayPlayerEmotionSfx(key);
            StartTyping();
        }

        void PerformOptionJump(DialogueOption option, bool skipRedundant)
        {
            if (option != null && !string.IsNullOrEmpty(option.ShopAction))
            {
                if (MouseBrotherShop.HandleAction(option.ShopAction, option))
                    return;
            }
            if (option != null && !string.IsNullOrEmpty(option.BranchFlag))
                GameState.SaveBranchFlag(option.BranchFlag);
            var nextId = ResolveOptionNext(option, skipRedundant);
            if (nextId == -1) EndDialogue();
            else if (GetNode(nextId) != null)
            {
                _currentId = nextId;
                UpdateDialogueUi();
            }
            else EndDialogue();
        }

        int GetOptionRawNext(DialogueOption option)
        {
            var branched = ConditionEvaluator.NextFromBranches(option.ConditionBranches);
            return branched.HasValue ? branched.Value : option.Next;
        }

        int ResolveOptionNext(DialogueOption option, bool skipRedundant)
        {
            var nextId = GetOptionRawNext(option);
            if (!skipRedundant) return nextId;
            var guard = 0;
            while (guard++ < 8 && nextId != -1)
            {
                var node = GetNode(nextId);
                if (node != null && node.NpcName == "玩家" && node.Dialogue == option.Text)
                    nextId = node.Next;
                else break;
            }
            return nextId;
        }

        bool IsPlayerFirstAfterOption(DialogueOption option)
        {
            var id = GetOptionRawNext(option);
            var guard = 0;
            while (guard++ < 48 && id != -1)
            {
                var node = GetNode(id);
                if (node == null) return false;
                if (node.RotatePool.Count > 0) { id = node.RotatePool[0]; continue; }
                if (string.IsNullOrEmpty(node.Dialogue) && node.Type != "Question")
                {
                    var routed = ConditionEvaluator.NextFromBranches(node.ConditionBranches);
                    id = routed.HasValue ? routed.Value : node.Next;
                    continue;
                }
                return node.NpcName == "玩家";
            }
            return false;
        }

        void ApplyNamePanel(string speaker)
        {
            if (string.IsNullOrEmpty(speaker) || speaker == "描述")
            {
                if (playerNamePanel != null) playerNamePanel.SetActive(false);
                if (npcNamePanel != null) npcNamePanel.SetActive(false);
                return;
            }
            var isPlayer = speaker == "玩家";
            SetPlayerNamePanel(isPlayer);
            if (npcName != null && !isPlayer) npcName.text = speaker;
        }

        void SetPlayerNamePanel(bool active)
        {
            if (playerNamePanel != null) playerNamePanel.SetActive(active);
            if (npcNamePanel != null) npcNamePanel.SetActive(!active);
        }

        string ResolvePlayerPortrait(DialogueNode data)
        {
            if (data != null && !string.IsNullOrEmpty(data.NpcSprite))
            {
                if (PlayerPortraitKeys.Contains(data.NpcSprite)) return data.NpcSprite;
                return data.NpcSprite;
            }
            return "正常";
        }

        string ResolvePortrait(DialogueNode data)
        {
            if (data == null) return null;
            if (!string.IsNullOrEmpty(data.NpcSprite)) return data.NpcSprite;
            var speaker = data.NpcName ?? "";
            if (speaker == "" || speaker == "描述" || speaker == "玩家") return null;
            var npc = NpcRegistry.GetByName(speaker);
            if (npc == null || string.IsNullOrEmpty(npc.AvatarPath)) return null;
            return System.IO.Path.GetFileNameWithoutExtension(npc.AvatarPath);
        }

        bool ApplyPortrait(string spriteKey, string speaker)
        {
            if (string.IsNullOrEmpty(spriteKey)) return false;
            if (speaker == "玩家")
            {
                if (npcSprite != null) npcSprite.gameObject.SetActive(false);
                if (playerSprite == null) { SetEmotionMarks(null); return false; }
                playerSprite.gameObject.SetActive(true);
                SetEmotionMarks(spriteKey);
                return true;
            }
            SetEmotionMarks(null);
            if (playerSprite != null) playerSprite.gameObject.SetActive(false);
            Sprite sprite;
            if (npcSprite == null || !_portraits.TryGetValue(spriteKey, out sprite) || sprite == null)
            {
                if (npcSprite != null) npcSprite.gameObject.SetActive(false);
                return false;
            }
            npcSprite.sprite = sprite;
            npcSprite.gameObject.SetActive(true);
            if (speaker != "描述") _lastPortraitKey = spriteKey;
            return true;
        }

        void SetEmotionMarks(string spriteKey)
        {
            if (playerExclamation != null) playerExclamation.SetActive(spriteKey == "惊讶");
            if (playerQuestion != null) playerQuestion.SetActive(spriteKey == "疑惑");
        }

        void PlayPlayerEmotionSfx(string spriteKey)
        {
            if (spriteKey == "惊讶") AudioDirector.PlayAudio("audio_shock");
            else if (spriteKey == "疑惑") AudioDirector.PlayAudio("audio_question");
        }

        string ClassifyPlayerPortrait(string text)
        {
            if (string.IsNullOrEmpty(text)) return "正常";
            if (text.Contains("！") || text.Contains("!") || text.Contains("竟然") || text.Contains("？？") || text.Contains("??"))
                return "惊讶";
            if (text.EndsWith("？") || text.EndsWith("?"))
            {
                var core = text.TrimEnd('？', '?', '。', '.', '！', '!', '…', '．');
                return core.Length <= 4 ? "惊讶" : "疑惑";
            }
            if (text.Contains("？") || text.Contains("?")) return "疑惑";
            return "正常";
        }

        void HideAllPortraits()
        {
            if (npcSprite != null) npcSprite.gameObject.SetActive(false);
            SetEmotionMarks(null);
            if (playerSprite != null) playerSprite.gameObject.SetActive(false);
        }

        public void EndDialogue()
        {
            var chain = _current;
            _currentId = -1;
            _waitingChoice = false;
            _waitingNextAfterOption = false;
            _selectedOption = null;
            _typing = false;
            _animatingOptions = false;
            _graph = null;
            _unlockedCache.Clear();
            _lastPortraitKey = null;
            HideAllPortraits();
            if (dialoguePanel != null) dialoguePanel.SetActive(false);
            if (playerPanel != null) playerPanel.SetActive(false);
            if (next != null) next.gameObject.SetActive(false);
            ClearOptionButtons();
            GameEvents.RaiseDialogueEnded();
            if (chain != null && chain.ChainDialogue != null && !string.IsNullOrEmpty(chain.ChainDialogue.NpcName))
                StartNpc(chain.ChainDialogue.NpcName, chain.ChainDialogue.StartId);
        }

        void Update()
        {
            if (_typing)
            {
                _typingTimer += Time.deltaTime;
                if (_typingTimer >= TypingSpeed)
                {
                    _typingTimer = 0f;
                    _typingIndex++;
                    if (_typingIndex <= _fullText.Length)
                        npcDialogueText.text = _fullText.Substring(0, _typingIndex);
                    else
                        CompleteTyping();
                }
            }
            if (_animatingOptions)
            {
                _optionAnimTimer += Time.deltaTime;
                if (_optionAnimTimer >= OptionAnimSpeed)
                {
                    _optionAnimTimer = 0f;
                    _optionAnimIndex++;
                    if (_optionAnimIndex <= _optionButtons.Count)
                    {
                        var btn = _optionButtons[_optionAnimIndex - 1];
                        if (btn != null) btn.SetActive(true);
                    }
                    else _animatingOptions = false;
                }
            }
            if (_currentId >= 0 && !_waitingChoice
                && (Input.GetKeyDown(KeyCode.Space) || Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.E)))
                OnNextClick();
        }

        static int ParseInt(string raw)
        {
            int n;
            return int.TryParse(raw, out n) ? n : 0;
        }

        void BindMissingUi()
        {
            if (dialoguePanel == null)
            {
                var canvas = transform.Find("Canvas/Dialogue") ?? transform.Find("Canvas");
                if (canvas == null)
                {
                    var named = GameObject.Find("dialoguePanel");
                    canvas = named != null ? named.transform.parent : transform;
                }
                if (canvas == null) canvas = transform;
                dialoguePanel = FindChild(canvas, "dialoguePanel") ?? GameObject.Find("dialoguePanel");
                playerNamePanel = FindChild(canvas, "PlayerNamePanel") ?? FindChild(canvas, "playerNamePanel");
                npcNamePanel = FindChild(canvas, "npcNamePanel");
                if (npcNamePanel != null)
                {
                    npcName = FindText(npcNamePanel.transform, "npcName") ?? npcNamePanel.GetComponentInChildren<Text>(true);
                    npcSprite = FindImage(npcNamePanel.transform, "npcSprite");
                    npcDialogueText = FindText(npcNamePanel.transform, "npcDialogueText");
                }
                if (playerNamePanel != null)
                {
                    playerSprite = FindImage(playerNamePanel.transform, "playerSprite");
                    playerExclamation = FindChild(playerNamePanel.transform, "playerExclamation") ?? FindChild(playerNamePanel.transform, "Exclamation");
                    playerQuestion = FindChild(playerNamePanel.transform, "playerQuestion") ?? FindChild(playerNamePanel.transform, "Question");
                }
                var nextGo = FindChild(canvas, "next");
                if (nextGo != null) next = nextGo.GetComponent<Button>();
            }
            if (playerPanel == null)
            {
                var tmpl = FindChild(transform, "playerPanelBtn") ?? GameObject.Find("playerPanelBtn");
                if (tmpl != null)
                {
                    playerPanel = tmpl.transform.parent != null ? tmpl.transform.parent.gameObject : tmpl;
                    playerPanelBtn = tmpl.GetComponent<Button>();
                }
            }
        }

        static GameObject FindChild(Transform root, string name)
        {
            if (root == null) return null;
            if (root.name == name) return root.gameObject;
            for (var i = 0; i < root.childCount; i++)
            {
                var found = FindChild(root.GetChild(i), name);
                if (found != null) return found;
            }
            return null;
        }

        static Image FindImage(Transform root, string name)
        {
            var go = FindChild(root, name);
            return go != null ? go.GetComponent<Image>() : null;
        }

        static Text FindText(Transform root, string name)
        {
            var go = FindChild(root, name);
            return go != null ? go.GetComponent<Text>() : null;
        }
    }
}
