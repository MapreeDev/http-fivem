middlewares = {}

middlewares.parseJsonBody = function()
    return function (req,res,next)
        if req.method == "GET" then return next() end
        if not req.headers["Content-Type"] then return next() end
        req._raw.setDataHandler(function(body)
            req.body = json.decode(body)
            next()
        end)
    end
end

middlewares.parseCookies = function()
    return function (req, res, next)
        local cookieList = {
            res = {},
            req = {}
        }

        local function computeReqCookiesList()
            local cookieHeader = req.headers.Cookie

            if cookieHeader then
                for pair in cookieHeader:gmatch('([^,%s]+)') do
                    local key, value = pair:match('([^=]+)=(.*)')
                    cookieList["req"][key] = value
                end
            end
        end

        local function setResCookiesList()
            local cookieHeader = ""
            for name, data in pairs(cookieList["res"]) do
                cookieHeader = cookieHeader .. name .. "=" .. data.value .. "; "
                if data.httpOnly then
                    cookieHeader = cookieHeader .. "HttpOnly; "
                end
                if data.priority then
                    cookieHeader = cookieHeader .. "Priority=" .. data.priority .. "; "
                end
                if data.expiresAt then
                    local expireTimeString = os.date("!%a, %d %b %Y %H:%M:%S GMT", data.expiresAt)
                    cookieHeader = cookieHeader .. "Expires=" .. expireTimeString .. "; "
                end
            end

            res.setHeader("Set-Cookie", cookieHeader)
        end

        req.getCookie = function(name)
            return cookieList["req"][name]
        end

        req.getCookies = function()
            return cookieList["req"]
        end

        res.getCookies = function()
            return cookieList["res"]
        end

        res.getCookie = function(name)
            return cookieList["res"][name] and cookieList["res"][name].value
        end

        res.setCookie = function(name, value, httpOnly, priority, expiresAt)
            cookieList["res"][name] = {
                value = value,
                httpOnly = httpOnly,
                priority = priority,
                expiresAt = expiresAt
            }
            setResCookiesList()
        end

        computeReqCookiesList()

        next()
    end
end

middlewares.cors = function(cfgOptions)
    local options = Config.defaultMiddlewareOptions.cors
    options = utils.destructuring(options,cfgOptions or {})
    if type(options.origin) ~= "table" and type(options.origin) ~= "string" then
        error("invalid cors configuration")
    end
    local function headerOrigin(options,req,res,requestOrigin)
        local reqOriginRaw = req.headers.Origin or req.headers.origin
        if not requestOrigin and options.strict then res.setHeader("Access-Control-Allow-Origin",false) end
        if options.origin == "*" or not requestOrigin then
            res.setHeader("Access-Control-Allow-Origin","*")
        else
            if type(options.origin) == "string" then res.setHeader("Access-Control-Allow-Origin",options.origin) end
            for i=1,#options.origin do
                if options.origin[i] == requestOrigin then
                    options.origin = options.origin[i]
                    break;
                end 
            end
            res.setHeader("Access-Control-Allow-Origin",type(options.origin) == "string" and reqOriginRaw or false)
        end
    end
    local function headerCredential(options,req,res)
        if options.credentials == true then
            res.setHeader("Access-Control-Allow-Credentials","true")
        end
    end
    local function headerMethods(options,req,res)
        local methods = options.methods
        if type(methods) == "table" then
            methods = table.concat(methods,", ")
        end
        res.setHeader("Access-Control-Allow-Methods",methods)
    end
    local function headerExposed(options,req,res)
        local headers = options.exposedHeaders
        if not headers then return end
        if type(headers) == "table" then
            table.concat(headers,",")
        end
        res.setHeader("Access-Control-Expose-Headers",headers)
    end
    local function headerMaxAge(options,req,res)
        if options.maxAge and type(options.maxAge) == "string" then
            res.setHeader("Access-Control-Max-Age",options.maxAge)
        end
    end
    return function(req,res,next)
        local reqOrigin = req.headers.Origin
        if reqOrigin then
            local parsedUrl = utils.urlParser(reqOrigin)
            if parsedUrl.host then reqOrigin = parsedUrl.host end
        end
        if req.method == "OPTIONS" then
            headerOrigin(options,req,res,reqOrigin)
            headerCredential(options,req,res)
            headerMethods(options,req,res)
            headerExposed(options,req,res)
            headerMaxAge(options,req,res)
            if options.preflightContinue then
                next()
            else
                res.status(options.optionsSuccessStatus)
                res.setHeader("Content-Length","0")
                res.send()
            end
        else
            headerOrigin(options,req,res,reqOrigin)
            headerCredential(options,req,res)
            headerExposed(options,req,res)
            next()
        end
    end
end

middlewares.static = function(pathOpt,options)
    return function (req,res,next)
        if req.method ~= "GET" and req.method ~= "HEAD" then
            if options.fallTrough then return next() end
            res.status(405)
            res.setHeader("Allow","GET, HEAD")
            res.setHeader("Content-Length","0")
            res.send()
            return
        end
        local forwardErr = not options.fallTrough
        local relativePath = string.gsub(req.path,"^"..req.route,"")
        local resolvedPath = utils.resolvePath(pathOpt.folder,relativePath)
        local fileBody = LoadResourceFile(pathOpt.rsc or req.app.data.rsc, resolvedPath)
        if not fileBody then
            if forwardErr then
                res.status(404)
                res.send("File not found")
                return
            end
            next()
        end
        local mimeType = utils.getMimetypeFromExtension(utils.getExt(resolvedPath))
        if options.maxAge and type(options.maxAge) == "number" then
            res.setHeader("Cache-Control","max-age="..options.maxAge)
        end
        res.setHeader("Content-Type",mimeType)
        res.setHeader("Content-Length",#fileBody)
        res.send(fileBody)
    end
end

return middlewares