--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.Audio
UnityEngine.Audio = {}

--- The mode in which an AudioMixer should update its time.
---@enum UnityEngine.Audio.AudioMixerUpdateMode
local AudioMixerUpdateMode_Enum = {
    --- Update the AudioMixer with scaled game time.
    Normal = 0,
    --- Update the AudioMixer with unscaled realtime.
    UnscaledTime = 1,
}
UnityEngine.Audio.AudioMixerUpdateMode = AudioMixerUpdateMode_Enum

--- An implementation of IPlayable that controls an AudioClip.
---@class UnityEngine.Audio.AudioClipPlayable : System.IEquatable<UnityEngine.Audio.AudioClipPlayable>, UnityEngine.Playables.IPlayable
local AudioClipPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AudioClipPlayable_Impl:GetHandle() end

---@param other UnityEngine.Audio.AudioClipPlayable 
---@return boolean ret 
function AudioClipPlayable_Impl:Equals(other) end

---@return UnityEngine.AudioClip ret 
function AudioClipPlayable_Impl:GetClip() end

---@param value UnityEngine.AudioClip 
function AudioClipPlayable_Impl:SetClip(value) end

---@return boolean ret 
function AudioClipPlayable_Impl:GetLooped() end

---@param value boolean 
function AudioClipPlayable_Impl:SetLooped(value) end

---@return boolean ret 
function AudioClipPlayable_Impl:IsPlaying() end

---@return boolean ret 
function AudioClipPlayable_Impl:IsChannelPlaying() end

---@return number ret 
function AudioClipPlayable_Impl:GetStartDelay() end

---@return number ret 
function AudioClipPlayable_Impl:GetPauseDelay() end

---@param startTime number 
---@param startDelay number 
function AudioClipPlayable_Impl:Seek(startTime, startDelay) end

---@param startTime number 
---@param startDelay number 
---@param duration number 
function AudioClipPlayable_Impl:Seek(startTime, startDelay, duration) end

---@class Static.UnityEngine.Audio.AudioClipPlayable
---@overload fun(): UnityEngine.Audio.AudioClipPlayable (Constructor)
local AudioClipPlayable_Static = {}

--- Creates an AudioClipPlayable in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the new AnimationLayerMixerPlayable.
---@param clip UnityEngine.AudioClip The AudioClip that will be added in the PlayableGraph.
---@param looping boolean True if the clip should loop, false otherwise.
---@return UnityEngine.Audio.AudioClipPlayable ret A AudioClipPlayable linked to the PlayableGraph.
function AudioClipPlayable_Static.Create(graph, clip, looping) end


---@type Static.UnityEngine.Audio.AudioClipPlayable
UnityEngine.Audio.AudioClipPlayable = AudioClipPlayable_Static

--------------------------------------------------------------------------------

--- AudioMixer asset.
---@class UnityEngine.Audio.AudioMixer : UnityEngine.Object
--- Routing target.
---@field outputAudioMixerGroup UnityEngine.Audio.AudioMixerGroup
--- How time should progress for this AudioMixer. Used during Snapshot transitions.
---@field updateMode UnityEngine.Audio.AudioMixerUpdateMode
local AudioMixer_Impl = {}

--- The name must be an exact match.
---@param name string Name of snapshot object to be returned.
---@return UnityEngine.Audio.AudioMixerSnapshot ret The snapshot identified by the name.
function AudioMixer_Impl:FindSnapshot(name) end

--- Connected groups in the mixer form a path from the mixer's master group to the leaves. This path has the format "Master GroupChild of Master GroupGrandchild of Master Group", so to find the grandchild group in this example, a valid search string would be for instance "randchi" which would return exactly one group while "hild" or "oup/" would return 2 different groups.
---@param subPath string Sub-string of the paths to be matched.
---@return UnityEngine.Audio.AudioMixerGroup[] ret Groups in the mixer whose paths match the specified search path.
function AudioMixer_Impl:FindMatchingGroups(subPath) end

--- Transitions to a weighted mixture of the snapshots specified. This can be used for games that specify the game state as a continuum between states or for interpolating snapshots from a triangulated map location.
---@param snapshots UnityEngine.Audio.AudioMixerSnapshot[] The set of snapshots to be mixed.
---@param weights number[] The mix weights for the snapshots specified.
---@param timeToReach number Relative time after which the mixture should be reached from any current state.
function AudioMixer_Impl:TransitionToSnapshots(snapshots, weights, timeToReach) end

--- Sets the value of the exposed parameter specified. When a parameter is exposed, it is not controlled by mixer snapshots and can therefore only be changed via this function.
---@param name string Name of exposed parameter.
---@param value number New value of exposed parameter.
---@return boolean ret Returns false if the exposed parameter was not found or snapshots are currently being edited.
function AudioMixer_Impl:SetFloat(name, value) end

--- Resets an exposed parameter to its initial value.
---@param name string Exposed parameter.
---@return boolean ret Returns false if the parameter was not found or could not be set.
function AudioMixer_Impl:ClearFloat(name) end

--- Returns the value of the exposed parameter specified. If the parameter doesn't exist the function returns false. Prior to calling SetFloat and after ClearFloat has been called on this parameter the value returned will be that of the current snapshot or snapshot transition.
---@param name string Name of exposed parameter.
---@return boolean ret Returns false if the exposed parameter specified doesn't exist.
---@return number value (Out) Return value of exposed parameter.
function AudioMixer_Impl:GetFloat(name) end

--------------------------------------------------------------------------------

--- Object representing a group in the mixer.
---@class UnityEngine.Audio.AudioMixerGroup : UnityEngine.Object, UnityEngine.Internal.ISubAssetNotDuplicatable
---@field audioMixer UnityEngine.Audio.AudioMixer
local AudioMixerGroup_Impl = {}

--------------------------------------------------------------------------------

--- An implementation of IPlayable that controls an audio mixer.
---@class UnityEngine.Audio.AudioMixerPlayable : System.IEquatable<UnityEngine.Audio.AudioMixerPlayable>, UnityEngine.Playables.IPlayable
local AudioMixerPlayable_Impl = {}

---@return UnityEngine.Playables.PlayableHandle ret 
function AudioMixerPlayable_Impl:GetHandle() end

---@param other UnityEngine.Audio.AudioMixerPlayable 
---@return boolean ret 
function AudioMixerPlayable_Impl:Equals(other) end

---@class Static.UnityEngine.Audio.AudioMixerPlayable
---@overload fun(): UnityEngine.Audio.AudioMixerPlayable (Constructor)
local AudioMixerPlayable_Static = {}

---@param graph UnityEngine.Playables.PlayableGraph 
---@param inputCount? integer 
---@param normalizeInputVolumes? boolean 
---@return UnityEngine.Audio.AudioMixerPlayable ret 
function AudioMixerPlayable_Static.Create(graph, inputCount, normalizeInputVolumes) end


---@type Static.UnityEngine.Audio.AudioMixerPlayable
UnityEngine.Audio.AudioMixerPlayable = AudioMixerPlayable_Static

--------------------------------------------------------------------------------

--- Object representing a snapshot in the mixer.
---@class UnityEngine.Audio.AudioMixerSnapshot : UnityEngine.Object, UnityEngine.Internal.ISubAssetNotDuplicatable
---@field audioMixer UnityEngine.Audio.AudioMixer
local AudioMixerSnapshot_Impl = {}

--- Performs an interpolated transition towards this snapshot over the time interval specified.
---@param timeToReach number Relative time after which this snapshot should be reached from any current state.
function AudioMixerSnapshot_Impl:TransitionTo(timeToReach) end

--------------------------------------------------------------------------------

--- A PlayableBinding that contains information representing an AudioPlayableOutput.
---@class UnityEngine.Audio.AudioPlayableBinding
local AudioPlayableBinding_Impl = {}

---@class Static.UnityEngine.Audio.AudioPlayableBinding
local AudioPlayableBinding_Static = {}

--- Creates a PlayableBinding that contains information representing an AudioPlayableOutput.
---@param name string The name of the AudioPlayableOutput.
---@param key UnityEngine.Object A reference to a UnityEngine.Object that acts as a key for this binding.
---@return UnityEngine.Playables.PlayableBinding ret Returns a PlayableBinding that contains information that is used to create an AudioPlayableOutput.
function AudioPlayableBinding_Static.Create(name, key) end


---@type Static.UnityEngine.Audio.AudioPlayableBinding
UnityEngine.Audio.AudioPlayableBinding = AudioPlayableBinding_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Audio.AudioPlayableGraphExtensions
local AudioPlayableGraphExtensions_Impl = {}

--------------------------------------------------------------------------------

--- A IPlayableOutput implementation that will be used to play audio.
---@class UnityEngine.Audio.AudioPlayableOutput : UnityEngine.Playables.IPlayableOutput
local AudioPlayableOutput_Impl = {}

---@return UnityEngine.Playables.PlayableOutputHandle ret 
function AudioPlayableOutput_Impl:GetHandle() end

---@return UnityEngine.AudioSource ret 
function AudioPlayableOutput_Impl:GetTarget() end

---@param value UnityEngine.AudioSource 
function AudioPlayableOutput_Impl:SetTarget(value) end

--- Gets the state of output playback when seeking.
---@return boolean ret Returns true if the output plays when seeking. Returns false otherwise.
function AudioPlayableOutput_Impl:GetEvaluateOnSeek() end

--- Controls whether the output should play when seeking.
---@param value boolean Set to true to play the output when seeking. Set to false to disable audio scrubbing on this output. Default is true.
function AudioPlayableOutput_Impl:SetEvaluateOnSeek(value) end

---@class Static.UnityEngine.Audio.AudioPlayableOutput
--- Returns an invalid AudioPlayableOutput.
---@field Null UnityEngine.Audio.AudioPlayableOutput
---@overload fun(): UnityEngine.Audio.AudioPlayableOutput (Constructor)
local AudioPlayableOutput_Static = {}

--- Creates an AudioPlayableOutput in the PlayableGraph.
---@param graph UnityEngine.Playables.PlayableGraph The PlayableGraph that will contain the AnimationPlayableOutput.
---@param name string The name of the output.
---@param target UnityEngine.AudioSource The AudioSource that will play the AudioPlayableOutput source Playable.
---@return UnityEngine.Audio.AudioPlayableOutput ret A new AudioPlayableOutput attached to the PlayableGraph.
function AudioPlayableOutput_Static.Create(graph, name, target) end


---@type Static.UnityEngine.Audio.AudioPlayableOutput
UnityEngine.Audio.AudioPlayableOutput = AudioPlayableOutput_Static

--------------------------------------------------------------------------------

