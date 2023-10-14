return function(res,appInstance)
    local self = {}

    self._raw = res

    self.data = {}

    self.data.status = 200
    self.data.headers = {}

    local function sendHTTPHead()
        self.setHeader("x-powered-by","MapreeDev")
        utils.logger("",)
        print(json.encode(self.data.headers))
        res.writeHead(self.data.status,self.data.headers)
    end

    self.json = function(...)
        self.send(...,true)
    end

    self.send = function(body,onlyJson)
        if type(body) == "table" or onlyJson then
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