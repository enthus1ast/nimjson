import nimjson/util
import json, os, strformat, parseopt

type
  Options = ref object
    args: seq[string]
    useHelp, useVersion: bool
    outFile: string
    objectName: string

const
  appName = "nimjson"
  version = "v1.0.0"
  doc = &"""
{appName} prints a converted Nim object type string from JSON file or string.

Usage:
    {appName} [options] [files...]
    {appName} (-h | --help)
    {appName} (-v | --version)

Options:
    -h, --help                       Print this help
    -v, --version                    Print version
    -o, --outfile:FILEPATH           Write file path
    -O, --object-name:OBJECT_NAME    Set object type name
"""

proc getCmdOpts*(params: seq[string]): Options =
  var optParser = initOptParser(params)
  new result

  # コマンドラインオプションを取得
  for kind, key, val in optParser.getopt():
    case kind
    of cmdArgument:
      result.args.add(key)
    of cmdLongOption, cmdShortOption:
      case key
      of "help", "h":
        echo doc
        result.useHelp = true
        return
      of "version", "v":
        echo version
        result.useVersion = true
        return
      of "outfile", "o":
        result.outFile = val
    of cmdEnd:
      assert false # cannot happen

when isMainModule:
  let opts = os.commandLineParams().getCmdOpts()
  if opts.useHelp or opts.useVersion: quit 0

  var outFile = if opts.outFile != "": opts.outFile.open(fmWrite)
                else: stdout
  if 0 < opts.args.len():
    for inFile in opts.args:
      outFile.write(inFile.parseFile().toTypeString())
  else:
    var str: string
    var line: string
    while stdin.readLine(line):
      str.add(line)
    outFile.write(str.parseJson().toTypeString())
  outFile.close()