--[[*

Como fazer ser sequencial:

pegar a url /bla/bla/bla/bla e a cada / ir separando e procurando se existe alguma rota no modo de use ex:

etapa 1: procurar /
etapa 2: procurar /bla
etapa 3: procurar /bla/bla
etapa 4: procurar /bla/bla/bla

e assim recursivamente até chegar na rota final

todas as buscas além da principal vão ser feitas procurando por method nil para procurar somente middlewares e não rotas normais, assim não ocorre conflitos.

pensar futuramente como fazer sistema de params

]]

local Middlewares = require "src.middlewares.index"

local app = express()

app.use(Middlewares.parseJsonBody())
app.use(Middlewares.parseCookies())

app.use("/bla",function(req,res,next)
    res.json({ ok = true, test = req.test })
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
    print("Http server listening on port "..port)
end)

SetHttpHandler(handler)