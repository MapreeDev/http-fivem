return function(res,appInstance)
    local self = {}

    self.data = {}

    self.data.answered = false
    self.data.status = 200
    self.data.headers = {}

    self._raw = res

    local function sendHTTPHead()
        self.setHeader("x-powered-by","MapreeDev")
        res.writeHead(self.data.status,self.data.headers)
    end

    self.json = function(jsonRaw)
        if self.data.answered then
            return self
        end
        self.send(jsonRaw)
        return self
    end

    self.send = function(body)
        if self.data.answered then
            return self
        end
        if type(body) == "table" then
            self.setHeader("Content-Type","application/json")
            body = json.encode(body)
        end
        sendHTTPHead()
        res.send(body)
        self.data.answered = true
        return self
    end

    self.status = function(statusCode)
        if self.data.answered then
            return self
        end
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