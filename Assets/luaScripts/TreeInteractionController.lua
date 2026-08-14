-- 大树双阶段交互：ForceZone(1-A) / ClickZone(1-B) 按全局变量切换
---@var forceZone :UnityEngine.GameObject
---@var clickZone :UnityEngine.GameObject
---@end

local lastForceEnabled = nil
local lastClickEnabled = nil

local function GetGlobalBool(name)
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

local function GetClickInteractorScript()
    if not clickZone then
        return nil
    end
    local scripts = clickZone:GetComponents(typeof(DouyinScript))
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

-- 对齐 DaHuang / ShuFen：开点只开 Area/Collider（永不 EnableInteraction，
-- 否则 Force→Click 切换时玩家仍在区内会把交互键强制弹在屏幕上）；
-- 关点须 DisableInteraction + 关 Collider，不能只 SetActive(false)。
local function SetClickInteractionEnabled(enabled)
    if not clickZone then
        return
    end

    local interactor = GetClickInteractorScript()

    if enabled then
        if not clickZone.activeSelf then
            clickZone:SetActive(true)
        end
        if interactor and interactor.InteractionArea then
            interactor.InteractionArea.enabled = true
        end
        local colliders = clickZone:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        if colliders then
            for i = 0, colliders.Length - 1 do
                colliders[i].enabled = true
            end
        end
        return
    end

    if interactor and interactor.DisableInteraction then
        interactor.DisableInteraction()
    end
    local colliders = clickZone:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = false
        end
    end
    if clickZone.activeSelf then
        clickZone:SetActive(false)
    end
end

local function SetForceZoneEnabled(enabled)
    if not forceZone then
        return
    end
    if forceZone.activeSelf ~= enabled then
        forceZone:SetActive(enabled)
    end
end

function RefreshTreeInteraction(force)
    local summoned = GetGlobalBool("Dog_BlackCatSummoned")
    local treeShakeStarted = GetGlobalBool("BlackCat_TreeShakeStarted")
    local treeHardShown = GetGlobalBool("BlackCat_TreeHardShown")
    local treeClosed = summoned or treeShakeStarted

    local forceEnabled = (not treeClosed) and (not treeHardShown)
    local clickEnabled = (not treeClosed) and treeHardShown

    if not force and lastForceEnabled == forceEnabled and lastClickEnabled == clickEnabled then
        return
    end
    lastForceEnabled = forceEnabled
    lastClickEnabled = clickEnabled

    -- 先关 Click（避免与 Force 重叠时弹出「大树对话」键）
    SetClickInteractionEnabled(clickEnabled)
    SetForceZoneEnabled(forceEnabled)
end

function Awake()
    RefreshTreeInteraction(true)
end

function Start()
    RefreshTreeInteraction(true)
end

function Update()
    RefreshTreeInteraction(false)
end
