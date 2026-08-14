local M = {}

local basic_types = {
    ["bool"]    = "boolean",
    ["byte"]    = "integer",
    ["sbyte"]   = "integer",
    ["short"]   = "integer",
    ["ushort"]  = "integer",
    ["int"]     = "integer",
    ["uint"]    = "integer",
    ["long"]    = "integer",
    ["ulong"]   = "integer",
    ["float"]   = "number",
    ["double"]  = "number",
    ["string"]  = "string",
    ["Vector2"]    = "UnityEngine.Vector2",
    ["Vector3"]    = "UnityEngine.Vector3",
    ["Vector4"]    = "UnityEngine.Vector4",
    ["Quaternion"] = "UnityEngine.Quaternion",
    ["Color"]      = "UnityEngine.Color",
}

function M.convertCStoLua(rawType, isSync)
    if not rawType then return "any" end
    rawType = rawType:match("^%s*(.-)%s*$")
    local listInner = rawType:match("^List%s*<%s*(.-)%s*>$")
    if listInner then
        print("!!!")
        local innerResolved = M.convertCStoLua(listInner, false)
        print(innerResolved)
        if isSync then
            return string.format("__SyncList<%s>", innerResolved)
        else
            return string.format("System.Collections.Generic.List<%s>", innerResolved)
        end
    end

    local dictContent = rawType:match("^Dictionary%s*<%s*(.-)%s*>$")
    if dictContent then
        local keyRaw, valueRaw = dictContent:match("^(.-)%s*,%s*(.+)$")
        if keyRaw and valueRaw then
            local kResolved = M.convertCStoLua(keyRaw, false)
            local vResolved = M.convertCStoLua(valueRaw, false)

            if isSync then
                return string.format("__SyncDictionary<%s, %s>", kResolved, vResolved)
            else
                return string.format("System.Collections.Generic.Dictionary<%s, %s>", kResolved, vResolved)
            end
        end
    end

    local resolvedName = basic_types[rawType] or rawType

    if isSync then
        return string.format("__SyncValue<%s>", resolvedName)
    else
        return resolvedName
    end
end

return M