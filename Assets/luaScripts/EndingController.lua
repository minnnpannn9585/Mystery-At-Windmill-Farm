-- E20 漫画收束 · Notebook/Ending（prefab 内默认 inactive）
-- 点窗：立刻全黑 + preEnding oneshot + 停农场 BGM
-- pre 播完：第一张图 fadeIn + endingLoop
-- 末页后：淡出图（黑幕保持）→ ResetPosition/NGPlus/Terminal → 黑幕渐隐 → 恢复 BGM

---@var panels :UnityEngine.GameObject[]
---@var clickArea :UnityEngine.UI.Button
---@var fadeDuration :float = 1.0
---@var hideOnEnding :UnityEngine.GameObject[] -- 进入 Ending 时关闭的左侧 HUD（笔记本按钮、奶酪等，Inspector 拖入）
---@end

local phase = "idle"
local fadeInfo = nil
local currentPanelIndex = 0
local finalized = false
local bgLocked = false
local bgImage = nil
local advanceBound = false
local crossfadeFrom = nil
local crossfadeTo = nil
local fadeInTarget = nil
local fadeOutPanel = nil
local preEndingRemain = 0
local hiddenHudStates = nil -- { { go, wasActive }, ... }

local PRE_ENDING_FALLBACK = 2.0

-- forward decls（互相调用）
local OnFadeComplete
local HoldBlackAndTeleport
local StartFadeOutBg
local BeginFirstPanel

local function RegisterGlobal()
    if _G["EndingController_Start"] then return end
    _G["EndingController_Start"] = function()
        EndingController_Start()
    end
end

local function SmoothStep(t)
    if t <= 0 then return 0 end
    if t >= 1 then return 1 end
    return t * t * (3 - 2 * t)
end

local function GetBgImage()
    if not bgImage then
        bgImage = self.gameObject:GetComponent(typeof(CS.UnityEngine.UI.Image))
    end
    return bgImage
end

local function SetBgAlpha(alpha)
    if bgLocked and alpha < 1 then return end
    local img = GetBgImage()
    if not img then return end
    local c = img.color
    img.color = CS.UnityEngine.Color(c.r, c.g, c.b, alpha)
end

local function LockBg()
    bgLocked = true
    SetBgAlpha(1)
end

local function SetVisualAlpha(go, alpha)
    if not go then return end
    local img = go:GetComponent(typeof(CS.UnityEngine.UI.Image))
    if img then
        local c = img.color
        img.color = CS.UnityEngine.Color(c.r, c.g, c.b, alpha)
        return
    end
    local txt = go:GetComponent(typeof(CS.UnityEngine.UI.Text))
    if txt then
        local c = txt.color
        txt.color = CS.UnityEngine.Color(c.r, c.g, c.b, alpha)
    end
end

local function ClearLegacyCanvasGroup(go)
    if not go then return end
    local cg = go:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
    if cg then
        CS.UnityEngine.Object.Destroy(cg)
    end
end

local function DeactivateGo(go)
    if not go then return end
    ClearLegacyCanvasGroup(go)
    SetVisualAlpha(go, 0)
    go:SetActive(false)
end

local function GetPanelCount()
    if not panels then return 0 end
    return panels.Length
end

local function HideAllPanels()
    if not panels then return end
    for i = 0, panels.Length - 1 do
        DeactivateGo(panels[i])
    end
end

local function SetClickEnabled(enabled)
    if clickArea then
        clickArea.interactable = enabled
    end
end

local function SetRootRaycastEnabled(enabled)
    local img = GetBgImage()
    if img then
        img.raycastTarget = enabled
    end
end

local function DisableButtonColorTransition(btn)
    if not btn then return end
    btn.transition = CS.UnityEngine.UI.Selectable.Transition.None
end

local function DisableConflictingComponents()
    local rootCg = self.gameObject:GetComponent(typeof(CS.UnityEngine.CanvasGroup))
    if rootCg then
        rootCg.alpha = 1
        rootCg.blocksRaycasts = false
    end
    local anim = self.gameObject:GetComponent(typeof(CS.UnityEngine.Animator))
    if anim then
        anim.enabled = false
    end
end

local function InitializeVisuals()
    bgLocked = false
    DisableConflictingComponents()
    SetBgAlpha(0)
    HideAllPanels()
    SetClickEnabled(false)
end

local function EnsureEndingHidden()
    InitializeVisuals()
    SetClickEnabled(false)
    SetRootRaycastEnabled(false)
    self.gameObject:SetActive(false)
end

local function HideHudForEnding()
    hiddenHudStates = {}
    if not hideOnEnding then
        return
    end
    for i = 0, hideOnEnding.Length - 1 do
        local go = hideOnEnding[i]
        if go then
            table.insert(hiddenHudStates, { go = go, wasActive = go.activeSelf })
            go:SetActive(false)
        end
    end
end

local function RestoreHudAfterEnding()
    if not hiddenHudStates then
        return
    end
    for _, info in ipairs(hiddenHudStates) do
        if info.go then
            info.go:SetActive(info.wasActive)
        end
    end
    hiddenHudStates = nil
end

local function ApplyTeleportAndFlags()
    print("[EndingController] 漫画收束完成，上报 Terminal")
    if DouyinApplication and DouyinApplication.isSimulator then
        print("[EndingController] 模拟器跳过 Terminal")
    else
        CS.DouyinTaskService.SendEvent(CS.DouyinTaskEvent.Terminal)
    end

    if _G["SetGlobalVar"] then
        _G["SetGlobalVar"]("NGPlus", true, "bool")
        print("[EndingController] NGPlus = true")
    end

    if _G["ResetPosition"] then
        _G["ResetPosition"]()
        print("[EndingController] 调用 ResetPosition")
    end

    if DouyinUIService.SetNativeUIVisible then
        DouyinUIService.SetNativeUIVisible(true)
    end
end

local function FinishEndingCleanup()
    if finalized then return end
    finalized = true
    phase = "done"
    SetClickEnabled(false)
    SetRootRaycastEnabled(false)

    if _G["StopBGM"] then
        _G["StopBGM"]()
    end
    if _G["PlayBGM"] then
        _G["PlayBGM"]()
    end

    RestoreHudAfterEnding()
    self.gameObject:SetActive(false)
end

StartFadeOutBg = function()
    phase = "fadeOutBg"
    bgLocked = false
    SetClickEnabled(false)
    SetBgAlpha(1)
    fadeInfo = { kind = "fadeOutBg", elapsed = 0, onComplete = OnFadeComplete }
end

HoldBlackAndTeleport = function()
    phase = "holdBlack"
    fadeInfo = nil
    LockBg()
    ApplyTeleportAndFlags()
    StartFadeOutBg()
end

OnFadeComplete = function()
    if phase == "fadeBg" then
        LockBg()
        -- 黑幕渐入完成；若 preEnding 还在播则继续等，否则出首图
        if preEndingRemain > 0 then
            phase = "waitPreEnding"
        else
            BeginFirstPanel()
        end
        return
    end

    if phase == "fadeIn" then
        if fadeInTarget then
            SetVisualAlpha(fadeInTarget, 1)
            fadeInTarget = nil
        end
        if GetPanelCount() == 0 then
            HoldBlackAndTeleport()
        else
            phase = "waitClick"
            SetClickEnabled(true)
        end
        return
    end

    if phase == "crossfade" then
        if crossfadeFrom then
            DeactivateGo(crossfadeFrom)
        end
        if crossfadeTo then
            SetVisualAlpha(crossfadeTo, 1)
        end
        crossfadeFrom = nil
        crossfadeTo = nil
        phase = "waitClick"
        SetClickEnabled(true)
        return
    end

    if phase == "fadeOutPanel" then
        if fadeOutPanel then
            DeactivateGo(fadeOutPanel)
            fadeOutPanel = nil
        end
        HoldBlackAndTeleport()
        return
    end

    if phase == "fadeOutBg" then
        SetBgAlpha(0)
        FinishEndingCleanup()
        return
    end
end

BeginFirstPanel = function()
    LockBg()
    if _G["PlayMusic"] then
        _G["PlayMusic"]("audio_endingLoop")
    end

    currentPanelIndex = 1
    local go = panels and panels.Length > 0 and panels[0] or nil
    if go then
        phase = "fadeIn"
        fadeInTarget = go
        go:SetActive(true)
        SetVisualAlpha(go, 0)
        fadeInfo = { kind = "in", elapsed = 0, onComplete = OnFadeComplete }
        print("[EndingController] preEnding 结束，首图 + endingLoop")
    else
        HoldBlackAndTeleport()
    end
end

local function StartFadeOutPanel(panelGo)
    phase = "fadeOutPanel"
    fadeOutPanel = panelGo
    -- 黑幕保持锁定全黑，只淡出末页图
    LockBg()
    SetClickEnabled(false)
    fadeInfo = { kind = "outPanel", elapsed = 0, onComplete = OnFadeComplete }
end

local function StartCrossfade(fromGo, toGo)
    phase = "crossfade"
    crossfadeFrom = fromGo
    crossfadeTo = toGo
    SetClickEnabled(false)
    if toGo then
        toGo:SetActive(true)
        SetVisualAlpha(toGo, 0)
    end
    if fromGo then
        SetVisualAlpha(fromGo, 1)
    end
    fadeInfo = {
        kind = "crossfade",
        elapsed = 0,
        onComplete = OnFadeComplete
    }
end

local function OnAdvanceClick()
    if phase ~= "waitClick" then return end

    local prevGo = nil
    if panels and currentPanelIndex >= 1 and currentPanelIndex <= panels.Length then
        prevGo = panels[currentPanelIndex - 1]
    end

    currentPanelIndex = currentPanelIndex + 1
    if currentPanelIndex <= GetPanelCount() then
        StartCrossfade(prevGo, panels[currentPanelIndex - 1])
    else
        StartFadeOutPanel(prevGo)
    end
end

local function BindClickArea()
    if advanceBound then return end
    advanceBound = true

    if clickArea then
        DisableButtonColorTransition(clickArea)
        clickArea.onClick:AddListener(OnAdvanceClick)
        return
    end

    local rootGo = self.gameObject
    local btn = rootGo:GetComponent(typeof(CS.UnityEngine.UI.Button))
    if not btn then
        btn = rootGo:AddComponent(typeof(CS.UnityEngine.UI.Button))
    end
    DisableButtonColorTransition(btn)
    btn.onClick:AddListener(OnAdvanceClick)
    clickArea = btn
end

function EndingController_Start()
    if phase ~= "idle" and phase ~= "done" then
        print("[EndingController] 演出进行中，忽略重复启动")
        return
    end

    finalized = false
    currentPanelIndex = 0
    fadeInfo = nil
    fadeInTarget = nil
    fadeOutPanel = nil
    crossfadeFrom = nil
    crossfadeTo = nil
    preEndingRemain = 0

    -- 必须在 SetActive(true) 之前离开 idle：
    -- 激活时 Unity 会立刻跑 Start()，若仍是 idle 会 EnsureEndingHidden 把 Ending 关掉
    phase = "fadeBg"

    BindClickArea()
    DisableConflictingComponents()
    HideAllPanels()
    SetClickEnabled(false)
    HideHudForEnding()

    bgLocked = false
    SetRootRaycastEnabled(true)

    if _G["StopBGM"] then
        _G["StopBGM"]()
    end
    if _G["PlayAudio"] then
        _G["PlayAudio"]("audio_preEnding")
    end

    local len = 0
    if _G["GetAudioClipLength"] then
        len = _G["GetAudioClipLength"]("audio_preEnding") or 0
    end
    if len <= 0 then
        len = PRE_ENDING_FALLBACK
    end
    preEndingRemain = len

    self.gameObject:SetActive(true)
    SetBgAlpha(0)
    fadeInfo = { kind = "bg", elapsed = 0, onComplete = OnFadeComplete }

    print("[EndingController] 开始漫画收束：黑幕渐入 + preEnding " .. tostring(len) .. "s")
end

function Start()
    RegisterGlobal()
    BindClickArea()
    -- 仅冷启动时隐藏；演出已开始时绝不可关掉
    if phase == "idle" then
        EnsureEndingHidden()
    end
end

function Update()
    local dt = CS.UnityEngine.Time.deltaTime

    -- preEnding 与黑幕渐入并行倒计时
    if (phase == "fadeBg" or phase == "waitPreEnding") and preEndingRemain > 0 then
        preEndingRemain = preEndingRemain - dt
        if preEndingRemain < 0 then
            preEndingRemain = 0
        end
    end

    if phase == "waitPreEnding" then
        if preEndingRemain <= 0 then
            BeginFirstPanel()
        end
        return
    end

    if not fadeInfo then return end

    local duration = fadeDuration or 1.0
    if duration <= 0 then duration = 1.0 end

    fadeInfo.elapsed = fadeInfo.elapsed + dt
    local progress = fadeInfo.elapsed / duration
    if progress > 1 then progress = 1 end
    local eased = SmoothStep(progress)

    if fadeInfo.kind == "bg" then
        SetBgAlpha(eased)
    elseif fadeInfo.kind == "in" then
        SetVisualAlpha(fadeInTarget, eased)
    elseif fadeInfo.kind == "crossfade" then
        if crossfadeFrom then
            SetVisualAlpha(crossfadeFrom, 1 - eased)
        end
        if crossfadeTo then
            SetVisualAlpha(crossfadeTo, eased)
        end
    elseif fadeInfo.kind == "outPanel" then
        if fadeOutPanel then
            SetVisualAlpha(fadeOutPanel, 1 - eased)
        end
    elseif fadeInfo.kind == "fadeOutBg" then
        -- 收束：黑幕渐隐露出场景
        SetBgAlpha(1 - eased)
    end

    if progress >= 1 then
        local cb = fadeInfo.onComplete
        fadeInfo = nil
        if cb then
            cb()
        end
    end
end
