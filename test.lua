local lib = require("lib")
local str = "This $b[is $bius[a $c25[test $cffaaee[string] lol]] :3]"

local correctAnsi = "This \x1b[1mis \x1b[1m\x1b[3m\x1b[4m\x1b[9ma \x1b[38;5;25mtest \x1b[38;2;255;170;238mstring\x1b[0m\x1b[1m\x1b[3m\x1b[4m\x1b[9m\x1b[38;5;25m lol\x1b[0m\x1b[1m\x1b[3m\x1b[4m\x1b[9m\x1b[0m\x1b[1m :3\x1b[0m"
local correctH4 = '<p><font color="white">This </font><b><font color="white">is </font></b><b><i><s><u><font color="white">a </font></u></s></i></b><b><i><s><u><font color="#375FAF">test </font></u></s></i></b><b><i><s><u><font color="#ffaaee">string</font></u></s></i></b><b><i><s><u><font color="#375FAF"> lol</font></u></s></i></b><b><i><s><u><font color="white"></font></u></s></i></b><b><font color="white"> :3</font></b><font color="white"></font></p>'
local correctH5 = '<p><span style="color: white">This </span><b><span style="color: white">is </span></b><b><i><s><span style="text-decoration: underline"><span style="color: white">a </span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375FAF">test </span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #ffaaee">string</span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375FAF"> lol</span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: white"></span></span></s></i></b><b><span style="color: white"> :3</span></b><span style="color: white"></span></p>'

local ansi = lib.toAnsi(str)
local html4 = lib.toHTML(str, false)
local html5 = lib.toHTML(str, true)

local failed = false
if ansi ~= correctAnsi then print("[FAIL] ANSI is not correct."); failed = true end
if html4 ~= correctH4 then print("[FAIL] HTML4 is not correct."); failed = true end
if html5 ~= correctH5 then print("[FAIL] HTML5 is not correct."); failed = true end

if failed then error() end

