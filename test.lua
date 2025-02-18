local lib = require("lib")
print(table.concat(arg, " "))
print(lib.toAnsi(table.concat(arg, " ")))
print(lib.toHTML(table.concat(arg, " "), false))
print(lib.toHTML(table.concat(arg, " "), true))

