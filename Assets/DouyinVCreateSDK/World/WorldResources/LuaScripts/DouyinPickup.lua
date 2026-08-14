---@require(DouyinObjectSync)
---@var InteractionType :InteractionType
---@var InteractionRange :number = 1.5
---@var InteractionArea :UnityEngine.Collider
---@var InteractionMode :Interaction3DType
---@var HandButton :DouyinButton
---@var RightLocation :UnityEngine.Transform
---@var AllowDrop :boolean = true
---@var AllowTheft :boolean
---@var DropDestroy :boolean =true
---@var DestroyTime :float=5
---@var MainButtonType :MainInteractButtonType
---@var IsShowMainButton :bool = false
---@var MainButton :DouyinButton
---@var MainJoyStick :DouyinJoyStick
---@var IsShowFirstSubButton : bool = false
---@var FirstSubButton :DouyinButton
---@end

local customMainButton = nil
local throwButton = nil
local customMainJoystick = nil
local lastPlayer = nil
local currentPlayer = nil
local currentPlayerGo = nil
local currentPlayerAnimator = nil
local currentPlayerBone = nil
local currentHandType = nil
local prevParent = nil
local rigidbody = nil
local holdHandsButton = nil
local stopHoldHandsButton = nil
local isKinematic = false
local isInteractable = false
local timer = 0
local isTimer = false
local interactorButton = nil
local LeftLocation = nil

function Awake()
    local allTrigger = self.gameObject:GetComponentsInChildren(typeof(CS.UnityEngine.Collider))
    for i = 0, allTrigger.Length - 1 do
        if allTrigger[i].isTrigger == true then
            if allTrigger[i] ~= InteractionArea then
                UnityEngine.Object.Destroy(allTrigger[i])
            end
        end
    end
    self.gameObject:SetLayer(CS.DouyinLayerDefine.PropsLayer)

    rigidbody = self.transform:GetComponent(typeof(CS.UnityEngine.Rigidbody))
    if rigidbody ~= nil then
        isKinematic = rigidbody.isKinematic
    end

    if InteractionArea == nil then
        InteractionType = CS.InteractionType.Range
    end
    if InteractionRange <= 0 then
        InteractionRange = 1.5
    end
    if InteractionType == CS.InteractionType.Range then
        if InteractionArea == nil then
            InteractionArea = self.gameObject:AddComponent(typeof(CS.UnityEngine.SphereCollider))
            InteractionArea.center = CS.UnityEngine.Vector3.zero
            local scale = self.gameObject.transform.localScale
            local maxScale = math.max(scale.x, scale.y, scale.z)
            if maxScale > 0 then
                InteractionArea.radius = InteractionRange / maxScale
            else
                InteractionArea.radius = InteractionRange
            end
        end
    end
    if InteractionArea ~= nil then
        InteractionArea.isTrigger = true
    end

    customMainButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.CustomMain)
    throwButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.Throw)
    customMainJoystick = CS.DouyinUIService.GetJoyStickControl(CS.UIType.CustomMain)

    holdHandsButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.HoldHands)
    stopHoldHandsButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.StopHoldHands)
    SetDefaultIcon(HandButton, CS.IconType.Pickup)
    SetDefaultIcon(MainButton, CS.IconType.Default)
    SetDefaultIcon(FirstSubButton, CS.IconType.Default)
    SetDefaultJoyStickIcon(MainJoyStick)
    HandButton.ButtonText = true
    if not AllowDrop then
        DropDestroy = false
    end
end

function SetDefaultIcon(btn, IconType)
    if btn == nil then
        return
    end

    local defaultIcon = CS.DouyinUIService.GetDefaultIcon(IconType)
    local defaultBackground = CS.DouyinUIService.GetDefaultIcon(CS.IconType.Background)
    local spriteState = btn.SpriteState

    if spriteState.normalImage == nil then
        spriteState.normalImage = defaultIcon
    end

    if spriteState.normalBackgroundImage == nil then
        spriteState.normalBackgroundImage = defaultBackground
    end

    btn.SpriteState = spriteState
end

function SetDefaultJoyStickIcon(joyStick)
    local interactiveImage = CS.DouyinUIService.GetDefaultIcon(CS.IconType.Default)
    if joyStick.backgroundImage == nil then
        joyStick.backgroundImage = interactiveImage
    end
    if joyStick.frontgroundImage == nil then
        joyStick.frontgroundImage = interactiveImage
    end
end

function Pickup(handType)
    local localActor = CS.DouyinActorService.GetLocalActor()
    if localActor == nil then
        return
    end

    if localActor:GetPickupInHand(handType) ~= nil then
        CS.DouyinUtility.Toast("手中已有物品")
        return
    end

    if handType == CS.HandType.Left then
        if LeftLocation ~= nil then
            localActor:Pickup(self.gameObject, handType, LeftLocation:LocalMatrix())
        else
            localActor:Pickup(self.gameObject, handType, CS.UnityEngine.Matrix4x4.identity)
        end
    elseif handType == CS.HandType.Right then
        if RightLocation ~= nil then
            localActor:Pickup(self.gameObject, handType, RightLocation:LocalMatrix())
        else
            localActor:Pickup(self.gameObject, handType, CS.UnityEngine.Matrix4x4.identity)
        end
    end
end

function ShowJoystickControl(joystick, descriptor)
    if joystick == nil or descriptor == nil then
        return
    end
    if joystick.gameObject ~= nil then
        joystick.gameObject:SetActive(true)
    end
    if joystick.background ~= nil then
        joystick.background.gameObject:SetActive(true)
        joystick.background.sprite = descriptor.backgroundImage
    end
    if joystick.frontground ~= nil then
        joystick.frontground.gameObject:SetActive(true)
        joystick.frontground.sprite = descriptor.frontgroundImage
    end
end

function HideJoystickControl(joystick)
    if joystick == nil then
        return
    end
    if joystick.gameObject ~= nil then
        joystick.gameObject:SetActive(false)
    end
    if joystick.background ~= nil then
        joystick.background.gameObject:SetActive(false)
    end
    if joystick.frontground ~= nil then
        joystick.frontground.gameObject:SetActive(false)
    end
end

function ApplyButtonConfig(btn, btnConfig)
    if btn == nil or btnConfig == nil then
        return
    end

    btn.transition = CS.UnityEngine.UI.Selectable.Transition.SpriteSwap
    btn.image.sprite = btnConfig.SpriteState.normalImage
    local spriteState = btn.spriteState
    spriteState.highlightedSprite = btnConfig.SpriteState.normalImage
    spriteState.pressedSprite = btnConfig.SpriteState.normalImage
    spriteState.selectedSprite = btnConfig.SpriteState.normalImage
    btn.spriteState = spriteState

    local backgroundTrnas = btn.transform:Find("Background")
    if backgroundTrnas ~= nil then
        local backgroundImage = backgroundTrnas:GetComponent(typeof(CS.UnityEngine.UI.Image))
        if backgroundImage ~= nil then
            local backgroundSprite
            if btnConfig.SpriteState.normalBackgroundImage then
                backgroundSprite = btnConfig.SpriteState.normalBackgroundImage
            end
            if backgroundSprite then
                backgroundImage.sprite = backgroundSprite
            end
        end
    end

    local txt = btn:GetComponentInChildren(typeof(CS.UnityEngine.UI.Text), true)
    if txt ~= nil then
        if btnConfig.ButtonText == true then
            txt.gameObject:SetActive(true)
            txt.text = btnConfig.Text
            txt.color = btnConfig.TextColor
        else
            txt.gameObject:SetActive(false)
        end
    end
end

function ShowInteractionButton(btn)
    if btn == nil or btn.gameObject == nil then
        return
    end
    btn.gameObject:SetActive(true)
end

function HideInteractionButton(btn)
    if btn == nil or btn.gameObject == nil then
        return
    end
    btn.gameObject:SetActive(false)
end

function EnableInteraction()
    if self.enabled == false then
        print("DouyinPickup is disabled")
        return
    end
    self:EnableInteraction()
end

function DisableInteraction()
    self:DisableInteraction()
end

function OnPlayerTriggerEnter(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil then
        return
    end
    if actor.isBindMode == false then
        return
    end
    isInteractable = true

    local enableInteract = false
    if AllowTheft and currentPlayerGo ~= actor.gameObject then
        enableInteract = true
    elseif not AllowTheft and currentPlayerGo == nil then
        enableInteract = true
    end

    if enableInteract and actor.isMasterMode then
        EnableInteraction()
    end
end

function OnPlayerTriggerExit(douyinPlayer)
    if douyinPlayer == nil then
        return
    end
    local actor = douyinPlayer:GetActor()
    if actor == nil then
        return
    end
    if actor.isBindMode == false then
        return
    end
    isInteractable = false
    DisableInteraction()
end

function OnPlayerJoined(player)
    if player.isLocal == false then
        return
    end
end

function OnPlayerLeft(player)
    if player == nil or player.isLocal == false then
        return
    end
    isInteractable = false
    DisableInteraction()
end

function OnDisable()
    if isInteractable == true then
        isInteractable = false
        DisableInteraction()
    end
end

function OnFocus()
    local localActor = DouyinActorService.GetLocalActor()
    if localActor ~= nil then
        local lastItem = localActor:GetPickupInHand(CS.HandType.All)
        if lastItem ~= nil then
            return
        end
    end

    interactorButton = self:AddInteractorButton()
    ApplyButtonConfig(interactorButton, HandButton)
end

function OnLostFocus()
    self:RemoveInteractorButton(interactorButton)
    interactorButton = nil
end

function OnOwnershipRequest(playerId)
    return true
end

function OnPickup(actor, handType, pickUpPoint)
    print("DouyinPickup.OnPickup", actor.actorID, handType, pickUpPoint)
    timer = 0
    isTimer = false
    if actor ~= nil then
        DisablePhysical()
        lastPlayer = currentPlayer
        currentPlayer = actor
        currentHandType = handType
        currentPlayerGo = currentPlayer.gameObject
        currentPlayerAnimator = currentPlayerGo:GetComponentInChildren(typeof(CS.UnityEngine.Animator))
        if currentPlayerAnimator ~= nil then
            currentPlayerBone = nil
            if handType == CS.HandType.Left then
                currentPlayerBone = currentPlayerAnimator:GetBoneTransform(CS.UnityEngine.HumanBodyBones.LeftHand)
            elseif handType == CS.HandType.Right then
                currentPlayerBone = currentPlayerAnimator:GetBoneTransform(CS.UnityEngine.HumanBodyBones.RightHand)
            end
            if currentPlayerBone ~= nil then
                if lastPlayer == nil then
                    prevParent = self.transform.parent
                end
                self.transform:SetParent(currentPlayerBone)
            end
            UpdateTransform(handType, pickUpPoint.inverse)
        end
        currentPlayer:StopFly()
    end
    DisableInteraction()
    OnPickupImp(handType)
end

function OnDrop(actor, handType)
    print("DouyinPickup.OnDrop", actor.actorID, handType)
    if actor.gameObject ~= nil and actor == currentPlayer then
        isTimer = true
        timer = 0
        OnDropImp(handType)
        self.transform:SetParent(prevParent)
        prevParent = nil
        EnablePhysical()
        lastPlayer = nil
        currentPlayer = nil
        currentPlayerGo = nil
        currentPlayerAnimator = nil
    end
end

function UpdateTransform(HandType, pickupMatrix)
    local palmPosition = CS.UnityEngine.Vector3.zero
    local palmRotation = CS.UnityEngine.Quaternion.identity

    if HandType == CS.HandType.Left then
        palmPosition, palmRotation = currentPlayer:CalculatePalmTransform(true)
    elseif HandType == CS.HandType.Right then
        palmPosition, palmRotation = currentPlayer:CalculatePalmTransform(false)
    end

    local palmWorldMatrix = CS.UnityEngine.Matrix4x4.TRS(palmPosition, palmRotation, CS.UnityEngine.Vector3.one)
    local palmMatrix = palmWorldMatrix * pickupMatrix
    self.transform.position = palmMatrix:GetPosition()
    self.transform.rotation = palmMatrix.rotation
end

function EnablePhysical()
    if rigidbody ~= nil and isKinematic ~= nil then
        rigidbody.isKinematic = isKinematic
    end
    self.gameObject:SetLayer(CS.DouyinLayerDefine.PropsLayer)
end

function DisablePhysical()
    if rigidbody ~= nil then
        rigidbody.isKinematic = true
    end
end

function OnPickupImp(handType)
    if not currentPlayer.isBindMode then
        return
    end
    if MainButtonType == CS.MainInteractButtonType.Button then
        throwButton.gameObject:SetActive(AllowDrop)
        if IsShowMainButton == true then
            ShowInteractionButton(customMainButton)
            ApplyButtonConfig(customMainButton, MainButton)
        end
    elseif MainButtonType == CS.MainInteractButtonType.Stick then
        throwButton.gameObject:SetActive(AllowDrop)
        ShowJoystickControl(customMainJoystick, MainJoyStick)
    end

    if IsShowFirstSubButton == true then
        local customSubButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.CustomSub)
        if customSubButton ~= nil then
            ShowInteractionButton(customSubButton)
            ApplyButtonConfig(customSubButton, FirstSubButton)
        end
    end

    holdHandsButton.gameObject:SetActive(false)
    stopHoldHandsButton.gameObject:SetActive(false)

    if currentPlayer ~= nil and currentPlayer.isLocal == true and DropDestroy == true then
        self.douyinObject:EnableDestroyWhenActorLeft(currentPlayer.actorID)
    end
end

function OnDropImp(hand)
    if currentPlayer ~= nil and currentPlayer.isBindMode == false then
        return
    end
    if MainButtonType == CS.MainInteractButtonType.Button then
        throwButton.gameObject:SetActive(false)
        HideInteractionButton(customMainButton)
    elseif MainButtonType == CS.MainInteractButtonType.Stick then
        throwButton.gameObject:SetActive(false)
        HideJoystickControl(customMainJoystick)
    end

    local customSubButton = CS.DouyinUIService.GetInteractionButton(CS.UIType.CustomSub)
    if customSubButton ~= nil then
        HideInteractionButton(customSubButton)
    end

    local localActor = CS.DouyinActorService.GetLocalActor()
    if localActor ~= nil then
        if not localActor:IsFlying() then
            holdHandsButton.gameObject:SetActive(true)
        end
    end
end

function OnUIPointerClick(uiType)
    if uiType == CS.UIType.Throw then
        if currentPlayer ~= nil then
            currentPlayer:Drop(self.gameObject)
        end
    end
    CallAdditveButtonActions(uiType)
end

function CallAdditveButtonActions(uiType)
    local ButtonActions = nil
    if uiType == CS.UIType.CustomMain then
        ButtonActions = MainButton.ButtonActions
    elseif uiType == CS.UIType.CustomSub then
        ButtonActions = FirstSubButton.ButtonActions
    end
    if ButtonActions and ButtonActions.Length > 0 then
        for i = 0, ButtonActions.Length - 1 do
            local item = ButtonActions[i]
            if item.Data then
                local pfn = item.Data.script[item.methodName]
                if pfn then
                    pfn()
                end
            end
        end
    end
end

function OnInteractorButtonClick()
    if currentPlayer == nil or currentPlayer.isLocal == false then
        Pickup(CS.HandType.Right)
    end
end

function OnActorOperationChanged(actor)
    if actor == nil then
        return
    end

    if actor.isBindMode == false or not isInteractable then
        return
    end

    if actor.isMasterMode == true then
        if currentPlayer == nil then
            EnableInteraction()
        elseif currentPlayer == actor then
            OnPickupImp(currentHandType)
        end
    else
        DisableInteraction()
    end
end

function Update()
    if self:HasOwnership() then
        if isTimer and DropDestroy then
            timer = timer + CS.UnityEngine.Time.deltaTime
            if timer > DestroyTime then
                DouyinObjectService.NetDestroy(self.gameObject, true)
            end
        end
    end
end

function GetInteractorButton()
    return interactorButton
end

function OnNetSpawned()
    if self:HasOwnership() and AllowTheft then
        self.douyinObject:SetProperty('AllowTheft', tostring(AllowTheft))
    end
end
