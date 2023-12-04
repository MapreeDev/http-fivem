local Middlewares = require "src.middlewares.main"
local express = require "src.main"
local Error = require "src.utils.error"

local app = express({
    development = true
})

-- Middleware to parse JSON body, cookies and cors
app.use(Middlewares.parseJsonBody())
app.use(Middlewares.parseCookies())
app.use(Middlewares.cors({ origin = {"www.mapree.dev","mapree.dev"} }))

-- Route to handle static files
app.use("/public",Middlewares.static({ folder = "/example/public", },{ maxAge = 86400 }))

-- Route to handle JSON response
app.get("/testing", function(req, res, next)
    res.json({ ok = true })
end)

-- Default route for GET request
app.get("/",function(req, res, next)
    res.send("Hello Fivem")
end)

-- Route for GET request at '/error'
app.get("/error", function(req, res)
    Error.throw(403,{ custom = true, field = "test" })
end)

-- Route for POST request at '/'
app.post("/", function(req, res)
    res.status(200).json({ ok = true, body = (req.body or {}) })
end)

-- Error handling middleware
app.setErrorHandling(function(req, res, err)
    res.status(err.statusCode).send(err.body)
end)

-- Build http handler
local handler = app.listen(function()
    print("HTTP server listening on http://localhost:30120/"..GetCurrentResourceName().."/")
end)

-- Set the HTTP handler
SetHttpHandler(handler)