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
        const float PanelInDuration = 0.2f;
        const float PanelOutDuration = 0.16f;
        const float PanelSlide = 18f;
        const float OptionFadeDuration = 0.12f;
        const float NextFadeDuration = 0.14f;
        const float NextBobAmp = 6f;
        const float NextBobPeriod = 1.5f;
        const float NextBobCycles = 2f;
        const float PortraitFadeDuration = 0.16f;
        const float NameFadeDuration = 0.12f;
        const float MarkPopDuration = 0.14f;

        int _currentId = -1;
        DialogueGraph _graph;
        DialogueNode _current;
        bool _waitingChoice;
        bool _typing;
        float _typingTimer;
        int _typingIndex;
        string _fullText = "";
        string _sourceText = "";
        string _speakerSource = "";
        bool _animatingOptions;
        float _optionClock;
        readonly List<OptionFade> _optionFades = new List<OptionFade>();
        CanvasGroup _panelGroup;
        RectTransform _panelRect;
        Vector2 _panelRest;
        bool _panelRestReady;
        int _panelMotion;
        float _panelT;
        float _panelFromAlpha;
        float _panelFromY;
        CanvasGroup _nextGroup;
        RectTransform _nextRect;
        Vector2 _nextRest;
        bool _nextRestReady;
        bool _nextBobbing;
        bool _nextFading;
        float _nextBobT;
        float _nextFadeT;
        CanvasGroup _softGroup;
        float _softT;
        string _softKey;
        CanvasGroup _nameFade;
        float _nameFadeT;
        Transform _markTrans;
        Vector3 _markBase;
        float _markT;
        bool _markPopping;
        DialogueOption _selectedOption;
        bool _waitingNextAfterOption;
        readonly HashSet<string> _unlockedCache = new HashSet<string>();
        string _lastPortraitKey;
        int _blockAdvanceFrame = -1;
        readonly List<DialogueOption> _options = new List<DialogueOption>();
        readonly List<GameObject> _optionButtons = new List<GameObject>();
        readonly Dictionary<string, Sprite> _portraits = new Dictionary<string, Sprite>();
        static readonly HashSet<string> PlayerPortraitKeys = new HashSet<string> { "正常", "惊讶", "疑惑", "无奈" };
        Text _playerNameLabel;

        // ---- 证词局节点级拦截（19 文档 §19.3.2）----
        // 末节点对白照常播完，但 SetVariables 延迟到小游戏成功才写。
        // _gatedNode 非 null 表示当前正停在拦截节点，变量处于「暂缓」状态。
        EggRescue.MiniGame.Hooks.MiniGameDialogueGate _gate;
        DialogueNode _gatedNode;
        bool _gateResumed;   // 小游戏回调期间防止重复触发

        public bool IsDialogueActive
        {
            get { return _currentId >= 0 || (dialoguePanel != null && dialoguePanel.activeSelf); }
        }

        void OnEnable()
        {
            GameLocale.Changed += OnLocaleChanged;
        }

        void OnDisable()
        {
            GameLocale.Changed -= OnLocaleChanged;
        }

        void Awake()
        {
            Instance = this;
            BindMissingUi();
            RebuildPortraitMap();
            ApplyPlayerName();
            EnsurePanel();
            EnsureNextRest();
            if (dialoguePanel != null) dialoguePanel.SetActive(false);
            if (playerPanel != null) playerPanel.SetActive(false);
            if (playerNamePanel != null) playerNamePanel.SetActive(false);
            SetNextVisible(false);
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
            _blockAdvanceFrame = Time.frameCount;
            PresentPanel();
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
            _blockAdvanceFrame = Time.frameCount;
            PresentPanel();
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
            // 证词局：末节点对白已播完，玩家点「下一句」准备离开 —— 此刻拦截开小游戏。
            if (_gate != null && _gatedNode != null && !_gateResumed)
            {
                TriggerGate();
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

            // 证词局拦截：进入末节点时先记下来，暂缓写 SetVariables。
            // 只有小游戏成功后才补写（见 TriggerGate / ResumeGate）。
            var gate = EggRescue.MiniGame.Hooks.MiniGameDialogueGates.Find(_graph.Module, _current.Id);
            if (gate != null && !_gateResumed && !IsGateSubmitted(gate))
            {
                _gate = gate;
                _gatedNode = _current;
                // 依旧解锁分支、但不 ApplySetVariables —— 线索变量要等小游戏成功。
                UnlockBranches(_current);
            }
            else
            {
                _gate = null;
                _gatedNode = null;
                ApplyNodeSideEffects(_current);
            }
            SetNextVisible(false);
            if (playerPanel != null) playerPanel.SetActive(false);
            ClearOptionButtons();
            UpdateNpcInfo(_current);
        }

        void ApplyNodeSideEffects(DialogueNode data)
        {
            UnlockBranches(data);
            ApplySetVariables(data);
        }

        // ---------------- 证词局节点级拦截（19 文档 §19.3.2）----------------

        bool IsGateSubmitted(EggRescue.MiniGame.Hooks.MiniGameDialogueGate gate)
        {
            var def = EggRescue.MiniGame.MiniGameRegistry.Get(gate.DefId);
            if (def == null) return false;
            // Q05/Q08/Q13 提交的是 int 状态；bool 局看 SubmitVar。
            return EggRescue.MiniGame.MiniGameHost.IsSubmitted(def);
        }

        /// <summary>
        /// 末节点对白播毕、玩家准备离开时开小游戏。
        /// 变量此刻还没写（进入节点时已被暂缓），符合「成功前不发线索」。
        /// </summary>
        void TriggerGate()
        {
            var gate = _gate;
            var node = _gatedNode;
            if (gate == null || node == null) return;

            // Q04 可选偷听作废：若其间 ChickStatus>=3，作废未结算记录，
            // 保持原交互关闭 —— 不写 E03_Overheard、不发 D02、不计数（§19.3.2）。
            if (!string.IsNullOrEmpty(gate.VoidIfVar) && GameState.GetInt(gate.VoidIfVar) >= gate.VoidIfValue)
            {
                EggRescue.MiniGame.MiniGameSave.Clear(gate.DefId);
                // 作废：绝不补写 E03_Overheard。传 false 只走原出口、不发线索、不计数。
                ResumeGate(false);
                return;
            }

            var def = EggRescue.MiniGame.MiniGameRegistry.Get(gate.DefId);
            if (def == null)
            {
                ResumeGate(false);   // 缺 def：按原出口继续，不阻断剧情
                return;
            }
            if (EggRescue.MiniGame.MiniGameHost.IsSubmitted(def))
            {
                // 已完成：末节点原有 SetVariables 本就该写（那是这段对白的正常副作用），
                // 只是不能再开一局。补写后走原出口，去重靠 IsSubmitted。
                ResumeGate(true);
                return;
            }

            _gateResumed = true;
            if (!EggRescue.MiniGame.MiniGameHost.Open(def, () => ResumeGate(
                    EggRescue.MiniGame.MiniGameHost.IsSubmitted(def))))
            {
                // 打开失败（内容未就绪等）：不能把玩家卡在末节点，放行对白。
                _gateResumed = false;
                ResumeGate(false);
            }
        }

        /// <summary>
        /// 小游戏结束（完成或中途退出）后接回对白。
        /// submitted=true 才补写末节点原有 SetVariables；否则只走原出口、不发线索。
        /// </summary>
        void ResumeGate(bool submitted)
        {
            var node = _gatedNode;
            if (node != null && submitted)
            {
                ApplySetVariables(node);
                // Q06 补录成功后，E12_ViewGreenPad 由 node 的 SetVariables 写；
                // 但 Q06 的 SubmitVar 也是它，IsSubmitted 已成立，不会重复发。
            }
            _gate = null;
            _gatedNode = null;

            if (node == null) { EndDialogue(); return; }
            var nextId = ConditionEvaluator.NextFromBranches(node.ConditionBranches);
            if (!nextId.HasValue) nextId = node.Next;
            _gateResumed = false;
            if (nextId.Value == -1 || GetNode(nextId.Value) == null) EndDialogue();
            else AdvanceTo(nextId.Value);
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
            _sourceText = data.Dialogue ?? "";
            _fullText = GameLocale.Line(_sourceText);
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
                if (npcName != null) npcName.text = GameLocale.Name("玩家");
                SetNextVisible(true);
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
            SetNextVisible(true);
        }

        void ShowQuestionUi(DialogueNode data)
        {
            _waitingChoice = true;
            SetNextVisible(false);
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
                var group = GetGroup(go);
                group.alpha = 0f;
                group.blocksRaycasts = false;
                go.SetActive(true);
                var label = go.GetComponentInChildren<Text>();
                if (label != null) label.text = GameLocale.Line(option.Text);
                var rect = go.GetComponent<RectTransform>();
                if (rect != null) rect.anchoredPosition = new Vector2(0f, startY - i * buttonHeight);
                var btn = go.GetComponent<Button>();
                if (btn != null)
                {
                    var captured = option;
                    btn.onClick.AddListener(() => OnOptionSelected(captured));
                }
                _optionFades.Add(new OptionFade { Group = group });
                _optionButtons.Add(go);
            }
            _animatingOptions = _optionFades.Count > 0;
            _optionClock = 0f;
        }

        void CompleteOptionAnimation()
        {
            _animatingOptions = false;
            for (var i = 0; i < _optionFades.Count; i++)
                ApplyOptionFade(_optionFades[i], 1f);
        }

        void ClearOptionButtons()
        {
            _animatingOptions = false;
            _optionFades.Clear();
            for (var i = 0; i < _optionButtons.Count; i++)
            {
                if (_optionButtons[i] != null) Destroy(_optionButtons[i]);
            }
            _optionButtons.Clear();
        }

        void OnOptionSelected(DialogueOption option)
        {
            if (!_waitingChoice) return;
            _blockAdvanceFrame = Time.frameCount;
            _waitingChoice = false;
            if (playerPanel != null) playerPanel.SetActive(false);
            ClearOptionButtons();
            SetNextVisible(false);
            if (IsPlayerFirstAfterOption(option))
            {
                PerformOptionJump(option, true);
                return;
            }
            _selectedOption = option;
            _waitingNextAfterOption = true;
            SetPlayerNamePanel(true);
            if (npcName != null) npcName.text = GameLocale.Name("玩家");
            _sourceText = option.Text;
            _fullText = GameLocale.Line(_sourceText);
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

        void OnLocaleChanged()
        {
            if (!string.IsNullOrEmpty(_sourceText))
            {
                _fullText = GameLocale.Line(_sourceText);
                if (npcDialogueText != null)
                {
                    if (_typing) _typingIndex = 0;
                    else npcDialogueText.text = _fullText;
                }
            }
            if (!string.IsNullOrEmpty(_speakerSource))
                ApplyNamePanel(_speakerSource);
            ApplyPlayerName();
            for (var i = 0; i < _optionButtons.Count && i < _options.Count; i++)
            {
                if (_optionButtons[i] == null) continue;
                var label = _optionButtons[i].GetComponentInChildren<Text>();
                if (label != null) label.text = GameLocale.Line(_options[i].Text);
            }
        }

        void ApplyNamePanel(string speaker)
        {
            _speakerSource = speaker;
            if (string.IsNullOrEmpty(speaker) || speaker == "描述")
            {
                RevealName(playerNamePanel, false);
                RevealName(npcNamePanel, false);
                return;
            }
            var isPlayer = speaker == "玩家";
            SetPlayerNamePanel(isPlayer);
            if (npcName != null && !isPlayer) npcName.text = GameLocale.Name(speaker);
            else if (npcName != null && isPlayer) npcName.text = GameLocale.Name("玩家");
        }

        void SetPlayerNamePanel(bool playerSpeaking)
        {
            if (playerSpeaking) ApplyPlayerName();
            RevealName(playerNamePanel, playerSpeaking);
            RevealName(npcNamePanel, !playerSpeaking);
        }

        void ApplyPlayerName()
        {
            if (_playerNameLabel == null && playerNamePanel != null)
                _playerNameLabel = FindText(playerNamePanel.transform, "playerName");
            if (_playerNameLabel != null)
                _playerNameLabel.text = GameLocale.Name("玩家");
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
                HideImage(npcSprite);
                if (playerSprite == null) { SetEmotionMarks(null); return false; }
                var key = spriteKey;
                if (string.IsNullOrEmpty(key) || !PlayerPortraitKeys.Contains(key)) key = "正常";
                Sprite portrait;
                if (_portraits.TryGetValue(key, out portrait) && portrait != null)
                    playerSprite.sprite = portrait;
                var changed = _softKey != "玩家:" + key;
                _softKey = "玩家:" + key;
                playerSprite.gameObject.SetActive(true);
                SetEmotionMarks(null);
                SoftReveal(playerSprite, changed);
                return true;
            }
            SetEmotionMarks(null);
            HideImage(playerSprite);
            Sprite sprite;
            if (npcSprite == null || !_portraits.TryGetValue(spriteKey, out sprite) || sprite == null)
            {
                HideImage(npcSprite);
                return false;
            }
            var portraitChanged = _softKey != spriteKey;
            _softKey = spriteKey;
            npcSprite.sprite = sprite;
            npcSprite.gameObject.SetActive(true);
            if (speaker != "描述") _lastPortraitKey = spriteKey;
            SoftReveal(npcSprite, portraitChanged);
            return true;
        }

        void SetEmotionMarks(string spriteKey)
        {
            var exclaim = spriteKey == "惊讶";
            var question = spriteKey == "疑惑";
            if (!exclaim) SetMark(playerExclamation, false);
            if (!question) SetMark(playerQuestion, false);
            if (exclaim) SetMark(playerExclamation, true);
            if (question) SetMark(playerQuestion, true);
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
            HideImage(npcSprite);
            SetEmotionMarks(null);
            HideImage(playerSprite);
            _softKey = null;
        }

        public void EndDialogue()
        {
            var chain = _current;
            // 对白被外部强制结束（读档 / 切场景）时，别把 gate 残留到下一次对话。
            _gate = null;
            _gatedNode = null;
            _gateResumed = false;
            _currentId = -1;
            _waitingChoice = false;
            _waitingNextAfterOption = false;
            _selectedOption = null;
            _typing = false;
            _animatingOptions = false;
            _graph = null;
            _unlockedCache.Clear();
            _lastPortraitKey = null;
            var chained = chain != null && chain.ChainDialogue != null && !string.IsNullOrEmpty(chain.ChainDialogue.NpcName);
            if (chained)
            {
                HideAllPortraits();
                if (playerPanel != null) playerPanel.SetActive(false);
                SetNextVisible(false);
                ClearOptionButtons();
                GameEvents.RaiseDialogueEnded();
                StartNpc(chain.ChainDialogue.NpcName, chain.ChainDialogue.StartId);
                return;
            }
            BeginPanelOut();
            GameEvents.RaiseDialogueEnded();
        }

        void Update()
        {
            if (GameEvents.Paused) return;
            var dt = Time.deltaTime;
            TickPanel(dt);
            TickNext(dt);
            TickPortrait(dt);
            TickName(dt);
            TickMark(dt);
            if (_typing)
            {
                _typingTimer += dt;
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
            if (_animatingOptions) TickOptions(dt);
            if (_currentId < 0 || Time.frameCount == _blockAdvanceFrame || !AdvancePressed()) return;
            if (_waitingChoice)
            {
                if (_animatingOptions) CompleteOptionAnimation();
                return;
            }
            OnNextClick();
        }

        static bool AdvancePressed()
        {
            return Input.GetMouseButtonDown(0)
                || Input.GetKeyDown(KeyCode.Space)
                || Input.GetKeyDown(KeyCode.Return)
                || Input.GetKeyDown(KeyCode.KeypadEnter);
        }

        static int ParseInt(string raw)
        {
            int n;
            return int.TryParse(raw, out n) ? n : 0;
        }

        sealed class OptionFade
        {
            public CanvasGroup Group;
        }

        void PresentPanel()
        {
            if (dialoguePanel == null) return;
            EnsurePanel();
            if (_panelGroup == null) { dialoguePanel.SetActive(true); return; }
            var settled = dialoguePanel.activeSelf && _panelMotion == 0 && _panelGroup.alpha > 0.98f;
            if (settled)
            {
                _panelGroup.blocksRaycasts = true;
                return;
            }
            if (!dialoguePanel.activeSelf || _panelGroup.alpha < 0.02f)
            {
                _panelFromAlpha = 0f;
                _panelFromY = _panelRest.y - PanelSlide;
            }
            else
            {
                _panelFromAlpha = _panelGroup.alpha;
                _panelFromY = _panelRect != null ? _panelRect.anchoredPosition.y : _panelRest.y;
            }
            dialoguePanel.SetActive(true);
            _panelGroup.alpha = _panelFromAlpha;
            _panelGroup.blocksRaycasts = true;
            if (_panelRect != null)
                _panelRect.anchoredPosition = new Vector2(_panelRest.x, _panelFromY);
            _panelMotion = 1;
            _panelT = 0f;
        }

        void BeginPanelOut()
        {
            if (dialoguePanel == null || !dialoguePanel.activeSelf)
            {
                FinishPanelOut();
                return;
            }
            EnsurePanel();
            if (_panelGroup == null)
            {
                FinishPanelOut();
                return;
            }
            if (_panelMotion == 2) return;
            if (_panelGroup.alpha < 0.02f)
            {
                FinishPanelOut();
                return;
            }
            CancelSoftFades();
            _panelFromAlpha = _panelGroup.alpha;
            _panelFromY = _panelRect != null ? _panelRect.anchoredPosition.y : _panelRest.y;
            _panelGroup.blocksRaycasts = false;
            _panelMotion = 2;
            _panelT = 0f;
        }

        void FinishPanelOut()
        {
            if (_currentId >= 0) return;
            _panelMotion = 0;
            HideAllPortraits();
            if (playerPanel != null) playerPanel.SetActive(false);
            SetNextVisible(false);
            ClearOptionButtons();
            if (_nameFade != null) { _nameFade.alpha = 1f; _nameFade = null; }
            if (_panelGroup != null) _panelGroup.alpha = 0f;
            if (_panelRect != null) _panelRect.anchoredPosition = _panelRest;
            if (dialoguePanel != null) dialoguePanel.SetActive(false);
        }

        void TickPanel(float dt)
        {
            if (_panelMotion == 0 || _panelGroup == null) return;
            var dur = _panelMotion == 1 ? PanelInDuration : PanelOutDuration;
            _panelT += dt;
            var e = EaseOut(_panelT / dur);
            if (_panelMotion == 1)
            {
                _panelGroup.alpha = Mathf.Lerp(_panelFromAlpha, 1f, e);
                if (_panelRect != null)
                    _panelRect.anchoredPosition = new Vector2(_panelRest.x, Mathf.Lerp(_panelFromY, _panelRest.y, e));
                if (_panelT < dur) return;
                _panelMotion = 0;
                _panelGroup.alpha = 1f;
                if (_panelRect != null) _panelRect.anchoredPosition = _panelRest;
                if (!_nextBobbing && next != null && next.gameObject.activeSelf)
                {
                    _nextBobbing = true;
                    _nextBobT = 0f;
                }
                return;
            }
            _panelGroup.alpha = Mathf.Lerp(_panelFromAlpha, 0f, e);
            if (_panelRect != null)
            {
                var targetY = _panelFromY - PanelSlide * 0.65f;
                _panelRect.anchoredPosition = new Vector2(_panelRest.x, Mathf.Lerp(_panelFromY, targetY, e));
            }
            if (_panelT < dur) return;
            if (_currentId >= 0)
            {
                _panelMotion = 1;
                _panelT = 0f;
                _panelFromAlpha = _panelGroup.alpha;
                _panelFromY = _panelRect != null ? _panelRect.anchoredPosition.y : _panelRest.y;
                _panelGroup.blocksRaycasts = true;
                return;
            }
            FinishPanelOut();
        }

        void EnsurePanel()
        {
            if (dialoguePanel == null) return;
            var rect = dialoguePanel.GetComponent<RectTransform>();
            if (_panelRestReady && _panelRect == rect) return;
            _panelRect = rect;
            _panelGroup = GetGroup(dialoguePanel);
            if (_panelRect != null) _panelRest = _panelRect.anchoredPosition;
            _panelRestReady = _panelRect != null;
        }

        void SetNextVisible(bool on)
        {
            if (next == null) return;
            EnsureNextRest();
            var was = next.gameObject.activeSelf;
            next.gameObject.SetActive(on);
            if (!on)
            {
                _nextBobbing = false;
                _nextFading = false;
                if (_nextRect != null) _nextRect.anchoredPosition = _nextRest;
                if (_nextGroup != null) _nextGroup.alpha = 1f;
                return;
            }
            next.interactable = true;
            if (was) return;
            _nextBobT = 0f;
            _nextBobbing = _panelMotion == 0;
            if (_panelMotion != 0 || _nextGroup == null)
            {
                _nextFading = false;
                if (_nextGroup != null) _nextGroup.alpha = 1f;
                return;
            }
            _nextFading = true;
            _nextFadeT = 0f;
            _nextGroup.alpha = 0f;
        }

        void EnsureNextRest()
        {
            if (_nextRestReady || next == null) return;
            _nextRect = next.GetComponent<RectTransform>();
            _nextGroup = GetGroup(next.gameObject);
            if (_nextRect != null) _nextRest = _nextRect.anchoredPosition;
            _nextRestReady = _nextRect != null;
        }

        void TickNext(float dt)
        {
            if (!_nextRestReady || next == null || !next.gameObject.activeSelf) return;
            if (_nextFading && _nextGroup != null)
            {
                _nextFadeT += dt;
                _nextGroup.alpha = EaseOut(_nextFadeT / NextFadeDuration);
                if (_nextFadeT >= NextFadeDuration) _nextFading = false;
            }
            if (!_nextBobbing || _nextRect == null) return;
            _nextBobT += dt;
            if (_nextBobT >= NextBobPeriod * NextBobCycles)
            {
                _nextRect.anchoredPosition = _nextRest;
                _nextBobbing = false;
                return;
            }
            var y = Mathf.Sin(_nextBobT * (Mathf.PI * 2f / NextBobPeriod)) * NextBobAmp;
            _nextRect.anchoredPosition = _nextRest + new Vector2(0f, y);
        }

        void TickOptions(float dt)
        {
            _optionClock += dt;
            var t = _optionClock / OptionFadeDuration;
            for (var i = 0; i < _optionFades.Count; i++)
                ApplyOptionFade(_optionFades[i], t);
            if (t >= 1f) _animatingOptions = false;
        }

        static void ApplyOptionFade(OptionFade fade, float t)
        {
            if (fade == null || fade.Group == null) return;
            var e = EaseOut(t);
            fade.Group.alpha = e;
            fade.Group.blocksRaycasts = e > 0.35f;
        }

        void RevealName(GameObject go, bool on)
        {
            if (go == null) return;
            if (go.activeSelf == on)
                return;
            go.SetActive(on);
            var cg = GetGroup(go);
            if (!on)
            {
                if (_nameFade == cg) _nameFade = null;
                cg.alpha = 1f;
                return;
            }
            if (_panelMotion != 0 || dialoguePanel == null || !dialoguePanel.activeSelf)
            {
                cg.alpha = 1f;
                if (_nameFade == cg) _nameFade = null;
                return;
            }
            cg.alpha = 0.4f;
            _nameFade = cg;
            _nameFadeT = 0f;
        }

        void TickName(float dt)
        {
            if (_nameFade == null) return;
            _nameFadeT += dt;
            _nameFade.alpha = Mathf.Lerp(0.4f, 1f, EaseOut(_nameFadeT / NameFadeDuration));
            if (_nameFadeT >= NameFadeDuration) _nameFade = null;
        }

        void SoftReveal(Image img, bool changed)
        {
            if (img == null) return;
            var cg = GetGroup(img.gameObject);
            if (!changed || _panelMotion != 0)
            {
                if (_softGroup == cg) _softGroup = null;
                cg.alpha = 1f;
                return;
            }
            cg.alpha = 0.55f;
            _softGroup = cg;
            _softT = 0f;
        }

        void TickPortrait(float dt)
        {
            if (_softGroup == null) return;
            _softT += dt;
            _softGroup.alpha = Mathf.Lerp(0.55f, 1f, EaseOut(_softT / PortraitFadeDuration));
            if (_softT >= PortraitFadeDuration) _softGroup = null;
        }

        void HideImage(Image img)
        {
            if (img == null) return;
            var cg = img.GetComponent<CanvasGroup>();
            if (cg != null)
            {
                if (_softGroup == cg) _softGroup = null;
                cg.alpha = 1f;
            }
            img.gameObject.SetActive(false);
        }

        void SetMark(GameObject go, bool on)
        {
            if (go == null) return;
            if (!on)
            {
                if (_markTrans == go.transform)
                {
                    _markTrans.localScale = _markBase;
                    _markPopping = false;
                    _markTrans = null;
                }
                go.SetActive(false);
                return;
            }
            var was = go.activeSelf;
            go.SetActive(true);
            if (was || _panelMotion != 0) return;
            _markTrans = go.transform;
            _markBase = _markTrans.localScale;
            _markT = 0f;
            _markPopping = true;
            _markTrans.localScale = _markBase * 0.88f;
        }

        void TickMark(float dt)
        {
            if (!_markPopping || _markTrans == null) return;
            _markT += dt;
            var e = EaseOut(_markT / MarkPopDuration);
            _markTrans.localScale = Vector3.Lerp(_markBase * 0.88f, _markBase, e);
            if (_markT < MarkPopDuration) return;
            _markTrans.localScale = _markBase;
            _markPopping = false;
        }

        void CancelSoftFades()
        {
            if (_softGroup != null)
            {
                _softGroup.alpha = 1f;
                _softGroup = null;
            }
            if (_nameFade != null)
            {
                _nameFade.alpha = 1f;
                _nameFade = null;
            }
        }

        static CanvasGroup GetGroup(GameObject go)
        {
            var cg = go.GetComponent<CanvasGroup>();
            if (cg == null) cg = go.AddComponent<CanvasGroup>();
            return cg;
        }

        static float EaseOut(float t)
        {
            t = Mathf.Clamp01(t);
            var inv = 1f - t;
            return 1f - inv * inv * inv;
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
