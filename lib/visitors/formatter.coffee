
BaseVisitor = require("./base")

# @class FormatterVisitor
# Handle the convertion of an ast node to a glsl source code. It also handle
#     the code formatting (minification, number of tabulations...).
#
class FormatterVisitor extends BaseVisitor

  @getSource: (node) ->
    new FormatterVisitor().getSource(node)

  # Creates a FormatterVisitor.
  # @constructor
  #
  # @param {String} tab the string used for tabulations
  # @param {Boolean} minified wheter the compiled code should be minified
  #
  constructor: ({@tab, @minified} = {}) ->
    @tab ?= '  '
    @minified ?= false

  addNewLine: ->
    if @minified then return ""
    @_sourceCode += "\n"
    for i in [0...@_indentLevel]
      @_sourceCode += @tab

  addOperator: (op) ->
    @_sourceCode += if @minified then op else " #{op} "

  addLeftBrace: ->
    if @minified
      @_sourceCode += "{"
    else
      @_sourceCode += " {"
      @addNewLine()

  addRightBrace: (newline = true) ->
    if @minified
      @_sourceCode += "}"
    else
      # Remove the tabulation generated by the last statement.
      @_sourceCode = @_sourceCode.substr(0, @_sourceCode.length - @tab.length)
      @_sourceCode += "}"
      if newline
        @addNewLine()

  addComma: ->
    @_sourceCode += if @minified then "," else ", "

  addSemicolon: (newline = true) ->
    @_sourceCode += ";"
    unless @minified
      if newline
        @addNewLine()
      else
        @_sourceCode += " "

  getSource: (node) ->
    @_sourceCode = ""
    @_indentLevel = 0
    @visitNode(node)
    @_sourceCode

  onRoot: (node) ->
    for statement in node.statements
      @visitNode(statement)
      # TODO(jeremie) find a way to avoid this kind of exceptions
    # @visitNodes(node.statements)

  onFunctionDeclaration: (node) ->
    @visitNode(node.returnType)
    @_sourceCode += " "
    @_sourceCode += node.name
    @_sourceCode += "("
    isFirst = true
    for parameter in node.parameters
      if isFirst is true
        isFirst = false
      else
        @addComma()
      @visitNode(parameter)
    @_sourceCode += ")"
    @visitNode(node.body)

  onParameter: (node) ->
    @_sourceCode += node.type_name
    @_sourceCode += " "
    @_sourceCode += node.name

  onReturn: (node) ->
    @_sourceCode += "return "
    @visitNode(node.value)
    @addSemicolon()

  onScope: (node) ->
    @_indentLevel += 1
    @addLeftBrace()
    @visitNodes(node.statements)
    @_indentLevel -= 1
    @addRightBrace()

  onExpression: (node) ->
    @visitNode(node.expression)
    @addSemicolon()

  onFunctionCall: (node) ->
    @_sourceCode += node.function_name
    @_sourceCode += "("
    isFirst = true
    for parameter in node.parameters
      if isFirst is true
        isFirst = false
      else
        @addComma()
      @visitNode(parameter)
    @_sourceCode += ")"

  onDeclarator: (node, newline) ->
    @visitNode(node.typeAttribute)
    @_sourceCode += " "
    @visitNodes(node.declarators)
    @addSemicolon(newline)

  onDeclaratorItem: (node) ->
    @visitNode(node.name)
    if node.initializer?
      @addOperator("=")
      @visitNode(node.initializer)

  onIfStatement: (node) ->
    @_sourceCode += if @minified then "if(" else "if ("
    @visitNode(node.condition)
    @_sourceCode += ")"
    if node.body.type isnt "scope"
      @_indentLevel += 1
      @addNewLine()
      @_indentLevel -= 1
    @visitNode(node.body)
    if node.elseBody?
      @_sourceCode += "else "
      unless node.elseBody.type in ["if_statement", "scope"]
        @_indentLevel += 1
        @addNewLine()
        @_indentLevel -= 1
      @visitNode(node.elseBody)

  onForStatement: (node) ->
    @_sourceCode += if @minified then "for(" else "for ("
    @visitNode(node.initializer, false)
    @visitNode(node.condition)
    @addSemicolon(false)
    @visitNode(node.increment)
    @_sourceCode += ")"
    # TODO(jeremie) handle when its not a scope, it should be done in a generic
    #     way to work with if and while as well.
    @visitNode(node.body)

  onStructDefinition: (node) ->
    @_sourceCode += "struct "
    @_sourceCode += node.name
    @_indentLevel += 1
    @addLeftBrace()
    for member in node.members
      @visitNode(member)
    @_indentLevel -= 1
    @addRightBrace(false)
    @addSemicolon()

  onBinary: (node) ->

    # TODO(jeremie) we add parenthesis to ensure the operators priority.
    #     However, it would be better to do it only when it is needed.

    if node.operator.operator in ["+", "-"]
      @_sourceCode += "("
    @visitNode(node.left)
    @_sourceCode += if @minified then "" else " "
    @visitNode(node.operator)
    @_sourceCode += if @minified then "" else " "
    @visitNode(node.right)
    if node.operator.operator in ["+", "-"]
      @_sourceCode += ")"

  onUnary: (node) ->
    @visitNode(node.operator)
    @visitNode(node.expression)

  onPostfix: (node) ->
    @visitNode(node.expression)
    @visitNode(node.operator)

  onFieldSelector: (node) ->
    @_sourceCode += "."
    @_sourceCode += node.selection

  onOperator: (node) ->
    @_sourceCode += node.operator

  onIdentifier: (node) -> @_sourceCode += node.name

  onType: (node) ->
    if node.qualifier?
      @_sourceCode += node.qualifier + " "
    if node.precision?
      @_sourceCode += node.precision + " "
    @_sourceCode += node.name

  onInt: (node) -> @_sourceCode += node.value
  onBool: (node) -> @_sourceCode += node.value
  onFloat: (node) -> @_sourceCode += node.value

module.exports = FormatterVisitor
