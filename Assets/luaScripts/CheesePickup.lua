-- C01/C02 奶酪碎碰撞拾取（doc 13 §13.5）
---@var pickupId :string
---@var amount :int = 1
---@var requiresNGPlus :bool = false
---@var visualRoot :UnityEngine.GameObject
---@var pickupVfx :UnityEngine.GameObject
---@end

if _G._CheesePickupState == nil then
    _G._CheesePickupState = {}
end
if _G._CheesePickupRefreshers == nil then
    _G._CheesePickupRefreshers = {}
end
-- id -> { amount, requiresNGPlus }；供老鼠「整场剩余奶酪」计算
if _G._CheesePickupRegistry == nil then
    _G._CheesePickupRegistry = {}
end

local function GetPickupId()
    if pickupId and pickupId ~= "" then
        return pickupId
    end
    local parent = self.transform.parent
    if parent and parent.parent and parent.parent.name == "奶酪散点" then
        return parent.name
    end
    return self.gameObject.name
end

local function GetGlobalBool(name)
    local getFunc = _G["GetGlobalVar"]
    return getFunc and getFunc(name) == true
end

local function IsPicked()
    return _G._CheesePickupState[GetPickupId()] == true
end

local function SetPickedState(picked)
    local id = GetPickupId()
    if picked then
        _G._CheesePickupState[id] = true
    else
        _G._CheesePickupState[id] = nil
    end
end

local function ResolveVisualRoot()
    if visualRoot then
        return visualRoot
    end
    local t = self.transform:Find("cheeseSingle")
    return t and t.gameObject or nil
end

local function ResolvePickupVfx()
    if pickupVfx then
        return pickupVfx
    end
    local t = self.transform:Find("vfx_interact")
    return t and t.gameObject or nil
end

local function PlayPickupVfx(vfxRoot)
    if vfxRoot == nil then
        return
    end

    vfxRoot:SetActive(true)
    local psType = typeof(CS.UnityEngine.ParticleSystem)
    local systems = vfxRoot:GetComponentsInChildren(psType, true)
    if systems ~= nil then
        for i = 0, systems.Length - 1 do
            local ps = systems[i]
            ps:Clear(true)
            ps:Play(true)
        end
    end
end

local function ResetPickupVfx(vfxRoot)
    if vfxRoot == nil then
        return
    end
    local psType = typeof(CS.UnityEngine.ParticleSystem)
    local stopMode = CS.UnityEngine.ParticleSystemStopBehavior.StopEmittingAndClear
    local systems = vfxRoot:GetComponentsInChildren(psType, true)
    if systems ~= nil then
        for i = 0, systems.Length - 1 do
            systems[i]:Stop(true, stopMode)
        end
    end
    vfxRoot:SetActive(true)
end

local function HidePickup(hideVfx)
    local vis = ResolveVisualRoot()
    if vis then
        vis:SetActive(false)
    end
    local col = self.gameObject:GetComponent(typeof(CS.UnityEngine.Collider))
    if col then
        col.enabled = false
    end
    if hideVfx then
        local vfx = ResolvePickupVfx()
        if vfx then
            vfx:SetActive(false)
        end
    end
end

local function ShowPickup()
    local vis = ResolveVisualRoot()
    if vis then
        vis:SetActive(true)
    end
    local col = self.gameObject:GetComponent(typeof(CS.UnityEngine.Collider))
    if col then
        col.enabled = true
    end
    ResetPickupVfx(ResolvePickupVfx())
end

local function ApplyVisibility()
    local ngOk = not requiresNGPlus or GetGlobalBool("NGPlus")
    local available = ngOk and not IsPicked()
    if available then
        ShowPickup()
    else
        HidePickup(true)
    end
end

function TryPickup()
    if IsPicked() then
        return
    end
    if requiresNGPlus and not GetGlobalBool("NGPlus") then
        return
    end

    local add = amount or 1
    local getFunc = _G["GetGlobalVar"]
    local setFunc = _G["SetGlobalVar"]
    if not getFunc or not setFunc then
        print("[CheesePickup] SetGlobalVar 未就绪")
        return
    end

    local current = tonumber(getFunc("CheeseCount")) or 0
    setFunc("CheeseCount", current + add, "int")
    SetPickedState(true)

    if _G["OnCheeseCountChanged"] then
        _G["OnCheeseCountChanged"]()
    end
    if _G["MouseBrother_RefreshDerivedFlags"] then
        _G["MouseBrother_RefreshDerivedFlags"]()
    end

    print(string.format("[CheesePickup] %s +%d => CheeseCount=%d",
        GetPickupId(), add, current + add))

    PlayPickupVfx(ResolvePickupVfx())
    HidePickup(false)
end

function OnPlayerTriggerEnter(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil or actor.isLocal ~= true then
        return
    end
    _G["PlayAudio"]("audio_cheese")
    TryPickup()
end

local function RegisterRefresher()
    _G._CheesePickupRefreshers[self.gameObject] = ApplyVisibility
end

local function UnregisterRefresher()
    if _G._CheesePickupRefreshers then
        _G._CheesePickupRefreshers[self.gameObject] = nil
    end
end

local function RegisterPickup()
    local id = GetPickupId()
    _G._CheesePickupRegistry[id] = {
        amount = amount or 1,
        requiresNGPlus = requiresNGPlus == true,
    }
end

local function UnregisterPickup()
    if _G._CheesePickupRegistry then
        _G._CheesePickupRegistry[GetPickupId()] = nil
    end
end

function Start()
    RegisterPickup()
    RegisterRefresher()
    ApplyVisibility()
    if _G["MouseBrother_RefreshDerivedFlags"] then
        _G["MouseBrother_RefreshDerivedFlags"]()
    end
end

function OnDestroy()
    UnregisterPickup()
    UnregisterRefresher()
end

if _G["CheesePickup_Refresh"] == nil then
    _G["CheesePickup_Refresh"] = function(go)
        local fn = _G._CheesePickupRefreshers and _G._CheesePickupRefreshers[go]
        if fn then
            fn()
        end
    end
end
