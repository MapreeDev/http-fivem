return function()
    return function (req, res, next)
        local cookieList = {
            res = {},
            req = {}
        }

        local function computeReqCookiesList()
            local cookieHeader = req.headers.Cookie

            if cookieHeader then
                for pair in cookieHeader:gmatch('([^,%s]+)') do
                    local key, value = pair:match('([^=]+)=(.*)')
                    cookieList["req"][key] = value
                end
            end
        end

        local function setResCookiesList()
            local cookieHeader = ""
            for name, data in pairs(cookieList["res"]) do
                cookieHeader = cookieHeader .. name .. "=" .. data.value .. "; "
                if data.httpOnly then
                    cookieHeader = cookieHeader .. "HttpOnly; "
                end
                if data.priority then
                    cookieHeader = cookieHeader .. "Priority=" .. data.priority .. "; "
                end
                if data.expiresAt then
                    local expireTimeString = os.date("!%a, %d %b %Y %H:%M:%S GMT", data.expiresAt)
                    cookieHeader = cookieHeader .. "Expires=" .. expireTimeString .. "; "
                end
            end

            res.setHeader("Set-Cookie", cookieHeader)
        end

        req.getCookie = function(name)
            return cookieList["req"][name]
        end

        req.getCookies = function()
            return cookieList["req"]
        end

        res.getCookies = function()
            return cookieList["res"]
        end

        res.getCookie = function(name)
            return cookieList["res"][name] and cookieList["res"][name].value
        end

        res.setCookie = function(name, value, httpOnly, priority, expiresAt)
            cookieList["res"][name] = {
                value = value,
                httpOnly = httpOnly,
                priority = priority,
                expiresAt = expiresAt
            }
            setResCookiesList()
        end

        computeReqCookiesList()

        next()
    end
end