--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.Video
UnityEngine.Video = {}

--- Type of destination for the images read by a VideoPlayer.
---@enum UnityEngine.Video.VideoRenderMode
local VideoRenderMode_Enum = {
    --- Draw video content behind a camera's Scene.
    CameraFarPlane = 0,
    --- Draw video content in front of a camera's Scene.
    CameraNearPlane = 1,
    --- Draw video content into a RenderTexture.
    RenderTexture = 2,
    --- Draw the video content into a user-specified property of the current GameObject's material.
    MaterialOverride = 3,
    --- Don't draw the video content anywhere, but still make it available via the VideoPlayer's texture property in the API.
    APIOnly = 4,
}
UnityEngine.Video.VideoRenderMode = VideoRenderMode_Enum

--- Types of 3D content layout within a video.
---@enum UnityEngine.Video.Video3DLayout
local Video3DLayout_Enum = {
    --- Video does not have any 3D content.
    No3D = 0,
    --- Video contains 3D content where the left eye occupies the left half and right eye occupies the right half of video frames.
    SideBySide3D = 1,
    --- Video contains 3D content where the left eye occupies the upper half and right eye occupies the lower half of video frames.
    OverUnder3D = 2,
}
UnityEngine.Video.Video3DLayout = Video3DLayout_Enum

--- Methods used to fit a video in the target area.
---@enum UnityEngine.Video.VideoAspectRatio
local VideoAspectRatio_Enum = {
    --- Preserve the pixel size without adjusting for target area.
    NoScaling = 0,
    --- Resize proportionally so that height fits the target area, cropping or adding black bars on each side if needed.
    FitVertically = 1,
    --- Resize proportionally so that width fits the target area, cropping or adding black bars above and below if needed.
    FitHorizontally = 2,
    --- Resize proportionally so that content fits the target area, adding black bars if needed.
    FitInside = 3,
    --- Resize proportionally so that content fits the target area, cropping if needed.
    FitOutside = 4,
    --- Resize non-proportionally to fit the target area.
    Stretch = 5,
}
UnityEngine.Video.VideoAspectRatio = VideoAspectRatio_Enum

--- Time source followed by the Video.VideoPlayer when reading content.
---@enum UnityEngine.Video.VideoTimeSource
local VideoTimeSource_Enum = {
    --- The audio hardware clock.
    AudioDSPTimeSource = 0,
    --- The unscaled game time as defined by Time.realtimeSinceStartup.
    GameTimeSource = 1,
}
UnityEngine.Video.VideoTimeSource = VideoTimeSource_Enum

--- The clock that the Video.VideoPlayer observes to detect and correct drift.
---@enum UnityEngine.Video.VideoTimeReference
local VideoTimeReference_Enum = {
    --- Disables the drift detection.
    Freerun = 0,
    --- Internal reference clock the Video.VideoPlayer observes to detect and correct drift.
    InternalTime = 1,
    --- External reference clock the Video.VideoPlayer observes to detect and correct drift.
    ExternalTime = 2,
}
UnityEngine.Video.VideoTimeReference = VideoTimeReference_Enum

--- Source of the video content for a VideoPlayer.
---@enum UnityEngine.Video.VideoSource
local VideoSource_Enum = {
    --- Use the current clip as the video content source.
    VideoClip = 0,
    --- Use the current URL as the video content source.
    Url = 1,
}
UnityEngine.Video.VideoSource = VideoSource_Enum

--- Places where the audio embedded in a video can be sent.
---@enum UnityEngine.Video.VideoAudioOutputMode
local VideoAudioOutputMode_Enum = {
    --- Disable the embedded audio.
    None = 0,
    --- Send the embedded audio into a specified AudioSource.
    AudioSource = 1,
    --- Send the embedded audio direct to the platform's audio hardware.
    Direct = 2,
    --- Send the embedded audio to the associated AudioSampleProvider.
    APIOnly = 3,
}
UnityEngine.Video.VideoAudioOutputMode = VideoAudioOutputMode_Enum

--- A container for video data.
---@class UnityEngine.Video.VideoClip : UnityEngine.Object
--- The video clip path in the project's assets. (Read Only).
---@field originalPath string
--- The length of the VideoClip in frames. (Read Only).
---@field frameCount integer
--- The frame rate of the clip in frames/second. (Read Only).
---@field frameRate number
--- The length of the video clip in seconds. (Read Only).
---@field length number
--- The width of the images in the video clip in pixels. (Read Only).
---@field width integer
--- The height of the images in the video clip in pixels. (Read Only).
---@field height integer
--- Numerator of the pixel aspect ratio (num:den). (Read Only).
---@field pixelAspectRatioNumerator integer
--- Denominator of the pixel aspect ratio (num:den). (Read Only).
---@field pixelAspectRatioDenominator integer
--- Whether the imported clip contains sRGB color data (Read Only).
---@field sRGB boolean
--- Number of audio tracks in the clip.
---@field audioTrackCount integer
local VideoClip_Impl = {}

--- The number of channels in the audio track. E.g. 2 for a stereo track.
---@param audioTrackIdx integer Index of the audio queried audio track.
---@return integer ret The number of channels.
function VideoClip_Impl:GetAudioChannelCount(audioTrackIdx) end

--- Get the audio track sampling rate in Hertz.
---@param audioTrackIdx integer Index of the audio queried audio track.
---@return integer ret The sampling rate in Hertz.
function VideoClip_Impl:GetAudioSampleRate(audioTrackIdx) end

--- Get the audio track language. Can be unknown.
---@param audioTrackIdx integer Index of the audio queried audio track.
---@return string ret The abbreviated name of the language.
function VideoClip_Impl:GetAudioLanguage(audioTrackIdx) end

--------------------------------------------------------------------------------

--- Plays video content onto a target.
---@class UnityEngine.Video.VideoPlayer : UnityEngine.Behaviour
--- The source that the VideoPlayer uses for playback.
---@field source UnityEngine.Video.VideoSource
--- The file or HTTP URL that the VideoPlayer reads content from.
---@field url string
--- The clip being played by the VideoPlayer.
---@field clip UnityEngine.Video.VideoClip
--- Where the video content will be drawn.
---@field renderMode UnityEngine.Video.VideoRenderMode
--- Camera component to draw to when Video.VideoPlayer.renderMode is set to either Video.VideoRenderMode.CameraFarPlane or Video.VideoRenderMode.CameraNearPlane.
---@field targetCamera UnityEngine.Camera
--- RenderTexture to draw to when Video.VideoPlayer.renderMode is set to Video.VideoTarget.RenderTexture.
---@field targetTexture UnityEngine.RenderTexture
--- Renderer which is targeted when Video.VideoPlayer.renderMode is set to Video.VideoTarget.MaterialOverride
---@field targetMaterialRenderer UnityEngine.Renderer
--- Material texture property which is targeted when Video.VideoPlayer.renderMode is set to Video.VideoTarget.MaterialOverride.
---@field targetMaterialProperty string
--- Defines how the video content will be stretched to fill the target area.
---@field aspectRatio UnityEngine.Video.VideoAspectRatio
--- Overall transparency level of the target camera plane video.
---@field targetCameraAlpha number
--- Type of 3D content contained in the source video media.
---@field targetCamera3DLayout UnityEngine.Video.Video3DLayout
--- Internal texture in which video content is placed. (Read Only)
---@field texture UnityEngine.Texture
--- Whether the VideoPlayer has successfully prepared the content to be played. (Read Only)
---@field isPrepared boolean
--- Determines whether the VideoPlayer will wait for the first frame to be loaded into the texture before starting playback when Video.VideoPlayer.playOnAwake is on.
---@field waitForFirstFrame boolean
--- Whether the content will start playing back as soon as the component awakes.
---@field playOnAwake boolean
--- Whether content is being played. (Read Only)
---@field isPlaying boolean
--- Whether playback is paused. (Read Only)
---@field isPaused boolean
--- Whether current time can be changed using the time or timeFrames property. (Read Only)
---@field canSetTime boolean
--- The presentation time of the currently available frame in VideoPlayer.texture.
---@field time number
--- The frame index of the currently available frame in VideoPlayer.texture.
---@field frame integer
--- The clock time that the VideoPlayer follows to schedule its samples. The clock time is expressed in seconds. (Read Only)
---@field clockTime number
--- Returns true if the VideoPlayer can step forward through the video content. (Read Only)
---@field canStep boolean
--- Whether the playback speed can be changed. (Read Only)
---@field canSetPlaybackSpeed boolean
--- Factor by which the basic playback rate will be multiplied.
---@field playbackSpeed number
--- Determines whether the VideoPlayer restarts from the beginning when it reaches the end of the clip.
---@field isLooping boolean
--- Whether the time source followed by the VideoPlayer can be changed. (Read Only)
---@field canSetTimeSource boolean
--- [NOT YET IMPLEMENTED] The source used used by the VideoPlayer to derive its current time.
---@field timeSource UnityEngine.Video.VideoTimeSource
--- The clock that the Video.VideoPlayer observes to detect and correct drift.
---@field timeReference UnityEngine.Video.VideoTimeReference
--- Reference time of the external clock the Video.VideoPlayer uses to correct its drift.
---@field externalReferenceTime number
--- Whether frame-skipping to maintain synchronization can be controlled. (Read Only)
---@field canSetSkipOnDrop boolean
--- Whether the VideoPlayer is allowed to skip frames to catch up with current time.
---@field skipOnDrop boolean
--- Number of frames in the current video content. (Read Only)
---@field frameCount integer
--- The frame rate of the clip or URL in frames/second. (Read Only)
---@field frameRate number
--- The length of the VideoClip, or the URL, in seconds. (Read Only)
---@field length number
--- The width of the images in the VideoClip, or URL, in pixels. (Read Only)
---@field width integer
--- The height of the images in the VideoClip, or URL, in pixels. (Read Only)
---@field height integer
--- Numerator of the pixel aspect ratio (num:den) for the VideoClip or the URL. (Read Only)
---@field pixelAspectRatioNumerator integer
--- Denominator of the pixel aspect ratio (num:den) for the VideoClip or the URL. (Read Only)
---@field pixelAspectRatioDenominator integer
--- Number of audio tracks found in the data source currently configured. (Read Only)
---@field audioTrackCount integer
--- Number of audio tracks that this VideoPlayer will take control of.
---@field controlledAudioTrackCount integer
--- Destination for the audio embedded in the video.
---@field audioOutputMode UnityEngine.Video.VideoAudioOutputMode
--- Whether direct-output volume controls are supported for the current platform and video format. (Read Only)
---@field canSetDirectAudioVolume boolean
--- Enables the frameReady events.
---@field sendFrameReadyEvents boolean
local VideoPlayer_Impl = {}

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Impl:prepareCompleted(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Impl:loopPointReached(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Impl:started(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Impl:frameDropped(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, message: string)
function VideoPlayer_Impl:errorReceived(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Impl:seekCompleted(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, seconds: number)
function VideoPlayer_Impl:clockResyncOccurred(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, frameIdx: integer)
function VideoPlayer_Impl:frameReady(action, callback) end

--- Initiates playback engine preparation.
function VideoPlayer_Impl:Prepare() end

--- Starts playback.
function VideoPlayer_Impl:Play() end

--- Pauses the playback and leaves the current time intact.
function VideoPlayer_Impl:Pause() end

--- Stops the playback and sets the current time to 0.
function VideoPlayer_Impl:Stop() end

--- Advances the current time by one frame immediately.
function VideoPlayer_Impl:StepForward() end

--- Returns the language code, if any, for the specified track.
---@param trackIndex integer Index of the audio track to query.
---@return string ret Language code.
function VideoPlayer_Impl:GetAudioLanguageCode(trackIndex) end

--- The number of audio channels in the specified audio track.
---@param trackIndex integer Index for the audio track being queried.
---@return integer ret Number of audio channels.
function VideoPlayer_Impl:GetAudioChannelCount(trackIndex) end

--- Gets the audio track sampling rate in Hertz.
---@param trackIndex integer Index of the audio track to query.
---@return integer ret The sampling rate in Hertz.
function VideoPlayer_Impl:GetAudioSampleRate(trackIndex) end

--- Enable/disable audio track decoding. Only effective when the VideoPlayer is not currently playing.
---@param trackIndex integer Index of the audio track to enable/disable.
---@param enabled boolean True for enabling the track. False for disabling the track.
function VideoPlayer_Impl:EnableAudioTrack(trackIndex, enabled) end

--- Whether decoding for the specified audio track is enabled. See Video.VideoPlayer.EnableAudioTrack for distinction with mute.
---@param trackIndex integer Index of the audio track being queried.
---@return boolean ret Returns true if decoding for the specified audio track is enabled.
function VideoPlayer_Impl:IsAudioTrackEnabled(trackIndex) end

--- Return the direct-output volume for specified track.
---@param trackIndex integer Track index for which the volume is queried.
---@return number ret Volume, between 0 and 1.
function VideoPlayer_Impl:GetDirectAudioVolume(trackIndex) end

--- Set the direct-output audio volume for the specified track.
---@param trackIndex integer Track index for which the volume is set.
---@param volume number New volume, between 0 and 1.
function VideoPlayer_Impl:SetDirectAudioVolume(trackIndex, volume) end

--- Gets the direct-output audio mute status for the specified track.
---@param trackIndex integer 
---@return boolean ret 
function VideoPlayer_Impl:GetDirectAudioMute(trackIndex) end

--- Set the direct-output audio mute status for the specified track.
---@param trackIndex integer Track index for which the mute is set.
---@param mute boolean Mute on/off.
function VideoPlayer_Impl:SetDirectAudioMute(trackIndex, mute) end

--- Gets the AudioSource that will receive audio samples for the specified track if Video.VideoPlayer.audioOutputMode is set to Video.VideoAudioOutputMode.AudioSource.
---@param trackIndex integer Index of the audio track for which the AudioSource is wanted.
---@return UnityEngine.AudioSource ret The source associated with the audio track.
function VideoPlayer_Impl:GetTargetAudioSource(trackIndex) end

--- Sets the AudioSource that will receive audio samples for the specified track if this audio target is selected with Video.VideoPlayer.audioOutputMode.
---@param trackIndex integer Index of the audio track to associate with the specified AudioSource.
---@param source UnityEngine.AudioSource AudioSource to associate with the audio track.
function VideoPlayer_Impl:SetTargetAudioSource(trackIndex, source) end

---@class Static.UnityEngine.Video.VideoPlayer
--- Maximum number of audio tracks that can be controlled. (Read Only)
---@field controlledAudioTrackMaxCount integer
---@overload fun(): UnityEngine.Video.VideoPlayer (Constructor)
local VideoPlayer_Static = {}

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Static.prepareCompleted(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Static.loopPointReached(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Static.started(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Static.frameDropped(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, message: string)
function VideoPlayer_Static.errorReceived(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer)
function VideoPlayer_Static.seekCompleted(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, seconds: number)
function VideoPlayer_Static.clockResyncOccurred(action, callback) end

---@param action string
---|"'+'"  # add callback
---|"'-'"  # remove callback
---@param callback fun(source: UnityEngine.Video.VideoPlayer, frameIdx: integer)
function VideoPlayer_Static.frameReady(action, callback) end


---@type Static.UnityEngine.Video.VideoPlayer
UnityEngine.Video.VideoPlayer = VideoPlayer_Static

--------------------------------------------------------------------------------

