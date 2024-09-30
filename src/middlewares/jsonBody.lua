return function()
    return function (req,res,next)
        if req.method == "GET" or req.method == "HEAD" then return next() end
        if not req.body or not req.headers["Content-Type"] or req.headers["Content-Type"] ~= "application/json" then return next() end
        if string.byte(req.body, 1) ~= 123 then return next() end
        req.body = json.decode(req.body)
        next()
    end
end