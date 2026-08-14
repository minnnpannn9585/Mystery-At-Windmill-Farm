GlobalVariableList = {}

---@var GlobalVariablesScript :DouyinScript
---@var NPCDataConfig :DouyinScript
---@var DialogueData :DouyinScript[]
---@end

local globalVariables = {}
local debugButtonImages = {}
local debugIntLabels = {}
local debugIntInitialValues = {}

-- 开发测 bool/int 变量 UI（Canvas 滚动列表）；发布前改 false
local VAR_DEBUG_UI_ENABLED = false

-- int 调试按钮循环上限（doc 17）；到顶后回到 GlobalVariables 初始 value
local DEBUG_INT_MAX = {
    ChickTraceCount = 3,
    TreeClueCount = 4,
    DogStatus = 4,
    ChickStatus = 3,
    CheeseCount = 99,
}

-- 开发测对话分支时设为 true：保留 NPCData_Config 里 Publish 的 currentBranchId（如大黄 branch 5 → FROM_DOC）
-- 正式打包/发布前改回 false
local KEEP_NPC_BRANCH_FOR_TEST = false

local COLOR_OFF = UnityEngine.Color(0.22, 0.24, 0.28, 0.92)
local COLOR_ON = UnityEngine.Color(0.18, 0.62, 0.32, 1.0)
local COLOR_INT = UnityEngine.Color(0.48, 0.36, 0.14, 0.95)
local COLOR_ACTION = UnityEngine.Color(0.22, 0.38, 0.58, 0.95)

local function ParseItemValue(item)
    if item.type == "bool" then
        return item.value == true or item.value == "true" or item.value == 1
    end
    return tonumber(item.value) or 0
end

local function FindListItem(varName)
    if not GlobalVariableList then return nil end
    for _, item in ipairs(GlobalVariableList) do
        if item.name == varName then
            return item
        end
    end
    return nil
end

local function LoadGlobalVariablesFromList(list)
    if not list then
        print("[GlobalVariables] GlobalVariableList 为空")
        return
    end

    for _, item in ipairs(list) do
        if item.name and item.type then
            local value = ParseItemValue(item)
            globalVariables[item.name] = { type = item.type, value = value }
            if item.type == "int" then
                debugIntInitialValues[item.name] = value
            end
        end
    end
    print("[GlobalVariables] 从 GlobalVariableList 加载完成")
end

local function BindInspectorVariableList()
    if GlobalVariablesScript and GlobalVariablesScript.script and GlobalVariablesScript.script.GlobalVariables then
        GlobalVariableList = GlobalVariablesScript.script.GlobalVariables
        return
    end
    print("[GlobalVariables] GlobalVariablesScript 引用未设置，GlobalVariableList 保持为空")
end

function GetGlobalVar(varName)
    if varName == nil or globalVariables[varName] == nil then
        return nil
    end
    return globalVariables[varName].value
end

function SetGlobalVar(varName, value, varType)
    if varName == nil or varName == "" then return end
    varType = varType or "bool"

    if globalVariables[varName] == nil then
        if varType == "bool" then
            globalVariables[varName] = { type = "bool", value = false }
        else
            globalVariables[varName] = { type = "int", value = 0 }
        end
    end

    if varType == "bool" then
        globalVariables[varName].value = (value == true or value == "true" or value == 1)
    else
        globalVariables[varName].value = tonumber(value) or 0
    end

    local runtimeValue = globalVariables[varName].value
    local listItem = FindListItem(varName)
    if listItem then
        listItem.value = runtimeValue
    end

    local btnImage = debugButtonImages[varName]
    if btnImage and varType == "bool" then
        btnImage.color = (runtimeValue == true) and COLOR_ON or COLOR_OFF
    end

    local intLabel = debugIntLabels[varName]
    if intLabel and varType == "int" then
        intLabel.text = varName .. " = " .. tostring(runtimeValue)
    end

    print("[GlobalVariables] 设置变量: " .. varName .. " = " .. tostring(runtimeValue))

    if varName == "CheeseCount" and varType == "int" and _G["OnCheeseCountChanged"] then
        _G["OnCheeseCountChanged"]()
    end
    if string.sub(varName or "", 1, 6) == "Mouse_" and _G["MouseBrother_RefreshDerivedFlags"] then
        _G["MouseBrother_RefreshDerivedFlags"]()
    end
    if varName == "NGPlus" and varType == "bool" and runtimeValue == true and _G["CheeseRefresh_OnNGPlus"] then
        _G["CheeseRefresh_OnNGPlus"]()
    end
    if varName == "BlackCat_Entered" and _G["SecondFloorWindow_Refresh"] then
        _G["SecondFloorWindow_Refresh"](true)
    end
    if varName == "BlackCat_Entered" and runtimeValue == true and _G.ClimbPath_Refresh then
        _G.ClimbPath_Refresh("roof")
    end
    if varName == "E05_GrainSoakGet" and _G["E05GrainSoak_Refresh"] then
        _G["E05GrainSoak_Refresh"](false)
    end
    if _G["BookController_OnVarChanged"] then
        _G["BookController_OnVarChanged"](varName)
    end
end

function GetGlobalVarType(varName)
    if varName == nil or globalVariables[varName] == nil then
        return nil
    end
    return globalVariables[varName].type
end

local function CreateRectChild(name, parent, anchorMin, anchorMax, offsetMin, offsetMax)
    local go = UnityEngine.GameObject(name)
    go.transform:SetParent(parent, false)
    local rt = go:AddComponent(typeof(UnityEngine.RectTransform))
    rt.anchorMin = anchorMin
    rt.anchorMax = anchorMax
    rt.offsetMin = offsetMin
    rt.offsetMax = offsetMax
    return go, rt
end

local function AddToggleBoolButton(contentRt, varName)
    local btnGo = UnityEngine.GameObject("VarBtn_" .. varName)
    btnGo.transform:SetParent(contentRt, false)
    local btnRt = btnGo:AddComponent(typeof(UnityEngine.RectTransform))
    btnRt.anchorMin = UnityEngine.Vector2(0, 1)
    btnRt.anchorMax = UnityEngine.Vector2(1, 1)
    btnRt.pivot = UnityEngine.Vector2(0.5, 1)
    btnRt.sizeDelta = UnityEngine.Vector2(0, 34)

    local layoutEl = btnGo:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    layoutEl.preferredHeight = 34
    layoutEl.minHeight = 34

    local img = btnGo:AddComponent(typeof(UnityEngine.UI.Image))
    local initial = GetGlobalVar(varName) == true
    img.color = initial and COLOR_ON or COLOR_OFF
    debugButtonImages[varName] = img

    local btn = btnGo:AddComponent(typeof(UnityEngine.UI.Button))
    btn.targetGraphic = img

    local textGo = UnityEngine.GameObject("Label")
    textGo.transform:SetParent(btnRt, false)
    local textRt = textGo:AddComponent(typeof(UnityEngine.RectTransform))
    textRt.anchorMin = UnityEngine.Vector2(0, 0)
    textRt.anchorMax = UnityEngine.Vector2(1, 1)
    textRt.offsetMin = UnityEngine.Vector2(8, 2)
    textRt.offsetMax = UnityEngine.Vector2(-8, -2)
    local label = textGo:AddComponent(typeof(UnityEngine.UI.Text))
    label.text = varName
    label.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
    label.fontSize = 13
    label.alignment = UnityEngine.TextAnchor.MiddleLeft
    label.color = UnityEngine.Color(0.95, 0.95, 0.95, 1)

    local captured = varName
    btn.onClick:AddListener(function()
        local current = GetGlobalVar(captured) == true
        SetGlobalVar(captured, not current, "bool")
    end)
end

local function AddIncrementIntButton(contentRt, varName, initialValue, maxValue)
    local btnGo = UnityEngine.GameObject("VarBtn_" .. varName)
    btnGo.transform:SetParent(contentRt, false)
    local btnRt = btnGo:AddComponent(typeof(UnityEngine.RectTransform))
    btnRt.anchorMin = UnityEngine.Vector2(0, 1)
    btnRt.anchorMax = UnityEngine.Vector2(1, 1)
    btnRt.pivot = UnityEngine.Vector2(0.5, 1)
    btnRt.sizeDelta = UnityEngine.Vector2(0, 34)

    local layoutEl = btnGo:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    layoutEl.preferredHeight = 34
    layoutEl.minHeight = 34

    local img = btnGo:AddComponent(typeof(UnityEngine.UI.Image))
    img.color = COLOR_INT
    debugButtonImages[varName] = img

    local btn = btnGo:AddComponent(typeof(UnityEngine.UI.Button))
    btn.targetGraphic = img

    local textGo = UnityEngine.GameObject("Label")
    textGo.transform:SetParent(btnRt, false)
    local textRt = textGo:AddComponent(typeof(UnityEngine.RectTransform))
    textRt.anchorMin = UnityEngine.Vector2(0, 0)
    textRt.anchorMax = UnityEngine.Vector2(1, 1)
    textRt.offsetMin = UnityEngine.Vector2(8, 2)
    textRt.offsetMax = UnityEngine.Vector2(-8, -2)
    local label = textGo:AddComponent(typeof(UnityEngine.UI.Text))
    local current = tonumber(GetGlobalVar(varName)) or initialValue
    label.text = varName .. " = " .. tostring(current)
    label.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
    label.fontSize = 13
    label.alignment = UnityEngine.TextAnchor.MiddleLeft
    label.color = UnityEngine.Color(0.95, 0.95, 0.95, 1)
    debugIntLabels[varName] = label

    local captured = varName
    local capturedInitial = initialValue
    local capturedMax = maxValue
    btn.onClick:AddListener(function()
        local cur = tonumber(GetGlobalVar(captured)) or capturedInitial
        local next = cur + 1
        if capturedMax and next > capturedMax then
            next = capturedInitial
        end
        SetGlobalVar(captured, next, "int")
    end)
end

local function SetVarDebugPanelVisible(visible)
    local canvas = UnityEngine.GameObject.Find("Canvas")
    if not canvas then return end
    local panel = canvas.transform:Find("VarDebugPanel")
    local openBtn = canvas.transform:Find("VarDebugOpenBtn")
    if panel then
        panel.gameObject:SetActive(visible)
    end
    if openBtn then
        openBtn.gameObject:SetActive(not visible)
    end
end

local function AddFixedButton(parentRt, name, anchorMin, anchorMax, offsetMin, offsetMax, label, color, onClick)
    local btnGo, btnRt = CreateRectChild(name, parentRt, anchorMin, anchorMax, offsetMin, offsetMax)
    local img = btnGo:AddComponent(typeof(UnityEngine.UI.Image))
    img.color = color or COLOR_ACTION

    local btn = btnGo:AddComponent(typeof(UnityEngine.UI.Button))
    btn.targetGraphic = img
    btn.onClick:AddListener(onClick)

    local textGo = UnityEngine.GameObject("Label")
    textGo.transform:SetParent(btnRt, false)
    local textRt = textGo:AddComponent(typeof(UnityEngine.RectTransform))
    textRt.anchorMin = UnityEngine.Vector2(0, 0)
    textRt.anchorMax = UnityEngine.Vector2(1, 1)
    textRt.offsetMin = UnityEngine.Vector2(4, 2)
    textRt.offsetMax = UnityEngine.Vector2(-4, -2)
    local text = textGo:AddComponent(typeof(UnityEngine.UI.Text))
    text.text = label
    text.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
    text.fontSize = 13
    text.alignment = UnityEngine.TextAnchor.MiddleCenter
    text.color = UnityEngine.Color(0.95, 0.95, 0.95, 1)
    return btnGo
end

local function AddActionButton(parentRt, label, onClick)
    local btnGo = UnityEngine.GameObject("ActionBtn_" .. label)
    btnGo.transform:SetParent(parentRt, false)
    local btnRt = btnGo:AddComponent(typeof(UnityEngine.RectTransform))
    btnRt.anchorMin = UnityEngine.Vector2(0, 1)
    btnRt.anchorMax = UnityEngine.Vector2(1, 1)
    btnRt.pivot = UnityEngine.Vector2(0.5, 1)
    btnRt.sizeDelta = UnityEngine.Vector2(0, 34)

    local layoutEl = btnGo:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    layoutEl.preferredHeight = 34
    layoutEl.minHeight = 34

    local img = btnGo:AddComponent(typeof(UnityEngine.UI.Image))
    img.color = COLOR_ACTION

    local btn = btnGo:AddComponent(typeof(UnityEngine.UI.Button))
    btn.targetGraphic = img
    btn.onClick:AddListener(onClick)

    local textGo = UnityEngine.GameObject("Label")
    textGo.transform:SetParent(btnRt, false)
    local textRt = textGo:AddComponent(typeof(UnityEngine.RectTransform))
    textRt.anchorMin = UnityEngine.Vector2(0, 0)
    textRt.anchorMax = UnityEngine.Vector2(1, 1)
    textRt.offsetMin = UnityEngine.Vector2(8, 2)
    textRt.offsetMax = UnityEngine.Vector2(-8, -2)
    local text = textGo:AddComponent(typeof(UnityEngine.UI.Text))
    text.text = label
    text.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
    text.fontSize = 13
    text.alignment = UnityEngine.TextAnchor.MiddleCenter
    text.color = UnityEngine.Color(0.95, 0.95, 0.95, 1)
end

local function TeleportLocalActorNear(npcGoName, offset)
    local npcGo = UnityEngine.GameObject.Find(npcGoName)
    if not npcGo then
        print("[GlobalVarDebug] 未找到 NPC: " .. npcGoName)
        return
    end

    local actor = DouyinActorService.GetLocalActor()
    if not actor then
        print("[GlobalVarDebug] 未找到本地玩家 Actor")
        return
    end

    local targetPos = npcGo.transform.position + (offset or UnityEngine.Vector3(0, 0, 1.8))
    actor:Teleport(targetPos)
    print(string.format("[GlobalVarDebug] 已传送到 %s 附近 (%.2f, %.2f, %.2f)",
        npcGoName, targetPos.x, targetPos.y, targetPos.z))
end

local function TeleportToCrow()
    TeleportLocalActorNear("乌鸦", UnityEngine.Vector3(0, 0, 1.8))
end

-- 传到红顶屋二层窗（E20）；若未开窗则先置 BlackCat_Entered 并刷新，便于测 Ending
local function TeleportToAtticWindow()
    SetGlobalVar("BlackCat_Entered", true, "bool")
    if _G["SecondFloorWindow_Refresh"] then
        _G["SecondFloorWindow_Refresh"](true)
    end

    local goName = "E20 · 打开二层窗"
    local go = UnityEngine.GameObject.Find(goName)
    if not go then
        goName = "E19 · 关闭二层窗"
        go = UnityEngine.GameObject.Find(goName)
    end
    if not go then
        print("[GlobalVarDebug] 未找到二层窗交互点 (E19/E20)")
        return
    end

    local actor = DouyinActorService.GetLocalActor()
    if not actor then
        print("[GlobalVarDebug] 未找到本地玩家 Actor")
        return
    end

    local offset = UnityEngine.Vector3(0, 0, 1.5)
    local targetPos = go.transform.position + offset
    actor:Teleport(targetPos)
    print(string.format("[GlobalVarDebug] 已传送到二层窗 %s 附近 (%.2f, %.2f, %.2f)",
        goName, targetPos.x, targetPos.y, targetPos.z))
end

local function AddCheeseFive()
    local cur = tonumber(GetGlobalVar("CheeseCount")) or 0
    local maxVal = DEBUG_INT_MAX.CheeseCount or 99
    local nextVal = cur + 5
    if nextVal > maxVal then
        nextVal = maxVal
    end
    SetGlobalVar("CheeseCount", nextVal, "int")
end

local function BuildVarDebugScrollPanel()
    if not VAR_DEBUG_UI_ENABLED then return end

    local canvas = UnityEngine.GameObject.Find("Canvas")
    if not canvas then
        print("[GlobalVarDebug] 未找到 Canvas")
        return
    end

    local canvasRt = canvas:GetComponent(typeof(UnityEngine.RectTransform))
    if not canvasRt then
        print("[GlobalVarDebug] Canvas 无 RectTransform")
        return
    end

    if canvas.transform:Find("VarDebugPanel") or canvas.transform:Find("VarDebugOpenBtn") then
        print("[GlobalVarDebug] 调试 UI 已存在，跳过创建")
        return
    end

    AddFixedButton(
        canvasRt,
        "VarDebugOpenBtn",
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(-112, -44),
        UnityEngine.Vector2(-12, -12),
        "打开调试",
        COLOR_ACTION,
        function()
            SetVarDebugPanelVisible(true)
        end
    )

    local panelGo, panelRt = CreateRectChild(
        "VarDebugPanel",
        canvasRt,
        UnityEngine.Vector2(1, 0),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(-340, 12),
        UnityEngine.Vector2(-12, -12)
    )
    local panelBg = panelGo:AddComponent(typeof(UnityEngine.UI.Image))
    panelBg.color = UnityEngine.Color(0.08, 0.09, 0.12, 0.88)

    local headerGo, headerRt = CreateRectChild(
        "Header",
        panelRt,
        UnityEngine.Vector2(0, 1),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(8, -38),
        UnityEngine.Vector2(-8, -8)
    )
    local titleGo, titleRt = CreateRectChild(
        "Title",
        headerRt,
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(-76, 0)
    )
    local titleText = titleGo:AddComponent(typeof(UnityEngine.UI.Text))
    titleText.text = "调试面板"
    titleText.font = UnityEngine.Resources.GetBuiltinResource(typeof(UnityEngine.Font), "Arial.ttf")
    titleText.fontSize = 14
    titleText.alignment = UnityEngine.TextAnchor.MiddleLeft
    titleText.color = UnityEngine.Color(1, 1, 1, 0.9)

    AddFixedButton(
        headerRt,
        "CloseBtn",
        UnityEngine.Vector2(1, 0.5),
        UnityEngine.Vector2(1, 0.5),
        UnityEngine.Vector2(-68, -14),
        UnityEngine.Vector2(0, 14),
        "关闭调试",
        UnityEngine.Color(0.55, 0.22, 0.22, 0.95),
        function()
            SetVarDebugPanelVisible(false)
        end
    )

    local actionsGo, actionsRt = CreateRectChild(
        "Actions",
        panelRt,
        UnityEngine.Vector2(0, 1),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(8, -158),
        UnityEngine.Vector2(-8, -42)
    )
    local actionsLayout = actionsGo:AddComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
    actionsLayout.childAlignment = UnityEngine.TextAnchor.UpperCenter
    actionsLayout.childControlWidth = true
    actionsLayout.childControlHeight = true
    actionsLayout.childForceExpandWidth = true
    actionsLayout.childForceExpandHeight = false
    actionsLayout.spacing = 4
    AddActionButton(actionsRt, "到乌鸦身边", TeleportToCrow)
    AddActionButton(actionsRt, "到二层窗", TeleportToAtticWindow)
    AddActionButton(actionsRt, "奶酪碎 +5", AddCheeseFive)

    local scrollGo, scrollRt = CreateRectChild(
        "ScrollView",
        panelRt,
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(8, 8),
        UnityEngine.Vector2(-8, -164)
    )
    local scrollRect = scrollGo:AddComponent(typeof(UnityEngine.UI.ScrollRect))
    scrollRect.horizontal = false
    scrollRect.vertical = true
    scrollRect.movementType = UnityEngine.UI.ScrollRect.MovementType.Clamped
    scrollRect.scrollSensitivity = 24

    local viewportGo, viewportRt = CreateRectChild(
        "Viewport",
        scrollRt,
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(0, 0)
    )
    local viewportImg = viewportGo:AddComponent(typeof(UnityEngine.UI.Image))
    viewportImg.color = UnityEngine.Color(1, 1, 1, 0.01)
    viewportGo:AddComponent(typeof(UnityEngine.UI.Mask))

    local contentGo, contentRt = CreateRectChild(
        "Content",
        viewportRt,
        UnityEngine.Vector2(0, 1),
        UnityEngine.Vector2(1, 1),
        UnityEngine.Vector2(0, 0),
        UnityEngine.Vector2(0, 0)
    )
    contentRt.pivot = UnityEngine.Vector2(0.5, 1)

    local layout = contentGo:AddComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
    layout.childAlignment = UnityEngine.TextAnchor.UpperCenter
    layout.childControlWidth = true
    layout.childControlHeight = true
    layout.childForceExpandWidth = true
    layout.childForceExpandHeight = false
    layout.spacing = 4
    layout.padding = CS.UnityEngine.RectOffset(4, 4, 4, 4)

    local fitter = contentGo:AddComponent(typeof(UnityEngine.UI.ContentSizeFitter))
    fitter.horizontalFit = UnityEngine.UI.ContentSizeFitter.FitMode.Unconstrained
    fitter.verticalFit = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize

    scrollRect.viewport = viewportRt
    scrollRect.content = contentRt

    local boolCount = 0
    local intCount = 0
    if GlobalVariableList then
        for _, item in ipairs(GlobalVariableList) do
            if item.name and item.type == "bool" then
                AddToggleBoolButton(contentRt, item.name)
                boolCount = boolCount + 1
            elseif item.name and item.type == "int" then
                local initial = debugIntInitialValues[item.name]
                if initial == nil then
                    initial = ParseItemValue(item)
                end
                AddIncrementIntButton(contentRt, item.name, initial, DEBUG_INT_MAX[item.name])
                intCount = intCount + 1
            end
        end
    end

    panelGo:SetActive(false)

    print("[GlobalVarDebug] VarDebugPanel 已创建（默认关闭），bool 按钮 x" .. boolCount .. "，int 按钮 x" .. intCount)
end

function ResetAllNPCBranchesToStart()
    if not NPCDataConfig or not NPCDataConfig.script then
        print("[GlobalVariables] NPCDataConfig 引用未设置")
        return
    end

    local data = NPCDataConfig.script.NPCData
    if data and data.npcList then
        for _, npc in ipairs(data.npcList) do
            if npc.currentBranchId then
                npc.currentBranchId = 1
            end
        end
        print("[GlobalVariables] NPCData_Config 所有分支已重置为 1")
    end
end

function Start()
    BindInspectorVariableList()
    LoadGlobalVariablesFromList(GlobalVariableList)

    if KEEP_NPC_BRANCH_FOR_TEST then
        print("[GlobalVariables] KEEP_NPC_BRANCH_FOR_TEST=true，保留 NPCData 中的 currentBranchId")
    else
        ResetAllNPCBranchesToStart()
    end

    _G["_GlobalVariables"] = globalVariables
    _G["GetGlobalVar"] = GetGlobalVar
    _G["SetGlobalVar"] = SetGlobalVar
    _G["GetGlobalVarType"] = GetGlobalVarType
    if NPCDataConfig and NPCDataConfig.script then
        _G["_NPCDataConfig"] = NPCDataConfig.script.NPCData
    end

    local count = 0
    for _ in pairs(globalVariables) do count = count + 1 end
    print("[GlobalVariables] 初始化完成，共 " .. count .. " 个变量")

    BuildVarDebugScrollPanel()
end
