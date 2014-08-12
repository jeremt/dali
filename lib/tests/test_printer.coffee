
Printer = require "./printer.coffee"

TEST_SOURCE = """
void main() {
  int i
  vec3 color = vec3(0, 0, 0);
  for (int j = 0; j < 5; ++j)
    color.b += j/10;
}
"""

testPrintMessage = ->
  Printer.printMessage("test", {message: "Coucou", line: 1, column: 0}, TEST_SOURCE)

testPrintError = ->
  Printer.printError({message: "missing ';' after `int i`", line: 2, column: 8}, TEST_SOURCE)

testPrintWarning = ->
  Printer.printWarning({message: "missing `gl_FragColor` assignation", line: 6, column: 0}, TEST_SOURCE)

testOneline = ->
  Printer.printError({message: "test", line: 0, column: 0}, TEST_SOURCE, oneline: true)

testPrintMessage()
testPrintError()
testPrintWarning()
testOneline()