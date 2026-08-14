---@var commissionSpot :UnityEngine.GameObject
---@var hubSpot :UnityEngine.GameObject
---@var ngPlusSpot :UnityEngine.GameObject
---@var gateBlockCollider :UnityEngine.Collider
---@end

-- 挂在 parent 上；只 SetActive 下面三个 Spot 引用，不动 parent。
-- !NGPlus && !Shufen_CommissionDone → commissionSpot
-- !NGPlus && Shufen_CommissionDone  → hubSpot
-- NGPlus                            → ngPlusSpot
-- 交互开关对齐 DaHuang：开点只开 Area/Collider；关点 DisableInteraction + 关 Collider；永不 EnableInteraction。

local lastActiveKey = nil
local lastCommissionDone = nil

local function GetGlobalBool(varName)
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return getFunc(varName) == true
    end
    local globalVars = _G["_GlobalVariables"]
    if globalVars and globalVars[varName] then
        return globalVars[varName].value == true
    end
    return false
end

local function GetInteractorScript(pointGo)
    if pointGo == nil then
        return nil
    end
    local scripts = pointGo:GetComponents(typeof(DouyinScript))
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

-- 与 DaHuang.SetInteractionEnabled 同语义（额外 SetActive 做视觉切换）
local function SetSpotEnabled(pointGo, enabled)
    if pointGo == nil then
        return
    end

    local interactorScript = GetInteractorScript(pointGo)

    if enabled then
        if not pointGo.activeSelf then
            pointGo:SetActive(true)
        end
        if interactorScript and interactorScript.InteractionArea then
            interactorScript.InteractionArea.enabled = true
        end
        local colliders = pointGo:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
        if colliders then
            for i = 0, colliders.Length - 1 do
                colliders[i].enabled = true
            end
        end
        return
    end

    if interactorScript and interactorScript.DisableInteraction then
        interactorScript.DisableInteraction()
    end
    local colliders = pointGo:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = false
        end
    end
    if pointGo.activeSelf then
        local playParticle = _G["PlayParticle"]
        if playParticle then
            playParticle("vfx_characterChange", pointGo.transform.position)
        end
        pointGo:SetActive(false)
    end
end

local function UpdateGateBlockCollider(commissionDone)
    if not gateBlockCollider then
        return
    end
    gateBlockCollider.enabled = not commissionDone
end

local function ResolveActiveKey(commissionDone, ngPlus)
    if ngPlus then
        return "ngplus"
    end
    if commissionDone then
        return "hub"
    end
    return "commission"
end

local function ApplySpots(activeKey)
    SetSpotEnabled(commissionSpot, activeKey == "commission")
    SetSpotEnabled(hubSpot, activeKey == "hub")
    SetSpotEnabled(ngPlusSpot, activeKey == "ngplus")
end

function CheckShufenState()
    local commissionDone = GetGlobalBool("Shufen_CommissionDone")
    local ngPlus = GetGlobalBool("NGPlus")
    local activeKey = ResolveActiveKey(commissionDone, ngPlus)

    if lastCommissionDone ~= commissionDone then
        lastCommissionDone = commissionDone
        UpdateGateBlockCollider(commissionDone)
    end

    if lastActiveKey == activeKey then
        return
    end
    lastActiveKey = activeKey

    -- 对话中变量一变就切（同大黄 DogStatus=4），开新点不 EnableInteraction
    ApplySpots(activeKey)
end

function Start()
    CheckShufenState()
end

function Update()
    CheckShufenState()
end
