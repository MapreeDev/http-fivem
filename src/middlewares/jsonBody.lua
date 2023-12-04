return function()
    return function (req,res,next)
        if req.method == "GET" then return next() end
        if not req.headers["Content-Type"] then return next() end
        req._raw.setDataHandler(function(body)
            req.body = json.decode(body)
            next()
        end)
    end
end