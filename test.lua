local lib = require("lib")
local str = "This $b[is $bius[a $c25[test $cffaaee[string] $C(2)[lol]]] :3]"

local correctAnsi = "\x1b[38;5;7m\x1b[48;5;0mThis \x1b[1m\x1b[38;5;7m\x1b[48;5;0mis \x1b[3m\x1b[4m\x1b[9ma \x1b[38;5;25mtest \x1b[38;2;255;170;238mstring\x1b[38;5;25m \x1b[48;5;2mlol\x1b[48;5;0m\x1b[38;5;7m\x1b[23m\x1b[24m\x1b[29m :3\x1b[22m\x1b[38;5;7m\x1b[48;5;0m"
local correctH4 = '<p><font color="#000000">This </font><b><font color="#000000">is </font></b><b><i><s><u><font color="#000000">a </font></u></s></i></b><b><i><s><u><font color="#375faf">test </font></u></s></i></b><b><i><s><u><font color="#ffaaee">string</font></u></s></i></b><b><i><s><u><font color="#375faf"> </font></u></s></i></b><b><i><s><u><font color="#375faf"><span style="background: #00cd00">lol</span></font></u></s></i></b><b><i><s><u><font color="#375faf"></font></u></s></i></b><b><i><s><u><font color="#000000"></font></u></s></i></b><b><font color="#000000"> :3</font></b><font color="#000000"></font></p>'
local correctH5 = '<p><span style="color: #000000">This </span><b><span style="color: #000000">is </span></b><b><i><s><span style="text-decoration: underline"><span style="color: #000000">a </span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375faf">test </span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #ffaaee">string</span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375faf"> </span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375faf"><span style="background: #00cd00">lol</span></span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #375faf"></span></span></s></i></b><b><i><s><span style="text-decoration: underline"><span style="color: #000000"></span></span></s></i></b><b><span style="color: #000000"> :3</span></b><span style="color: #000000"></span></p>'

local ansi = lib.toAnsi(str)
local html4 = lib.toHTML(str, false)
local html5 = lib.toHTML(str, true)

local failed = false
if ansi ~= correctAnsi then print("[FAIL] ANSI is not correct."); failed = true end
if html4 ~= correctH4 then print("[FAIL] HTML4 is not correct."); failed = true end
if html5 ~= correctH5 then print("[FAIL] HTML5 is not correct."); failed = true end

if failed then error() end

