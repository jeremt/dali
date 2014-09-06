
Parser
------

- Combine main by multiply gl_FragColor of each ones together

Preprocessor
------------

- Parse directives' conditions
- Add instructions #error, #import, #enable and #disable
- handle ! as an operator and ()
- handle other values than just integers
- replace define in source code (in Preprocessor visitor)