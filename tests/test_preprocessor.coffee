
fs = require "fs"
pegjs = require "pegjs"
Printer = require "../lib/utils/printer"
Preprocessor = require "../lib/visitors/preprocessor"

testFull = ->

  grammar = fs.readFileSync("../grammar/preprocessor.pegjs").toString()
  source = fs.readFileSync("../examples/preprocessor.glsl").toString()

  try
    parser = pegjs.buildParser(grammar)
    data = parser.parse(source)
    console.log Preprocessor.process(data)
  catch e
    if e.name is "SyntaxError"
      Printer.printError(e, source)
    else
      throw e

testFull()
