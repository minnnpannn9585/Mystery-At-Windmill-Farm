local typeUtils = require("type_utils")

local function OnSetText(uri, text)
    local diffs = {}
    
    local pattern = "([-]*)@var%s+([%w_]+)%s*:%s*(.-)%s*([\r\n])"

    local init = 1
    while true do
        local startPos, endPos, dashes, name, typeName, newline = text:find(pattern, init)
        
        if not startPos then break end
        
        local replacement = string.format("local %s = nil ---@type %s", name, typeUtils.convertCStoLua(typeName, false))

        table.insert(diffs, {
            start  = startPos,
            finish = endPos - 1,
            text   = replacement
        })

        init = endPos
    end

    if #diffs == 0 then return nil end
    return diffs
end

return {
    OnSetText = OnSetText
}