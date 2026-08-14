-- E03 身后偷听点：偷听一次后关闭；小鸡招供（ChickStatus>=3）后也关闭
-- 开点只开 Area/Collider；关点 DisableInteraction + 关 Collider；永不 EnableInteraction

local lastEnabled = nil

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

local function GetGlobalInt(name)
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return tonumber(getFunc(name)) or 0
    end
    local vars = _G["_GlobalVariables"]
    if vars and vars[name] then
        return tonumber(vars[name].value) or 0
    end
    return 0
end

local function ShouldEnableE03()
    if GetGlobalBool("E03_Overheard") then
        return false
    end
    if GetGlobalInt("ChickStatus") >= 3 then
        return false
    end
    return true
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
        return
    end

    if interactorScript and interactorScript.DisableInteraction then
        interactorScript.DisableInteraction()
    end
    local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = false
        end
    end
end

function RefreshE03Interaction(force)
    local enabled = ShouldEnableE03()
    if not force and lastEnabled == enabled then
        return
    end
    lastEnabled = enabled
    SetInteractionEnabled(enabled)
end

function Start()
    RefreshE03Interaction(true)
end

function Update()
    RefreshE03Interaction(false)
end
