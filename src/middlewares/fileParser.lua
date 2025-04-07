return function()
    return function(req,res,next)
        if not req.hasBody or not req.bodyBinary then return next() end
        for fileName,config in pairs(Config.defaultMiddlewareOptions.static.extensionToMimetype) do
            if type(config) ~= "table" then
                goto continue
            end
            if req.body:sub(1,#config[2]) == config[2] then
                req.setContentType(config[1])
                req.fileExtension = fileName
                break
            end
            ::continue::
        end
        next()
    end
end