local utils = {}

utils.cleanPath = function(path)
    path = path:gsub("//+", "/")
    if path:sub(1, 1) ~= "/" then
        path = "/" .. path
    end
    if path:sub(-1) == "/" and path:len() > 1 then
        path = path:sub(1, -2)
    end
    return path
end

utils.splitPath = function(path)
    local parts = {}
    local currentPart = ""

    table.insert(parts,"/")

    for part in path:gmatch("[^/]+") do
        currentPart = currentPart .. "/" .. part
        parts[#parts+1] = currentPart
    end

    return parts
end

utils.getNonIndexedTableLength = function(table)
    local length = 0
    for k,v in pairs(table) do
        length = length+1
    end
    return length
end

utils.methods = {"GET","POST","PATCH","HEAD","PUT","DELETE","CONNECT","OPTIONS","TRACE"}

utils.isMethodAvailable = function(method)
    local status = false
    for i=1,#utils.methods do
        local sMethod = utils.methods[i]
        if sMethod == method then
            status = true
            break
        end
    end
    return status
end

utils.putMethodsLogic = function(onRegister,inheritObject)
    for i=1,#utils.methods do
        local method = utils.methods[i]
        inheritObject[string.lower(method)] = function (path,...)
            local middlewares = {...}
            if #middlewares == 0 then
                if type(path) ~= "function" then return print("Cannot use string or number as a middleware") end
                middlewares = {path}
                path = "/"
            end
            path = utils.cleanPath(path)
            for i=1,#middlewares do
                local middleware = middlewares[i]
                if onRegister and type(onRegister) == "function" then onRegister(path,middleware,method) end
            end
        end
    end
    return inheritObject
end

return utils