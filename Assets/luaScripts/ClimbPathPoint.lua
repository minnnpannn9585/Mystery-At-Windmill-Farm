-- 攀爬路径点：解锁后依次点亮 targetVfx，玩家触达后关闭当前并打开下一个
---@var pathId :string = "barn"
---@var pointIndex :int = 0
---@var unlockVarName :string = "E06_LadderPlaced"
---@var targetVfx :UnityEngine.GameObject
---@end

local function EnsureState()
    if _G._ClimbPathState == nil then
        _G._ClimbPathState = {}
    end
end

local function GetGlobalBool(name)
    if not name or name == "" then
        return false
    end
    local getFunc = _G["GetGlobalVar"] or _G["GetGlobalVariable"]
    if getFunc then
        return getFunc(name) == true
    end
    return false
end

local function ResolveVfx()
    if targetVfx then
        return targetVfx
    end
    local t = self.transform:Find("targetVfx")
    return t and t.gameObject or nil
end

local function SetVfxVisible(vfxGo, visible)
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
    local anim = vfxGo:GetComponent(typeof(CS.UnityEngine.Animator))
    if anim then
        anim:Rebind()
        anim:Update(0)
    end
end

local function GetPathState()
    EnsureState()
    return _G._ClimbPathState[pathId]
end

local function RegisterPoint()
    EnsureState()
    local state = _G._ClimbPathState
    if state[pathId] == nil then
        state[pathId] = {
            unlockVar = unlockVarName,
            points = {},
            unlocked = false,
            activeIndex = -1,
        }
    end

    local path = state[pathId]
    local idx = pointIndex or 0
    path.points[idx] = {
        vfx = ResolveVfx(),
        go = self.gameObject,
    }
    SetVfxVisible(path.points[idx].vfx, false)

    if path.unlocked then
        if path.activeIndex == idx then
            SetVfxVisible(path.points[idx].vfx, true)
        end
    elseif GetGlobalBool(path.unlockVar) then
        ClimbPath_Refresh(pathId)
    end
end

function ClimbPath_Refresh(pathKey)
    local path = _G._ClimbPathState and _G._ClimbPathState[pathKey]
    if path == nil or path.unlocked then
        return
    end
    if not GetGlobalBool(path.unlockVar) then
        return
    end

    path.unlocked = true
    path.activeIndex = 0
    local first = path.points[0]
    if first then
        SetVfxVisible(first.vfx, true)
        print(string.format("[ClimbPath] %s unlocked, show point 0", pathKey))
    end
end

function ClimbPath_Advance(pathKey, fromIndex)
    local path = _G._ClimbPathState and _G._ClimbPathState[pathKey]
    if path == nil or not path.unlocked then
        return
    end
    if path.activeIndex ~= fromIndex then
        return
    end

    local current = path.points[fromIndex]
    if current then
        SetVfxVisible(current.vfx, false)
    end

    local nextIndex = fromIndex + 1
    local nextPoint = path.points[nextIndex]
    if nextPoint then
        path.activeIndex = nextIndex
        SetVfxVisible(nextPoint.vfx, true)
        print(string.format("[ClimbPath] %s reached %d, show point %d", pathKey, fromIndex, nextIndex))
    else
        path.activeIndex = -1
        print(string.format("[ClimbPath] %s reached %d, path complete", pathKey, fromIndex))
    end
end

function Start()
    RegisterPoint()
    ClimbPath_Refresh(pathId)
end

function Update()
    ClimbPath_Refresh(pathId)
end

function OnPlayerTriggerEnter(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil or actor.isLocal ~= true then
        return
    end
    ClimbPath_Advance(pathId, pointIndex or 0)
end

_G.ClimbPath_Refresh = ClimbPath_Refresh
_G.ClimbPath_Advance = ClimbPath_Advance
