
fs = require "fs"
pegjs = require "pegjs"
Printer = require "../lib/utils/printer"

source = """

// Very simple
#define DALI

// Simple
#define ZERO_VEC3 vec3(0, 0, 0)

// Multilines
#define ZERO_VEC2 \
  vec2(0, \
    0)

// With one parameter
#define ZERO(type) type(0)

// With parameters
#define LERP(src, dest, rate) src + (dest - src) * rate 

#ifndef TOTO
#endif

"""

testFull = ->
  try
    grammar = fs.readFileSync("../grammar/preprocessor.pegjs").toString()
    parser = pegjs.buildParser(grammar)
    console.log parser.parse(source)
  catch e
    if e.name is "SyntaxError"
      Printer.printError(e, source)
    else
      throw e

testFull()