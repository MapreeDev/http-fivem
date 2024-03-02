return function()
    return function (req,res,next)
        if req.method == "GET" or req.method == "HEAD" then return next() end
        if not req.headers["Content-Type"] then return next() end
        req._raw.setDataHandler(function(body)
            req.body = json.decode(body)
            if not req.body and body then
                -- Handle files
            end
            next()
        end)
    end
end