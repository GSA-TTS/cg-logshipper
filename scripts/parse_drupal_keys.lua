DRUPAL_KEYS_WITH_TERMINATORS = {}
DRUPAL_KEYS_WITH_TERMINATORS["base_url"] = "severity"
DRUPAL_KEYS_WITH_TERMINATORS["severity"] = "type"
DRUPAL_KEYS_WITH_TERMINATORS["type"] = "date"
DRUPAL_KEYS_WITH_TERMINATORS["date"] = "message"
DRUPAL_KEYS_WITH_TERMINATORS["message"] = "uid"
DRUPAL_KEYS_WITH_TERMINATORS["uid"] = "request_uri"
DRUPAL_KEYS_WITH_TERMINATORS["request_uri"] = "refer"
DRUPAL_KEYS_WITH_TERMINATORS["refer"] = "link"
DRUPAL_KEYS_WITH_TERMINATORS["link"] = ""

-- Splits a string of foo="bar" pairs and makes parsable json out of it.
function parse_keys_with_eq_pairs(tag, timestamp, record)
    print("record: ")
    print(record)
    if (record["drupal"] ~= nil) then
        record["drupal"] = drupal_attributes_json_string(record["drupal"])
    end
     -- 2 leaves timestamp unchanged
    return 2, timestamp, record
end

function drupal_attributes_json_string(orig_string)
    print("orig_string: ")
    print(orig_string)
    -- replace all the = with : and add a comma to the end of each line, use v as terminator to account for unknown characters in attribute values
    for k, v in DRUPAL_KEYS_WITH_TERMINATORS do
        new_string = string.gsub(
            orig_string,
            k .. "= (.*) " .. v,
            "\"" .. k .. "\":\"%1\","
        )
    end
    print("new_string: ")
    print(new_string)
    escaped_string = escape_JSON_special_charaters(new_string);
    -- trim off that last , and add curly braces around:
    final_string = string.gsub(escaped_string, "(.+),$", "{%1}")
    print("final_string: ")
    print(final_string)
    return final_string
end

function escape_JSON_special_charaters(orig_string)
    local new_string = string.gsub(orig_string, "\\", "\\\\")
    new_string = string.gsub(new_string, "\"", "\\\"")
    new_string = string.gsub(new_string, "/", "\\/")
    new_string = string.gsub(new_string, "\b", "\\b")
    new_string = string.gsub(new_string, "\f", "\\f")
    new_string = string.gsub(new_string, "\n", "\\n")
    new_string = string.gsub(new_string, "\r", "\\r")
    new_string = string.gsub(new_string, "\t", "\\t")
    return new_string
end