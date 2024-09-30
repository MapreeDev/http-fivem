local function saveFile(filename, data)
    local file = io.open(filename, "wb")
    if not file then
        error("Could not open file for writing: " .. filename)
    end
    file:write(data)
    file:close()
end

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
    self.contentType = self.headers["Content-Type"]
    self.bodyBinary = false
    self.hxr = self.headers["X-Requested-With"] == "XMLHttpRequest"
    self.hasBody = false

    self.setContentType = function(contentType)
        req.headers["Content-Type"] = contentType
        self.headers = req.headers
        return self
    end

    if self.headers["Content-Length"] and tonumber(self.headers["Content-Length"]) > 0 then
        local bodyRead = false
        if self.contentType == "application/octet-stream" then
            req.setDataHandler(function(body)
                bodyRead = true
                self.body = body
                self.bodyBinary = true
            end,"binary")
        else
            req.setDataHandler(function(body)
                bodyRead = true
                self.body = body
            end)
        end
        while not bodyRead do
            Wait(1)
        end
        if self.body then
            self.hasBody = true
        end
    end

    return self
end