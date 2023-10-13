return function(req,appInstance)
    local self = {}

    self._raw = req

    local function parseQueryUrl()
        
    end

    self.path = utils.cleanPath(req.path)
    self.method = req.method
    self.headers = req.headers
    self["user-agent"] = req["User-Agent"]
    self.accept = req.accept
    self["cache-control"] = req["Cache-Control"]
    self["accept-language"] = req["Accept-Language"]

    return self
end