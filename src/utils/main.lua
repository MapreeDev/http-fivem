local utils = {}

utils.extractQuery = function(url)
    local queryStart = url:find("?")
    if not queryStart then
        return {}
    end

    local query = url:sub(queryStart + 1)
    local queryTable = {}

    for key, value in query:gmatch("([^&=?]-)=([^&=?]+)") do
        key = key:gsub("%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
        end)
        value = value:gsub("%%(%x%x)", function(hex)
            return string.char(tonumber(hex, 16))
        end)
        queryTable[key] = value
    end

    return queryTable
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
            path = Path.clean(path)
            for i=1,#middlewares do
                local middleware = middlewares[i]
                if onRegister and type(onRegister) == "function" then onRegister(path,middleware,method) end
            end
        end
    end
    return inheritObject
end

utils.validator = function(data, options, functionalValidatorOptions)
    if not data then error("Provide a data") end
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
        if config.minLength and data[key] then
            local minLength = type(config.minLength) == "number" and config.minLength
            if type(config.minLength) == "table" then
                minLength = config.minLength.value
            end
            local message = type(config.minLength) == "table" and config.minLength.message:gsub("%%KEY%%", key)
            if minLength and string.len(data[key]) < minLength then
                error(message or "`" .. key .. "` Must need " .. minLength .. " characters", key)
            end
        end
        if config.maxLength and data[key] then
            local maxLength = type(config.maxLength) == "number" and config.maxLength
            if type(config.maxLength) == "table" then
                maxLength = config.maxLength.value
            end
            local message = type(config.maxLength) == "table" and config.maxLength.message:gsub("%%KEY%%", key)
            if maxLength and string.len(data[key]) > maxLength then
                error(message or "`" .. key .. "` Must need " .. maxLength .. " characters", key)
            end
        end
        if config.custom and data[key] then
            local customFn = type(config.custom) == "function" and config.custom
            if type(config.custom) == "table" then
                customFn = config.custom.value
            end
            local message = type(config.custom) == "table" and config.custom.message:gsub("%%KEY%%", key)
            if customFn and not customFn(data[key]) then
                error(message or "`" .. key .. "` Cannot pass custom verification", key)
            end
        end
        if config.pattern and data[key] then
            local pattern = type(config.pattern) == "userdata" and config.pattern or config.pattern.value
            local message = type(config.pattern) == "userdata" and config.pattern.message:gsub("%%KEY%%", key)
            if not pattern:match(data[key]) then
                error(message or "`" .. key .. "` must need to match pattern", key)
            end
        end
    end
    return true
end

utils.logger = function(message,canLog)
    if not canLog then return end
    print(message)
end

utils.destructuring = function(obj,inheriter)
    local deepObj = obj
    for k,v in pairs(inheriter) do
        deepObj[k] = v
    end
    return deepObj
end

utils.urlParser = function(url)
    local parsed = {}
    local pattern = "([^:]+):?//?([^/]+)([^#]*)#?(.*)"
    local scheme, host, path, fragment = url:match(pattern)
    if not host then
        host = url:match("([^/]+)")
        path = url:sub(host:len() + 1)
    end
    local host, port = host:match("([^:]+):?(.*)")
    parsed.host = host
    parsed.port = tonumber(port) or nil
    if scheme then parsed.scheme = scheme end
    parsed.hostname = host:match("%.?([^%.]+%.[^%.]+)$") or host
    if path and path ~= "" then
        parsed.path = utils.cleanPath(path)
        parsed.pathSegments = utils.splitPath(parsed.path)
    else
        parsed.pathSegments = { "/" }
    end
    if fragment then parsed.fragment = fragment end
    return parsed
end

utils.getMimetypeFromExtension = function(extension)
    local mimeType = Config.defaultMiddlewareOptions.static.extensionToMimetype[extension] or Config.defaultMiddlewareOptions.static.defaultMimeType
    if type(mimeType) == "table" then
        mimeType = mimeType[1]
    end
    return mimeType
end

utils.getExtensionFromMimetype = function(mimeType)
    local extension = nil
    for sExtension,sMimetype in pairs(Config.defaultMiddlewareOptions.static.extensionToMimetype) do
        if type(sMimetype) == "table" then
            sMimetype = sMimetype[1]
        end
        if sMimetype == mimeType then
            print("ASDD",sMimeType,mimeType)
            extension = sExtension
            break;
        end
    end
    if not extension then extension = "txt" end
    return extension
end

return utils