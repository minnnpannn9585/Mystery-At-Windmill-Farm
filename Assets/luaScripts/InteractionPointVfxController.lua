-- 交互点首次检视粒子：场景内静态挂载，运行时仅显隐（会话级）
---@var pointId :string
---@var targetVfx :UnityEngine.GameObject
---@end

local function EnsureState()
    if _G._InteractionPointVfxState == nil then
        _G._InteractionPointVfxState = {}
    end
    if _G._InteractionPointVfxDiscoverers == nil then
        _G._InteractionPointVfxDiscoverers = {}
    end
end

local function GetPointId()
    if pointId and pointId ~= "" then
        return pointId
    end
    return self.gameObject.name
end

local function ResolveVfx()
    if targetVfx then
        return targetVfx
    end
    local yellow = self.transform:Find("VFX_InteractionPoint")
    if yellow then
        return yellow.gameObject
    end
    local pink = self.transform:Find("VFX_InteractionPoint_Pink")
    if pink then
        return pink.gameObject
    end
    return nil
end

local function SetVfxVisible(visible)
    local vfxGo = ResolveVfx()
    if vfxGo == nil then
        return
    end
    vfxGo:SetActive(visible)
    if not visible then
        return
    end
    local psType = typeof(CS.UnityEngine.ParticleSystem)
    local systems = vfxGo:GetComponentsInChildren(psType, true)
    if systems ~= nil then
        for i = 0, systems.Length - 1 do
            local ps = systems[i]
            ps:Clear(true)
            ps:Play(true)
        end
    end
end

function Discover()
    EnsureState()
    local id = GetPointId()
    _G._InteractionPointVfxState[id] = true
    SetVfxVisible(false)
end

function Start()
    EnsureState()
    local id = GetPointId()
    _G._InteractionPointVfxDiscoverers[id] = Discover
    local discovered = _G._InteractionPointVfxState[id] == true
    SetVfxVisible(not discovered)
end

--- 供 ClueTrigger / DialogueTrigger / E06 等在点击时调用（幂等）
local function DiscoverFromGo(go)
    if go == nil then
        return
    end
    EnsureState()
    local id = go.name
    local fn = _G._InteractionPointVfxDiscoverers[id]
    if fn then
        fn()
        return
    end
    -- 控制器尚未 Start 时的兜底：按子节点名直接关闭
    if _G._InteractionPointVfxState[id] == true then
        return
    end
    local t = go.transform
    local yellow = t:Find("VFX_InteractionPoint")
    local pink = t:Find("VFX_InteractionPoint_Pink")
    local vfx = (yellow and yellow.gameObject) or (pink and pink.gameObject)
    if vfx then
        vfx:SetActive(false)
        _G._InteractionPointVfxState[id] = true
    end
end

_G.InteractionPointVfx_DiscoverFrom = DiscoverFromGo