
fs = require "fs"
pegjs = require "pegjs"
Formatter = require "../lib/visitors/formatter"
Printer = require "../lib/utils/printer"

testFull = ->
  source = fs.readFileSync("../examples/full.glsl").toString()
  grammar = fs.readFileSync("../grammar/glsl.pegjs").toString()
  try
    parser = pegjs.buildParser(grammar)
    data = parser.parse(source)
    fmt = new Formatter()
    console.log fmt.getSource(data)
  catch e
    Printer.printError(e, source)

testFull()