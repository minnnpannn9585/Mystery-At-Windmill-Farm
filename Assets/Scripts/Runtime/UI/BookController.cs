using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    public sealed class BookController : MonoBehaviour
    {
        public Button open;
        public Button close;
        public GameObject openRedDot;
        public GameObject boolPanel;
        public GameObject[] hideOnOpen;
        public GameObject[] pageContents;
        public Button[] page1TabBtns;
        public Button[] page2TabBtns;
        public Button[] page3TabBtns;
        public Button[] page4TabBtns;

        public GameObject entry_D01, entry_E01, entry_E02, entry_D02, entry_D03, entry_FrogImage, entry_E12;
        public GameObject entry_D04, entry_D05, entry_D06, entry_E23, entry_E25, entry_E04, entry_D07, entry_D08;
        public GameObject entry_E06, entry_E07, entry_E08, entry_E09, entry_E27, entry_E34, entry_E10, entry_D09;
        public GameObject entry_E13, entry_E14, entry_E15, entry_E16, entry_E28, entry_E17, entry_E18;
        public GameObject entry_D12, entry_D13, entry_D14, entry_D18;

        public GameObject intelCheapPrefab;
        public GameObject intelPremiumPrefab;
        public GameObject intelLayoutLeft;
        public GameObject intelLayoutRight;
        public int intelLeftColumnMax = 9;

        public GameObject link_D03_D04, link_D03_D05, link_D03_D06, link_D05_E23;
        public GameObject[] link_E17_D05, link_E17_E23, link_D06_D07;
        public GameObject link_E04_E06, link_E07_E08, link_E08_E27, link_E27_E34, link_E08_E34;
        public GameObject link_D13_E12, link_D13_D12, link_D14_D12;

        public GameObject mod_D03_strike, mod_D03_note, mod_D07_strike, mod_D07_note;
        public GameObject mod_E04_borrowed, mod_E04_ladderPic, mod_E06_done, mod_D08_got;
        public GameObject mod_E08_glassNote, mod_D12_got, mod_D12_fishPic, mod_E13_strike, mod_E13_note;

        const float FadeDuration = 1f;
        const float BlinkDuration = 0.35f;
        const float BlinkMin = 0.15f;
        const float IconBounceDuration = 0.4f;
        const float IconBouncePeak = 2f;

        sealed class EntryDef { public GameObject Go; public string Cond; }
        sealed class LinkDef { public GameObject Go; public GameObject[] Gos; public string A; public string B; }
        sealed class ModDef { public GameObject Go; public string EntryUnlock; public string Cond; }
        sealed class Pending { public CanvasGroup Group; public int Page; }
        sealed class Anim { public CanvasGroup Group; public string Phase; public float Elapsed; }
        sealed class HudState { public GameObject Go; public bool WasActive; }

        readonly Dictionary<string, EntryDef> _entries = new Dictionary<string, EntryDef>();
        readonly List<LinkDef> _links = new List<LinkDef>();
        readonly List<ModDef> _mods = new List<ModDef>();
        readonly Dictionary<string, bool> _unlocked = new Dictionary<string, bool>();
        readonly Dictionary<string, Pending> _pending = new Dictionary<string, Pending>();
        readonly Dictionary<string, Anim> _anims = new Dictionary<string, Anim>();
        readonly Dictionary<string, GameObject> _intelSpawned = new Dictionary<string, GameObject>();
        readonly Dictionary<int, List<GameObject>> _pageDots = new Dictionary<int, List<GameObject>>();
        readonly Dictionary<string, string> _intelText = new Dictionary<string, string>();
        readonly Dictionary<string, string> _intelTier = new Dictionary<string, string>();
        static readonly string[] IntelOrder =
        {
            "Mouse_CheapSold_01","Mouse_CheapSold_02","Mouse_CheapSold_03","Mouse_CheapSold_04","Mouse_CheapSold_05",
            "Mouse_CheapSold_06","Mouse_CheapSold_07","Mouse_CheapSold_08","Mouse_CheapSold_09","Mouse_CheapSold_10",
            "Mouse_PremiumSold_01","Mouse_PremiumSold_02","Mouse_PremiumSold_03","Mouse_PremiumSold_04",
            "Mouse_PremiumSold_05","Mouse_PremiumSold_06","Mouse_PremiumSold_07","Mouse_PremiumSold_08"
        };

        int _page = 1;
        Transform _openIcon;
        Vector3 _iconBase;
        bool _iconBounce;
        float _iconElapsed;
        bool _lastRedDot;
        bool? _lastOpenInteractable;
        bool _iconVisible;
        List<HudState> _hiddenHud;

        void OnEnable() { GameEvents.VariableChanged += OnVarChanged; }
        void OnDisable() { GameEvents.VariableChanged -= OnVarChanged; }

        void Start()
        {
            AutoBindFields();
            BuildCatalog();
            if (boolPanel != null) boolPanel.SetActive(false);
            if (open != null)
            {
                open.gameObject.SetActive(false);
                _iconVisible = false;
                open.onClick.AddListener(OnOpenClick);
            }
            if (close != null) close.onClick.AddListener(OnCloseClick);
            BindTabs(page1TabBtns, 1);
            BindTabs(page2TabBtns, 2);
            BindTabs(page3TabBtns, 3);
            BindTabs(page4TabBtns, 4);
            CollectDots();
            foreach (var kv in _entries)
            {
                if (kv.Value.Go == null) continue;
                kv.Value.Go.SetActive(false);
                GetGroup(kv.Value.Go).alpha = 0f;
                _unlocked[kv.Key] = false;
            }
            foreach (var link in _links)
            {
                if (link.Gos != null) SetGos(link.Gos, false);
                else if (link.Go != null) link.Go.SetActive(false);
            }
            foreach (var mod in _mods)
                if (mod.Go != null) mod.Go.SetActive(false);
            RebuildIntel();
            HidePages();
            ShowPage();
            ResolveIcon();
            RefreshOpenInteractable();
            UpdatePageDots();
            CheckAllEntries();
        }

        void Update()
        {
            RefreshOpenInteractable();
            TickIcon(Time.deltaTime);
            if (!GameEvents.DialogueActive && Input.GetKeyDown(KeyCode.N))
            {
                if (IsOpen()) OnCloseClick();
                else if (open != null && open.gameObject.activeSelf) OnOpenClick();
            }
            var done = new List<string>();
            foreach (var kv in _anims)
            {
                var info = kv.Value;
                if (info.Group == null) { done.Add(kv.Key); continue; }
                info.Elapsed += Time.deltaTime;
                if (info.Phase == "fade")
                {
                    var p = info.Elapsed / FadeDuration;
                    if (p >= 1f) { info.Group.alpha = 1f; info.Phase = "blink"; info.Elapsed = 0f; }
                    else info.Group.alpha = p;
                }
                else if (info.Phase == "blink")
                {
                    var p = info.Elapsed / BlinkDuration;
                    if (p >= 1f) { info.Group.alpha = 1f; done.Add(kv.Key); }
                    else
                    {
                        var t = p < 0.5f ? p * 2f : 2f - p * 2f;
                        info.Group.alpha = 1f - t * (1f - BlinkMin);
                    }
                }
                else done.Add(kv.Key);
            }
            for (var i = 0; i < done.Count; i++) _anims.Remove(done[i]);
        }

        void OnVarChanged(string name)
        {
            CheckAllEntries();
            if (!string.IsNullOrEmpty(name) && (name.StartsWith("Mouse_CheapSold_") || name.StartsWith("Mouse_PremiumSold_")))
                SpawnIntel(name, true);
        }

        void BuildCatalog()
        {
            Add("D01", entry_D01, "Shufen_CommissionDone==true");
            Add("E01", entry_E01, "E01_ViewCharcoal==true");
            Add("E02", entry_E02, "E02_ViewFeather==true");
            Add("D02", entry_D02, "E03_Overheard==true");
            Add("D03", entry_D03, "ChickStatus>=2");
            Add("FROG_IMAGE", entry_FrogImage, "Frog_FirstMeetShown==true");
            Add("E12", entry_E12, "E12_ViewGreenPad==true");
            Add("D04", entry_D04, "Frog_WaterMonsterQueried==true");
            Add("D05", entry_D05, "Frog_WaterMonsterQueried==true");
            Add("D06", entry_D06, "Frog_WaterMonsterQueried==true");
            Add("E23", entry_E23, "E23_dabble==true");
            Add("E25", entry_E25, "E25_ChickenFootprints==true");
            Add("E04", entry_E04, "DogStatus>=2");
            Add("D07", entry_D07, "DogStatus>=2");
            Add("D08", entry_D08, "Shufen_DaHuangWakeAsked==true|Chick_WakeDogHintShown==true|Mouse_CheapSold_07==true");
            Add("E06", entry_E06, "E06_ViewNeedLadder==true");
            Add("E07", entry_E07, "E07_ViewNapSpot==true");
            Add("E08", entry_E08, "E08_ViewBurnMark==true");
            Add("E09", entry_E09, "E09_AnimalPawPrints==true");
            Add("E27", entry_E27, "E27_ColorReflective==true");
            Add("E34", entry_E34, "E34_Glass==true");
            Add("E10", entry_E10, "E10_ViewWhiteStone==true");
            Add("D09", entry_D09, "ChickStatus>=3");
            Add("E13", entry_E13, "E13_ViewDoorBlocked==true");
            Add("E14", entry_E14, "E14_ViewCatDoor==true");
            Add("E15", entry_E15, "E15_ViewFoodBowl==true");
            Add("E16", entry_E16, "E16_ViewFur==true");
            Add("E28", entry_E28, "E28_ViewTreeScratch==true");
            Add("E17", entry_E17, "E17_ViewEmptyBucket==true");
            Add("E18", entry_E18, "E18_ViewBootprints==true");
            Add("D12", entry_D12, "BlackCat_MintFishPending==true");
            Add("D13", entry_D13, "BlackCat_MintFishPending==true&E12_ViewGreenPad==true");
            Add("D14", entry_D14, "Mouse_MintFishPaid==true");
            Add("D18", entry_D18, "BlackCat_Entered==true");

            _links.Add(new LinkDef { Go = link_D03_D04, A = "D03", B = "D04" });
            _links.Add(new LinkDef { Go = link_D03_D05, A = "D03", B = "D05" });
            _links.Add(new LinkDef { Go = link_D03_D06, A = "D03", B = "D06" });
            _links.Add(new LinkDef { Go = link_D05_E23, A = "D05", B = "E23" });
            _links.Add(new LinkDef { Gos = link_E17_D05, A = "E17", B = "D05" });
            _links.Add(new LinkDef { Gos = link_E17_E23, A = "E17", B = "E23" });
            _links.Add(new LinkDef { Gos = link_D06_D07, A = "D06", B = "D07" });
            _links.Add(new LinkDef { Go = link_E04_E06, A = "E04", B = "E06" });
            _links.Add(new LinkDef { Go = link_E07_E08, A = "E07", B = "E08" });
            _links.Add(new LinkDef { Go = link_E08_E27, A = "E08", B = "E27" });
            _links.Add(new LinkDef { Go = link_E27_E34, A = "E27", B = "E34" });
            _links.Add(new LinkDef { Go = link_E08_E34, A = "E08", B = "E34" });
            _links.Add(new LinkDef { Go = link_D13_E12, A = "D13", B = "E12" });
            _links.Add(new LinkDef { Go = link_D13_D12, A = "D13", B = "D12" });
            _links.Add(new LinkDef { Go = link_D14_D12, A = "D14", B = "D12" });

            _mods.Add(new ModDef { Go = mod_D03_strike, EntryUnlock = "D09" });
            _mods.Add(new ModDef { Go = mod_D03_note, EntryUnlock = "D09" });
            _mods.Add(new ModDef { Go = mod_D07_strike, EntryUnlock = "E10" });
            _mods.Add(new ModDef { Go = mod_D07_note, EntryUnlock = "E10" });
            _mods.Add(new ModDef { Go = mod_E04_borrowed, Cond = "E06_LadderBorrowed==true" });
            _mods.Add(new ModDef { Go = mod_E04_ladderPic, Cond = "E06_LadderBorrowed==true" });
            _mods.Add(new ModDef { Go = mod_E06_done, Cond = "E06_LadderPlaced==true" });
            _mods.Add(new ModDef { Go = mod_D08_got, Cond = "E05_GrainSoakGet==true" });
            _mods.Add(new ModDef { Go = mod_E08_glassNote, Cond = "Crow_GlassBeadAsked==true" });
            _mods.Add(new ModDef { Go = mod_D12_got, Cond = "MintFish_Obtained==true" });
            _mods.Add(new ModDef { Go = mod_D12_fishPic, Cond = "MintFish_Obtained==true" });
            _mods.Add(new ModDef { Go = mod_E13_strike, Cond = "BlackCat_Entered==true" });
            _mods.Add(new ModDef { Go = mod_E13_note, Cond = "BlackCat_Entered==true" });

            AddIntel("Mouse_CheapSold_01", "cheap", "大黄的项圈是镀银的。");
            AddIntel("Mouse_CheapSold_02", "cheap", "青蛙年轻时是这片水域的第一情圣。");
            AddIntel("Mouse_CheapSold_03", "cheap", "淑芬十年前是隔壁村的斗鸡冠军。");
            AddIntel("Mouse_CheapSold_04", "cheap", "Flash 是隔壁农场派来的商业间谍，画了三年地图了。");
            AddIntel("Mouse_CheapSold_05", "cheap", "主人是鸡科圣手，尤其精通《母鸡的产后护理》。");
            AddIntel("Mouse_CheapSold_06", "cheap", "大橡树会走路——一年挪一厘米。");
            AddIntel("Mouse_CheapSold_07", "cheap", "上次大黄偷喝主人的发酵苹果渣，是淑芬用谷物泡水叫醒的。");
            AddIntel("Mouse_CheapSold_08", "cheap", "主人这几天常趴窗看鸡舍方向——看完又不进去。");
            AddIntel("Mouse_CheapSold_09", "cheap", "小鸡昨晚都缩在鸡舍里不出来，像在等什么");
            AddIntel("Mouse_CheapSold_10", "cheap", "黑猫前天下午自己爬上过谷仓顶");
            AddIntel("Mouse_PremiumSold_01", "premium", "水怪是老鼠兄弟随口编的。");
            AddIntel("Mouse_PremiumSold_02", "premium", "乌鸦前天早上从鸡舍门口草丛搞了个东西回屋顶。");
            AddIntel("Mouse_PremiumSold_03", "premium", "昨晚红顶屋里亮黄灯，墙里嗡嗡响——像有个不会落山的小太阳。");
            AddIntel("Mouse_PremiumSold_04", "premium", "昨晚主人雨靴来回两趟——一趟带湿泥，一趟朝鸡舍。");
            AddIntel("Mouse_PremiumSold_05", "premium", "昨晚那阵'水怪低吼'其实是大黄打的呼噜。");
            AddIntel("Mouse_PremiumSold_06", "premium", "黑猫昨晚在篱笆边和自己的影子咬耳朵。");
            AddIntel("Mouse_PremiumSold_07", "premium", "以前还有一家卖情报的，被老鼠兄弟搞垮了。");
            AddIntel("Mouse_PremiumSold_08", "premium", "Flash 昨晚从宽叶上飞起来盘旋了一圈。");
        }

        void Add(string id, GameObject go, string cond)
        {
            _entries[id] = new EntryDef { Go = go, Cond = cond };
        }

        void AddIntel(string key, string tier, string text)
        {
            _intelTier[key] = tier;
            _intelText[key] = text;
        }

        void CheckAllEntries()
        {
            foreach (var kv in _entries)
            {
                bool unlocked;
                _unlocked.TryGetValue(kv.Key, out unlocked);
                if (kv.Value.Go != null && !unlocked && ConditionEvaluator.EvalUnlockString(kv.Value.Cond))
                    Unlock(kv.Key);
            }
            Reconcile();
        }

        void Unlock(string id)
        {
            EntryDef def;
            if (!_entries.TryGetValue(id, out def) || def.Go == null) return;
            bool already;
            if (_unlocked.TryGetValue(id, out already) && already) return;
            _unlocked[id] = true;
            def.Go.SetActive(true);
            QueueReveal(id, def.Go);
            if (id == "E10")
            {
                _page = 2;
                if (IsOpen()) { HidePages(); ShowPage(); }
            }
            Reconcile();
        }

        void Reconcile()
        {
            foreach (var link in _links)
            {
                if (IsUnlocked(link.A) && IsUnlocked(link.B))
                {
                    if (link.Gos != null) SetGos(link.Gos, true);
                    else if (link.Go != null) link.Go.SetActive(true);
                }
            }
            foreach (var mod in _mods)
            {
                if (mod.Go == null) continue;
                var show = (!string.IsNullOrEmpty(mod.EntryUnlock) && IsUnlocked(mod.EntryUnlock))
                           || (!string.IsNullOrEmpty(mod.Cond) && ConditionEvaluator.EvalUnlockString(mod.Cond));
                if (show) mod.Go.SetActive(true);
            }
        }

        bool IsUnlocked(string id)
        {
            bool v;
            return _unlocked.TryGetValue(id, out v) && v;
        }

        void QueueReveal(string id, GameObject go)
        {
            if (go == null || _pending.ContainsKey(id) || _anims.ContainsKey(id)) return;
            var cg = GetGroup(go);
            cg.alpha = 0f;
            var page = ResolvePage(go);
            if (page <= 0) { cg.alpha = 1f; return; }
            _pending[id] = new Pending { Group = cg, Page = page };
            RevealIcon();
            AudioDirector.PlayAudio("audio_unlockClue");
            if (!IsOpen()) PlayIconBounce();
            else TryStartPending();
            UpdatePageDots();
        }

        void TryStartPending()
        {
            if (!IsOpen()) return;
            var started = new List<string>();
            foreach (var kv in _pending)
            {
                if (kv.Value.Page != _page || kv.Value.Group == null) continue;
                _anims[kv.Key] = new Anim { Group = kv.Value.Group, Phase = "fade", Elapsed = 0f };
                kv.Value.Group.alpha = 0f;
                started.Add(kv.Key);
            }
            for (var i = 0; i < started.Count; i++) _pending.Remove(started[i]);
            if (started.Count > 0)
            {
                AudioDirector.PlayAudio("audio_showClue");
                UpdatePageDots();
            }
        }

        void SpawnIntel(string varName, bool fade)
        {
            if (_intelSpawned.ContainsKey(varName)) return;
            if (!ConditionEvaluator.EvalUnlockString(varName + "==true")) return;
            string tier;
            if (!_intelTier.TryGetValue(varName, out tier)) return;
            var prefab = tier == "premium" ? intelPremiumPrefab : intelCheapPrefab;
            if (prefab == null) return;
            Transform parent = null;
            var maxLeft = intelLeftColumnMax <= 0 ? 9 : intelLeftColumnMax;
            if (intelLayoutLeft != null && intelLayoutLeft.transform.childCount < maxLeft)
                parent = intelLayoutLeft.transform;
            else if (intelLayoutRight != null) parent = intelLayoutRight.transform;
            else if (intelLayoutLeft != null) parent = intelLayoutLeft.transform;
            if (parent == null) return;
            var instance = Instantiate(prefab, parent);
            instance.SetActive(true);
            var label = instance.GetComponentInChildren<Text>(true);
            string text;
            if (label != null && _intelText.TryGetValue(varName, out text)) label.text = text;
            if (fade) QueueReveal("intel_" + varName, instance);
            else GetGroup(instance).alpha = 1f;
            _intelSpawned[varName] = instance;
        }

        void RebuildIntel()
        {
            ClearLayout(intelLayoutLeft);
            ClearLayout(intelLayoutRight);
            _intelSpawned.Clear();
            for (var i = 0; i < IntelOrder.Length; i++)
            {
                if (ConditionEvaluator.EvalUnlockString(IntelOrder[i] + "==true"))
                    SpawnIntel(IntelOrder[i], false);
            }
        }

        static void ClearLayout(GameObject layout)
        {
            if (layout == null) return;
            for (var i = layout.transform.childCount - 1; i >= 0; i--)
                Destroy(layout.transform.GetChild(i).gameObject);
        }

        void OnOpenClick()
        {
            if (GameEvents.DialogueActive || IsOpen()) return;
            AudioDirector.PlayAudio("audio_openNote");
            HideHud();
            boolPanel.SetActive(true);
            if (close != null) close.gameObject.SetActive(true);
            GameEvents.RaiseNotebookOpened();
            UpdateRedDot();
            CheckAllEntries();
            HidePages();
            ShowPage();
        }

        void OnCloseClick()
        {
            AudioDirector.PlayAudio("audio_closeNote");
            boolPanel.SetActive(false);
            RestoreHud();
            if (_iconVisible && open != null) open.gameObject.SetActive(true);
            if (close != null) close.gameObject.SetActive(false);
            _lastOpenInteractable = null;
            GameEvents.RaiseNotebookClosed();
            RefreshOpenInteractable();
            UpdateRedDot();
        }

        void GoToPage(int page)
        {
            if (pageContents == null || page < 1 || page > pageContents.Length || page == _page) return;
            AudioDirector.PlayAudio("audio_switchPage");
            _page = page;
            HidePages();
            ShowPage();
        }

        void HidePages()
        {
            if (pageContents == null) return;
            for (var i = 0; i < pageContents.Length; i++)
                if (pageContents[i] != null) pageContents[i].SetActive(false);
        }

        void ShowPage()
        {
            if (pageContents == null || pageContents.Length == 0) return;
            var idx = _page - 1;
            if (idx >= 0 && idx < pageContents.Length && pageContents[idx] != null)
                pageContents[idx].SetActive(true);
            TryStartPending();
        }

        bool IsOpen() { return boolPanel != null && boolPanel.activeSelf; }

        void BindTabs(Button[] tabs, int fromPage)
        {
            if (tabs == null) return;
            for (var i = 0; i < tabs.Length; i++)
            {
                var target = i + 1;
                if (tabs[i] != null && target != fromPage)
                    tabs[i].onClick.AddListener(() => GoToPage(target));
            }
        }

        void CollectDots()
        {
            Collect(page1TabBtns);
            Collect(page2TabBtns);
            Collect(page3TabBtns);
            Collect(page4TabBtns);
        }

        void Collect(Button[] tabs)
        {
            if (tabs == null) return;
            for (var i = 0; i < tabs.Length; i++)
            {
                if (tabs[i] == null) continue;
                var dot = tabs[i].transform.Find("Dot");
                if (dot == null) continue;
                var page = i + 1;
                List<GameObject> list;
                if (!_pageDots.TryGetValue(page, out list))
                {
                    list = new List<GameObject>();
                    _pageDots[page] = list;
                }
                list.Add(dot.gameObject);
                dot.gameObject.SetActive(false);
            }
        }

        void UpdatePageDots()
        {
            for (var page = 1; page <= 4; page++)
            {
                List<GameObject> dots;
                if (!_pageDots.TryGetValue(page, out dots)) continue;
                var show = PageHasPending(page);
                for (var i = 0; i < dots.Count; i++)
                    if (dots[i] != null) dots[i].SetActive(show);
            }
            UpdateRedDot();
        }

        bool PageHasPending(int page)
        {
            foreach (var kv in _pending)
                if (kv.Value.Page == page) return true;
            return false;
        }

        bool HasPending()
        {
            return _pending.Count > 0;
        }

        void UpdateRedDot()
        {
            var show = HasPending() && !IsOpen();
            if (openRedDot != null) openRedDot.SetActive(show);
            if (show && !_lastRedDot) PlayIconBounce();
            _lastRedDot = show;
        }

        void RefreshOpenInteractable()
        {
            if (open == null) return;
            var can = !GameEvents.DialogueActive;
            if (_lastOpenInteractable == can) return;
            _lastOpenInteractable = can;
            open.interactable = can;
        }

        void RevealIcon()
        {
            if (_iconVisible || open == null) return;
            _iconVisible = true;
            open.gameObject.SetActive(true);
            _lastOpenInteractable = null;
            RefreshOpenInteractable();
        }

        void ResolveIcon()
        {
            if (_openIcon != null || open == null) return;
            var t = open.transform.Find("NoteImage");
            if (t == null) return;
            _openIcon = t;
            _iconBase = t.localScale;
        }

        void PlayIconBounce()
        {
            ResolveIcon();
            if (_openIcon == null) return;
            _iconBounce = true;
            _iconElapsed = 0f;
        }

        void TickIcon(float dt)
        {
            if (!_iconBounce) return;
            ResolveIcon();
            if (_openIcon == null) { _iconBounce = false; return; }
            _iconElapsed += dt;
            var p = _iconElapsed / IconBounceDuration;
            if (p >= 1f)
            {
                _openIcon.localScale = _iconBase;
                _iconBounce = false;
                return;
            }
            var s = 1f + (IconBouncePeak - 1f) * Mathf.Sin(p * Mathf.PI);
            _openIcon.localScale = _iconBase * s;
        }

        int ResolvePage(GameObject go)
        {
            if (go == null || pageContents == null) return 0;
            var t = go.transform;
            for (var i = 0; i < pageContents.Length; i++)
            {
                if (pageContents[i] != null && t.IsChildOf(pageContents[i].transform))
                    return i + 1;
            }
            return 0;
        }

        static CanvasGroup GetGroup(GameObject go)
        {
            var cg = go.GetComponent<CanvasGroup>();
            if (cg == null) cg = go.AddComponent<CanvasGroup>();
            return cg;
        }

        static void SetGos(GameObject[] gos, bool on)
        {
            if (gos == null) return;
            for (var i = 0; i < gos.Length; i++)
                if (gos[i] != null) gos[i].SetActive(on);
        }

        void HideHud()
        {
            _hiddenHud = new List<HudState>();
            if (hideOnOpen == null) return;
            for (var i = 0; i < hideOnOpen.Length; i++)
            {
                var go = hideOnOpen[i];
                if (go == null) continue;
                _hiddenHud.Add(new HudState { Go = go, WasActive = go.activeSelf });
                go.SetActive(false);
            }
        }

        void RestoreHud()
        {
            if (_hiddenHud == null) return;
            for (var i = 0; i < _hiddenHud.Count; i++)
                if (_hiddenHud[i].Go != null) _hiddenHud[i].Go.SetActive(_hiddenHud[i].WasActive);
            _hiddenHud = null;
        }

        void AutoBindFields()
        {
            var flags = System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.Public;
            var fields = GetType().GetFields(flags);
            for (var i = 0; i < fields.Length; i++)
            {
                var f = fields[i];
                if (f.FieldType == typeof(GameObject) && f.GetValue(this) == null)
                {
                    var found = FindDeep(transform, f.Name);
                    if (found != null) f.SetValue(this, found);
                }
                else if (f.FieldType == typeof(Button) && f.GetValue(this) == null)
                {
                    var found = FindDeep(transform, f.Name);
                    if (found != null) f.SetValue(this, found.GetComponent<Button>());
                }
            }
            if (boolPanel == null)
            {
                var p = FindDeep(transform, "boolPanel");
                if (p != null) boolPanel = p;
            }
        }

        static GameObject FindDeep(Transform root, string name)
        {
            if (root.name == name) return root.gameObject;
            for (var i = 0; i < root.childCount; i++)
            {
                var found = FindDeep(root.GetChild(i), name);
                if (found != null) return found;
            }
            return null;
        }
    }
}
