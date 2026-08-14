---@var sleepDog :UnityEngine.GameObject
---@var soberDog :UnityEngine.GameObject
---@end

-- 谷仓「大黄」与红顶「大黄 2」：DogStatus 控制睡/醒模型；DogStatus>=4 切换交互点

local lastSpotEnabled = nil
local lastAwake = nil

local function IsRedRoofSpot()
    return self.gameObject.name == "大黄 2"
end

local function GetDogStatus()
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return tonumber(getFunc("DogStatus")) or 1
    end
    local globalVars = _G["_GlobalVariables"]
    if globalVars and globalVars["DogStatus"] then
        return tonumber(globalVars["DogStatus"].value) or 1
    end
    return 1
end

local function GetDouyinInteractorScript()
    local comp = self:GetDouyinScript("DouyinInteractor")
    if comp and comp.script then
        return comp.script
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

local function GetVfxPosition()
    if soberDog and soberDog.activeSelf then
        return soberDog.transform.position
    end
    if sleepDog and sleepDog.activeSelf then
        return sleepDog.transform.position
    end
    if soberDog then
        return soberDog.transform.position
    end
    if sleepDog then
        return sleepDog.transform.position
    end
    return self.transform.position
end

local function PlayCharacterChangeVfx()
    local playParticle = _G["PlayParticle"]
    if playParticle then
        playParticle("vfx_characterChange", GetVfxPosition())
    end
end

local function ApplyAwakeModels(isAwake, playVfx)
    if playVfx then
        PlayCharacterChangeVfx()
    end
    if sleepDog then
        sleepDog:SetActive(not isAwake)
    end
    if soberDog then
        soberDog:SetActive(isAwake)
    end
end

local function HideAllModels()
    if sleepDog then sleepDog:SetActive(false) end
    if soberDog then soberDog:SetActive(false) end
end

function CheckDogState()
    local dogStatus = GetDogStatus()
    local isChapter2 = dogStatus >= 4
    local redRoof = IsRedRoofSpot()
    local spotEnabled = redRoof and isChapter2 or (not redRoof and not isChapter2)
    local isAwake = dogStatus >= 3

    if lastSpotEnabled == spotEnabled and lastAwake == isAwake then
        return
    end

    -- 首帧初始化不播粒子；仅实际状态切换时播
    local spotChanged = lastSpotEnabled ~= nil and lastSpotEnabled ~= spotEnabled
    local awakeChanged = lastAwake ~= nil and lastAwake ~= isAwake

    lastSpotEnabled = spotEnabled
    lastAwake = isAwake

    SetInteractionEnabled(spotEnabled)

    if not spotEnabled then
        if spotChanged then
            PlayCharacterChangeVfx()
        end
        HideAllModels()
        return
    end

    if redRoof then
        ApplyAwakeModels(true, spotChanged)
    else
        ApplyAwakeModels(isAwake, spotChanged or awakeChanged)
    end
end

function Start()
    CheckDogState()
end

function Update()
    CheckDogState()
end
