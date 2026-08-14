-- 游戏开始后按子节点空 Transform 生成奶酪拾取 prefab
---@var cheesePrefab :UnityEngine.GameObject
---@end

local PICKUP_CHILD_NAME = "Pickup"

local function FindMarkerPickup(marker)
    local t = marker:Find(PICKUP_CHILD_NAME)
    return t and t.gameObject or nil
end

local function IsMarkerAvailable(markerName)
    if _G._CheesePickupState and _G._CheesePickupState[markerName] == true then
        return false
    end
    return true
end

function Start()
    local markerRoot = self.transform

    local function EnsureMarkerPickup(marker)
        if cheesePrefab == nil then
            return
        end

        local existing = FindMarkerPickup(marker)
        if existing then
            if _G["CheesePickup_Refresh"] then
                _G["CheesePickup_Refresh"](existing)
            end
            return
        end

        if not IsMarkerAvailable(marker.name) then
            return
        end

        local go = UnityEngine.GameObject.Instantiate(cheesePrefab, marker)
        go.name = PICKUP_CHILD_NAME
        go.transform.localPosition = CS.UnityEngine.Vector3.zero
        go.transform.localRotation = CS.UnityEngine.Quaternion.identity
        go.transform.localScale = CS.UnityEngine.Vector3.one
    end

    local function SpawnAll()
        if cheesePrefab == nil then
            print("[CheeseSpawner] cheesePrefab 未绑定")
            return
        end

        for i = 0, markerRoot.childCount - 1 do
            local marker = markerRoot:GetChild(i)
            EnsureMarkerPickup(marker)
        end
    end

    _G["CheeseSpawner_Respawn"] = SpawnAll
    SpawnAll()
end
