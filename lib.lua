--[[
Copyright 2025 Figura Goofballs

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]

local lib = {}

-- Almost fully taken from XTERM defaults. the only thing not the real default is #0000ff not being #5c5cff
lib.colorMap16 = {
   "#000000",
   "#cd0000",
   "#00cd00",
   "#cdcd00",
   "#0000ee",
   "#cd00cd",
   "#00cdcd",
   "#e5e5e5",
   "#7f7f7f",
   "#ff0000",
   "#00ff00",
   "#ffff00",
   "#0000ff",
   "#ff00ff",
   "#00ffff",
   "#ffffff"
}

-- 256 color to rgb hex
-- Ported from https://github.com/joejulian/xterm/blob/master/256colres.pl#L64-L76
local function colorToHex(int)
   local r, g, b = 0, 0, 0
   if int >= 0 and int <= 15 then -- System colors
      return lib.colorMap16[int + 1]
   elseif int >= 16 and int <= 231 then -- 6x6x6 RGB cube
      r = (math.floor((int - 16) / 36) * 40 + 55)
      g = (math.floor((int - 16) % 36 / 6) * 40 + 55)
      b = ((int - 16) % 6 * 40 + 55)
   elseif int >= 232 and int <= 255 then -- Grayscale ramp
      local gray = (int - 232) * 10 + 8
      r = gray
      g = gray
      b = gray
   else
      return "#000000"
   end

   r = math.min(255, math.max(0, math.floor(r)))  -- Clamp to 0-255
   g = math.min(255, math.max(0, math.floor(g)))
   b = math.min(255, math.max(0, math.floor(b)))

   local function toHex(c)
      return string.format("%02X", c)
   end

   local hex_color = "#" .. toHex(r) .. toHex(g) .. toHex(b)
   return hex_color
end

local function copy(tbl)
   local new = {}

   for key, value in pairs(tbl) do
      if type(value) == "table" then
         new[key] = copy(value)
      else
         new[key] = value
      end
   end

   return new
end

---@alias Color {8,number}|{24,number,number,number}

---@class Format
---@param b boolean Bold
---@param i boolean Italic
---@param u boolean Underline
---@param s boolean Strikethrough
---@param fg Color Foreground color
---@param bg Color Background color

local eightColorMap = {"black", "red", "green", "yellow", "blue", "light_purple", "aqua", "white"}

--- Translates a LuaFormatting string to an arbitrary format.
--- @param formatterFunction fun(style: Format, nextStyle: Format, text: string) The converter function to format a bit of text with a specific style.
--- @param text string The text to format.
function lib.convertViaFormatter(formatterFunction, text, ...)
	local style = {}
	while text ~= "" do
		local nextPos = text:find("[$%]]")
		if nextPos then
			local frag, rest = text:sub(1, nextPos), text:sub(nextPos, -1)
			local newStyle = setmetatable({}, { __index = style })
			formatterFunction(style, newStyle, frag, ...)
		else
			formatterFunction(style, {}, text, ...)
		end
	end
end

local function convertAnsi(style, nextStyle, text)
	-- TODO
end

--- Translates a LuaFormatting string to SGR-escaped text.
--- @param text string The text to format.
function lib.toAnsi(text)
	local tbl = {""}
	lib.convertViaFormatter(convertAnsi, text, tbl)
	return tbl[1]
end

return lib

