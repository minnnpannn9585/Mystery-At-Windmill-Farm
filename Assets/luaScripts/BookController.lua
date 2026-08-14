-- 侦探笔记本 · doc 09 §9.2.1 / §9.2.2
-- Inspector 接线：每条目 / 每条连线 / 每个修饰各拖一个 GameObject（字段名 = 下表名）
--
-- 壳层：open, openRedDot, boolPanel, pageContents（含第 4 页老鼠情报）, hideOnOpen
-- 翻页：每页底部 4 个页签 pageNTabBtns[1..4]→跳到第 N 页；本页对应槽位可留空
-- 红点：openRedDot + 页签子节点 Dot；有 pendingReveals（已解锁未观看）时显示
-- 入口：开局隐藏 open；线索入册时显示 + NoteImage 弹跳（含已有未看线索时再解锁）；关本后红点亮起时同款弹跳
-- 条目 entry_*（33）| 老鼠 prefab + LayoutLeft/Right | 连线 link_*（15，断线段用 GameObject[]：E17×2、D06↔D07）| 修饰 mod_*（13）
-- 详见 MissingEggDoc-main/docs/09-侦探笔记本.md §9.8 与 docs/IMPLEMENTATION.md §6

---@var open :UnityEngine.UI.Button
---@var close :UnityEngine.UI.Button
---@var openRedDot :UnityEngine.GameObject
---@var boolPanel :UnityEngine.GameObject
---@var hideOnOpen :UnityEngine.GameObject[] -- 打开笔记本时关闭的左侧 HUD（Inspector 拖入）
---@var pageContents :UnityEngine.GameObject[]
---@var page1TabBtns :UnityEngine.UI.Button[]
---@var page2TabBtns :UnityEngine.UI.Button[]
---@var page3TabBtns :UnityEngine.UI.Button[]
---@var page4TabBtns :UnityEngine.UI.Button[]

---@var entry_D01 :UnityEngine.GameObject
---@var entry_E01 :UnityEngine.GameObject
---@var entry_E02 :UnityEngine.GameObject
---@var entry_D02 :UnityEngine.GameObject
---@var entry_D03 :UnityEngine.GameObject
---@var entry_FrogImage :UnityEngine.GameObject
---@var entry_E12 :UnityEngine.GameObject
---@var entry_D04 :UnityEngine.GameObject
---@var entry_D05 :UnityEngine.GameObject
---@var entry_D06 :UnityEngine.GameObject
---@var entry_E23 :UnityEngine.GameObject
---@var entry_E25 :UnityEngine.GameObject
---@var entry_E04 :UnityEngine.GameObject
---@var entry_D07 :UnityEngine.GameObject
---@var entry_D08 :UnityEngine.GameObject
---@var entry_E06 :UnityEngine.GameObject
---@var entry_E07 :UnityEngine.GameObject
---@var entry_E08 :UnityEngine.GameObject
---@var entry_E09 :UnityEngine.GameObject
---@var entry_E27 :UnityEngine.GameObject
---@var entry_E34 :UnityEngine.GameObject
---@var entry_E10 :UnityEngine.GameObject
---@var entry_D09 :UnityEngine.GameObject
---@var entry_E13 :UnityEngine.GameObject
---@var entry_E14 :UnityEngine.GameObject
---@var entry_E15 :UnityEngine.GameObject
---@var entry_E16 :UnityEngine.GameObject
---@var entry_E28 :UnityEngine.GameObject
---@var entry_E17 :UnityEngine.GameObject
---@var entry_E18 :UnityEngine.GameObject
---@var entry_D12 :UnityEngine.GameObject
---@var entry_D13 :UnityEngine.GameObject
---@var entry_D14 :UnityEngine.GameObject
---@var entry_D18 :UnityEngine.GameObject

---@var intelCheapPrefab :UnityEngine.GameObject
---@var intelPremiumPrefab :UnityEngine.GameObject
---@var intelLayoutLeft :UnityEngine.GameObject
---@var intelLayoutRight :UnityEngine.GameObject
---@var intelLeftColumnMax :int = 9

---@var link_D03_D04 :UnityEngine.GameObject
---@var link_D03_D05 :UnityEngine.GameObject
---@var link_D03_D06 :UnityEngine.GameObject
---@var link_D05_E23 :UnityEngine.GameObject
---@var link_E17_D05 :UnityEngine.GameObject[]
---@var link_E17_E23 :UnityEngine.GameObject[]
---@var link_D06_D07 :UnityEngine.GameObject[]
---@var link_E04_E06 :UnityEngine.GameObject
---@var link_E07_E08 :UnityEngine.GameObject
---@var link_E08_E27 :UnityEngine.GameObject
---@var link_E27_E34 :UnityEngine.GameObject
---@var link_E08_E34 :UnityEngine.GameObject
---@var link_D13_E12 :UnityEngine.GameObject
---@var link_D13_D12 :UnityEngine.GameObject
---@var link_D14_D12 :UnityEngine.GameObject

---@var mod_D03_strike :UnityEngine.GameObject
---@var mod_D03_note :UnityEngine.GameObject
---@var mod_D07_strike :UnityEngine.GameObject
---@var mod_D07_note :UnityEngine.GameObject
---@var mod_E04_borrowed :UnityEngine.GameObject
---@var mod_E04_ladderPic :UnityEngine.GameObject
---@var mod_E06_done :UnityEngine.GameObject
---@var mod_D08_got :UnityEngine.GameObject
---@var mod_E08_glassNote :UnityEngine.GameObject
---@var mod_D12_got :UnityEngine.GameObject
---@var mod_D12_fishPic :UnityEngine.GameObject
---@var mod_E13_strike :UnityEngine.GameObject
---@var mod_E13_note :UnityEngine.GameObject
---@end

local BOOK_DEBUG = false
local FADE_DURATION = 1.0
local BLINK_DURATION = 0.35
local BLINK_MIN_ALPHA = 0.15
local ICON_BOUNCE_DURATION = 0.4
local ICON_BOUNCE_PEAK = 2.0

local currentIndex = 1
local unlockedEntries = {}
-- 已解锁、尚未首次翻到所在页：{ canvasGroup, pageIndex }
local pendingReveals = {}
-- 正在播渐显 / 闪烁：{ canvasGroup, phase = "fade"|"blink", elapsed }
local revealAnims = {}

local ENTRY_DEFS = nil
local LINK_DEFS = nil
local MOD_DEFS = nil
local INTEL_CONTENT = nil
local INTEL_VAR_ORDER = nil

local intelSpawned = {}
local intelSpawnOrder = {}
-- pageIndex → Dot GameObject[]（从各页 pageNTabBtns 子节点 "Dot" 收集）
local pageTabDots = {}
-- 入口图标弹跳：单次 1→peak→1，缩放 NoteImage，避免改 Button 影响 Layout
local openIconTf = nil
local openIconBaseScale = nil
local iconBouncePlaying = false
local iconBounceElapsed = 0
local lastRedDotShow = false
local lastOpenInteractable = nil
-- 首条线索入册前隐藏笔记本入口
local notebookIconVisible = false
-- 打开本子时暂藏的左侧 HUD：{ { go, wasActive }, ... }
local hiddenHudStates = nil

local function Dbg(msg)
    if BOOK_DEBUG then
        print("[BookController] " .. msg)
    end
end

local function GetCanvasGroup(obj)
    if not obj then return nil end
    local canvasGroup = obj:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
    if not canvasGroup then
        canvasGroup = obj:AddComponent(typeof(CS.UnityEngine.CanvasGroup))
    end
    return canvasGroup
end

local function BuildCatalog()
    ENTRY_DEFS = {
        D01 = { go = entry_D01, cond = "Shufen_CommissionDone==true" },
        E01 = { go = entry_E01, cond = "E01_ViewCharcoal==true" },
        E02 = { go = entry_E02, cond = "E02_ViewFeather==true" },
        D02 = { go = entry_D02, cond = "E03_Overheard==true" },
        D03 = { go = entry_D03, cond = "ChickStatus>=2" },
        -- 青蛙图片与 E12 绿垫文字必须是两个独立（非父子）引用，才能分时解锁。
        FROG_IMAGE = { go = entry_FrogImage, cond = "Frog_FirstMeetShown==true" },
        E12 = { go = entry_E12, cond = "E12_ViewGreenPad==true" },
        D04 = { go = entry_D04, cond = "Frog_WaterMonsterQueried==true" },
        D05 = { go = entry_D05, cond = "Frog_WaterMonsterQueried==true" },
        D06 = { go = entry_D06, cond = "Frog_WaterMonsterQueried==true" },
        E23 = { go = entry_E23, cond = "E23_dabble==true" },
        E25 = { go = entry_E25, cond = "E25_ChickenFootprints==true" },
        E04 = { go = entry_E04, cond = "DogStatus>=2" },
        D07 = { go = entry_D07, cond = "DogStatus>=2" },
        D08 = { go = entry_D08, cond = "Shufen_DaHuangWakeAsked==true|Chick_WakeDogHintShown==true|Mouse_CheapSold_07==true" },
        E06 = { go = entry_E06, cond = "E06_ViewNeedLadder==true" },
        E07 = { go = entry_E07, cond = "E07_ViewNapSpot==true" },
        E08 = { go = entry_E08, cond = "E08_ViewBurnMark==true" },
        E09 = { go = entry_E09, cond = "E09_AnimalPawPrints==true" },
        E27 = { go = entry_E27, cond = "E27_ColorReflective==true" },
        E34 = { go = entry_E34, cond = "E34_Glass==true" },
        E10 = { go = entry_E10, cond = "E10_ViewWhiteStone==true" },
        D09 = { go = entry_D09, cond = "ChickStatus>=3" },
        E13 = { go = entry_E13, cond = "E13_ViewDoorBlocked==true" },
        E14 = { go = entry_E14, cond = "E14_ViewCatDoor==true" },
        E15 = { go = entry_E15, cond = "E15_ViewFoodBowl==true" },
        E16 = { go = entry_E16, cond = "E16_ViewFur==true" },
        E28 = { go = entry_E28, cond = "E28_ViewTreeScratch==true" },
        E17 = { go = entry_E17, cond = "E17_ViewEmptyBucket==true" },
        E18 = { go = entry_E18, cond = "E18_ViewBootprints==true" },
        D12 = { go = entry_D12, cond = "BlackCat_MintFishPending==true" },
        D13 = { go = entry_D13, cond = "BlackCat_MintFishPending==true&E12_ViewGreenPad==true" },
        D14 = { go = entry_D14, cond = "Mouse_MintFishPaid==true" },
        D18 = { go = entry_D18, cond = "BlackCat_Entered==true" },
    }

    INTEL_CONTENT = {
        Mouse_CheapSold_01 = { tier = "cheap", text = "大黄的项圈是镀银的。" },
        Mouse_CheapSold_02 = { tier = "cheap", text = "青蛙年轻时是这片水域的第一情圣。" },
        Mouse_CheapSold_03 = { tier = "cheap", text = "淑芬十年前是隔壁村的斗鸡冠军。" },
        Mouse_CheapSold_04 = { tier = "cheap", text = "Flash 是隔壁农场派来的商业间谍，画了三年地图了。" },
        Mouse_CheapSold_05 = { tier = "cheap", text = "主人是鸡科圣手，尤其精通《母鸡的产后护理》。" },
        Mouse_CheapSold_06 = { tier = "cheap", text = "大橡树会走路——一年挪一厘米。" },
        Mouse_CheapSold_07 = { tier = "cheap", text = "上次大黄偷喝主人的发酵苹果渣，是淑芬用谷物泡水叫醒的。" },
        Mouse_CheapSold_08 = { tier = "cheap", text = "主人这几天常趴窗看鸡舍方向——看完又不进去。" },
        Mouse_CheapSold_09 = { tier = "cheap", text = "小鸡昨晚都缩在鸡舍里不出来，像在等什么" },
        Mouse_CheapSold_10 = { tier = "cheap", text = "黑猫前天下午自己爬上过谷仓顶" },
        Mouse_PremiumSold_01 = { tier = "premium", text = "水怪是老鼠兄弟随口编的。" },
        Mouse_PremiumSold_02 = { tier = "premium", text = "乌鸦前天早上从鸡舍门口草丛搞了个东西回屋顶。" },
        Mouse_PremiumSold_03 = { tier = "premium", text = "昨晚红顶屋里亮黄灯，墙里嗡嗡响——像有个不会落山的小太阳。" },
        Mouse_PremiumSold_04 = { tier = "premium", text = "昨晚主人雨靴来回两趟——一趟带湿泥，一趟朝鸡舍。" },
        Mouse_PremiumSold_05 = { tier = "premium", text = "昨晚那阵'水怪低吼'其实是大黄打的呼噜。" },
        Mouse_PremiumSold_06 = { tier = "premium", text = "黑猫昨晚在篱笆边和自己的影子咬耳朵。" },
        Mouse_PremiumSold_07 = { tier = "premium", text = "以前还有一家卖情报的，被老鼠兄弟搞垮了。" },
        Mouse_PremiumSold_08 = { tier = "premium", text = "Flash 昨晚从宽叶上飞起来盘旋了一圈。" },
    }

    INTEL_VAR_ORDER = {
        "Mouse_CheapSold_01", "Mouse_CheapSold_02", "Mouse_CheapSold_03", "Mouse_CheapSold_04",
        "Mouse_CheapSold_05", "Mouse_CheapSold_06", "Mouse_CheapSold_07", "Mouse_CheapSold_08",
        "Mouse_CheapSold_09", "Mouse_CheapSold_10",
        "Mouse_PremiumSold_01", "Mouse_PremiumSold_02", "Mouse_PremiumSold_03", "Mouse_PremiumSold_04",
        "Mouse_PremiumSold_05", "Mouse_PremiumSold_06", "Mouse_PremiumSold_07", "Mouse_PremiumSold_08",
    }

    LINK_DEFS = {
        { go = link_D03_D04,  ends = { "D03", "D04" } },
        { go = link_D03_D05,  ends = { "D03", "D05" } },
        { go = link_D03_D06,  ends = { "D03", "D06" } },
        { go = link_D05_E23,  ends = { "D05", "E23" } },
        { gos = link_E17_D05, ends = { "E17", "D05" } },
        { gos = link_E17_E23, ends = { "E17", "E23" } },
        { gos = link_D06_D07, ends = { "D06", "D07" } },
        { go = link_E04_E06,  ends = { "E04", "E06" } },
        { go = link_E07_E08,  ends = { "E07", "E08" } },
        { go = link_E08_E27,  ends = { "E08", "E27" } },
        { go = link_E27_E34,  ends = { "E27", "E34" } },
        { go = link_E08_E34,  ends = { "E08", "E34" } },
        { go = link_D13_E12,  ends = { "D13", "E12" } },
        { go = link_D13_D12,  ends = { "D13", "D12" } },
        { go = link_D14_D12,  ends = { "D14", "D12" } },
    }

    -- entryUnlock：指定条目入册后显示；cond：全局变量条件（晚入册时入册当次一并 reconcile）
    MOD_DEFS = {
        { go = mod_D03_strike,    entryUnlock = "D09" },
        { go = mod_D03_note,      entryUnlock = "D09" },
        { go = mod_D07_strike,    entryUnlock = "E10" },
        { go = mod_D07_note,      entryUnlock = "E10" },
        { go = mod_E04_borrowed,  cond = "E06_LadderBorrowed==true" },
        { go = mod_E04_ladderPic, cond = "E06_LadderBorrowed==true" },
        { go = mod_E06_done,      cond = "E06_LadderPlaced==true" },
        { go = mod_D08_got,       cond = "E05_GrainSoakGet==true" },
        { go = mod_E08_glassNote, cond = "Crow_GlassBeadAsked==true" },
        { go = mod_D12_got,       cond = "MintFish_Obtained==true" },
        { go = mod_D12_fishPic,   cond = "MintFish_Obtained==true" },
        { go = mod_E13_strike,    cond = "BlackCat_Entered==true" },
        { go = mod_E13_note,      cond = "BlackCat_Entered==true" },
    }
end

local function IsMouseIntelVar(varName)
    if not varName then return false end
    return string.match(varName, "^Mouse_CheapSold_") ~= nil
        or string.match(varName, "^Mouse_PremiumSold_") ~= nil
end

local function GetLayoutChildCount(layoutGo)
    if not layoutGo then return 0 end
    return layoutGo.transform.childCount
end

local function ClearIntelLayouts()
    local function clearOne(layoutGo)
        if not layoutGo then return end
        local t = layoutGo.transform
        for i = t.childCount - 1, 0, -1 do
            CS.UnityEngine.Object.Destroy(t:GetChild(i).gameObject)
        end
    end
    clearOne(intelLayoutLeft)
    clearOne(intelLayoutRight)
    intelSpawned = {}
    intelSpawnOrder = {}
end

local function PickIntelLayoutParent()
    local maxLeft = intelLeftColumnMax
    if maxLeft == nil or maxLeft <= 0 then
        maxLeft = 9
    end
    if intelLayoutLeft and GetLayoutChildCount(intelLayoutLeft) < maxLeft then
        return intelLayoutLeft.transform
    end
    if intelLayoutRight then
        return intelLayoutRight.transform
    end
    return intelLayoutLeft and intelLayoutLeft.transform or nil
end

local function SetIntelTextOnInstance(instance, text)
    if not instance or not text then return end
    local textComp = instance:GetComponentInChildren(typeof(CS.UnityEngine.UI.Text), true)
    if textComp then
        textComp.text = text
    end
end

local function ResolvePageIndex(go)
    if not go or not pageContents then return nil end
    local t = go.transform
    for i = 0, pageContents.Length - 1 do
        local page = pageContents[i]
        if page and t:IsChildOf(page.transform) then
            return i + 1
        end
    end
    return nil
end

local function IsNotebookOpen()
    return boolPanel and boolPanel.activeSelf
end

local function PageHasPending(pageIndex)
    for _, info in pairs(pendingReveals) do
        if info.pageIndex == pageIndex then
            return true
        end
    end
    return false
end

local function HasAnyPending()
    for _ in pairs(pendingReveals) do
        return true
    end
    return false
end

local function IsDialogueActive()
    local mgr = _G["_DialogueManager"]
    if mgr and mgr.IsDialogueActive then
        return mgr.IsDialogueActive()
    end
    return false
end

local function ResolveOpenIcon()
    if openIconTf or not open then return end
    local t = open.transform:Find("NoteImage")
    if not t then return end
    openIconTf = t
    local s = t.localScale
    openIconBaseScale = CS.UnityEngine.Vector3(s.x, s.y, s.z)
end

local function PlayIconBounce()
    ResolveOpenIcon()
    if not openIconTf or not openIconBaseScale then return end
    iconBouncePlaying = true
    iconBounceElapsed = 0
end

local function TickIconBounce(dt)
    if not iconBouncePlaying then return end
    ResolveOpenIcon()
    if not openIconTf or not openIconBaseScale then
        iconBouncePlaying = false
        return
    end
    iconBounceElapsed = iconBounceElapsed + dt
    local progress = iconBounceElapsed / ICON_BOUNCE_DURATION
    if progress >= 1 then
        openIconTf.localScale = openIconBaseScale
        iconBouncePlaying = false
        return
    end
    -- sin(0..π)：1 → peak → 1，播完即停
    local s = 1 + (ICON_BOUNCE_PEAK - 1) * math.sin(progress * math.pi)
    openIconTf.localScale = CS.UnityEngine.Vector3(
        openIconBaseScale.x * s,
        openIconBaseScale.y * s,
        openIconBaseScale.z
    )
end

local function RefreshOpenInteractable()
    if not open then return end
    local canOpen = not IsDialogueActive()
    if lastOpenInteractable == canOpen then return end
    lastOpenInteractable = canOpen
    open.interactable = canOpen
end

local function RevealNotebookIcon()
    if notebookIconVisible or not open then return end
    notebookIconVisible = true
    open.gameObject:SetActive(true)
    lastOpenInteractable = nil
    RefreshOpenInteractable()
end

local function UpdateRedDot()
    local panelOpen = boolPanel and boolPanel.activeSelf
    local show = HasAnyPending() and not panelOpen
    if openRedDot then
        openRedDot:SetActive(show)
    end
    -- 关本后红点由隐→显（例如刚解锁时本子开着，关掉才看到红点）
    if show and not lastRedDotShow then
        PlayIconBounce()
    end
    lastRedDotShow = show
end

local function UpdatePageDots()
    for page = 1, 4 do
        local dots = pageTabDots[page]
        if dots then
            local show = PageHasPending(page)
            for _, go in ipairs(dots) do
                if go then
                    go:SetActive(show)
                end
            end
        end
    end
    UpdateRedDot()
end

local function CollectPageTabDots()
    pageTabDots = {}
    local function collect(tabs)
        if not tabs then return end
        for i = 0, tabs.Length - 1 do
            local btn = tabs[i]
            local targetPage = i + 1
            if btn then
                local dotTf = btn.transform:Find("Dot")
                if dotTf then
                    if not pageTabDots[targetPage] then
                        pageTabDots[targetPage] = {}
                    end
                    table.insert(pageTabDots[targetPage], dotTf.gameObject)
                    dotTf.gameObject:SetActive(false)
                end
            end
        end
    end
    collect(page1TabBtns)
    collect(page2TabBtns)
    collect(page3TabBtns)
    collect(page4TabBtns)
end

local function TryStartPendingReveals()
    if not IsNotebookOpen() then return end
    local started = {}
    for id, info in pairs(pendingReveals) do
        if info.pageIndex == currentIndex and info.canvasGroup then
            revealAnims[id] = {
                canvasGroup = info.canvasGroup,
                phase = "fade",
                elapsed = 0
            }
            info.canvasGroup.alpha = 0
            table.insert(started, id)
            Dbg("开始入册演出 " .. tostring(id) .. " @ page " .. tostring(currentIndex))
        end
    end
    for _, id in ipairs(started) do
        pendingReveals[id] = nil
    end
    if #started > 0 then
        _G["PlayAudio"]("audio_showClue")
        UpdatePageDots()
    end
end

local function QueueReveal(id, go)
    if not go then return end
    if pendingReveals[id] or revealAnims[id] then return end
    local canvasGroup = GetCanvasGroup(go)
    canvasGroup.alpha = 0
    local pageIdx = ResolvePageIndex(go)
    if not pageIdx then
        Dbg("QueueReveal 找不到页: " .. tostring(id))
        canvasGroup.alpha = 1
        return
    end
    pendingReveals[id] = {
        canvasGroup = canvasGroup,
        pageIndex = pageIdx
    }
    RevealNotebookIcon()
    _G["PlayAudio"]("audio_unlockClue")
    -- 本子关闭时每条新线索都弹跳；红点已亮时 UpdateRedDot 不会再触发边沿
    if not IsNotebookOpen() then
        PlayIconBounce()
    end
    if IsNotebookOpen() then
        TryStartPendingReveals()
    end
    UpdatePageDots()
end

local function SpawnIntelInstance(varName, withFade)
    if intelSpawned[varName] then
        return false
    end
    local content = INTEL_CONTENT and INTEL_CONTENT[varName]
    if not content or not CheckUnlockCondition(varName .. "==true") then
        return false
    end

    local prefab = content.tier == "premium" and intelPremiumPrefab or intelCheapPrefab
    if not prefab then
        Dbg("缺少情报 prefab: " .. tostring(content.tier))
        return false
    end

    local parent = PickIntelLayoutParent()
    if not parent then
        Dbg("缺少 intelLayoutLeft / intelLayoutRight")
        return false
    end

    local instance = CS.UnityEngine.Object.Instantiate(prefab, parent)
    instance.transform:SetParent(parent, false)
    instance:SetActive(true)
    SetIntelTextOnInstance(instance, content.text)

    if withFade then
        QueueReveal("intel_" .. varName, instance)
    else
        GetCanvasGroup(instance).alpha = 1
    end

    intelSpawned[varName] = instance
    table.insert(intelSpawnOrder, varName)
    Dbg("生成情报 " .. varName)
    return true
end

local function RebuildIntelFromSoldVars()
    if not INTEL_VAR_ORDER then return end
    ClearIntelLayouts()
    for _, varName in ipairs(INTEL_VAR_ORDER) do
        if CheckUnlockCondition(varName .. "==true") then
            SpawnIntelInstance(varName, false)
        end
    end
end

local function TrySpawnIntelOnVarChanged(varName)
    if not IsMouseIntelVar(varName) then return end
    if SpawnIntelInstance(varName, true) then
        return
    end
    -- 变量已 true 但实例已存在（重入）时忽略
end

local function IsEntryUnlocked(entryId)
    return unlockedEntries[entryId] == true
end

function CheckSingleCondition(subCond, globalVars)
    local pattern = "^([%w_]+)([<>!=]+)([%d]+)$"
    local name, op, val = string.match(subCond, pattern)

    if not name then
        local boolPattern = "^([%w_]+)==([a-z]+)$"
        name, val = string.match(subCond, boolPattern)
        if name and val then
            local var = globalVars[name]
            if not var then return false end
            local boolVal = (val == "true" or val == "1")
            return var.value == boolVal
        end
        return false
    end

    local var = globalVars[name]
    if not var then return false end

    local numVal = tonumber(val)
    if not numVal then return false end

    if op == ">=" then
        return var.value >= numVal
    elseif op == "<=" then
        return var.value <= numVal
    elseif op == ">" then
        return var.value > numVal
    elseif op == "<" then
        return var.value < numVal
    elseif op == "==" then
        return var.value == numVal
    elseif op == "!=" then
        return var.value ~= numVal
    end
    return false
end

function CheckUnlockCondition(condition)
    if not condition or condition == "" then return false end

    local globalVars = _G["_GlobalVariables"]
    if not globalVars then return false end

    local orGroups = {}
    for orPart in string.gmatch(condition, "[^|]+") do
        local trimmedOr = string.gsub(orPart, "^%s*(.-)%s*$", "%1")
        if trimmedOr ~= "" then
            table.insert(orGroups, trimmedOr)
        end
    end

    for _, orGroup in ipairs(orGroups) do
        local andOk = true
        for subCond in string.gmatch(orGroup, "[^&]+") do
            local trimmed = string.gsub(subCond, "^%s*(.-)%s*$", "%1")
            if trimmed ~= "" and not CheckSingleCondition(trimmed, globalVars) then
                andOk = false
                break
            end
        end
        if andOk then return true end
    end
    return false
end

local function HideGo(go)
    if not go then return end
    go:SetActive(false)
end

local function ShowGo(go)
    if not go then return end
    go:SetActive(true)
end

local function HideGos(gos)
    if not gos then return end
    for i = 0, gos.Length - 1 do
        HideGo(gos[i])
    end
end

local function ShowGos(gos)
    if not gos then return end
    for i = 0, gos.Length - 1 do
        ShowGo(gos[i])
    end
end

local function UnlockEntry(entryId)
    local def = ENTRY_DEFS and ENTRY_DEFS[entryId]
    if not def or not def.go or unlockedEntries[entryId] then
        return false
    end

    unlockedEntries[entryId] = true
    def.go:SetActive(true)
    QueueReveal(entryId, def.go)

    Dbg("解锁条目 " .. entryId)

    if entryId == "E10" then
        currentIndex = 2
        if IsNotebookOpen() then
            HideAllPages()
            ShowCurrentPage()
        end
    end

    ReconcileLinksAndMods()
    return true
end

function ReconcileLinksAndMods()
    if not LINK_DEFS or not MOD_DEFS then return end

    for _, link in ipairs(LINK_DEFS) do
        if link.ends then
            local a = IsEntryUnlocked(link.ends[1])
            local b = IsEntryUnlocked(link.ends[2])
            if a and b then
                if link.gos then
                    ShowGos(link.gos)
                elseif link.go then
                    ShowGo(link.go)
                end
            end
        end
    end

    for _, mod in ipairs(MOD_DEFS) do
        if not mod.go then goto continue_mod end
        local shouldShow = false
        if mod.entryUnlock and IsEntryUnlocked(mod.entryUnlock) then
            shouldShow = true
        elseif mod.cond and CheckUnlockCondition(mod.cond) then
            shouldShow = true
        end
        if shouldShow then
            ShowGo(mod.go)
        end
        ::continue_mod::
    end
end

local function CheckAllEntries()
    if not ENTRY_DEFS then return end
    for entryId, def in pairs(ENTRY_DEFS) do
        if def.go and not unlockedEntries[entryId] and def.cond and CheckUnlockCondition(def.cond) then
            UnlockEntry(entryId)
        end
    end
    ReconcileLinksAndMods()
end

local function InitializeEntries()
    if not ENTRY_DEFS then return end
    for entryId, def in pairs(ENTRY_DEFS) do
        if def.go then
            def.go:SetActive(false)
            GetCanvasGroup(def.go).alpha = 0
            unlockedEntries[entryId] = false
        end
    end
end

local function InitializeLinksAndMods()
    if LINK_DEFS then
        for _, link in ipairs(LINK_DEFS) do
            if link.gos then
                HideGos(link.gos)
            elseif link.go then
                HideGo(link.go)
            end
        end
    end
    if MOD_DEFS then
        for _, mod in ipairs(MOD_DEFS) do
            HideGo(mod.go)
        end
    end
end

function BookController_OnVarChanged(varName)
    CheckAllEntries()
    TrySpawnIntelOnVarChanged(varName)
end

local function GoToPage(pageIndex)
    if not pageContents or pageContents.Length == 0 then return end
    if pageIndex < 1 or pageIndex > pageContents.Length then return end
    if pageIndex == currentIndex then return end
    _G["PlayAudio"]("audio_switchPage")
    currentIndex = pageIndex
    HideAllPages()
    ShowCurrentPage()
end

local function BindPageTabBtns(tabs, fromPage)
    if not tabs then return end
    for i = 0, tabs.Length - 1 do
        local btn = tabs[i]
        local targetPage = i + 1
        if btn and targetPage ~= fromPage then
            local target = targetPage
            btn.onClick:AddListener(function()
                GoToPage(target)
            end)
        end
    end
end

function Start()
    BuildCatalog()
    boolPanel:SetActive(false)
    if open then
        open.gameObject:SetActive(false)
        notebookIconVisible = false
        open.onClick:AddListener(OnOpenClick)
    end
    if close then close.onClick:AddListener(OnCloseClick) end
    BindPageTabBtns(page1TabBtns, 1)
    BindPageTabBtns(page2TabBtns, 2)
    BindPageTabBtns(page3TabBtns, 3)
    BindPageTabBtns(page4TabBtns, 4)
    CollectPageTabDots()

    InitializeEntries()
    InitializeLinksAndMods()
    RebuildIntelFromSoldVars()
    HideAllPages()
    ShowCurrentPage()
    ResolveOpenIcon()
    RefreshOpenInteractable()
    UpdatePageDots()

    _G["BookController_OnVarChanged"] = BookController_OnVarChanged
    _G["BookController_UnlockMouseIntel"] = function(varName)
        BookController_OnVarChanged(varName)
    end

    CheckAllEntries()
    TryRegisterEndingController()
end

function TryRegisterEndingController()
    if _G["EndingController_Start"] then return true end

    local notebookGo = CS.UnityEngine.GameObject.Find("Notebook")
    if not notebookGo then return false end
    local endingTf = notebookGo.transform:Find("Ending")
    if not endingTf then return false end
    local endingGo = endingTf.gameObject

    local scripts = endingGo:GetComponents(typeof(DouyinScript))
    if not scripts then return false end

    local endingDs = nil
    for i = 0, scripts.Length - 1 do
        local ds = scripts[i]
        if ds and ds.script and ds.script.EndingController_Start then
            endingDs = ds
            break
        end
    end

    if not endingDs then
        for i = 0, scripts.Length - 1 do
            local ds = scripts[i]
            if ds then
                endingDs = ds
                break
            end
        end
    end

    if not endingDs then return false end

    -- 不激活 Ending（避免 Image 挡交互）；E20 触发时再打开
    _G["EndingController_Start"] = function()
        -- 始终先激活，保证 DouyinScript Start/Update 能跑
        if endingGo and not endingGo.activeSelf then
            endingGo:SetActive(true)
        end
        if endingDs.script and endingDs.script.EndingController_Start then
            endingDs.script.EndingController_Start()
        else
            print("[EndingController] ✗ 脚本未就绪，请确认 Ending 上已挂 EndingController.lua")
        end
    end
    return true
end

_G["EndingController_TryRegister"] = TryRegisterEndingController

function Update()
    local toRemove = {}
    local dt = CS.UnityEngine.Time.deltaTime
    RefreshOpenInteractable()
    TickIconBounce(dt)
    for id, info in pairs(revealAnims) do
        if not info.canvasGroup then
            table.insert(toRemove, id)
            goto continue_anim
        end
        info.elapsed = info.elapsed + dt
        if info.phase == "fade" then
            local progress = info.elapsed / FADE_DURATION
            if progress >= 1 then
                info.canvasGroup.alpha = 1
                info.phase = "blink"
                info.elapsed = 0
            else
                info.canvasGroup.alpha = progress
            end
        elseif info.phase == "blink" then
            local progress = info.elapsed / BLINK_DURATION
            if progress >= 1 then
                info.canvasGroup.alpha = 1
                table.insert(toRemove, id)
            else
                -- 三角波：1 → BLINK_MIN → 1
                local t = progress < 0.5 and (progress * 2) or (2 - progress * 2)
                info.canvasGroup.alpha = 1 - t * (1 - BLINK_MIN_ALPHA)
            end
        else
            table.insert(toRemove, id)
        end
        ::continue_anim::
    end
    for _, id in ipairs(toRemove) do
        revealAnims[id] = nil
    end
end
local function HideHudOnOpen()
    hiddenHudStates = {}
    if not hideOnOpen then
        return
    end
    for i = 0, hideOnOpen.Length - 1 do
        local go = hideOnOpen[i]
        if go then
            table.insert(hiddenHudStates, { go = go, wasActive = go.activeSelf })
            go:SetActive(false)
        end
    end
end

local function RestoreHudOnClose()
    if not hiddenHudStates then
        return
    end
    for _, info in ipairs(hiddenHudStates) do
        if info.go then
            info.go:SetActive(info.wasActive)
        end
    end
    hiddenHudStates = nil
end

function OnCloseClick()
    _G["PlayAudio"]("audio_closeNote")
    boolPanel:SetActive(false)
    RestoreHudOnClose()
    if notebookIconVisible and open then
        open.gameObject:SetActive(true)
    end
    close.gameObject:SetActive(false)
    lastOpenInteractable = nil
    RefreshOpenInteractable()
    UpdateRedDot()
end
function OnOpenClick()
    if IsDialogueActive() then
        return
    end
    if IsNotebookOpen() then
        return
    end

    _G["PlayAudio"]("audio_openNote")
    HideHudOnOpen()
    boolPanel:SetActive(true)
    -- 打开面板后仍保留笔记本入口 icon
    close.gameObject:SetActive(true)
    if boolPanel.activeSelf then
        UpdateRedDot()
        CheckAllEntries()
        HideAllPages()
        ShowCurrentPage()
    end
end

function HideAllPages()
    if not pageContents then return end
    for i = 0, pageContents.Length - 1 do
        pageContents[i]:SetActive(false)
    end
end

function ShowCurrentPage()
    if not pageContents or pageContents.Length == 0 then return end
    local idx = currentIndex - 1
    if idx >= 0 and idx < pageContents.Length then
        pageContents[idx]:SetActive(true)
    end
    TryStartPendingReveals()
end
