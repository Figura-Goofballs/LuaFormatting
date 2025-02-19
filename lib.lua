---@class LuaFormatting
local lib = {}

---@alias LuaFormatting.Color {bits: 8, color: integer, default: boolean?}|{bits: 24, color: string, default: boolean?}
---@alias LuaFormatting.Style {bold: boolean, italic: boolean, underline: boolean, strikethrough: boolean, fgColor: LuaFormatting.Color?, bgColor: LuaFormatting.Color?}

---Map 16-color to 24-bit color.
---
---This uses (almost) the xterm defaults.
lib.sixteenColorMap = {
   "#000000";
   "#cd0000";
   "#00cd00";
   "#cdcd00";
   "#0000ee";
   "#cd00cd";
   "#00cdcd";
   "#e5e5e5";
   "#7f7f7f";
   "#ff0000";
   "#00ff00";
   "#ffff00";
   "#0000ff";
   "#ff00ff";
   "#00ffff";
   "#ffffff";
}

local function rgbToHex(r, g, b)
   local format = "%02x"
   return "#" .. format:format(r) .. format:format(g) .. format:format(b)
end

---Convert 256-color to 24-bit color.
---
---Made using xterm's source code as a reference.
---@param int integer
---@return LuaFormatting.Color
function lib.eightBitTo24BitColor(int)
   local r, g, b = 0, 0, 0
   if int >= 0 and int <= 15 then -- System colors
      return {bits = 24, color = lib.sixteenColorMap[int + 1]}
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
      return {bits = 24, color = "#000000"}
   end

   r = math.min(255, math.max(0, math.floor(r)))  -- Clamp to 0-255
   g = math.min(255, math.max(0, math.floor(g)))
   b = math.min(255, math.max(0, math.floor(b)))

   return {bits = 24, color = rgbToHex(r, g, b)}
end

local charVars = {
   b = "bold",
   i = "italic",
   u = "underline",
   s = "strikethrough"
}

---Converts to any format using a function.
---@param str any
---@param func fun(oldStyle: LuaFormatting.Style?, newStyle: LuaFormatting.Style, text: string, ...): string
---@return unknown
function lib.convertUsingFormatter(str, func, ...)
   local final = ""

   local styles = {
      {
         text = "",
         style = {
            bold = false,
            italic = false,
            underline = false,
            strikethrough = false,
            fgColor = {bits = 8, color = 7, default = true},
            bgColor = {bits = 8, color = 0, default = true}
         }
      }
   }
   local layers = {
      {
         bold = false,
         italic = false,
         underline = false,
         strikethrough = false,
         fgColor = {bits = 8, color = 7, default = true},
         bgColor = {bits = 8, color = 0, default = true}
      }
   }

   local checking = false
   ---@type boolean|string
   local color = false
   local newStyle = {
      bold = false,
      italic = false,
      underline = false,
      strikethrough = false,
      fgColor = {bits = 8, color = 7, default = true},
      bgColor = {bits = 8, color = 0, default = true},
   }
   local iter = 0
   for char in str:gmatch("[\0-\x7F\xC2-\xF4][\x80-\xBF]*") do
      iter = iter + #char

      if color then
         local subbed = str:sub(iter, iter + 7)
         local hex = subbed:match("^%(?#?%x%x%x%x%x%x%)?")
         local int = subbed:match("^%(?%d%d?%d?%)?")

         if hex then
            newStyle[color] = {bits = 24, color = "#" .. hex:gsub("[%(%)#]", "")}
         elseif int then
            ---@diagnostic disable-next-line
            newStyle[color] = {bits = 8, color = tonumber(int:gsub("[%(%)]", ""), nil)}
         end
         color = false
      elseif checking then
         if char == "$" or char == "]" then
            styles[#styles].text = styles[#styles].text .. char
         elseif char == "[" then
            layers[#layers + 1] = newStyle
            styles[#styles + 1] = {
               text = "",
               style = newStyle
            }
            newStyle = {
               bold = styles[#styles].style.bold,
               italic = styles[#styles].style.italic,
               underline = styles[#styles].style.underline,
               strikethrough = styles[#styles].style.strikethrough,
               fgColor = styles[#styles].style.fgColor,
               bgColor = styles[#styles].style.bgColor
            }
            checking = false
         end

         local var = charVars[char]
         if var then
            newStyle[var] = true
         elseif char == "c" then
            color = "fgColor"
         elseif char == "C" then
            color = "bgColor"
         end
      elseif char == "$" then
         checking = true
      elseif char == "]" then
         newStyle = {}
         layers[#layers] = nil
         styles[#styles + 1] = {
            style = layers[#layers],
            text = ""
         }
         newStyle = {
            bold = layers[#layers].bold,
            italic = layers[#layers].italic,
            underline = layers[#layers].underline,
            strikethrough = layers[#layers].strikethrough,
            fgColor = layers[#layers].fgColor,
            bgColor = layers[#layers].bgColor
         }
      else
         styles[#styles].text = styles[#styles].text .. char
      end
   end

   for k, v in ipairs(styles) do
      final = final .. func((styles[k - 1] or {}).style, v.style, v.text, ...)
   end

   return final
end

local keys = {"bold", "italic", "underline", "strikethrough", "fgColor", "bgColor"}
local function toAnsi(oldStyle, newStyle, text)
   local styleText = ""

   oldStyle = oldStyle or {
      bold = false,
      italic = false,
      strikethrough = false,
      underline = false
   }
   newStyle = newStyle or {
      bold = false,
      italic = false,
      strikethrough = false,
      underline = false
   }

   local diff = {}

   for key, value in pairs(newStyle) do
      if oldStyle[key] == value then goto continue end

      diff[key] = value

      if value == nil then
         diff[key] = false
      end

      ::continue::
   end

   for _, key in ipairs(keys) do
      local value = diff[key]
      if value == nil then goto continue end

      if key == "bold" then
         if value then
            styleText = styleText .. "\x1b[1m"
         else
            styleText = styleText .. "\x1b[22m"
         end
      elseif key == "italic" then
         if value then
            styleText = styleText .. "\x1b[3m"
         else
            styleText = styleText .. "\x1b[23m"
         end
      elseif key == "underline" then
         if value then
            styleText = styleText .. "\x1b[4m"
         else
            styleText = styleText .. "\x1b[24m"
         end
      elseif key == "strikethrough" then
         if value then
            styleText = styleText .. "\x1b[9m"
         else
            styleText = styleText .. "\x1b[29m"
         end
      elseif key == "fgColor" then
         styleText = styleText .. "\x1b["
         local bits = value.bits

         if bits == 8 then
            styleText = styleText .. "38;5;" .. value.color .. "m"
         elseif bits == 24 then
            local r, g, b = value.color:match("#(%x%x)(%x%x)(%x%x)")

            r = tonumber("0x" .. r)
            g = tonumber("0x" .. g)
            b = tonumber("0x" .. b)

            styleText = styleText .. "38;2;" .. r .. ";" .. g .. ";" .. b .. "m"
         end
      elseif key == "bgColor" then
         styleText = styleText .. "\x1b["
         local bits = value.bits

         if bits == 8 then
            styleText = styleText .. "48;5;" .. value.color .. "m"
         elseif bits == 24 then
            local r, g, b = value.color:match("#(%x%x)(%x%x)(%x%x)")

            r = tonumber("0x" .. r)
            g = tonumber("0x" .. g)
            b = tonumber("0x" .. b)

            styleText = styleText .. "48;2;" .. r .. ";" .. g .. ";" .. b .. "m"
         end
      end

      ::continue::
   end


   return styleText .. text
end

function lib.toAnsi(str)
   return lib.convertUsingFormatter(str, toAnsi)
end

local function toHTML(_, style, str, five)
   local finalStr = ""

   if not style.fgColor then return str end

   local color = (style.fgColor.default and "#000000") or
   (style.fgColor.bits == 24 and style.fgColor.color) or
   (style.fgColor.bits == 8 and lib.eightBitTo24BitColor(style.fgColor.color).color)

   local bgColor = (style.bgColor.default and "") or
   (style.bgColor.bits == 24 and style.bgColor.color) or
   (style.bgColor.bits == 8 and lib.eightBitTo24BitColor(style.bgColor.color).color)

   five = five and true
   local text = str:gsub(".", {
      ["&"] = "&amp;";
      ["<"] = "&lt;";
      [">"] = "&gt;";
   })

   finalStr = finalStr ..
   (style.bold and "<b>" or "") ..
   (style.italic and "<i>" or "") ..
   (style.strikethrough and "<s>" or "")

   if five then
      finalStr = finalStr .. (style.underline and '<span style="text-decoration: underline">' or "")
   else
      finalStr = finalStr .. (style.underline and "<u>" or "")
   end

   if five and color then
      finalStr = finalStr .. '<span style="color: ' .. color .. '">'
   elseif color then
      finalStr = finalStr .. '<font color="' .. color .. '">'
   end

   if bgColor ~= "" then
      finalStr = finalStr .. '<span style="background: ' .. bgColor .. '">'
   end

   finalStr = finalStr .. text

   if bgColor ~= "" then
      finalStr = finalStr .. '</span>'
   end

   if five and color then
      finalStr = finalStr .. '</span>'
   elseif color then
      finalStr = finalStr .. '</font>'
   end

   if five then
      finalStr = finalStr .. (style.underline and '</span>' or "")
   else
      finalStr = finalStr .. (style.underline and "</u>" or "")
   end

   finalStr = finalStr ..
   (style.strikethrough and "</s>" or "") ..
   (style.italic and "</i>" or "") ..
   (style.bold and "</b>" or "")

   return finalStr
end

function lib.toHTML(str, five)
   return "<p>" .. lib.convertUsingFormatter(str, toHTML, five) .. "</p>"
end

return lib

