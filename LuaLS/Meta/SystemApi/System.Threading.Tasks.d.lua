--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- System.Threading.Tasks
System.Threading.Tasks = {}

---@class System.Threading.Tasks.Task : System.IAsyncResult, System.Threading.IThreadPoolWorkItem, System.IDisposable
---@field Id integer
---@field Exception System.AggregateException
---@field Status System.Threading.Tasks.TaskStatus
---@field IsCanceled boolean
---@field IsCompleted boolean
---@field IsCompletedSuccessfully boolean
---@field CreationOptions System.Threading.Tasks.TaskCreationOptions
---@field AsyncState System.Object
---@field IsFaulted boolean
local Task_Impl = {}

function Task_Impl:Start() end

---@param scheduler System.Threading.Tasks.TaskScheduler 
function Task_Impl:Start(scheduler) end

function Task_Impl:RunSynchronously() end

---@param scheduler System.Threading.Tasks.TaskScheduler 
function Task_Impl:RunSynchronously(scheduler) end

function Task_Impl:Dispose() end

---@return System.Runtime.CompilerServices.TaskAwaiter ret 
function Task_Impl:GetAwaiter() end

---@param continueOnCapturedContext boolean 
---@return System.Runtime.CompilerServices.ConfiguredTaskAwaitable ret 
function Task_Impl:ConfigureAwait(continueOnCapturedContext) end

function Task_Impl:Wait() end

---@param timeout System.TimeSpan 
---@return boolean ret 
function Task_Impl:Wait(timeout) end

---@param cancellationToken System.Threading.CancellationToken 
function Task_Impl:Wait(cancellationToken) end

---@param millisecondsTimeout integer 
---@return boolean ret 
function Task_Impl:Wait(millisecondsTimeout) end

---@param millisecondsTimeout integer 
---@param cancellationToken System.Threading.CancellationToken 
---@return boolean ret 
function Task_Impl:Wait(millisecondsTimeout, cancellationToken) end

---@param continuationAction fun() 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction) end

---@param continuationAction fun() 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, cancellationToken) end

---@param continuationAction fun() 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, scheduler) end

---@param continuationAction fun() 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, continuationOptions) end

---@param continuationAction fun() 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, cancellationToken, continuationOptions, scheduler) end

---@param continuationAction fun() 
---@param state System.Object 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state) end

---@param continuationAction fun() 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, cancellationToken) end

---@param continuationAction fun() 
---@param state System.Object 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, scheduler) end

---@param continuationAction fun() 
---@param state System.Object 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, continuationOptions) end

---@param continuationAction fun() 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, cancellationToken, continuationOptions, scheduler) end

---@generic TResult
---@param continuationFunction Func 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction) end

---@generic TResult
---@param continuationFunction Func 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, cancellationToken) end

---@generic TResult
---@param continuationFunction Func 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, scheduler) end

---@generic TResult
---@param continuationFunction Func 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, continuationOptions) end

---@generic TResult
---@param continuationFunction Func 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, cancellationToken, continuationOptions, scheduler) end

---@generic TResult
---@param continuationFunction Func 
---@param state System.Object 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state) end

---@generic TResult
---@param continuationFunction Func 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, cancellationToken) end

---@generic TResult
---@param continuationFunction Func 
---@param state System.Object 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, scheduler) end

---@generic TResult
---@param continuationFunction Func 
---@param state System.Object 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, continuationOptions) end

---@generic TResult
---@param continuationFunction Func 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, cancellationToken, continuationOptions, scheduler) end

---@param e System.Threading.ThreadAbortException 
function Task_Impl:MarkAborted(e) end

---@class Static.System.Threading.Tasks.Task
---@field CurrentId System.Nullable
---@field Factory System.Threading.Tasks.TaskFactory
---@field CompletedTask System.Threading.Tasks.Task
---@overload fun(action:fun()): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), cancellationToken:System.Threading.CancellationToken): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), cancellationToken:System.Threading.CancellationToken, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), state:System.Object): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), state:System.Object, cancellationToken:System.Threading.CancellationToken): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), state:System.Object, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(action:fun(), state:System.Object, cancellationToken:System.Threading.CancellationToken, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
local Task_Static = {}

---@return System.Runtime.CompilerServices.YieldAwaitable ret 
function Task_Static.Yield() end

---@param tasks System.Threading.Tasks.Task[] 
function Task_Static.WaitAll(tasks) end

---@param tasks System.Threading.Tasks.Task[] 
---@param timeout System.TimeSpan 
---@return boolean ret 
function Task_Static.WaitAll(tasks, timeout) end

---@param tasks System.Threading.Tasks.Task[] 
---@param millisecondsTimeout integer 
---@return boolean ret 
function Task_Static.WaitAll(tasks, millisecondsTimeout) end

---@param tasks System.Threading.Tasks.Task[] 
---@param cancellationToken System.Threading.CancellationToken 
function Task_Static.WaitAll(tasks, cancellationToken) end

---@param tasks System.Threading.Tasks.Task[] 
---@param millisecondsTimeout integer 
---@param cancellationToken System.Threading.CancellationToken 
---@return boolean ret 
function Task_Static.WaitAll(tasks, millisecondsTimeout, cancellationToken) end

---@param tasks System.Threading.Tasks.Task[] 
---@return integer ret 
function Task_Static.WaitAny(tasks) end

---@param tasks System.Threading.Tasks.Task[] 
---@param timeout System.TimeSpan 
---@return integer ret 
function Task_Static.WaitAny(tasks, timeout) end

---@param tasks System.Threading.Tasks.Task[] 
---@param cancellationToken System.Threading.CancellationToken 
---@return integer ret 
function Task_Static.WaitAny(tasks, cancellationToken) end

---@param tasks System.Threading.Tasks.Task[] 
---@param millisecondsTimeout integer 
---@return integer ret 
function Task_Static.WaitAny(tasks, millisecondsTimeout) end

---@param tasks System.Threading.Tasks.Task[] 
---@param millisecondsTimeout integer 
---@param cancellationToken System.Threading.CancellationToken 
---@return integer ret 
function Task_Static.WaitAny(tasks, millisecondsTimeout, cancellationToken) end

---@generic TResult
---@param result TResult 
---@return Task ret 
function Task_Static.FromResult(result) end

---@param exception System.Exception 
---@return System.Threading.Tasks.Task ret 
function Task_Static.FromException(exception) end

---@generic TResult
---@param exception System.Exception 
---@return Task ret 
function Task_Static.FromException(exception) end

---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Static.FromCanceled(cancellationToken) end

---@generic TResult
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Static.FromCanceled(cancellationToken) end

---@param action fun() 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Run(action) end

---@param action fun() 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Run(action, cancellationToken) end

---@generic TResult
---@param function Func 
---@return Task ret 
function Task_Static.Run(function) end

---@generic TResult
---@param function Func 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Static.Run(function, cancellationToken) end

---@param function System.Func 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Run(function) end

---@param function System.Func 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Run(function, cancellationToken) end

---@generic TResult
---@param function Func 
---@return Task ret 
function Task_Static.Run(function) end

---@generic TResult
---@param function Func 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Static.Run(function, cancellationToken) end

---@param delay System.TimeSpan 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Delay(delay) end

---@param delay System.TimeSpan 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Delay(delay, cancellationToken) end

---@param millisecondsDelay integer 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Delay(millisecondsDelay) end

---@param millisecondsDelay integer 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Static.Delay(millisecondsDelay, cancellationToken) end

---@param tasks System.Collections.Generic.IEnumerable 
---@return System.Threading.Tasks.Task ret 
function Task_Static.WhenAll(tasks) end

---@param tasks System.Threading.Tasks.Task[] 
---@return System.Threading.Tasks.Task ret 
function Task_Static.WhenAll(tasks) end

---@generic TResult
---@param tasks IEnumerable 
---@return Task ret 
function Task_Static.WhenAll(tasks) end

---@generic TResult
---@param tasks Task 
---@return Task ret 
function Task_Static.WhenAll(tasks) end

---@param tasks System.Threading.Tasks.Task[] 
---@return System.Threading.Tasks.Task ret 
function Task_Static.WhenAny(tasks) end

---@param tasks System.Collections.Generic.IEnumerable 
---@return System.Threading.Tasks.Task ret 
function Task_Static.WhenAny(tasks) end

---@generic TResult
---@param tasks Task 
---@return Task ret 
function Task_Static.WhenAny(tasks) end

---@generic TResult
---@param tasks IEnumerable 
---@return Task ret 
function Task_Static.WhenAny(tasks) end

---@generic TResult
---@param outerTask System.Threading.Tasks.Task 
---@param lookForOce boolean 
---@return Task ret 
function Task_Static.CreateUnwrapPromise(outerTask, lookForOce) end


---@type Static.System.Threading.Tasks.Task
System.Threading.Tasks.Task = Task_Static

--------------------------------------------------------------------------------

---@class System.Threading.Tasks.Task<TResult> : System.Threading.Tasks.Task, System.IAsyncResult, System.Threading.IThreadPoolWorkItem, System.IDisposable
---@field Result TResult
local Task_Impl = {}

---@return TaskAwaiter ret 
function Task_Impl:GetAwaiter() end

---@param continueOnCapturedContext boolean 
---@return ConfiguredTaskAwaitable ret 
function Task_Impl:ConfigureAwait(continueOnCapturedContext) end

---@param continuationAction Action 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction) end

---@param continuationAction Action 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, cancellationToken) end

---@param continuationAction Action 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, scheduler) end

---@param continuationAction Action 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, continuationOptions) end

---@param continuationAction Action 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, cancellationToken, continuationOptions, scheduler) end

---@param continuationAction Action 
---@param state System.Object 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state) end

---@param continuationAction Action 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, cancellationToken) end

---@param continuationAction Action 
---@param state System.Object 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, scheduler) end

---@param continuationAction Action 
---@param state System.Object 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, continuationOptions) end

---@param continuationAction Action 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return System.Threading.Tasks.Task ret 
function Task_Impl:ContinueWith(continuationAction, state, cancellationToken, continuationOptions, scheduler) end

---@generic TNewResult
---@param continuationFunction Func 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction) end

---@generic TNewResult
---@param continuationFunction Func 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, cancellationToken) end

---@generic TNewResult
---@param continuationFunction Func 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, scheduler) end

---@generic TNewResult
---@param continuationFunction Func 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, continuationOptions) end

---@generic TNewResult
---@param continuationFunction Func 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, cancellationToken, continuationOptions, scheduler) end

---@generic TNewResult
---@param continuationFunction Func 
---@param state System.Object 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state) end

---@generic TNewResult
---@param continuationFunction Func 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, cancellationToken) end

---@generic TNewResult
---@param continuationFunction Func 
---@param state System.Object 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, scheduler) end

---@generic TNewResult
---@param continuationFunction Func 
---@param state System.Object 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, continuationOptions) end

---@generic TNewResult
---@param continuationFunction Func 
---@param state System.Object 
---@param cancellationToken System.Threading.CancellationToken 
---@param continuationOptions System.Threading.Tasks.TaskContinuationOptions 
---@param scheduler System.Threading.Tasks.TaskScheduler 
---@return Task ret 
function Task_Impl:ContinueWith(continuationFunction, state, cancellationToken, continuationOptions, scheduler) end

---@class Static.System.Threading.Tasks.Task
---@field Factory TaskFactory
---@overload fun(function:Func): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, cancellationToken:System.Threading.CancellationToken): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, cancellationToken:System.Threading.CancellationToken, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, state:System.Object): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, state:System.Object, cancellationToken:System.Threading.CancellationToken): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, state:System.Object, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
---@overload fun(function:Func, state:System.Object, cancellationToken:System.Threading.CancellationToken, creationOptions:System.Threading.Tasks.TaskCreationOptions): System.Threading.Tasks.Task (Constructor)
local Task_Static = {}


---@type Static.System.Threading.Tasks.Task
System.Threading.Tasks.Task = Task_Static

--------------------------------------------------------------------------------

