Request = require "src.models.request"
Response = require "src.models.response"
utils = require "src.utils.main"

return function(options)
    local self = {}

    self.data = {}

    self.data.sharedSecret = GetConvar("shared_secret","secret")
    self.data.startTime = nil
    self.data.rsc = GetCurrentResourceName()
    self.data.port = GetConvar("port","30120")
    self.data.routes = {}

    local function addRoute(path,execute,method)
        if not self.data.routes[path] then self.data.routes[path] = {} end
        local idx = #self.data.routes[path]+1
        self.data.routes[path][idx] = { method = method, execute = execute }
    end

    utils.putMethodsLogic(addRoute,self)
 
    self.use = function(path,...)
        local middlewares = {...}
        if #middlewares == 0 then
            if type(path) ~= "function" then return print("Cannot use string or number as a middleware") end
            middlewares = {path}
            path = "/"
        end
        path = utils.cleanPath(path)
        for i=1,#middlewares do
            local middleware = middlewares[i]
            addRoute(path,middleware)
        end
    end

    self.listen = function(onSuccess)
        self.data.startTime = os.time()
        if onSuccess then onSuccess(self.data.port) end
        return function(rawReq,rawRes)
            local req = Request(rawReq,self)
            local res = Response(rawRes,self)
            local splitedPath = utils.splitPath(req.path)
            local routesFiltered = {}
            for i=1,#splitedPath do
                local pathToSearch = splitedPath[i]
                if not self.data.routes[pathToSearch] then goto continue end
                local isFinal = (i == #splitedPath)
                for i=1,#self.data.routes[pathToSearch] do
                    local routeSearched = self.data.routes[pathToSearch][i]
                    if not isFinal and routeSearched.method then goto sub_continue end
                    if isFinal and routeSearched.method and routeSearched.method ~= req.method then goto sub_continue end
                    routesFiltered[#routesFiltered+1] = self.data.routes[pathToSearch][i]
                    ::sub_continue::
                end
                ::continue::
            end
            local currentIndex = 0
            function next(data)
                currentIndex = currentIndex + 1
                local route = routesFiltered[currentIndex]
                if route then
                    route.execute(req,res,next,data)
                else
                    res.status(404).send("Not Found")
                end
            end
            next()
        end
    end

    return self
end