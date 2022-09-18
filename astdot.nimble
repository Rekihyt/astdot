# Package

version       = "1.0.1"
author        = "Rekihyt"
description   = "Prints a dot graph of a nim ast dumped using the `dumpTree` macro."
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
bin           = @["astdot"]


# Dependencies

requires "nim >= 1.2.0"
requires "clapfn"
requires "nimgraphviz >= 0.3.0"