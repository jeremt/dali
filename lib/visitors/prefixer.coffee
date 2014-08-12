
BaseVisitor = require "./base"

# This visitor add a prefix to global declaration of a shader in order to
#     avoid conflicts.
#
class PrefixerVisitor extends BaseVisitor

  # Apply the given prefix to the given ast node recursively.
  # @param {Object} node the root ast node
  # @param {String} prefix the prefix to apply
  #
  applyPrefix: (node, @prefix) ->

    # TODO(jeremie) Add generic feature in BaseVisitor to recurse on all nodes.
    # TODO(jeremie) recurse through all nodes and add prefix to variables registered in globals

    # Store the name of every nodes that should be prefixed to avoid collisions
    #     with other modules.
    @_globalNames = []

    # Store the names of the current scope, to know which global's names have
    #     been overwritten.
    @_localNames = []

    @visitNode(node)

  # Add a prefix to the node's name if it's a global and there is no local
  #     one with the same name.
  maybePrefix: (node) ->
    if node.name in @_globalNames and not (node.name in @_localNames)
      node.name = @prefix + node.name

  onRoot: (node) ->
    for statement in node.statements
      @visitNode(statement, true)

  onDeclarator: (node, isGlobal) ->
    @visitNodes(node.declarators, isGlobal)

  onDeclaratorItem: (node, isGlobal) ->
    if isGlobal
      @_globalNames.push(node.name.name)
    else
      @_localNames.push(node.name.name)
    @visitNode(node.name)

  onFunctionDeclaration: (node) ->
    @_globalNames.push(node.name)
    node.name = @prefix + node.name

    # Reset local names for the function's scope.
    @_localNames = []
    @visitNodes(node.parameters)
    @visitNode(node.body)

  onParameter: (node) ->
    @_localNames.push(node.name)

  onScope: (node) ->
    @visitNodes(node.statements)

  onStructDefinition: (node) ->
    @_globalNames.push(node.name)
    node.name = @prefix + node.name

  onIfStatement: (node) ->
    @visitNode(node.condition)
    @visitNode(node.body)
    if node.elseBody?
      @visitNode(node.elseBody)

  onForStatement: (node) ->
    @visitNode(node.initializer)
    @visitNode(node.condition)
    @visitNode(node.increment)
    @visitNode(node.body)

  onFunctionCall: (node) ->
    @visitNodes(node.parameters)

  onExpression: (node) ->
    @visitNode(node.expression)

  onReturn: (node) ->
    @visitNode(node.value)

  onBinary: (node) ->
    @visitNode(node.left)
    @visitNode(node.right)

  onUnary: (node) ->
    @visitNode(node.expression)

  onIdentifier: (node) ->
    @maybePrefix(node)

  onPreprocessor: (node) ->
  onPostfix: (node) ->
  onInt: (node) ->
  onFloat: (node) ->
  onBool: (node) ->

module.exports = PrefixerVisitor