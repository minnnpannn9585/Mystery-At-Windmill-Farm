-- 黑猫显隐与可点：摇树前不可交互，2-A 落地后可点；进屋后关闭（3-B / NGPlus 例外）
---@var catModel :UnityEngine.GameObject
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

local function ShouldEnableBlackCatInteraction()
    if GetGlobalBool("NGPlus") then
        return GetGlobalBool("Dog_BlackCatSummoned")
    end

    if not GetGlobalBool("Dog_BlackCatSummoned") then
        return false
    end

    if not GetGlobalBool("BlackCat_Entered") then
        return true
    end

    -- 漫画收束后仍可点进 3-B 揭穿
    return GetGlobalBool("Comic_Revealed") and not GetGlobalBool("BlackCat_StoneRevealShown")
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

-- 对齐 DaHuang / TreeInteractionController：开点只开 Area/Collider；关点 DisableInteraction + 关 Collider
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

    if catModel then
        local playParticle = _G["PlayParticle"]
        if playParticle then
            playParticle("vfx_characterChange", catModel.transform.position)
        end
        catModel:SetActive(enabled)
    end
end

function RefreshBlackCatInteraction(force)
    local interactionEnabled = ShouldEnableBlackCatInteraction()

    if not force and lastInteractionEnabled == interactionEnabled then
        return
    end
    lastInteractionEnabled = interactionEnabled

    SetInteractionEnabled(interactionEnabled)
end

function Start()
    if catModel == nil and self.transform.childCount > 0 then
        catModel = self.transform:GetChild(0).gameObject
    end
    RefreshBlackCatInteraction(true)
end

function Update()
    RefreshBlackCatInteraction(false)
end
