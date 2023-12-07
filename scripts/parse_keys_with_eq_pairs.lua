-- This parser is just a proof-of-concept.

KEYS_TO_PARSE = {"tags", "gauge"}

-- Splits a string of foo="bar" pairs and makes parsable json out of it.
function parse_keys_with_eq_pairs(tag, timestamp, record)
    print("record: ")
    print(record)
    for k, v in pairs(KEYS_TO_PARSE) do
        if (record[v] ~= nil) then
            record[v] = eq_pairs_to_json_string(record[v])
	end
    end
     -- 2 leaves timestamp unchanged
    return 2, timestamp, record
end

function eq_pairs_to_json_string(orig_string)
print("orig_string: ")
print(orig_string)

    local new_string = string.gsub(orig_string, "(%S+)=(%S+)", "\"%1\":%2,")
    -- trim off that last , and add curly braces around:
    new_string = string.gsub(new_string, "(.+),$", "{%1}")
    return new_string
end
