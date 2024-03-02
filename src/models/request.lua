return function(req,appInstance)
    local self = {}

    self._raw = req

    self.app = appInstance
    self.path = Path.clean(req.path)
    self.query = Utils.extractQuery(req.path)
    self.method = req.method
    self.headers = req.headers
    self["user-agent"] = req["User-Agent"]
    self.accept = req.accept
    self["cache-control"] = req["Cache-Control"]
    self["accept-language"] = req["Accept-Language"]

    self.hxr = self.headers["X-Requested-With"] == "XMLHttpRequest"

    return self
end