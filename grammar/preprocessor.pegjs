
{

  // This ID is incremented for each node in order to provide a UID for each
  //    node of the ast.
  var current_id = 0;

  // Creates an ast node from the given type and properties. It will also
  //    store the line and column of the source code from which the node has
  //    been added.
  // @param {String} type the type of the given ast node
  // @param {Object} props the bonus properties to add to the node
  //
  function Node(type, props) {
    this.type = type;
    // this.id = current_id++;
    // this.line = line();
    // this.column = column();
    for (var prop in props) {
      if (props.hasOwnProperty(prop))
        this[prop] = props[prop];
    }
  }

  // Generates AST Nodes for a preprocessor branch.
  function preprocessor_branch(if_directive, elif_directives, else_directive) {
    var elseList = elif_directives;
    if (else_directive) {
      elseList = elseList.concat([else_directive]);
    }
    var result = if_directive[0];
    result.guarded_statements = if_directive[1].statements;
    var current_branch = result;
    for (var i = 0; i < elseList.length; i++) {
      current_branch.elseBody = elseList[i][0];
      current_branch.elseBody.guarded_statements =
        elseList[i][1].statements;
      current_branch = current_branch.elseBody;
    }
    return result;
  }

}

// Main
// ----------------------------------------------------------------------------

start
  = statement*

statement
  = __? statement:preprocessor_directive __? { return statement; }

preprocessor_directive
  = preprocessor_define
  / preprocessor_branch

// Define
// ----------------------------------------------------------------------------

preprocessor_define "#define"
  = directive:$("#" _? "define") _
    identifier:identifier
    parameters:define_parameters? 
    body:define_body? {
  return new Node("preprocessor_define", {
    directive: directive,
    identifier: identifier,
    parameters: parameters,
    body: body
  });
}

define_parameters =
  // No space is allowed between a macro's identifier and its opening
  // paren
  "(" _? first:(identifier)?
  rest:(_? "," _? value:identifier { return value; })* _? ")" {
    if (!first)
      return [];
    return [first].concat(rest);
  }

define_body
  = _ value:$((!(!"\\" "\n") .)+) "\n" {
  return new Node("code_string", {value: value});
}

// Conditions
// ----------------------------------------------------------------------------

preprocessor_if
  = "#" _? directive:("ifdef" / "ifndef"/ "if")
     _ value:$([^\n]+) '\n' {
       return new Node("preprocessor_sub_branch", {
         directive: "#" + directive,
         value: value
       });
     }

preprocessor_else_if
  = "#" _? "elif" _ value:$([^\n]*) _? '\n' {
      return new Node("preprocessor_sub_branch", {
        directive: "#elif",
        value: value
      });
    }

preprocessor_else
  = "#" _? "else" _? '\n' {
    return new Node("preprocessor_sub_branch", {directive: "#else"});
  }

preprocessor_end
  = "#" _? "endif" _? '\n'

preprocessor_branch
  = if_directive:(preprocessor_if source_code)
    elif_directive:(preprocessor_else_if source_code)*
    else_directive:(preprocessor_else source_code)?
    preprocessor_end {
      return preprocessor_branch(if_directive, elif_directive, else_directive);
    }

// Source code (everything but preprocessor declaration)
// ----------------------------------------------------------------------------

source_code
  = /* TODO */

// Identifier
// ----------------------------------------------------------------------------

identifier "identifier"
  = !(keyword) name:$([A-Za-z_][A-Za-z_0-9]*) {
     return new Node("identifier", {name: name});
  }

keyword "keyword"
  = "attribute" / "const" / "bool" / "float" / "int"
  / "break" / "continue" / "do" / "else" / "for" / "if"
  / "discard" / "return" / vector / matrix
  / "in" / "out" / "inout" / "uniform" / "varying"
  / "sampler2D" / "samplerCube" / "struct" / "void"
  / "while" / "highp" / "mediump" / "lowp" / "true" / "false"

vector = name:$([bi]? "vec" [234])
matrix = name:$("mat" [234])

// Whitespaces
// ----------------------------------------------------------------------------

eof "eof"
  = !.

comment "comment"
  = $("/*" (!"*/" .)* "*/")
  / $("//" [^\n]* ("\n" / eof))

__ "newline"
  = ([\n\t ] / comment)+

_ "space"
  = ([\t ] / comment)+
