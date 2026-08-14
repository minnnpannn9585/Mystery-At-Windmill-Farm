-- E05：取得谷物泡水后关闭交互点（DisableInteraction 清屏幕按钮）+ 隐藏模型
-- 关点对齐 E03/DaHuang：DisableInteraction + 关 Collider；永不 EnableInteraction
---@var grainSoakModel :UnityEngine.GameObject
---@end

local HIDE_VAR = "E05_GrainSoakGet"
local MODEL_NAME = "guwupaoshui"
local pendingClose = false
local lastClosed = nil

local function GetGlobalBool(name)
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return getFunc(name) == true
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

local function GetDouyinInteractorScript()
    local comp = self:GetDouyinScript("DouyinInteractor")
    if comp and comp.script then
        return comp.script
    end
    local scripts = self.gameObject:GetComponents(typeof(DouyinScript))
    if scripts then
        for i = 0, scripts.Length - 1 do
            local ds = scripts[i]
            if ds and ds.script and ds.script.ButtonConfigs then
                return ds.script
            end
        end
    end
    return nil
end

local function ResolveModel()
    if grainSoakModel then
        return grainSoakModel
    end
    local t = self.transform:Find(MODEL_NAME)
    return t and t.gameObject or nil
end

local function SetModelVisible(visible)
    local go = ResolveModel()
    if go == nil then
        return
    end
    if go.activeSelf ~= visible then
        go:SetActive(visible)
    end
end

-- 关点必须走 DisableInteraction，否则玩家仍在范围内时屏幕交互按钮会残留
local function SetPointClosed(closed)
    local interactor = GetDouyinInteractorScript()

    if not closed then
        if interactor and interactor.InteractionArea then
            interactor.InteractionArea.enabled = true
        end
        local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        if colliders then
            for i = 0, colliders.Length - 1 do
                colliders[i].enabled = true
            end
        end
        SetModelVisible(true)
        return
    end

    if interactor and interactor.DisableInteraction then
        interactor.DisableInteraction()
    end
    local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = false
        end
    end
    SetModelVisible(false)
end

local function ApplyClosed(closed, force)
    if not force and lastClosed == closed then
        return
    end
    lastClosed = closed
    SetPointClosed(closed)
    if closed then
        print("[E05GrainSoak] point closed (DisableInteraction + hide model)")
    end
end

function RefreshE05GrainSoak(forceImmediate)
    local got = GetGlobalBool(HIDE_VAR)
    if not got then
        pendingClose = false
        ApplyClosed(false, forceImmediate == true)
        return
    end

    if forceImmediate or not IsDialogueActive() then
        pendingClose = false
        ApplyClosed(true, forceImmediate == true)
        return
    end

    -- 对话进行中：等说完再关，避免按钮在 EndDialogue 后因仍在范围内而弹回
    pendingClose = true
end

function Start()
    _G["E05GrainSoak_Refresh"] = RefreshE05GrainSoak
    RefreshE05GrainSoak(true)
end

function Update()
    if pendingClose and not IsDialogueActive() then
        pendingClose = false
        ApplyClosed(true, true)
        print("[E05GrainSoak] point closed after dialogue")
    end
end
