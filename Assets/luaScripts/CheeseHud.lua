-- HUD：奶酪碎计数（doc 11）
-- 开局隐藏图标；首次 CheeseCount>0（捡拾 / 调试加奶酪）时显示并弹跳
---@var countText :UnityEngine.UI.Text
---@end

local ICON_BOUNCE_DURATION = 0.4
local ICON_BOUNCE_PEAK = 1.5

local cheeseRoot = nil
local cheeseBaseScale = nil
local iconBouncePlaying = false
local iconBounceElapsed = 0
local cheeseHudUnlocked = false
local lastCheeseCount = 0

local function GetCheeseCount()
    local getFunc = _G["GetGlobalVar"]
    if getFunc then
        return tonumber(getFunc("CheeseCount")) or 0
    end
    return 0
end

local function ResolveCheeseRoot()
    if cheeseRoot then return cheeseRoot end
    if not countText or not countText.transform or not countText.transform.parent then
        return nil
    end
    cheeseRoot = countText.transform.parent.gameObject
    local s = cheeseRoot.transform.localScale
    cheeseBaseScale = CS.UnityEngine.Vector3(s.x, s.y, s.z)
    return cheeseRoot
end

local function PlayIconBounce()
    local root = ResolveCheeseRoot()
    if not root or not cheeseBaseScale then return end
    iconBouncePlaying = true
    iconBounceElapsed = 0
end

local function TickIconBounce(dt)
    if not iconBouncePlaying then return end
    local root = ResolveCheeseRoot()
    if not root or not cheeseBaseScale then
        iconBouncePlaying = false
        return
    end
    iconBounceElapsed = iconBounceElapsed + dt
    local progress = iconBounceElapsed / ICON_BOUNCE_DURATION
    if progress >= 1 then
        root.transform.localScale = cheeseBaseScale
        iconBouncePlaying = false
        return
    end
    local s = 1 + (ICON_BOUNCE_PEAK - 1) * math.sin(progress * math.pi)
    root.transform.localScale = CS.UnityEngine.Vector3(
        cheeseBaseScale.x * s,
        cheeseBaseScale.y * s,
        cheeseBaseScale.z
    )
end

function RefreshCheeseHud()
    local count = GetCheeseCount()
    if countText then
        countText.text = tostring(count)
    end
end

local function RevealCheeseHud(withAnim)
    if cheeseHudUnlocked then
        RefreshCheeseHud()
        return
    end
    local root = ResolveCheeseRoot()
    if not root then return end
    cheeseHudUnlocked = true
    root:SetActive(true)
    RefreshCheeseHud()
    if withAnim then
        PlayIconBounce()
    end
end

function OnCheeseCountChanged()
    local count = GetCheeseCount()
    local gained = count > lastCheeseCount
    lastCheeseCount = count
    RefreshCheeseHud()
    if not gained then
        return
    end
    if not cheeseHudUnlocked then
        RevealCheeseHud(true)
    else
        PlayIconBounce()
    end
end

function Update()
    TickIconBounce(CS.UnityEngine.Time.deltaTime)
end

function Start()
    _G["CheeseHud_Refresh"] = RefreshCheeseHud
    _G["OnCheeseCountChanged"] = OnCheeseCountChanged

    lastCheeseCount = GetCheeseCount()
    local root = ResolveCheeseRoot()
    if lastCheeseCount > 0 then
        RevealCheeseHud(false)
    elseif root then
        root:SetActive(false)
        cheeseHudUnlocked = false
        RefreshCheeseHud()
    else
        RefreshCheeseHud()
    end
end
