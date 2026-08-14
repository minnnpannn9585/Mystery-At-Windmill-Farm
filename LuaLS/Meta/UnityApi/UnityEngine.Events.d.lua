--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- UnityEngine.Events
UnityEngine.Events = {}

--- The mode that a listener is operating in.
---@enum UnityEngine.Events.PersistentListenerMode
local PersistentListenerMode_Enum = {
    --- The listener will use the function binding specified by the event.
    EventDefined = 0,
    --- The listener will bind to zero argument functions.
    Void = 1,
    --- The listener will bind to one argument Object functions.
    Object = 2,
    --- The listener will bind to one argument int functions.
    Int = 3,
    --- The listener will bind to one argument float functions.
    Float = 4,
    --- The listener will bind to one argument string functions.
    String = 5,
    --- The listener will bind to one argument bool functions.
    Bool = 6,
}
UnityEngine.Events.PersistentListenerMode = PersistentListenerMode_Enum

--- Controls the scope of UnityEvent callbacks.
---@enum UnityEngine.Events.UnityEventCallState
local UnityEventCallState_Enum = {
    --- Callback is not issued.
    Off = 0,
    --- Callback is always issued.
    EditorAndRuntime = 1,
    --- Callback is only issued in the Runtime and Editor playmode.
    RuntimeOnly = 2,
}
UnityEngine.Events.UnityEventCallState = UnityEventCallState_Enum

---@class UnityEngine.Events.UnityEventTools
local UnityEventTools_Impl = {}

---@class Static.UnityEngine.Events.UnityEventTools
---@overload fun(): UnityEngine.Events.UnityEventTools (Constructor)
local UnityEventTools_Static = {}


---@type Static.UnityEngine.Events.UnityEventTools
UnityEngine.Events.UnityEventTools = UnityEventTools_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.ArgumentCache : UnityEngine.ISerializationCallbackReceiver
---@field unityObjectArgument UnityEngine.Object
---@field unityObjectArgumentAssemblyTypeName string
---@field intArgument integer
---@field floatArgument number
---@field stringArgument string
---@field boolArgument boolean
local ArgumentCache_Impl = {}

function ArgumentCache_Impl:OnBeforeSerialize() end

function ArgumentCache_Impl:OnAfterDeserialize() end

---@class Static.UnityEngine.Events.ArgumentCache
---@overload fun(): UnityEngine.Events.ArgumentCache (Constructor)
local ArgumentCache_Static = {}


---@type Static.UnityEngine.Events.ArgumentCache
UnityEngine.Events.ArgumentCache = ArgumentCache_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.BaseInvokableCall
local BaseInvokableCall_Impl = {}

---@param args System.Object[] 
function BaseInvokableCall_Impl:Invoke(args) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function BaseInvokableCall_Impl:Find(targetObj, method) end

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCall : UnityEngine.Events.BaseInvokableCall
local InvokableCall_Impl = {}

---@param args System.Object[] 
function InvokableCall_Impl:Invoke(args) end

function InvokableCall_Impl:Invoke() end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function InvokableCall_Impl:Find(targetObj, method) end

---@class Static.UnityEngine.Events.InvokableCall
---@overload fun(target:System.Object, theFunction:System.Reflection.MethodInfo): UnityEngine.Events.InvokableCall (Constructor)
---@overload fun(action:fun()): UnityEngine.Events.InvokableCall (Constructor)
local InvokableCall_Static = {}


---@type Static.UnityEngine.Events.InvokableCall
UnityEngine.Events.InvokableCall = InvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCall<T1> : UnityEngine.Events.BaseInvokableCall
local InvokableCall_Impl = {}

---@param args System.Object[] 
function InvokableCall_Impl:Invoke(args) end

---@param args0 T1 
function InvokableCall_Impl:Invoke(args0) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function InvokableCall_Impl:Find(targetObj, method) end

---@class Static.UnityEngine.Events.InvokableCall
---@overload fun(target:System.Object, theFunction:System.Reflection.MethodInfo): UnityEngine.Events.InvokableCall (Constructor)
---@overload fun(action:UnityAction): UnityEngine.Events.InvokableCall (Constructor)
local InvokableCall_Static = {}


---@type Static.UnityEngine.Events.InvokableCall
UnityEngine.Events.InvokableCall = InvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCall<T1, T2> : UnityEngine.Events.BaseInvokableCall
local InvokableCall_Impl = {}

---@param args System.Object[] 
function InvokableCall_Impl:Invoke(args) end

---@param args0 T1 
---@param args1 T2 
function InvokableCall_Impl:Invoke(args0, args1) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function InvokableCall_Impl:Find(targetObj, method) end

---@class Static.UnityEngine.Events.InvokableCall
---@overload fun(target:System.Object, theFunction:System.Reflection.MethodInfo): UnityEngine.Events.InvokableCall (Constructor)
---@overload fun(action:UnityAction): UnityEngine.Events.InvokableCall (Constructor)
local InvokableCall_Static = {}


---@type Static.UnityEngine.Events.InvokableCall
UnityEngine.Events.InvokableCall = InvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCall<T1, T2, T3> : UnityEngine.Events.BaseInvokableCall
local InvokableCall_Impl = {}

---@param args System.Object[] 
function InvokableCall_Impl:Invoke(args) end

---@param args0 T1 
---@param args1 T2 
---@param args2 T3 
function InvokableCall_Impl:Invoke(args0, args1, args2) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function InvokableCall_Impl:Find(targetObj, method) end

---@class Static.UnityEngine.Events.InvokableCall
---@overload fun(target:System.Object, theFunction:System.Reflection.MethodInfo): UnityEngine.Events.InvokableCall (Constructor)
---@overload fun(action:UnityAction): UnityEngine.Events.InvokableCall (Constructor)
local InvokableCall_Static = {}


---@type Static.UnityEngine.Events.InvokableCall
UnityEngine.Events.InvokableCall = InvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCall<T1, T2, T3, T4> : UnityEngine.Events.BaseInvokableCall
local InvokableCall_Impl = {}

---@param args System.Object[] 
function InvokableCall_Impl:Invoke(args) end

---@param args0 T1 
---@param args1 T2 
---@param args2 T3 
---@param args3 T4 
function InvokableCall_Impl:Invoke(args0, args1, args2, args3) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
---@return boolean ret 
function InvokableCall_Impl:Find(targetObj, method) end

---@class Static.UnityEngine.Events.InvokableCall
---@overload fun(target:System.Object, theFunction:System.Reflection.MethodInfo): UnityEngine.Events.InvokableCall (Constructor)
---@overload fun(action:UnityAction): UnityEngine.Events.InvokableCall (Constructor)
local InvokableCall_Static = {}


---@type Static.UnityEngine.Events.InvokableCall
UnityEngine.Events.InvokableCall = InvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.CachedInvokableCall<T> : InvokableCall<T>
local CachedInvokableCall_Impl = {}

---@param args System.Object[] 
function CachedInvokableCall_Impl:Invoke(args) end

---@param arg0 T 
function CachedInvokableCall_Impl:Invoke(arg0) end

---@class Static.UnityEngine.Events.CachedInvokableCall
---@overload fun(target:UnityEngine.Object, theFunction:System.Reflection.MethodInfo, argument:T): UnityEngine.Events.CachedInvokableCall (Constructor)
local CachedInvokableCall_Static = {}


---@type Static.UnityEngine.Events.CachedInvokableCall
UnityEngine.Events.CachedInvokableCall = CachedInvokableCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.PersistentCall : UnityEngine.ISerializationCallbackReceiver
---@field target UnityEngine.Object
---@field targetAssemblyTypeName string
---@field methodName string
---@field mode UnityEngine.Events.PersistentListenerMode
---@field arguments UnityEngine.Events.ArgumentCache
---@field callState UnityEngine.Events.UnityEventCallState
local PersistentCall_Impl = {}

---@return boolean ret 
function PersistentCall_Impl:IsValid() end

---@param theEvent UnityEngine.Events.UnityEventBase 
---@return UnityEngine.Events.BaseInvokableCall ret 
function PersistentCall_Impl:GetRuntimeCall(theEvent) end

---@param ttarget UnityEngine.Object 
---@param targetType System.Type 
---@param mmethodName string 
function PersistentCall_Impl:RegisterPersistentListener(ttarget, targetType, mmethodName) end

function PersistentCall_Impl:UnregisterPersistentListener() end

function PersistentCall_Impl:OnBeforeSerialize() end

function PersistentCall_Impl:OnAfterDeserialize() end

---@class Static.UnityEngine.Events.PersistentCall
---@overload fun(): UnityEngine.Events.PersistentCall (Constructor)
local PersistentCall_Static = {}


---@type Static.UnityEngine.Events.PersistentCall
UnityEngine.Events.PersistentCall = PersistentCall_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.PersistentCallGroup
---@field Count integer
local PersistentCallGroup_Impl = {}

---@param index integer 
---@return UnityEngine.Events.PersistentCall ret 
function PersistentCallGroup_Impl:GetListener(index) end

---@return System.Collections.Generic.IEnumerable ret 
function PersistentCallGroup_Impl:GetListeners() end

function PersistentCallGroup_Impl:AddListener() end

---@param call UnityEngine.Events.PersistentCall 
function PersistentCallGroup_Impl:AddListener(call) end

---@param index integer 
function PersistentCallGroup_Impl:RemoveListener(index) end

function PersistentCallGroup_Impl:Clear() end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterEventPersistentListener(index, targetObj, targetObjType, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterVoidPersistentListener(index, targetObj, targetObjType, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param argument UnityEngine.Object 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterObjectPersistentListener(index, targetObj, targetObjType, argument, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param argument integer 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterIntPersistentListener(index, targetObj, targetObjType, argument, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param argument number 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterFloatPersistentListener(index, targetObj, targetObjType, argument, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param argument string 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterStringPersistentListener(index, targetObj, targetObjType, argument, methodName) end

---@param index integer 
---@param targetObj UnityEngine.Object 
---@param targetObjType System.Type 
---@param argument boolean 
---@param methodName string 
function PersistentCallGroup_Impl:RegisterBoolPersistentListener(index, targetObj, targetObjType, argument, methodName) end

---@param index integer 
function PersistentCallGroup_Impl:UnregisterPersistentListener(index) end

---@param target UnityEngine.Object 
---@param methodName string 
function PersistentCallGroup_Impl:RemoveListeners(target, methodName) end

---@param invokableList UnityEngine.Events.InvokableCallList 
---@param unityEventBase UnityEngine.Events.UnityEventBase 
function PersistentCallGroup_Impl:Initialize(invokableList, unityEventBase) end

---@class Static.UnityEngine.Events.PersistentCallGroup
---@overload fun(): UnityEngine.Events.PersistentCallGroup (Constructor)
local PersistentCallGroup_Static = {}


---@type Static.UnityEngine.Events.PersistentCallGroup
UnityEngine.Events.PersistentCallGroup = PersistentCallGroup_Static

--------------------------------------------------------------------------------

---@class UnityEngine.Events.InvokableCallList
---@field Count integer
local InvokableCallList_Impl = {}

---@param call UnityEngine.Events.BaseInvokableCall 
function InvokableCallList_Impl:AddPersistentInvokableCall(call) end

---@param call UnityEngine.Events.BaseInvokableCall 
function InvokableCallList_Impl:AddListener(call) end

---@param targetObj System.Object 
---@param method System.Reflection.MethodInfo 
function InvokableCallList_Impl:RemoveListener(targetObj, method) end

function InvokableCallList_Impl:Clear() end

function InvokableCallList_Impl:ClearPersistent() end

---@return System.Collections.Generic.List ret 
function InvokableCallList_Impl:PrepareInvoke() end

---@class Static.UnityEngine.Events.InvokableCallList
---@overload fun(): UnityEngine.Events.InvokableCallList (Constructor)
local InvokableCallList_Static = {}


---@type Static.UnityEngine.Events.InvokableCallList
UnityEngine.Events.InvokableCallList = InvokableCallList_Static

--------------------------------------------------------------------------------

--- Abstract base class for UnityEvents.
---@class UnityEngine.Events.UnityEventBase : UnityEngine.ISerializationCallbackReceiver
local UnityEventBase_Impl = {}

--- Get the number of registered persistent listeners.
---@return integer ret 
function UnityEventBase_Impl:GetPersistentEventCount() end

--- Get the target component of the listener at index index.
---@param index integer Index of the listener to query.
---@return UnityEngine.Object ret 
function UnityEventBase_Impl:GetPersistentTarget(index) end

--- Get the target method name of the listener at index index.
---@param index integer Index of the listener to query.
---@return string ret 
function UnityEventBase_Impl:GetPersistentMethodName(index) end

--- Modify the execution state of a persistent listener.
---@param index integer Index of the listener to query.
---@param state UnityEngine.Events.UnityEventCallState State to set.
function UnityEventBase_Impl:SetPersistentListenerState(index, state) end

--- Returns the execution state of a persistent listener.
---@param index integer Index of the listener to query.
---@return UnityEngine.Events.UnityEventCallState ret Execution state of the persistent listener.
function UnityEventBase_Impl:GetPersistentListenerState(index) end

--- Remove all non-persisent (ie created from script) listeners from the event.
function UnityEventBase_Impl:RemoveAllListeners() end

---@return string ret 
function UnityEventBase_Impl:ToString() end

---@class Static.UnityEngine.Events.UnityEventBase
local UnityEventBase_Static = {}

--- Given an object, function name, and a list of argument types; find the method that matches.
---@param obj System.Object Object to search for the method.
---@param functionName string Function name to search for.
---@param argumentTypes System.Type[] Argument types for the function.
---@return System.Reflection.MethodInfo ret 
function UnityEventBase_Static.GetValidMethodInfo(obj, functionName, argumentTypes) end

--- Given an object type, function name, and a list of argument types; find the method that matches.
---@param objectType System.Type Object type to search for the method.
---@param functionName string Function name to search for.
---@param argumentTypes System.Type[] Argument types for the function.
---@return System.Reflection.MethodInfo ret 
function UnityEventBase_Static.GetValidMethodInfo(objectType, functionName, argumentTypes) end


---@type Static.UnityEngine.Events.UnityEventBase
UnityEngine.Events.UnityEventBase = UnityEventBase_Static

--------------------------------------------------------------------------------

--- A zero argument persistent callback that can be saved with the Scene.
---@class UnityEngine.Events.UnityEvent : UnityEngine.Events.UnityEventBase, UnityEngine.ISerializationCallbackReceiver
local UnityEvent_Impl = {}

--- Add a non persistent listener to the UnityEvent.
---@param call fun() Callback function.
function UnityEvent_Impl:AddListener(call) end

--- Remove a non persistent listener from the UnityEvent. If you have added the same listener multiple times, this method will remove all occurrences of it.
---@param call fun() Callback function.
function UnityEvent_Impl:RemoveListener(call) end

--- Invoke all registered callbacks (runtime and persistent).
function UnityEvent_Impl:Invoke() end

---@class Static.UnityEngine.Events.UnityEvent
---@overload fun(): UnityEngine.Events.UnityEvent (Constructor)
local UnityEvent_Static = {}


---@type Static.UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEvent_Static

--------------------------------------------------------------------------------

--- One argument version of UnityEvent.
---@class UnityEngine.Events.UnityEvent<T0> : UnityEngine.Events.UnityEventBase, UnityEngine.ISerializationCallbackReceiver
local UnityEvent_Impl = {}

---@param call UnityAction 
function UnityEvent_Impl:AddListener(call) end

---@param call UnityAction 
function UnityEvent_Impl:RemoveListener(call) end

---@param arg0 T0 
function UnityEvent_Impl:Invoke(arg0) end

---@class Static.UnityEngine.Events.UnityEvent
---@overload fun(): UnityEngine.Events.UnityEvent (Constructor)
local UnityEvent_Static = {}


---@type Static.UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEvent_Static

--------------------------------------------------------------------------------

--- Two argument version of UnityEvent.
---@class UnityEngine.Events.UnityEvent<T0, T1> : UnityEngine.Events.UnityEventBase, UnityEngine.ISerializationCallbackReceiver
local UnityEvent_Impl = {}

---@param call UnityAction 
function UnityEvent_Impl:AddListener(call) end

---@param call UnityAction 
function UnityEvent_Impl:RemoveListener(call) end

---@param arg0 T0 
---@param arg1 T1 
function UnityEvent_Impl:Invoke(arg0, arg1) end

---@class Static.UnityEngine.Events.UnityEvent
---@overload fun(): UnityEngine.Events.UnityEvent (Constructor)
local UnityEvent_Static = {}


---@type Static.UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEvent_Static

--------------------------------------------------------------------------------

--- Three argument version of UnityEvent.
---@class UnityEngine.Events.UnityEvent<T0, T1, T2> : UnityEngine.Events.UnityEventBase, UnityEngine.ISerializationCallbackReceiver
local UnityEvent_Impl = {}

---@param call UnityAction 
function UnityEvent_Impl:AddListener(call) end

---@param call UnityAction 
function UnityEvent_Impl:RemoveListener(call) end

---@param arg0 T0 
---@param arg1 T1 
---@param arg2 T2 
function UnityEvent_Impl:Invoke(arg0, arg1, arg2) end

---@class Static.UnityEngine.Events.UnityEvent
---@overload fun(): UnityEngine.Events.UnityEvent (Constructor)
local UnityEvent_Static = {}


---@type Static.UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEvent_Static

--------------------------------------------------------------------------------

--- Four argument version of UnityEvent.
---@class UnityEngine.Events.UnityEvent<T0, T1, T2, T3> : UnityEngine.Events.UnityEventBase, UnityEngine.ISerializationCallbackReceiver
local UnityEvent_Impl = {}

---@param call UnityAction 
function UnityEvent_Impl:AddListener(call) end

---@param call UnityAction 
function UnityEvent_Impl:RemoveListener(call) end

---@param arg0 T0 
---@param arg1 T1 
---@param arg2 T2 
---@param arg3 T3 
function UnityEvent_Impl:Invoke(arg0, arg1, arg2, arg3) end

---@class Static.UnityEngine.Events.UnityEvent
---@overload fun(): UnityEngine.Events.UnityEvent (Constructor)
local UnityEvent_Static = {}


---@type Static.UnityEngine.Events.UnityEvent
UnityEngine.Events.UnityEvent = UnityEvent_Static

--------------------------------------------------------------------------------

