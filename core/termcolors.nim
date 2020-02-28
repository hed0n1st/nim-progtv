
import
  strutils,
  strformat

type
  Color* = enum
    black = 0
    red = 1
    green = 2
    yellow = 3
    blue = 4
    magenta = 5
    cyan = 6
    white = 7
    cchar = "\u001b"
    cbold = "\u001b[1m"
    cunderline = "\u001b[4m"
    creversed = "\u001b[7m"
    creset = "\u001b[0m"

proc colorMode(s: string, mode: string = ""): string =
  result = s
  if mode.contains("b"): result &= $cbold
  if mode.contains("u"): result &= $cunderline
  if mode.contains("r"): result &= $creversed

proc fg256*(s: string, color: int, mode: string = ""): string =
  var colorCode = fmt"[38;5;{color}m".colorMode(mode)
  result = join([$cchar, colorCode, s, $creset])

proc bg256*(s: string, color: int): string =
  var colorCode = fmt"[48;5;{color}m"
  result = join([$cchar, colorCode, s, $creset])

proc fgColor*(s: string, color: Color, bright: bool = false, mode: string = ""): string =
  var colorCode: string
  case bright
  of true:
    colorCode = fmt"[3{ord(color)};1m".colorMode(mode)
  of false:
    colorCode = fmt"[3{ord(color)}m".colorMode(mode)

  result = join([$cchar, colorCode, s, $creset])

proc bgColor*(s: string, color: Color, bright: bool = false): string =
  var colorCode: string
  case bright
  of true:
    colorCode = fmt"[4{ord(color)};1m"
  of false:
    colorCode = fmt"[4{ord(color)}m"
  result = join([$cchar, colorCode, s, $creset])

# foreground
proc fgBlack*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(black, bright, mode)

proc fgRed*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(red, bright, mode)

proc fgGreen*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(green, bright, mode)

proc fgYellow*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(yellow, bright, mode)

proc fgBlue*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(blue, bright, mode)

proc fgMagenta*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(magenta, bright, mode)

proc fgCyan*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(cyan, bright, mode)

proc fgWhite*(s: string, bright: bool = false, mode: string = ""): string =
  result = s.fgColor(white, bright, mode)

# background
proc bgBlack*(s: string, bright: bool = false): string =
  result = s.bgColor(black, bright)

proc bgRed*(s: string, bright: bool = false): string =
  result = s.bgColor(red, bright)

proc bgGreen*(s: string, bright: bool = false): string =
  result = s.bgColor(green, bright)

proc bgYellow*(s: string, bright: bool = false): string =
  result = s.bgColor(yellow, bright)

proc bgBlue*(s: string, bright: bool = false): string =
  result = s.bgColor(blue, bright)

proc bgMagenta*(s: string, bright: bool = false): string =
  result = s.bgColor(magenta, bright)

proc bgCyan*(s: string, bright: bool = false): string =
  result = s.bgColor(cyan, bright)

proc bgWhite*(s: string, bright: bool = false): string =
  result = s.bgColor(white, bright)

# modes
proc bold*(s: string): string =
  result = $cbold & s & $creset

proc underline*(s: string): string =
  result = $cunderline & s & $creset

proc reversed*(s: string): string =
  result = $creversed & s & & $creset

