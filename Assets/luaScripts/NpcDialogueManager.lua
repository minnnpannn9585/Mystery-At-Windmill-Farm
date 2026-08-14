--对话配置文件
---@var dialoguePanel :UnityEngine.GameObject
---@var playerNamePanel :UnityEngine.GameObject
---@var npcNamePanel :UnityEngine.GameObject
---@var npcName :UnityEngine.UI.Text
---@var npcSprite :UnityEngine.UI.Image
---@var playerSprite :UnityEngine.UI.Image
---@var playerExclamation :UnityEngine.GameObject
---@var playerQuestion :UnityEngine.GameObject
---@var npcDialogueText :UnityEngine.UI.Text
---@var next :UnityEngine.UI.Button
---@var playerPanel :UnityEngine.GameObject
---@var playerPanelBtn :UnityEngine.UI.Button
-- 立绘引用（拖切好的 Sprite；NpcSprite key 见括号）
---@var 立绘_淑芬_守望 :UnityEngine.Sprite
---@var 立绘_淑芬_护雏 :UnityEngine.Sprite
---@var 立绘_淑芬_团聚 :UnityEngine.Sprite
---@var 立绘_大黄_醉倒 :UnityEngine.Sprite
---@var 立绘_大黄_执勤 :UnityEngine.Sprite
---@var 立绘_大黄_振奋 :UnityEngine.Sprite
---@var 立绘_悲伤蛙_丧 :UnityEngine.Sprite
---@var 立绘_悲伤蛙_介入 :UnityEngine.Sprite
---@var 立绘_老鼠_兜售 :UnityEngine.Sprite
---@var 立绘_老鼠_八卦 :UnityEngine.Sprite
---@var 立绘_老鼠_发怵 :UnityEngine.Sprite
---@var 立绘_小鸡_装酷 :UnityEngine.Sprite
---@var 立绘_小鸡_心虚 :UnityEngine.Sprite
---@var 立绘_小鸡_愧疚 :UnityEngine.Sprite
---@var 立绘_小鸡_背对 :UnityEngine.Sprite
---@var 立绘_乌鸦_得意 :UnityEngine.Sprite
---@var 立绘_乌鸦_吝啬 :UnityEngine.Sprite
---@var 立绘_乌鸦_叫嚣 :UnityEngine.Sprite
---@var 立绘_黑猫_高傲 :UnityEngine.Sprite
---@var 立绘_黑猫_审视 :UnityEngine.Sprite
---@var 立绘_黑猫_炸毛 :UnityEngine.Sprite
---@var 立绘_闪电蜗牛_待机 :UnityEngine.Sprite
---@var 立绘_闪电蜗牛_闪电蜗牛 :UnityEngine.Sprite
---@var 立绘_玩家_正常 :UnityEngine.Sprite
---@var 立绘_玩家_惊讶 :UnityEngine.Sprite
---@var 立绘_玩家_疑惑 :UnityEngine.Sprite
---@end

local dialogueManager = {}

-- 私有变量
local currentDialogueID = -1
local allSprites = {}
local isWaitingForChoice = false
local currentOptions = {}
local optionButtons = {}

-- 打字机效果相关变量
local typingSpeed = 0.05
local isTyping = false
local typingTimer = 0
local currentTypingIndex = 0
local fullDialogueText = ""
local currentDataCache = nil

-- 选项逐个显示动画相关变量
local isAnimatingOptions = false
local optionAnimationTimer = 0
local currentAnimatingOptionIndex = 0
local optionAnimationSpeed = 0.2

-- ========== 选项：下一段若玩家先说话则不播选项；否则先播选项再 Next 跳转 ==========
local selectedOptionCache = nil
local isWaitingForNextAfterOption = false
local externalDialogueConfig = nil -- 动态加载的外部对话数据
local unlockedBranchCache = {}     -- 已处理过的分支缓存，防止同一节点重复解锁
local lastPortraitSpriteKey = nil  -- 描述行沿用上一句 NPC 立绘

-- World Debugger 对话调试（过滤关键字 [Dialogue]）
local DIALOGUE_DEBUG = false

local function Dbg(msg)
    if DIALOGUE_DEBUG then
        print("[Dialogue] " .. msg)
    end
end

local function DbgError(msg)
    logError("[Dialogue] " .. msg)
end

-- ========== 立绘：Inspector 按 NPC·立绘名 拖入，注册到 allSprites[NpcSprite key] ==========
local function RegPortrait(key, sprite)
    if key and sprite then
        allSprites[key] = sprite
    end
end

local function GetLuaBinding(varName)
    if _ENV and _ENV[varName] ~= nil then
        return _ENV[varName]
    end
    return _G[varName]
end

local function InitPortraitRefs()
    RegPortrait("守望", GetLuaBinding("立绘_淑芬_守望"))
    RegPortrait("护雏", GetLuaBinding("立绘_淑芬_护雏"))
    RegPortrait("团聚", GetLuaBinding("立绘_淑芬_团聚"))
    RegPortrait("醉倒", GetLuaBinding("立绘_大黄_醉倒"))
    RegPortrait("执勤", GetLuaBinding("立绘_大黄_执勤"))
    RegPortrait("振奋", GetLuaBinding("立绘_大黄_振奋"))
    RegPortrait("丧", GetLuaBinding("立绘_悲伤蛙_丧"))
    RegPortrait("介入", GetLuaBinding("立绘_悲伤蛙_介入"))
    RegPortrait("兜售", GetLuaBinding("立绘_老鼠_兜售"))
    RegPortrait("八卦", GetLuaBinding("立绘_老鼠_八卦"))
    RegPortrait("发怵", GetLuaBinding("立绘_老鼠_发怵"))
    RegPortrait("装酷", GetLuaBinding("立绘_小鸡_装酷"))
    RegPortrait("心虚", GetLuaBinding("立绘_小鸡_心虚"))
    RegPortrait("愧疚", GetLuaBinding("立绘_小鸡_愧疚"))
    RegPortrait("背对", GetLuaBinding("立绘_小鸡_背对"))
    RegPortrait("得意", GetLuaBinding("立绘_乌鸦_得意"))
    RegPortrait("吝啬", GetLuaBinding("立绘_乌鸦_吝啬"))
    RegPortrait("叫嚣", GetLuaBinding("立绘_乌鸦_叫嚣"))
    RegPortrait("高傲", GetLuaBinding("立绘_黑猫_高傲"))
    RegPortrait("审视", GetLuaBinding("立绘_黑猫_审视"))
    RegPortrait("炸毛", GetLuaBinding("立绘_黑猫_炸毛"))
    RegPortrait("待机", GetLuaBinding("立绘_闪电蜗牛_待机"))
    RegPortrait("闪电蜗牛", GetLuaBinding("立绘_闪电蜗牛_闪电蜗牛"))
    -- 玩家立绘不换图：UI Image 上已放好的素材；惊讶/疑惑只开关符号
end

local PLAYER_PORTRAIT_KEYS = {
    ["正常"] = true,
    ["惊讶"] = true,
    ["疑惑"] = true,
}

local function SetPlayerEmotionMarks(spriteKey)
    local showEx = spriteKey == "惊讶"
    local showQ = spriteKey == "疑惑"
    if playerExclamation then
        playerExclamation:SetActive(showEx)
    end
    if playerQuestion then
        playerQuestion:SetActive(showQ)
    end
end

local function PlayPlayerEmotionSfx(spriteKey)
    if spriteKey == "惊讶" then
        _G["PlayAudio"]("audio_shock")
    elseif spriteKey == "疑惑" then
        _G["PlayAudio"]("audio_question")
    end
end

local function HideAllPortraits()
    if npcSprite then
        npcSprite.gameObject:SetActive(false)
    end
    SetPlayerEmotionMarks(nil)
    if playerSprite then
        playerSprite.gameObject:SetActive(false)
    end
end

-- TREE_TO_LUA_SPEC §5.1.1 冲突优先级（选项回显无 NpcSprite 时用）
local function ClassifyPlayerPortraitFromText(text)
    if not text or text == "" then
        return "正常"
    end
    if text:find("！", 1, true) or text:find("!", 1, true)
        or text:find("竟然", 1, true) or text:find("？？", 1, true)
        or text:find("??", 1, true) then
        return "惊讶"
    end
    if text:match("？$") or text:match("%?$") then
        local core = text:gsub("[？?。.！!…．]+$", "")
        local len = (utf8 and utf8.len(core)) or #core
        if len <= 4 then
            return "惊讶"
        end
        return "疑惑"
    end
    if text:find("？", 1, true) or text:find("?", 1, true) then
        return "疑惑"
    end
    return "正常"
end

local function ResolvePlayerPortraitKey(data)
    if data and data.NpcSprite and data.NpcSprite ~= "" then
        if PLAYER_PORTRAIT_KEYS[data.NpcSprite] then
            return data.NpcSprite
        end
        return data.NpcSprite
    end
    return "正常"
end

-- ========== 新增：头像辅助功能 ==========
local _npcConfigsCache = nil -- NPC 配置缓存，避免重复读取文件

-- 从 avatarPath 中提取 sprite 名称（去掉路径和扩展名）
-- 例如: "Assets/Res/TouXiang_LiHui/Dog/Dog01.png" -> "Dog01"
local function ExtractSpriteNameFromPath(avatarPath)
    if not avatarPath or avatarPath == "" then
        return nil
    end
    -- 提取文件名（不带路径）
    local fileName = avatarPath:match("[^/\\]+$")
    if not fileName then
        return nil
    end
    -- 去掉扩展名
    local spriteName = fileName:match("(.+)%..+$")
    return spriteName or fileName
end

-- 确保 NPC 配置已加载（如果还没加载则从全局 _NPCDataConfig 读取）
local function EnsureNPCConfigsLoaded()
    -- 优先复用 DialogueTrigger 加载的全局 _NPCConfigs
    if _G["_NPCConfigs"] and _G["_NPCConfigs"].byName then
        _npcConfigsCache = _G["_NPCConfigs"]
        return _npcConfigsCache
    end

    -- 如果已有缓存，直接返回
    if _npcConfigsCache and _npcConfigsCache.byName then
        return _npcConfigsCache
    end

    -- 从 GlobalVariablesManager 注册的全局 _NPCDataConfig 读取
    local data = _G["_NPCDataConfig"]
    if data and data.npcList then
        _npcConfigsCache = { byId = {}, byName = {} }
        for _, npc in ipairs(data.npcList) do
            if npc.id then _npcConfigsCache.byId[npc.id] = npc end
            if npc.name then _npcConfigsCache.byName[npc.name] = npc end
        end
        return _npcConfigsCache
    end

    return nil
end

local function ResolvePortraitSpriteKey(data)
    if not data then
        return nil
    end
    if data.NpcSprite and data.NpcSprite ~= "" then
        return data.NpcSprite
    end
    local speaker = data.NpcName or ""
    if speaker == "" or speaker == "描述" or speaker == "玩家" then
        return nil
    end
    local npcConfigs = EnsureNPCConfigsLoaded()
    if npcConfigs and npcConfigs.byName and npcConfigs.byName[speaker] then
        local npcConfig = npcConfigs.byName[speaker]
        if npcConfig.avatarPath and npcConfig.avatarPath ~= "" then
            return ExtractSpriteNameFromPath(npcConfig.avatarPath)
        end
    end
    return nil
end

-- speaker=玩家 → 只开关立绘与情绪符号（不改 Image.sprite，沿用 UI 上已放好的图）
-- 否则 → npcSprite（描述沿用 lastPortrait，不改 last）
local function ApplyPortraitSprite(spriteKey, speaker)
    if not spriteKey or spriteKey == "" then
        return false
    end

    if speaker == "玩家" then
        if npcSprite then
            npcSprite.gameObject:SetActive(false)
        end
        if not playerSprite then
            SetPlayerEmotionMarks(nil)
            return false
        end
        playerSprite.gameObject:SetActive(true)
        SetPlayerEmotionMarks(spriteKey)
        return true
    end

    SetPlayerEmotionMarks(nil)
    if playerSprite then
        playerSprite.gameObject:SetActive(false)
    end
    local sprite = allSprites[spriteKey]
    if not npcSprite or not sprite then
        if npcSprite then
            npcSprite.gameObject:SetActive(false)
        end
        return false
    end
    npcSprite.sprite = sprite
    npcSprite.gameObject:SetActive(true)
    if speaker ~= "描述" then
        lastPortraitSpriteKey = spriteKey
    end
    return true
end

-- 根据条件分支计算下一个节点 ID（reason 供 World Debugger 日志）
function GetNextNodeByCondition(data)
    local nextID, _ = GetNextNodeByConditionDetailed(data)
    return nextID
end

function GetNextNodeByConditionDetailed(data)
    if data == nil or data.ConditionBranches == nil or #data.ConditionBranches == 0 then
        return nil, nil
    end

    local getFunc = _G["GetGlobalVar"]

    for i, cb in ipairs(data.ConditionBranches) do
        if cb.VarName ~= nil and cb.VarName ~= "" then
            local varType = cb.VarType or "bool"
            local varValue = getFunc and getFunc(cb.VarName)

            if varType == "bool" then
                if varValue == true and cb.TrueNext ~= nil then
                    return cb.TrueNext,
                        "cond " .. cb.VarName .. "=true → TrueNext=" .. tostring(cb.TrueNext)
                elseif (varValue == false or varValue == nil) and cb.FalseNext ~= nil then
                    return cb.FalseNext,
                        "cond " .. cb.VarName .. "=false → FalseNext=" .. tostring(cb.FalseNext)
                end
            else
                local op = cb.Op or "=="
                local cmpValue = tonumber(cb.Value) or 0
                local intVal = tonumber(varValue) or 0
                local match = false
                if op == "==" then
                    match = (intVal == cmpValue)
                elseif op == "!=" then
                    match = (intVal ~= cmpValue)
                elseif op == ">" then
                    match = (intVal > cmpValue)
                elseif op == "<" or op == "lt" then
                    match = (intVal < cmpValue)
                elseif op == ">=" then
                    match = (intVal >= cmpValue)
                elseif op == "<=" then
                    match = (intVal <= cmpValue)
                end
                if match and cb.Next ~= nil then
                    return cb.Next,
                        "cond " .. cb.VarName .. op .. tostring(cmpValue) .. " → Next=" .. tostring(cb.Next)
                end
            end
        end
    end
    return nil, "no cond match"
end

----- ========== 新增：应用 SetVariables（节点执行时设置全局变量的值）==========
function ApplySetVariables(data)
    if not data then return end
    if not data.SetVariables or #data.SetVariables == 0 then return end

    for _, setVar in ipairs(data.SetVariables) do
        local varName = setVar.VarName or setVar.varName
        local varType = setVar.VarType or setVar.varType or "bool"
        local value = setVar.Value

        if not varName or varName == "" then goto continue end

        local getFunc = _G["GetGlobalVar"]
        local was = getFunc and getFunc(varName)
        local setFunc = _G["SetGlobalVar"]
        if varType == "bool" then
            local boolVal = value == true or value == "true" or value == 1
            setFunc(varName, boolVal, "bool")
            Dbg("SetVar " .. varName .. "=" .. tostring(boolVal) .. " (was " .. tostring(was) .. ")")
            if string.match(varName or "", "^Mouse_CheapSold_") or string.match(varName or "", "^Mouse_PremiumSold_") then
                if _G["BookController_UnlockMouseIntel"] then
                    _G["BookController_UnlockMouseIntel"](varName)
                end
            end
        else
            local intVal = tonumber(value) or 0
            setFunc(varName, intVal, "int")
            Dbg("SetVar " .. varName .. "=" .. tostring(intVal) .. " (was " .. tostring(was) .. ")")
        end

        ::continue::
    end
end

--- ========== 新增：检查并处理 UnlockBranches（节点执行时解锁指定 NPC 的分支）==========
function CheckAndUnlockBranch(data)
    if not data then
        return
    end

    -- 收集所有需要解锁的条目：可能是数组（新格式），也可能是 UnlockBranchId 整数（兼容）
    local entries = {}

    if data.UnlockBranches and #data.UnlockBranches > 0 then
        -- 新格式：UnlockBranches = { { NpcName = "大树", BranchId = 2 }, ... }
        for _, item in ipairs(data.UnlockBranches) do
            local name = item.NpcName or item.npcName
            local bid = tonumber(item.BranchId) or tonumber(item.branchId) or 0
            if name and name ~= "" and bid > 0 then
                table.insert(entries, { npcName = name, branchId = bid })
            end
        end
    end

    if data.UnlockBranchId and tonumber(data.UnlockBranchId) > 0 then
        -- 兼容旧格式：UnlockBranchId = 2，NPC 为当前节点的 NpcName
        local name = data.NpcName or ""
        if name ~= "" then
            table.insert(entries, { npcName = name, branchId = tonumber(data.UnlockBranchId) })
        end
    end

    if #entries == 0 then
        return
    end

    -- 逐条执行解锁（同节点内每个NPC只处理一次，直接修改内存中 _NPCDataConfig）
    for _, entry in ipairs(entries) do
        local cacheKey = currentDialogueID .. "_" .. entry.npcName
        if not unlockedBranchCache[cacheKey] then
            local npcConfig = _G["_NPCDataConfig"]
            if npcConfig and npcConfig.npcList then
                for _, npc in ipairs(npcConfig.npcList) do
                    if npc.name == entry.npcName then
                        local oldBranchId = npc.currentBranchId or 1
                        npc.currentBranchId = entry.branchId
                        unlockedBranchCache[cacheKey] = true
                        Dbg("[NPC分支解锁] " ..
                            entry.npcName .. " currentBranchId: " .. oldBranchId .. " -> " .. entry.branchId)
                        break
                    end
                end
            end
        end
    end
end

local function RegisterDialogueManagerApi(target)
    target.StartDialogue = StartDialogue
    target.StartDialogueWithData = StartDialogueWithData
    target.EndDialogue = EndDialogue
    target.IsDialogueActive = IsDialogueActive
    target.CheckBranch = CheckBranchFlag
    target.JumpToDialogueNode = JumpToDialogueNode
end

function Awake()
    RegisterDialogueManagerApi(self.script)
    _G["_DialogueManager"] = self.script
    dialogueManager = self.script
    Dbg("DialogueManager 已注册 (_DialogueManager.StartDialogueWithData OK)")

    InitPortraitRefs()

    if dialoguePanel then
        dialoguePanel:SetActive(false)
    end
    if playerPanel then
        playerPanel:SetActive(false)
    end
    if playerNamePanel then
        playerNamePanel:SetActive(false)
    end

    if next then
        next.onClick:AddListener(OnNextClick)
        next.gameObject:SetActive(false)
    end

    if dialoguePanel then
        local panelBtn = dialoguePanel:GetComponent(typeof(UnityEngine.UI.Button))
        if not panelBtn then
            panelBtn = dialoguePanel:AddComponent(typeof(UnityEngine.UI.Button))
        end
        panelBtn.onClick:AddListener(OnNextClick)
    end

    if playerPanelBtn then
        playerPanelBtn.gameObject:SetActive(false)
    end
end

function Start()
    -- StartDialogue(1)
end

function GetDialogueData(id)
    if externalDialogueConfig and externalDialogueConfig[id] ~= nil then
        return externalDialogueConfig[id]
    end
    return nil
end

function StartDialogue(dialogueID)
    if GetDialogueData(dialogueID) == nil then
        return
    end

    -- 重置 NPC 配置缓存，确保每次对话都读取最新的配置文件
    _npcConfigsCache = nil
    if _G["_NPCConfigs"] then _G["_NPCConfigs"] = nil end
    lastPortraitSpriteKey = nil
    HideAllPortraits()

    SetPlayerNamePanel(false)
    currentDialogueID = dialogueID
    if dialoguePanel then
        dialoguePanel:SetActive(true)
    end

    DouyinUIService.SetUIVisible(false)

    _G["PlayAudio"]("audio_hello")
    UpdateDialogueUI()
end

-- 对话进行中的节点跳转（如老鼠商店抽选情报）；须写 local currentDialogueID，不能 mgr.currentDialogueID=
function JumpToDialogueNode(nodeId)
    if GetDialogueData(nodeId) == nil then
        DbgError("JumpToDialogueNode: missing node " .. tostring(nodeId))
        return false
    end

    isWaitingForChoice = false
    isWaitingForNextAfterOption = false
    selectedOptionCache = nil
    isTyping = false
    isAnimatingOptions = false

    SetPlayerNamePanel(false)
    currentDialogueID = nodeId
    if dialoguePanel then
        dialoguePanel:SetActive(true)
    end
    DouyinUIService.SetUIVisible(false)
    UpdateDialogueUI()
    return true
end

function StartDialogueWithData(dialogueData, startID)
    externalDialogueConfig = dialogueData

    -- 重置 NPC 配置缓存，确保每次对话都读取最新的配置文件
    _npcConfigsCache = nil
    if _G["_NPCConfigs"] then _G["_NPCConfigs"] = nil end
    lastPortraitSpriteKey = nil
    HideAllPortraits()

    local actualID = startID or 1
    if GetDialogueData(actualID) == nil then
        for k, v in pairs(dialogueData) do
            actualID = k
            break
        end
    end
    if GetDialogueData(actualID) == nil then
        return
    end
    SetPlayerNamePanel(false)
    currentDialogueID = actualID
    if dialoguePanel then
        dialoguePanel:SetActive(true)
    end
    DouyinUIService.SetUIVisible(false)
    _G["PlayAudio"]("audio_hello")
    UpdateDialogueUI()
end

function OnNextClick()
    -- 如果选项正在动画显示中...
    if isAnimatingOptions then
        CompleteOptionAnimation()
        return
    end

    if isWaitingForChoice then
        return
    end

    if isTyping then
        CompleteTypingEffect()
        return
    end

    if isWaitingForNextAfterOption and selectedOptionCache then
        local opt = selectedOptionCache
        selectedOptionCache = nil
        isWaitingForNextAfterOption = false
        PerformOptionJump(opt, false)
        return
    end

    -- 普通对话的 Next 逻辑...
    local currentData = GetDialogueData(currentDialogueID)
    if currentData == nil then
        EndDialogue()
        return
    end

    local fromID = currentDialogueID
    local fromTag = currentData.DocTag or "?"
    local nextID, condReason = GetNextNodeByConditionDetailed(currentData)
    local via = condReason
    if nextID == nil then
        nextID = currentData.Next
        via = "fallback Next=" .. tostring(nextID)
    end

    if nextID == -1 then
        Dbg("Leave node=" .. fromID .. " DocTag=" .. fromTag .. " via " .. via .. " → END")
        EndDialogue(via)
    elseif GetDialogueData(nextID) ~= nil then
        Dbg("Leave node=" .. fromID .. " DocTag=" .. fromTag .. " via " .. via .. " → " .. nextID)
        currentDialogueID = nextID
        _G["PlayAudio"]("audio_nextSentence")
        UpdateDialogueUI()
    else
        DbgError("Leave node=" .. fromID .. " target " .. tostring(nextID) .. " missing")
        EndDialogue("missing next " .. tostring(nextID))
    end
end

function UpdateDialogueUI()
    local data = GetDialogueData(currentDialogueID)
    if data == nil then
        DbgError("Enter node=" .. tostring(currentDialogueID) .. " — data missing")
        EndDialogue("data missing")
        return
    end

    -- 自动跳过空台词路由节点（entry#0 / entry#barn* 等）与 RotatePool 分发
    local skipGuard = 0
    while skipGuard < 48 do
        skipGuard = skipGuard + 1
        data = GetDialogueData(currentDialogueID)
        if data == nil then
            DbgError("Enter node=" .. tostring(currentDialogueID) .. " — data missing during skip")
            EndDialogue("data missing")
            return
        end

        if data.RotatePool ~= nil and #data.RotatePool > 0 then
            local pick = math.random(1, #data.RotatePool)
            local poolStart = data.RotatePool[pick]
            if GetDialogueData(poolStart) ~= nil then
                Dbg("RotatePool dispatcher " ..
                    currentDialogueID .. " → " .. poolStart .. " (pick " .. pick .. "/" .. #data.RotatePool .. ")")
                CheckAndUnlockBranch(data)
                ApplySetVariables(data)
                currentDialogueID = poolStart
            else
                break
            end
        elseif (data.Dialogue == nil or data.Dialogue == "") and data.Type ~= "Question" then
            CheckAndUnlockBranch(data)
            ApplySetVariables(data)

            local nextID, condReason = GetNextNodeByConditionDetailed(data)
            local via = condReason
            if nextID == nil then
                nextID = data.Next
                via = "fallback Next=" .. tostring(nextID)
            end

            if nextID == -1 then
                Dbg("Leave empty dispatcher node=" ..
                    currentDialogueID .. " DocTag=" .. (data.DocTag or "?") .. " via " .. tostring(via) .. " → END")
                EndDialogue(via)
                return
            end
            if nextID == nil or GetDialogueData(nextID) == nil then
                DbgError("empty dispatcher " .. currentDialogueID .. " → missing " .. tostring(nextID))
                EndDialogue("missing next " .. tostring(nextID))
                return
            end

            Dbg("Skip empty dispatcher node=" ..
                currentDialogueID .. " DocTag=" .. (data.DocTag or "?") .. " via " .. tostring(via) .. " → " .. nextID)
            currentDialogueID = nextID
        else
            break
        end
    end

    data = GetDialogueData(currentDialogueID)
    if data == nil then
        DbgError("Enter node=" .. tostring(currentDialogueID) .. " — data missing after skip")
        EndDialogue("data missing")
        return
    end

    currentDataCache = data

    local docTag = data.DocTag or "?"
    Dbg("Enter node=" .. currentDialogueID .. " DocTag=" .. docTag ..
        " type=" .. tostring(data.Type) .. " npc=" .. tostring(data.NpcName) .. " Next=" .. tostring(data.Next))

    -- 检查是否需要解锁分支
    CheckAndUnlockBranch(data)

    ApplySetVariables(data)

    if next then
        next.gameObject:SetActive(false)
    end
    if playerPanel then
        playerPanel:SetActive(false)
    end
    ClearOptionButtons()

    UpdateNPCInfo(data)
end

local function ApplyNamePanelForSpeaker(speakerName)
    if speakerName == nil or speakerName == "" or speakerName == "描述" then
        if playerNamePanel then
            playerNamePanel:SetActive(false)
        end
        if npcNamePanel then
            npcNamePanel:SetActive(false)
        end
        return
    end

    local isPlayer = speakerName == "玩家"
    SetPlayerNamePanel(isPlayer)
    if npcName and not isPlayer then
        npcName.text = speakerName
    end
end

function UpdateNPCInfo(data)
    local speaker = data.NpcName or ""
    local dialogue = data.Dialogue or ""
    local displaySpeaker = speaker
    if dialogue:match("^（") then
        displaySpeaker = "描述"
    end
    ApplyNamePanelForSpeaker(displaySpeaker)

    local spriteKey = nil
    if displaySpeaker == "玩家" then
        spriteKey = ResolvePlayerPortraitKey(data)
    else
        spriteKey = ResolvePortraitSpriteKey(data)
        if (not spriteKey or spriteKey == "") and displaySpeaker == "描述" then
            spriteKey = lastPortraitSpriteKey
        end
    end

    if not ApplyPortraitSprite(spriteKey, displaySpeaker) then
        if displaySpeaker ~= "描述" and displaySpeaker ~= "玩家" then
            local availableKeys = {}
            for k, v in pairs(allSprites) do
                table.insert(availableKeys, k)
            end
            Dbg("[头像加载] 找不到 spriteKey: " ..
                tostring(spriteKey) .. ". 可用 keys: " .. table.concat(availableKeys, ", "))
        end
        HideAllPortraits()
    elseif displaySpeaker == "玩家" then
        PlayPlayerEmotionSfx(spriteKey)
    end

    if npcDialogueText then
        fullDialogueText = data.Dialogue or ""
        if data.Type == "Question" and fullDialogueText == "" then
            -- 空台词 Question hub（老鼠 1-hub 等）：保留上一句 NPC 气泡，直接出菜单
            local preserved = npcDialogueText.text
            if preserved and preserved ~= "" then
                fullDialogueText = preserved
            end
            isTyping = false
            npcDialogueText.text = fullDialogueText
            ShowQuestionUI(data)
        else
            StartTypingEffect()
        end
    end
end

function StartTypingEffect()
    isTyping = true
    typingTimer = 0
    currentTypingIndex = 0
    npcDialogueText.text = ""
end

function CompleteTypingEffect()
    isTyping = false
    npcDialogueText.text = fullDialogueText

    if isWaitingForNextAfterOption then
        SetPlayerNamePanel(true)
        if npcName then
            npcName.text = "玩家"
        end
        if next then
            next.gameObject:SetActive(true)
            next.interactable = true
        end
        return
    end

    if currentDataCache then
        if currentDataCache.Type == "Question" then
            ShowQuestionUI(currentDataCache)
        else
            ShowNPCConversationUI(currentDataCache)
        end
    end
end

function CompleteOptionAnimation()
    isAnimatingOptions = false
    if optionButtons then
        for i, btn in ipairs(optionButtons) do
            if btn and btn.gameObject then
                btn.gameObject:SetActive(true)
            end
        end
    end
end

function Update()
    if isTyping then
        typingTimer = typingTimer + UnityEngine.Time.deltaTime
        if typingTimer >= typingSpeed then
            typingTimer = 0
            currentTypingIndex = currentTypingIndex + 1

            local textLen = utf8.len(fullDialogueText)
            if currentTypingIndex <= textLen then
                local byteStart = utf8.offset(fullDialogueText, 1)
                local byteEnd = utf8.offset(fullDialogueText, currentTypingIndex + 1) - 1
                npcDialogueText.text = string.sub(fullDialogueText, byteStart, byteEnd)
            else
                CompleteTypingEffect()
            end
        end
    end

    if isAnimatingOptions then
        optionAnimationTimer = optionAnimationTimer + UnityEngine.Time.deltaTime
        if optionAnimationTimer >= optionAnimationSpeed then
            optionAnimationTimer = 0
            currentAnimatingOptionIndex = currentAnimatingOptionIndex + 1

            if optionButtons and currentAnimatingOptionIndex <= #optionButtons then
                local btn = optionButtons[currentAnimatingOptionIndex]
                if btn and btn.gameObject then
                    btn.gameObject:SetActive(true)
                end
            else
                isAnimatingOptions = false
            end
        end
    end
end

function ShowNPCConversationUI(data)
    isWaitingForChoice = false

    if playerPanel then
        playerPanel:SetActive(false)
    end
    ClearOptionButtons()

    ApplyNamePanelForSpeaker(data and data.NpcName)

    if next then
        next.gameObject:SetActive(true)
        next.interactable = true
    end
end

-- 根据显示条件检查选项是否应该显示
-- DisplayConditions：AND（全部满足）
-- DisplayAnyConditions：OR（至少一条满足）；可与 DisplayConditions 组合
local function EvaluateDisplayCondition(cond, getFunc)
    if not cond then
        return true
    end

    local varName = cond.VarName
    local varType = cond.VarType or "bool"
    local varValue = getFunc(varName)
    local op = cond.Op or "=="
    local condValue = cond.Value

    if varType == "bool" then
        local expectedValue = condValue
        if expectedValue == nil then
            expectedValue = true
        end
        if type(expectedValue) == "string" then
            expectedValue = (expectedValue == "true" or expectedValue == "1")
        end

        local varBool = varValue
        if varValue == nil then
            varBool = false
        elseif type(varValue) == "number" then
            varBool = (varValue ~= 0)
        elseif type(varValue) == "string" then
            varBool = (varValue == "true" or varValue == "1")
        end

        if op == "==" then
            return varBool == expectedValue
        elseif op == "!=" then
            return varBool ~= expectedValue
        end
        return false
    end

    local cmpValue = tonumber(condValue) or 0
    local intVal = tonumber(varValue) or 0
    if op == "==" then
        return intVal == cmpValue
    elseif op == "!=" then
        return intVal ~= cmpValue
    elseif op == ">" then
        return intVal > cmpValue
    elseif op == "<" or op == "lt" then
        return intVal < cmpValue
    elseif op == ">=" then
        return intVal >= cmpValue
    elseif op == "<=" then
        return intVal <= cmpValue
    end
    return false
end

function CheckOptionDisplayConditions(option)
    if not option then
        return true
    end

    local conditions = option.DisplayConditions
    local anyConditions = option.DisplayAnyConditions
    local hasAnd = conditions and #conditions > 0
    local hasOr = anyConditions and #anyConditions > 0

    if not hasAnd and not hasOr then
        return true
    end

    local getFunc = _G["GetGlobalVar"]

    Dbg(string.format("[DisplayCond] 检查选项: %s, AND=%d OR=%d",
        tostring(option.Text), hasAnd and #conditions or 0, hasOr and #anyConditions or 0))

    if hasAnd then
        for i, cond in ipairs(conditions) do
            if not EvaluateDisplayCondition(cond, getFunc) then
                Dbg(string.format("[DisplayCond] AND[%d] 不满足，返回 false", i))
                return false
            end
        end
    end

    if hasOr then
        local anyMatch = false
        for i, cond in ipairs(anyConditions) do
            if EvaluateDisplayCondition(cond, getFunc) then
                anyMatch = true
                break
            end
        end
        if not anyMatch then
            Dbg("[DisplayCond] OR 组无匹配，返回 false")
            return false
        end
    end

    Dbg("[DisplayCond] 所有条件通过，选项显示")
    return true
end

-- hub 菜单最多显示 4 项：超过时保留前 3 项 + 最后一项（告辞/结束对话，策划约定排在菜单末尾）
-- Question.MenuCap = 0 表示不限制（老鼠 1-hub）
local function ApplyHubMenuCap(options, hubData)
    local count = #options
    local cap = 4
    if hubData and hubData.MenuCap ~= nil then
        if hubData.MenuCap == 0 then
            return options
        end
        cap = hubData.MenuCap
    end
    if count <= cap then
        return options
    end
    return {
        options[1],
        options[2],
        options[3],
        options[count],
    }
end

function ShowQuestionUI(data)
    isWaitingForChoice = true

    if next then
        next.gameObject:SetActive(false)
    end

    if playerPanel then
        playerPanel:SetActive(true)
    end

    ApplyNamePanelForSpeaker(data and data.NpcName)

    currentOptions = data.Options or {}

    -- 根据显示条件过滤选项：只有满足所有 DisplayConditions 的选项才显示给玩家
    local filteredOptions = {}
    for _, option in ipairs(currentOptions) do
        if CheckOptionDisplayConditions(option) then
            table.insert(filteredOptions, option)
        end
    end
    currentOptions = filteredOptions
    currentOptions = ApplyHubMenuCap(currentOptions, data)

    if #currentOptions == 0 then
        EndDialogue()
        return
    end

    GenerateOptionButtons()
end

function ClearOptionButtons()
    if optionButtons then
        for i, btn in ipairs(optionButtons) do
            if btn and btn.gameObject then
                UnityEngine.GameObject.Destroy(btn.gameObject)
            end
        end
        optionButtons = {}
    end
end

function GenerateOptionButtons()
    if not playerPanel then
        return
    end

    if not playerPanelBtn then
        return
    end

    ClearOptionButtons()

    local templateRect = playerPanelBtn:GetComponent(typeof(UnityEngine.RectTransform))
    local buttonHeight = 80
    if templateRect then
        buttonHeight = templateRect.rect.height
    end

    local totalHeight = #currentOptions * buttonHeight
    local startY = totalHeight / 2 - buttonHeight / 2

    for i, option in ipairs(currentOptions) do
        local btnObj = UnityEngine.GameObject.Instantiate(playerPanelBtn.gameObject, playerPanel.transform)
        btnObj:SetActive(false)

        local btnText = btnObj:GetComponentInChildren(typeof(UnityEngine.UI.Text))
        if btnText then
            btnText.text = option.Text
        end

        local rect = btnObj:GetComponent(typeof(UnityEngine.RectTransform))
        if rect then
            local yPos = startY - (i - 1) * buttonHeight
            rect.anchoredPosition = UnityEngine.Vector2(0, yPos)
        end

        local btn = btnObj:GetComponent(typeof(UnityEngine.UI.Button))
        if btn then
            local capturedOption = option
            btn.onClick:AddListener(function()
                OnOptionSelected(capturedOption)
            end)
        end

        table.insert(optionButtons, btnObj)
    end

    isAnimatingOptions = true
    optionAnimationTimer = 0
    currentAnimatingOptionIndex = 0
end

function SetPlayerNamePanel(active)
    if playerNamePanel then
        playerNamePanel:SetActive(active)
    end
    if npcNamePanel then
        npcNamePanel:SetActive(not active)
    end
end

-- 根据选项的条件分支计算下一个节点 ID（新增：支持选项内部的条件分支规则）
function GetOptionNextNode(option)
    -- 有 ConditionBranches 时：按条件分支走
    if option ~= nil and option.ConditionBranches ~= nil and #option.ConditionBranches > 0 then
        for i, cb in ipairs(option.ConditionBranches) do
            if cb.VarName ~= nil and cb.VarName ~= "" then
                local varType = cb.VarType or "bool"
                local varValue = _G["GetGlobalVar"] and _G["GetGlobalVar"](cb.VarName)

                if varType == "bool" then
                    -- bool 模式：变量为真走 TrueNext，为假/不存在走 FalseNext
                    -- -1 表示"结束对话"，因此需要允许 -1 被返回
                    if varValue == true and cb.TrueNext ~= nil then
                        return cb.TrueNext
                    elseif (varValue == false or varValue == nil) and cb.FalseNext ~= nil then
                        return cb.FalseNext
                    end
                else
                    -- int 模式：用操作符比较
                    local op = cb.Op or "=="
                    local cmpValue = tonumber(cb.Value) or 0
                    local intVal = tonumber(varValue) or 0
                    local match = false
                    if op == "==" then
                        match = (intVal == cmpValue)
                    elseif op == "!=" then
                        match = (intVal ~= cmpValue)
                    elseif op == ">" then
                        match = (intVal > cmpValue)
                    elseif op == "<" or op == "lt" then
                        match = (intVal < cmpValue)
                    elseif op == ">=" then
                        match = (intVal >= cmpValue)
                    elseif op == "<=" then
                        match = (intVal <= cmpValue)
                    end
                    if match and cb.Next ~= nil then
                        return cb.Next
                    end
                end
            end
        end
        -- 有条件分支，但没有匹配上，返回 nil（调用方决定是否走默认 Next）
        return nil
    end

    -- 没有条件分支：走默认的 option.Next
    return nil
end

local function GetOptionRawNextID(option)
    local nextID = GetOptionNextNode(option)
    if nextID == nil then
        nextID = option.Next
    end
    return nextID
end

-- 跳过空路由节点，找到 option.Next 后第一个有台词的节点
local function GetFirstContentNodeAfterID(startID)
    local nextID = startID
    local guard = 0
    while guard < 48 and nextID ~= nil and nextID ~= -1 do
        guard = guard + 1
        local nodeData = GetDialogueData(nextID)
        if nodeData == nil then
            return nil
        end

        if nodeData.RotatePool ~= nil and #nodeData.RotatePool > 0 then
            nextID = nodeData.RotatePool[1]
        elseif (nodeData.Dialogue == nil or nodeData.Dialogue == "") and nodeData.Type ~= "Question" then
            local routed = GetNextNodeByCondition(nodeData)
            if routed == nil then
                routed = nodeData.Next
            end
            nextID = routed
        else
            return nodeData
        end
    end
    return nil
end

function IsPlayerFirstAfterOption(option)
    local firstNode = GetFirstContentNodeAfterID(GetOptionRawNextID(option))
    return firstNode ~= nil and firstNode.NpcName == "玩家"
end

-- 若 option.Next 首节点玩家台词与选项文字完全相同，视为已表达，再跳一段（缩略/全文相同时只播一次）
local function ShouldSkipRedundantPlayerLine(option, nodeData)
    if not option or not option.Text or option.Text == "" then
        return false
    end
    if not nodeData or nodeData.NpcName ~= "玩家" then
        return false
    end
    return nodeData.Dialogue == option.Text
end

local function ResolveOptionNextID(option, skipRedundantPlayerLine)
    if skipRedundantPlayerLine == nil then
        skipRedundantPlayerLine = true
    end

    local nextID = GetOptionRawNextID(option)

    if not skipRedundantPlayerLine then
        return nextID
    end

    local guard = 0
    while guard < 8 and nextID ~= nil and nextID ~= -1 do
        guard = guard + 1
        local nodeData = GetDialogueData(nextID)
        if nodeData and ShouldSkipRedundantPlayerLine(option, nodeData) then
            nextID = nodeData.Next
        else
            break
        end
    end
    return nextID
end

-- ========== 修改：执行选项的实际分支跳转逻辑（支持条件分支）==========
function PerformOptionJump(option, skipRedundantPlayerLine)
    if option ~= nil and option.ShopAction ~= nil and option.ShopAction ~= "" then
        local shopFn = _G["MouseShop_HandleAction"]
        if shopFn and shopFn(option.ShopAction, option) then
            return
        end
    end

    if option.BranchFlag then
        SaveBranchFlag(option.BranchFlag)
    end

    local nextID = ResolveOptionNextID(option, skipRedundantPlayerLine)

    if nextID == -1 then
        EndDialogue()
    elseif GetDialogueData(nextID) ~= nil then
        currentDialogueID = nextID
        UpdateDialogueUI()
    else
        EndDialogue()
    end
end

-- 选项是菜单缩略语；若下一段首句为玩家台词则不播选项，否则先播选项再等 Next
function OnOptionSelected(option)
    if not isWaitingForChoice then
        return
    end

    isWaitingForChoice = false
    if playerPanel then
        playerPanel:SetActive(false)
    end
    ClearOptionButtons()
    if next then
        next.gameObject:SetActive(false)
    end

    if IsPlayerFirstAfterOption(option) then
        PerformOptionJump(option, true)
        return
    end

    selectedOptionCache = option
    isWaitingForNextAfterOption = true
    SetPlayerNamePanel(true)
    if npcName then
        npcName.text = "玩家"
    end
    fullDialogueText = option.Text
    local optionPortraitKey = ClassifyPlayerPortraitFromText(option.Text)
    ApplyPortraitSprite(optionPortraitKey, "玩家")
    PlayPlayerEmotionSfx(optionPortraitKey)
    StartTypingEffect()
end

function SaveBranchFlag(flag)
    local actor = DouyinActorService.GetLocalActor()
    if actor then
        actor:SetActorTag("Branch_" .. flag, "true")
    end

    _G["DialogueBranch_" .. flag] = true
end

function CheckBranchFlag(flag)
    local actor = DouyinActorService.GetLocalActor()
    if actor then
        local value = actor:GetActorTag("Branch_" .. flag)
        return value == "true"
    end
    return _G["DialogueBranch_" .. flag] == true
end

-- ========== 修改：结束对话时重置新增的状态变量 ==========
function IsDialogueActive()
    if currentDialogueID < 0 then
        return false
    end
    if dialoguePanel and dialoguePanel.activeSelf then
        return true
    end
    return currentDialogueID >= 0
end

local function TryChainDialogueFromNode(data)
    if not data or not data.ChainDialogue then
        return
    end
    local chain = data.ChainDialogue
    local targetNpc = chain.NpcName or chain.npcName
    local startId = chain.StartId or chain.startId or 0
    if not targetNpc or targetNpc == "" then
        return
    end
    local startFn = _G.StartNpcDialogue
    if not startFn then
        DbgError("ChainDialogue: StartNpcDialogue 未注册")
        return
    end
    Dbg("ChainDialogue → " .. targetNpc .. " startID=" .. tostring(startId))
    startFn(targetNpc, startId)
end

function EndDialogue(reason)
    if reason then
        Dbg("End dialogue reason=" .. tostring(reason))
    end

    local chainSource = currentDataCache
    currentDialogueID = -1
    isWaitingForChoice = false
    isWaitingForNextAfterOption = false
    selectedOptionCache = nil
    isTyping = false
    isAnimatingOptions = false
    externalDialogueConfig = nil
    unlockedBranchCache = {}
    lastPortraitSpriteKey = nil
    HideAllPortraits()

    if dialoguePanel then
        dialoguePanel:SetActive(false)
    end
    if playerPanel then
        playerPanel:SetActive(false)
    end
    if next then
        next.gameObject:SetActive(false)
    end

    ClearOptionButtons()
    DouyinUIService.SetUIVisible(true)

    TryChainDialogueFromNode(chainSource)
end
