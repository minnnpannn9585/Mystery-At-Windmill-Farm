-- 进入 Trigger 区域后强制播放 NPC 对话（不需按交互键）
-- 条件未满足时不置 fired；玩家仍在区内且条件稍后满足会补播
---@var npcName :string
---@var startNodeId :int
---@var requireVarName :string
---@var requireVarMustBe :bool
---@var blockVarName :string
---@var blockWhenTrue :bool
---@var disableColliderAfterFire :bool
---@var skipIfDialogueActive :bool
---@end

local fired = false
local playerInside = false

local function GetGlobalBool(name)
    if not name or name == "" then
        return nil
    end
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return getFunc(name) == true
    end
    local vars = _G["_GlobalVariables"]
    if vars and vars[name] then
        return vars[name].value == true
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

local function DisableSelfCollider()
    local col = self.gameObject:GetComponent(typeof(CS.UnityEngine.Collider))
    if col then
        col.enabled = false
    end
end

local function ConditionsMet()
    if requireVarName and requireVarName ~= "" then
        local actual = GetGlobalBool(requireVarName)
        local expected = requireVarMustBe == true
        if actual ~= expected then
            return false
        end
    end

    if blockVarName and blockVarName ~= "" then
        local blocked = GetGlobalBool(blockVarName)
        if blockWhenTrue ~= false and blocked then
            return false
        end
        if blockWhenTrue == false and not blocked then
            return false
        end
    end
    return true
end

function TryFireDialogue()
    if fired then
        return
    end

    if skipIfDialogueActive ~= false and IsDialogueActive() then
        return
    end

    if not ConditionsMet() then
        return
    end

    local startFn = _G.StartNpcDialogue
    if not startFn then
        print("[DialogueAreaTrigger] StartNpcDialogue 未注册")
        return
    end

    fired = true
    if disableColliderAfterFire ~= false then
        DisableSelfCollider()
    end

    startFn(npcName, startNodeId or 1)
end

function Update()
    if fired or not playerInside then
        return
    end
    TryFireDialogue()
end

function OnPlayerTriggerEnter(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil or actor.isLocal ~= true then
        return
    end
    playerInside = true
    TryFireDialogue()
end

function OnPlayerTriggerExit(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil or actor.isLocal ~= true then
        return
    end
    playerInside = false
end
