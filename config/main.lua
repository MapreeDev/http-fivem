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
        extensionToMimetype = { -- https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
            ["txt"] = "text/plain",
            ["html"] = "text/html",
            ["css"] = "text/css",
            ["js"] = "application/javascript",
            ["json"] = "application/json",
            ["png"] = {"image/png","\137PNG"},
            ["jpg"] = {"image/jpeg","\255\216\255"},
            ["jpeg"] = {"image/jpeg","\255\216\255"},
            ["gif"] = {"image/gif","GIF8"},
            ["pdf"] = {"application/pdf","%PDF"},
            ["7z"] = "application/x-7z-compressed",
            ["zip"] = {"application/zip","PK\x03\x04"},
            ["xml"] = "application/xml",
            ["woff"] = "font/woff",
            ["woff2"] = "font/woff2",
            ["webp"] = "image/webp",
            ["tar"] = "application/x-tar",
            ["svg"] = "application/svg+xml",
        },
        defaultMimeType = "application/octet-stream"
    }
}

return config