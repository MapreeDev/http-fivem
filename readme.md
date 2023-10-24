# HTTP

## Overview

HTTP is a lightweight and simple HTTP server for FiveM, inspired by the syntax of Express.js. It aims to provide a familiar and easy-to-use framework for handling HTTP requests and building server-side logic in the FiveM environment.

## Installation

1. Download the required `ox_lib` dependency from the following link: [ox_lib](https://github.com/overextended/ox_lib/releases/)

2. Extract the downloaded `ox_lib` archive and place it in the `resources` directory of your FiveM server.

3. Clone the HTTP repository or download it from the following link: [HTTP](https://github.com/MapreeDev/http-fivem/archive/refs/heads/master.zip)

4. Extract the downloaded HTTP archive, remove "-fivem-main" from the name, and place it in the `resources` directory of your FiveM server.

5. Include `ox_lib` and `http` in your `server.cfg` file:

   ```ini
   ensure ox_lib
   ensure http
   ```

6. Start your FiveM server.

7. Visit `http://localhost:30120` in your browser to see the default welcome message.

## Features

### Implemented

- Basic routing with a familiar Express.js syntax.
- Middleware support for handling requests.
- Route query string parsing.
- Support for handling GET, POST, and other HTTP methods.
- Parse JSON body.
- Parse cookies.
- Parse URL query.

### Planned

- Static file serving.
- Route params parser.
- Session management.
- WebSocket integration.
- Integration with databases.
- HTML Template support.
- New version warning.

### Under Development

- Request validation and sanitization.
- Custom error handling.

## Usage

### Routing

Define routes using Express.js syntax:

```lua
local express = require "@http.src.main"
local app = express()

app.get('/', function(req, res)
  res.send('Hello, FiveM!')
end)
```

### Middleware

Use middleware functions to process requests before reaching route handlers:

```lua
app.use(function(req, res, next)
  print('Request received at', os.date())
  next()
end)
```

### Listen

Use the `listen` function to make it live and listen on your FiveM server:

```lua
local listen = app.listen(function()
    print("Listening on the FiveM server\nExample: http://localhost:30120/"..GetCurrentResourceName().."/")
end)
SetHttpHandler(listen)
```

### Example Project

For more examples, visit the file `example/main.lua`.

## Contribution

Contributions are welcome! Feel free to open issues or submit pull requests to improve HTTP.

## License

HTTP is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Enjoy using HTTP in your FiveM server! If you have any questions or suggestions, feel free to reach out.
