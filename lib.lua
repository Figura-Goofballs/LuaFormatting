local lib = {}

local ansi = {
   b = {
      variable = "bold";
      escape = "\x1b[1m";
      unescape = "\x1b[22m";
   },
   i = {
      variable = "itali";
      escape = "\x1b[3m";
      unescape = "\x1b[23m";
   },
   u = {
      variable = "underline";
      escape = "\x1b[4m";
      unescape = "\x1b[24m";
   },
   s = {
      variable = "strikethrough";
      escape = "\x1b[9m";
      unescape = "\x1b[29m";
   }
}

function lib.toAnsi(str)
   local formatLayers = {
      bold = 0;
      italic = 0;
      underline = 0;
      strikethrough = 0;
   }
   local final = ""

   local iter = 0
   local checking = false
   local layer = 1
   while iter <= #str do
      iter = iter + 1
      local char = str:sub(iter, iter)

      if checking then
         if char == "[" then
            layer = layer + 1
            checking = false
            goto continue
         elseif char == "]" then
            final = final .. "]"
            checking = false
            goto continue
         end

         if ansi[char] then
            final = final .. ansi[char].escape
            formatLayers[ansi[char].variable] = layer
         end
      else
         if char == "]" then
            if layer == 1 then
               final = final .. "]"
               goto continue
            end

            layer = layer - 1
            for _, v in pairs(ansi) do
               if formatLayers[v.variable] == layer then
                  formatLayers[v.variable] = 0
                  final = final .. v.unescape
               end
            end

            goto continue
         elseif char == "$" then
            checking = true
            goto continue
         end

         final = final .. char
      end

      ::continue::
   end

   return final
end

return lib

