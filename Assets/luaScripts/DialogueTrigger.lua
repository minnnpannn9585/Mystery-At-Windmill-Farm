--开始对话的ID
---@var ID :int
---@var npcname :string
---@end

local loadedNPCScripts = {}

-- World Debugger 对话加载调试（过滤关键字 [DialogueLoad]）；发布前改 false
local DIALOGUE_LOAD_DEBUG = false

local function LoadDbg(msg)
    if DIALOGUE_LOAD_DEBUG then
        print(msg)
    end
end

local function ResolveDialogueManager()
    local mgr = _G["_DialogueManager"]
    if mgr then
        return mgr
    end

    local managerGo = CS.UnityEngine.GameObject.Find("DialogueManager")
    if not managerGo then
        return nil
    end

    local douyinScript = managerGo:GetComponent(typeof(DouyinScript))
    if not douyinScript or not douyinScript.script then
        return nil
    end

    _G["_DialogueManager"] = douyinScript.script
    return douyinScript.script
end

-- Unity 启动入口：检查 DialogueManager 是否存在
function Start()
    if ResolveDialogueManager() == nil then
        logError("场景中缺少DialogueManager预制件")
    end
end

-- 从全局 _NPCDataConfig 加载 NPC 配置，构建 byId/byName 索引表
function LoadNPCConfig()
    local data = _G["_NPCDataConfig"]
    if not data or not data.npcList then
        logError("NPC: _NPCDataConfig 数据为空")
        return
    end

    _NPCConfigs = { byId = {}, byName = {} }
    for _, npc in ipairs(data.npcList) do
        if npc.id then _NPCConfigs.byId[npc.id] = npc end
        if npc.name then _NPCConfigs.byName[npc.name] = npc end
    end
    LoadDbg("NPC " .. #data.npcList .. " ")
end

-- 判断表是否像 DialogueConfig 节点表（数字键 + 对白字段）
local function LooksLikeDialogueConfigTable(data)
    if type(data) ~= "table" then
        return false
    end
    for k, v in pairs(data) do
        if type(k) == "number" and type(v) == "table" and (v.Dialogue or v.NpcName or v.Type) then
            return true
        end
    end
    return false
end

-- 从 DouyinScript 环境表中提取 DialogueConfig（支持嵌套 .script unwrap）
local function ExtractDialogueConfigFromEnv(env, depth)
    if env == nil or depth > 3 then
        return nil
    end

    if type(env) ~= "table" then
        if env.script ~= nil then
            return ExtractDialogueConfigFromEnv(env.script, depth + 1)
        end
        return nil
    end

    if env.DialogueConfig then
        return env.DialogueConfig
    end

    if LooksLikeDialogueConfigTable(env) then
        return env
    end

    if env.script ~= nil then
        return ExtractDialogueConfigFromEnv(env.script, depth + 1)
    end

    return nil
end

-- 收集表顶层键名，供加载失败日志使用
local function CollectTableKeys(data, limit)
    local keys = {}
    if type(data) ~= "table" then
        return keys
    end
    for k, _ in pairs(data) do
        table.insert(keys, tostring(k))
        if limit and #keys >= limit then
            break
        end
    end
    table.sort(keys)
    return keys
end

-- 标准化对话数据格式：支持 DouyinScript 组件、script.DialogueConfig、直接 DialogueConfig 表
function NormalizeDialogueData(rawData)
    if rawData == nil then
        return nil
    end
    return ExtractDialogueConfigFromEnv(rawData, 0)
end

local function MergeDialogueConfigs(into, from)
    if into == nil or from == nil then
        return into
    end
    for id, node in pairs(from) do
        into[id] = node
    end
    return into
end

-- 从 DialogueData/{moduleName} 上的 DouyinScript 读取 DialogueConfig
local function LoadDialogueModuleFromScene(moduleName, dialogueDataGo, npcName)
    local childTransform = dialogueDataGo.transform:Find(moduleName)
    if not childTransform then
        logError("NPC [" .. npcName .. "]: DialogueData 下未找到子物体: " .. moduleName)
        return nil
    end

    local douyinScript = childTransform.gameObject:GetComponent(typeof(DouyinScript))
    if not douyinScript then
        logError("NPC [" .. npcName .. "]: " .. moduleName .. " 上未找到 DouyinScript 组件")
        return nil
    end
    if not douyinScript.script then
        logError("NPC [" .. npcName .. "]: " .. moduleName
            .. " DouyinScript.script 未加载（检查 Data/DialogueData 是否 Publish / Reimport）")
        return nil
    end

    local normalizedData = NormalizeDialogueData(douyinScript)
    if normalizedData == nil then
        local outer = douyinScript.script
        local outerKeys = CollectTableKeys(outer)
        local detail = "script keys: " .. table.concat(outerKeys, ", ")
        if type(outer) == "table" and type(outer.script) == "table" then
            detail = detail .. "; inner keys: " .. table.concat(CollectTableKeys(outer.script), ", ")
        end
        logError("NPC " .. npcName .. " 对话数据为空（" .. moduleName
            .. " 无 DialogueConfig；" .. detail
            .. "；请执行 Publish + Refresh Scene DialogueData）")
    end
    return normalizedData
end

-- 根据 NPC 名称加载对应分支的对话脚本，从场景中 DialogueData 物体下查找 DouyinScript 读取数据
function LoadNPCScript(npcName)
    if not npcName or npcName == "" then
        logError("NPC")
        return nil
    end

    -- 懒加载：首次调用时如果 _NPCConfigs 未初始化，尝试加载
    if not _NPCConfigs and _G["_NPCDataConfig"] and _G["_NPCDataConfig"].npcList then
        LoadNPCConfig()
    end

    -- 从全局 _NPCDataConfig 查找 NPC 配置
    local npcConfig = nil
    local data = _G["_NPCDataConfig"]
    if not data then
        logError("NPC [" .. npcName .. "]: _NPCDataConfig 全局变量未设置")
        return nil
    end
    if not data.npcList then
        logError("NPC [" .. npcName .. "]: _NPCDataConfig.npcList 为空")
        return nil
    end
    for _, npc in ipairs(data.npcList) do
        if npc.name == npcName then
            npcConfig = npc
            break
        end
    end

    if not npcConfig then
        logError("NPC [" .. npcName .. "]: 在 npcList 中未找到")
        return nil
    end

    local currentBranchId = npcConfig.currentBranchId or 1
    local luaAssetPath = nil
    local currentGraph = nil

    if npcConfig.storyGraphs then
        for _, graph in ipairs(npcConfig.storyGraphs) do
            if graph.branchId == currentBranchId then
                luaAssetPath = graph.luaAssetPath
                currentGraph = graph
                break
            end
        end
        -- 旧 UnlockBranches 可能把 currentBranchId 切到已删除的分支，回退到可用分支
        if (not luaAssetPath or luaAssetPath == "") and #npcConfig.storyGraphs > 0 then
            local fallbackId = currentBranchId
            for _, graph in ipairs(npcConfig.storyGraphs) do
                if graph.branchId == 1 and graph.luaAssetPath and graph.luaAssetPath ~= "" then
                    luaAssetPath = graph.luaAssetPath
                    fallbackId = 1
                    break
                end
            end
            if not luaAssetPath or luaAssetPath == "" then
                local g = npcConfig.storyGraphs[1]
                luaAssetPath = g.luaAssetPath
                fallbackId = g.branchId or 1
            end
            if fallbackId ~= currentBranchId then
                LoadDbg(string.format(
                    "[DialogueLoad] NPC %s branch %d 无 Lua，回退到 branch %d",
                    npcName, currentBranchId, fallbackId))
                npcConfig.currentBranchId = fallbackId
                currentBranchId = fallbackId
            end
        end
    end

    if not luaAssetPath or luaAssetPath == "" then
        logError("NPC " .. npcName .. " " .. currentBranchId .. " Lua")
        return nil
    end

    -- 从 luaAssetPath 提取文件名（不含扩展名），如 "Assets/Editor/DialogueData/miaosu.lua" → "miaosu"
    local scriptName = luaAssetPath:match("([^/\\]+)%.lua$")
    if not scriptName then
        scriptName = luaAssetPath:match("([^/\\]+)$")
    end

    local cacheKey = npcName .. "_b" .. currentBranchId .. "_" .. scriptName
    if currentGraph and currentGraph.mergeLuaModules then
        for _, modName in ipairs(currentGraph.mergeLuaModules) do
            cacheKey = cacheKey .. "+" .. modName
        end
    end
    if loadedNPCScripts[cacheKey] then
        return loadedNPCScripts[cacheKey]
    end

    -- 在场景中查找 DialogueData 父物体
    local dialogueDataGo = CS.UnityEngine.GameObject.Find("DialogueData")
    if not dialogueDataGo then
        logError("NPC [" .. npcName .. "]: 场景中未找到 DialogueData 物体")
        return nil
    end

    local normalizedData = LoadDialogueModuleFromScene(scriptName, dialogueDataGo, npcName)
    if normalizedData == nil then
        return nil
    end

    if currentGraph and currentGraph.mergeLuaModules then
        for _, modName in ipairs(currentGraph.mergeLuaModules) do
            local extraData = LoadDialogueModuleFromScene(modName, dialogueDataGo, npcName)
            if extraData == nil then
                return nil
            end
            MergeDialogueConfigs(normalizedData, extraData)
        end
    end

    loadedNPCScripts[cacheKey] = normalizedData
    local mergeInfo = ""
    if currentGraph and currentGraph.mergeLuaModules and #currentGraph.mergeLuaModules > 0 then
        mergeInfo = " merge=" .. table.concat(currentGraph.mergeLuaModules, "+")
    end
    LoadDbg(string.format(
        "[DialogueLoad] npc=%s branchId=%d script=%s path=%s%s",
        npcName, currentBranchId, scriptName, luaAssetPath, mergeInfo))
    return normalizedData
end

-- 共享入口：强制 trigger / 同链转接 / DialogueTrigger 点击均走此函数
function StartNpcDialogue(targetNpcName, startId)
    if not targetNpcName or targetNpcName == "" then
        logError("[DialogueLoad] StartNpcDialogue: npcName 为空")
        return false
    end
    local mgr = ResolveDialogueManager()
    if not mgr then
        logError("[DialogueLoad] DialogueManager 未就绪：场景中缺少 DialogueManager 或 NpcDialogueManager.Awake 未执行")
        return false
    end
    if not mgr.StartDialogueWithData then
        logError("[DialogueLoad] DialogueManager 未就绪：缺少 StartDialogueWithData（检查 NpcDialogueManager.lua 是否已 Publish）")
        return false
    end
    local npcScript = LoadNPCScript(targetNpcName)
    if not npcScript then
        return false
    end
    local sid = startId or 0
    LoadDbg(string.format("[DialogueLoad] start npc=%s startID=%s", targetNpcName, tostring(sid)))
    mgr.StartDialogueWithData(npcScript, sid)
    return true
end

_G.StartNpcDialogue = StartNpcDialogue
_G.LoadNPCScript = LoadNPCScript

function StartDialogue()
    if _G.InteractionPointVfx_DiscoverFrom then
        _G.InteractionPointVfx_DiscoverFrom(self.gameObject)
    end
    if npcname and npcname ~= "" then
        StartNpcDialogue(npcname, ID)
        return
    end
    LoadDbg(string.format("[DialogueLoad] start directID=%s", tostring(ID)))
    local mgr = ResolveDialogueManager()
    if not mgr or not mgr.StartDialogue then
        logError("[DialogueLoad] DialogueManager 未就绪：缺少 StartDialogue")
        return
    end
    mgr.StartDialogue(ID)
end
