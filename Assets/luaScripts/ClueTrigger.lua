--线索解锁脚本
---@var varName1 :string
---@var varType1 :string
---@var varValue1 :bool
---@var varIntValue1 :int
---@var varIsAdd1 :bool

---@var varName2 :string
---@var varType2 :string
---@var varValue2 :bool
---@var varIntValue2 :int
---@var varIsAdd2 :bool
---@end

function Awake()
    ResetAllBoolVariablesToFalse()
end

function Start()
end

function SetClue()
    local setFunc = _G["SetGlobalVar"]
    local getFunc = _G["GetGlobalVar"]

    if not setFunc then
        print("[ClueTrigger] ✗ SetGlobalVar 不存在，请确保 GlobalVariablesManager 已初始化")
        return
    end

    SetVariable(1, varName1, varType1, varValue1, varIntValue1, varIsAdd1, setFunc, getFunc)
    SetVariable(2, varName2, varType2, varValue2, varIntValue2, varIsAdd2, setFunc, getFunc)

    if _G.InteractionPointVfx_DiscoverFrom then
        _G.InteractionPointVfx_DiscoverFrom(self.gameObject)
    end

    print("[ClueTrigger] ✓ 所有变量设置完成")
end

function SetVariable(index, name, varType, value, intValue, isAdd, setFunc, getFunc)
    if name == nil or name == "" then
        return
    end

    local detectedType = _G["GetGlobalVarType"] and _G["GetGlobalVarType"](name)
    varType = detectedType or varType or "bool"

    if varType == "int" then
        if intValue == nil then
            print("[ClueTrigger] ⚠ 变量[" .. index .. "] " .. name .. " 的 intValue 未设置")
            return
        end

        local finalValue = intValue
        if isAdd and getFunc then
            local currentValue = getFunc(name) or 0
            finalValue = currentValue + intValue
        end
        setFunc(name, finalValue, "int")
        print("[ClueTrigger] ✓ 变量[" ..
        index ..
        "] " .. name .. " " .. (isAdd and "+" or "=") .. " " .. tostring(intValue) .. " => " .. tostring(finalValue))
    else
        if value == nil then
            print("[ClueTrigger] ⚠ 变量[" .. index .. "] " .. name .. " 的 value 未设置，默认设为 false")
            value = false
        end
        setFunc(name, value, "bool")
        print("[ClueTrigger] ✓ 变量[" .. index .. "] " .. name .. " = " .. tostring(value))
    end
end

function ResetAllBoolVariablesToFalse()
    local vars = _G["_GlobalVariables"]
    if vars then
        local setFunc = _G["SetGlobalVar"]
        for varName, varData in pairs(vars) do
            if varData.type == "bool" then
                if setFunc then
                    setFunc(varName, false, "bool")
                else
                    varData.value = false
                end
            end
        end
        print("[ClueTrigger] ✓ 已重置所有 bool 变量为 false")
    else
        print("[ClueTrigger] ✗ _GlobalVariables 不存在，请确保 GlobalVariablesManager 已初始化")
    end
end
