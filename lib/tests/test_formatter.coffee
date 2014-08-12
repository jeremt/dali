
fs = require "fs"
pegjs = require "pegjs"
Formatter = require "../visitors/formatter"
Printer = require "../utils/printer"

testGetSource = ->
  source = fs.readFileSync("../../examples/full.glsl").toString()
  grammar = fs.readFileSync("../../grammar/glsl.pegjs").toString()
  try
    parser = pegjs.buildParser(grammar)
    data = parser.parse(source)
    fmt = new Formatter(prefix: "__filter_full_")
    console.log fmt.getSource(data)
  catch e
    Printer.printError(e, source)

testGetSource()