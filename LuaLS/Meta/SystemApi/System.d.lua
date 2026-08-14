--- ⚠️ 本文件由工具自动生成，请勿手动修改
--- Generated automatically. DO NOT EDIT MANUALLY.

---@meta _
---@diagnostic disable

--- System
System = {}

---@class System.Object
local Object_Impl = {}

---@param obj System.Object 
---@return boolean ret 
function Object_Impl:Equals(obj) end

---@return integer ret 
function Object_Impl:GetHashCode() end

---@return System.Type ret 
function Object_Impl:GetType() end

---@return string ret 
function Object_Impl:ToString() end

---@class Static.System.Object
---@overload fun(): System.Object (Constructor)
local Object_Static = {}

---@param objA System.Object 
---@param objB System.Object 
---@return boolean ret 
function Object_Static.Equals(objA, objB) end

---@param objA System.Object 
---@param objB System.Object 
---@return boolean ret 
function Object_Static.ReferenceEquals(objA, objB) end


---@type Static.System.Object
System.Object = Object_Static

--------------------------------------------------------------------------------

---@class System.String : System.ICloneable, System.IComparable, System.IComparable<System.String>, System.IConvertible, System.Collections.Generic.IEnumerable<System.Char>, System.Collections.IEnumerable, System.IEquatable<System.String>
---@field Length integer
local String_Impl = {}

---@param value System.Object 
---@return integer ret 
function String_Impl:CompareTo(value) end

---@param strB string 
---@return integer ret 
function String_Impl:CompareTo(strB) end

---@param value string 
---@return boolean ret 
function String_Impl:EndsWith(value) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Impl:EndsWith(value, comparisonType) end

---@param value string 
---@param ignoreCase boolean 
---@param culture System.Globalization.CultureInfo 
---@return boolean ret 
function String_Impl:EndsWith(value, ignoreCase, culture) end

---@param value System.Char 
---@return boolean ret 
function String_Impl:EndsWith(value) end

---@param obj System.Object 
---@return boolean ret 
function String_Impl:Equals(obj) end

---@param value string 
---@return boolean ret 
function String_Impl:Equals(value) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Impl:Equals(value, comparisonType) end

---@return integer ret 
function String_Impl:GetHashCode() end

---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:GetHashCode(comparisonType) end

---@param value string 
---@return boolean ret 
function String_Impl:StartsWith(value) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Impl:StartsWith(value, comparisonType) end

---@param value string 
---@param ignoreCase boolean 
---@param culture System.Globalization.CultureInfo 
---@return boolean ret 
function String_Impl:StartsWith(value, ignoreCase, culture) end

---@param value System.Char 
---@return boolean ret 
function String_Impl:StartsWith(value) end

---@param startIndex integer 
---@param value string 
---@return string ret 
function String_Impl:Insert(startIndex, value) end

---@param totalWidth integer 
---@return string ret 
function String_Impl:PadLeft(totalWidth) end

---@param totalWidth integer 
---@param paddingChar System.Char 
---@return string ret 
function String_Impl:PadLeft(totalWidth, paddingChar) end

---@param totalWidth integer 
---@return string ret 
function String_Impl:PadRight(totalWidth) end

---@param totalWidth integer 
---@param paddingChar System.Char 
---@return string ret 
function String_Impl:PadRight(totalWidth, paddingChar) end

---@param startIndex integer 
---@param count integer 
---@return string ret 
function String_Impl:Remove(startIndex, count) end

---@param startIndex integer 
---@return string ret 
function String_Impl:Remove(startIndex) end

---@param oldValue string 
---@param newValue string 
---@param ignoreCase boolean 
---@param culture System.Globalization.CultureInfo 
---@return string ret 
function String_Impl:Replace(oldValue, newValue, ignoreCase, culture) end

---@param oldValue string 
---@param newValue string 
---@param comparisonType System.StringComparison 
---@return string ret 
function String_Impl:Replace(oldValue, newValue, comparisonType) end

---@param oldChar System.Char 
---@param newChar System.Char 
---@return string ret 
function String_Impl:Replace(oldChar, newChar) end

---@param oldValue string 
---@param newValue string 
---@return string ret 
function String_Impl:Replace(oldValue, newValue) end

---@param separator System.Char 
---@param options? System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, options) end

---@param separator System.Char 
---@param count integer 
---@param options? System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, count, options) end

---@param separator System.Char[] 
---@return string[] ret 
function String_Impl:Split(separator) end

---@param separator System.Char[] 
---@param count integer 
---@return string[] ret 
function String_Impl:Split(separator, count) end

---@param separator System.Char[] 
---@param options System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, options) end

---@param separator System.Char[] 
---@param count integer 
---@param options System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, count, options) end

---@param separator string 
---@param options? System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, options) end

---@param separator string 
---@param count integer 
---@param options? System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, count, options) end

---@param separator string[] 
---@param options System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, options) end

---@param separator string[] 
---@param count integer 
---@param options System.StringSplitOptions 
---@return string[] ret 
function String_Impl:Split(separator, count, options) end

---@param startIndex integer 
---@return string ret 
function String_Impl:Substring(startIndex) end

---@param startIndex integer 
---@param length integer 
---@return string ret 
function String_Impl:Substring(startIndex, length) end

---@return string ret 
function String_Impl:ToLower() end

---@param culture System.Globalization.CultureInfo 
---@return string ret 
function String_Impl:ToLower(culture) end

---@return string ret 
function String_Impl:ToLowerInvariant() end

---@return string ret 
function String_Impl:ToUpper() end

---@param culture System.Globalization.CultureInfo 
---@return string ret 
function String_Impl:ToUpper(culture) end

---@return string ret 
function String_Impl:ToUpperInvariant() end

---@return string ret 
function String_Impl:Trim() end

---@param trimChar System.Char 
---@return string ret 
function String_Impl:Trim(trimChar) end

---@param trimChars System.Char[] 
---@return string ret 
function String_Impl:Trim(trimChars) end

---@return string ret 
function String_Impl:TrimStart() end

---@param trimChar System.Char 
---@return string ret 
function String_Impl:TrimStart(trimChar) end

---@param trimChars System.Char[] 
---@return string ret 
function String_Impl:TrimStart(trimChars) end

---@return string ret 
function String_Impl:TrimEnd() end

---@param trimChar System.Char 
---@return string ret 
function String_Impl:TrimEnd(trimChar) end

---@param trimChars System.Char[] 
---@return string ret 
function String_Impl:TrimEnd(trimChars) end

---@param value string 
---@return boolean ret 
function String_Impl:Contains(value) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Impl:Contains(value, comparisonType) end

---@param value System.Char 
---@return boolean ret 
function String_Impl:Contains(value) end

---@param value System.Char 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Impl:Contains(value, comparisonType) end

---@param value System.Char 
---@return integer ret 
function String_Impl:IndexOf(value) end

---@param value System.Char 
---@param startIndex integer 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex) end

---@param value System.Char 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:IndexOf(value, comparisonType) end

---@param value System.Char 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex, count) end

---@param anyOf System.Char[] 
---@return integer ret 
function String_Impl:IndexOfAny(anyOf) end

---@param anyOf System.Char[] 
---@param startIndex integer 
---@return integer ret 
function String_Impl:IndexOfAny(anyOf, startIndex) end

---@param anyOf System.Char[] 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:IndexOfAny(anyOf, startIndex, count) end

---@param value string 
---@return integer ret 
function String_Impl:IndexOf(value) end

---@param value string 
---@param startIndex integer 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex) end

---@param value string 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex, count) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:IndexOf(value, comparisonType) end

---@param value string 
---@param startIndex integer 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex, comparisonType) end

---@param value string 
---@param startIndex integer 
---@param count integer 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:IndexOf(value, startIndex, count, comparisonType) end

---@param value System.Char 
---@return integer ret 
function String_Impl:LastIndexOf(value) end

---@param value System.Char 
---@param startIndex integer 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex) end

---@param value System.Char 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex, count) end

---@param anyOf System.Char[] 
---@return integer ret 
function String_Impl:LastIndexOfAny(anyOf) end

---@param anyOf System.Char[] 
---@param startIndex integer 
---@return integer ret 
function String_Impl:LastIndexOfAny(anyOf, startIndex) end

---@param anyOf System.Char[] 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:LastIndexOfAny(anyOf, startIndex, count) end

---@param value string 
---@return integer ret 
function String_Impl:LastIndexOf(value) end

---@param value string 
---@param startIndex integer 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex) end

---@param value string 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex, count) end

---@param value string 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:LastIndexOf(value, comparisonType) end

---@param value string 
---@param startIndex integer 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex, comparisonType) end

---@param value string 
---@param startIndex integer 
---@param count integer 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Impl:LastIndexOf(value, startIndex, count, comparisonType) end

---@return System.Object ret 
function String_Impl:Clone() end

---@param sourceIndex integer 
---@param destination System.Char[] 
---@param destinationIndex integer 
---@param count integer 
function String_Impl:CopyTo(sourceIndex, destination, destinationIndex, count) end

---@return System.Char[] ret 
function String_Impl:ToCharArray() end

---@param startIndex integer 
---@param length integer 
---@return System.Char[] ret 
function String_Impl:ToCharArray(startIndex, length) end

---@return string ret 
function String_Impl:ToString() end

---@param provider System.IFormatProvider 
---@return string ret 
function String_Impl:ToString(provider) end

---@return System.CharEnumerator ret 
function String_Impl:GetEnumerator() end

---@return System.TypeCode ret 
function String_Impl:GetTypeCode() end

---@return boolean ret 
function String_Impl:IsNormalized() end

---@param normalizationForm System.Text.NormalizationForm 
---@return boolean ret 
function String_Impl:IsNormalized(normalizationForm) end

---@return string ret 
function String_Impl:Normalize() end

---@param normalizationForm System.Text.NormalizationForm 
---@return string ret 
function String_Impl:Normalize(normalizationForm) end

---@class Static.System.String
---@field Empty string
---@overload fun(value:System.Char[]): System.String (Constructor)
---@overload fun(value:System.Char[], startIndex:integer, length:integer): System.String (Constructor)
---@overload fun(value:System.Char*): System.String (Constructor)
---@overload fun(value:System.Char*, startIndex:integer, length:integer): System.String (Constructor)
---@overload fun(value:System.SByte*): System.String (Constructor)
---@overload fun(value:System.SByte*, startIndex:integer, length:integer): System.String (Constructor)
---@overload fun(value:System.SByte*, startIndex:integer, length:integer, enc:System.Text.Encoding): System.String (Constructor)
---@overload fun(c:System.Char, count:integer): System.String (Constructor)
---@overload fun(value:System.ReadOnlySpan): System.String (Constructor)
local String_Static = {}

---@param strA string 
---@param strB string 
---@return integer ret 
function String_Static.Compare(strA, strB) end

---@param strA string 
---@param strB string 
---@param ignoreCase boolean 
---@return integer ret 
function String_Static.Compare(strA, strB, ignoreCase) end

---@param strA string 
---@param strB string 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Static.Compare(strA, strB, comparisonType) end

---@param strA string 
---@param strB string 
---@param culture System.Globalization.CultureInfo 
---@param options System.Globalization.CompareOptions 
---@return integer ret 
function String_Static.Compare(strA, strB, culture, options) end

---@param strA string 
---@param strB string 
---@param ignoreCase boolean 
---@param culture System.Globalization.CultureInfo 
---@return integer ret 
function String_Static.Compare(strA, strB, ignoreCase, culture) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@return integer ret 
function String_Static.Compare(strA, indexA, strB, indexB, length) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@param ignoreCase boolean 
---@return integer ret 
function String_Static.Compare(strA, indexA, strB, indexB, length, ignoreCase) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@param ignoreCase boolean 
---@param culture System.Globalization.CultureInfo 
---@return integer ret 
function String_Static.Compare(strA, indexA, strB, indexB, length, ignoreCase, culture) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@param culture System.Globalization.CultureInfo 
---@param options System.Globalization.CompareOptions 
---@return integer ret 
function String_Static.Compare(strA, indexA, strB, indexB, length, culture, options) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@param comparisonType System.StringComparison 
---@return integer ret 
function String_Static.Compare(strA, indexA, strB, indexB, length, comparisonType) end

---@param strA string 
---@param strB string 
---@return integer ret 
function String_Static.CompareOrdinal(strA, strB) end

---@param strA string 
---@param indexA integer 
---@param strB string 
---@param indexB integer 
---@param length integer 
---@return integer ret 
function String_Static.CompareOrdinal(strA, indexA, strB, indexB, length) end

---@param a string 
---@param b string 
---@return boolean ret 
function String_Static.Equals(a, b) end

---@param a string 
---@param b string 
---@param comparisonType System.StringComparison 
---@return boolean ret 
function String_Static.Equals(a, b, comparisonType) end

---@param arg0 System.Object 
---@return string ret 
function String_Static.Concat(arg0) end

---@param arg0 System.Object 
---@param arg1 System.Object 
---@return string ret 
function String_Static.Concat(arg0, arg1) end

---@param arg0 System.Object 
---@param arg1 System.Object 
---@param arg2 System.Object 
---@return string ret 
function String_Static.Concat(arg0, arg1, arg2) end

---@param args System.Object[] 
---@return string ret 
function String_Static.Concat(args) end

---@generic T
---@param values IEnumerable 
---@return string ret 
function String_Static.Concat(values) end

---@param values System.Collections.Generic.IEnumerable 
---@return string ret 
function String_Static.Concat(values) end

---@param str0 string 
---@param str1 string 
---@return string ret 
function String_Static.Concat(str0, str1) end

---@param str0 string 
---@param str1 string 
---@param str2 string 
---@return string ret 
function String_Static.Concat(str0, str1, str2) end

---@param str0 string 
---@param str1 string 
---@param str2 string 
---@param str3 string 
---@return string ret 
function String_Static.Concat(str0, str1, str2, str3) end

---@param values string[] 
---@return string ret 
function String_Static.Concat(values) end

---@param format string 
---@param arg0 System.Object 
---@return string ret 
function String_Static.Format(format, arg0) end

---@param format string 
---@param arg0 System.Object 
---@param arg1 System.Object 
---@return string ret 
function String_Static.Format(format, arg0, arg1) end

---@param format string 
---@param arg0 System.Object 
---@param arg1 System.Object 
---@param arg2 System.Object 
---@return string ret 
function String_Static.Format(format, arg0, arg1, arg2) end

---@param format string 
---@param args System.Object[] 
---@return string ret 
function String_Static.Format(format, args) end

---@param provider System.IFormatProvider 
---@param format string 
---@param arg0 System.Object 
---@return string ret 
function String_Static.Format(provider, format, arg0) end

---@param provider System.IFormatProvider 
---@param format string 
---@param arg0 System.Object 
---@param arg1 System.Object 
---@return string ret 
function String_Static.Format(provider, format, arg0, arg1) end

---@param provider System.IFormatProvider 
---@param format string 
---@param arg0 System.Object 
---@param arg1 System.Object 
---@param arg2 System.Object 
---@return string ret 
function String_Static.Format(provider, format, arg0, arg1, arg2) end

---@param provider System.IFormatProvider 
---@param format string 
---@param args System.Object[] 
---@return string ret 
function String_Static.Format(provider, format, args) end

---@param separator System.Char 
---@param value string[] 
---@return string ret 
function String_Static.Join(separator, value) end

---@param separator System.Char 
---@param values System.Object[] 
---@return string ret 
function String_Static.Join(separator, values) end

---@generic T
---@param separator System.Char 
---@param values IEnumerable 
---@return string ret 
function String_Static.Join(separator, values) end

---@param separator System.Char 
---@param value string[] 
---@param startIndex integer 
---@param count integer 
---@return string ret 
function String_Static.Join(separator, value, startIndex, count) end

---@param separator string 
---@param value string[] 
---@return string ret 
function String_Static.Join(separator, value) end

---@param separator string 
---@param values System.Object[] 
---@return string ret 
function String_Static.Join(separator, values) end

---@generic T
---@param separator string 
---@param values IEnumerable 
---@return string ret 
function String_Static.Join(separator, values) end

---@param separator string 
---@param values System.Collections.Generic.IEnumerable 
---@return string ret 
function String_Static.Join(separator, values) end

---@param separator string 
---@param value string[] 
---@param startIndex integer 
---@param count integer 
---@return string ret 
function String_Static.Join(separator, value, startIndex, count) end

---@generic TState
---@param length integer 
---@param state TState 
---@param action SpanAction 
---@return string ret 
function String_Static.Create(length, state, action) end

---@param str string 
---@return string ret 
function String_Static.Copy(str) end

---@param value string 
---@return boolean ret 
function String_Static.IsNullOrEmpty(value) end

---@param value string 
---@return boolean ret 
function String_Static.IsNullOrWhiteSpace(value) end

---@param arg0 System.Object 
---@param arg1 System.Object 
---@param arg2 System.Object 
---@param arg3 System.Object 
---@return string ret 
function String_Static.Concat(arg0, arg1, arg2, arg3) end

---@param str string 
---@return string ret 
function String_Static.Intern(str) end

---@param str string 
---@return string ret 
function String_Static.IsInterned(str) end


---@type Static.System.String
System.String = String_Static

--------------------------------------------------------------------------------

---@class System.Array : System.Collections.IStructuralComparable, System.Collections.IStructuralEquatable, System.ICloneable, System.Collections.ICollection, System.Collections.IEnumerable, System.Collections.IList
---@field LongLength integer
---@field IsFixedSize boolean
---@field IsReadOnly boolean
---@field IsSynchronized boolean
---@field SyncRoot System.Object
---@field Length integer
---@field Rank integer
local Array_Impl = {}

---@param array System.Array 
---@param index integer 
function Array_Impl:CopyTo(array, index) end

---@return System.Object ret 
function Array_Impl:Clone() end

---@param array System.Array 
---@param index integer 
function Array_Impl:CopyTo(array, index) end

---@param dimension integer 
---@return integer ret 
function Array_Impl:GetLongLength(dimension) end

---@param index integer 
---@return System.Object ret 
function Array_Impl:GetValue(index) end

---@param index1 integer 
---@param index2 integer 
---@return System.Object ret 
function Array_Impl:GetValue(index1, index2) end

---@param index1 integer 
---@param index2 integer 
---@param index3 integer 
---@return System.Object ret 
function Array_Impl:GetValue(index1, index2, index3) end

---@param indices integer[] 
---@return System.Object ret 
function Array_Impl:GetValue(indices) end

---@param value System.Object 
---@param index integer 
function Array_Impl:SetValue(value, index) end

---@param value System.Object 
---@param index1 integer 
---@param index2 integer 
function Array_Impl:SetValue(value, index1, index2) end

---@param value System.Object 
---@param index1 integer 
---@param index2 integer 
---@param index3 integer 
function Array_Impl:SetValue(value, index1, index2, index3) end

---@param value System.Object 
---@param indices integer[] 
function Array_Impl:SetValue(value, indices) end

---@return System.Collections.IEnumerator ret 
function Array_Impl:GetEnumerator() end

---@param dimension integer 
---@return integer ret 
function Array_Impl:GetLength(dimension) end

---@param dimension integer 
---@return integer ret 
function Array_Impl:GetLowerBound(dimension) end

---@param indices integer[] 
---@return System.Object ret 
function Array_Impl:GetValue(indices) end

---@param value System.Object 
---@param indices integer[] 
function Array_Impl:SetValue(value, indices) end

---@param dimension integer 
---@return integer ret 
function Array_Impl:GetUpperBound(dimension) end

---@param index integer 
---@return System.Object ret 
function Array_Impl:GetValue(index) end

---@param index1 integer 
---@param index2 integer 
---@return System.Object ret 
function Array_Impl:GetValue(index1, index2) end

---@param index1 integer 
---@param index2 integer 
---@param index3 integer 
---@return System.Object ret 
function Array_Impl:GetValue(index1, index2, index3) end

---@param value System.Object 
---@param index integer 
function Array_Impl:SetValue(value, index) end

---@param value System.Object 
---@param index1 integer 
---@param index2 integer 
function Array_Impl:SetValue(value, index1, index2) end

---@param value System.Object 
---@param index1 integer 
---@param index2 integer 
---@param index3 integer 
function Array_Impl:SetValue(value, index1, index2, index3) end

function Array_Impl:Initialize() end

---@class Static.System.Array
local Array_Static = {}

---@param elementType System.Type 
---@param lengths integer[] 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, lengths) end

---@generic T
---@param array T[] 
---@return ReadOnlyCollection ret 
function Array_Static.AsReadOnly(array) end

---@generic T
---@param array T[] 
---@param newSize integer 
---@return T[] array (Ref) 
function Array_Static.Resize(array, newSize) end

---@param array System.Array 
---@param value System.Object 
---@return integer ret 
function Array_Static.BinarySearch(array, value) end

---@generic TInput
---@generic TOutput
---@param array TInput[] 
---@param converter Converter 
---@return TOutput[] ret 
function Array_Static.ConvertAll(array, converter) end

---@param sourceArray System.Array 
---@param destinationArray System.Array 
---@param length integer 
function Array_Static.Copy(sourceArray, destinationArray, length) end

---@param sourceArray System.Array 
---@param sourceIndex integer 
---@param destinationArray System.Array 
---@param destinationIndex integer 
---@param length integer 
function Array_Static.Copy(sourceArray, sourceIndex, destinationArray, destinationIndex, length) end

---@generic T
---@param array T[] 
---@param action Action 
function Array_Static.ForEach(array, action) end

---@param array System.Array 
---@param index integer 
---@param length integer 
---@param value System.Object 
---@return integer ret 
function Array_Static.BinarySearch(array, index, length, value) end

---@param array System.Array 
---@param value System.Object 
---@param comparer System.Collections.IComparer 
---@return integer ret 
function Array_Static.BinarySearch(array, value, comparer) end

---@param array System.Array 
---@param index integer 
---@param length integer 
---@param value System.Object 
---@param comparer System.Collections.IComparer 
---@return integer ret 
function Array_Static.BinarySearch(array, index, length, value, comparer) end

---@generic T
---@param array T[] 
---@param value T 
---@return integer ret 
function Array_Static.BinarySearch(array, value) end

---@generic T
---@param array T[] 
---@param value T 
---@param comparer IComparer 
---@return integer ret 
function Array_Static.BinarySearch(array, value, comparer) end

---@generic T
---@param array T[] 
---@param index integer 
---@param length integer 
---@param value T 
---@return integer ret 
function Array_Static.BinarySearch(array, index, length, value) end

---@generic T
---@param array T[] 
---@param index integer 
---@param length integer 
---@param value T 
---@param comparer IComparer 
---@return integer ret 
function Array_Static.BinarySearch(array, index, length, value, comparer) end

---@param array System.Array 
---@param value System.Object 
---@return integer ret 
function Array_Static.IndexOf(array, value) end

---@param array System.Array 
---@param value System.Object 
---@param startIndex integer 
---@return integer ret 
function Array_Static.IndexOf(array, value, startIndex) end

---@param array System.Array 
---@param value System.Object 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function Array_Static.IndexOf(array, value, startIndex, count) end

---@generic T
---@param array T[] 
---@param value T 
---@return integer ret 
function Array_Static.IndexOf(array, value) end

---@generic T
---@param array T[] 
---@param value T 
---@param startIndex integer 
---@return integer ret 
function Array_Static.IndexOf(array, value, startIndex) end

---@generic T
---@param array T[] 
---@param value T 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function Array_Static.IndexOf(array, value, startIndex, count) end

---@param array System.Array 
---@param value System.Object 
---@return integer ret 
function Array_Static.LastIndexOf(array, value) end

---@param array System.Array 
---@param value System.Object 
---@param startIndex integer 
---@return integer ret 
function Array_Static.LastIndexOf(array, value, startIndex) end

---@param array System.Array 
---@param value System.Object 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function Array_Static.LastIndexOf(array, value, startIndex, count) end

---@generic T
---@param array T[] 
---@param value T 
---@return integer ret 
function Array_Static.LastIndexOf(array, value) end

---@generic T
---@param array T[] 
---@param value T 
---@param startIndex integer 
---@return integer ret 
function Array_Static.LastIndexOf(array, value, startIndex) end

---@generic T
---@param array T[] 
---@param value T 
---@param startIndex integer 
---@param count integer 
---@return integer ret 
function Array_Static.LastIndexOf(array, value, startIndex, count) end

---@param array System.Array 
function Array_Static.Reverse(array) end

---@param array System.Array 
---@param index integer 
---@param length integer 
function Array_Static.Reverse(array, index, length) end

---@generic T
---@param array T[] 
function Array_Static.Reverse(array) end

---@generic T
---@param array T[] 
---@param index integer 
---@param length integer 
function Array_Static.Reverse(array, index, length) end

---@param array System.Array 
function Array_Static.Sort(array) end

---@param array System.Array 
---@param index integer 
---@param length integer 
function Array_Static.Sort(array, index, length) end

---@param array System.Array 
---@param comparer System.Collections.IComparer 
function Array_Static.Sort(array, comparer) end

---@param array System.Array 
---@param index integer 
---@param length integer 
---@param comparer System.Collections.IComparer 
function Array_Static.Sort(array, index, length, comparer) end

---@param keys System.Array 
---@param items System.Array 
function Array_Static.Sort(keys, items) end

---@param keys System.Array 
---@param items System.Array 
---@param comparer System.Collections.IComparer 
function Array_Static.Sort(keys, items, comparer) end

---@param keys System.Array 
---@param items System.Array 
---@param index integer 
---@param length integer 
function Array_Static.Sort(keys, items, index, length) end

---@param keys System.Array 
---@param items System.Array 
---@param index integer 
---@param length integer 
---@param comparer System.Collections.IComparer 
function Array_Static.Sort(keys, items, index, length, comparer) end

---@generic T
---@param array T[] 
function Array_Static.Sort(array) end

---@generic T
---@param array T[] 
---@param index integer 
---@param length integer 
function Array_Static.Sort(array, index, length) end

---@generic T
---@param array T[] 
---@param comparer IComparer 
function Array_Static.Sort(array, comparer) end

---@generic T
---@param array T[] 
---@param index integer 
---@param length integer 
---@param comparer IComparer 
function Array_Static.Sort(array, index, length, comparer) end

---@generic T
---@param array T[] 
---@param comparison Comparison 
function Array_Static.Sort(array, comparison) end

---@generic TKey
---@generic TValue
---@param keys TKey[] 
---@param items TValue[] 
function Array_Static.Sort(keys, items) end

---@generic TKey
---@generic TValue
---@param keys TKey[] 
---@param items TValue[] 
---@param index integer 
---@param length integer 
function Array_Static.Sort(keys, items, index, length) end

---@generic TKey
---@generic TValue
---@param keys TKey[] 
---@param items TValue[] 
---@param comparer IComparer 
function Array_Static.Sort(keys, items, comparer) end

---@generic TKey
---@generic TValue
---@param keys TKey[] 
---@param items TValue[] 
---@param index integer 
---@param length integer 
---@param comparer IComparer 
function Array_Static.Sort(keys, items, index, length, comparer) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return boolean ret 
function Array_Static.Exists(array, match) end

---@generic T
---@param array T[] 
---@param value T 
function Array_Static.Fill(array, value) end

---@generic T
---@param array T[] 
---@param value T 
---@param startIndex integer 
---@param count integer 
function Array_Static.Fill(array, value, startIndex, count) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return T ret 
function Array_Static.Find(array, match) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return T[] ret 
function Array_Static.FindAll(array, match) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindIndex(array, match) end

---@generic T
---@param array T[] 
---@param startIndex integer 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindIndex(array, startIndex, match) end

---@generic T
---@param array T[] 
---@param startIndex integer 
---@param count integer 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindIndex(array, startIndex, count, match) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return T ret 
function Array_Static.FindLast(array, match) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindLastIndex(array, match) end

---@generic T
---@param array T[] 
---@param startIndex integer 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindLastIndex(array, startIndex, match) end

---@generic T
---@param array T[] 
---@param startIndex integer 
---@param count integer 
---@param match Predicate 
---@return integer ret 
function Array_Static.FindLastIndex(array, startIndex, count, match) end

---@generic T
---@param array T[] 
---@param match Predicate 
---@return boolean ret 
function Array_Static.TrueForAll(array, match) end

---@param elementType System.Type 
---@param length integer 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, length) end

---@param elementType System.Type 
---@param length1 integer 
---@param length2 integer 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, length1, length2) end

---@param elementType System.Type 
---@param length1 integer 
---@param length2 integer 
---@param length3 integer 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, length1, length2, length3) end

---@param elementType System.Type 
---@param lengths integer[] 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, lengths) end

---@param elementType System.Type 
---@param lengths integer[] 
---@param lowerBounds integer[] 
---@return System.Array ret 
function Array_Static.CreateInstance(elementType, lengths, lowerBounds) end

---@param array System.Array 
---@param index integer 
---@param length integer 
function Array_Static.Clear(array, index, length) end

---@param sourceArray System.Array 
---@param destinationArray System.Array 
---@param length integer 
function Array_Static.Copy(sourceArray, destinationArray, length) end

---@param sourceArray System.Array 
---@param sourceIndex integer 
---@param destinationArray System.Array 
---@param destinationIndex integer 
---@param length integer 
function Array_Static.Copy(sourceArray, sourceIndex, destinationArray, destinationIndex, length) end

---@param sourceArray System.Array 
---@param sourceIndex integer 
---@param destinationArray System.Array 
---@param destinationIndex integer 
---@param length integer 
function Array_Static.ConstrainedCopy(sourceArray, sourceIndex, destinationArray, destinationIndex, length) end

---@generic T
---@return T[] ret 
function Array_Static.Empty() end


---@type Static.System.Array
System.Array = Array_Static

--------------------------------------------------------------------------------

---@class System.Type : System.Reflection.MemberInfo, System.Runtime.InteropServices._MemberInfo, System.Runtime.InteropServices._Type, System.Reflection.ICustomAttributeProvider, System.Reflection.IReflect
---@field IsSerializable boolean
---@field ContainsGenericParameters boolean
---@field IsVisible boolean
---@field MemberType System.Reflection.MemberTypes
---@field Namespace string
---@field AssemblyQualifiedName string
---@field FullName string
---@field Assembly System.Reflection.Assembly
---@field Module System.Reflection.Module
---@field IsNested boolean
---@field DeclaringType System.Type
---@field DeclaringMethod System.Reflection.MethodBase
---@field ReflectedType System.Type
---@field UnderlyingSystemType System.Type
---@field IsTypeDefinition boolean
---@field IsArray boolean
---@field IsByRef boolean
---@field IsPointer boolean
---@field IsConstructedGenericType boolean
---@field IsGenericParameter boolean
---@field IsGenericTypeParameter boolean
---@field IsGenericMethodParameter boolean
---@field IsGenericType boolean
---@field IsGenericTypeDefinition boolean
---@field IsSZArray boolean
---@field IsVariableBoundArray boolean
---@field IsByRefLike boolean
---@field HasElementType boolean
---@field GenericTypeArguments System.Type[]
---@field GenericParameterPosition integer
---@field GenericParameterAttributes System.Reflection.GenericParameterAttributes
---@field Attributes System.Reflection.TypeAttributes
---@field IsAbstract boolean
---@field IsImport boolean
---@field IsSealed boolean
---@field IsSpecialName boolean
---@field IsClass boolean
---@field IsNestedAssembly boolean
---@field IsNestedFamANDAssem boolean
---@field IsNestedFamily boolean
---@field IsNestedFamORAssem boolean
---@field IsNestedPrivate boolean
---@field IsNestedPublic boolean
---@field IsNotPublic boolean
---@field IsPublic boolean
---@field IsAutoLayout boolean
---@field IsExplicitLayout boolean
---@field IsLayoutSequential boolean
---@field IsAnsiClass boolean
---@field IsAutoClass boolean
---@field IsUnicodeClass boolean
---@field IsCOMObject boolean
---@field IsContextful boolean
---@field IsCollectible boolean
---@field IsEnum boolean
---@field IsMarshalByRef boolean
---@field IsPrimitive boolean
---@field IsValueType boolean
---@field IsSignatureType boolean
---@field IsSecurityCritical boolean
---@field IsSecuritySafeCritical boolean
---@field IsSecurityTransparent boolean
---@field StructLayoutAttribute System.Runtime.InteropServices.StructLayoutAttribute
---@field TypeInitializer System.Reflection.ConstructorInfo
---@field TypeHandle System.RuntimeTypeHandle
---@field GUID System.Guid
---@field BaseType System.Type
---@field IsInterface boolean
local Type_Impl = {}

---@param value System.Object 
---@return boolean ret 
function Type_Impl:IsEnumDefined(value) end

---@param value System.Object 
---@return string ret 
function Type_Impl:GetEnumName(value) end

---@return string[] ret 
function Type_Impl:GetEnumNames() end

---@param filter fun(m: System.Type, filterCriteria: System.Object): boolean 
---@param filterCriteria System.Object 
---@return System.Type[] ret 
function Type_Impl:FindInterfaces(filter, filterCriteria) end

---@param memberType System.Reflection.MemberTypes 
---@param bindingAttr System.Reflection.BindingFlags 
---@param filter fun(m: System.Reflection.MemberInfo, filterCriteria: System.Object): boolean 
---@param filterCriteria System.Object 
---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:FindMembers(memberType, bindingAttr, filter, filterCriteria) end

---@param c System.Type 
---@return boolean ret 
function Type_Impl:IsSubclassOf(c) end

---@param c System.Type 
---@return boolean ret 
function Type_Impl:IsAssignableFrom(c) end

---@return System.Type ret 
function Type_Impl:GetType() end

---@return System.Type ret 
function Type_Impl:GetElementType() end

---@return integer ret 
function Type_Impl:GetArrayRank() end

---@return System.Type ret 
function Type_Impl:GetGenericTypeDefinition() end

---@return System.Type[] ret 
function Type_Impl:GetGenericArguments() end

---@return System.Type[] ret 
function Type_Impl:GetGenericParameterConstraints() end

---@param types System.Type[] 
---@return System.Reflection.ConstructorInfo ret 
function Type_Impl:GetConstructor(types) end

---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.ConstructorInfo ret 
function Type_Impl:GetConstructor(bindingAttr, binder, types, modifiers) end

---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param callConvention System.Reflection.CallingConventions 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.ConstructorInfo ret 
function Type_Impl:GetConstructor(bindingAttr, binder, callConvention, types, modifiers) end

---@return System.Reflection.ConstructorInfo[] ret 
function Type_Impl:GetConstructors() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.ConstructorInfo[] ret 
function Type_Impl:GetConstructors(bindingAttr) end

---@param name string 
---@return System.Reflection.EventInfo ret 
function Type_Impl:GetEvent(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.EventInfo ret 
function Type_Impl:GetEvent(name, bindingAttr) end

---@return System.Reflection.EventInfo[] ret 
function Type_Impl:GetEvents() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.EventInfo[] ret 
function Type_Impl:GetEvents(bindingAttr) end

---@param name string 
---@return System.Reflection.FieldInfo ret 
function Type_Impl:GetField(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.FieldInfo ret 
function Type_Impl:GetField(name, bindingAttr) end

---@return System.Reflection.FieldInfo[] ret 
function Type_Impl:GetFields() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.FieldInfo[] ret 
function Type_Impl:GetFields(bindingAttr) end

---@param name string 
---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetMember(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetMember(name, bindingAttr) end

---@param name string 
---@param type System.Reflection.MemberTypes 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetMember(name, type, bindingAttr) end

---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetMembers() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetMembers(bindingAttr) end

---@param name string 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, bindingAttr) end

---@param name string 
---@param types System.Type[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, types) end

---@param name string 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, types, modifiers) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, bindingAttr, binder, types, modifiers) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param callConvention System.Reflection.CallingConventions 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, bindingAttr, binder, callConvention, types, modifiers) end

---@param name string 
---@param genericParameterCount integer 
---@param types System.Type[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, genericParameterCount, types) end

---@param name string 
---@param genericParameterCount integer 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, genericParameterCount, types, modifiers) end

---@param name string 
---@param genericParameterCount integer 
---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, genericParameterCount, bindingAttr, binder, types, modifiers) end

---@param name string 
---@param genericParameterCount integer 
---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param callConvention System.Reflection.CallingConventions 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.MethodInfo ret 
function Type_Impl:GetMethod(name, genericParameterCount, bindingAttr, binder, callConvention, types, modifiers) end

---@return System.Reflection.MethodInfo[] ret 
function Type_Impl:GetMethods() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.MethodInfo[] ret 
function Type_Impl:GetMethods(bindingAttr) end

---@param name string 
---@return System.Type ret 
function Type_Impl:GetNestedType(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Type ret 
function Type_Impl:GetNestedType(name, bindingAttr) end

---@return System.Type[] ret 
function Type_Impl:GetNestedTypes() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Type[] ret 
function Type_Impl:GetNestedTypes(bindingAttr) end

---@param name string 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, bindingAttr) end

---@param name string 
---@param returnType System.Type 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, returnType) end

---@param name string 
---@param types System.Type[] 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, types) end

---@param name string 
---@param returnType System.Type 
---@param types System.Type[] 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, returnType, types) end

---@param name string 
---@param returnType System.Type 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, returnType, types, modifiers) end

---@param name string 
---@param bindingAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param returnType System.Type 
---@param types System.Type[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@return System.Reflection.PropertyInfo ret 
function Type_Impl:GetProperty(name, bindingAttr, binder, returnType, types, modifiers) end

---@return System.Reflection.PropertyInfo[] ret 
function Type_Impl:GetProperties() end

---@param bindingAttr System.Reflection.BindingFlags 
---@return System.Reflection.PropertyInfo[] ret 
function Type_Impl:GetProperties(bindingAttr) end

---@return System.Reflection.MemberInfo[] ret 
function Type_Impl:GetDefaultMembers() end

---@param name string 
---@param invokeAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param target System.Object 
---@param args System.Object[] 
---@return System.Object ret 
function Type_Impl:InvokeMember(name, invokeAttr, binder, target, args) end

---@param name string 
---@param invokeAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param target System.Object 
---@param args System.Object[] 
---@param culture System.Globalization.CultureInfo 
---@return System.Object ret 
function Type_Impl:InvokeMember(name, invokeAttr, binder, target, args, culture) end

---@param name string 
---@param invokeAttr System.Reflection.BindingFlags 
---@param binder System.Reflection.Binder 
---@param target System.Object 
---@param args System.Object[] 
---@param modifiers System.Reflection.ParameterModifier[] 
---@param culture System.Globalization.CultureInfo 
---@param namedParameters string[] 
---@return System.Object ret 
function Type_Impl:InvokeMember(name, invokeAttr, binder, target, args, modifiers, culture, namedParameters) end

---@param name string 
---@return System.Type ret 
function Type_Impl:GetInterface(name) end

---@param name string 
---@param ignoreCase boolean 
---@return System.Type ret 
function Type_Impl:GetInterface(name, ignoreCase) end

---@return System.Type[] ret 
function Type_Impl:GetInterfaces() end

---@param interfaceType System.Type 
---@return System.Reflection.InterfaceMapping ret 
function Type_Impl:GetInterfaceMap(interfaceType) end

---@param o System.Object 
---@return boolean ret 
function Type_Impl:IsInstanceOfType(o) end

---@param other System.Type 
---@return boolean ret 
function Type_Impl:IsEquivalentTo(other) end

---@return System.Type ret 
function Type_Impl:GetEnumUnderlyingType() end

---@return System.Array ret 
function Type_Impl:GetEnumValues() end

---@return System.Type ret 
function Type_Impl:MakeArrayType() end

---@param rank integer 
---@return System.Type ret 
function Type_Impl:MakeArrayType(rank) end

---@return System.Type ret 
function Type_Impl:MakeByRefType() end

---@param typeArguments System.Type[] 
---@return System.Type ret 
function Type_Impl:MakeGenericType(typeArguments) end

---@return System.Type ret 
function Type_Impl:MakePointerType() end

---@return string ret 
function Type_Impl:ToString() end

---@param o System.Object 
---@return boolean ret 
function Type_Impl:Equals(o) end

---@return integer ret 
function Type_Impl:GetHashCode() end

---@param o System.Type 
---@return boolean ret 
function Type_Impl:Equals(o) end

---@class Static.System.Type
---@field DefaultBinder System.Reflection.Binder
---@field Delimiter System.Char
---@field EmptyTypes System.Type[]
---@field Missing System.Object
---@field FilterAttribute fun(m: System.Reflection.MemberInfo, filterCriteria: System.Object): boolean
---@field FilterName fun(m: System.Reflection.MemberInfo, filterCriteria: System.Object): boolean
---@field FilterNameIgnoreCase fun(m: System.Reflection.MemberInfo, filterCriteria: System.Object): boolean
local Type_Static = {}

---@param o System.Object 
---@return System.RuntimeTypeHandle ret 
function Type_Static.GetTypeHandle(o) end

---@param args System.Object[] 
---@return System.Type[] ret 
function Type_Static.GetTypeArray(args) end

---@param type System.Type 
---@return System.TypeCode ret 
function Type_Static.GetTypeCode(type) end

---@param clsid System.Guid 
---@return System.Type ret 
function Type_Static.GetTypeFromCLSID(clsid) end

---@param clsid System.Guid 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetTypeFromCLSID(clsid, throwOnError) end

---@param clsid System.Guid 
---@param server string 
---@return System.Type ret 
function Type_Static.GetTypeFromCLSID(clsid, server) end

---@param progID string 
---@return System.Type ret 
function Type_Static.GetTypeFromProgID(progID) end

---@param progID string 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetTypeFromProgID(progID, throwOnError) end

---@param progID string 
---@param server string 
---@return System.Type ret 
function Type_Static.GetTypeFromProgID(progID, server) end

---@param genericTypeDefinition System.Type 
---@param typeArguments System.Type[] 
---@return System.Type ret 
function Type_Static.MakeGenericSignatureType(genericTypeDefinition, typeArguments) end

---@param position integer 
---@return System.Type ret 
function Type_Static.MakeGenericMethodParameter(position) end

---@param handle System.RuntimeTypeHandle 
---@return System.Type ret 
function Type_Static.GetTypeFromHandle(handle) end

---@param typeName string 
---@param throwOnError boolean 
---@param ignoreCase boolean 
---@return System.Type ret 
function Type_Static.GetType(typeName, throwOnError, ignoreCase) end

---@param typeName string 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetType(typeName, throwOnError) end

---@param typeName string 
---@return System.Type ret 
function Type_Static.GetType(typeName) end

---@param typeName string 
---@param assemblyResolver System.Func 
---@param typeResolver System.Func 
---@return System.Type ret 
function Type_Static.GetType(typeName, assemblyResolver, typeResolver) end

---@param typeName string 
---@param assemblyResolver System.Func 
---@param typeResolver System.Func 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetType(typeName, assemblyResolver, typeResolver, throwOnError) end

---@param typeName string 
---@param assemblyResolver System.Func 
---@param typeResolver System.Func 
---@param throwOnError boolean 
---@param ignoreCase boolean 
---@return System.Type ret 
function Type_Static.GetType(typeName, assemblyResolver, typeResolver, throwOnError, ignoreCase) end

---@param typeName string 
---@param throwIfNotFound boolean 
---@param ignoreCase boolean 
---@return System.Type ret 
function Type_Static.ReflectionOnlyGetType(typeName, throwIfNotFound, ignoreCase) end

---@param clsid System.Guid 
---@param server string 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetTypeFromCLSID(clsid, server, throwOnError) end

---@param progID string 
---@param server string 
---@param throwOnError boolean 
---@return System.Type ret 
function Type_Static.GetTypeFromProgID(progID, server, throwOnError) end


---@type Static.System.Type
System.Type = Type_Static

--------------------------------------------------------------------------------

---@class System.DateTime : System.IFormattable, System.Runtime.Serialization.ISerializable, System.ISpanFormattable, System.IComparable, System.IComparable<System.DateTime>, System.IConvertible, System.IEquatable<System.DateTime>
---@field Date System.DateTime
---@field Day integer
---@field DayOfWeek System.DayOfWeek
---@field DayOfYear integer
---@field Hour integer
---@field Kind System.DateTimeKind
---@field Millisecond integer
---@field Minute integer
---@field Month integer
---@field Second integer
---@field Ticks integer
---@field TimeOfDay System.TimeSpan
---@field Year integer
---@operator add(System.TimeSpan):System.DateTime
---@operator sub(System.TimeSpan):System.DateTime
---@operator sub(System.DateTime):System.TimeSpan
local DateTime_Impl = {}

---@param value System.TimeSpan 
---@return System.DateTime ret 
function DateTime_Impl:Add(value) end

---@param value number 
---@return System.DateTime ret 
function DateTime_Impl:AddDays(value) end

---@param value number 
---@return System.DateTime ret 
function DateTime_Impl:AddHours(value) end

---@param value number 
---@return System.DateTime ret 
function DateTime_Impl:AddMilliseconds(value) end

---@param value number 
---@return System.DateTime ret 
function DateTime_Impl:AddMinutes(value) end

---@param months integer 
---@return System.DateTime ret 
function DateTime_Impl:AddMonths(months) end

---@param value number 
---@return System.DateTime ret 
function DateTime_Impl:AddSeconds(value) end

---@param value integer 
---@return System.DateTime ret 
function DateTime_Impl:AddTicks(value) end

---@param value integer 
---@return System.DateTime ret 
function DateTime_Impl:AddYears(value) end

---@param value System.Object 
---@return integer ret 
function DateTime_Impl:CompareTo(value) end

---@param value System.DateTime 
---@return integer ret 
function DateTime_Impl:CompareTo(value) end

---@param value System.Object 
---@return boolean ret 
function DateTime_Impl:Equals(value) end

---@param value System.DateTime 
---@return boolean ret 
function DateTime_Impl:Equals(value) end

---@return boolean ret 
function DateTime_Impl:IsDaylightSavingTime() end

---@return integer ret 
function DateTime_Impl:ToBinary() end

---@return integer ret 
function DateTime_Impl:GetHashCode() end

---@param value System.DateTime 
---@return System.TimeSpan ret 
function DateTime_Impl:Subtract(value) end

---@param value System.TimeSpan 
---@return System.DateTime ret 
function DateTime_Impl:Subtract(value) end

---@return number ret 
function DateTime_Impl:ToOADate() end

---@return integer ret 
function DateTime_Impl:ToFileTime() end

---@return integer ret 
function DateTime_Impl:ToFileTimeUtc() end

---@return System.DateTime ret 
function DateTime_Impl:ToLocalTime() end

---@return string ret 
function DateTime_Impl:ToLongDateString() end

---@return string ret 
function DateTime_Impl:ToLongTimeString() end

---@return string ret 
function DateTime_Impl:ToShortDateString() end

---@return string ret 
function DateTime_Impl:ToShortTimeString() end

---@return string ret 
function DateTime_Impl:ToString() end

---@param format string 
---@return string ret 
function DateTime_Impl:ToString(format) end

---@param provider System.IFormatProvider 
---@return string ret 
function DateTime_Impl:ToString(provider) end

---@param format string 
---@param provider System.IFormatProvider 
---@return string ret 
function DateTime_Impl:ToString(format, provider) end

---@param destination System.Span 
---@param format? System.ReadOnlySpan 
---@param provider? System.IFormatProvider 
---@return boolean ret 
---@return integer charsWritten (Out) 
function DateTime_Impl:TryFormat(destination, format, provider) end

---@return System.DateTime ret 
function DateTime_Impl:ToUniversalTime() end

---@return string[] ret 
function DateTime_Impl:GetDateTimeFormats() end

---@param provider System.IFormatProvider 
---@return string[] ret 
function DateTime_Impl:GetDateTimeFormats(provider) end

---@param format System.Char 
---@return string[] ret 
function DateTime_Impl:GetDateTimeFormats(format) end

---@param format System.Char 
---@param provider System.IFormatProvider 
---@return string[] ret 
function DateTime_Impl:GetDateTimeFormats(format, provider) end

---@return System.TypeCode ret 
function DateTime_Impl:GetTypeCode() end

---@class Static.System.DateTime
---@field Now System.DateTime
---@field Today System.DateTime
---@field UtcNow System.DateTime
---@field MinValue System.DateTime
---@field MaxValue System.DateTime
---@field UnixEpoch System.DateTime
---@overload fun(ticks:integer): System.DateTime (Constructor)
---@overload fun(ticks:integer, kind:System.DateTimeKind): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, calendar:System.Globalization.Calendar): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, kind:System.DateTimeKind): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, calendar:System.Globalization.Calendar): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, millisecond:integer): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, millisecond:integer, kind:System.DateTimeKind): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, millisecond:integer, calendar:System.Globalization.Calendar): System.DateTime (Constructor)
---@overload fun(year:integer, month:integer, day:integer, hour:integer, minute:integer, second:integer, millisecond:integer, calendar:System.Globalization.Calendar, kind:System.DateTimeKind): System.DateTime (Constructor)
---@overload fun(): System.DateTime (Constructor)
local DateTime_Static = {}

---@param t1 System.DateTime 
---@param t2 System.DateTime 
---@return integer ret 
function DateTime_Static.Compare(t1, t2) end

---@param year integer 
---@param month integer 
---@return integer ret 
function DateTime_Static.DaysInMonth(year, month) end

---@param t1 System.DateTime 
---@param t2 System.DateTime 
---@return boolean ret 
function DateTime_Static.Equals(t1, t2) end

---@param dateData integer 
---@return System.DateTime ret 
function DateTime_Static.FromBinary(dateData) end

---@param fileTime integer 
---@return System.DateTime ret 
function DateTime_Static.FromFileTime(fileTime) end

---@param fileTime integer 
---@return System.DateTime ret 
function DateTime_Static.FromFileTimeUtc(fileTime) end

---@param d number 
---@return System.DateTime ret 
function DateTime_Static.FromOADate(d) end

---@param value System.DateTime 
---@param kind System.DateTimeKind 
---@return System.DateTime ret 
function DateTime_Static.SpecifyKind(value, kind) end

---@param year integer 
---@return boolean ret 
function DateTime_Static.IsLeapYear(year) end

---@param s string 
---@return System.DateTime ret 
function DateTime_Static.Parse(s) end

---@param s string 
---@param provider System.IFormatProvider 
---@return System.DateTime ret 
function DateTime_Static.Parse(s, provider) end

---@param s string 
---@param provider System.IFormatProvider 
---@param styles System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.Parse(s, provider, styles) end

---@param s System.ReadOnlySpan 
---@param provider? System.IFormatProvider 
---@param styles? System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.Parse(s, provider, styles) end

---@param s string 
---@param format string 
---@param provider System.IFormatProvider 
---@return System.DateTime ret 
function DateTime_Static.ParseExact(s, format, provider) end

---@param s string 
---@param format string 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.ParseExact(s, format, provider, style) end

---@param s System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@param provider System.IFormatProvider 
---@param style? System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.ParseExact(s, format, provider, style) end

---@param s string 
---@param formats string[] 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.ParseExact(s, formats, provider, style) end

---@param s System.ReadOnlySpan 
---@param formats string[] 
---@param provider System.IFormatProvider 
---@param style? System.Globalization.DateTimeStyles 
---@return System.DateTime ret 
function DateTime_Static.ParseExact(s, formats, provider, style) end

---@param s string 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParse(s) end

---@param s System.ReadOnlySpan 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParse(s) end

---@param s string 
---@param provider System.IFormatProvider 
---@param styles System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParse(s, provider, styles) end

---@param s System.ReadOnlySpan 
---@param provider System.IFormatProvider 
---@param styles System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParse(s, provider, styles) end

---@param s string 
---@param format string 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParseExact(s, format, provider, style) end

---@param s System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParseExact(s, format, provider, style) end

---@param s string 
---@param formats string[] 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParseExact(s, formats, provider, style) end

---@param s System.ReadOnlySpan 
---@param formats string[] 
---@param provider System.IFormatProvider 
---@param style System.Globalization.DateTimeStyles 
---@return boolean ret 
---@return System.DateTime result (Out) 
function DateTime_Static.TryParseExact(s, formats, provider, style) end


---@type Static.System.DateTime
System.DateTime = DateTime_Static

--------------------------------------------------------------------------------

---@class System.TimeSpan : System.IFormattable, System.ISpanFormattable, System.IComparable, System.IComparable<System.TimeSpan>, System.IEquatable<System.TimeSpan>
---@field Ticks integer
---@field Days integer
---@field Hours integer
---@field Milliseconds integer
---@field Minutes integer
---@field Seconds integer
---@field TotalDays number
---@field TotalHours number
---@field TotalMilliseconds number
---@field TotalMinutes number
---@field TotalSeconds number
---@operator unm(System.TimeSpan):System.TimeSpan
---@operator sub(System.TimeSpan):System.TimeSpan
---@operator add(System.TimeSpan):System.TimeSpan
---@operator mul(number):System.TimeSpan
---@operator mul(number):System.TimeSpan
---@operator div(number):System.TimeSpan
---@operator div(System.TimeSpan):number
local TimeSpan_Impl = {}

---@param ts System.TimeSpan 
---@return System.TimeSpan ret 
function TimeSpan_Impl:Add(ts) end

---@param value System.Object 
---@return integer ret 
function TimeSpan_Impl:CompareTo(value) end

---@param value System.TimeSpan 
---@return integer ret 
function TimeSpan_Impl:CompareTo(value) end

---@return System.TimeSpan ret 
function TimeSpan_Impl:Duration() end

---@param value System.Object 
---@return boolean ret 
function TimeSpan_Impl:Equals(value) end

---@param obj System.TimeSpan 
---@return boolean ret 
function TimeSpan_Impl:Equals(obj) end

---@return integer ret 
function TimeSpan_Impl:GetHashCode() end

---@return System.TimeSpan ret 
function TimeSpan_Impl:Negate() end

---@param ts System.TimeSpan 
---@return System.TimeSpan ret 
function TimeSpan_Impl:Subtract(ts) end

---@param factor number 
---@return System.TimeSpan ret 
function TimeSpan_Impl:Multiply(factor) end

---@param divisor number 
---@return System.TimeSpan ret 
function TimeSpan_Impl:Divide(divisor) end

---@param ts System.TimeSpan 
---@return number ret 
function TimeSpan_Impl:Divide(ts) end

---@return string ret 
function TimeSpan_Impl:ToString() end

---@param format string 
---@return string ret 
function TimeSpan_Impl:ToString(format) end

---@param format string 
---@param formatProvider System.IFormatProvider 
---@return string ret 
function TimeSpan_Impl:ToString(format, formatProvider) end

---@param destination System.Span 
---@param format? System.ReadOnlySpan 
---@param formatProvider? System.IFormatProvider 
---@return boolean ret 
---@return integer charsWritten (Out) 
function TimeSpan_Impl:TryFormat(destination, format, formatProvider) end

---@class Static.System.TimeSpan
---@field TicksPerMillisecond integer
---@field TicksPerSecond integer
---@field TicksPerMinute integer
---@field TicksPerHour integer
---@field TicksPerDay integer
---@field Zero System.TimeSpan
---@field MaxValue System.TimeSpan
---@field MinValue System.TimeSpan
---@overload fun(ticks:integer): System.TimeSpan (Constructor)
---@overload fun(hours:integer, minutes:integer, seconds:integer): System.TimeSpan (Constructor)
---@overload fun(days:integer, hours:integer, minutes:integer, seconds:integer): System.TimeSpan (Constructor)
---@overload fun(days:integer, hours:integer, minutes:integer, seconds:integer, milliseconds:integer): System.TimeSpan (Constructor)
---@overload fun(): System.TimeSpan (Constructor)
local TimeSpan_Static = {}

---@param t1 System.TimeSpan 
---@param t2 System.TimeSpan 
---@return integer ret 
function TimeSpan_Static.Compare(t1, t2) end

---@param value number 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromDays(value) end

---@param t1 System.TimeSpan 
---@param t2 System.TimeSpan 
---@return boolean ret 
function TimeSpan_Static.Equals(t1, t2) end

---@param value number 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromHours(value) end

---@param value number 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromMilliseconds(value) end

---@param value number 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromMinutes(value) end

---@param value number 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromSeconds(value) end

---@param value integer 
---@return System.TimeSpan ret 
function TimeSpan_Static.FromTicks(value) end

---@param s string 
---@return System.TimeSpan ret 
function TimeSpan_Static.Parse(s) end

---@param input string 
---@param formatProvider System.IFormatProvider 
---@return System.TimeSpan ret 
function TimeSpan_Static.Parse(input, formatProvider) end

---@param input System.ReadOnlySpan 
---@param formatProvider? System.IFormatProvider 
---@return System.TimeSpan ret 
function TimeSpan_Static.Parse(input, formatProvider) end

---@param input string 
---@param format string 
---@param formatProvider System.IFormatProvider 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, format, formatProvider) end

---@param input string 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, formats, formatProvider) end

---@param input string 
---@param format string 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, format, formatProvider, styles) end

---@param input System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@param formatProvider System.IFormatProvider 
---@param styles? System.Globalization.TimeSpanStyles 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, format, formatProvider, styles) end

---@param input string 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, formats, formatProvider, styles) end

---@param input System.ReadOnlySpan 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@param styles? System.Globalization.TimeSpanStyles 
---@return System.TimeSpan ret 
function TimeSpan_Static.ParseExact(input, formats, formatProvider, styles) end

---@param s string 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParse(s) end

---@param s System.ReadOnlySpan 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParse(s) end

---@param input string 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParse(input, formatProvider) end

---@param input System.ReadOnlySpan 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParse(input, formatProvider) end

---@param input string 
---@param format string 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, format, formatProvider) end

---@param input System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, format, formatProvider) end

---@param input string 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, formats, formatProvider) end

---@param input System.ReadOnlySpan 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, formats, formatProvider) end

---@param input string 
---@param format string 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, format, formatProvider, styles) end

---@param input System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, format, formatProvider, styles) end

---@param input string 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, formats, formatProvider, styles) end

---@param input System.ReadOnlySpan 
---@param formats string[] 
---@param formatProvider System.IFormatProvider 
---@param styles System.Globalization.TimeSpanStyles 
---@return boolean ret 
---@return System.TimeSpan result (Out) 
function TimeSpan_Static.TryParseExact(input, formats, formatProvider, styles) end


---@type Static.System.TimeSpan
System.TimeSpan = TimeSpan_Static

--------------------------------------------------------------------------------

---@class System.Guid : System.IFormattable, System.ISpanFormattable, System.IComparable, System.IComparable<System.Guid>, System.IEquatable<System.Guid>
local Guid_Impl = {}

---@return System.Byte[] ret 
function Guid_Impl:ToByteArray() end

---@param destination System.Span 
---@return boolean ret 
function Guid_Impl:TryWriteBytes(destination) end

---@return string ret 
function Guid_Impl:ToString() end

---@return integer ret 
function Guid_Impl:GetHashCode() end

---@param o System.Object 
---@return boolean ret 
function Guid_Impl:Equals(o) end

---@param g System.Guid 
---@return boolean ret 
function Guid_Impl:Equals(g) end

---@param value System.Object 
---@return integer ret 
function Guid_Impl:CompareTo(value) end

---@param value System.Guid 
---@return integer ret 
function Guid_Impl:CompareTo(value) end

---@param format string 
---@return string ret 
function Guid_Impl:ToString(format) end

---@param format string 
---@param provider System.IFormatProvider 
---@return string ret 
function Guid_Impl:ToString(format, provider) end

---@param destination System.Span 
---@param format? System.ReadOnlySpan 
---@return boolean ret 
---@return integer charsWritten (Out) 
function Guid_Impl:TryFormat(destination, format) end

---@class Static.System.Guid
---@field Empty System.Guid
---@overload fun(b:System.Byte[]): System.Guid (Constructor)
---@overload fun(b:System.ReadOnlySpan): System.Guid (Constructor)
---@overload fun(a:integer, b:integer, c:integer, d:System.Byte, e:System.Byte, f:System.Byte, g:System.Byte, h:System.Byte, i:System.Byte, j:System.Byte, k:System.Byte): System.Guid (Constructor)
---@overload fun(a:integer, b:integer, c:integer, d:System.Byte[]): System.Guid (Constructor)
---@overload fun(a:integer, b:integer, c:integer, d:System.Byte, e:System.Byte, f:System.Byte, g:System.Byte, h:System.Byte, i:System.Byte, j:System.Byte, k:System.Byte): System.Guid (Constructor)
---@overload fun(g:string): System.Guid (Constructor)
---@overload fun(): System.Guid (Constructor)
local Guid_Static = {}

---@return System.Guid ret 
function Guid_Static.NewGuid() end

---@param input string 
---@return System.Guid ret 
function Guid_Static.Parse(input) end

---@param input System.ReadOnlySpan 
---@return System.Guid ret 
function Guid_Static.Parse(input) end

---@param input string 
---@return boolean ret 
---@return System.Guid result (Out) 
function Guid_Static.TryParse(input) end

---@param input System.ReadOnlySpan 
---@return boolean ret 
---@return System.Guid result (Out) 
function Guid_Static.TryParse(input) end

---@param input string 
---@param format string 
---@return System.Guid ret 
function Guid_Static.ParseExact(input, format) end

---@param input System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@return System.Guid ret 
function Guid_Static.ParseExact(input, format) end

---@param input string 
---@param format string 
---@return boolean ret 
---@return System.Guid result (Out) 
function Guid_Static.TryParseExact(input, format) end

---@param input System.ReadOnlySpan 
---@param format System.ReadOnlySpan 
---@return boolean ret 
---@return System.Guid result (Out) 
function Guid_Static.TryParseExact(input, format) end


---@type Static.System.Guid
System.Guid = Guid_Static

--------------------------------------------------------------------------------

