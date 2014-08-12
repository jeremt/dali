
class GenericError extends Error

  constructor: (@message) ->
    @name = @constructor.name

module.exports = GenericError