

fs = require "fs"
pegjs = require "pegjs"
Formatter = require "../lib/visitors/formatter"
Prefixer = require "../lib/visitors/prefixer"
Printer = require "../lib/utils/printer"

testFull = ->

  source = fs.readFileSync("../examples/full.glsl").toString()
  grammar = fs.readFileSync("../grammar/glsl.pegjs").toString()

  try

    parser = pegjs.buildParser(grammar)
    data = parser.parse(source)

    Prefixer.applyPrefix(data, "__filter_full_")
    console.log Formatter.getSource(data)

  catch e
    if e.name is "SyntaxError"
      Printer.printError(e, source)
    else
      throw e

testFull()