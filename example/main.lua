local Middlewares = require "src.middlewares.index"
local express = require "src.main"

local app = express()

app.use(Middlewares.parseJsonBody())
app.use(Middlewares.parseCookies())

app.use("/json",function(req,res,next)
    res.json({ ok = true, test = req.test })
end)

app.use("/",function(req,res,next)
    print("Accessing "..req.path.." in method "..req.method)
    next()
end)

app.get("/",function(req,res,next)
    res.send("Ok G E T")
end)

app.post("/",function(req,res)
    res.status(200).json({ ok = true, body = (req.body or {}) })
end)

app.use("/",function(req,res)
    res.status(404).json({ error = "Not Found" })
end)

local handler = app.listen(function(port)
    print("Http server listening on http://localhost:"..port.."/"..GetCurrentResourceName().."/")
end)

SetHttpHandler(handler)