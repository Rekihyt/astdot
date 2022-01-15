# Astdot

Print a dot graph of a nim ast dumped using the `dumpTree` macro.


![example tree](example.jpg)

The theme used is currently hardcoded with colors from my syntax theme [oak](https://github.com/Rekihyt/oak).

Note: node names are hardcoded, and many are missing colors.

---

## View image

To view output in fim:
`astdot | dot -Tjpg | fim -i --autowindow`

## Feed output from `dumpTree`

Force recompile (to reprint macros) and pipe into astdot:
`nim r -f src/example.nim | astdot`

## Pipe clipboard

With xclip to paste from clipboard:
`xclip -selection clipboard -o | astdot`
