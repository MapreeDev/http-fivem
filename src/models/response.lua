return function(res,appInstance)
    local self = {}

    self._raw = res

    self.data = {}

    self.data.status = 200
    self.data.headers = {}

    local function sendHTTPHead()
        self.setHeader("x-powered-by","MapreeDev")
        print(json.encode(self.data.headers))
        res.writeHead(self.data.status,self.data.headers)
    end

    self.json = function(jsonRaw)
        self.send(jsonRaw)
        return self
    end

    self.send = function(body)
        if type(body) == "table" then
            self.setHeader("Content-Type","application/json")
            body = json.encode(body)
        end
        sendHTTPHead()
        res.send(body)
        return self
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