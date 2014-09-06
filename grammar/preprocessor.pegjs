
// Bug I'm lazy to correct:  you write #define, #error... within a comment
// or string it's won't work.

{

  // True to add id, line and column information in nodes.
  var verbose = false;

  // This ID is incremented for each node in order to provide a UID for each
  //    node of the ast.
  var current_id = 0;

  // Creates an ast node from the given type and properties. It will also
  //    store the line and column of the source code from which the node has
  //    been added.
  // @param {String} type the type of the given ast node
  // @param {Object} props the bonus properties to add to the node
  //
  function node(type, props) {
    if (verbose) {
      this.id = current_id++;
      this.line = line();
      this.column = column();
    }
    this.type = type;
    for (var prop in props) {
      if (props.hasOwnProperty(prop))
        this[prop] = props[prop];
    }
  }

  // Generates AST nodes for a preprocessor branch.
  function branch_directive(if_directive, elif_directives, else_directive) {
    var elseList = elif_directives;
    if (else_directive) {
      elseList = elseList.concat([else_directive]);
    }
    var result = if_directive[0];
    result.guarded_statements = if_directive[1];
    var current_branch = result;
    for (var i = 0; i < elseList.length; i++) {
      current_branch.elseBody = elseList[i][0];
      current_branch.elseBody.guarded_statements =
        elseList[i][1];
      current_branch = current_branch.elseBody;
    }
    return result;
  }

  // Check whether the given node is a directive.
  function is_directive(node) {
    return node.type === "branch_directive" ||
           node.type === "define_directive";
  }

  // Create a list of `directive` and `code_string` nodes.
  function build_source(code) {
    var result = []
      , i = 0;
    while (i < code.length) {
      if (is_directive(code[i])) {
        result.push(code[i]);
        ++i;
      } else {
        var code_string = "";
        while (code[i] && !is_directive(code[i])) {
          code_string += code[i];
          ++i;
        }
        if (!/^[ \t\n]+$/.test(code_string))
          result.push({type: "code_string", data: code_string});
      }
    }
    return result;
  }

  // Helper function to daisy chain together a series of binary operations.
  function daisy_chain(head, tail) {
    var result = head;
    for (var i = 0; i < tail.length; i++) {
      result = {
        type: "binary",
        operator: tail[i][1],
        left: result,
        right: tail[i][3]
      };
    }
    return result;
  }

}

// Main
// ----------------------------------------------------------------------------

start
  = source_code:source_code {
    return {
      type: "root",
      data: source_code
    };
  }

source_code
  = code:(directive / $(!("#" _? keyword_directive) .))* {
    return build_source(code);
  }

directive
  = define_directive
  / branch_directive

// Preprocessor utils
// ----------------------------------------------------------------------------

keyword_directive
  = "endif"
  / "if"
  / "ifdef"
  / "ifndef"
  / "elif"
  / "else"
  / "define"
  / "error"

// Define
// ----------------------------------------------------------------------------

define_directive "#define"
  = "#" _? "define" _
    identifier:identifier
    parameters:define_parameters? 
    body:define_body? {
  return new node("define_directive", {
    directive: "#define",
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

define_body // everything which isnt a \n (and skip if \\n)
  = _ value:$(!(!"\\" ("\n" / eof)) .)+ ("\n" / eof) {
  return new node("code_string", {value: value});
}

// Conditions
// ----------------------------------------------------------------------------

if_directive "#if, #ifdef, #ifndef"
  = "#" _? directive:("ifdef" / "ifndef"/ "if")
     _ condition:condition '\n' {
       return new node("branch_directive", {
         directive: "#" + directive,
         condition: condition
       });
     }

elif_directive
  = "#" _? "elif" _ condition:condition '\n' {
      return new node("sub_branch", {
        directive: "#elif",
        condition: condition
      });
    }

else_directive
  = "#" _? "else" _? '\n' {
    return new node("sub_branch", {directive: "#else"});
  }

endif_directive "#endif"
  = "#" _? "endif" _? ('\n' / eof)

branch_directive
  = if_directive:(if_directive source_code)
    elif_directive:(elif_directive source_code)*
    else_directive:(else_directive source_code)?
    endif_directive {
      return branch_directive(if_directive, elif_directive, else_directive);
    }

condition
  = left:or_expr rest:(_? "&&" _? or_expr)* {
    return daisy_chain(left, rest);
  }

or_expr
  = left:base_expr rest:(_? "||" _? base_expr)* {
    return daisy_chain(left, rest);
  }

base_expr
  = defined_operator
  / binary
  / variable
  / "(" condition:condition ")" {
    return condition;
  }

binary
  = left:variable _? operator:binary_operator _? right:variable {
    return {
      type: "binary",
      operator: operator,
      left: left,
      right: right
    }
  }

binary_operator
  = "=="
  / ">="
  / "<="
  / "<"
  / ">"

defined_operator
  = not:"!"? "defined" _? "(" _? value:identifier _? ")" {
    return {
      type: "unary",
      operator: not ? "!defined" : "defined ",
      value: value
    };
  }
  / not:"!"? _? "defined" _ value:identifier {
    return {
      type: "unary",
      operator: not ? "!defined" : "defined ",
      value: value
    };
  }

variable
  = identifier
  / value

value
  = value:$[0-9]+ {
  return {
    type: "value",
    value: parseInt(value)
  }
}

// Identifier
// ----------------------------------------------------------------------------

identifier "identifier"
  = name:$([A-Za-z_][A-Za-z_0-9]*) {
    return new node("identifier", {name: name});
  }

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
