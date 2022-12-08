local str = require("str")
local str_split = str.split
local _M = {}
--[[
@ get ip v4 decimal value 
]]
local function get_ip_num(ip_segs)
  local ip_num = 0
  local ip_shifts = { 16777216, 65536, 256, 1 }
  for i, seg in ipairs(ip_segs) do
    local v = tonumber(seg)
    if v ~= nil then
      ip_num = ip_num + v * ip_shifts[i]
    else
      return nil
    end
  end
  return ip_num
end

--[[
@ get ip v4 masks  
]]
local function get_ip_masks(high_bits)
  -- 32 bits of 1
  local total_mask = 4294967295
  local low_bits = 32 - high_bits
  if low_bits == 0 then
    return { total_mask, 0 }
  else
    local or_mask = tonumber(string.rep("1", low_bits), 2)
    return { total_mask - or_mask, or_mask }
  end
end

--[[
@ get ip ranges from cidr
]]
function _M.cidr2ranges(cidrs)
  local ip_ranges = {}
  for _, cidr in ipairs(cidrs) do
    local ip_segs = str_split(cidr, ".")
    if #ip_segs == 4 then
      local ip_seg_4 = ip_segs[4]
      local ip_seg_4_segs = str_split(ip_seg_4, "/")
      if #ip_seg_4_segs == 2 then
        local high_bits = tonumber(ip_seg_4_segs[2])
        if high_bits ~= nil and (high_bits >= 0 and high_bits <= 32) then
          ip_segs[4] = ip_seg_4_segs[1]
          local ip_num = get_ip_num(ip_segs)
          if ip_num ~= nil then
            local masks = get_ip_masks(high_bits)
            local mask, or_mask = masks[1], masks[2]
            local min_ip = tonumber(bit.tohex(bit.band(ip_num, mask)), 16)
            local max_ip = tonumber(bit.tohex(bit.bor(ip_num, or_mask)), 16)
            if high_bits <= 30 then
              ip_ranges[#ip_ranges + 1] = { min_ip + 1, max_ip - 1 }
            else
              ip_ranges[#ip_ranges + 1] = { min_ip, max_ip }
            end
          end
        end
      else
        local ip_num = get_ip_num(ip_segs)
        if ip_num ~= nil then
          ip_ranges[#ip_ranges + 1] = { ip_num, ip_num }
        end
      end
    end
  end
  return ip_ranges
end

--[[
@ check if ip is in cidr 
]]
function _M.is_ip_match(ip_v4, cidrs)
  local ip_segs = str_split(ip_v4, ",")
  if #ip_segs == 4 then
    local ip_num = get_ip_num(ip_segs)
    if ip_num ~= nil then
      local ip_ranges = _M.cidr2ranges(cidrs)
      for _, range in ipairs(ip_ranges) do
        local min_ip, max_ip = range[1], range[2]
        if ip_num >= min_ip and ip_num <= max_ip then
          return true
        end
      end
    end
  end
  return false
end

return _M
