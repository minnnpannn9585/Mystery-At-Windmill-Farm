--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.Animations
UnityEngine.Animations = {}

---@enum UnityEngine.Animations.JobMethodIndex
local JobMethodIndex_Enum = {
    ProcessRootMotionMethodIndex = 0,
    ProcessAnimationMethodIndex = 1,
    MethodIndexCount = 2,
}
UnityEngine.Animations.JobMethodIndex = JobMethodIndex_Enum

--- Constrains the orientation of an object relative to the position of one or more source objects, such that the object is facing the average position of the sources.
---@enum UnityEngine.Animations.AimConstraint.WorldUpType
local WorldUpType_Enum = {
    --- Uses and defines the world up vector as the Unity Scene up vector (the Y axis).
    SceneUp = 0,
    --- Uses and defines the world up vector as a vector from the constrained object, in the direction of the up object.
    ObjectUp = 1,
    --- Uses and defines the world up vector as relative to the local space of the object.
    ObjectRotationUp = 2,
    --- Uses and defines the world up vector as a vector specified by the user.
    Vector = 3,
    --- Neither defines nor uses a world up vector.
    None = 4,
}
UnityEngine.Animations.WorldUpType = WorldUpType_Enum

---@enum UnityEngine.Animations.AnimatorBindingsVersion
local AnimatorBindingsVersion_Enum = {
    kInvalidNotNative = 0,
    kInvalidUnresolved = 1,
    kValidMinVersion = 2,
}
UnityEngine.Animations.AnimatorBindingsVersion = AnimatorBindingsVersion_Enum

---@enum UnityEngine.Animations.BindType
local BindType_Enum = {
    Unbound = 0,
    Float = 5,
    Bool = 6,
    GameObjectActive = 7,
    ObjectReference = 9,
    Int = 10,
    DiscreetInt = 11,
}
UnityEngine.Animations.BindType = BindType_Enum

--- The type of custom stream property to create using BindCustomStreamProperty
---@enum UnityEngine.Animations.CustomStreamPropertyType
local CustomStreamPropertyType_Enum = {
    --- A float value.
    Float = 5,
    --- A boolean value.
    Bool = 6,
    --- An integer value.
    Int = 10,
}
UnityEngine.Animations.CustomStreamPropertyType = CustomStreamPropertyType_Enum

--- Represents the axes used in 3D space.
---@enum UnityEngine.Animations.Axis
local Axis_Enum = {
    --- Represents the case when no axis is specified.
    None = 0,
    --- Represents the X axis.
    X = 1,
    --- Represents the Y axis.
    Y = 2,
    --- Represents the Z axis.
    Z = 4,
}
UnityEngine.Animations.Axis = Axis_Enum

--- A PlayableBinding that contains information representing an AnimationPlayableOutput.
---@class UnityEngine.Animations.AnimationPlayableBinding
local AnimationPlayableBinding_Impl = {}

---@class Static.UnityEngine.Animations.AnimationPlayableBinding
local AnimationPlayableBinding_Static = {}

--- Creates a PlayableBinding that contains information representing an AnimationPlayableOutput.
---@param name string The name of the AnimationPlayableOutput.
---@param key UnityEngine.Object A reference to a UnityEngine.Object that acts as a key for this binding.
---@return UnityEngine.Playables.PlayableBinding ret Returns a PlayableBinding that contains information that is used to create an AnimationPlayableOutput.
function AnimationPlayableBinding_Static.Create(name, key) end


---@type Static.UnityEngine.Animations.AnimationPlayableBinding
UnityEngine.Animations.AnimationPlayableBinding = AnimationPlayableBinding_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.ProcessAnimationJobStruct<T>
local ProcessAnimationJobStruct_Impl = {}

---@class Static.UnityEngine.Animations.ProcessAnimationJobStruct
---@overload fun(): UnityEngine.Animations.ProcessAnimationJobStruct (Constructor)
local ProcessAnimationJobStruct_Static = {}

---@return System.IntPtr ret 
function ProcessAnimationJobStruct_Static.GetJobReflectionData() end

---@param data T 
---@param animationStreamPtr System.IntPtr 
---@param methodIndex System.IntPtr 
---@param ranges Unity.Jobs.LowLevel.Unsafe.JobRanges 
---@param jobIndex integer 
---@return T data (Ref) 
---@return Unity.Jobs.LowLevel.Unsafe.JobRanges ranges (Ref) 
function ProcessAnimationJobStruct_Static.Execute(data, animationStreamPtr, methodIndex, ranges, jobIndex) end


---@type Static.UnityEngine.Animations.ProcessAnimationJobStruct
UnityEngine.Animations.ProcessAnimationJobStruct = ProcessAnimationJobStruct_Static

--------------------------------------------------------------------------------

--- Constrains the orientation of an object relative to the position of one or more source objects, such that the object is facing the average position of the sources.
---@class UnityEngine.Animations.AimConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offset and rotation at rest.
---@field locked boolean
--- The rotation used when the sources have a total weight of 0.
---@field rotationAtRest UnityEngine.Vector3
--- Represents an offset from the constrained orientation.
---@field rotationOffset UnityEngine.Vector3
--- The axes affected by the AimConstraint.
---@field rotationAxis UnityEngine.Animations.Axis
--- The axis towards which the constrained object orients.
---@field aimVector UnityEngine.Vector3
--- The up vector.
---@field upVector UnityEngine.Vector3
--- The world up Vector used when the world up type is AimConstraint.WorldUpType.Vector or AimConstraint.WorldUpType.ObjectRotationUp.
---@field worldUpVector UnityEngine.Vector3
--- The world up object, used to calculate the world up vector when the world up Type is AimConstraint.WorldUpType.ObjectUp or AimConstraint.WorldUpType.ObjectRotationUp.
---@field worldUpObject UnityEngine.Transform
--- The type of the world up vector.
---@field worldUpType UnityEngine.Animations.AimConstraint.WorldUpType
--- The number of sources set on the component (read-only).
---@field sourceCount integer
local AimConstraint_Impl = {}

---@param sources System.Collections.Generic.List 
function AimConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function AimConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function AimConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function AimConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret The source object and its weight.
function AimConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function AimConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

--- A Playable that controls an AnimationClip.
---@class UnityEngine.Animations.AnimationClipPlayable : System.IEquatable<UnityEngine.Animations.AnimationClipPlayable>, UnityEngine.Playables.IPlayable
local AnimationClipPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationClipPlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationClipPlayable 
---@return boolean ret 
function AnimationClipPlayable_Impl:Equals(other) end

--- Returns the AnimationClip stored in the AnimationClipPlayable.
---@return UnityEngine.AnimationClip ret 
function AnimationClipPlayable_Impl:GetAnimationClip() end

--- Returns the state of the ApplyFootIK flag.
---@return boolean ret 
function AnimationClipPlayable_Impl:GetApplyFootIK() end

--- Sets the value of the ApplyFootIK flag.
---@param value boolean The new value of the ApplyFootIK flag.
function AnimationClipPlayable_Impl:SetApplyFootIK(value) end

--- Returns the state of the ApplyPlayableIK flag.
---@return boolean ret 
function AnimationClipPlayable_Impl:GetApplyPlayableIK() end

--- Requests OnAnimatorIK to be called on the animated GameObject.
---@param value boolean 
function AnimationClipPlayable_Impl:SetApplyPlayableIK(value) end

---@class Static.UnityEngine.Animations.AnimationClipPlayable
---@overload fun(): UnityEngine.Animations.AnimationClipPlayable (Constructor)
local AnimationClipPlayable_Static = {}

--- Creates an AnimationClipPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph object that will own the AnimationClipPlayable.
---@param clip UnityEngine.AnimationClip The AnimationClip that will be added in the PlayableGraph.
---@return UnityEngine.Animations.AnimationClipPlayable ret A AnimationClipPlayable linked to the PlayableGraph.
function AnimationClipPlayable_Static.Create(graph, clip) end


---@type Static.UnityEngine.Animations.AnimationClipPlayable
UnityEngine.Animations.AnimationClipPlayable = AnimationClipPlayable_Static

--------------------------------------------------------------------------------

--- The humanoid stream of animation data passed from one Playable to another.
---@class UnityEngine.Animations.AnimationHumanStream
--- Returns true if the stream is valid; false otherwise. (Read Only)
---@field isValid boolean
--- The scale of the Avatar. (Read Only)
---@field humanScale number
--- The left foot height from the floor. (Read Only)
---@field leftFootHeight number
--- The right foot height from the floor. (Read Only)
---@field rightFootHeight number
--- The position of the body center of mass relative to the root.
---@field bodyLocalPosition UnityEngine.Vector3
--- The rotation of the body center of mass relative to the root.
---@field bodyLocalRotation UnityEngine.Quaternion
--- The position of the body center of mass in world space.
---@field bodyPosition UnityEngine.Vector3
--- The rotation of the body center of mass in world space.
---@field bodyRotation UnityEngine.Quaternion
--- The left foot velocity from the last evaluated frame. (Read Only)
---@field leftFootVelocity UnityEngine.Vector3
--- The right foot velocity from the last evaluated frame. (Read Only)
---@field rightFootVelocity UnityEngine.Vector3
local AnimationHumanStream_Impl = {}

--- Returns the muscle value.
---@param muscle UnityEngine.Animations.MuscleHandle The Muscle that is queried.
---@return number ret The muscle value.
function AnimationHumanStream_Impl:GetMuscle(muscle) end

--- Sets the muscle value.
---@param muscle UnityEngine.Animations.MuscleHandle The Muscle that is queried.
---@param value number The muscle value.
function AnimationHumanStream_Impl:SetMuscle(muscle, value) end

--- Reset the current pose to the stance pose (T Pose).
function AnimationHumanStream_Impl:ResetToStancePose() end

--- Returns the position of this IK goal in world space computed from the stream current pose.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Vector3 ret The position of this IK goal.
function AnimationHumanStream_Impl:GetGoalPositionFromPose(index) end

--- Returns the rotation of this IK goal in world space computed from the stream current pose.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Quaternion ret The rotation of this IK goal.
function AnimationHumanStream_Impl:GetGoalRotationFromPose(index) end

--- Returns the position of this IK goal relative to the root.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Vector3 ret The position of this IK goal.
function AnimationHumanStream_Impl:GetGoalLocalPosition(index) end

--- Sets the position of this IK goal relative to the root.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param pos UnityEngine.Vector3 The position of this IK goal.
function AnimationHumanStream_Impl:SetGoalLocalPosition(index, pos) end

--- Returns the rotation of this IK goal relative to the root.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Quaternion ret The rotation of this IK goal.
function AnimationHumanStream_Impl:GetGoalLocalRotation(index) end

--- Sets the rotation of this IK goal relative to the root.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param rot UnityEngine.Quaternion The rotation of this IK goal.
function AnimationHumanStream_Impl:SetGoalLocalRotation(index, rot) end

--- Returns the position of this IK goal in world space.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Vector3 ret The position of this IK goal.
function AnimationHumanStream_Impl:GetGoalPosition(index) end

--- Sets the position of this IK goal in world space.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param pos UnityEngine.Vector3 The position of this IK goal.
function AnimationHumanStream_Impl:SetGoalPosition(index, pos) end

--- Returns the rotation of this IK goal in world space.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return UnityEngine.Quaternion ret The rotation of this IK goal.
function AnimationHumanStream_Impl:GetGoalRotation(index) end

--- Sets the rotation of this IK goal in world space.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param rot UnityEngine.Quaternion The rotation of this IK goal.
function AnimationHumanStream_Impl:SetGoalRotation(index, rot) end

--- Sets the position weight of the IK goal.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param value number The position weight of the IK goal.
function AnimationHumanStream_Impl:SetGoalWeightPosition(index, value) end

--- Sets the rotation weight of the IK goal.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@param value number The rotation weight of the IK goal.
function AnimationHumanStream_Impl:SetGoalWeightRotation(index, value) end

--- Returns the position weight of the IK goal.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return number ret The position weight of the IK goal.
function AnimationHumanStream_Impl:GetGoalWeightPosition(index) end

--- Returns the rotation weight of the IK goal.
---@param index UnityEngine.AvatarIKGoal The AvatarIKGoal that is queried.
---@return number ret The rotation weight of the IK goal.
function AnimationHumanStream_Impl:GetGoalWeightRotation(index) end

--- Returns the position of this IK Hint in world space.
---@param index UnityEngine.AvatarIKHint The AvatarIKHint that is queried.
---@return UnityEngine.Vector3 ret The position of this IK Hint.
function AnimationHumanStream_Impl:GetHintPosition(index) end

--- Sets the position of this IK hint in world space.
---@param index UnityEngine.AvatarIKHint The AvatarIKHint that is queried.
---@param pos UnityEngine.Vector3 The position of this IK hint.
function AnimationHumanStream_Impl:SetHintPosition(index, pos) end

--- Sets the position weight of the IK Hint.
---@param index UnityEngine.AvatarIKHint The AvatarIKHint that is queried.
---@param value number The position weight of the IK Hint.
function AnimationHumanStream_Impl:SetHintWeightPosition(index, value) end

--- Returns the position weight of the IK Hint.
---@param index UnityEngine.AvatarIKHint The AvatarIKHint that is queried.
---@return number ret The position weight of the IK Hint.
function AnimationHumanStream_Impl:GetHintWeightPosition(index) end

--- Sets the look at position in world space.
---@param lookAtPosition UnityEngine.Vector3 The look at position.
function AnimationHumanStream_Impl:SetLookAtPosition(lookAtPosition) end

--- Sets the LookAt clamp weight.
---@param weight number The LookAt clamp weight.
function AnimationHumanStream_Impl:SetLookAtClampWeight(weight) end

--- Sets the LookAt body weight.
---@param weight number The LookAt body weight.
function AnimationHumanStream_Impl:SetLookAtBodyWeight(weight) end

--- Sets the LookAt head weight.
---@param weight number The LookAt head weight.
function AnimationHumanStream_Impl:SetLookAtHeadWeight(weight) end

--- Sets the LookAt eyes weight.
---@param weight number The LookAt eyes weight.
function AnimationHumanStream_Impl:SetLookAtEyesWeight(weight) end

--- Execute the IK solver.
function AnimationHumanStream_Impl:SolveIK() end

---@class Static.UnityEngine.Animations.AnimationHumanStream
---@overload fun(): UnityEngine.Animations.AnimationHumanStream (Constructor)
local AnimationHumanStream_Static = {}


---@type Static.UnityEngine.Animations.AnimationHumanStream
UnityEngine.Animations.AnimationHumanStream = AnimationHumanStream_Static

--------------------------------------------------------------------------------

--- An implementation of IPlayable that controls an animation layer mixer.
---@class UnityEngine.Animations.AnimationLayerMixerPlayable : System.IEquatable<UnityEngine.Animations.AnimationLayerMixerPlayable>, UnityEngine.Playables.IPlayable
local AnimationLayerMixerPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationLayerMixerPlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationLayerMixerPlayable 
---@return boolean ret 
function AnimationLayerMixerPlayable_Impl:Equals(other) end

--- Returns true if the layer is additive, false otherwise.
---@param layerIndex integer The layer index.
---@return boolean ret True if the layer is additive, false otherwise.
function AnimationLayerMixerPlayable_Impl:IsLayerAdditive(layerIndex) end

--- Specifies whether a layer is additive or not. Additive layers blend with previous layers.
---@param layerIndex integer The layer index.
---@param value boolean Whether the layer is additive or not. Set to true for an additive blend, or false for a regular blend.
function AnimationLayerMixerPlayable_Impl:SetLayerAdditive(layerIndex, value) end

--- Sets the mask for the current layer.
---@param layerIndex integer The layer index.
---@param mask UnityEngine.AvatarMask The AvatarMask used to create the new LayerMask.
function AnimationLayerMixerPlayable_Impl:SetLayerMaskFromAvatarMask(layerIndex, mask) end

---@class Static.UnityEngine.Animations.AnimationLayerMixerPlayable
--- Returns an invalid AnimationLayerMixerPlayable.
---@field Null UnityEngine.Animations.AnimationLayerMixerPlayable
---@overload fun(): UnityEngine.Animations.AnimationLayerMixerPlayable (Constructor)
local AnimationLayerMixerPlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param inputCount? integer 
---@return UnityEngine.Animations.AnimationLayerMixerPlayable ret 
function AnimationLayerMixerPlayable_Static.Create(graph, inputCount) end

--- Creates an AnimationLayerMixerPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the new AnimationLayerMixerPlayable.
---@param inputCount integer The number of layers.
---@param singleLayerOptimization boolean This optimization automatically sets the weight of the first animation layer to 1. Set to true If your layer mixer has a single animation layer and you want to bypass unnecessary weight calculations. This optimization is automatically set to false if your layer mixer has multiple animation layers.
---@return UnityEngine.Animations.AnimationLayerMixerPlayable ret A new AnimationLayerMixerPlayable linked to the PlayableGraph.
function AnimationLayerMixerPlayable_Static.Create(graph, inputCount, singleLayerOptimization) end


---@type Static.UnityEngine.Animations.AnimationLayerMixerPlayable
UnityEngine.Animations.AnimationLayerMixerPlayable = AnimationLayerMixerPlayable_Static

--------------------------------------------------------------------------------

--- An implementation of IPlayable that controls an animation mixer.
---@class UnityEngine.Animations.AnimationMixerPlayable : System.IEquatable<UnityEngine.Animations.AnimationMixerPlayable>, UnityEngine.Playables.IPlayable
local AnimationMixerPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationMixerPlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationMixerPlayable 
---@return boolean ret 
function AnimationMixerPlayable_Impl:Equals(other) end

---@class Static.UnityEngine.Animations.AnimationMixerPlayable
--- Returns an invalid AnimationMixerPlayable.
---@field Null UnityEngine.Animations.AnimationMixerPlayable
---@overload fun(): UnityEngine.Animations.AnimationMixerPlayable (Constructor)
local AnimationMixerPlayable_Static = {}

--- Creates an AnimationMixerPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the new AnimationMixerPlayable.
---@param inputCount integer The number of inputs that the mixer will update.
---@param normalizeWeights boolean NormalizeWeights is obsolete. It has no effect and will be removed.
---@return UnityEngine.Animations.AnimationMixerPlayable ret Returns a new AnimationMixerPlayable linked to the PlayableGraph.
function AnimationMixerPlayable_Static.Create(graph, inputCount, normalizeWeights) end

--- Creates an AnimationMixerPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the new AnimationMixerPlayable.
---@param inputCount? integer The number of inputs that the mixer will update.
---@return UnityEngine.Animations.AnimationMixerPlayable ret Returns a new AnimationMixerPlayable linked to the PlayableGraph.
function AnimationMixerPlayable_Static.Create(graph, inputCount) end


---@type Static.UnityEngine.Animations.AnimationMixerPlayable
UnityEngine.Animations.AnimationMixerPlayable = AnimationMixerPlayable_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.AnimationOffsetPlayable : System.IEquatable<UnityEngine.Animations.AnimationOffsetPlayable>, UnityEngine.Playables.IPlayable
local AnimationOffsetPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationOffsetPlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationOffsetPlayable 
---@return boolean ret 
function AnimationOffsetPlayable_Impl:Equals(other) end

---@return UnityEngine.Vector3 ret 
function AnimationOffsetPlayable_Impl:GetPosition() end

---@param value UnityEngine.Vector3 
function AnimationOffsetPlayable_Impl:SetPosition(value) end

---@return UnityEngine.Quaternion ret 
function AnimationOffsetPlayable_Impl:GetRotation() end

---@param value UnityEngine.Quaternion 
function AnimationOffsetPlayable_Impl:SetRotation(value) end

---@class Static.UnityEngine.Animations.AnimationOffsetPlayable
---@field Null UnityEngine.Animations.AnimationOffsetPlayable
---@overload fun(): UnityEngine.Animations.AnimationOffsetPlayable (Constructor)
local AnimationOffsetPlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param position UnityEngine.Vector3 
---@param rotation UnityEngine.Quaternion 
---@param inputCount integer 
---@return UnityEngine.Animations.AnimationOffsetPlayable ret 
function AnimationOffsetPlayable_Static.Create(graph, position, rotation, inputCount) end


---@type Static.UnityEngine.Animations.AnimationOffsetPlayable
UnityEngine.Animations.AnimationOffsetPlayable = AnimationOffsetPlayable_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.AnimationPlayableExtensions
local AnimationPlayableExtensions_Impl = {}

---@class Static.UnityEngine.Animations.AnimationPlayableExtensions
local AnimationPlayableExtensions_Static = {}

---@generic U
---@param playable U 
---@param clip UnityEngine.AnimationClip 
function AnimationPlayableExtensions_Static.SetAnimatedProperties(playable, clip) end


---@type Static.UnityEngine.Animations.AnimationPlayableExtensions
UnityEngine.Animations.AnimationPlayableExtensions = AnimationPlayableExtensions_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.AnimationPlayableGraphExtensions
local AnimationPlayableGraphExtensions_Impl = {}

--------------------------------------------------------------------------------

--- A IPlayableOutput implementation that connects the PlayableGraph to an Animator in the Scene.
---@class UnityEngine.Animations.AnimationPlayableOutput : UnityEngine.Playables.IPlayableOutput
local AnimationPlayableOutput_Impl = {}

---@return UnityEngine.Playables.PlayableOutputHandle ret 
function AnimationPlayableOutput_Impl:GetHandle() end

--- Returns the Animator that plays the animation graph.
---@return UnityEngine.Animator ret The targeted Animator.
function AnimationPlayableOutput_Impl:GetTarget() end

--- Sets the Animator that plays the animation graph.
---@param value UnityEngine.Animator The targeted Animator.
function AnimationPlayableOutput_Impl:SetTarget(value) end

---@class Static.UnityEngine.Animations.AnimationPlayableOutput
---@field Null UnityEngine.Animations.AnimationPlayableOutput
---@overload fun(): UnityEngine.Animations.AnimationPlayableOutput (Constructor)
local AnimationPlayableOutput_Static = {}

--- Creates an AnimationPlayableOutput in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the AnimationPlayableOutput.
---@param name string The name of the output.
---@param target UnityEngine.Animator The Animator that will process the PlayableGraph.
---@return UnityEngine.Animations.AnimationPlayableOutput ret A new AnimationPlayableOutput attached to the PlayableGraph.
function AnimationPlayableOutput_Static.Create(graph, name, target) end


---@type Static.UnityEngine.Animations.AnimationPlayableOutput
UnityEngine.Animations.AnimationPlayableOutput = AnimationPlayableOutput_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.AnimationPosePlayable : System.IEquatable<UnityEngine.Animations.AnimationPosePlayable>, UnityEngine.Playables.IPlayable
local AnimationPosePlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationPosePlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationPosePlayable 
---@return boolean ret 
function AnimationPosePlayable_Impl:Equals(other) end

---@return boolean ret 
function AnimationPosePlayable_Impl:GetMustReadPreviousPose() end

---@param value boolean 
function AnimationPosePlayable_Impl:SetMustReadPreviousPose(value) end

---@return boolean ret 
function AnimationPosePlayable_Impl:GetReadDefaultPose() end

---@param value boolean 
function AnimationPosePlayable_Impl:SetReadDefaultPose(value) end

---@return boolean ret 
function AnimationPosePlayable_Impl:GetApplyFootIK() end

---@param value boolean 
function AnimationPosePlayable_Impl:SetApplyFootIK(value) end

---@class Static.UnityEngine.Animations.AnimationPosePlayable
---@field Null UnityEngine.Animations.AnimationPosePlayable
---@overload fun(): UnityEngine.Animations.AnimationPosePlayable (Constructor)
local AnimationPosePlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@return UnityEngine.Animations.AnimationPosePlayable ret 
function AnimationPosePlayable_Static.Create(graph) end


---@type Static.UnityEngine.Animations.AnimationPosePlayable
UnityEngine.Animations.AnimationPosePlayable = AnimationPosePlayable_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Animations.AnimationRemoveScalePlayable : System.IEquatable<UnityEngine.Animations.AnimationRemoveScalePlayable>, UnityEngine.Playables.IPlayable
local AnimationRemoveScalePlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationRemoveScalePlayable_Impl:GetHandle() end

---@param other UnityEngine.Animations.AnimationRemoveScalePlayable 
---@return boolean ret 
function AnimationRemoveScalePlayable_Impl:Equals(other) end

---@class Static.UnityEngine.Animations.AnimationRemoveScalePlayable
---@field Null UnityEngine.Animations.AnimationRemoveScalePlayable
---@overload fun(): UnityEngine.Animations.AnimationRemoveScalePlayable (Constructor)
local AnimationRemoveScalePlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param inputCount integer 
---@return UnityEngine.Animations.AnimationRemoveScalePlayable ret 
function AnimationRemoveScalePlayable_Static.Create(graph, inputCount) end


---@type Static.UnityEngine.Animations.AnimationRemoveScalePlayable
UnityEngine.Animations.AnimationRemoveScalePlayable = AnimationRemoveScalePlayable_Static

--------------------------------------------------------------------------------

--- A Playable that can run a custom, multi-threaded animation job.
---@class UnityEngine.Animations.AnimationScriptPlayable : UnityEngine.Animations.IAnimationJobPlayable, System.IEquatable<UnityEngine.Animations.AnimationScriptPlayable>, UnityEngine.Playables.IPlayable
local AnimationScriptPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimationScriptPlayable_Impl:GetHandle() end

--- Gets the job data contained in the playable.
---@generic T
---@return T ret Returns the IAnimationJob data contained in the playable.
function AnimationScriptPlayable_Impl:GetJobData() end

--- Sets a new job data in the playable.
---@generic T
---@param jobData T The new IAnimationJob data to set in the playable.
function AnimationScriptPlayable_Impl:SetJobData(jobData) end

---@param other UnityEngine.Animations.AnimationScriptPlayable 
---@return boolean ret 
function AnimationScriptPlayable_Impl:Equals(other) end

--- Sets the new value for processing the inputs or not.
---@param value boolean The new value for processing the inputs or not.
function AnimationScriptPlayable_Impl:SetProcessInputs(value) end

--- Returns whether the playable inputs will be processed or not.
---@return boolean ret true if the inputs will be processed; false otherwise.
function AnimationScriptPlayable_Impl:GetProcessInputs() end

---@class Static.UnityEngine.Animations.AnimationScriptPlayable
---@field Null UnityEngine.Animations.AnimationScriptPlayable
---@overload fun(): UnityEngine.Animations.AnimationScriptPlayable (Constructor)
local AnimationScriptPlayable_Static = {}

--- Creates an AnimationScriptPlayable in the PlayableGraph.
---@generic T
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph object that will own the AnimationScriptPlayable.
---@param jobData T 
---@param inputCount? integer The number of inputs on the playable.
---@return UnityEngine.Animations.AnimationScriptPlayable ret A new AnimationScriptPlayable linked to the PlayableGraph.
function AnimationScriptPlayable_Static.Create(graph, jobData, inputCount) end


---@type Static.UnityEngine.Animations.AnimationScriptPlayable
UnityEngine.Animations.AnimationScriptPlayable = AnimationScriptPlayable_Static

--------------------------------------------------------------------------------

--- The stream of animation data passed from one Playable to another.
---@class UnityEngine.Animations.AnimationStream
--- Returns true if the stream is valid; false otherwise. (Read Only)
---@field isValid boolean
--- Gets the delta time for the evaluated frame. (Read Only)
---@field deltaTime number
--- Gets or sets the avatar velocity for the evaluated frame.
---@field velocity UnityEngine.Vector3
--- Gets or sets the avatar angular velocity for the evaluated frame.
---@field angularVelocity UnityEngine.Vector3
--- Gets the root motion position for the evaluated frame. (Read Only)
---@field rootMotionPosition UnityEngine.Vector3
--- Gets the root motion rotation for the evaluated frame. (Read Only)
---@field rootMotionRotation UnityEngine.Quaternion
--- Returns true if the stream is from a humanoid avatar; false otherwise. (Read Only)
---@field isHumanStream boolean
--- Gets the number of input streams. (Read Only)
---@field inputStreamCount integer
local AnimationStream_Impl = {}

--- Gets the same stream, but as an AnimationHumanStream.
---@return UnityEngine.Animations.AnimationHumanStream ret Returns the same stream, but as an AnimationHumanStream.
function AnimationStream_Impl:AsHuman() end

--- Gets the AnimationStream of the playable input at index.
---@param index integer The input index.
---@return UnityEngine.Animations.AnimationStream ret Returns the AnimationStream of the playable input at index. Returns an invalid stream if the input is not an animation Playable.
function AnimationStream_Impl:GetInputStream(index) end

--- Gets the weight of the Playable connected at a specific input index.
---@param index integer The input index.
---@return number ret Returns the weight of the Playable input as a float.
function AnimationStream_Impl:GetInputWeight(index) end

--- Deep copies motion from a source animation stream to the current animation stream.
---@param animationStream UnityEngine.Animations.AnimationStream The source animation stream with the motion to deep copy.
function AnimationStream_Impl:CopyAnimationStreamMotion(animationStream) end

---@class Static.UnityEngine.Animations.AnimationStream
---@overload fun(): UnityEngine.Animations.AnimationStream (Constructor)
local AnimationStream_Static = {}


---@type Static.UnityEngine.Animations.AnimationStream
UnityEngine.Animations.AnimationStream = AnimationStream_Static

--------------------------------------------------------------------------------

--- Position, rotation and scale of an object in the AnimationStream.
---@class UnityEngine.Animations.TransformStreamHandle
local TransformStreamHandle_Impl = {}

--- Returns whether this is a valid handle.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Whether this is a valid handle.
function TransformStreamHandle_Impl:IsValid(stream) end

--- Bind this handle with an animated values from the AnimationStream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
function TransformStreamHandle_Impl:Resolve(stream) end

--- Returns whether this handle is resolved.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the handle is resolved, false otherwise.
function TransformStreamHandle_Impl:IsResolved(stream) end

--- Gets the position of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Vector3 ret The position of the transform in world space.
function TransformStreamHandle_Impl:GetPosition(stream) end

--- Sets the position of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param position UnityEngine.Vector3 The position of the transform in world space.
function TransformStreamHandle_Impl:SetPosition(stream, position) end

--- Gets the rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Quaternion ret The rotation of the transform in world space.
function TransformStreamHandle_Impl:GetRotation(stream) end

--- Sets the rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param rotation UnityEngine.Quaternion The rotation of the transform in world space.
function TransformStreamHandle_Impl:SetRotation(stream, rotation) end

--- Gets the position of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Vector3 ret The position of the transform relative to the parent.
function TransformStreamHandle_Impl:GetLocalPosition(stream) end

--- Sets the position of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param position UnityEngine.Vector3 The position of the transform relative to the parent.
function TransformStreamHandle_Impl:SetLocalPosition(stream, position) end

--- Gets the rotation of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Quaternion ret The rotation of the transform relative to the parent.
function TransformStreamHandle_Impl:GetLocalRotation(stream) end

--- Sets the rotation of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param rotation UnityEngine.Quaternion The rotation of the transform relative to the parent.
function TransformStreamHandle_Impl:SetLocalRotation(stream, rotation) end

--- Gets the scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Vector3 ret The scale of the transform relative to the parent.
function TransformStreamHandle_Impl:GetLocalScale(stream) end

--- Sets the scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param scale UnityEngine.Vector3 The scale of the transform relative to the parent.
function TransformStreamHandle_Impl:SetLocalScale(stream, scale) end

--- Gets the position read mask of the transform.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the position can be read.
function TransformStreamHandle_Impl:GetPositionReadMask(stream) end

--- Gets the rotation read mask of the transform.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the rotation can be read.
function TransformStreamHandle_Impl:GetRotationReadMask(stream) end

--- Gets the scale read mask of the transform.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the scale can be read.
function TransformStreamHandle_Impl:GetScaleReadMask(stream) end

--- Gets the position, rotation and scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Vector3 position (Out) The position of the transform relative to the parent.
---@return UnityEngine.Quaternion rotation (Out) The rotation of the transform relative to the parent.
---@return UnityEngine.Vector3 scale (Out) The scale of the transform relative to the parent.
function TransformStreamHandle_Impl:GetLocalTRS(stream) end

--- Sets the position, rotation and scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param position UnityEngine.Vector3 The position of the transform relative to the parent.
---@param rotation UnityEngine.Quaternion The rotation of the transform relative to the parent.
---@param scale UnityEngine.Vector3 The scale of the transform relative to the parent.
---@param useMask boolean Set to true to write the specified parameters if the matching stream parameters have not already been modified.
function TransformStreamHandle_Impl:SetLocalTRS(stream, position, rotation, scale, useMask) end

--- Gets the position and scaled rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return UnityEngine.Vector3 position (Out) The position of the transform in world space.
---@return UnityEngine.Quaternion rotation (Out) The rotation of the transform in world space.
function TransformStreamHandle_Impl:GetGlobalTR(stream) end

--- Sets the position and rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param position UnityEngine.Vector3 The position of the transform in world space.
---@param rotation UnityEngine.Quaternion The rotation of the transform in world space.
---@param useMask boolean Set to true to write the specified parameters if the matching stream parameters have not already been modified.
function TransformStreamHandle_Impl:SetGlobalTR(stream, position, rotation, useMask) end

---@class Static.UnityEngine.Animations.TransformStreamHandle
---@overload fun(): UnityEngine.Animations.TransformStreamHandle (Constructor)
local TransformStreamHandle_Static = {}


---@type Static.UnityEngine.Animations.TransformStreamHandle
UnityEngine.Animations.TransformStreamHandle = TransformStreamHandle_Static

--------------------------------------------------------------------------------

--- Handle for a Component property on an object in the AnimationStream.
---@class UnityEngine.Animations.PropertyStreamHandle
local PropertyStreamHandle_Impl = {}

--- Returns whether or not the handle is valid.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Whether or not the handle is valid.
function PropertyStreamHandle_Impl:IsValid(stream) end

--- Resolves the handle.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
function PropertyStreamHandle_Impl:Resolve(stream) end

--- Returns whether or not the handle is resolved.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the handle is resolved, false otherwise.
function PropertyStreamHandle_Impl:IsResolved(stream) end

--- Gets the float property value from a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return number ret The float property value.
function PropertyStreamHandle_Impl:GetFloat(stream) end

--- Sets the float property value into a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param value number The new float property value.
function PropertyStreamHandle_Impl:SetFloat(stream, value) end

--- Gets the integer property value from a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return integer ret The integer property value.
function PropertyStreamHandle_Impl:GetInt(stream) end

--- Sets the integer property value into a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param value integer The new integer property value.
function PropertyStreamHandle_Impl:SetInt(stream, value) end

--- Gets the boolean property value from a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret The boolean property value.
function PropertyStreamHandle_Impl:GetBool(stream) end

--- Sets the boolean property value into a stream.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@param value boolean The new boolean property value.
function PropertyStreamHandle_Impl:SetBool(stream, value) end

--- Gets the read mask of the property.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that holds the animated values.
---@return boolean ret Returns true if the property can be read.
function PropertyStreamHandle_Impl:GetReadMask(stream) end

---@class Static.UnityEngine.Animations.PropertyStreamHandle
---@overload fun(): UnityEngine.Animations.PropertyStreamHandle (Constructor)
local PropertyStreamHandle_Static = {}


---@type Static.UnityEngine.Animations.PropertyStreamHandle
UnityEngine.Animations.PropertyStreamHandle = PropertyStreamHandle_Static

--------------------------------------------------------------------------------

--- Handle to read position, rotation and scale of an object in the Scene.
---@class UnityEngine.Animations.TransformSceneHandle
local TransformSceneHandle_Impl = {}

--- Returns whether this is a valid handle.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return boolean ret Whether this is a valid handle.
function TransformSceneHandle_Impl:IsValid(stream) end

--- Gets the position of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Vector3 ret The position of the transform in world space.
function TransformSceneHandle_Impl:GetPosition(stream) end

--- Sets the position of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@param position UnityEngine.Vector3 The position of the transform in world space.
function TransformSceneHandle_Impl:SetPosition(stream, position) end

--- Gets the position of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Vector3 ret The position of the transform relative to the parent.
function TransformSceneHandle_Impl:GetLocalPosition(stream) end

--- Sets the position of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@param position UnityEngine.Vector3 The position of the transform relative to the parent.
function TransformSceneHandle_Impl:SetLocalPosition(stream, position) end

--- Gets the rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Quaternion ret The rotation of the transform in world space.
function TransformSceneHandle_Impl:GetRotation(stream) end

--- Sets the rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@param rotation UnityEngine.Quaternion The rotation of the transform in world space.
function TransformSceneHandle_Impl:SetRotation(stream, rotation) end

--- Gets the rotation of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Quaternion ret The rotation of the transform relative to the parent.
function TransformSceneHandle_Impl:GetLocalRotation(stream) end

--- Sets the rotation of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@param rotation UnityEngine.Quaternion The rotation of the transform relative to the parent.
function TransformSceneHandle_Impl:SetLocalRotation(stream, rotation) end

--- Gets the scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Vector3 ret The scale of the transform relative to the parent.
function TransformSceneHandle_Impl:GetLocalScale(stream) end

--- Gets the position, rotation and scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Vector3 position (Out) The position of the transform relative to the parent.
---@return UnityEngine.Quaternion rotation (Out) The rotation of the transform relative to the parent.
---@return UnityEngine.Vector3 scale (Out) The scale of the transform relative to the parent.
function TransformSceneHandle_Impl:GetLocalTRS(stream) end

--- Gets the position and scaled rotation of the transform in world space.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@return UnityEngine.Vector3 position (Out) The position of the transform in world space.
---@return UnityEngine.Quaternion rotation (Out) The rotation of the transform in world space.
function TransformSceneHandle_Impl:GetGlobalTR(stream) end

--- Sets the scale of the transform relative to the parent.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream that manages this handle.
---@param scale UnityEngine.Vector3 The scale of the transform relative to the parent.
function TransformSceneHandle_Impl:SetLocalScale(stream, scale) end

---@class Static.UnityEngine.Animations.TransformSceneHandle
---@overload fun(): UnityEngine.Animations.TransformSceneHandle (Constructor)
local TransformSceneHandle_Static = {}


---@type Static.UnityEngine.Animations.TransformSceneHandle
UnityEngine.Animations.TransformSceneHandle = TransformSceneHandle_Static

--------------------------------------------------------------------------------

--- Handle to read a Component property on an object in the Scene.
---@class UnityEngine.Animations.PropertySceneHandle
local PropertySceneHandle_Impl = {}

--- Returns whether or not the handle is valid.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@return boolean ret Whether or not the handle is valid.
function PropertySceneHandle_Impl:IsValid(stream) end

--- Resolves the handle.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
function PropertySceneHandle_Impl:Resolve(stream) end

--- Returns whether or not the handle is resolved.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@return boolean ret Returns true if the handle is resolved, false otherwise.
function PropertySceneHandle_Impl:IsResolved(stream) end

--- Gets the float property value from an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@return number ret The float property value.
function PropertySceneHandle_Impl:GetFloat(stream) end

--- Sets the float property value to an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@param value number The new float property value.
function PropertySceneHandle_Impl:SetFloat(stream, value) end

--- Gets the integer property value from an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@return integer ret The integer property value.
function PropertySceneHandle_Impl:GetInt(stream) end

--- Sets the integer property value to an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@param value integer The new integer property value.
function PropertySceneHandle_Impl:SetInt(stream, value) end

--- Gets the boolean property value from an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@return boolean ret The boolean property value.
function PropertySceneHandle_Impl:GetBool(stream) end

--- Sets the boolean property value to an object in the Scene.
---@param stream UnityEngine.Animations.AnimationStream The AnimationStream managing this handle.
---@param value boolean The new boolean property value.
function PropertySceneHandle_Impl:SetBool(stream, value) end

---@class Static.UnityEngine.Animations.PropertySceneHandle
---@overload fun(): UnityEngine.Animations.PropertySceneHandle (Constructor)
local PropertySceneHandle_Static = {}


---@type Static.UnityEngine.Animations.PropertySceneHandle
UnityEngine.Animations.PropertySceneHandle = PropertySceneHandle_Static

--------------------------------------------------------------------------------

--- Static class providing utility functions for animation scene handles.
---@class UnityEngine.Animations.AnimationSceneHandleUtility
local AnimationSceneHandleUtility_Impl = {}

---@class Static.UnityEngine.Animations.AnimationSceneHandleUtility
local AnimationSceneHandleUtility_Static = {}

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
function AnimationSceneHandleUtility_Static.ReadInts(stream, handles, buffer) end

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
function AnimationSceneHandleUtility_Static.ReadFloats(stream, handles, buffer) end


---@type Static.UnityEngine.Animations.AnimationSceneHandleUtility
UnityEngine.Animations.AnimationSceneHandleUtility = AnimationSceneHandleUtility_Static

--------------------------------------------------------------------------------

--- Static class providing utility functions for animation stream handles.
---@class UnityEngine.Animations.AnimationStreamHandleUtility
local AnimationStreamHandleUtility_Impl = {}

---@class Static.UnityEngine.Animations.AnimationStreamHandleUtility
local AnimationStreamHandleUtility_Static = {}

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
---@param useMask boolean 
function AnimationStreamHandleUtility_Static.WriteInts(stream, handles, buffer, useMask) end

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
---@param useMask boolean 
function AnimationStreamHandleUtility_Static.WriteFloats(stream, handles, buffer, useMask) end

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
function AnimationStreamHandleUtility_Static.ReadInts(stream, handles, buffer) end

---@param stream UnityEngine.Animations.AnimationStream 
---@param handles Unity.Collections.NativeArray 
---@param buffer Unity.Collections.NativeArray 
function AnimationStreamHandleUtility_Static.ReadFloats(stream, handles, buffer) end


---@type Static.UnityEngine.Animations.AnimationStreamHandleUtility
UnityEngine.Animations.AnimationStreamHandleUtility = AnimationStreamHandleUtility_Static

--------------------------------------------------------------------------------

--- An implementation of IPlayable that controls an animation RuntimeAnimatorController.
---@class UnityEngine.Animations.AnimatorControllerPlayable : System.IEquatable<UnityEngine.Animations.AnimatorControllerPlayable>, UnityEngine.Playables.IPlayable
local AnimatorControllerPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AnimatorControllerPlayable_Impl:GetHandle() end

---@param handle UnityEngine.Playables.PlayableHandle 
function AnimatorControllerPlayable_Impl:SetHandle(handle) end

---@param other UnityEngine.Animations.AnimatorControllerPlayable 
---@return boolean ret 
function AnimatorControllerPlayable_Impl:Equals(other) end

--- Returns the value of the given float parameter.
---@param name string The parameter name.
---@return number ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetFloat(name) end

--- Returns the value of the given float parameter.
---@param id integer The parameter ID.
---@return number ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetFloat(id) end

--- Send float values to the AnimatorController to affect transitions.
---@param name string The parameter name.
---@param value number The new parameter value.
function AnimatorControllerPlayable_Impl:SetFloat(name, value) end

--- Send float values to the AnimatorController to affect transitions.
---@param id integer The parameter ID.
---@param value number The new parameter value.
function AnimatorControllerPlayable_Impl:SetFloat(id, value) end

--- Returns the value of the given boolean parameter.
---@param name string The parameter name.
---@return boolean ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetBool(name) end

--- Returns the value of the given boolean parameter.
---@param id integer The parameter ID.
---@return boolean ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetBool(id) end

--- Sets the value of the given boolean parameter.
---@param name string The parameter name.
---@param value boolean The new parameter value.
function AnimatorControllerPlayable_Impl:SetBool(name, value) end

--- Sets the value of the given boolean parameter.
---@param id integer The parameter ID.
---@param value boolean The new parameter value.
function AnimatorControllerPlayable_Impl:SetBool(id, value) end

--- Returns the value of the given integer parameter.
---@param name string The parameter name.
---@return integer ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetInteger(name) end

--- Returns the value of the given integer parameter.
---@param id integer The parameter ID.
---@return integer ret The value of the parameter.
function AnimatorControllerPlayable_Impl:GetInteger(id) end

--- Sets the value of the given integer parameter.
---@param name string The parameter name.
---@param value integer The new parameter value.
function AnimatorControllerPlayable_Impl:SetInteger(name, value) end

--- Sets the value of the given integer parameter.
---@param id integer The parameter ID.
---@param value integer The new parameter value.
function AnimatorControllerPlayable_Impl:SetInteger(id, value) end

--- Sets the value of the given trigger parameter.
---@param name string The parameter name.
function AnimatorControllerPlayable_Impl:SetTrigger(name) end

--- Sets the value of the given trigger parameter.
---@param id integer The parameter ID.
function AnimatorControllerPlayable_Impl:SetTrigger(id) end

--- Resets the value of the given trigger parameter.
---@param name string The parameter name.
function AnimatorControllerPlayable_Impl:ResetTrigger(name) end

--- Resets the value of the given trigger parameter.
---@param id integer The parameter ID.
function AnimatorControllerPlayable_Impl:ResetTrigger(id) end

--- Returns true if the parameter is controlled by a curve, false otherwise.
---@param name string The parameter name.
---@return boolean ret True if the parameter is controlled by a curve, false otherwise.
function AnimatorControllerPlayable_Impl:IsParameterControlledByCurve(name) end

--- Returns true if the parameter is controlled by a curve, false otherwise.
---@param id integer The parameter ID.
---@return boolean ret True if the parameter is controlled by a curve, false otherwise.
function AnimatorControllerPlayable_Impl:IsParameterControlledByCurve(id) end

---@return integer ret 
function AnimatorControllerPlayable_Impl:GetLayerCount() end

--- Returns the layer name.
---@param layerIndex integer The layer index.
---@return string ret The layer name.
function AnimatorControllerPlayable_Impl:GetLayerName(layerIndex) end

--- Returns the index of the layer with the given name.
---@param layerName string The layer name.
---@return integer ret The layer index.
function AnimatorControllerPlayable_Impl:GetLayerIndex(layerName) end

--- Returns the weight of the layer at the specified index.
---@param layerIndex integer The layer index.
---@return number ret The layer weight.
function AnimatorControllerPlayable_Impl:GetLayerWeight(layerIndex) end

--- Sets the weight of the layer at the given index.
---@param layerIndex integer The layer index.
---@param weight number The new layer weight.
function AnimatorControllerPlayable_Impl:SetLayerWeight(layerIndex, weight) end

--- Returns an AnimatorStateInfo with the information on the current state.
---@param layerIndex integer The layer index.
---@return UnityEngine.AnimatorStateInfo ret An AnimatorStateInfo with the information on the current state.
function AnimatorControllerPlayable_Impl:GetCurrentAnimatorStateInfo(layerIndex) end

--- Returns an AnimatorStateInfo with the information on the next state.
---@param layerIndex integer The layer index.
---@return UnityEngine.AnimatorStateInfo ret An AnimatorStateInfo with the information on the next state.
function AnimatorControllerPlayable_Impl:GetNextAnimatorStateInfo(layerIndex) end

--- Returns an AnimatorTransitionInfo with the informations on the current transition.
---@param layerIndex integer The layer's index.
---@return UnityEngine.AnimatorTransitionInfo ret An AnimatorTransitionInfo with the informations on the current transition.
function AnimatorControllerPlayable_Impl:GetAnimatorTransitionInfo(layerIndex) end

--- Returns an array of all the AnimatorClipInfo in the current state of the given layer.
---@param layerIndex integer The layer index.
---@return UnityEngine.AnimatorClipInfo[] ret An array of all the AnimatorClipInfo in the current state.
function AnimatorControllerPlayable_Impl:GetCurrentAnimatorClipInfo(layerIndex) end

---@param layerIndex integer 
---@param clips System.Collections.Generic.List 
function AnimatorControllerPlayable_Impl:GetCurrentAnimatorClipInfo(layerIndex, clips) end

---@param layerIndex integer 
---@param clips System.Collections.Generic.List 
function AnimatorControllerPlayable_Impl:GetNextAnimatorClipInfo(layerIndex, clips) end

--- Returns the number of AnimatorClipInfo in the current state.
---@param layerIndex integer The layer index.
---@return integer ret The number of AnimatorClipInfo in the current state.
function AnimatorControllerPlayable_Impl:GetCurrentAnimatorClipInfoCount(layerIndex) end

--- Returns the number of AnimatorClipInfo in the next state.
---@param layerIndex integer The layer index.
---@return integer ret The number of AnimatorClipInfo in the next state.
function AnimatorControllerPlayable_Impl:GetNextAnimatorClipInfoCount(layerIndex) end

--- Returns an array of all the AnimatorClipInfo in the next state of the given layer.
---@param layerIndex integer The layer index.
---@return UnityEngine.AnimatorClipInfo[] ret An array of all the AnimatorClipInfo in the next state.
function AnimatorControllerPlayable_Impl:GetNextAnimatorClipInfo(layerIndex) end

--- Returns true if there is a transition on the given layer, false otherwise.
---@param layerIndex integer The layer index.
---@return boolean ret True if there is a transition on the given layer, false otherwise.
function AnimatorControllerPlayable_Impl:IsInTransition(layerIndex) end

---@return integer ret 
function AnimatorControllerPlayable_Impl:GetParameterCount() end

--- See AnimatorController.parameters.
---@param index integer 
---@return UnityEngine.AnimatorControllerParameter ret 
function AnimatorControllerPlayable_Impl:GetParameter(index) end

---@param stateName string 
---@param transitionDuration number 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateName, transitionDuration) end

---@param stateName string 
---@param transitionDuration number 
---@param layer integer 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateName, transitionDuration, layer) end

---@param stateName string 
---@param transitionDuration number 
---@param layer integer 
---@param fixedTime number 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateName, transitionDuration, layer, fixedTime) end

---@param stateNameHash integer 
---@param transitionDuration number 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateNameHash, transitionDuration) end

---@param stateNameHash integer 
---@param transitionDuration number 
---@param layer integer 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateNameHash, transitionDuration, layer) end

---@param stateNameHash integer 
---@param transitionDuration number 
---@param layer integer 
---@param fixedTime number 
function AnimatorControllerPlayable_Impl:CrossFadeInFixedTime(stateNameHash, transitionDuration, layer, fixedTime) end

---@param stateName string 
---@param transitionDuration number 
function AnimatorControllerPlayable_Impl:CrossFade(stateName, transitionDuration) end

---@param stateName string 
---@param transitionDuration number 
---@param layer integer 
function AnimatorControllerPlayable_Impl:CrossFade(stateName, transitionDuration, layer) end

---@param stateName string 
---@param transitionDuration number 
---@param layer integer 
---@param normalizedTime number 
function AnimatorControllerPlayable_Impl:CrossFade(stateName, transitionDuration, layer, normalizedTime) end

---@param stateNameHash integer 
---@param transitionDuration number 
function AnimatorControllerPlayable_Impl:CrossFade(stateNameHash, transitionDuration) end

---@param stateNameHash integer 
---@param transitionDuration number 
---@param layer integer 
function AnimatorControllerPlayable_Impl:CrossFade(stateNameHash, transitionDuration, layer) end

---@param stateNameHash integer 
---@param transitionDuration number 
---@param layer integer 
---@param normalizedTime number 
function AnimatorControllerPlayable_Impl:CrossFade(stateNameHash, transitionDuration, layer, normalizedTime) end

---@param stateName string 
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateName) end

---@param stateName string 
---@param layer integer 
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateName, layer) end

--- Plays a state.
---@param stateName string The state name.
---@param layer integer The layer index. If layer is -1, it plays the first state with the given state name or hash.
---@param fixedTime number The time offset (in seconds).
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateName, layer, fixedTime) end

---@param stateNameHash integer 
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateNameHash) end

---@param stateNameHash integer 
---@param layer integer 
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateNameHash, layer) end

--- Plays a state.
---@param stateNameHash integer The state hash name. If stateNameHash is 0, it changes the current state time.
---@param layer integer The layer index. If layer is -1, it plays the first state with the given state name or hash.
---@param fixedTime number The time offset (in seconds).
function AnimatorControllerPlayable_Impl:PlayInFixedTime(stateNameHash, layer, fixedTime) end

---@param stateName string 
function AnimatorControllerPlayable_Impl:Play(stateName) end

---@param stateName string 
---@param layer integer 
function AnimatorControllerPlayable_Impl:Play(stateName, layer) end

--- Plays a state.
---@param stateName string The state name.
---@param layer integer The layer index. If layer is -1, it plays the first state with the given state name or hash.
---@param normalizedTime number The time offset between zero and one.
function AnimatorControllerPlayable_Impl:Play(stateName, layer, normalizedTime) end

---@param stateNameHash integer 
function AnimatorControllerPlayable_Impl:Play(stateNameHash) end

---@param stateNameHash integer 
---@param layer integer 
function AnimatorControllerPlayable_Impl:Play(stateNameHash, layer) end

--- Plays a state.
---@param stateNameHash integer The state hash name. If stateNameHash is 0, it changes the current state time.
---@param layer integer The layer index. If layer is -1, it plays the first state with the given state name or hash.
---@param normalizedTime number The time offset between zero and one.
function AnimatorControllerPlayable_Impl:Play(stateNameHash, layer, normalizedTime) end

--- Returns true if the state exists in this layer, false otherwise.
---@param layerIndex integer The layer index.
---@param stateID integer The state ID.
---@return boolean ret True if the state exists in this layer, false otherwise.
function AnimatorControllerPlayable_Impl:HasState(layerIndex, stateID) end

---@class Static.UnityEngine.Animations.AnimatorControllerPlayable
--- Returns an invalid AnimatorControllerPlayable.
---@field Null UnityEngine.Animations.AnimatorControllerPlayable
---@overload fun(): UnityEngine.Animations.AnimatorControllerPlayable (Constructor)
local AnimatorControllerPlayable_Static = {}

--- Creates an AnimatorControllerPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph object that will own the AnimatorControllerPlayable.
---@param controller UnityEngine.RuntimeAnimatorController The RuntimeAnimatorController that will be added in the graph.
---@return UnityEngine.Animations.AnimatorControllerPlayable ret A AnimatorControllerPlayable.
function AnimatorControllerPlayable_Static.Create(graph, controller) end


---@type Static.UnityEngine.Animations.AnimatorControllerPlayable
UnityEngine.Animations.AnimatorControllerPlayable = AnimatorControllerPlayable_Static

--------------------------------------------------------------------------------

--- Static class providing extension methods for Animator and the animation C# jobs.
---@class UnityEngine.Animations.AnimatorJobExtensions
local AnimatorJobExtensions_Impl = {}

---@class Static.UnityEngine.Animations.AnimatorJobExtensions
local AnimatorJobExtensions_Static = {}

--- Creates a dependency between animator jobs and the job represented by the supplied job handle. To add multiple job dependencies, call this method for each job that need to run before the Animator's jobs.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param jobHandle Unity.Jobs.JobHandle The JobHandle of the job that needs to run before animator jobs.
function AnimatorJobExtensions_Static.AddJobDependency(animator, jobHandle) end

--- Create a TransformStreamHandle representing the new binding between the Animator and a Transform already bound to the Animator.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to bind.
---@return UnityEngine.Animations.TransformStreamHandle ret Returns the TransformStreamHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindStreamTransform(animator, transform) end

--- Create a PropertyStreamHandle representing the new binding on the Component property of a Transform already bound to the Animator.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to target.
---@param type System.Type The Component type.
---@param property string The property to bind.
---@return UnityEngine.Animations.PropertyStreamHandle ret Returns the PropertyStreamHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindStreamProperty(animator, transform, type, property) end

--- Create a custom property in the AnimationStream to pass extra data to downstream animation jobs in your graph. Custom properties created in the AnimationStream do not exist in the scene.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param property string 
---@param type UnityEngine.Animations.CustomStreamPropertyType The type of property to create (float, integer or boolean).
---@return UnityEngine.Animations.PropertyStreamHandle ret Returns the PropertyStreamHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindCustomStreamProperty(animator, property, type) end

--- Create a PropertyStreamHandle representing the new binding on the Component property of a Transform already bound to the Animator.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to target.
---@param type System.Type The Component type.
---@param property string The property to bind.
---@param isObjectReference boolean isObjectReference need to be set to true if the property to bind does animate an Object like SpriteRenderer.sprite.
---@return UnityEngine.Animations.PropertyStreamHandle ret Returns the PropertyStreamHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindStreamProperty(animator, transform, type, property, isObjectReference) end

--- Create a TransformSceneHandle representing the new binding between the Animator and a Transform in the Scene.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to bind.
---@return UnityEngine.Animations.TransformSceneHandle ret Returns the TransformSceneHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindSceneTransform(animator, transform) end

--- Create a PropertySceneHandle representing the new binding on the Component property of a Transform in the Scene.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to target.
---@param type System.Type The Component type.
---@param property string The property to bind.
---@return UnityEngine.Animations.PropertySceneHandle ret Returns the PropertySceneHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindSceneProperty(animator, transform, type, property) end

--- Create a PropertySceneHandle representing the new binding on the Component property of a Transform in the Scene.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param transform UnityEngine.Transform The Transform to target.
---@param type System.Type The Component type.
---@param property string The property to bind.
---@param isObjectReference boolean isObjectReference need to be set to true if the property to bind does access an Object like SpriteRenderer.sprite.
---@return UnityEngine.Animations.PropertySceneHandle ret Returns the PropertySceneHandle that represents the new binding.
function AnimatorJobExtensions_Static.BindSceneProperty(animator, transform, type, property, isObjectReference) end

--- Open a new stream on the Animator.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param stream UnityEngine.Animations.AnimationStream The new stream.
---@return boolean ret Returns whether or not the stream has been opened.
---@return UnityEngine.Animations.AnimationStream stream (Ref) The new stream.
function AnimatorJobExtensions_Static.OpenAnimationStream(animator, stream) end

--- Close a stream that has been opened using OpenAnimationStream.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
---@param stream UnityEngine.Animations.AnimationStream The stream to close.
---@return UnityEngine.Animations.AnimationStream stream (Ref) The stream to close.
function AnimatorJobExtensions_Static.CloseAnimationStream(animator, stream) end

--- Newly created handles are always resolved lazily on the next access when the jobs are run. To avoid a cpu spike while evaluating the jobs you can manually resolve all handles from the main thread.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
function AnimatorJobExtensions_Static.ResolveAllStreamHandles(animator) end

--- Newly created handles are always resolved lazily on the next access when the jobs are run. To avoid a cpu spike while evaluating the jobs you can manually resolve all handles from the main thread.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
function AnimatorJobExtensions_Static.ResolveAllSceneHandles(animator) end

--- Removes all PropertyStreamHandles and TransformStreamHandles associated with the Animator instance. Use this method to manage the lifecycle of stream handles when the animated hierarchy changes.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
function AnimatorJobExtensions_Static.UnbindAllStreamHandles(animator) end

--- Removes all PropertySceneHandles and TransformSceneHandles associated with the Animator instance. Use this method to manage the lifecycle of scene handles when the animated hierarchy changes.
---@param animator UnityEngine.Animator The Animator instance that calls this method.
function AnimatorJobExtensions_Static.UnbindAllSceneHandles(animator) end


---@type Static.UnityEngine.Animations.AnimatorJobExtensions
UnityEngine.Animations.AnimatorJobExtensions = AnimatorJobExtensions_Static

--------------------------------------------------------------------------------

--- Represents a source for the constraint.
---@class UnityEngine.Animations.ConstraintSource
--- The transform component of the source object.
---@field sourceTransform UnityEngine.Transform
--- The weight of the source in the evaluation of the constraint.
---@field weight number
local ConstraintSource_Impl = {}

---@class Static.UnityEngine.Animations.ConstraintSource
---@overload fun(): UnityEngine.Animations.ConstraintSource (Constructor)
local ConstraintSource_Static = {}


---@type Static.UnityEngine.Animations.ConstraintSource
UnityEngine.Animations.ConstraintSource = ConstraintSource_Static

--------------------------------------------------------------------------------

--- Constrains the position of an object relative to the position of one or more source objects.
---@class UnityEngine.Animations.PositionConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- The translation used when the sources have a total weight of 0.
---@field translationAtRest UnityEngine.Vector3
--- The offset from the constrained position.
---@field translationOffset UnityEngine.Vector3
--- The axes affected by the PositionConstraint.
---@field translationAxis UnityEngine.Animations.Axis
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offset and position at rest.
---@field locked boolean
--- The number of sources set on the component (read-only).
---@field sourceCount integer
local PositionConstraint_Impl = {}

---@param sources System.Collections.Generic.List 
function PositionConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function PositionConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function PositionConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function PositionConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret The source object and its weight.
function PositionConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function PositionConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

--- Constrains the rotation of an object relative to the rotation of one or more source objects.
---@class UnityEngine.Animations.RotationConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- The rotation used when the sources have a total weight of 0.
---@field rotationAtRest UnityEngine.Vector3
--- The offset from the constrained rotation.
---@field rotationOffset UnityEngine.Vector3
--- The axes affected by the RotationConstraint.
---@field rotationAxis UnityEngine.Animations.Axis
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offset and rotation at rest.
---@field locked boolean
--- The number of sources set on the component (read-only).
---@field sourceCount integer
local RotationConstraint_Impl = {}

---@param sources System.Collections.Generic.List 
function RotationConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function RotationConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function RotationConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function RotationConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret The source object and its weight.
function RotationConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function RotationConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

--- Constrains the scale of an object relative to the scale of one or more source objects.
---@class UnityEngine.Animations.ScaleConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- The scale used when the sources have a total weight of 0.
---@field scaleAtRest UnityEngine.Vector3
--- The offset from the constrained scale.
---@field scaleOffset UnityEngine.Vector3
--- The axes affected by the ScaleConstraint.
---@field scalingAxis UnityEngine.Animations.Axis
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offset and scale at rest.
---@field locked boolean
--- The number of sources set on the component (read-only).
---@field sourceCount integer
local ScaleConstraint_Impl = {}

---@param sources System.Collections.Generic.List 
function ScaleConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function ScaleConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function ScaleConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function ScaleConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret The source object and its weight.
function ScaleConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function ScaleConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

--- Constrains the orientation of an object relative to the position of one or more source objects, such that the object is facing the average position of the sources. The LookAtConstraint is a simplified Animations.AimConstraint typically used with a Camera.
---@class UnityEngine.Animations.LookAtConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- The rotation angle along the z axis of the object. The constraint uses this property to calculate the world up vector when Animations.LookAtConstraint.UseUpObject is false.
---@field roll number
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offset and rotation at rest.
---@field locked boolean
--- The rotation used when the sources have a total weight of 0.
---@field rotationAtRest UnityEngine.Vector3
--- Represents an offset from the constrained orientation.
---@field rotationOffset UnityEngine.Vector3
--- The world up object, used to calculate the world up vector when Animations.LookAtConstraint.UseUpObject is true.
---@field worldUpObject UnityEngine.Transform
--- Determines how the up vector is calculated.
---@field useUpObject boolean
--- The number of sources set on the component (Read Only).
---@field sourceCount integer
local LookAtConstraint_Impl = {}

---@param sources System.Collections.Generic.List 
function LookAtConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function LookAtConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function LookAtConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function LookAtConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret Returns the source object and its weight.
function LookAtConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function LookAtConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

--- Handle for a muscle in the AnimationHumanStream.
---@class UnityEngine.Animations.MuscleHandle
--- The muscle human part. (Read Only)
---@field humanPartDof UnityEngine.HumanPartDof
--- The muscle human sub-part. (Read Only)
---@field dof integer
--- The name of the muscle. (Read Only)
---@field name string
local MuscleHandle_Impl = {}

---@class Static.UnityEngine.Animations.MuscleHandle
--- The total number of DoF parts in a humanoid. (Read Only)
---@field muscleHandleCount integer
---@overload fun(bodyDof:UnityEngine.BodyDof): UnityEngine.Animations.MuscleHandle (Constructor)
---@overload fun(headDof:UnityEngine.HeadDof): UnityEngine.Animations.MuscleHandle (Constructor)
---@overload fun(partDof:UnityEngine.HumanPartDof, legDof:UnityEngine.LegDof): UnityEngine.Animations.MuscleHandle (Constructor)
---@overload fun(partDof:UnityEngine.HumanPartDof, armDof:UnityEngine.ArmDof): UnityEngine.Animations.MuscleHandle (Constructor)
---@overload fun(partDof:UnityEngine.HumanPartDof, fingerDof:UnityEngine.FingerDof): UnityEngine.Animations.MuscleHandle (Constructor)
---@overload fun(): UnityEngine.Animations.MuscleHandle (Constructor)
local MuscleHandle_Static = {}

--- Fills the array with all the possible muscle handles on a humanoid.
---@param muscleHandles UnityEngine.Animations.MuscleHandle[] An array of MuscleHandle.
function MuscleHandle_Static.GetMuscleHandles(muscleHandles) end


---@type Static.UnityEngine.Animations.MuscleHandle
UnityEngine.Animations.MuscleHandle = MuscleHandle_Static

--------------------------------------------------------------------------------

--- Constrains the orientation and translation of an object to one or more source objects. The constrained object behaves as if it is in the hierarchy of the sources.
---@class UnityEngine.Animations.ParentConstraint : UnityEngine.Behaviour, UnityEngine.Animations.IConstraint, UnityEngine.Animations.IConstraintInternal
--- The weight of the constraint component.
---@field weight number
--- Activates or deactivates the constraint.
---@field constraintActive boolean
--- Locks the offsets and position (translation and rotation) at rest.
---@field locked boolean
--- The number of sources set on the component (read-only).
---@field sourceCount integer
--- The position of the object in local space, used when the sources have a total weight of 0.
---@field translationAtRest UnityEngine.Vector3
--- The rotation used when the sources have a total weight of 0.
---@field rotationAtRest UnityEngine.Vector3
--- The translation offsets from the constrained orientation.
---@field translationOffsets UnityEngine.Vector3[]
--- The rotation offsets from the constrained orientation.
---@field rotationOffsets UnityEngine.Vector3[]
--- The translation axes affected by the ParentConstraint.
---@field translationAxis UnityEngine.Animations.Axis
--- The rotation axes affected by the ParentConstraint.
---@field rotationAxis UnityEngine.Animations.Axis
local ParentConstraint_Impl = {}

--- Gets the rotation offset associated with a source by index.
---@param index integer The index of the constraint source.
---@return UnityEngine.Vector3 ret The translation offset.
function ParentConstraint_Impl:GetTranslationOffset(index) end

--- Sets the translation offset associated with a source by index.
---@param index integer The index of the constraint source.
---@param value UnityEngine.Vector3 The new translation offset.
function ParentConstraint_Impl:SetTranslationOffset(index, value) end

--- Gets the rotation offset associated with a source by index.
---@param index integer The index of the constraint source.
---@return UnityEngine.Vector3 ret The rotation offset, as Euler angles.
function ParentConstraint_Impl:GetRotationOffset(index) end

--- Sets the rotation offset associated with a source by index.
---@param index integer The index of the constraint source.
---@param value UnityEngine.Vector3 The new rotation offset.
function ParentConstraint_Impl:SetRotationOffset(index, value) end

---@param sources System.Collections.Generic.List 
function ParentConstraint_Impl:GetSources(sources) end

---@param sources System.Collections.Generic.List 
function ParentConstraint_Impl:SetSources(sources) end

--- Adds a constraint source.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
---@return integer ret Returns the index of the added source.
function ParentConstraint_Impl:AddSource(source) end

--- Removes a source from the component.
---@param index integer The index of the source to remove.
function ParentConstraint_Impl:RemoveSource(index) end

--- Gets a constraint source by index.
---@param index integer The index of the source.
---@return UnityEngine.Animations.ConstraintSource ret The source object and its weight.
function ParentConstraint_Impl:GetSource(index) end

--- Sets a source at a specified index.
---@param index integer The index of the source to set.
---@param source UnityEngine.Animations.ConstraintSource The source object and its weight.
function ParentConstraint_Impl:SetSource(index, source) end

--------------------------------------------------------------------------------

