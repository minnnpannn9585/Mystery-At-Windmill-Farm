-- E19/E20 二层窗：BlackCat_Entered 前显示关闭窗，开窗后显示打开窗（互斥）
---@var closedPoint :UnityEngine.GameObject
---@var openPoint :UnityEngine.GameObject
---@end

local CLOSED_NAME = "E19 · 关闭二层窗"
local OPEN_NAME = "E20 · 打开二层窗"

local lastWindowOpen = nil

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

local function ResolvePoints()
    if closedPoint == nil then
        local t = self.transform:Find(CLOSED_NAME)
        closedPoint = t and t.gameObject or nil
    end
    if openPoint == nil then
        local t = self.transform:Find(OPEN_NAME)
        openPoint = t and t.gameObject or nil
    end
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

-- 对齐 ShuFen/DaHuang：开点只开 Area/Collider，永不 EnableInteraction；
-- 关点 DisableInteraction + 关 Collider。按钮由玩家走进交互区自然触发。
local function SetPointActive(pointGo, active)
    if pointGo == nil then
        return
    end

    local interactor = GetInteractorScript(pointGo)

    if active then
        if not pointGo.activeSelf then
            pointGo:SetActive(true)
        end
        if interactor and interactor.InteractionArea then
            interactor.InteractionArea.enabled = true
        end
        local colliders = pointGo:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
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
    local colliders = pointGo:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = false
        end
    end
    if pointGo.activeSelf then
        pointGo:SetActive(false)
    end
end

function RefreshSecondFloorWindow(force)
    ResolvePoints()
    local windowOpen = GetGlobalBool("BlackCat_Entered")

    if not force and lastWindowOpen == windowOpen then
        return
    end
    lastWindowOpen = windowOpen

    SetPointActive(closedPoint, not windowOpen)
    SetPointActive(openPoint, windowOpen)

    print(string.format(
        "[SecondFloorWindow] open=%s (E19=%s E20=%s)",
        tostring(windowOpen),
        tostring(not windowOpen),
        tostring(windowOpen)))
end

function Start()
    RefreshSecondFloorWindow(true)
    _G["SecondFloorWindow_Refresh"] = RefreshSecondFloorWindow
end

function Update()
    RefreshSecondFloorWindow(false)
end
