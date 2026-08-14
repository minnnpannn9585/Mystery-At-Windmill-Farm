--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.UI
UnityEngine.UI = {}

---@enum UnityEngine.UI.CanvasUpdate
local CanvasUpdate_Enum = {
    Prelayout = 0,
    Layout = 1,
    PostLayout = 2,
    PreRender = 3,
    LatePreRender = 4,
    MaxUpdateValue = 5,
}
UnityEngine.UI.CanvasUpdate = CanvasUpdate_Enum

---@enum UnityEngine.UI.GraphicRaycaster.BlockingObjects
local BlockingObjects_Enum = {
    None = 0,
    TwoD = 1,
    ThreeD = 2,
    All = 3,
}
UnityEngine.UI.BlockingObjects = BlockingObjects_Enum

---@enum UnityEngine.UI.Image.Type
local Type_Enum = {
    Simple = 0,
    Sliced = 1,
    Tiled = 2,
    Filled = 3,
}
UnityEngine.UI.Type = Type_Enum

---@enum UnityEngine.UI.Image.FillMethod
local FillMethod_Enum = {
    Horizontal = 0,
    Vertical = 1,
    Radial90 = 2,
    Radial180 = 3,
    Radial360 = 4,
}
UnityEngine.UI.FillMethod = FillMethod_Enum

---@enum UnityEngine.UI.Image.OriginHorizontal
local OriginHorizontal_Enum = {
    Left = 0,
    Right = 1,
}
UnityEngine.UI.OriginHorizontal = OriginHorizontal_Enum

---@enum UnityEngine.UI.Image.OriginVertical
local OriginVertical_Enum = {
    Bottom = 0,
    Top = 1,
}
UnityEngine.UI.OriginVertical = OriginVertical_Enum

---@enum UnityEngine.UI.Image.Origin90
local Origin90_Enum = {
    BottomLeft = 0,
    TopLeft = 1,
    TopRight = 2,
    BottomRight = 3,
}
UnityEngine.UI.Origin90 = Origin90_Enum

---@enum UnityEngine.UI.Image.Origin180
local Origin180_Enum = {
    Bottom = 0,
    Left = 1,
    Top = 2,
    Right = 3,
}
UnityEngine.UI.Origin180 = Origin180_Enum

---@enum UnityEngine.UI.Image.Origin360
local Origin360_Enum = {
    Bottom = 0,
    Right = 1,
    Top = 2,
    Left = 3,
}
UnityEngine.UI.Origin360 = Origin360_Enum

---@enum UnityEngine.UI.InputField.ContentType
local ContentType_Enum = {
    Standard = 0,
    Autocorrected = 1,
    IntegerNumber = 2,
    DecimalNumber = 3,
    Alphanumeric = 4,
    Name = 5,
    EmailAddress = 6,
    Password = 7,
    Pin = 8,
    Custom = 9,
}
UnityEngine.UI.ContentType = ContentType_Enum

---@enum UnityEngine.UI.InputField.InputType
local InputType_Enum = {
    Standard = 0,
    AutoCorrect = 1,
    Password = 2,
}
UnityEngine.UI.InputType = InputType_Enum

---@enum UnityEngine.UI.InputField.CharacterValidation
local CharacterValidation_Enum = {
    None = 0,
    Integer = 1,
    Decimal = 2,
    Alphanumeric = 3,
    Name = 4,
    EmailAddress = 5,
}
UnityEngine.UI.CharacterValidation = CharacterValidation_Enum

---@enum UnityEngine.UI.InputField.LineType
local LineType_Enum = {
    SingleLine = 0,
    MultiLineSubmit = 1,
    MultiLineNewline = 2,
}
UnityEngine.UI.LineType = LineType_Enum

---@enum UnityEngine.UI.InputField.EditState
local EditState_Enum = {
    Continue = 0,
    Finish = 1,
}
UnityEngine.UI.EditState = EditState_Enum

---@enum UnityEngine.UI.AspectRatioFitter.AspectMode
local AspectMode_Enum = {
    None = 0,
    WidthControlsHeight = 1,
    HeightControlsWidth = 2,
    FitInParent = 3,
    EnvelopeParent = 4,
}
UnityEngine.UI.AspectMode = AspectMode_Enum

---@enum UnityEngine.UI.CanvasScaler.ScaleMode
local ScaleMode_Enum = {
    ConstantPixelSize = 0,
    ScaleWithScreenSize = 1,
    ConstantPhysicalSize = 2,
}
UnityEngine.UI.ScaleMode = ScaleMode_Enum

---@enum UnityEngine.UI.CanvasScaler.ScreenMatchMode
local ScreenMatchMode_Enum = {
    MatchWidthOrHeight = 0,
    Expand = 1,
    Shrink = 2,
}
UnityEngine.UI.ScreenMatchMode = ScreenMatchMode_Enum

---@enum UnityEngine.UI.CanvasScaler.Unit
local Unit_Enum = {
    Centimeters = 0,
    Millimeters = 1,
    Inches = 2,
    Points = 3,
    Picas = 4,
}
UnityEngine.UI.Unit = Unit_Enum

---@enum UnityEngine.UI.ContentSizeFitter.FitMode
local FitMode_Enum = {
    Unconstrained = 0,
    MinSize = 1,
    PreferredSize = 2,
}
UnityEngine.UI.FitMode = FitMode_Enum

---@enum UnityEngine.UI.GridLayoutGroup.Corner
local Corner_Enum = {
    UpperLeft = 0,
    UpperRight = 1,
    LowerLeft = 2,
    LowerRight = 3,
}
UnityEngine.UI.Corner = Corner_Enum

---@enum UnityEngine.UI.GridLayoutGroup.Axis
local Axis_Enum = {
    Horizontal = 0,
    Vertical = 1,
}
UnityEngine.UI.Axis = Axis_Enum

---@enum UnityEngine.UI.GridLayoutGroup.Constraint
local Constraint_Enum = {
    Flexible = 0,
    FixedColumnCount = 1,
    FixedRowCount = 2,
}
UnityEngine.UI.Constraint = Constraint_Enum

---@enum UnityEngine.UI.Navigation.Mode
local Mode_Enum = {
    None = 0,
    Horizontal = 1,
    Vertical = 2,
    Automatic = 3,
    Explicit = 4,
}
UnityEngine.UI.Mode = Mode_Enum

---@enum UnityEngine.UI.Scrollbar.Direction
local Direction_Enum = {
    LeftToRight = 0,
    RightToLeft = 1,
    BottomToTop = 2,
    TopToBottom = 3,
}
UnityEngine.UI.Direction = Direction_Enum

---@enum UnityEngine.UI.Scrollbar.Axis
local Axis_Enum = {
    Horizontal = 0,
    Vertical = 1,
}
UnityEngine.UI.Axis = Axis_Enum

---@enum UnityEngine.UI.ScrollRect.MovementType
local MovementType_Enum = {
    Unrestricted = 0,
    Elastic = 1,
    Clamped = 2,
}
UnityEngine.UI.MovementType = MovementType_Enum

---@enum UnityEngine.UI.ScrollRect.ScrollbarVisibility
local ScrollbarVisibility_Enum = {
    Permanent = 0,
    AutoHide = 1,
    AutoHideAndExpandViewport = 2,
}
UnityEngine.UI.ScrollbarVisibility = ScrollbarVisibility_Enum

---@enum UnityEngine.UI.Selectable.Transition
local Transition_Enum = {
    None = 0,
    ColorTint = 1,
    SpriteSwap = 2,
    Animation = 3,
}
UnityEngine.UI.Transition = Transition_Enum

---@enum UnityEngine.UI.Selectable.SelectionState
local SelectionState_Enum = {
    Normal = 0,
    Highlighted = 1,
    Pressed = 2,
    Selected = 3,
    Disabled = 4,
}
UnityEngine.UI.SelectionState = SelectionState_Enum

---@enum UnityEngine.UI.Slider.Direction
local Direction_Enum = {
    LeftToRight = 0,
    RightToLeft = 1,
    BottomToTop = 2,
    TopToBottom = 3,
}
UnityEngine.UI.Direction = Direction_Enum

---@enum UnityEngine.UI.Slider.Axis
local Axis_Enum = {
    Horizontal = 0,
    Vertical = 1,
}
UnityEngine.UI.Axis = Axis_Enum

---@enum UnityEngine.UI.Toggle.ToggleTransition
local ToggleTransition_Enum = {
    None = 0,
    Fade = 1,
}
UnityEngine.UI.ToggleTransition = ToggleTransition_Enum

---@class UnityEngine.UI.AnimationTriggers
---@field normalTrigger string
---@field highlightedTrigger string
---@field pressedTrigger string
---@field selectedTrigger string
---@field disabledTrigger string
local AnimationTriggers_Impl = {}

---@class Static.UnityEngine.UI.AnimationTriggers
---@overload fun(): UnityEngine.UI.AnimationTriggers (Constructor)
local AnimationTriggers_Static = {}


---@type Static.UnityEngine.UI.AnimationTriggers
UnityEngine.UI.AnimationTriggers = AnimationTriggers_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Button : UnityEngine.UI.Selectable, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler, UnityEngine.EventSystems.ISubmitHandler, UnityEngine.EventSystems.IPointerClickHandler
---@field onClick UnityEngine.UI.Button.ButtonClickedEvent
local Button_Impl = {}

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Button_Impl:OnPointerClick(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Button_Impl:OnSubmit(eventData) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.CanvasUpdateRegistry
local CanvasUpdateRegistry_Impl = {}

---@class Static.UnityEngine.UI.CanvasUpdateRegistry
---@field instance UnityEngine.UI.CanvasUpdateRegistry
local CanvasUpdateRegistry_Static = {}

---@param element UnityEngine.UI.ICanvasElement 
function CanvasUpdateRegistry_Static.RegisterCanvasElementForLayoutRebuild(element) end

---@param element UnityEngine.UI.ICanvasElement 
---@return boolean ret 
function CanvasUpdateRegistry_Static.TryRegisterCanvasElementForLayoutRebuild(element) end

---@param element UnityEngine.UI.ICanvasElement 
function CanvasUpdateRegistry_Static.RegisterCanvasElementForGraphicRebuild(element) end

---@param element UnityEngine.UI.ICanvasElement 
---@return boolean ret 
function CanvasUpdateRegistry_Static.TryRegisterCanvasElementForGraphicRebuild(element) end

---@param element UnityEngine.UI.ICanvasElement 
function CanvasUpdateRegistry_Static.UnRegisterCanvasElementForRebuild(element) end

---@param element UnityEngine.UI.ICanvasElement 
function CanvasUpdateRegistry_Static.DisableCanvasElementForRebuild(element) end

---@return boolean ret 
function CanvasUpdateRegistry_Static.IsRebuildingLayout() end

---@return boolean ret 
function CanvasUpdateRegistry_Static.IsRebuildingGraphics() end


---@type Static.UnityEngine.UI.CanvasUpdateRegistry
UnityEngine.UI.CanvasUpdateRegistry = CanvasUpdateRegistry_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ColorBlock : System.IEquatable<UnityEngine.UI.ColorBlock>
---@field normalColor UnityEngine.Color
---@field highlightedColor UnityEngine.Color
---@field pressedColor UnityEngine.Color
---@field selectedColor UnityEngine.Color
---@field disabledColor UnityEngine.Color
---@field colorMultiplier number
---@field fadeDuration number
local ColorBlock_Impl = {}

---@param obj System.Object 
---@return boolean ret 
function ColorBlock_Impl:Equals(obj) end

---@param other UnityEngine.UI.ColorBlock 
---@return boolean ret 
function ColorBlock_Impl:Equals(other) end

---@return integer ret 
function ColorBlock_Impl:GetHashCode() end

---@class Static.UnityEngine.UI.ColorBlock
---@field defaultColorBlock UnityEngine.UI.ColorBlock
---@overload fun(): UnityEngine.UI.ColorBlock (Constructor)
local ColorBlock_Static = {}


---@type Static.UnityEngine.UI.ColorBlock
UnityEngine.UI.ColorBlock = ColorBlock_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ClipperRegistry
local ClipperRegistry_Impl = {}

function ClipperRegistry_Impl:Cull() end

---@class Static.UnityEngine.UI.ClipperRegistry
---@field instance UnityEngine.UI.ClipperRegistry
local ClipperRegistry_Static = {}

---@param c UnityEngine.UI.IClipper 
function ClipperRegistry_Static.Register(c) end

---@param c UnityEngine.UI.IClipper 
function ClipperRegistry_Static.Unregister(c) end

---@param c UnityEngine.UI.IClipper 
function ClipperRegistry_Static.Disable(c) end


---@type Static.UnityEngine.UI.ClipperRegistry
UnityEngine.UI.ClipperRegistry = ClipperRegistry_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Clipping
local Clipping_Impl = {}

---@class Static.UnityEngine.UI.Clipping
local Clipping_Static = {}

---@param rectMaskParents System.Collections.Generic.List 
---@return UnityEngine.Rect ret 
---@return boolean validRect (Out) 
function Clipping_Static.FindCullAndClipWorldRect(rectMaskParents) end


---@type Static.UnityEngine.UI.Clipping
UnityEngine.UI.Clipping = Clipping_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.RectangularVertexClipper
local RectangularVertexClipper_Impl = {}

---@param t UnityEngine.RectTransform 
---@param c UnityEngine.Canvas 
---@return UnityEngine.Rect ret 
function RectangularVertexClipper_Impl:GetCanvasRect(t, c) end

---@class Static.UnityEngine.UI.RectangularVertexClipper
---@overload fun(): UnityEngine.UI.RectangularVertexClipper (Constructor)
local RectangularVertexClipper_Static = {}


---@type Static.UnityEngine.UI.RectangularVertexClipper
UnityEngine.UI.RectangularVertexClipper = RectangularVertexClipper_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.DefaultControls
local DefaultControls_Impl = {}

---@class Static.UnityEngine.UI.DefaultControls
---@field factory UnityEngine.UI.DefaultControls.IFactoryControls
local DefaultControls_Static = {}

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreatePanel(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateButton(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateText(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateImage(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateRawImage(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateSlider(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateScrollbar(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateToggle(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateInputField(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateDropdown(resources) end

---@param resources UnityEngine.UI.DefaultControls.Resources 
---@return UnityEngine.GameObject ret 
function DefaultControls_Static.CreateScrollView(resources) end


---@type Static.UnityEngine.UI.DefaultControls
UnityEngine.UI.DefaultControls = DefaultControls_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Dropdown : UnityEngine.UI.Selectable, UnityEngine.EventSystems.ICancelHandler, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler, UnityEngine.EventSystems.ISubmitHandler, UnityEngine.EventSystems.IPointerClickHandler
---@field template UnityEngine.RectTransform
---@field captionText UnityEngine.UI.Text
---@field captionImage UnityEngine.UI.Image
---@field itemText UnityEngine.UI.Text
---@field itemImage UnityEngine.UI.Image
---@field options System.Collections.Generic.List
---@field onValueChanged UnityEngine.UI.Dropdown.DropdownEvent
---@field alphaFadeSpeed number
---@field value integer
local Dropdown_Impl = {}

---@param input integer 
function Dropdown_Impl:SetValueWithoutNotify(input) end

function Dropdown_Impl:RefreshShownValue() end

---@param options System.Collections.Generic.List 
function Dropdown_Impl:AddOptions(options) end

---@param options System.Collections.Generic.List 
function Dropdown_Impl:AddOptions(options) end

---@param options System.Collections.Generic.List 
function Dropdown_Impl:AddOptions(options) end

function Dropdown_Impl:ClearOptions() end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Dropdown_Impl:OnPointerClick(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Dropdown_Impl:OnSubmit(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Dropdown_Impl:OnCancel(eventData) end

function Dropdown_Impl:Show() end

function Dropdown_Impl:Hide() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.FontData : UnityEngine.ISerializationCallbackReceiver
---@field font UnityEngine.Font
---@field fontSize integer
---@field fontStyle UnityEngine.FontStyle
---@field bestFit boolean
---@field minSize integer
---@field maxSize integer
---@field alignment UnityEngine.TextAnchor
---@field alignByGeometry boolean
---@field richText boolean
---@field horizontalOverflow UnityEngine.HorizontalWrapMode
---@field verticalOverflow UnityEngine.VerticalWrapMode
---@field lineSpacing number
local FontData_Impl = {}

---@class Static.UnityEngine.UI.FontData
---@field defaultFontData UnityEngine.UI.FontData
---@overload fun(): UnityEngine.UI.FontData (Constructor)
local FontData_Static = {}


---@type Static.UnityEngine.UI.FontData
UnityEngine.UI.FontData = FontData_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.FontUpdateTracker
local FontUpdateTracker_Impl = {}

---@class Static.UnityEngine.UI.FontUpdateTracker
local FontUpdateTracker_Static = {}

---@param t UnityEngine.UI.Text 
function FontUpdateTracker_Static.TrackText(t) end

---@param t UnityEngine.UI.Text 
function FontUpdateTracker_Static.UntrackText(t) end


---@type Static.UnityEngine.UI.FontUpdateTracker
UnityEngine.UI.FontUpdateTracker = FontUpdateTracker_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Graphic : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ICanvasElement
---@field color UnityEngine.Color
---@field raycastTarget boolean
---@field raycastPadding UnityEngine.Vector4
---@field depth integer
---@field rectTransform UnityEngine.RectTransform
---@field canvas UnityEngine.Canvas
---@field canvasRenderer UnityEngine.CanvasRenderer
---@field defaultMaterial UnityEngine.Material
---@field material UnityEngine.Material
---@field materialForRendering UnityEngine.Material
---@field mainTexture UnityEngine.Texture
local Graphic_Impl = {}

function Graphic_Impl:SetAllDirty() end

function Graphic_Impl:SetLayoutDirty() end

function Graphic_Impl:SetVerticesDirty() end

function Graphic_Impl:SetMaterialDirty() end

function Graphic_Impl:SetRaycastDirty() end

function Graphic_Impl:OnCullingChanged() end

---@param update UnityEngine.UI.CanvasUpdate 
function Graphic_Impl:Rebuild(update) end

function Graphic_Impl:LayoutComplete() end

function Graphic_Impl:GraphicUpdateComplete() end

function Graphic_Impl:OnRebuildRequested() end

function Graphic_Impl:SetNativeSize() end

---@param sp UnityEngine.Vector2 
---@param eventCamera UnityEngine.Camera 
---@return boolean ret 
function Graphic_Impl:Raycast(sp, eventCamera) end

---@param point UnityEngine.Vector2 
---@return UnityEngine.Vector2 ret 
function Graphic_Impl:PixelAdjustPoint(point) end

---@return UnityEngine.Rect ret 
function Graphic_Impl:GetPixelAdjustedRect() end

---@param targetColor UnityEngine.Color 
---@param duration number 
---@param ignoreTimeScale boolean 
---@param useAlpha boolean 
function Graphic_Impl:CrossFadeColor(targetColor, duration, ignoreTimeScale, useAlpha) end

---@param targetColor UnityEngine.Color 
---@param duration number 
---@param ignoreTimeScale boolean 
---@param useAlpha boolean 
---@param useRGB boolean 
function Graphic_Impl:CrossFadeColor(targetColor, duration, ignoreTimeScale, useAlpha, useRGB) end

---@param alpha number 
---@param duration number 
---@param ignoreTimeScale boolean 
function Graphic_Impl:CrossFadeAlpha(alpha, duration, ignoreTimeScale) end

---@param action fun() 
function Graphic_Impl:RegisterDirtyLayoutCallback(action) end

---@param action fun() 
function Graphic_Impl:UnregisterDirtyLayoutCallback(action) end

---@param action fun() 
function Graphic_Impl:RegisterDirtyVerticesCallback(action) end

---@param action fun() 
function Graphic_Impl:UnregisterDirtyVerticesCallback(action) end

---@param action fun() 
function Graphic_Impl:RegisterDirtyMaterialCallback(action) end

---@param action fun() 
function Graphic_Impl:UnregisterDirtyMaterialCallback(action) end

---@class Static.UnityEngine.UI.Graphic
---@field defaultGraphicMaterial UnityEngine.Material
local Graphic_Static = {}


---@type Static.UnityEngine.UI.Graphic
UnityEngine.UI.Graphic = Graphic_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.GraphicRaycaster : UnityEngine.EventSystems.BaseRaycaster
---@field sortOrderPriority integer
---@field renderOrderPriority integer
---@field ignoreReversedGraphics boolean
---@field blockingObjects UnityEngine.UI.GraphicRaycaster.BlockingObjects
---@field blockingMask UnityEngine.LayerMask
---@field eventCamera UnityEngine.Camera
local GraphicRaycaster_Impl = {}

---@param eventData UnityEngine.EventSystems.PointerEventData 
---@param resultAppendList System.Collections.Generic.List 
function GraphicRaycaster_Impl:Raycast(eventData, resultAppendList) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.GraphicRegistry
local GraphicRegistry_Impl = {}

---@class Static.UnityEngine.UI.GraphicRegistry
---@field instance UnityEngine.UI.GraphicRegistry
local GraphicRegistry_Static = {}

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.RegisterGraphicForCanvas(c, graphic) end

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.RegisterRaycastGraphicForCanvas(c, graphic) end

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.UnregisterGraphicForCanvas(c, graphic) end

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.UnregisterRaycastGraphicForCanvas(c, graphic) end

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.DisableGraphicForCanvas(c, graphic) end

---@param c UnityEngine.Canvas 
---@param graphic UnityEngine.UI.Graphic 
function GraphicRegistry_Static.DisableRaycastGraphicForCanvas(c, graphic) end

---@param canvas UnityEngine.Canvas 
---@return System.Collections.Generic.IList ret 
function GraphicRegistry_Static.GetGraphicsForCanvas(canvas) end

---@param canvas UnityEngine.Canvas 
---@return System.Collections.Generic.IList ret 
function GraphicRegistry_Static.GetRaycastableGraphicsForCanvas(canvas) end


---@type Static.UnityEngine.UI.GraphicRegistry
UnityEngine.UI.GraphicRegistry = GraphicRegistry_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Image : UnityEngine.UI.MaskableGraphic, UnityEngine.UI.IMaterialModifier, UnityEngine.UI.IMaskable, UnityEngine.ICanvasRaycastFilter, UnityEngine.ISerializationCallbackReceiver, UnityEngine.UI.ICanvasElement, UnityEngine.UI.ILayoutElement, UnityEngine.UI.IClippable
---@field sprite UnityEngine.Sprite
---@field overrideSprite UnityEngine.Sprite
---@field type UnityEngine.UI.Image.Type
---@field preserveAspect boolean
---@field fillCenter boolean
---@field fillMethod UnityEngine.UI.Image.FillMethod
---@field fillAmount number
---@field fillClockwise boolean
---@field fillOrigin integer
---@field eventAlphaThreshold number
---@field alphaHitTestMinimumThreshold number
---@field useSpriteMesh boolean
---@field mainTexture UnityEngine.Texture
---@field hasBorder boolean
---@field pixelsPerUnitMultiplier number
---@field pixelsPerUnit number
---@field material UnityEngine.Material
---@field minWidth number
---@field preferredWidth number
---@field flexibleWidth number
---@field minHeight number
---@field preferredHeight number
---@field flexibleHeight number
---@field layoutPriority integer
local Image_Impl = {}

function Image_Impl:DisableSpriteOptimizations() end

function Image_Impl:OnBeforeSerialize() end

function Image_Impl:OnAfterDeserialize() end

function Image_Impl:SetNativeSize() end

function Image_Impl:CalculateLayoutInputHorizontal() end

function Image_Impl:CalculateLayoutInputVertical() end

---@param screenPoint UnityEngine.Vector2 
---@param eventCamera UnityEngine.Camera 
---@return boolean ret 
function Image_Impl:IsRaycastLocationValid(screenPoint, eventCamera) end

---@class Static.UnityEngine.UI.Image
---@field defaultETC1GraphicMaterial UnityEngine.Material
local Image_Static = {}


---@type Static.UnityEngine.UI.Image
UnityEngine.UI.Image = Image_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.InputField : UnityEngine.UI.Selectable, UnityEngine.EventSystems.IBeginDragHandler, UnityEngine.EventSystems.IDragHandler, UnityEngine.EventSystems.IEndDragHandler, UnityEngine.UI.ICanvasElement, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.IUpdateSelectedHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler, UnityEngine.UI.ILayoutElement, UnityEngine.EventSystems.ISubmitHandler, UnityEngine.EventSystems.IPointerClickHandler
---@field shouldHideMobileInput boolean
---@field shouldActivateOnSelect boolean
---@field text string
---@field isFocused boolean
---@field caretBlinkRate number
---@field caretWidth integer
---@field textComponent UnityEngine.UI.Text
---@field placeholder UnityEngine.UI.Graphic
---@field caretColor UnityEngine.Color
---@field customCaretColor boolean
---@field selectionColor UnityEngine.Color
---@field onEndEdit UnityEngine.UI.InputField.EndEditEvent
---@field onSubmit UnityEngine.UI.InputField.SubmitEvent
---@field onValueChange UnityEngine.UI.InputField.OnChangeEvent
---@field onValueChanged UnityEngine.UI.InputField.OnChangeEvent
---@field onValidateInput fun(text: string, charIndex: integer, addedChar: System.Char): System.Char
---@field characterLimit integer
---@field contentType UnityEngine.UI.InputField.ContentType
---@field lineType UnityEngine.UI.InputField.LineType
---@field inputType UnityEngine.UI.InputField.InputType
---@field touchScreenKeyboard UnityEngine.TouchScreenKeyboard
---@field keyboardType UnityEngine.TouchScreenKeyboardType
---@field characterValidation UnityEngine.UI.InputField.CharacterValidation
---@field readOnly boolean
---@field multiLine boolean
---@field asteriskChar System.Char
---@field wasCanceled boolean
---@field caretSelectPosition integer
---@field caretPosition integer
---@field selectionAnchorPosition integer
---@field selectionFocusPosition integer
---@field minWidth number
---@field preferredWidth number
---@field flexibleWidth number
---@field minHeight number
---@field preferredHeight number
---@field flexibleHeight number
---@field layoutPriority integer
local InputField_Impl = {}

---@param input string 
function InputField_Impl:SetTextWithoutNotify(input) end

---@param shift boolean 
function InputField_Impl:MoveTextEnd(shift) end

---@param shift boolean 
function InputField_Impl:MoveTextStart(shift) end

---@param screen UnityEngine.Vector2 
---@return UnityEngine.Vector2 ret 
function InputField_Impl:ScreenToLocal(screen) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function InputField_Impl:OnBeginDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function InputField_Impl:OnDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function InputField_Impl:OnEndDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function InputField_Impl:OnPointerDown(eventData) end

---@param e UnityEngine.Event 
function InputField_Impl:ProcessEvent(e) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function InputField_Impl:OnUpdateSelected(eventData) end

function InputField_Impl:ForceLabelUpdate() end

---@param update UnityEngine.UI.CanvasUpdate 
function InputField_Impl:Rebuild(update) end

function InputField_Impl:LayoutComplete() end

function InputField_Impl:GraphicUpdateComplete() end

function InputField_Impl:ActivateInputField() end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function InputField_Impl:OnSelect(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function InputField_Impl:OnPointerClick(eventData) end

function InputField_Impl:DeactivateInputField() end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function InputField_Impl:OnDeselect(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function InputField_Impl:OnSubmit(eventData) end

function InputField_Impl:CalculateLayoutInputHorizontal() end

function InputField_Impl:CalculateLayoutInputVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.AspectRatioFitter : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ILayoutSelfController, UnityEngine.UI.ILayoutController
---@field aspectMode UnityEngine.UI.AspectRatioFitter.AspectMode
---@field aspectRatio number
local AspectRatioFitter_Impl = {}

function AspectRatioFitter_Impl:SetLayoutHorizontal() end

function AspectRatioFitter_Impl:SetLayoutVertical() end

---@return boolean ret 
function AspectRatioFitter_Impl:IsComponentValidOnObject() end

---@return boolean ret 
function AspectRatioFitter_Impl:IsAspectModeValid() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.CanvasScaler : UnityEngine.EventSystems.UIBehaviour
---@field uiScaleMode UnityEngine.UI.CanvasScaler.ScaleMode
---@field referencePixelsPerUnit number
---@field scaleFactor number
---@field referenceResolution UnityEngine.Vector2
---@field screenMatchMode UnityEngine.UI.CanvasScaler.ScreenMatchMode
---@field matchWidthOrHeight number
---@field physicalUnit UnityEngine.UI.CanvasScaler.Unit
---@field fallbackScreenDPI number
---@field defaultSpriteDPI number
---@field dynamicPixelsPerUnit number
local CanvasScaler_Impl = {}

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ContentSizeFitter : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ILayoutSelfController, UnityEngine.UI.ILayoutController
---@field horizontalFit UnityEngine.UI.ContentSizeFitter.FitMode
---@field verticalFit UnityEngine.UI.ContentSizeFitter.FitMode
local ContentSizeFitter_Impl = {}

function ContentSizeFitter_Impl:SetLayoutHorizontal() end

function ContentSizeFitter_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.GridLayoutGroup : UnityEngine.UI.LayoutGroup, UnityEngine.UI.ILayoutGroup, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
---@field startCorner UnityEngine.UI.GridLayoutGroup.Corner
---@field startAxis UnityEngine.UI.GridLayoutGroup.Axis
---@field cellSize UnityEngine.Vector2
---@field spacing UnityEngine.Vector2
---@field constraint UnityEngine.UI.GridLayoutGroup.Constraint
---@field constraintCount integer
local GridLayoutGroup_Impl = {}

function GridLayoutGroup_Impl:CalculateLayoutInputHorizontal() end

function GridLayoutGroup_Impl:CalculateLayoutInputVertical() end

function GridLayoutGroup_Impl:SetLayoutHorizontal() end

function GridLayoutGroup_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.HorizontalLayoutGroup : UnityEngine.UI.HorizontalOrVerticalLayoutGroup, UnityEngine.UI.ILayoutGroup, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
local HorizontalLayoutGroup_Impl = {}

function HorizontalLayoutGroup_Impl:CalculateLayoutInputHorizontal() end

function HorizontalLayoutGroup_Impl:CalculateLayoutInputVertical() end

function HorizontalLayoutGroup_Impl:SetLayoutHorizontal() end

function HorizontalLayoutGroup_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.HorizontalOrVerticalLayoutGroup : UnityEngine.UI.LayoutGroup, UnityEngine.UI.ILayoutGroup, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
---@field spacing number
---@field childForceExpandWidth boolean
---@field childForceExpandHeight boolean
---@field childControlWidth boolean
---@field childControlHeight boolean
---@field childScaleWidth boolean
---@field childScaleHeight boolean
---@field reverseArrangement boolean
local HorizontalOrVerticalLayoutGroup_Impl = {}

--------------------------------------------------------------------------------

---@class UnityEngine.UI.LayoutElement : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ILayoutIgnorer, UnityEngine.UI.ILayoutElement
---@field ignoreLayout boolean
---@field minWidth number
---@field minHeight number
---@field preferredWidth number
---@field preferredHeight number
---@field flexibleWidth number
---@field flexibleHeight number
---@field layoutPriority integer
local LayoutElement_Impl = {}

function LayoutElement_Impl:CalculateLayoutInputHorizontal() end

function LayoutElement_Impl:CalculateLayoutInputVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.LayoutGroup : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ILayoutGroup, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
---@field padding UnityEngine.RectOffset
---@field childAlignment UnityEngine.TextAnchor
---@field minWidth number
---@field preferredWidth number
---@field flexibleWidth number
---@field minHeight number
---@field preferredHeight number
---@field flexibleHeight number
---@field layoutPriority integer
local LayoutGroup_Impl = {}

function LayoutGroup_Impl:CalculateLayoutInputHorizontal() end

function LayoutGroup_Impl:CalculateLayoutInputVertical() end

function LayoutGroup_Impl:SetLayoutHorizontal() end

function LayoutGroup_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.LayoutRebuilder : UnityEngine.UI.ICanvasElement
---@field transform UnityEngine.Transform
local LayoutRebuilder_Impl = {}

---@return boolean ret 
function LayoutRebuilder_Impl:IsDestroyed() end

---@param executing UnityEngine.UI.CanvasUpdate 
function LayoutRebuilder_Impl:Rebuild(executing) end

function LayoutRebuilder_Impl:LayoutComplete() end

function LayoutRebuilder_Impl:GraphicUpdateComplete() end

---@return integer ret 
function LayoutRebuilder_Impl:GetHashCode() end

---@param obj System.Object 
---@return boolean ret 
function LayoutRebuilder_Impl:Equals(obj) end

---@return string ret 
function LayoutRebuilder_Impl:ToString() end

---@class Static.UnityEngine.UI.LayoutRebuilder
---@overload fun(): UnityEngine.UI.LayoutRebuilder (Constructor)
local LayoutRebuilder_Static = {}

---@param layoutRoot UnityEngine.RectTransform 
function LayoutRebuilder_Static.ForceRebuildLayoutImmediate(layoutRoot) end

---@param rect UnityEngine.RectTransform 
function LayoutRebuilder_Static.MarkLayoutForRebuild(rect) end


---@type Static.UnityEngine.UI.LayoutRebuilder
UnityEngine.UI.LayoutRebuilder = LayoutRebuilder_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.LayoutUtility
local LayoutUtility_Impl = {}

---@class Static.UnityEngine.UI.LayoutUtility
local LayoutUtility_Static = {}

---@param rect UnityEngine.RectTransform 
---@param axis integer 
---@return number ret 
function LayoutUtility_Static.GetMinSize(rect, axis) end

---@param rect UnityEngine.RectTransform 
---@param axis integer 
---@return number ret 
function LayoutUtility_Static.GetPreferredSize(rect, axis) end

---@param rect UnityEngine.RectTransform 
---@param axis integer 
---@return number ret 
function LayoutUtility_Static.GetFlexibleSize(rect, axis) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetMinWidth(rect) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetPreferredWidth(rect) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetFlexibleWidth(rect) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetMinHeight(rect) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetPreferredHeight(rect) end

---@param rect UnityEngine.RectTransform 
---@return number ret 
function LayoutUtility_Static.GetFlexibleHeight(rect) end

---@param rect UnityEngine.RectTransform 
---@param property System.Func 
---@param defaultValue number 
---@return number ret 
function LayoutUtility_Static.GetLayoutProperty(rect, property, defaultValue) end

---@param rect UnityEngine.RectTransform 
---@param property System.Func 
---@param defaultValue number 
---@return number ret 
---@return UnityEngine.UI.ILayoutElement source (Out) 
function LayoutUtility_Static.GetLayoutProperty(rect, property, defaultValue) end


---@type Static.UnityEngine.UI.LayoutUtility
UnityEngine.UI.LayoutUtility = LayoutUtility_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.VerticalLayoutGroup : UnityEngine.UI.HorizontalOrVerticalLayoutGroup, UnityEngine.UI.ILayoutGroup, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
local VerticalLayoutGroup_Impl = {}

function VerticalLayoutGroup_Impl:CalculateLayoutInputHorizontal() end

function VerticalLayoutGroup_Impl:CalculateLayoutInputVertical() end

function VerticalLayoutGroup_Impl:SetLayoutHorizontal() end

function VerticalLayoutGroup_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Mask : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.IMaterialModifier, UnityEngine.ICanvasRaycastFilter
---@field rectTransform UnityEngine.RectTransform
---@field showMaskGraphic boolean
---@field graphic UnityEngine.UI.Graphic
local Mask_Impl = {}

---@return boolean ret 
function Mask_Impl:MaskEnabled() end

function Mask_Impl:OnSiblingGraphicEnabledDisabled() end

---@param sp UnityEngine.Vector2 
---@param eventCamera UnityEngine.Camera 
---@return boolean ret 
function Mask_Impl:IsRaycastLocationValid(sp, eventCamera) end

---@param baseMaterial UnityEngine.Material 
---@return UnityEngine.Material ret 
function Mask_Impl:GetModifiedMaterial(baseMaterial) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.MaskableGraphic : UnityEngine.UI.Graphic, UnityEngine.UI.IMaterialModifier, UnityEngine.UI.IMaskable, UnityEngine.UI.ICanvasElement, UnityEngine.UI.IClippable
---@field onCullStateChanged UnityEngine.UI.MaskableGraphic.CullStateChangedEvent
---@field maskable boolean
---@field isMaskingGraphic boolean
local MaskableGraphic_Impl = {}

---@param baseMaterial UnityEngine.Material 
---@return UnityEngine.Material ret 
function MaskableGraphic_Impl:GetModifiedMaterial(baseMaterial) end

---@param clipRect UnityEngine.Rect 
---@param validRect boolean 
function MaskableGraphic_Impl:Cull(clipRect, validRect) end

---@param clipRect UnityEngine.Rect 
---@param validRect boolean 
function MaskableGraphic_Impl:SetClipRect(clipRect, validRect) end

---@param clipSoftness UnityEngine.Vector2 
function MaskableGraphic_Impl:SetClipSoftness(clipSoftness) end

function MaskableGraphic_Impl:ParentMaskStateChanged() end

function MaskableGraphic_Impl:RecalculateClipping() end

function MaskableGraphic_Impl:RecalculateMasking() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.MaskUtilities
local MaskUtilities_Impl = {}

---@class Static.UnityEngine.UI.MaskUtilities
---@overload fun(): UnityEngine.UI.MaskUtilities (Constructor)
local MaskUtilities_Static = {}

---@param mask UnityEngine.Component 
function MaskUtilities_Static.Notify2DMaskStateChanged(mask) end

---@param mask UnityEngine.Component 
function MaskUtilities_Static.NotifyStencilStateChanged(mask) end

---@param start UnityEngine.Transform 
---@return UnityEngine.Transform ret 
function MaskUtilities_Static.FindRootSortOverrideCanvas(start) end

---@param transform UnityEngine.Transform 
---@param stopAfter UnityEngine.Transform 
---@return integer ret 
function MaskUtilities_Static.GetStencilDepth(transform, stopAfter) end

---@param father UnityEngine.Transform 
---@param child UnityEngine.Transform 
---@return boolean ret 
function MaskUtilities_Static.IsDescendantOrSelf(father, child) end

---@param clippable UnityEngine.UI.IClippable 
---@return UnityEngine.UI.RectMask2D ret 
function MaskUtilities_Static.GetRectMaskForClippable(clippable) end

---@param clipper UnityEngine.UI.RectMask2D 
---@param masks System.Collections.Generic.List 
function MaskUtilities_Static.GetRectMasksForClip(clipper, masks) end


---@type Static.UnityEngine.UI.MaskUtilities
UnityEngine.UI.MaskUtilities = MaskUtilities_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Misc
local Misc_Impl = {}

---@class Static.UnityEngine.UI.Misc
local Misc_Static = {}

---@param obj UnityEngine.Object 
function Misc_Static.Destroy(obj) end

---@param obj UnityEngine.Object 
function Misc_Static.DestroyImmediate(obj) end


---@type Static.UnityEngine.UI.Misc
UnityEngine.UI.Misc = Misc_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.MultipleDisplayUtilities
local MultipleDisplayUtilities_Impl = {}

---@class Static.UnityEngine.UI.MultipleDisplayUtilities
local MultipleDisplayUtilities_Static = {}

---@param eventData UnityEngine.EventSystems.PointerEventData 
---@param position UnityEngine.Vector2 
---@return boolean ret 
---@return UnityEngine.Vector2 position (Ref) 
function MultipleDisplayUtilities_Static.GetRelativeMousePositionForDrag(eventData, position) end

---@param position UnityEngine.Vector2 
---@return UnityEngine.Vector3 ret 
function MultipleDisplayUtilities_Static.RelativeMouseAtScaled(position) end


---@type Static.UnityEngine.UI.MultipleDisplayUtilities
UnityEngine.UI.MultipleDisplayUtilities = MultipleDisplayUtilities_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Navigation : System.IEquatable<UnityEngine.UI.Navigation>
---@field mode UnityEngine.UI.Navigation.Mode
---@field wrapAround boolean
---@field selectOnUp UnityEngine.UI.Selectable
---@field selectOnDown UnityEngine.UI.Selectable
---@field selectOnLeft UnityEngine.UI.Selectable
---@field selectOnRight UnityEngine.UI.Selectable
local Navigation_Impl = {}

---@param other UnityEngine.UI.Navigation 
---@return boolean ret 
function Navigation_Impl:Equals(other) end

---@class Static.UnityEngine.UI.Navigation
---@field defaultNavigation UnityEngine.UI.Navigation
---@overload fun(): UnityEngine.UI.Navigation (Constructor)
local Navigation_Static = {}


---@type Static.UnityEngine.UI.Navigation
UnityEngine.UI.Navigation = Navigation_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.RawImage : UnityEngine.UI.MaskableGraphic, UnityEngine.UI.IMaterialModifier, UnityEngine.UI.IMaskable, UnityEngine.UI.ICanvasElement, UnityEngine.UI.IClippable
---@field mainTexture UnityEngine.Texture
---@field texture UnityEngine.Texture
---@field uvRect UnityEngine.Rect
local RawImage_Impl = {}

function RawImage_Impl:SetNativeSize() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.RectMask2D : UnityEngine.EventSystems.UIBehaviour, UnityEngine.ICanvasRaycastFilter, UnityEngine.UI.IClipper
---@field padding UnityEngine.Vector4
---@field softness UnityEngine.Vector2Int
---@field canvasRect UnityEngine.Rect
---@field rectTransform UnityEngine.RectTransform
local RectMask2D_Impl = {}

---@param sp UnityEngine.Vector2 
---@param eventCamera UnityEngine.Camera 
---@return boolean ret 
function RectMask2D_Impl:IsRaycastLocationValid(sp, eventCamera) end

function RectMask2D_Impl:PerformClipping() end

function RectMask2D_Impl:UpdateClipSoftness() end

---@param clippable UnityEngine.UI.IClippable 
function RectMask2D_Impl:AddClippable(clippable) end

---@param clippable UnityEngine.UI.IClippable 
function RectMask2D_Impl:RemoveClippable(clippable) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Scrollbar : UnityEngine.UI.Selectable, UnityEngine.EventSystems.IBeginDragHandler, UnityEngine.EventSystems.IInitializePotentialDragHandler, UnityEngine.EventSystems.IDragHandler, UnityEngine.UI.ICanvasElement, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler
---@field handleRect UnityEngine.RectTransform
---@field direction UnityEngine.UI.Scrollbar.Direction
---@field value number
---@field size number
---@field numberOfSteps integer
---@field onValueChanged UnityEngine.UI.Scrollbar.ScrollEvent
local Scrollbar_Impl = {}

---@param input number 
function Scrollbar_Impl:SetValueWithoutNotify(input) end

---@param executing UnityEngine.UI.CanvasUpdate 
function Scrollbar_Impl:Rebuild(executing) end

function Scrollbar_Impl:LayoutComplete() end

function Scrollbar_Impl:GraphicUpdateComplete() end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Scrollbar_Impl:OnBeginDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Scrollbar_Impl:OnDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Scrollbar_Impl:OnPointerDown(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Scrollbar_Impl:OnPointerUp(eventData) end

---@param eventData UnityEngine.EventSystems.AxisEventData 
function Scrollbar_Impl:OnMove(eventData) end

---@return UnityEngine.UI.Selectable ret 
function Scrollbar_Impl:FindSelectableOnLeft() end

---@return UnityEngine.UI.Selectable ret 
function Scrollbar_Impl:FindSelectableOnRight() end

---@return UnityEngine.UI.Selectable ret 
function Scrollbar_Impl:FindSelectableOnUp() end

---@return UnityEngine.UI.Selectable ret 
function Scrollbar_Impl:FindSelectableOnDown() end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Scrollbar_Impl:OnInitializePotentialDrag(eventData) end

---@param direction UnityEngine.UI.Scrollbar.Direction 
---@param includeRectLayouts boolean 
function Scrollbar_Impl:SetDirection(direction, includeRectLayouts) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ScrollRect : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.ILayoutGroup, UnityEngine.EventSystems.IBeginDragHandler, UnityEngine.EventSystems.IInitializePotentialDragHandler, UnityEngine.EventSystems.IDragHandler, UnityEngine.EventSystems.IEndDragHandler, UnityEngine.UI.ICanvasElement, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IScrollHandler, UnityEngine.UI.ILayoutElement, UnityEngine.UI.ILayoutController
---@field content UnityEngine.RectTransform
---@field horizontal boolean
---@field vertical boolean
---@field movementType UnityEngine.UI.ScrollRect.MovementType
---@field elasticity number
---@field inertia boolean
---@field decelerationRate number
---@field scrollSensitivity number
---@field viewport UnityEngine.RectTransform
---@field horizontalScrollbar UnityEngine.UI.Scrollbar
---@field verticalScrollbar UnityEngine.UI.Scrollbar
---@field horizontalScrollbarVisibility UnityEngine.UI.ScrollRect.ScrollbarVisibility
---@field verticalScrollbarVisibility UnityEngine.UI.ScrollRect.ScrollbarVisibility
---@field horizontalScrollbarSpacing number
---@field verticalScrollbarSpacing number
---@field onValueChanged UnityEngine.UI.ScrollRect.ScrollRectEvent
---@field velocity UnityEngine.Vector2
---@field normalizedPosition UnityEngine.Vector2
---@field horizontalNormalizedPosition number
---@field verticalNormalizedPosition number
---@field minWidth number
---@field preferredWidth number
---@field flexibleWidth number
---@field minHeight number
---@field preferredHeight number
---@field flexibleHeight number
---@field layoutPriority integer
local ScrollRect_Impl = {}

---@param executing UnityEngine.UI.CanvasUpdate 
function ScrollRect_Impl:Rebuild(executing) end

function ScrollRect_Impl:LayoutComplete() end

function ScrollRect_Impl:GraphicUpdateComplete() end

---@return boolean ret 
function ScrollRect_Impl:IsActive() end

function ScrollRect_Impl:StopMovement() end

---@param data UnityEngine.EventSystems.PointerEventData 
function ScrollRect_Impl:OnScroll(data) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function ScrollRect_Impl:OnInitializePotentialDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function ScrollRect_Impl:OnBeginDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function ScrollRect_Impl:OnEndDrag(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function ScrollRect_Impl:OnDrag(eventData) end

function ScrollRect_Impl:CalculateLayoutInputHorizontal() end

function ScrollRect_Impl:CalculateLayoutInputVertical() end

function ScrollRect_Impl:SetLayoutHorizontal() end

function ScrollRect_Impl:SetLayoutVertical() end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Selectable : UnityEngine.EventSystems.UIBehaviour, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler
---@field navigation UnityEngine.UI.Navigation
---@field transition UnityEngine.UI.Selectable.Transition
---@field colors UnityEngine.UI.ColorBlock
---@field spriteState UnityEngine.UI.SpriteState
---@field animationTriggers UnityEngine.UI.AnimationTriggers
---@field targetGraphic UnityEngine.UI.Graphic
---@field interactable boolean
---@field image UnityEngine.UI.Image
---@field animator UnityEngine.Animator
local Selectable_Impl = {}

---@return boolean ret 
function Selectable_Impl:IsInteractable() end

---@param dir UnityEngine.Vector3 
---@return UnityEngine.UI.Selectable ret 
function Selectable_Impl:FindSelectable(dir) end

---@return UnityEngine.UI.Selectable ret 
function Selectable_Impl:FindSelectableOnLeft() end

---@return UnityEngine.UI.Selectable ret 
function Selectable_Impl:FindSelectableOnRight() end

---@return UnityEngine.UI.Selectable ret 
function Selectable_Impl:FindSelectableOnUp() end

---@return UnityEngine.UI.Selectable ret 
function Selectable_Impl:FindSelectableOnDown() end

---@param eventData UnityEngine.EventSystems.AxisEventData 
function Selectable_Impl:OnMove(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Selectable_Impl:OnPointerDown(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Selectable_Impl:OnPointerUp(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Selectable_Impl:OnPointerEnter(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Selectable_Impl:OnPointerExit(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Selectable_Impl:OnSelect(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Selectable_Impl:OnDeselect(eventData) end

function Selectable_Impl:Select() end

---@class Static.UnityEngine.UI.Selectable
---@field allSelectablesArray UnityEngine.UI.Selectable[]
---@field allSelectableCount integer
---@field allSelectables System.Collections.Generic.List
local Selectable_Static = {}

---@param selectables UnityEngine.UI.Selectable[] 
---@return integer ret 
function Selectable_Static.AllSelectablesNoAlloc(selectables) end


---@type Static.UnityEngine.UI.Selectable
UnityEngine.UI.Selectable = Selectable_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.SetPropertyUtility
local SetPropertyUtility_Impl = {}

---@class Static.UnityEngine.UI.SetPropertyUtility
local SetPropertyUtility_Static = {}

---@param currentValue UnityEngine.Color 
---@param newValue UnityEngine.Color 
---@return boolean ret 
---@return UnityEngine.Color currentValue (Ref) 
function SetPropertyUtility_Static.SetColor(currentValue, newValue) end

---@generic T
---@param currentValue T 
---@param newValue T 
---@return boolean ret 
---@return T currentValue (Ref) 
function SetPropertyUtility_Static.SetStruct(currentValue, newValue) end

---@generic T
---@param currentValue T 
---@param newValue T 
---@return boolean ret 
---@return T currentValue (Ref) 
function SetPropertyUtility_Static.SetClass(currentValue, newValue) end


---@type Static.UnityEngine.UI.SetPropertyUtility
UnityEngine.UI.SetPropertyUtility = SetPropertyUtility_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Slider : UnityEngine.UI.Selectable, UnityEngine.EventSystems.IInitializePotentialDragHandler, UnityEngine.EventSystems.IDragHandler, UnityEngine.UI.ICanvasElement, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler
---@field fillRect UnityEngine.RectTransform
---@field handleRect UnityEngine.RectTransform
---@field direction UnityEngine.UI.Slider.Direction
---@field minValue number
---@field maxValue number
---@field wholeNumbers boolean
---@field value number
---@field normalizedValue number
---@field onValueChanged UnityEngine.UI.Slider.SliderEvent
local Slider_Impl = {}

---@param input number 
function Slider_Impl:SetValueWithoutNotify(input) end

---@param executing UnityEngine.UI.CanvasUpdate 
function Slider_Impl:Rebuild(executing) end

function Slider_Impl:LayoutComplete() end

function Slider_Impl:GraphicUpdateComplete() end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Slider_Impl:OnPointerDown(eventData) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Slider_Impl:OnDrag(eventData) end

---@param eventData UnityEngine.EventSystems.AxisEventData 
function Slider_Impl:OnMove(eventData) end

---@return UnityEngine.UI.Selectable ret 
function Slider_Impl:FindSelectableOnLeft() end

---@return UnityEngine.UI.Selectable ret 
function Slider_Impl:FindSelectableOnRight() end

---@return UnityEngine.UI.Selectable ret 
function Slider_Impl:FindSelectableOnUp() end

---@return UnityEngine.UI.Selectable ret 
function Slider_Impl:FindSelectableOnDown() end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Slider_Impl:OnInitializePotentialDrag(eventData) end

---@param direction UnityEngine.UI.Slider.Direction 
---@param includeRectLayouts boolean 
function Slider_Impl:SetDirection(direction, includeRectLayouts) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.SpriteState : System.IEquatable<UnityEngine.UI.SpriteState>
---@field highlightedSprite UnityEngine.Sprite
---@field pressedSprite UnityEngine.Sprite
---@field selectedSprite UnityEngine.Sprite
---@field disabledSprite UnityEngine.Sprite
local SpriteState_Impl = {}

---@param other UnityEngine.UI.SpriteState 
---@return boolean ret 
function SpriteState_Impl:Equals(other) end

---@class Static.UnityEngine.UI.SpriteState
---@overload fun(): UnityEngine.UI.SpriteState (Constructor)
local SpriteState_Static = {}


---@type Static.UnityEngine.UI.SpriteState
UnityEngine.UI.SpriteState = SpriteState_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.StencilMaterial
local StencilMaterial_Impl = {}

---@class Static.UnityEngine.UI.StencilMaterial
local StencilMaterial_Static = {}

---@param baseMat UnityEngine.Material 
---@param stencilID integer 
---@return UnityEngine.Material ret 
function StencilMaterial_Static.Add(baseMat, stencilID) end

---@param baseMat UnityEngine.Material 
---@param stencilID integer 
---@param operation UnityEngine.Rendering.StencilOp 
---@param compareFunction UnityEngine.Rendering.CompareFunction 
---@param colorWriteMask UnityEngine.Rendering.ColorWriteMask 
---@return UnityEngine.Material ret 
function StencilMaterial_Static.Add(baseMat, stencilID, operation, compareFunction, colorWriteMask) end

---@param baseMat UnityEngine.Material 
---@param stencilID integer 
---@param operation UnityEngine.Rendering.StencilOp 
---@param compareFunction UnityEngine.Rendering.CompareFunction 
---@param colorWriteMask UnityEngine.Rendering.ColorWriteMask 
---@param readMask integer 
---@param writeMask integer 
---@return UnityEngine.Material ret 
function StencilMaterial_Static.Add(baseMat, stencilID, operation, compareFunction, colorWriteMask, readMask, writeMask) end

---@param customMat UnityEngine.Material 
function StencilMaterial_Static.Remove(customMat) end

function StencilMaterial_Static.ClearAll() end


---@type Static.UnityEngine.UI.StencilMaterial
UnityEngine.UI.StencilMaterial = StencilMaterial_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Text : UnityEngine.UI.MaskableGraphic, UnityEngine.UI.IMaterialModifier, UnityEngine.UI.IMaskable, UnityEngine.UI.ICanvasElement, UnityEngine.UI.ILayoutElement, UnityEngine.UI.IClippable
---@field cachedTextGenerator UnityEngine.TextGenerator
---@field cachedTextGeneratorForLayout UnityEngine.TextGenerator
---@field mainTexture UnityEngine.Texture
---@field font UnityEngine.Font
---@field text string
---@field supportRichText boolean
---@field resizeTextForBestFit boolean
---@field resizeTextMinSize integer
---@field resizeTextMaxSize integer
---@field alignment UnityEngine.TextAnchor
---@field alignByGeometry boolean
---@field fontSize integer
---@field horizontalOverflow UnityEngine.HorizontalWrapMode
---@field verticalOverflow UnityEngine.VerticalWrapMode
---@field lineSpacing number
---@field fontStyle UnityEngine.FontStyle
---@field pixelsPerUnit number
---@field minWidth number
---@field preferredWidth number
---@field flexibleWidth number
---@field minHeight number
---@field preferredHeight number
---@field flexibleHeight number
---@field layoutPriority integer
local Text_Impl = {}

function Text_Impl:FontTextureChanged() end

---@param extents UnityEngine.Vector2 
---@return UnityEngine.TextGenerationSettings ret 
function Text_Impl:GetGenerationSettings(extents) end

function Text_Impl:CalculateLayoutInputHorizontal() end

function Text_Impl:CalculateLayoutInputVertical() end

function Text_Impl:OnRebuildRequested() end

---@class Static.UnityEngine.UI.Text
local Text_Static = {}

---@param anchor UnityEngine.TextAnchor 
---@return UnityEngine.Vector2 ret 
function Text_Static.GetTextAnchorPivot(anchor) end


---@type Static.UnityEngine.UI.Text
UnityEngine.UI.Text = Text_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Toggle : UnityEngine.UI.Selectable, UnityEngine.UI.ICanvasElement, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler, UnityEngine.EventSystems.ISelectHandler, UnityEngine.EventSystems.IPointerExitHandler, UnityEngine.EventSystems.IDeselectHandler, UnityEngine.EventSystems.IPointerDownHandler, UnityEngine.EventSystems.IPointerUpHandler, UnityEngine.EventSystems.IMoveHandler, UnityEngine.EventSystems.ISubmitHandler, UnityEngine.EventSystems.IPointerClickHandler
---@field group UnityEngine.UI.ToggleGroup
---@field isOn boolean
---@field toggleTransition UnityEngine.UI.Toggle.ToggleTransition
---@field graphic UnityEngine.UI.Graphic
---@field onValueChanged UnityEngine.UI.Toggle.ToggleEvent
local Toggle_Impl = {}

---@param executing UnityEngine.UI.CanvasUpdate 
function Toggle_Impl:Rebuild(executing) end

function Toggle_Impl:LayoutComplete() end

function Toggle_Impl:GraphicUpdateComplete() end

---@param value boolean 
function Toggle_Impl:SetIsOnWithoutNotify(value) end

---@param eventData UnityEngine.EventSystems.PointerEventData 
function Toggle_Impl:OnPointerClick(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function Toggle_Impl:OnSubmit(eventData) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ToggleGroup : UnityEngine.EventSystems.UIBehaviour
---@field allowSwitchOff boolean
local ToggleGroup_Impl = {}

---@param toggle UnityEngine.UI.Toggle 
---@param sendCallback? boolean 
function ToggleGroup_Impl:NotifyToggleOn(toggle, sendCallback) end

---@param toggle UnityEngine.UI.Toggle 
function ToggleGroup_Impl:UnregisterToggle(toggle) end

---@param toggle UnityEngine.UI.Toggle 
function ToggleGroup_Impl:RegisterToggle(toggle) end

function ToggleGroup_Impl:EnsureValidState() end

---@return boolean ret 
function ToggleGroup_Impl:AnyTogglesOn() end

---@return System.Collections.Generic.IEnumerable ret 
function ToggleGroup_Impl:ActiveToggles() end

---@return UnityEngine.UI.Toggle ret 
function ToggleGroup_Impl:GetFirstActiveToggle() end

---@param sendCallback? boolean 
function ToggleGroup_Impl:SetAllTogglesOff(sendCallback) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.VertexHelper : System.IDisposable
---@field currentVertCount integer
---@field currentIndexCount integer
local VertexHelper_Impl = {}

function VertexHelper_Impl:Dispose() end

function VertexHelper_Impl:Clear() end

---@param vertex UnityEngine.UIVertex 
---@param i integer 
---@return UnityEngine.UIVertex vertex (Ref) 
function VertexHelper_Impl:PopulateUIVertex(vertex, i) end

---@param vertex UnityEngine.UIVertex 
---@param i integer 
function VertexHelper_Impl:SetUIVertex(vertex, i) end

---@param mesh UnityEngine.Mesh 
function VertexHelper_Impl:FillMesh(mesh) end

---@param position UnityEngine.Vector3 
---@param color UnityEngine.Color32 
---@param uv0 UnityEngine.Vector4 
---@param uv1 UnityEngine.Vector4 
---@param uv2 UnityEngine.Vector4 
---@param uv3 UnityEngine.Vector4 
---@param normal UnityEngine.Vector3 
---@param tangent UnityEngine.Vector4 
function VertexHelper_Impl:AddVert(position, color, uv0, uv1, uv2, uv3, normal, tangent) end

---@param position UnityEngine.Vector3 
---@param color UnityEngine.Color32 
---@param uv0 UnityEngine.Vector4 
---@param uv1 UnityEngine.Vector4 
---@param normal UnityEngine.Vector3 
---@param tangent UnityEngine.Vector4 
function VertexHelper_Impl:AddVert(position, color, uv0, uv1, normal, tangent) end

---@param position UnityEngine.Vector3 
---@param color UnityEngine.Color32 
---@param uv0 UnityEngine.Vector4 
function VertexHelper_Impl:AddVert(position, color, uv0) end

---@param v UnityEngine.UIVertex 
function VertexHelper_Impl:AddVert(v) end

---@param idx0 integer 
---@param idx1 integer 
---@param idx2 integer 
function VertexHelper_Impl:AddTriangle(idx0, idx1, idx2) end

---@param verts UnityEngine.UIVertex[] 
function VertexHelper_Impl:AddUIVertexQuad(verts) end

---@param verts System.Collections.Generic.List 
---@param indices System.Collections.Generic.List 
function VertexHelper_Impl:AddUIVertexStream(verts, indices) end

---@param verts System.Collections.Generic.List 
function VertexHelper_Impl:AddUIVertexTriangleStream(verts) end

---@param stream System.Collections.Generic.List 
function VertexHelper_Impl:GetUIVertexStream(stream) end

---@class Static.UnityEngine.UI.VertexHelper
---@overload fun(): UnityEngine.UI.VertexHelper (Constructor)
---@overload fun(m:UnityEngine.Mesh): UnityEngine.UI.VertexHelper (Constructor)
local VertexHelper_Static = {}


---@type Static.UnityEngine.UI.VertexHelper
UnityEngine.UI.VertexHelper = VertexHelper_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.BaseVertexEffect
local BaseVertexEffect_Impl = {}

---@param vertices System.Collections.Generic.List 
function BaseVertexEffect_Impl:ModifyVertices(vertices) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.BaseMeshEffect : UnityEngine.EventSystems.UIBehaviour, UnityEngine.UI.IMeshModifier
local BaseMeshEffect_Impl = {}

---@param mesh UnityEngine.Mesh 
function BaseMeshEffect_Impl:ModifyMesh(mesh) end

---@param vh UnityEngine.UI.VertexHelper 
function BaseMeshEffect_Impl:ModifyMesh(vh) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Outline : UnityEngine.UI.Shadow, UnityEngine.UI.IMeshModifier
local Outline_Impl = {}

---@param vh UnityEngine.UI.VertexHelper 
function Outline_Impl:ModifyMesh(vh) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.PositionAsUV1 : UnityEngine.UI.BaseMeshEffect, UnityEngine.UI.IMeshModifier
local PositionAsUV1_Impl = {}

---@param vh UnityEngine.UI.VertexHelper 
function PositionAsUV1_Impl:ModifyMesh(vh) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Shadow : UnityEngine.UI.BaseMeshEffect, UnityEngine.UI.IMeshModifier
---@field effectColor UnityEngine.Color
---@field effectDistance UnityEngine.Vector2
---@field useGraphicAlpha boolean
local Shadow_Impl = {}

---@param vh UnityEngine.UI.VertexHelper 
function Shadow_Impl:ModifyMesh(vh) end

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Button.ButtonClickedEvent : UnityEngine.Events.UnityEvent, UnityEngine.ISerializationCallbackReceiver
local ButtonClickedEvent_Impl = {}

---@class Static.UnityEngine.UI.Button.ButtonClickedEvent
---@overload fun(): UnityEngine.UI.Button.ButtonClickedEvent (Constructor)
local ButtonClickedEvent_Static = {}


---@type Static.UnityEngine.UI.Button.ButtonClickedEvent
UnityEngine.UI.ButtonClickedEvent = ButtonClickedEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.DefaultControls.DefaultRuntimeFactory : UnityEngine.UI.DefaultControls.IFactoryControls
local DefaultRuntimeFactory_Impl = {}

---@param name string 
---@param components System.Type[] 
---@return UnityEngine.GameObject ret 
function DefaultRuntimeFactory_Impl:CreateGameObject(name, components) end

---@class Static.UnityEngine.UI.DefaultControls.DefaultRuntimeFactory
---@field Default UnityEngine.UI.DefaultControls.IFactoryControls
---@overload fun(): UnityEngine.UI.DefaultControls.DefaultRuntimeFactory (Constructor)
local DefaultRuntimeFactory_Static = {}


---@type Static.UnityEngine.UI.DefaultControls.DefaultRuntimeFactory
UnityEngine.UI.DefaultRuntimeFactory = DefaultRuntimeFactory_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.DefaultControls.Resources
---@field standard UnityEngine.Sprite
---@field background UnityEngine.Sprite
---@field inputField UnityEngine.Sprite
---@field knob UnityEngine.Sprite
---@field checkmark UnityEngine.Sprite
---@field dropdown UnityEngine.Sprite
---@field mask UnityEngine.Sprite
local Resources_Impl = {}

---@class Static.UnityEngine.UI.DefaultControls.Resources
---@overload fun(): UnityEngine.UI.DefaultControls.Resources (Constructor)
local Resources_Static = {}


---@type Static.UnityEngine.UI.DefaultControls.Resources
UnityEngine.UI.Resources = Resources_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Dropdown.DropdownItem : UnityEngine.MonoBehaviour, UnityEngine.EventSystems.ICancelHandler, UnityEngine.EventSystems.IEventSystemHandler, UnityEngine.EventSystems.IPointerEnterHandler
---@field text UnityEngine.UI.Text
---@field image UnityEngine.UI.Image
---@field rectTransform UnityEngine.RectTransform
---@field toggle UnityEngine.UI.Toggle
local DropdownItem_Impl = {}

---@param eventData UnityEngine.EventSystems.PointerEventData 
function DropdownItem_Impl:OnPointerEnter(eventData) end

---@param eventData UnityEngine.EventSystems.BaseEventData 
function DropdownItem_Impl:OnCancel(eventData) end

---@class Static.UnityEngine.UI.Dropdown.DropdownItem
---@overload fun(): UnityEngine.UI.Dropdown.DropdownItem (Constructor)
local DropdownItem_Static = {}


---@type Static.UnityEngine.UI.Dropdown.DropdownItem
UnityEngine.UI.DropdownItem = DropdownItem_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Dropdown.OptionData
---@field text string
---@field image UnityEngine.Sprite
local OptionData_Impl = {}

---@class Static.UnityEngine.UI.Dropdown.OptionData
---@overload fun(): UnityEngine.UI.Dropdown.OptionData (Constructor)
---@overload fun(text:string): UnityEngine.UI.Dropdown.OptionData (Constructor)
---@overload fun(image:UnityEngine.Sprite): UnityEngine.UI.Dropdown.OptionData (Constructor)
---@overload fun(text:string, image:UnityEngine.Sprite): UnityEngine.UI.Dropdown.OptionData (Constructor)
local OptionData_Static = {}


---@type Static.UnityEngine.UI.Dropdown.OptionData
UnityEngine.UI.OptionData = OptionData_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Dropdown.OptionDataList
---@field options System.Collections.Generic.List
local OptionDataList_Impl = {}

---@class Static.UnityEngine.UI.Dropdown.OptionDataList
---@overload fun(): UnityEngine.UI.Dropdown.OptionDataList (Constructor)
local OptionDataList_Static = {}


---@type Static.UnityEngine.UI.Dropdown.OptionDataList
UnityEngine.UI.OptionDataList = OptionDataList_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Dropdown.DropdownEvent : UnityEngine.Events.UnityEvent<System.Int32>, UnityEngine.ISerializationCallbackReceiver
local DropdownEvent_Impl = {}

---@class Static.UnityEngine.UI.Dropdown.DropdownEvent
---@overload fun(): UnityEngine.UI.Dropdown.DropdownEvent (Constructor)
local DropdownEvent_Static = {}


---@type Static.UnityEngine.UI.Dropdown.DropdownEvent
UnityEngine.UI.DropdownEvent = DropdownEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.InputField.SubmitEvent : UnityEngine.Events.UnityEvent<System.String>, UnityEngine.ISerializationCallbackReceiver
local SubmitEvent_Impl = {}

---@class Static.UnityEngine.UI.InputField.SubmitEvent
---@overload fun(): UnityEngine.UI.InputField.SubmitEvent (Constructor)
local SubmitEvent_Static = {}


---@type Static.UnityEngine.UI.InputField.SubmitEvent
UnityEngine.UI.SubmitEvent = SubmitEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.InputField.EndEditEvent : UnityEngine.Events.UnityEvent<System.String>, UnityEngine.ISerializationCallbackReceiver
local EndEditEvent_Impl = {}

---@class Static.UnityEngine.UI.InputField.EndEditEvent
---@overload fun(): UnityEngine.UI.InputField.EndEditEvent (Constructor)
local EndEditEvent_Static = {}


---@type Static.UnityEngine.UI.InputField.EndEditEvent
UnityEngine.UI.EndEditEvent = EndEditEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.InputField.OnChangeEvent : UnityEngine.Events.UnityEvent<System.String>, UnityEngine.ISerializationCallbackReceiver
local OnChangeEvent_Impl = {}

---@class Static.UnityEngine.UI.InputField.OnChangeEvent
---@overload fun(): UnityEngine.UI.InputField.OnChangeEvent (Constructor)
local OnChangeEvent_Static = {}


---@type Static.UnityEngine.UI.InputField.OnChangeEvent
UnityEngine.UI.OnChangeEvent = OnChangeEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.MaskableGraphic.CullStateChangedEvent : UnityEngine.Events.UnityEvent<System.Boolean>, UnityEngine.ISerializationCallbackReceiver
local CullStateChangedEvent_Impl = {}

---@class Static.UnityEngine.UI.MaskableGraphic.CullStateChangedEvent
---@overload fun(): UnityEngine.UI.MaskableGraphic.CullStateChangedEvent (Constructor)
local CullStateChangedEvent_Static = {}


---@type Static.UnityEngine.UI.MaskableGraphic.CullStateChangedEvent
UnityEngine.UI.CullStateChangedEvent = CullStateChangedEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Scrollbar.ScrollEvent : UnityEngine.Events.UnityEvent<System.Single>, UnityEngine.ISerializationCallbackReceiver
local ScrollEvent_Impl = {}

---@class Static.UnityEngine.UI.Scrollbar.ScrollEvent
---@overload fun(): UnityEngine.UI.Scrollbar.ScrollEvent (Constructor)
local ScrollEvent_Static = {}


---@type Static.UnityEngine.UI.Scrollbar.ScrollEvent
UnityEngine.UI.ScrollEvent = ScrollEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.ScrollRect.ScrollRectEvent : UnityEngine.Events.UnityEvent<UnityEngine.Vector2>, UnityEngine.ISerializationCallbackReceiver
local ScrollRectEvent_Impl = {}

---@class Static.UnityEngine.UI.ScrollRect.ScrollRectEvent
---@overload fun(): UnityEngine.UI.ScrollRect.ScrollRectEvent (Constructor)
local ScrollRectEvent_Static = {}


---@type Static.UnityEngine.UI.ScrollRect.ScrollRectEvent
UnityEngine.UI.ScrollRectEvent = ScrollRectEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Slider.SliderEvent : UnityEngine.Events.UnityEvent<System.Single>, UnityEngine.ISerializationCallbackReceiver
local SliderEvent_Impl = {}

---@class Static.UnityEngine.UI.Slider.SliderEvent
---@overload fun(): UnityEngine.UI.Slider.SliderEvent (Constructor)
local SliderEvent_Static = {}


---@type Static.UnityEngine.UI.Slider.SliderEvent
UnityEngine.UI.SliderEvent = SliderEvent_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.StencilMaterial.MatEntry
---@field baseMat UnityEngine.Material
---@field customMat UnityEngine.Material
---@field count integer
---@field stencilId integer
---@field operation UnityEngine.Rendering.StencilOp
---@field compareFunction UnityEngine.Rendering.CompareFunction
---@field readMask integer
---@field writeMask integer
---@field useAlphaClip boolean
---@field colorMask UnityEngine.Rendering.ColorWriteMask
local MatEntry_Impl = {}

---@class Static.UnityEngine.UI.StencilMaterial.MatEntry
---@overload fun(): UnityEngine.UI.StencilMaterial.MatEntry (Constructor)
local MatEntry_Static = {}


---@type Static.UnityEngine.UI.StencilMaterial.MatEntry
UnityEngine.UI.MatEntry = MatEntry_Static

--------------------------------------------------------------------------------

---@class UnityEngine.UI.Toggle.ToggleEvent : UnityEngine.Events.UnityEvent<System.Boolean>, UnityEngine.ISerializationCallbackReceiver
local ToggleEvent_Impl = {}

---@class Static.UnityEngine.UI.Toggle.ToggleEvent
---@overload fun(): UnityEngine.UI.Toggle.ToggleEvent (Constructor)
local ToggleEvent_Static = {}


---@type Static.UnityEngine.UI.Toggle.ToggleEvent
UnityEngine.UI.ToggleEvent = ToggleEvent_Static

--------------------------------------------------------------------------------

