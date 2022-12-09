local str = require "str"
local str_split = str.split
local _M = {}

--[[
@ loop the fields until the last field
--]]
local function json_loop(data, fields, cb, index)
  if type(data) ~= "table" then
    return
  end
  local field = fields[index]
  if index == #fields then
    -- the last field of the field paths
    if field == "*" then
      for i, v in ipairs(data) do
        data[i] = cb(v)
      end
    else
      data[field] = cb(data[field])
    end
  else
    -- not the last field
    local cur_index = index + 1
    if field == "*" then
      for _, v in ipairs(data) do
        json_loop(v, fields, cb, cur_index)
      end
    else
      json_loop(data[field], fields, cb, cur_index)
    end
  end
end

--[[
@ change a json data
--]]
function _M.jsonfy(data, selector, cb)
  json_loop(data, str_split(selector, "."), cb, 1)
  return data
end

return _M
