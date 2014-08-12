
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
    @visitNode()

module.exports = PrefixerVisitor