
GenericError = require "../utils/genericerror"

# @class VisitorError
# Handle errors related to the formatter.
#
class VisitorError extends GenericError

# @class BaseVisitor
# This class provides some utilities to manipulate ast's nodes. All your
#     visitors should be inherited from `BaseVisitor`.
#
class BaseVisitor

  # Get a formatted delegate function's name from the node.type attribute.
  #     For instance, if the node.type attribute is 'declarator_item', this
  #     function would return 'onDeclaratorItem'.
  # @param {String} nodeType the type attribute of the current node
  #
  getFunctionName: (nodeType) ->
    """on#{nodeType[0].toUpperCase()}#{
      nodeType.replace(/[-_\s]+(.)?/g, (match, c) ->
        if c then c.toUpperCase() else ""
      ).substr(1)
    }"""

  # Returns the code source generated from the given AST node. This method will
  #     automatically call the method corresponding to the type of the node.
  #     Otherwise, it will recurse on the node's children.
  # @param {Object} the AST node to serialize.
  #
  visitNode: (node, args...) ->
    if typeof node.type isnt "string"
      throw new VisitorError("invalid node type")
    funcName = @getFunctionName(node.type)
    if @[funcName]?
      @[funcName](node, args...)
    else
      throw new VisitorError("unsupported node type `#{node.type}`")

  # Visit all the nodes of the given array.
  # @param {Array<Object>} nodes an array of ast nodes
  #
  visitNodes: (nodes, args...) ->
    for node in nodes
      @visitNode(node, args...)

module.exports = BaseVisitor