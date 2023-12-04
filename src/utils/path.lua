local Path = {}

Path.clean = function(p)
    p = p:gsub("//+", "/")
    if p:sub(1, 1) ~= "/" then
        p = "/" .. p
    end
    if p:sub(-1) == "/" and p:len() > 1 then
        p = p:sub(1, -2)
    end
    local queryStart = p:find("?")
    if queryStart then
        p = p:sub(1, queryStart - 1)
    end
    return p
end

Path.split = function(p)
    local parts = {"/"}
    local currentPart = ""
    for part in p:gmatch("[^/]+") do
        currentPart = currentPart .. "/" .. part
        parts[#parts+1] = currentPart
    end
    return parts
end

Path.resolve = function(...)
    local parts = {...}
    local resolvedPath = ""
    for _, part in ipairs(parts) do
        if not part:match("^/") then part = "/" .. part end
        resolvedPath = resolvedPath .. part
    end
    return resolvedPath
end

Path.extname = function(p)
    local filename = p:match("[^/]+$")
    return filename:match("%.([^%.]+)$") or ""
end

return Path