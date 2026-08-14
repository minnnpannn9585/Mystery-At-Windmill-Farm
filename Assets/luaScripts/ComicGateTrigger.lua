-- E20 · 红顶屋二层窗 → 漫画收束（EndingController）

---@var placeholderDialogueId :int = 600
---@end

local function SetGlobalBool(name, value)
    local setFunc = _G["SetGlobalVar"]
    if setFunc then
        setFunc(name, value, "bool")
    end
end

local function GetGlobalBool(name)
    local getFunc = _G["GetGlobalVar"]
    if getFunc then
        return getFunc(name) == true
    end
    return false
end

function OnComicInteract()
    if GetGlobalBool("Comic_Revealed") then
        print("[ComicGate] 漫画已收束，忽略重复点击")
        return
    end

    -- 兜底：点击进入时关掉 roof 窗子引导 VFX（Trigger 未踩到时也关掉）
    if _G.ClimbPath_Advance then
        _G.ClimbPath_Advance("roof", 2)
    end

    SetGlobalBool("Comic_Revealed", true)
    print("[ComicGate] Comic_Revealed = true，启动 Ending")

    if not _G["EndingController_Start"] and _G["EndingController_TryRegister"] then
        _G["EndingController_TryRegister"]()
    end

    if _G["EndingController_Start"] then
        _G["EndingController_Start"]()
    else
        print("[ComicGate] ✗ 未找到 EndingController，请在 Notebook/Ending 上挂 EndingController.lua")
    end
end

function Start()
    _G["ComicGate_OnInteract"] = function()
        OnComicInteract()
    end
end
