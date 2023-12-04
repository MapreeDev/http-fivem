Request = require "src.models.request"
Response = require "src.models.response"
Utils = require "src.utils.main"
Config = require "config.main"
Path = require "src.utils.path"
Error = require "src.utils.error"

return function(options)
    if not options then options = Config.defaultServerOptions end
    local self = {}

    self.data = {}

    self.data.startTime = nil
    self.data.rsc = GetCurrentResourceName()
    self.data.routes = {}
    self.data.isDevelopment = options.development or Config.defaultServerOptions.development
    self.data.errorHandling = nil

    local function addRoute(path,execute,method)
        if not self.data.routes[path] then self.data.routes[path] = {} end
        local idx = #self.data.routes[path]+1
        self.data.routes[path][idx] = { method = method, execute = execute }
        Utils.logger("Route Added method: "..(method or "ALL").." path: "..path.." index: "..idx,self.data.isDevelopment)
    end

    Utils.putMethodsLogic(addRoute,self)
 
    self.use = function(path,...)
        local middlewares = {...}
        if #middlewares == 0 then
            if type(path) ~= "function" then return print("Cannot use string or number as a middleware") end
            middlewares = {path}
            path = "/"
        end
        path = Path.clean(path)
        for i=1,#middlewares do
            local middleware = middlewares[i]
            addRoute(path,middleware)
        end
    end

    self.setErrorHandling = function(errorHandling)
        if type(errorHandling) ~= "function" then print("Error handling must be a function") end
        self.data.errorHandling = errorHandling
    end

    self.listen = function(onSuccess)
        self.data.startTime = os.time()
        if onSuccess then onSuccess() end
        return function(rawReq,rawRes)
            local req = Request(rawReq,self)
            local res = Response(rawRes,self)
            Utils.logger("New request income to "..req.path.." in method "..req.method.."",self.data.isDevelopment)
            local splitedPath = Path.split(req.path)
            local routesFiltered = {}
            for i=1,#splitedPath do
                local pathToSearch = splitedPath[i]
                if not pathToSearch or not self.data.routes[pathToSearch] then goto continue end
                local isFinal = (i == #splitedPath)
                for i=1,#self.data.routes[pathToSearch] do
                    local routeSearched = self.data.routes[pathToSearch][i]
                    if not isFinal and routeSearched.method then goto sub_continue end
                    if isFinal and routeSearched.method and routeSearched.method ~= req.method then goto sub_continue end
                    routeSearched.path = pathToSearch
                    routesFiltered[#routesFiltered+1] = routeSearched
                    ::sub_continue::
                end
                ::continue::
            end
            local currentIndex = 0
            function next(data)
                currentIndex = currentIndex + 1
                local route = routesFiltered[currentIndex]
                if route then
                    req.route = route.path
                    route.execute(req,res,next,data)
                else
                    if currentIndex > #routesFiltered then
                        res.status(404).send("Not Found")
                    else
                        next()
                    end
                end
            end
            local status,err = pcall(function()
                next()
            end)
            if not status and err then
                Utils.logger("Error in route: "..err,self.data.isDevelopment)
                if self.data.errorHandling then
                    local status,err = pcall(function()
                        self.data.errorHandling(req,res,Error.parse(err))
                    end)
                    if not status and err then print("Ocurred a error in errorHandling "..err) end
                end
            end
        end
    end
    return self
end