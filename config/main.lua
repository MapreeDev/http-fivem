local config = {}

config.defaultServerOptions = {
    development = false,
    
}

config.defaultMiddlewareOptions = {
    cors = {
        origin = "*",
        methods = "GET,HEAD,PUT,PATCH,POST,DELETE",
        preflightContinue =  false,
        optionsSuccessStatus = 204,
        strict = false,
        credentials = false,
        -- maxAge = "123",
        -- exposedHeaders = {}
    },
    static = {
        extensionToMimetype = {
            ["txt"] = "text/plain",
            ["html"] = "text/html",
            ["css"] = "text/css",
            ["js"] = "application/javascript",
            ["json"] = "application/json",
            ["xml"] = "application/xml",
            ["png"] = "image/png",
            ["jpg"] = "image/jpeg",
            ["jpeg"] = "image/jpeg",
            ["gif"] = "image/gif",
            ["pdf"] = "application/pdf",
        },
        defaultMimeType = "application/octet-stream"
    }
}

return config