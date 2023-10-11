return function(req,appInstance)
    local self = {}

    self._raw = req

    self.path = utils.cleanPath(req.path)
    self.method = req.method
    self.headers = req.headers
    self.cookie = req.Cookie
    self["user-agent"] = req["User-Agent"]
    self.accept = req.accept
    self["cache-control"] = req["Cache-Control"]
    self["accept-language"] = req["Accept-Language"]

    return self
end