
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

#define cos(angle) \
    (angle == 90 ? 1 : \
     angle == 180 ? -1 : 0)

// With one parameter
#define ZERO(type) type(0)

// With parameters
#define LERP(src, dest, rate) src + (dest - src) * rate 

#ifndef TOTO
#define TOTO 42
int i;
#ifdef TEST
#define TRUC(X) X
#elif defined(TEST2)
#define TRUC(X) (2 * X)
#else
#define TRUC(X) (3 * X)
#endif
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
