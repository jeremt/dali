
# @class Printer
# Print nice formatted message by display the line number, the column and a
# source code overview of the message's context.
#
class Printer

  min = (a, b) -> if a > b then b else a
  max = (a, b) -> if a > b then a else b

  # @static
  # The function to print the message.
  # @param {String} label the label written before the message
  # @param {Error} error a class inherited from error
  # @param {String} source the source code related to the message
  # @param {Boolean} oneline display message without the context
  # @param {Number} before the number of lines to display before the error
  # @param {Number} after the number of lines to display after the error
  # @param {Function} print the function to use to print the message
  #
  @printMessage: (label, error, source, {oneline, before, after, print} = {}) ->
    before ?= 2
    after ?= 2
    oneline ?= false
    print ?= console.log
    source = source.split('\n')
    print "#{label}: #{error.line}(#{error.column}): #{error.message}"
    unless oneline
      current = error.line - 1
      firstLine = max(current - before, 0)
      lastLine = min(current + after, source.length - 1)
      for line in [firstLine..lastLine]
        cursor = if line is current then '>' else ' '
        spaces = ""
        n = lastLine.toString(10).length - (line + 1).toString(10).length + 1
        spaces += " " for i in [0..n]
        print "#{cursor} #{line + 1}#{spaces}| #{source[line]}"

  @printError: -> @printMessage.call(@, 'Error', arguments...)
  @printWarning: -> @printMessage.call(@, 'Warning', arguments...)

module.exports = Printer