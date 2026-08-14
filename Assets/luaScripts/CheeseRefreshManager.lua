-- C02 二周目奶酪碎刷新（NGPlus 后重置拾取点）
---@end

local function RefreshAllPickups()
    _G._CheesePickupState = {}
    if _G["CheeseSpawner_Respawn"] then
        _G["CheeseSpawner_Respawn"]()
    end
    if _G["MouseBrother_RefreshDerivedFlags"] then
        _G["MouseBrother_RefreshDerivedFlags"]()
    end
    print("[CheeseRefreshManager] 已刷新全部奶酪拾取点")
end

function OnNGPlusActivated()
    RefreshAllPickups()
end

function Start()
    _G["CheeseRefresh_OnNGPlus"] = OnNGPlusActivated

    local getFunc = _G["GetGlobalVar"]
    if getFunc and getFunc("NGPlus") == true then
        RefreshAllPickups()
    end
end
