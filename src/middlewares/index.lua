middlewares = {}

middlewares.parseJsonBody = function()
    return function (req,res,next)
        if req.method == "GET" then return next() end
        req._raw.setDataHandler(function(body)
            req.body = json.decode(body)
            next()
        end)
    end
end

middlewares.parseCookies = function()
    return function (req, res, next)
        print(req.headers.Cookie)
        req.getCookie = function(name,value)
        end

        req.getCookies = function(name,value)
        end

        res.getCookies = function()
        end

        res.getCookie = function(name,value)
        end

        res.setCookie = function(name,value,httpOnly,priority,expiresAt)
        end
        
        next()
    end
end


return middlewares