---@var moveBtn :UnityEngine.UI.Button      -- 移动按钮
---@var targetObject :UnityEngine.GameObject -- 目标物体（在Inspector中拖入）

function Start()
    _G["ResetPosition"] = OnMoveBtnClick
    if moveBtn then
        moveBtn.onClick:AddListener(OnMoveBtnClick)
    end
end

-- 按钮点击事件：将玩家移动到目标物体的位置，并设置相同的旋转
function OnMoveBtnClick()
    -- 1. 检查目标物体是否存在
    if not targetObject then
        print("❌ 未设置目标物体，请在Inspector中拖入")
        return
    end

    -- 2. 获取本地玩家
    local actor = CS.DouyinActorService.GetLocalActor()
    if not actor then
        print("❌ 未找到本地玩家")
        return
    end

    -- 3. 获取目标物体的位置和旋转
    local targetPos = targetObject.transform.position
    local targetRot = targetObject.transform.rotation

    -- 4. 移动玩家并设置旋转
    actor.position = targetPos
    actor.rotation = targetRot -- 直接复制旋转

    print(string.format("✅ 玩家已移动到 (%.2f, %.2f, %.2f)，旋转已同步",
        targetPos.x, targetPos.y, targetPos.z))
end
