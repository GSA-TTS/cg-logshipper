-- Convert the http_headers field (block of text) to a table of key:value pairs
function parse_http_headers(tag, timestamp, record)
    local header_string	= record["http_headers"]
    local headers = {}
    for header_name, val in string.gmatch(header_string, "(%S+): ([^\r\n]+)") do    
       -- fluent-bit keys cannot include dashes. Let's coerce to lowercase as well.
       local safe_name = string.lower(string.gsub(header_name, '-', '_'))
       headers[safe_name] = val
    end
    record["http_headers"] = headers
    -- 2 leaves timestamp unchanged    
    return 2, timestamp, record
end

