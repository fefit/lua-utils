local _M = {}

local url_mark_chars = {
  ['~'] = 126,
  ['_'] = 95,
  ['.'] = 46,
  ['-'] = 45,
  ['*'] = 42,
  [')'] = 41,
  ['('] = 40,
  ["'"] = 39,
  ['!'] = 33
}

local function char_encode_url(code)
  if code <= 122 and code >= 97 then
    -- a-z
    return string.char(code)
  elseif code <= 90 and code >= 65 then
    -- A-Z
    return string.char(code)
  elseif code <= 57 and code >= 48 then
    -- 0-9
    return string.char(code)
  else
    -- mark characters
    for ch, char_code in pairs(url_mark_chars) do
      if char_code == code then
        return ch
      end
    end
  end
  -- URL encode
  return string.format("%%%02X", code)
end

--[[
encode URI
]]
function _M.encode(value)
  local len = #value
  local result = {}
  for i = 1, len do
    local encoded = char_encode_url(string.byte(value, i))
    table.insert(result, encoded)
  end
  return table.concat(result, "")
end

return _M
