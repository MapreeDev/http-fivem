local Error = {}

Error.throw = function(statusCode,message)
    if not statusCode then statusCode = 500 end
    if not message then message = "Unknown Error" end
    error(json.encode({ statusCode, message }))
end

Error.parse = function(err)
    local data = err:gsub('@.+:(%d+):', ''):gsub('%[%d+%]: ', '') or "{}"
    data = json.decode(data)
    local statusCode = data and data[1] or 500
    local body = data and data[2] or "Unknown error"
    return {statusCode = statusCode,body = body}
end

return Error