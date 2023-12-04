return function(cfgOptions)
    local options = Config.defaultMiddlewareOptions.cors
    options = Utils.destructuring(options,cfgOptions or {})
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
            local parsedUrl = Utils.urlParser(reqOrigin)
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