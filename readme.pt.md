# HTTP

## Visão Geral

HTTP é um servidor HTTP leve e simples para FiveM, inspirado na sintaxe do Express.js. Ele tem como objetivo fornecer um framework familiar e fácil de usar para lidar com solicitações HTTP e construir lógica do lado do servidor no ambiente FiveM.

## Instalação

1. Baixe a dependência `ox_lib` necessária pelo seguinte link: [ox_lib](https://github.com/overextended/ox_lib/releases/)

2. Extraia o arquivo `ox_lib` baixado e coloque-o no diretório `resources` do seu servidor FiveM.

3. Clone o repositório HTTP ou baixe-o pelo seguinte link: [HTTP](https://github.com/MapreeDev/http-fivem/archive/refs/heads/master.zip)

4. Extraia o arquivo HTTP baixado, remova "-fivem-main" do nome e coloque-o no diretório `resources` do seu servidor FiveM.

5. Inclua `ox_lib` e `http` no seu arquivo `server.cfg`:

   ```ini
   ensure ox_lib
   ensure http
   ```

6. Inicie o seu servidor FiveM.

7. Visite `http://localhost:30120/http` no seu navegador para ver a mensagem de boas-vindas padrão.

## Recursos

### Implementados

- Roteamento básico com uma sintaxe familiar ao Express.js.
- Suporte a middleware para manipulação de solicitações.
- Análise de string de consulta de rota.
- Suporte para manipulação de GET, POST e outros métodos HTTP.
- Análise do corpo JSON.
- Análise de cookies.
- Serviço de arquivos estáticos.
- Cors
- Manipulação de erros personalizada.

### Planejados

- Analisador de parâmetros de rota.
- Gerenciamento de sessão.
- Integração com WebSocket.
- Integração com bancos de dados.
- Suporte a modelos HTML.
- Aviso de nova versão.
- Refatorar busca de rota.

### Em Desenvolvimento

- Validação e saneamento de solicitações.

## Uso

### Roteamento

Defina rotas usando a sintaxe do Express.js:

```lua
local express = require "@http.src.main"
local app = express()

app.get('/', function(req, res)
  res.send('Olá, FiveM!')
end)
```

### Middleware

Use funções de middleware para processar solicitações antes de chegar aos manipuladores de rota:

```lua
app.use(function(req, res, next)
  print('Solicitação recebida em', os.date())
  next()
end)
```

### Ouvir

Use a função `listen` para torná-lo ativo e ouvir no seu servidor FiveM:

```lua
local listen = app.listen(function()
    print("Ouvindo no servidor FiveM\nExemplo: http://localhost:30120/"..GetCurrentResourceName().."/")
end)
SetHttpHandler(listen)
```

### Projeto de Exemplo

Para mais exemplos, visite o arquivo `example/main.lua`.

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir problemas ou enviar solicitações de pull para melhorar o HTTP.

## Licença

HTTP está licenciado sob a Licença MIT - veja o arquivo [LICENSE](license) para mais detalhes.

---

Curta o uso do HTTP no seu servidor FiveM! Se tiver alguma dúvida ou sugestão, sinta-se à vontade para entrar em contato.
