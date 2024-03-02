return function(pathOpt,options)
    if type(pathOpt) == "string" then
        pathOpt = { folder = pathOpt }
    end
    if not options then options = {} end
    return function (req,res,next)
        if req.method ~= "GET" and req.method ~= "HEAD" then
            if options.fallthrough then return next() end
            res.status(405)
            res.setHeader("Allow","GET, HEAD")
            res.setHeader("Content-Length","0")
            res.send()
            return
        end
        local forwardErr = not options.fallthrough
        local relativePath = string.gsub(req.path,"^"..req.route,"")
        local resolvedPath = Path.resolve(pathOpt.folder,relativePath)
        local ext = Path.extname(resolvedPath)
        local mimeType = Utils.getMimetypeFromExtension(ext)
        local fake404 = false
        if options.blockExtension then
            for i=1,#options.blockExtension do
                if options.blockExtension[i] == ext then
                    fake404 = true
                    break
                end
            end
        end
        local fileBody = fake404 and true or LoadResourceFile(pathOpt.rsc or req.app.data.rsc, resolvedPath)
        if not fileBody or fileBody == true then
            if forwardErr then
                res.status(404)
                res.send("File not found")
                return
            end
            next()
        end
        if options.maxAge and type(options.maxAge) == "number" then res.setHeader("Cache-Control","max-age="..options.maxAge) end
        res.setHeader("Content-Type",mimeType)
        res.setHeader("Content-Length",#fileBody)
        res.send(fileBody)
    end
end