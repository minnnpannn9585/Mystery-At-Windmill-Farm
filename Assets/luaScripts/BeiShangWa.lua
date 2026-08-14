---@var beforeSpot :UnityEngine.GameObject
---@var afterSpot :UnityEngine.GameObject
---@var cushionSpot :UnityEngine.GameObject
---@end

-- 挂在 parent 上；只切换下面三个引用，不动 parent。
-- !MintFish_Obtained → beforeSpot（悲伤蛙1）+ cushionSpot（E12 绿垫交互点）
-- MintFish_Obtained  → afterSpot（悲伤蛙2）；关掉蛙1 与 E12
-- 交互开关对齐 DaHuang：开点只开 Area/Collider；关点 DisableInteraction + 关 Collider；永不 EnableInteraction。

local lastActiveKey = nil

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

local function ApplySpots(mintFishObtained)
    SetSpotEnabled(beforeSpot, not mintFishObtained)
    SetSpotEnabled(afterSpot, mintFishObtained)
    -- E12 绿垫也是交互点，必须走 DisableInteraction，不能只 SetActive
    SetSpotEnabled(cushionSpot, not mintFishObtained)
end

function CheckFrogState()
    local mintFishObtained = GetGlobalBool("MintFish_Obtained")
    local activeKey = mintFishObtained and "after" or "before"

    if lastActiveKey == activeKey then
        return
    end
    lastActiveKey = activeKey

    -- 3-C / 3-D 末句写 MintFish_Obtained 时立刻切（同大黄 / 淑芬）
    ApplySpots(mintFishObtained)
end

function Start()
    CheckFrogState()
end

function Update()
    CheckFrogState()
end
