return function(res,appInstance)
    local self = {}

    self._raw = res

    self.data = {}

    self.data.status = 200
    self.data.headers = {}
    self.headersSent = false

    local function sendHTTPHead()
        if self.headersSent then return end
        self.headersSent = true
        self.setHeader("x-powered-by","MapreeDev")
        for k,w in pairs(self.data.headers) do
            if type(w) ~= "string" then self.data.headers[k] = tostring(self.data.headers[k]) end
        end
        res.writeHead(self.data.status,self.data.headers)
    end

    self.json = function(...)
        self.send(...,true)
    end

    self.send = function(body,onlyJson)
        if type(body) == "table" or onlyJson then
            self.type("json")
            -- self.setHeader("Content-Type","application/json")
            body = json.encode(body)
        end
        sendHTTPHead()
        res.send(body or "")
        return self
    end

    self.writeHead = function()
        sendHTTPHead()
        return self
    end

    self.redirect = function(statusCode,targetUrl)
        if not targetUrl then
            targetUrl = targetUrl
            statusCode = 302
        end
        self.status(statusCode)
        self.setHeader("Location",targetUrl)
        sendHTTPHead()
    end

    self.type = function(ext)
        self.setHeader("Content-Type",Utils.getMimetypeFromExtension(ext))
    end

    self.status = function(statusCode)
        self.data.status = statusCode
        return self
    end

    self.setHeader = function(header,value)
        self.data.headers[header] = value
        return self
    end

    self.getHeader = function(header)
        return self.data.headers[header] or ""
    end

    return self
end