--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.Playables
UnityEngine.Playables = {}

--- This structure contains the frame information a Playable receives in Playable.PrepareFrame.
---@enum UnityEngine.Playables.FrameData.Flags
local Flags_Enum = {
    Evaluate = 1,
    SeekOccured = 2,
    Loop = 4,
    Hold = 8,
    EffectivePlayStateDelayed = 16,
    EffectivePlayStatePlaying = 32,
}
UnityEngine.Playables.Flags = Flags_Enum

--- This structure contains the frame information a Playable receives in Playable.PrepareFrame.
---@enum UnityEngine.Playables.FrameData.EvaluationType
local EvaluationType_Enum = {
    --- Indicates the graph was updated due to a call to PlayableGraph.Evaluate.
    Evaluate = 0,
    --- Indicates the graph was called by the runtime during normal playback due to PlayableGraph.Play being called.
    Playback = 1,
}
UnityEngine.Playables.EvaluationType = EvaluationType_Enum

--- Wrap mode for Playables.
---@enum UnityEngine.Playables.DirectorWrapMode
local DirectorWrapMode_Enum = {
    --- Hold the last frame when the playable time reaches it's duration.
    Hold = 0,
    --- Loop back to zero time and continue playing.
    Loop = 1,
    --- Do not keep playing when the time reaches the duration.
    None = 2,
}
UnityEngine.Playables.DirectorWrapMode = DirectorWrapMode_Enum

--- Describes the type of information that flows in and out of a Playable. This also specifies that this Playable is connectable to others of the same type.
---@enum UnityEngine.Playables.DataStreamType
local DataStreamType_Enum = {
    --- Describes that the information flowing in and out of the Playable is of Animation type.
    Animation = 0,
    --- Describes that the information flowing in and out of the Playable is of Audio type.
    Audio = 1,
    --- Describes that the information flowing in and out of the Playable is of type Texture.
    Texture = 2,
    --- Describes that the Playable does not have any particular type. This is use for Playables that execute script code, or that create their own playable graphs, such as the Sequence.
    None = 3,
}
UnityEngine.Playables.DataStreamType = DataStreamType_Enum

--- Traversal mode for Playables.
---@enum UnityEngine.Playables.PlayableTraversalMode
local PlayableTraversalMode_Enum = {
    --- Causes the Playable to prepare and process it's inputs when demanded by an output.
    Mix = 0,
    --- Causes the Playable to act as a passthrough for PrepareFrame and ProcessFrame. If the PlayableOutput being processed is connected to the n-th input port of the Playable, the Playable only propagates the n-th output port. Use this enum value in conjunction with PlayableOutput SetSourceOutputPort.
    Passthrough = 1,
}
UnityEngine.Playables.PlayableTraversalMode = PlayableTraversalMode_Enum

--- Defines what time source is used to update a Director graph.
---@enum UnityEngine.Playables.DirectorUpdateMode
local DirectorUpdateMode_Enum = {
    --- Update is based on DSP (Digital Sound Processing) clock. Use this for graphs that need to be synchronized with Audio.
    DSPClock = 0,
    --- Update is based on Time.time. Use this for graphs that need to be synchronized on gameplay, and that need to be paused when the game is paused.
    GameTime = 1,
    --- Update is based on Time.unscaledTime. Use this for graphs that need to be updated even when gameplay is paused. Example: Menus transitions need to be updated even when the game is paused.
    UnscaledGameTime = 2,
    --- Update mode is manual. You need to manually call PlayableGraph.Evaluate with your own deltaTime. This can be useful for graphs that are completely disconnected from the rest of the game. For example, localized bullet time.
    Manual = 3,
}
UnityEngine.Playables.DirectorUpdateMode = DirectorUpdateMode_Enum

--- Status of a Playable.
---@enum UnityEngine.Playables.PlayState
local PlayState_Enum = {
    --- The Playable has been paused. Its local time will not advance.
    Paused = 0,
    --- The Playable is currently Playing.
    Playing = 1,
    --- The Playable has been delayed, using PlayableExtensions.SetDelay. It will not start until the delay is entirely consumed.
    Delayed = 2,
}
UnityEngine.Playables.PlayState = PlayState_Enum

--- Implements high-level utility methods to simplify use of the Playable API with Animations.
---@class UnityEngine.Playables.AnimationPlayableUtilities
local AnimationPlayableUtilities_Impl = {}

---@class Static.UnityEngine.Playables.AnimationPlayableUtilities
local AnimationPlayableUtilities_Static = {}

--- Plays the Playable on the given Animator.
---@param animator UnityEngine.Animator Target Animator.
---@param playable UnityEngine.Playables.Playable The Playable that will be played.
---@param graph UnityEngine.Playables.PlayableGraph The Graph that owns the Playable.
function AnimationPlayableUtilities_Static.Play(animator, playable, graph) end

--- Creates a PlayableGraph to be played on the given Animator. An AnimationClipPlayable is also created for the given AnimationClip.
---@param animator UnityEngine.Animator Target Animator.
---@param clip UnityEngine.AnimationClip The AnimationClip to create an AnimationClipPlayable for.
---@return UnityEngine.Animations.AnimationClipPlayable ret A handle to the newly-created AnimationClipPlayable.
---@return UnityEngine.Playables.PlayableGraph graph (Out) The created PlayableGraph.
function AnimationPlayableUtilities_Static.PlayClip(animator, clip) end

--- Creates a PlayableGraph to be played on the given Animator. An AnimationMixerPlayable is also created.
---@param animator UnityEngine.Animator Target Animator.
---@param inputCount integer The input count for the AnimationMixerPlayable.
---@return UnityEngine.Animations.AnimationMixerPlayable ret A handle to the newly-created AnimationMixerPlayable.
---@return UnityEngine.Playables.PlayableGraph graph (Out) The created PlayableGraph.
function AnimationPlayableUtilities_Static.PlayMixer(animator, inputCount) end

--- Creates a PlayableGraph to be played on the given Animator. An AnimationLayerMixerPlayable is also created.
---@param animator UnityEngine.Animator Target Animator.
---@param inputCount integer The input count for the AnimationLayerMixerPlayable. Defines the number of layers.
---@return UnityEngine.Animations.AnimationLayerMixerPlayable ret A handle to the newly-created AnimationLayerMixerPlayable.
---@return UnityEngine.Playables.PlayableGraph graph (Out) The created PlayableGraph.
function AnimationPlayableUtilities_Static.PlayLayerMixer(animator, inputCount) end

--- Creates a PlayableGraph to be played on the given Animator. An AnimatorControllerPlayable is also created for the given RuntimeAnimatorController.
---@param animator UnityEngine.Animator Target Animator.
---@param controller UnityEngine.RuntimeAnimatorController The RuntimeAnimatorController to create an AnimatorControllerPlayable for.
---@return UnityEngine.Animations.AnimatorControllerPlayable ret A handle to the newly-created AnimatorControllerPlayable.
---@return UnityEngine.Playables.PlayableGraph graph (Out) The created PlayableGraph.
function AnimationPlayableUtilities_Static.PlayAnimatorController(animator, controller) end


---@type Static.UnityEngine.Playables.AnimationPlayableUtilities
UnityEngine.Playables.AnimationPlayableUtilities = AnimationPlayableUtilities_Static

--------------------------------------------------------------------------------

--- This structure contains the frame information a Playable receives in Playable.PrepareFrame.
---@class UnityEngine.Playables.FrameData
--- The current frame identifier.
---@field frameId integer
--- Time difference between this frame and the preceding frame.
---@field deltaTime number
--- The weight of the current Playable.
---@field weight number
--- The accumulated weight of the Playable during the PlayableGraph traversal.
---@field effectiveWeight number
--- The accumulated delay of the parent Playable during the PlayableGraph traversal.
---@field effectiveParentDelay number
--- The accumulated speed of the parent Playable during the PlayableGraph traversal.
---@field effectiveParentSpeed number
--- The accumulated speed of the Playable during the PlayableGraph traversal.
---@field effectiveSpeed number
--- Indicates the type of evaluation that caused PlayableGraph.PrepareFrame to be called.
---@field evaluationType UnityEngine.Playables.FrameData.EvaluationType
--- Indicates that the local time was explicitly set.
---@field seekOccurred boolean
--- Indicates the local time wrapped because it has reached the duration and the extrapolation mode is set to Loop.
---@field timeLooped boolean
--- Indicates the local time did not advance because it has reached the duration and the extrapolation mode is set to Hold.
---@field timeHeld boolean
--- The PlayableOutput that initiated this graph traversal.
---@field output UnityEngine.Playables.PlayableOutput
--- The accumulated play state of this playable.
---@field effectivePlayState UnityEngine.Playables.PlayState
local FrameData_Impl = {}

---@class Static.UnityEngine.Playables.FrameData
---@overload fun(): UnityEngine.Playables.FrameData (Constructor)
local FrameData_Static = {}


---@type Static.UnityEngine.Playables.FrameData
UnityEngine.Playables.FrameData = FrameData_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Playables.FrameRate : System.IEquatable<UnityEngine.Playables.FrameRate>
---@field dropFrame boolean
---@field rate number
local FrameRate_Impl = {}

---@return boolean ret 
function FrameRate_Impl:IsValid() end

---@param other UnityEngine.Playables.FrameRate 
---@return boolean ret 
function FrameRate_Impl:Equals(other) end

---@param obj System.Object 
---@return boolean ret 
function FrameRate_Impl:Equals(obj) end

---@return integer ret 
function FrameRate_Impl:GetHashCode() end

---@return string ret 
function FrameRate_Impl:ToString() end

---@param format string 
---@return string ret 
function FrameRate_Impl:ToString(format) end

---@param format string 
---@param formatProvider System.IFormatProvider 
---@return string ret 
function FrameRate_Impl:ToString(format, formatProvider) end

---@class Static.UnityEngine.Playables.FrameRate
---@field k_24Fps UnityEngine.Playables.FrameRate
---@field k_23_976Fps UnityEngine.Playables.FrameRate
---@field k_25Fps UnityEngine.Playables.FrameRate
---@field k_30Fps UnityEngine.Playables.FrameRate
---@field k_29_97Fps UnityEngine.Playables.FrameRate
---@field k_50Fps UnityEngine.Playables.FrameRate
---@field k_60Fps UnityEngine.Playables.FrameRate
---@field k_59_94Fps UnityEngine.Playables.FrameRate
---@overload fun(frameRate?:integer, drop?:boolean): UnityEngine.Playables.FrameRate (Constructor)
---@overload fun(): UnityEngine.Playables.FrameRate (Constructor)
local FrameRate_Static = {}


---@type Static.UnityEngine.Playables.FrameRate
UnityEngine.Playables.FrameRate = FrameRate_Static

--------------------------------------------------------------------------------

--- Default implementation for Playable notifications.
---@class UnityEngine.Playables.Notification : UnityEngine.Playables.INotification
--- The name that identifies this notification.
---@field id UnityEngine.PropertyName
local Notification_Impl = {}

---@class Static.UnityEngine.Playables.Notification
---@overload fun(name:string): UnityEngine.Playables.Notification (Constructor)
local Notification_Static = {}


---@type Static.UnityEngine.Playables.Notification
UnityEngine.Playables.Notification = Notification_Static

--------------------------------------------------------------------------------

--- Playables are customizable runtime objects that can be connected together and are contained in a PlayableGraph to create complex behaviours.
---@class UnityEngine.Playables.Playable : System.IEquatable<UnityEngine.Playables.Playable>, UnityEngine.Playables.IPlayable
local Playable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function Playable_Impl:GetHandle() end

---@generic T
---@return boolean ret 
function Playable_Impl:IsPlayableOfType() end

---@return System.Type ret 
function Playable_Impl:GetPlayableType() end

---@param other UnityEngine.Playables.Playable 
---@return boolean ret 
function Playable_Impl:Equals(other) end

---@class Static.UnityEngine.Playables.Playable
--- Returns an invalid Playable.
---@field Null UnityEngine.Playables.Playable
---@overload fun(): UnityEngine.Playables.Playable (Constructor)
local Playable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param inputCount? integer 
---@return UnityEngine.Playables.Playable ret 
function Playable_Static.Create(graph, inputCount) end


---@type Static.UnityEngine.Playables.Playable
UnityEngine.Playables.Playable = Playable_Static

--------------------------------------------------------------------------------

--- A base class for assets that can be used to instantiate a Playable at runtime.
---@class UnityEngine.Playables.PlayableAsset : UnityEngine.ScriptableObject, UnityEngine.Playables.IPlayableAsset
--- The playback duration in seconds of the instantiated Playable.
---@field duration number
--- A description of the outputs of the instantiated Playable.
---@field outputs System.Collections.Generic.IEnumerable
local PlayableAsset_Impl = {}

--- Implement this method to have your asset inject playables into the given graph.
---@param graph UnityEngine.Playables.PlayableGraph The graph to inject playables into.
---@param owner UnityEngine.GameObject The game object which initiated the build.
---@return UnityEngine.Playables.Playable ret The playable injected into the graph, or the root playable if multiple playables are injected.
function PlayableAsset_Impl:CreatePlayable(graph, owner) end

--------------------------------------------------------------------------------

--- PlayableBehaviour is the base class from which every custom playable script derives.
---@class UnityEngine.Playables.PlayableBehaviour : System.ICloneable, UnityEngine.Playables.IPlayableBehaviour
local PlayableBehaviour_Impl = {}

--- This function is called when the PlayableGraph that owns this PlayableBehaviour starts.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
function PlayableBehaviour_Impl:OnGraphStart(playable) end

--- This function is called when the PlayableGraph that owns this PlayableBehaviour stops.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
function PlayableBehaviour_Impl:OnGraphStop(playable) end

--- This function is called when the Playable that owns the PlayableBehaviour is created.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
function PlayableBehaviour_Impl:OnPlayableCreate(playable) end

--- This function is called when the Playable that owns the PlayableBehaviour is destroyed.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
function PlayableBehaviour_Impl:OnPlayableDestroy(playable) end

--- This function is called when the Playable play state is changed to Playables.PlayState.Delayed.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
function PlayableBehaviour_Impl:OnBehaviourDelay(playable, info) end

--- This function is called when the Playable play state is changed to Playables.PlayState.Playing.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
function PlayableBehaviour_Impl:OnBehaviourPlay(playable, info) end

--- This method is invoked when one of the following situations occurs: <br><br> The effective play state during traversal is changed to Playables.PlayState.Paused. This state is indicated by FrameData.effectivePlayState.<br><br> The PlayableGraph is stopped while the playable play state is Playing. This state is indicated by PlayableGraph.IsPlaying returning true.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
function PlayableBehaviour_Impl:OnBehaviourPause(playable, info) end

--- This function is called during the PrepareData phase of the PlayableGraph.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
function PlayableBehaviour_Impl:PrepareData(playable, info) end

--- This function is called during the PrepareFrame phase of the PlayableGraph.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
function PlayableBehaviour_Impl:PrepareFrame(playable, info) end

--- This function is called during the ProcessFrame phase of the PlayableGraph.
---@param playable UnityEngine.Playables.Playable The Playable that owns the current PlayableBehaviour.
---@param info UnityEngine.Playables.FrameData A FrameData structure that contains information about the current frame context.
---@param playerData System.Object The user data of the ScriptPlayableOutput that initiated the process pass.
function PlayableBehaviour_Impl:ProcessFrame(playable, info, playerData) end

---@return System.Object ret 
function PlayableBehaviour_Impl:Clone() end

--------------------------------------------------------------------------------

--- Struct that holds information regarding an output of a PlayableAsset.
---@class UnityEngine.Playables.PlayableBinding
--- The name of the output or input stream.
---@field streamName string
--- A reference to a UnityEngine.Object that acts a key for this binding.
---@field sourceObject UnityEngine.Object
--- The type of target required by the PlayableOutput for this PlayableBinding.
---@field outputTargetType System.Type
---@field sourceBindingType System.Type
--- The type of the output or input stream.
---@field streamType UnityEngine.Playables.DataStreamType
local PlayableBinding_Impl = {}

---@class Static.UnityEngine.Playables.PlayableBinding
--- A constant to represent a PlayableAsset has no bindings.
---@field None UnityEngine.Playables.PlayableBinding[]
--- The default duration used when a PlayableOutput has no fixed duration.
---@field DefaultDuration number
---@overload fun(): UnityEngine.Playables.PlayableBinding (Constructor)
local PlayableBinding_Static = {}


---@type Static.UnityEngine.Playables.PlayableBinding
UnityEngine.Playables.PlayableBinding = PlayableBinding_Static

--------------------------------------------------------------------------------

--- Extensions for all the types that implements IPlayable.
---@class UnityEngine.Playables.PlayableExtensions
local PlayableExtensions_Impl = {}

---@class Static.UnityEngine.Playables.PlayableExtensions
local PlayableExtensions_Static = {}

--- Returns true if the Playable is null, false otherwise.
---@generic U
---@param playable U The Playable used by this operation.
---@return boolean ret 
function PlayableExtensions_Static.IsNull(playable) end

--- Returns the vality of the current Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return boolean ret True if the Playable is properly constructed by the PlayableGraph and has not been destroyed, false otherwise.
function PlayableExtensions_Static.IsValid(playable) end

--- Destroys the current Playable.
---@generic U
---@param playable U The Playable used by this operation.
function PlayableExtensions_Static.Destroy(playable) end

--- Returns the PlayableGraph that owns this Playable. A Playable can only be used in the graph that was used to create it.
---@generic U
---@param playable U The Playable used by this operation.
---@return UnityEngine.Playables.PlayableGraph ret The PlayableGraph associated with the current Playable.
function PlayableExtensions_Static.GetGraph(playable) end

--- Changes the current PlayState of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value UnityEngine.Playables.PlayState The new PlayState.
function PlayableExtensions_Static.SetPlayState(playable, value) end

--- Returns the current PlayState of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return UnityEngine.Playables.PlayState ret The current PlayState of the Playable.
function PlayableExtensions_Static.GetPlayState(playable) end

--- Starts to play the Playable.
---@generic U
---@param playable U The Playable used by this operation.
function PlayableExtensions_Static.Play(playable) end

--- Tells to pause the Playable.
---@generic U
---@param playable U The Playable used by this operation.
function PlayableExtensions_Static.Pause(playable) end

--- Changes the speed multiplier that is applied to the the current Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value number The new speed.
function PlayableExtensions_Static.SetSpeed(playable, value) end

--- Returns the speed multiplier that is applied to the the current Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret The current speed.
function PlayableExtensions_Static.GetSpeed(playable) end

--- Changes the duration of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value number The new duration in seconds, must be a positive value.
function PlayableExtensions_Static.SetDuration(playable, value) end

--- Returns the duration of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret The duration in seconds.
function PlayableExtensions_Static.GetDuration(playable) end

--- Changes the current local time of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value number The current time in seconds.
function PlayableExtensions_Static.SetTime(playable, value) end

--- Returns the current local time of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret The current time in seconds.
function PlayableExtensions_Static.GetTime(playable) end

--- Returns the previous local time of the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret The previous time in seconds.
function PlayableExtensions_Static.GetPreviousTime(playable) end

--- Changes a flag indicating that a playable has completed its operation.
---@generic U
---@param playable U The Playable used by this operation.
---@param value boolean True if the operation is completed, false otherwise.
function PlayableExtensions_Static.SetDone(playable, value) end

--- Returns a flag indicating that a playable has completed its operation.
---@generic U
---@param playable U The Playable used by this operation.
---@return boolean ret True if the playable has completed its operation, false otherwise.
function PlayableExtensions_Static.IsDone(playable) end

--- Changes the time propagation behavior of this Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value boolean True to enable time propagation.
function PlayableExtensions_Static.SetPropagateSetTime(playable, value) end

--- Returns the time propagation behavior of this Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return boolean ret True if time propagation is enabled.
function PlayableExtensions_Static.GetPropagateSetTime(playable) end

---@generic U
---@param playable U 
---@return boolean ret 
function PlayableExtensions_Static.CanChangeInputs(playable) end

---@generic U
---@param playable U 
---@return boolean ret 
function PlayableExtensions_Static.CanSetWeights(playable) end

---@generic U
---@param playable U 
---@return boolean ret 
function PlayableExtensions_Static.CanDestroy(playable) end

--- Changes the number of inputs supported by the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value integer 
function PlayableExtensions_Static.SetInputCount(playable, value) end

--- Returns the number of inputs supported by the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return integer ret The count of inputs on the Playable.
function PlayableExtensions_Static.GetInputCount(playable) end

--- Changes the number of outputs supported by the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param value integer 
function PlayableExtensions_Static.SetOutputCount(playable, value) end

--- Returns the number of outputs supported by the Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return integer ret The count of outputs on the Playable.
function PlayableExtensions_Static.GetOutputCount(playable) end

--- Returns the Playable connected at the given input port index.
---@generic U
---@param playable U The Playable used by this operation.
---@param inputPort integer The port index.
---@return UnityEngine.Playables.Playable ret Playable connected at the index specified, or null if the index is valid but is not connected to anything. This happens if there was once a Playable connected at the index, but was disconnected via PlayableGraph.Disconnect.
function PlayableExtensions_Static.GetInput(playable, inputPort) end

--- Returns the Playable connected at the given output port index.
---@generic U
---@param playable U The Playable used by this operation.
---@param outputPort integer The port index.
---@return UnityEngine.Playables.Playable ret Playable connected at the output index specified, or null if the index is valid but is not connected to anything. This happens if there was once a Playable connected at the index, but was disconnected via PlayableGraph.Disconnect.
function PlayableExtensions_Static.GetOutput(playable, outputPort) end

--- Changes the weight of the Playable connected to the current Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param inputIndex integer 
---@param weight number The weight. Should be between 0 and 1.
function PlayableExtensions_Static.SetInputWeight(playable, inputIndex, weight) end

--- Changes the weight of the Playable connected to the current Playable.
---@generic U
---@generic V
---@param playable U The Playable used by this operation.
---@param input V The connected Playable to change.
---@param weight number The weight. Should be between 0 and 1.
function PlayableExtensions_Static.SetInputWeight(playable, input, weight) end

--- Returns the weight of the Playable connected at the given input port index.
---@generic U
---@param playable U The Playable used by this operation.
---@param inputIndex integer The port index.
---@return number ret The current weight of the connected Playable.
function PlayableExtensions_Static.GetInputWeight(playable, inputIndex) end

---@generic U
---@generic V
---@param playable U 
---@param inputIndex integer 
---@param sourcePlayable V 
---@param sourceOutputIndex integer 
function PlayableExtensions_Static.ConnectInput(playable, inputIndex, sourcePlayable, sourceOutputIndex) end

--- Connect the output port of a Playable to one of the input ports.
---@generic U
---@generic V
---@param playable U The Playable used by this operation.
---@param inputIndex integer The input port index.
---@param sourcePlayable V The Playable to connect to.
---@param sourceOutputIndex integer The output port of the Playable.
---@param weight number The weight of the input port.
function PlayableExtensions_Static.ConnectInput(playable, inputIndex, sourcePlayable, sourceOutputIndex, weight) end

--- Disconnect the input port of a Playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param inputPort integer The input port index.
function PlayableExtensions_Static.DisconnectInput(playable, inputPort) end

--- Create a new input port and connect it to the output port of the given Playable.
---@generic U
---@generic V
---@param playable U The Playable used by this operation.
---@param sourcePlayable V The Playable to connect to.
---@param sourceOutputIndex integer The output port of the Playable.
---@param weight? number The weight of the created input port.
---@return integer ret The index of the newly created input port.
function PlayableExtensions_Static.AddInput(playable, sourcePlayable, sourceOutputIndex, weight) end

--- Set a delay until the playable starts.
---@generic U
---@param playable U The Playable used by this operation.
---@param delay number The delay in seconds.
function PlayableExtensions_Static.SetDelay(playable, delay) end

--- Returns the delay of the playable.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret The delay in seconds.
function PlayableExtensions_Static.GetDelay(playable) end

--- Returns whether or not the Playable has a delay.
---@generic U
---@param playable U The Playable used by this operation.
---@return boolean ret True if the playable is delayed, false otherwise.
function PlayableExtensions_Static.IsDelayed(playable) end

--- Sets the Playable lead time in seconds.
---@generic U
---@param playable U The Playable used by this operation.
---@param value number The new lead time in seconds.
function PlayableExtensions_Static.SetLeadTime(playable, value) end

--- Returns the Playable lead time in seconds.
---@generic U
---@param playable U The Playable used by this operation.
---@return number ret 
function PlayableExtensions_Static.GetLeadTime(playable) end

--- Returns the propagation mode for the multi-output playable.
---@generic U
---@param playable U 
---@return UnityEngine.Playables.PlayableTraversalMode ret Traversal mode (Mix or Passthrough).
function PlayableExtensions_Static.GetTraversalMode(playable) end

--- Sets the propagation mode of PrepareFrame and ProcessFrame for the multi-output playable.
---@generic U
---@param playable U The Playable used by this operation.
---@param mode UnityEngine.Playables.PlayableTraversalMode The new traversal mode.
function PlayableExtensions_Static.SetTraversalMode(playable, mode) end


---@type Static.UnityEngine.Playables.PlayableExtensions
UnityEngine.Playables.PlayableExtensions = PlayableExtensions_Static

--------------------------------------------------------------------------------

--- Use the PlayableGraph to manage Playable creations and destructions.
---@class UnityEngine.Playables.PlayableGraph
local PlayableGraph_Impl = {}

--- Returns the Playable with no output connections at the given index.
---@param index integer The index of the root Playable.
---@return UnityEngine.Playables.Playable ret 
function PlayableGraph_Impl:GetRootPlayable(index) end

--- Connects two Playable instances.
---@generic U
---@generic V
---@param source U The source playable or its handle.
---@param sourceOutputPort integer The port used in the source playable.
---@param destination V The destination playable or its handle.
---@param destinationInputPort integer The port used in the destination playable. If set to -1, a new port is created and connected.
---@return boolean ret Returns true if connection is successful.
function PlayableGraph_Impl:Connect(source, sourceOutputPort, destination, destinationInputPort) end

--- Disconnects the Playable. The connections determine the topology of the PlayableGraph and how it is evaluated.
---@generic U
---@param input U The source playabe or its handle.
---@param inputPort integer The port used in the source playable.
function PlayableGraph_Impl:Disconnect(input, inputPort) end

--- Destroys the Playable.
---@generic U
---@param playable U The playable to destroy.
function PlayableGraph_Impl:DestroyPlayable(playable) end

--- Destroys the Playable and all its inputs, recursively.
---@generic U
---@param playable U The Playable to destroy.
function PlayableGraph_Impl:DestroySubgraph(playable) end

--- Destroys the PlayableOutput.
---@generic U
---@param output U The output to destroy.
function PlayableGraph_Impl:DestroyOutput(output) end

--- Get the number of PlayableOutput of the requested type in the graph.
---@generic T
---@return integer ret The number of PlayableOutput of the same type T in the graph.
function PlayableGraph_Impl:GetOutputCountByType() end

--- Get PlayableOutput at the given index in the graph.
---@param index integer The output index.
---@return UnityEngine.Playables.PlayableOutput ret The PlayableOutput at this given index, otherwise null.
function PlayableGraph_Impl:GetOutput(index) end

--- Get PlayableOutput of the requested type at the given index in the graph.
---@generic T
---@param index integer The output index.
---@return UnityEngine.Playables.PlayableOutput ret The PlayableOutput at the given index among all the PlayableOutput of the same type T.
function PlayableGraph_Impl:GetOutputByType(index) end

--- Evaluates all the PlayableOutputs in the graph, and updates all the connected Playables in the graph.
function PlayableGraph_Impl:Evaluate() end

--- Destroys the graph.
function PlayableGraph_Impl:Destroy() end

--- Returns true if the PlayableGraph has been properly constructed using PlayableGraph.CreateGraph and is not deleted.
---@return boolean ret A boolean indicating if the graph is invalid or not.
function PlayableGraph_Impl:IsValid() end

--- Indicates that a graph is presently running.
---@return boolean ret A boolean indicating if the graph is playing or not.
function PlayableGraph_Impl:IsPlaying() end

--- Indicates that a graph has completed its operations.
---@return boolean ret A boolean indicating if the graph is done playing or not.
function PlayableGraph_Impl:IsDone() end

--- Plays the graph.
function PlayableGraph_Impl:Play() end

--- Stops the graph, if it is playing.
function PlayableGraph_Impl:Stop() end

--- Evaluates all the PlayableOutputs in the graph, and updates all the connected Playables in the graph.
---@param deltaTime number The time in seconds by which to advance each Playable in the graph.
function PlayableGraph_Impl:Evaluate(deltaTime) end

--- Returns how time is incremented when playing back.
---@return UnityEngine.Playables.DirectorUpdateMode ret 
function PlayableGraph_Impl:GetTimeUpdateMode() end

--- Changes how time is incremented when playing back.
---@param value UnityEngine.Playables.DirectorUpdateMode The new DirectorUpdateMode.
function PlayableGraph_Impl:SetTimeUpdateMode(value) end

--- Returns the table used by the graph to resolve ExposedReferences.
---@return UnityEngine.IExposedPropertyTable ret 
function PlayableGraph_Impl:GetResolver() end

--- Changes the table used by the graph to resolve ExposedReferences.
---@param value UnityEngine.IExposedPropertyTable 
function PlayableGraph_Impl:SetResolver(value) end

--- Returns the number of Playable owned by the Graph.
---@return integer ret 
function PlayableGraph_Impl:GetPlayableCount() end

--- Returns the number of Playable owned by the Graph that have no connected outputs.
---@return integer ret 
function PlayableGraph_Impl:GetRootPlayableCount() end

--- Returns the number of PlayableOutput in the graph.
---@return integer ret The number of PlayableOutput in the graph.
function PlayableGraph_Impl:GetOutputCount() end

--- Returns the name of the PlayableGraph.
---@return string ret 
function PlayableGraph_Impl:GetEditorName() end

---@class Static.UnityEngine.Playables.PlayableGraph
---@overload fun(): UnityEngine.Playables.PlayableGraph (Constructor)
local PlayableGraph_Static = {}

--- Creates a PlayableGraph.
---@return UnityEngine.Playables.PlayableGraph ret The newly created PlayableGraph.
function PlayableGraph_Static.Create() end

--- Creates a PlayableGraph.
---@param name string The name of the graph.
---@return UnityEngine.Playables.PlayableGraph ret The newly created PlayableGraph.
function PlayableGraph_Static.Create(name) end


---@type Static.UnityEngine.Playables.PlayableGraph
UnityEngine.Playables.PlayableGraph = PlayableGraph_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Playables.PlayableHandle : System.IEquatable<UnityEngine.Playables.PlayableHandle>
local PlayableHandle_Impl = {}

---@param p System.Object 
---@return boolean ret 
function PlayableHandle_Impl:Equals(p) end

---@param other UnityEngine.Playables.PlayableHandle 
---@return boolean ret 
function PlayableHandle_Impl:Equals(other) end

---@return integer ret 
function PlayableHandle_Impl:GetHashCode() end

---@class Static.UnityEngine.Playables.PlayableHandle
---@field Null UnityEngine.Playables.PlayableHandle
---@overload fun(): UnityEngine.Playables.PlayableHandle (Constructor)
local PlayableHandle_Static = {}


---@type Static.UnityEngine.Playables.PlayableHandle
UnityEngine.Playables.PlayableHandle = PlayableHandle_Static

--------------------------------------------------------------------------------

--- See: Playables.IPlayableOutput.
---@class UnityEngine.Playables.PlayableOutput : UnityEngine.Playables.IPlayableOutput, System.IEquatable<UnityEngine.Playables.PlayableOutput>
local PlayableOutput_Impl = {}

---@return UnityEngine.Playables.PlayableOutputHandle ret 
function PlayableOutput_Impl:GetHandle() end

---@generic T
---@return boolean ret 
function PlayableOutput_Impl:IsPlayableOutputOfType() end

---@return System.Type ret 
function PlayableOutput_Impl:GetPlayableOutputType() end

---@param other UnityEngine.Playables.PlayableOutput 
---@return boolean ret 
function PlayableOutput_Impl:Equals(other) end

---@class Static.UnityEngine.Playables.PlayableOutput
--- Returns an invalid PlayableOutput.
---@field Null UnityEngine.Playables.PlayableOutput
---@overload fun(): UnityEngine.Playables.PlayableOutput (Constructor)
local PlayableOutput_Static = {}


---@type Static.UnityEngine.Playables.PlayableOutput
UnityEngine.Playables.PlayableOutput = PlayableOutput_Static

--------------------------------------------------------------------------------

--- Extensions for all the types that implements IPlayableOutput.
---@class UnityEngine.Playables.PlayableOutputExtensions
local PlayableOutputExtensions_Impl = {}

---@class Static.UnityEngine.Playables.PlayableOutputExtensions
local PlayableOutputExtensions_Static = {}

--- Returns true if the PlayableOutput is null, false otherwise.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@return boolean ret 
function PlayableOutputExtensions_Static.IsOutputNull(output) end

---@generic U
---@param output U The PlayableOutput used by this operation.
---@return boolean ret True if the PlayableOutput has not yet been destroyed and false otherwise.
function PlayableOutputExtensions_Static.IsOutputValid(output) end

---@generic U
---@param output U 
---@return UnityEngine.Object ret 
function PlayableOutputExtensions_Static.GetReferenceObject(output) end

--- Sets the bound object to a new value. Used to associate an output to an object (Track asset in case of Timeline).
---@generic U
---@param output U The PlayableOutput used by this operation.
---@param value UnityEngine.Object The new reference object value.
function PlayableOutputExtensions_Static.SetReferenceObject(output, value) end

--- Returns the opaque user data. This is the same value as the last last argument of ProcessFrame.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@return UnityEngine.Object ret The user data.
function PlayableOutputExtensions_Static.GetUserData(output) end

--- Sets the opaque user data. This same data is passed as the last argument to ProcessFrame.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@param value UnityEngine.Object The new user data.
function PlayableOutputExtensions_Static.SetUserData(output, value) end

--- Returns the source playable.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@return UnityEngine.Playables.Playable ret The source playable.
function PlayableOutputExtensions_Static.GetSourcePlayable(output) end

--- Sets which playable that computes the output.
---@generic U
---@generic V
---@param output U The PlayableOutput used by this operation.
---@param value V The new source Playable.
function PlayableOutputExtensions_Static.SetSourcePlayable(output, value) end

--- Sets which playable that computes the output and which sub-tree index.
---@generic U
---@generic V
---@param output U The PlayableOutput used by this operation.
---@param value V The new source Playable.
---@param port integer The new output port value.
function PlayableOutputExtensions_Static.SetSourcePlayable(output, value, port) end

--- Returns the source playable's output connection index.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@return integer ret The output port.
function PlayableOutputExtensions_Static.GetSourceOutputPort(output) end

--- Returns the weight of the connection from the PlayableOutput to the source playable.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@return number ret The weight of the connection to the source playable.
function PlayableOutputExtensions_Static.GetWeight(output) end

--- Sets the weight of the connection from the PlayableOutput to the source playable.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@param value number The new weight.
function PlayableOutputExtensions_Static.SetWeight(output, value) end

--- Queues a notification to be sent through the Playable system.
---@generic U
---@param output U The output sending the notification.
---@param origin UnityEngine.Playables.Playable The originating playable of the notification.
---@param notification UnityEngine.Playables.INotification The notification to be sent.
---@param context? System.Object Extra information about the state when the notification was fired.
function PlayableOutputExtensions_Static.PushNotification(output, origin, notification, context) end

--- Retrieves the list of notification receivers currently registered on the output.
---@generic U
---@param output U The output holding the receivers.
---@return UnityEngine.Playables.INotificationReceiver[] ret Returns the list of registered receivers.
function PlayableOutputExtensions_Static.GetNotificationReceivers(output) end

--- Registers a new receiver that listens for notifications.
---@generic U
---@param output U The target output.
---@param receiver UnityEngine.Playables.INotificationReceiver The receiver to register.
function PlayableOutputExtensions_Static.AddNotificationReceiver(output, receiver) end

--- Unregisters a receiver on the output.
---@generic U
---@param output U The target output.
---@param receiver UnityEngine.Playables.INotificationReceiver The receiver to unregister.
function PlayableOutputExtensions_Static.RemoveNotificationReceiver(output, receiver) end

---@generic U
---@param output U 
---@return integer ret 
function PlayableOutputExtensions_Static.GetSourceInputPort(output) end

---@generic U
---@param output U 
---@param value integer 
function PlayableOutputExtensions_Static.SetSourceInputPort(output, value) end

--- Sets the source playable's output connection index. For playables with multiple outputs, this determines which sub-branch of the source playable generates this output.
---@generic U
---@param output U The PlayableOutput used by this operation.
---@param value integer The new output port value.
function PlayableOutputExtensions_Static.SetSourceOutputPort(output, value) end


---@type Static.UnityEngine.Playables.PlayableOutputExtensions
UnityEngine.Playables.PlayableOutputExtensions = PlayableOutputExtensions_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Playables.PlayableOutputHandle : System.IEquatable<UnityEngine.Playables.PlayableOutputHandle>
local PlayableOutputHandle_Impl = {}

---@return integer ret 
function PlayableOutputHandle_Impl:GetHashCode() end

---@param p System.Object 
---@return boolean ret 
function PlayableOutputHandle_Impl:Equals(p) end

---@param other UnityEngine.Playables.PlayableOutputHandle 
---@return boolean ret 
function PlayableOutputHandle_Impl:Equals(other) end

---@class Static.UnityEngine.Playables.PlayableOutputHandle
---@field Null UnityEngine.Playables.PlayableOutputHandle
---@overload fun(): UnityEngine.Playables.PlayableOutputHandle (Constructor)
local PlayableOutputHandle_Static = {}


---@type Static.UnityEngine.Playables.PlayableOutputHandle
UnityEngine.Playables.PlayableOutputHandle = PlayableOutputHandle_Static

--------------------------------------------------------------------------------

--- A IPlayable implementation that contains a PlayableBehaviour for the PlayableGraph. PlayableBehaviour can be used to write custom Playable that implement their own PrepareFrame callback.
---@class UnityEngine.Playables.ScriptPlayable<T> : IEquatable<UnityEngine.Playables.ScriptPlayable>, UnityEngine.Playables.IPlayable
local ScriptPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function ScriptPlayable_Impl:GetHandle() end

---@return T ret 
function ScriptPlayable_Impl:GetBehaviour() end

---@param other UnityEngine.Playables.ScriptPlayable 
---@return boolean ret 
function ScriptPlayable_Impl:Equals(other) end

---@class Static.UnityEngine.Playables.ScriptPlayable
---@field Null UnityEngine.Playables.ScriptPlayable
---@overload fun(): UnityEngine.Playables.ScriptPlayable (Constructor)
local ScriptPlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param inputCount? integer 
---@return UnityEngine.Playables.ScriptPlayable ret 
function ScriptPlayable_Static.Create(graph, inputCount) end

---@param graph UnityEngine.Playables.PlayableGraph 
---@param template T 
---@param inputCount? integer 
---@return UnityEngine.Playables.ScriptPlayable ret 
function ScriptPlayable_Static.Create(graph, template, inputCount) end


---@type Static.UnityEngine.Playables.ScriptPlayable
UnityEngine.Playables.ScriptPlayable = ScriptPlayable_Static

--------------------------------------------------------------------------------

--- A PlayableBinding that contains information representing a ScriptingPlayableOutput.
---@class UnityEngine.Playables.ScriptPlayableBinding
local ScriptPlayableBinding_Impl = {}

---@class Static.UnityEngine.Playables.ScriptPlayableBinding
local ScriptPlayableBinding_Static = {}

--- Creates a PlayableBinding that contains information representing a ScriptPlayableOutput.
---@param name string The name of the ScriptPlayableOutput.
---@param key UnityEngine.Object A reference to a UnityEngine.Object that acts as a key for this binding.
---@param type System.Type The type of object that will be bound to the ScriptPlayableOutput.
---@return UnityEngine.Playables.PlayableBinding ret Returns a PlayableBinding that contains information that is used to create a ScriptPlayableOutput.
function ScriptPlayableBinding_Static.Create(name, key, type) end


---@type Static.UnityEngine.Playables.ScriptPlayableBinding
UnityEngine.Playables.ScriptPlayableBinding = ScriptPlayableBinding_Static

--------------------------------------------------------------------------------

--- A IPlayableOutput implementation that contains a script output for the a PlayableGraph.
---@class UnityEngine.Playables.ScriptPlayableOutput : UnityEngine.Playables.IPlayableOutput
local ScriptPlayableOutput_Impl = {}

---@return UnityEngine.Playables.PlayableOutputHandle ret 
function ScriptPlayableOutput_Impl:GetHandle() end

---@class Static.UnityEngine.Playables.ScriptPlayableOutput
--- Returns an invalid ScriptPlayableOutput.
---@field Null UnityEngine.Playables.ScriptPlayableOutput
---@overload fun(): UnityEngine.Playables.ScriptPlayableOutput (Constructor)
local ScriptPlayableOutput_Static = {}

--- Creates a new ScriptPlayableOutput in the associated PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the ScriptPlayableOutput.
---@param name string The name of this ScriptPlayableOutput.
---@return UnityEngine.Playables.ScriptPlayableOutput ret The created ScriptPlayableOutput.
function ScriptPlayableOutput_Static.Create(graph, name) end


---@type Static.UnityEngine.Playables.ScriptPlayableOutput
UnityEngine.Playables.ScriptPlayableOutput = ScriptPlayableOutput_Static

--------------------------------------------------------------------------------

--- Instantiates a PlayableAsset and controls playback of Playable objects.
---@class UnityEngine.Playables.PlayableDirector : UnityEngine.Behaviour, UnityEngine.IExposedPropertyTable
--- The current playing state of the component. (Read Only)
---@field state UnityEngine.Playables.PlayState
--- Controls how the time is incremented when it goes beyond the duration of the playable.
---@field extrapolationMode UnityEngine.Playables.DirectorWrapMode
--- The PlayableAsset that is used to instantiate a playable for playback.
---@field playableAsset UnityEngine.Playables.PlayableAsset
--- The PlayableGraph created by the PlayableDirector.
---@field playableGraph UnityEngine.Playables.PlayableGraph
--- Whether the playable asset will start playing back as soon as the component awakes.
---@field playOnAwake boolean
--- Controls how time is incremented when playing back.
---@field timeUpdateMode UnityEngine.Playables.DirectorUpdateMode
--- The component's current time. This value is incremented according to the PlayableDirector.timeUpdateMode when it is playing. You can also change this value manually.
---@field time number
--- The time at which the Playable should start when first played.
---@field initialTime number
--- The duration of the Playable in seconds.
---@field duration number
local PlayableDirector_Impl = {}

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Impl:played(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Impl:paused(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Impl:stopped(action, callback) end

--- Tells the PlayableDirector to evaluate it's PlayableGraph on the next update.
function PlayableDirector_Impl:DeferredEvaluate() end

--- Instatiates a Playable using the provided PlayableAsset and starts playback.
---@param asset UnityEngine.Playables.PlayableAsset An asset to instantiate a playable from.
function PlayableDirector_Impl:Play(asset) end

--- Instatiates a Playable using the provided PlayableAsset and starts playback.
---@param asset UnityEngine.Playables.PlayableAsset An asset to instantiate a playable from.
---@param mode UnityEngine.Playables.DirectorWrapMode What to do when the time passes the duration of the playable.
function PlayableDirector_Impl:Play(asset, mode) end

--- Sets the binding of a reference object from a PlayableBinding.
---@param key UnityEngine.Object The source object in the PlayableBinding.
---@param value UnityEngine.Object The object to bind to the key.
function PlayableDirector_Impl:SetGenericBinding(key, value) end

--- Evaluates the currently playing Playable at the current time.
function PlayableDirector_Impl:Evaluate() end

--- Instatiates a Playable using the provided PlayableAsset and starts playback.
function PlayableDirector_Impl:Play() end

--- Stops playback of the current Playable and destroys the corresponding graph.
function PlayableDirector_Impl:Stop() end

--- Pauses playback of the currently running playable.
function PlayableDirector_Impl:Pause() end

--- Resume playing a paused playable.
function PlayableDirector_Impl:Resume() end

--- Discards the existing PlayableGraph and creates a new instance.
function PlayableDirector_Impl:RebuildGraph() end

--- Clears an exposed reference value.
---@param id UnityEngine.PropertyName Identifier of the ExposedReference.
function PlayableDirector_Impl:ClearReferenceValue(id) end

--- Sets an ExposedReference value.
---@param id UnityEngine.PropertyName Identifier of the ExposedReference.
---@param value UnityEngine.Object The object to bind to set the reference value to.
function PlayableDirector_Impl:SetReferenceValue(id, value) end

--- Retreives an ExposedReference binding.
---@param id UnityEngine.PropertyName Identifier of the ExposedReference.
---@return UnityEngine.Object ret 
---@return boolean idValid (Out) Whether the reference was found.
function PlayableDirector_Impl:GetReferenceValue(id) end

--- Returns a binding to a reference object.
---@param key UnityEngine.Object The object that acts as a key.
---@return UnityEngine.Object ret 
function PlayableDirector_Impl:GetGenericBinding(key) end

--- Clears the binding of a reference object.
---@param key UnityEngine.Object The source object in the PlayableBinding.
function PlayableDirector_Impl:ClearGenericBinding(key) end

--- Rebinds each PlayableOutput of the PlayableGraph.
function PlayableDirector_Impl:RebindPlayableGraphOutputs() end

---@class Static.UnityEngine.Playables.PlayableDirector
---@overload fun(): UnityEngine.Playables.PlayableDirector (Constructor)
local PlayableDirector_Static = {}

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Static.played(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Static.paused(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun()
function PlayableDirector_Static.stopped(action, callback) end


---@type Static.UnityEngine.Playables.PlayableDirector
UnityEngine.Playables.PlayableDirector = PlayableDirector_Static

--------------------------------------------------------------------------------

