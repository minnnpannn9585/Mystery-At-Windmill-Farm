--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- System.Collections.Generic
System.Collections.Generic = {}

---@class System.Collections.Generic.List<T> : IReadOnlyList<T>, System.Collections.ICollection, IEnumerable<T>, System.Collections.IEnumerable, IList<T>, IReadOnlyCollection<T>, System.Collections.IList, ICollection<T>
---@field Capacity integer
---@field Count integer
local List_Impl = {}

---@param item T 
function List_Impl:Add(item) end

---@param collection IEnumerable 
function List_Impl:AddRange(collection) end

---@return ReadOnlyCollection ret 
function List_Impl:AsReadOnly() end

---@param index integer 
---@param count integer 
---@param item T 
---@param comparer IComparer 
---@return integer ret 
function List_Impl:BinarySearch(index, count, item, comparer) end

---@param item T 
---@return integer ret 
function List_Impl:BinarySearch(item) end

---@param item T 
---@param comparer IComparer 
---@return integer ret 
function List_Impl:BinarySearch(item, comparer) end

function List_Impl:Clear() end

---@param item T 
---@return boolean ret 
function List_Impl:Contains(item) end

---@generic TOutput
---@param converter Converter 
---@return List ret 
function List_Impl:ConvertAll(converter) end

---@param array T[] 
function List_Impl:CopyTo(array) end

---@param index integer 
---@param array T[] 
---@param arrayIndex integer 
---@param count integer 
function List_Impl:CopyTo(index, array, arrayIndex, count) end

---@param array T[] 
---@param arrayIndex integer 
function List_Impl:CopyTo(array, arrayIndex) end

---@param match Predicate 
---@return boolean ret 
function List_Impl:Exists(match) end

---@param match Predicate 
---@return T ret 
function List_Impl:Find(match) end

---@param match Predicate 
---@return System.Collections.Generic.List ret 
function List_Impl:FindAll(match) end

---@param match Predicate 
---@return integer ret 
function List_Impl:FindIndex(match) end

---@param startIndex integer 
---@param match Predicate 
---@return integer ret 
function List_Impl:FindIndex(startIndex, match) end

---@param startIndex integer 
---@param count integer 
---@param match Predicate 
---@return integer ret 
function List_Impl:FindIndex(startIndex, count, match) end

---@param match Predicate 
---@return T ret 
function List_Impl:FindLast(match) end

---@param match Predicate 
---@return integer ret 
function List_Impl:FindLastIndex(match) end

---@param startIndex integer 
---@param match Predicate 
---@return integer ret 
function List_Impl:FindLastIndex(startIndex, match) end

---@param startIndex integer 
---@param count integer 
---@param match Predicate 
---@return integer ret 
function List_Impl:FindLastIndex(startIndex, count, match) end

---@param action Action 
function List_Impl:ForEach(action) end

---@return Enumerator ret 
function List_Impl:GetEnumerator() end

---@param index integer 
---@param count integer 
---@return System.Collections.Generic.List ret 
function List_Impl:GetRange(index, count) end

---@param item T 
---@return integer ret 
function List_Impl:IndexOf(item) end

---@param item T 
---@param index integer 
---@return integer ret 
function List_Impl:IndexOf(item, index) end

---@param item T 
---@param index integer 
---@param count integer 
---@return integer ret 
function List_Impl:IndexOf(item, index, count) end

---@param index integer 
---@param item T 
function List_Impl:Insert(index, item) end

---@param index integer 
---@param collection IEnumerable 
function List_Impl:InsertRange(index, collection) end

---@param item T 
---@return integer ret 
function List_Impl:LastIndexOf(item) end

---@param item T 
---@param index integer 
---@return integer ret 
function List_Impl:LastIndexOf(item, index) end

---@param item T 
---@param index integer 
---@param count integer 
---@return integer ret 
function List_Impl:LastIndexOf(item, index, count) end

---@param item T 
---@return boolean ret 
function List_Impl:Remove(item) end

---@param match Predicate 
---@return integer ret 
function List_Impl:RemoveAll(match) end

---@param index integer 
function List_Impl:RemoveAt(index) end

---@param index integer 
---@param count integer 
function List_Impl:RemoveRange(index, count) end

function List_Impl:Reverse() end

---@param index integer 
---@param count integer 
function List_Impl:Reverse(index, count) end

function List_Impl:Sort() end

---@param comparer IComparer 
function List_Impl:Sort(comparer) end

---@param index integer 
---@param count integer 
---@param comparer IComparer 
function List_Impl:Sort(index, count, comparer) end

---@param comparison Comparison 
function List_Impl:Sort(comparison) end

---@return T[] ret 
function List_Impl:ToArray() end

function List_Impl:TrimExcess() end

---@param match Predicate 
---@return boolean ret 
function List_Impl:TrueForAll(match) end

---@class Static.System.Collections.Generic.List
---@overload fun(): System.Collections.Generic.List (Constructor)
---@overload fun(capacity:integer): System.Collections.Generic.List (Constructor)
---@overload fun(collection:IEnumerable): System.Collections.Generic.List (Constructor)
local List_Static = {}


---@type Static.System.Collections.Generic.List
System.Collections.Generic.List = List_Static

--------------------------------------------------------------------------------

---@class System.Collections.Generic.Dictionary<TKey, TValue> : System.Runtime.Serialization.IDeserializationCallback, IReadOnlyDictionary<TKey, TValue>, IDictionary<TKey, TValue>, System.Runtime.Serialization.ISerializable, System.Collections.ICollection, System.Collections.IDictionary, IEnumerable<KeyValuePair>, System.Collections.IEnumerable, IReadOnlyCollection<KeyValuePair>, ICollection<KeyValuePair>
---@field Comparer IEqualityComparer
---@field Count integer
---@field Keys KeyCollection
---@field Values ValueCollection
local Dictionary_Impl = {}

---@param key TKey 
---@param value TValue 
function Dictionary_Impl:Add(key, value) end

function Dictionary_Impl:Clear() end

---@param key TKey 
---@return boolean ret 
function Dictionary_Impl:ContainsKey(key) end

---@param value TValue 
---@return boolean ret 
function Dictionary_Impl:ContainsValue(value) end

---@return Enumerator ret 
function Dictionary_Impl:GetEnumerator() end

---@param info System.Runtime.Serialization.SerializationInfo 
---@param context System.Runtime.Serialization.StreamingContext 
function Dictionary_Impl:GetObjectData(info, context) end

---@param sender System.Object 
function Dictionary_Impl:OnDeserialization(sender) end

---@param key TKey 
---@return boolean ret 
function Dictionary_Impl:Remove(key) end

---@param key TKey 
---@return boolean ret 
---@return TValue value (Out) 
function Dictionary_Impl:Remove(key) end

---@param key TKey 
---@return boolean ret 
---@return TValue value (Out) 
function Dictionary_Impl:TryGetValue(key) end

---@param key TKey 
---@param value TValue 
---@return boolean ret 
function Dictionary_Impl:TryAdd(key, value) end

---@param capacity integer 
---@return integer ret 
function Dictionary_Impl:EnsureCapacity(capacity) end

function Dictionary_Impl:TrimExcess() end

---@param capacity integer 
function Dictionary_Impl:TrimExcess(capacity) end

---@class Static.System.Collections.Generic.Dictionary
---@overload fun(): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(capacity:integer): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(comparer:IEqualityComparer): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(capacity:integer, comparer:IEqualityComparer): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(dictionary:IDictionary): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(dictionary:IDictionary, comparer:IEqualityComparer): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(collection:IEnumerable): System.Collections.Generic.Dictionary (Constructor)
---@overload fun(collection:IEnumerable, comparer:IEqualityComparer): System.Collections.Generic.Dictionary (Constructor)
local Dictionary_Static = {}


---@type Static.System.Collections.Generic.Dictionary
System.Collections.Generic.Dictionary = Dictionary_Static

--------------------------------------------------------------------------------

---@class System.Collections.Generic.HashSet<T> : System.Runtime.Serialization.IDeserializationCallback, System.Runtime.Serialization.ISerializable, IEnumerable<T>, ISet<T>, System.Collections.IEnumerable, IReadOnlyCollection<T>, ICollection<T>
---@field Count integer
---@field Comparer IEqualityComparer
local HashSet_Impl = {}

function HashSet_Impl:Clear() end

---@param item T 
---@return boolean ret 
function HashSet_Impl:Contains(item) end

---@param array T[] 
---@param arrayIndex integer 
function HashSet_Impl:CopyTo(array, arrayIndex) end

---@param item T 
---@return boolean ret 
function HashSet_Impl:Remove(item) end

---@return Enumerator ret 
function HashSet_Impl:GetEnumerator() end

---@param info System.Runtime.Serialization.SerializationInfo 
---@param context System.Runtime.Serialization.StreamingContext 
function HashSet_Impl:GetObjectData(info, context) end

---@param sender System.Object 
function HashSet_Impl:OnDeserialization(sender) end

---@param item T 
---@return boolean ret 
function HashSet_Impl:Add(item) end

---@param equalValue T 
---@return boolean ret 
---@return T actualValue (Out) 
function HashSet_Impl:TryGetValue(equalValue) end

---@param other IEnumerable 
function HashSet_Impl:UnionWith(other) end

---@param other IEnumerable 
function HashSet_Impl:IntersectWith(other) end

---@param other IEnumerable 
function HashSet_Impl:ExceptWith(other) end

---@param other IEnumerable 
function HashSet_Impl:SymmetricExceptWith(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:IsSubsetOf(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:IsProperSubsetOf(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:IsSupersetOf(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:IsProperSupersetOf(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:Overlaps(other) end

---@param other IEnumerable 
---@return boolean ret 
function HashSet_Impl:SetEquals(other) end

---@param array T[] 
function HashSet_Impl:CopyTo(array) end

---@param array T[] 
---@param arrayIndex integer 
---@param count integer 
function HashSet_Impl:CopyTo(array, arrayIndex, count) end

---@param match Predicate 
---@return integer ret 
function HashSet_Impl:RemoveWhere(match) end

---@param capacity integer 
---@return integer ret 
function HashSet_Impl:EnsureCapacity(capacity) end

function HashSet_Impl:TrimExcess() end

---@class Static.System.Collections.Generic.HashSet
---@overload fun(): System.Collections.Generic.HashSet (Constructor)
---@overload fun(comparer:IEqualityComparer): System.Collections.Generic.HashSet (Constructor)
---@overload fun(capacity:integer): System.Collections.Generic.HashSet (Constructor)
---@overload fun(collection:IEnumerable): System.Collections.Generic.HashSet (Constructor)
---@overload fun(collection:IEnumerable, comparer:IEqualityComparer): System.Collections.Generic.HashSet (Constructor)
---@overload fun(capacity:integer, comparer:IEqualityComparer): System.Collections.Generic.HashSet (Constructor)
local HashSet_Static = {}

---@return IEqualityComparer ret 
function HashSet_Static.CreateSetComparer() end


---@type Static.System.Collections.Generic.HashSet
System.Collections.Generic.HashSet = HashSet_Static

--------------------------------------------------------------------------------

---@class System.Collections.Generic.Queue<T> : System.Collections.ICollection, IEnumerable<T>, System.Collections.IEnumerable, IReadOnlyCollection<T>
---@field Count integer
local Queue_Impl = {}

function Queue_Impl:Clear() end

---@param array T[] 
---@param arrayIndex integer 
function Queue_Impl:CopyTo(array, arrayIndex) end

---@param item T 
function Queue_Impl:Enqueue(item) end

---@return Enumerator ret 
function Queue_Impl:GetEnumerator() end

---@return T ret 
function Queue_Impl:Dequeue() end

---@return boolean ret 
---@return T result (Out) 
function Queue_Impl:TryDequeue() end

---@return T ret 
function Queue_Impl:Peek() end

---@return boolean ret 
---@return T result (Out) 
function Queue_Impl:TryPeek() end

---@param item T 
---@return boolean ret 
function Queue_Impl:Contains(item) end

---@return T[] ret 
function Queue_Impl:ToArray() end

function Queue_Impl:TrimExcess() end

---@class Static.System.Collections.Generic.Queue
---@overload fun(): System.Collections.Generic.Queue (Constructor)
---@overload fun(capacity:integer): System.Collections.Generic.Queue (Constructor)
---@overload fun(collection:IEnumerable): System.Collections.Generic.Queue (Constructor)
local Queue_Static = {}


---@type Static.System.Collections.Generic.Queue
System.Collections.Generic.Queue = Queue_Static

--------------------------------------------------------------------------------

---@class System.Collections.Generic.Stack<T> : System.Collections.ICollection, IEnumerable<T>, System.Collections.IEnumerable, IReadOnlyCollection<T>
---@field Count integer
local Stack_Impl = {}

function Stack_Impl:Clear() end

---@param item T 
---@return boolean ret 
function Stack_Impl:Contains(item) end

---@param array T[] 
---@param arrayIndex integer 
function Stack_Impl:CopyTo(array, arrayIndex) end

---@return Enumerator ret 
function Stack_Impl:GetEnumerator() end

function Stack_Impl:TrimExcess() end

---@return T ret 
function Stack_Impl:Peek() end

---@return boolean ret 
---@return T result (Out) 
function Stack_Impl:TryPeek() end

---@return T ret 
function Stack_Impl:Pop() end

---@return boolean ret 
---@return T result (Out) 
function Stack_Impl:TryPop() end

---@param item T 
function Stack_Impl:Push(item) end

---@return T[] ret 
function Stack_Impl:ToArray() end

---@class Static.System.Collections.Generic.Stack
---@overload fun(): System.Collections.Generic.Stack (Constructor)
---@overload fun(capacity:integer): System.Collections.Generic.Stack (Constructor)
---@overload fun(collection:IEnumerable): System.Collections.Generic.Stack (Constructor)
local Stack_Static = {}


---@type Static.System.Collections.Generic.Stack
System.Collections.Generic.Stack = Stack_Static

--------------------------------------------------------------------------------

---@class System.Collections.Generic.IEnumerable<T> : System.Collections.IEnumerable
local IEnumerable_Impl = {}

---@return IEnumerator ret 
function IEnumerable_Impl:GetEnumerator() end

--------------------------------------------------------------------------------

