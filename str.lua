local _M = {}

function _M.char_at(str, index)
  return string.sub(str, index, index)
end

function _M.split(str, sep)
  local result = {}
  if #sep == 0 then
    -- sep is empty
    for i = 1, #str do
      result[i] = _M.char_at(str, i)
    end
  else
    -- not empty seperator
    local index = nil
    local start_index = 1
    local end_index = 1
    local loops = 1
    while true do
      index, end_index = string.find(str, sep, start_index, true)
      if index ~= nil then
        result[loops] = string.sub(str, start_index, index - 1)
        start_index = end_index + 1
        loops = loops + 1
      else
        result[loops] = string.sub(str, start_index)
        break
      end
    end
  end
  return result
end

return _M
