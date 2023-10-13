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

utils.validator = function(data, options, functionalValidatorOptions)
    local error = functionalValidatorOptions and functionalValidatorOptions.customError or defaultError
    for key, config in pairs(options) do
        if type(config) == "string" then
            config = presetsConfig[config]
        end
        if config.required == true or (type(config.required) == "table" and config.required.value == true) then
            local message = type(config.required) == "table" and config.required.message:gsub("%%KEY%%", key)
            if not data[key] then
                error(message or "Missing `" .. key .. "`", key)
            end
        end
        if config.minLength then
            local minLength = type(config.minLength) == "number" and config.minLength
            if type(config.minLength) == "table" then
                minLength = config.minLength.value
            end
            local message = type(config.minLength) == "table" and config.minLength.message:gsub("%%KEY%%", key)
            if minLength and #data[key] < minLength then
                error(message or "`" .. key .. "` Must need " .. minLength .. " characters", key)
            end
        end
        if config.maxLength then
            local maxLength = type(config.maxLength) == "number" and config.maxLength
            if type(config.maxLength) == "table" then
                maxLength = config.maxLength.value
            end
            local message = type(config.maxLength) == "table" and config.maxLength.message:gsub("%%KEY%%", key)
            if maxLength and #data[key] > maxLength then
                error(message or "`" .. key .. "` Must need " .. maxLength .. " characters", key)
            end
        end
        if config.custom then
            local customFn = type(config.custom) == "function" and config.custom
            if type(config.custom) == "table" then
                customFn = config.custom.value
            end
            local message = type(config.custom) == "table" and config.custom.message:gsub("%%KEY%%", key)
            if customFn and not customFn(data[key]) then
                error(message or "`" .. key .. "` Cannot pass custom verification", key)
            end
        end
        if config.pattern then
            local pattern = type(config.pattern) == "userdata" and config.pattern or config.pattern.value
            local message = type(config.pattern) == "userdata" and config.pattern.message:gsub("%%KEY%%", key)
            if not pattern:match(data[key]) then
                error(message or "`" .. key .. "` must need to match pattern", key)
            end
        end
    end
    return true
end

return utils