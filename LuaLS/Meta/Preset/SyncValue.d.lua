---@meta _
---@diagnostic disable

---@class __SyncValue<T>
local SyncValue_Impl = {}

--- get current stored synced variable
---@return T
function SyncValue_Impl:GetValue() end

---@param val T
function SyncValue_Impl:SetValue(val) end

---@param callback fun(curVal: T, preVal: T)
function SyncValue_Impl:OnValueChanged(callback) end

---@class __SyncList<T>
local SyncList_Impl = {}

--- get value at index
---@return T
function SyncList_Impl:GetValue(arrIdx) end

--- set value at index
---@param arrIdx integer
---@param val T
function SyncList_Impl:SetValue(arrIdx, val) end

---@param callback fun()
function SyncList_Impl:OnValueChanged(callback) end

---@return integer
function SyncList_Impl:Count() end

---@param callback fun(val:T, idx:integer)
function SyncList_Impl:ForEach(callback) end

--- clear storage
function SyncList_Impl:Clear() end

--- Append value 
---@param val T
function SyncList_Impl:Add(val) end

--- insert element at index
---@param arrIdx integer
---@param val T
function SyncList_Impl:Insert(arrIdx,val) end

--- remove element
---@param arrIdx integer
function SyncList_Impl:RemoveAt(arrIdx) end

---@class __SyncDictionary<T,U>
local SyncDictionary_Impl = {}

---@param key T
---@return U
function SyncDictionary_Impl:GetValue(key) end

--- add or change dictionary value
---@param key T
---@param val U
function SyncDictionary_Impl:SetValue(key, val) end

---@param key T
---@return boolean
function SyncDictionary_Impl:ContainsKey(key) end

---@param callback fun()
function SyncDictionary_Impl:OnValueChanged(callback) end

---@return integer
function SyncDictionary_Impl:Count() end

---@param callback fun(val:U, key:T)
function SyncDictionary_Impl:ForEach(callback) end

--- clear storage
function SyncDictionary_Impl:Clear() end

--- remove dictionary item
---@param key T
function SyncDictionary_Impl:Remove(key) end