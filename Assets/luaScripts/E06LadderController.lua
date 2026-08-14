---@var barnLadder :UnityEngine.GameObject
---@var e06PlacedLadder :UnityEngine.GameObject
---@var discoveryDialogueId :int = 8
---@var placedDialogueId :int = 31
---@var textDiscover :string = "这里上面有个通道"
---@var textPlaceLadder :string = "摆放梯子"
---@end

-- 挂在「发现缺少梯子」物体上：E06 交互 + 架梯模型
-- 屏幕交互 UI 文字：同物体 DouyinInteractor → ButtonConfigs[1].Text（Inspector 填默认文案；本脚本按状态动态刷新）

local E06_POINT_NAME = "E06 · 发现缺少梯子"
local PLACED_LADDER_CHILD = "E06_placed_ladder"

local lastBarnVisible = nil
local lastPlacedVisible = nil
local lastInteractEnabled = nil
local lastButtonText = nil

local function GetGlobalBool(name)
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if not getFunc then
        return false
    end
    local v = getFunc(name)
    if type(v) == "number" then
        return v ~= 0
    end
    if type(v) == "string" then
        return v == "true" or v == "1"
    end
    return v == true
end

local function SetGlobalBool(name, value)
    local setFunc = _G["SetGlobalVar"]
    if setFunc then
        setFunc(name, value, "bool")
    end
end

local function GetDogStatus()
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return tonumber(getFunc("DogStatus")) or 1
    end
    return 1
end

local function IsE06Point()
    return self.gameObject.name == E06_POINT_NAME
end

local function GetDouyinInteractorScript()
    local comp = self:GetDouyinScript("DouyinInteractor")
    if comp and comp.script then
        return comp.script
    end
    return nil
end

local function ResolveBarnLadder()
    if barnLadder then
        return barnLadder
    end
    local dh = CS.UnityEngine.GameObject.Find("大黄")
    if dh then
        local t = dh.transform:Find("pingmuti")
        if t then
            return t.gameObject
        end
        t = dh.transform:Find("dogdrunkp/pingmuti")
        if t then
            return t.gameObject
        end
    end
    return CS.UnityEngine.GameObject.Find("pingmuti")
end

local function ResolvePlacedLadderVisual()
    if e06PlacedLadder then
        return e06PlacedLadder
    end
    local child = self.transform:Find(PLACED_LADDER_CHILD)
    if child then
        return child.gameObject
    end
    return CS.UnityEngine.GameObject.Find(PLACED_LADDER_CHILD)
end

local function DetachBarnLadderFromDogModel(ladderGo)
    if not ladderGo then
        return
    end
    local parent = ladderGo.transform.parent
    if parent and parent.name == "dogdrunkp" then
        local barnRoot = parent.parent
        if barnRoot then
            ladderGo.transform:SetParent(barnRoot, true)
        end
    end
end

local function SetColliderEnabled(enabled)
    local colliders = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
    if colliders then
        for i = 0, colliders.Length - 1 do
            colliders[i].enabled = enabled
        end
    end
end

local function ComputeE06InteractState()
    local borrowed = GetGlobalBool("E06_LadderBorrowed")
    local placed = GetGlobalBool("E06_LadderPlaced")
    local viewNeed = GetGlobalBool("E06_ViewNeedLadder")

    if placed then
        return false, nil
    end
    if borrowed then
        return true, textPlaceLadder or "摆放梯子"
    end
    if not viewNeed then
        return true, textDiscover or "这里上面有个通道"
    end
    -- 已发现缺梯、尚未借梯：关闭交互，等玩家去大黄借梯
    return false, nil
end

local function ApplyInteractorButtonText(interactorScript, label)
    if not interactorScript or not label or label == "" then
        return
    end
    if interactorScript.ButtonConfigs and #interactorScript.ButtonConfigs > 0 then
        interactorScript.ButtonConfigs[1].Text = label
    end
    if interactorScript.GetInteractorButton then
        local btn = interactorScript.GetInteractorButton(1)
        if btn then
            local txt = btn:GetComponentInChildren(typeof(CS.UnityEngine.UI.Text), true)
            if txt then
                txt.text = label
            end
        end
    end
end

local function RefreshE06InteractUI(force)
    if not IsE06Point() then
        return
    end

    local enabled, label = ComputeE06InteractState()
    local interactorScript = GetDouyinInteractorScript()

    if force or lastInteractEnabled ~= enabled then
        lastInteractEnabled = enabled
        SetColliderEnabled(enabled)
        if interactorScript then
            if enabled then
                if interactorScript.InteractionArea then
                    interactorScript.InteractionArea.enabled = true
                end
            elseif interactorScript.DisableInteraction then
                interactorScript.DisableInteraction()
            end
        end
    end

    if enabled and label and (force or lastButtonText ~= label) then
        lastButtonText = label
        ApplyInteractorButtonText(interactorScript, label)
    end
end

local function LoadMiaosuDialogue()
    local dialogueDataGo = CS.UnityEngine.GameObject.Find("DialogueData")
    if not dialogueDataGo then
        return nil
    end
    local childTransform = dialogueDataGo.transform:Find("miaosu")
    if not childTransform then
        return nil
    end
    local douyinScript = childTransform.gameObject:GetComponent(typeof(DouyinScript))
    if not douyinScript or not douyinScript.script then
        return nil
    end
    if douyinScript.script.DialogueConfig then
        return douyinScript.script.DialogueConfig
    end
    return douyinScript.script
end

function StartDiscoveryDialogue()
    local mgr = _G["_DialogueManager"]
    if not mgr or not mgr.StartDialogueWithData then
        print("[E06Ladder] DialogueManager 未就绪")
        return
    end
    local data = LoadMiaosuDialogue()
    if not data then
        print("[E06Ladder] 未找到 miaosu 对话数据")
        return
    end
    mgr.StartDialogueWithData(data, discoveryDialogueId or 8)
end

function StartPlacedDialogue()
    local mgr = _G["_DialogueManager"]
    if not mgr or not mgr.StartDialogueWithData then
        print("[E06Ladder] DialogueManager 未就绪")
        return
    end
    local data = LoadMiaosuDialogue()
    if not data then
        print("[E06Ladder] 未找到 miaosu 对话数据")
        return
    end
    mgr.StartDialogueWithData(data, placedDialogueId or 31)
end

function RefreshLadderState(force)
    local borrowed = GetGlobalBool("E06_LadderBorrowed")
    local placed = GetGlobalBool("E06_LadderPlaced")
    local dogStatus = GetDogStatus()

    local barnGo = ResolveBarnLadder()
    local showBarn = not borrowed and dogStatus < 4
    if barnGo and (force or lastBarnVisible ~= showBarn) then
        lastBarnVisible = showBarn
        barnGo:SetActive(showBarn)
    end

    if IsE06Point() then
        local placedGo = ResolvePlacedLadderVisual()
        if placedGo and placedGo ~= barnGo and (force or lastPlacedVisible ~= placed) then
            lastPlacedVisible = placed
            placedGo:SetActive(placed)
        end
        RefreshE06InteractUI(force)
    end
end

function PlaceLadderAtE06()
    if not GetGlobalBool("E06_LadderBorrowed") then
        print("[E06Ladder] 尚未借梯，无法架设")
        return
    end
    if GetGlobalBool("E06_LadderPlaced") then
        return
    end
    SetGlobalBool("E06_LadderPlaced", true)
    print("[E06Ladder] E06_LadderPlaced = true")
    RefreshLadderState(true)
    if _G.ClimbPath_Refresh then
        _G.ClimbPath_Refresh("barn")
    end
    StartPlacedDialogue()
end

function OnE06Interact()
    local borrowed = GetGlobalBool("E06_LadderBorrowed")
    local placed = GetGlobalBool("E06_LadderPlaced")
    local viewNeed = GetGlobalBool("E06_ViewNeedLadder")

    if placed then
        return
    end

    if borrowed then
        PlaceLadderAtE06()
        return
    end

    if not viewNeed then
        SetGlobalBool("E06_ViewNeedLadder", true)
        if _G.InteractionPointVfx_DiscoverFrom then
            _G.InteractionPointVfx_DiscoverFrom(self.gameObject)
        end
        StartDiscoveryDialogue()
        RefreshLadderState(true)
        return
    end
end

function Start()
    local ladderGo = ResolveBarnLadder()
    DetachBarnLadderFromDogModel(ladderGo)
    if ladderGo then
        barnLadder = ladderGo
    end

    if IsE06Point() then
        local placedGo = ResolvePlacedLadderVisual()
        if placedGo and placedGo ~= ladderGo then
            placedGo:SetActive(false)
        end
    end

    _G["E06Ladder_Place"] = function()
        PlaceLadderAtE06()
    end
    RefreshLadderState(true)
end

function Update()
    RefreshLadderState()
end
