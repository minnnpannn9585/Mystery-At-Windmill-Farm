-- 老鼠兄弟墙缝 · 商店路由（盲盒抽选 / 扣费 / 派生 hub 条件）
---@end

local HUB_ID = 100
local HUB_REVISIT_DISPATCH_ID = 95
local NGPLUS_HUB_ID = 910

local CHEAP_INTEL = {
    [1] = 500, [2] = 510, [3] = 520, [4] = 530, [5] = 540,
    [6] = 550, [7] = 560, [8] = 570, [9] = 580, [10] = 590,
}

local PREMIUM_INTEL = {
    [1] = 600, [2] = 610, [3] = 620, [4] = 630, [5] = 640,
    [6] = 650, [7] = 660, [8] = 670,
}

local function GetVar(name)
    local fn = _G["GetGlobalVar"]
    return fn and fn(name)
end

local function SetVar(name, value, vtype)
    local fn = _G["SetGlobalVar"]
    if fn then
        fn(name, value, vtype or "bool")
    end
end

local function GetBool(name)
    return GetVar(name) == true
end

function TrySpendCheese(amount)
    local cur = tonumber(GetVar("CheeseCount")) or 0
    if cur < amount then
        return false
    end
    SetVar("CheeseCount", cur - amount, "int")
    if _G["OnCheeseCountChanged"] then
        _G["OnCheeseCountChanged"]()
    end
    return true
end

local function IsCheapSold(i)
    return GetBool(string.format("Mouse_CheapSold_%02d", i))
end

local function IsPremiumSold(i)
    return GetBool(string.format("Mouse_PremiumSold_%02d", i))
end

local function PremiumPoolLimit()
    return GetBool("Mouse_PremiumPoolUnlocked") and 8 or 2
end

local function CheapPoolAvailable()
    for i = 1, 10 do
        if not IsCheapSold(i) then
            return true
        end
    end
    return false
end

local function PremiumPoolAvailable()
    for i = 1, PremiumPoolLimit() do
        if not IsPremiumSold(i) then
            return true
        end
    end
    return false
end

-- 钱包 + 场景未捡（C02 仅 NGPlus 计入）
local function CheeseRemainingTotal()
    local wallet = tonumber(GetVar("CheeseCount")) or 0
    local unpicked = 0
    local registry = _G._CheesePickupRegistry
    local picked = _G._CheesePickupState
    local ngPlus = GetBool("NGPlus")
    if registry then
        for id, info in pairs(registry) do
            if info and not (picked and picked[id]) then
                if not info.requiresNGPlus or ngPlus then
                    unpicked = unpicked + (tonumber(info.amount) or 1)
                end
            end
        end
    end
    return wallet + unpicked
end

local function CanAffordMint8InGame()
    return CheeseRemainingTotal() >= 8
end

local refreshingDerived = false

function RefreshDerivedFlags()
    -- 防重入：派生标志本身是 Mouse_ 变量，SetVar 会回调本函数，否则无限递归
    if refreshingDerived then
        return
    end
    refreshingDerived = true
    SetVar("Mouse_CheapPoolAvailable", CheapPoolAvailable(), "bool")
    SetVar("Mouse_PremiumPoolAvailable", PremiumPoolAvailable(), "bool")
    SetVar("Mouse_CanAffordMint8InGame", CanAffordMint8InGame(), "bool")
    refreshingDerived = false
end

local function PickFromPool(pool, soldFn, count)
    local available = {}
    for i = 1, count do
        if not soldFn(i) then
            local node = pool[i]
            if node then
                table.insert(available, node)
            end
        end
    end
    if #available == 0 then
        return nil
    end
    return available[math.random(1, #available)]
end

function PickCheapIntel()
    return PickFromPool(CHEAP_INTEL, IsCheapSold, 10)
end

function PickPremiumIntel()
    return PickFromPool(PREMIUM_INTEL, IsPremiumSold, PremiumPoolLimit())
end

local function GoToDialogueNode(nodeId)
    local mgr = _G["_DialogueManager"]
    if mgr and mgr.JumpToDialogueNode then
        return mgr.JumpToDialogueNode(nodeId)
    end
    return false
end

local function GoToHub()
    if GetBool("NGPlus") then
        return GoToDialogueNode(NGPLUS_HUB_ID)
    end
    if GetBool("Mouse_FirstGreetShown") then
        return GoToDialogueNode(HUB_REVISIT_DISPATCH_ID)
    end
    return GoToDialogueNode(HUB_ID)
end

function UnlockMouseIntelPage(soldVarName)
    if _G["BookController_UnlockMouseIntel"] then
        _G["BookController_UnlockMouseIntel"](soldVarName)
    end
end

function MouseShop_HandleAction(action, option)
    RefreshDerivedFlags()

    if action == "cheap" then
        local node = PickCheapIntel()
        if not node then
            GoToHub()
            return true
        end
        if not TrySpendCheese(1) then
            GoToHub()
            return true
        end
        RefreshDerivedFlags()
        GoToDialogueNode(node)
        return true
    end

    if action == "premium" then
        local node = PickPremiumIntel()
        if not node then
            GoToHub()
            return true
        end
        if not TrySpendCheese(5) then
            GoToHub()
            return true
        end
        RefreshDerivedFlags()
        GoToDialogueNode(node)
        return true
    end

    if action == "pay8_mint" or action == "pay8_frog" then
        if not TrySpendCheese(8) then
            -- 整场剩余锁允许“未捡奶酪”计入显示；钱包不足时明确提示玩家先去拾取。
            GoToDialogueNode(260)
            return true
        end

        -- 扣费与资格写入同帧完成，避免付费后在演出途中退出造成“钱扣了、资格没给”。
        SetVar("Mouse_MintFishPaid", true, "bool")
        SetVar("Mouse_PremiumPoolUnlocked", true, "bool")
        RefreshDerivedFlags()
        local nextId = option and option.Next
        if nextId and nextId > 0 then
            GoToDialogueNode(nextId)
        else
            GoToHub()
        end
        return true
    end

    return false
end

function Start()
    _G["MouseBrother_RefreshDerivedFlags"] = RefreshDerivedFlags
    _G["MouseShop_HandleAction"] = MouseShop_HandleAction
    _G["MouseBrother_TrySpendCheese"] = TrySpendCheese
    RefreshDerivedFlags()
end

function Update()
    -- 对话外也保持派生条件新鲜（拾取奶酪后 hub 未打开时）
    if UnityEngine.Time.frameCount % 120 == 0 then
        RefreshDerivedFlags()
    end
end
