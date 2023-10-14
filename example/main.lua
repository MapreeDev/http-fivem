local Middlewares = require "src.middlewares.main"
local express = require "src.main"

local app = express({
    development = true
})

app.use(Middlewares.parseJsonBody())
app.use(Middlewares.parseCookies())

app.use("/json",function(req,res,next)
    res.json({ ok = true, test = req.test })
end)

app.get("/testing",function(req,res,next)
    res.json({ ok = true })
end)

app.get("/",function(req,res,next)
    error("Test",json.encode({ test = true }))
    res.send("Ok G E T")
end)

app.get("/error",function(req,res)
    error("Test",json.encode({ test = true }))
end)

app.post("/",function(req,res)
    res.status(200).json({ ok = true, body = (req.body or {}) })
end)

app.setErrorHandling(function(req,res,err)
    print(json.encode(utils.parseError(err)))
    res.send("Error founded")
end)

local handler = app.listen(function(port)
    print("Http server listening on http://localhost:"..port.."/"..GetCurrentResourceName().."/")
end)

SetHttpHandler(handler)