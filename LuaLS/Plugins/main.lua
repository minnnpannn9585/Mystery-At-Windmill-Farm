local plugins = {
    require("var_parser"),
    require("varsync_parser"),
}

function OnSetText(uri, text)
    if uri:find("/LuaLS/") or uri:find("/Meta/") or not uri:match("%.lua$") then
        return {}
    end

    local all_diffs = {}

    for _, plugin in ipairs(plugins) do
        if plugin.OnSetText then
            local diffs = plugin.OnSetText(uri, text)
            if diffs then
                for _, diff in ipairs(diffs) do
                    table.insert(all_diffs, diff)
                end
            end
        end
    end

    return all_diffs
end