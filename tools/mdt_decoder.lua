#!/usr/bin/env lua5.1
--[[
MDT Route String Decoder (Standalone Lua)
==========================================

This script decodes Mythic Dungeon Tools route strings outside of World of Warcraft.
It reimplements the necessary parts of LibDeflate and AceSerializer.

Requirements:
- Lua 5.1 (same version as WoW uses)
- lua-zlib (luarocks install lua-zlib)

Usage:
lua mdt_decoder.lua route_string.txt
lua mdt_decoder.lua "!fBvtpUjmq0FrbH)aS9X..."

Note: This is a simplified implementation for educational purposes.
For production use, consider the Python/Node.js/C# versions.
--]]

local zlib = require('zlib')
local json = require('json') or require('dkjson') or require('cjson')

-- If no JSON library is available, create a simple one
if not json then
  json = {
    encode = function(obj)
      if type(obj) == "table" then
        local parts = {}
        local is_array = true
        local max_index = 0

        for k, v in pairs(obj) do
          if type(k) ~= "number" then
            is_array = false
            break
          else
            max_index = math.max(max_index, k)
          end
        end

        if is_array then
          local array_parts = {}
          for i = 1, max_index do
            array_parts[i] = json.encode(obj[i] or "null")
          end
          return "["..table.concat(array_parts, ",").."]"
        else
          for k, v in pairs(obj) do
            table.insert(parts, '"'..tostring(k)..'":'..json.encode(v))
          end
          return "{"..table.concat(parts, ",").."}"
        end
      elseif type(obj) == "string" then
        return '"'..obj:gsub('"', '\\"')..'"'
      elseif type(obj) == "number" then
        return tostring(obj)
      elseif type(obj) == "boolean" then
        return obj and "true" or "false"
      else
        return '"'..tostring(obj)..'"'
      end
    end
  }
end

-- Custom Base64 alphabet used by MDT
local B64_ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789()"

-- Create decode table
local B64_DECODE = {}
for i = 1, #B64_ALPHABET do
  B64_DECODE[B64_ALPHABET:sub(i, i)] = i - 1
end

-- Bit manipulation functions (for Lua 5.1 compatibility)
local function bit_and(a, b)
  local result = 0
  local bitval = 1
  while a > 0 and b > 0 do
    if a % 2 == 1 and b % 2 == 1 then
      result = result + bitval
    end
    bitval = bitval * 2
    a = math.floor(a / 2)
    b = math.floor(b / 2)
  end
  return result
end

local function bit_lshift(a, b)
  return a * (2 ^ b)
end

local function bit_rshift(a, b)
  return math.floor(a / (2 ^ b))
end

-- Decode custom Base64 string to binary data
local function decode_custom_b64(encoded_str)
  local decoded = {}
  local bitfield = 0
  local bitfield_len = 0
  local decoded_size = 0

  for i = 1, #encoded_str do
    local ch = B64_DECODE[encoded_str:sub(i, i)]
    if ch then
      bitfield = bitfield + bit_lshift(ch, bitfield_len)
      bitfield_len = bitfield_len + 6

      while bitfield_len >= 8 do
        decoded_size = decoded_size + 1
        decoded[decoded_size] = string.char(bit_and(bitfield, 255))
        bitfield = bit_rshift(bitfield, 8)
        bitfield_len = bitfield_len - 8
      end
    end
  end

  return table.concat(decoded)
end

-- Decompress deflate data
local function decompress_data(compressed_data)
  local success, result = pcall(function()
    local stream = zlib.inflate()
    local decompressed, eof, bytes_in, bytes_out = stream(compressed_data)

    if decompressed then
      return decompressed
    else
      error("Decompression failed")
    end
  end)

  if success then
    return result
  else
    error("Decompression failed: "..tostring(result))
  end
end

-- Parse AceSerializer format data (simplified)
local function parse_ace_serialized_data(data)
  local result = {
    format = "AceSerializer",
    raw_data_hex = "",
    parsed_data = "Partial parsing - full AceSerializer implementation needed"
  }

  -- Convert to hex for inspection
  for i = 1, #data do
    result.raw_data_hex = result.raw_data_hex..string.format("%02x", string.byte(data, i))
  end

  -- Try to extract some basic information
  if data:find("week") then
    result.contains_week_info = true
  end
  if data:find("objects") then
    result.contains_objects = true
  end
  if data:find("pulls") then
    result.contains_pulls = true
  end

  -- Try to find patterns
  local dungeon_pattern = data:match("dungeonIdx.-(%d+)")
  if dungeon_pattern then
    result.dungeon_id = tonumber(dungeon_pattern)
  end

  local week_pattern = data:match("week.-(%d+)")
  if week_pattern then
    result.week = tonumber(week_pattern)
  end

  return result
end

-- Decode an MDT route string
local function decode_mdt_route_string(route_string)
  local success, result = pcall(function()
    -- Step 1: Remove the leading "!" marker
    local encoded_data = route_string
    if route_string:sub(1, 1) == "!" then
      encoded_data = route_string:sub(2)
    end

    -- Step 2: Decode custom Base64
    print("Decoding Base64...")
    local compressed_data = decode_custom_b64(encoded_data)
    print("Decoded "..#compressed_data.." bytes")

    -- Step 3: Decompress deflate data
    print("Decompressing data...")
    local decompressed_data = decompress_data(compressed_data)
    print("Decompressed to "..#decompressed_data.." bytes")

    -- Step 4: Parse serialized data
    print("Parsing serialized data...")
    local parsed_data = parse_ace_serialized_data(decompressed_data)

    -- Step 5: Create result structure
    return {
      metadata = {
        original_length = #route_string,
        compressed_length = #compressed_data,
        decompressed_length = #decompressed_data,
        compression_ratio = math.floor((#compressed_data / #decompressed_data) * 100) / 100
      },
      route_data = parsed_data
    }
  end)

  if success then
    return result
  else
    return {
      error = "Failed to decode route string: "..tostring(result),
      original_string = #route_string > 100 and (route_string:sub(1, 100).."...") or route_string
    }
  end
end

-- Main function
local function main(args)
  args = args or arg or {}

  if #args ~= 1 then
    print("Usage: lua mdt_decoder.lua <route_string_or_file>")
    print("Example: lua mdt_decoder.lua rt1.txt")
    print("Example: lua mdt_decoder.lua '!fBvtpUjmq0FrbH)aS9X...'")
    return
  end

  local input_arg = args[1]
  local route_string

  -- Check if it's a file or direct string
  if input_arg:match("%.txt$") or input_arg:match("[/\\]") then
    -- It's a file path
    local file = io.open(input_arg, "r")
    if not file then
      print("Error: File '"..input_arg.."' not found")
      return
    end

    route_string = file:read("*all"):gsub("%s+$", "")
    file:close()
  else
    -- It's a direct string
    route_string = input_arg
  end

  -- Decode the route string
  local result = decode_mdt_route_string(route_string)

  -- Output as JSON
  print(json.encode(result))
end

-- Run main function
main(arg)
