-- 登顶前禁用乌鸦 NPC 点击（Crow_RoofIntroShown 后才可点 entry#0）
---@end

local lastInteractionEnabled = nil

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

local function GetDouyinInteractorScript()
    local comp = self:GetDouyinScript("DouyinInteractor")
    if comp and comp.script then
        return comp.script
    end
    local ds = self.gameObject:GetComponent(typeof(DouyinScript))
    if ds and ds.script and ds.script.ButtonConfigs then
        return ds.script
    end
    return nil
end

local function SetInteractionEnabled(enabled)
    local interactorScript = GetDouyinInteractorScript()

    if enabled then
        if interactorScript and interactorScript.InteractionArea then
            interactorScript.InteractionArea.enabled = true
        end
        local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        if colliders then
            for i = 0, colliders.Length - 1 do
                colliders[i].enabled = true
            end
        end
        if interactorScript and interactorScript.EnableInteraction then
            interactorScript.EnableInteraction()
        end
    else
        if interactorScript and interactorScript.DisableInteraction then
            interactorScript.DisableInteraction()
        end
        local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        if colliders then
            for i = 0, colliders.Length - 1 do
                colliders[i].enabled = false
            end
        end
    end
end

function RefreshCrowInteraction(force)
    local roofIntroShown = GetGlobalBool("Crow_RoofIntroShown")
    local interactionEnabled = roofIntroShown

    if not force and lastInteractionEnabled == interactionEnabled then
        return
    end
    lastInteractionEnabled = interactionEnabled

    SetInteractionEnabled(interactionEnabled)
end

function Start()
    RefreshCrowInteraction(true)
end

function Update()
    RefreshCrowInteraction(false)
end
