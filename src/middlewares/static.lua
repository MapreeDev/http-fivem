return function(pathOpt,options)
    return function (req,res,next)
        if req.method ~= "GET" and req.method ~= "HEAD" then
            if options.fallTrough then return next() end
            res.status(405)
            res.setHeader("Allow","GET, HEAD")
            res.setHeader("Content-Length","0")
            res.send()
            return
        end
        local forwardErr = not options.fallTrough
        local relativePath = string.gsub(req.path,"^"..req.route,"")
        local resolvedPath = Path.resolve(pathOpt.folder,relativePath)
        local fileBody = LoadResourceFile(pathOpt.rsc or req.app.data.rsc, resolvedPath)
        if not fileBody then
            if forwardErr then
                res.status(404)
                res.send("File not found")
                return
            end
            next()
        end
        local mimeType = Utils.getMimetypeFromExtension(Path.extname(resolvedPath))
        if options.maxAge and type(options.maxAge) == "number" then
            res.setHeader("Cache-Control","max-age="..options.maxAge)
        end
        res.setHeader("Content-Type",mimeType)
        res.setHeader("Content-Length",#fileBody)
        res.send(fileBody)
    end
end