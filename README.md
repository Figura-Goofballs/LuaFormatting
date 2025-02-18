# LuaFormatting
## Syntax
Here's an example:
```
This is $b[bold and $i[italic]]! This is also $bi[bold and italic]
Here's an example for [brackets$]
```
This is **bold and *italic***! This is also ***bold and italic***  
Here's an example for \[brackets\]
| Character | Format |
| --- | --- |
| `b` | bold |
| `i` | italic |
| `u` | underline |
| `s` | strikethrough |
| `c` | color (see below) |
## Color
After the `c` for setting color, you want to put a number 0-255 for 256 color (0-7 uses 8 color), or put a hexadecimal string.  
Example:
```
This is $cffaaee[pink (24-bit)], this is $c3[yellow (8 color)], and this is $c25[a shade of blue (256 color)]
```
## Methods
toAnsi(str) -- convert to ansi escapes
toMinecraft(str) -- convert to a minecraft raw text component (converting to json not done by this library, this just returns a table)
toHTML(str, five) -- convert to html. if five is true, it doesn't use elements removed in html5, so the output will be larger.

