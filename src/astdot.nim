## To view output in fim:
## astdot | dot -Tjpg | fim -i --autowindow
## 
## Force recompile (to reprint macros) and pipe into astdot
## nim r -f src/example.nim | astdot
## 
## With xclip to paste from clipboard:
## xclip -selection clipboard -o | astdot

# TODO:
# diffing
# custom color rules options

import nimgraphviz
import strutils
import clapfn


var parser = ArgumentParser(
  programName: "astdot",
  fullName: "Nim AST Grapher",
  description: "Prints a dot graph of a nim ast dumped using" &
    " the `dumpTree` macro.",
  version: "1.0.0",
  author: "Rekihyt <checkmateguy@gmail.com>"
)

parser.addSwitchArgument(
  shortName="-j",
  longName="--jpg",
  default=false,
  help="Output jpg image instead of a dot string."
)


var
  indentLevel = 0
  prevIndentLevel = 0
  indentLevelDiff = 0
  nth = 0                       # The nth node used as the unique identifier 
  parents: seq[string] = @[""]  # Stack of parent nodes, most recent on top
  graph = newGraph[Arrow]()
  line: string

const colorRules = {
      "comments": "#579C89",
      "types": "#09C284",
      "modules": "#9779DF",
      "keywords": "#5086CE",
      "literals": "#CFA957",
      "functions": "#30B040",
      "variables": "#9e6f32",
      "escapes": "#A0A0A0",
      "generics": "#81FF90",
      "operators": "#C26F9B",
      "source": "#978266"
  }.toTable()


proc countIndents(str: string): int =
  for c in str:
    if c == ' ':
      result += 1
    else:
      break

  if result mod 2 == 0:
    result = result div 2
  else:
    quit("Odd number of spaces on line " & 'n' & $nth & ":\n" & str)

func matchColor(nodeName: string): string =
  let color = case split(nodeName)[0]
    of "StmtList":
      "modules"
    of "Ty":
      "types"
    of "StrLit", "IntLit", "BoolLit":
      "literals"
    of "Ident":
      "variables"
    of "VarSection", "LetSection":
      "keywords"
    of "ProcDef", "Command":
      "functions"
    of "Prefix", "Bracket", "BracketExpr":
      "operators"
    else:
      "source"
  colorRules[color]


while not stdin.endOfFile():
  line = stdin.readLine()
  indentLevel = line.countIndents()
  indentLevelDiff = line.countIndents() - prevIndentLevel
  let color = matchColor(line.strip())
  # Prefix dot node names with 'n', so they aren't just
  # numbers (which aren't accepted)
  graph.addNode('n' & $nth, [
      ("label", line.strip()),
      ("fontcolor", color),
      ("color", color),
    ]
  )

  # At the top level, nodes are all parents. Draw a new tree each time by
  # overwriting last node in parents.
  if indentLevel == 0:
    parents[^1] = line
  elif indentLevelDiff == 0:
    # New child
    graph.addEdge(parents[^1] -> 'n' & $nth)
  elif indentLevelDiff == 1:
    # Previous node must be the parent, add to parents
    parents.add( 'n' & $(nth - 1))
    graph.addEdge(parents[^1] -> 'n' & $nth)
  elif indentLevelDiff <= -1:
    # Each negative indentation level corresponds to the end of a node.
    for _ in 1 .. indentLevelDiff:
      discard parents.pop()
    # Add this node to the grandparent of the previous.
    graph.addEdge(parents[^1] -> 'n' & $nth)
  else:
    quit("Incorrect indentation on line " & 'n' & $nth & ":\n" & line)

  nth += 1
  prevIndentLevel = indentLevel


echo graph.exportDot()