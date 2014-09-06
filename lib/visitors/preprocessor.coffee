
BaseVisitor = require "./base"

class Preprocessor extends BaseVisitor

  @process: (node) ->
    new Preprocessor().process(node)

  process: (node) ->
    @_defines = {}
    @_source = ""
    @visitNode(node)
    data =
      source: @_source
      defines: @_defines

  onRoot: (node) ->
    @visitNodes(node.data)

  onCodeString: (node) ->
    @_source += @_applyDefines(node.data)

  onBranchDirective: (node) ->
    if @visitNode(node.condition, node.directive)
      @visitNodes(node.guarded_statements)

  onDefineDirective: (node) ->
    @_defines[node.identifier.name] = node
    regexp = "#{node.identifier.name}"
    if node.parameters?.length > 0
      regexp += "\\((.+)"
      if node.parameters.length > 1
        regexp += "(,(.+)){#{node.parameters.length - 1}}"
      regexp += "\\)"
    @_defines[node.identifier.name].regexp = new RegExp(regexp)

  onBinary: (node, directive) ->
    left = @visitNode(node.left, directive)
    right = @visitNode(node.right)
    switch node.operator
      when "&&" then  return left and right
      when "||" then  return left or  right
      when "<"  then  return left <   right
      when ">"  then  return left <   right
      when "<=" then  return left <=  right
      when ">=" then  return left >=  right
      when "==" then  return left ==  right
      else throw new Error("invalid binary operator #{node.operator}")

  onUnary: (node) ->
    switch node.operator
      when "!defined" then return @_defines[node.name] is undefined
      when "defined"  then return @_defines[node.name] isnt undefined
      else throw new Error("invalid unary operator #{node.operator}")

  onValue: (node) -> node.value

  onIdentifier: (node, directive) ->
    switch directive
      when "#ifdef"  then return @_defines[node.name] isnt undefined
      when "#ifndef" then return @_defines[node.name] is undefined
      when "#if"     then return @_defines[node.name]?.body # TODO: eval if possible
      else                return @_defines[node.name]?.body # TODO: eval if possible

  _applyDefines: (codeString) ->
    for name, node of @_defines
      codeString = codeString.replace(node.regexp, (str) ->
        return "MACRO_HERE"
      )
    codeString

module.exports = Preprocessor