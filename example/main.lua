local cors = require "src.middlewares.cors"
local jsonBody = require "src.middlewares.jsonBody"
local cookies = require "src.middlewares.cookies"
local static = require "src.middlewares.static"
local express = require "src.main"
local Error = require "src.utils.error"
local fileParser = require"src.middlewares.files"

local app = express({
    development = true
})

-- Middleware to parse JSON body, cookies and cors
app.use(jsonBody())
app.use(cookies())
app.use(cors({ origin = {"www.mapree.dev","mapree.dev"} }))
app.use(fileParser())

-- Route to handle static files
app.use("/public",static("/example/public",{ maxAge = 86400, blockExtension={"jpg"} }))

-- Route to handle JSON response
app.get("/testing", function(req, res, next)
    res.json({ ok = true })
end)

-- Default route for GET request
app.get("/",function(req, res, next)
    res.send("Hello Fivem")
end)

-- Route for GET request at '/redirect'
app.get("/redirect",function(req,res)
    res.redirect("https://www.google.com")
end)

-- Route for GET request at '/error'
app.get("/error", function(req, res)
    Error.throw(403,{ custom = true, field = "test" })
end)

-- Route for POST request at '/'
app.post("/", function(req, res)
    print("TAMO AQ",req.body)
    res.status(200).json({ ok = true, body = req.body })
end)

-- Error handling middleware
app.setErrorHandling(function(req, res, err)
    res.status(err.statusCode).send(err.body)
end)

local function saveFile(filename, data)
    local file = io.open(filename, "wb")
    if not file then
        error("Could not open file for writing: " .. filename)
    end
    file:write(data)
    file:close()
end

-- Route for POST request at '/upload' send an image as body
app.post("/upload",function(req,res)
    if not req.body or not req.bodyBinary or not req.fileExtension then return res.status(400).send("Invalid body format") end
    saveFile("testing."..req.fileExtension,req.body)
    res.send("OK")
end)

-- Build http handler
local handler = app.listen(function()
    print(#"\255\216\255")
    local rsc = GetCurrentResourceName()
    print("HTTP server listening on http://localhost:30120/"..rsc.."/ or https://"..GetConvar("web_baseUrl","").."/"..rsc.."/")
end)

-- Set the HTTP handler
SetHttpHandler(handler)