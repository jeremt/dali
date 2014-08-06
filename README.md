dali
====

Simplified shader language inspired by Python like syntax.

Examples
--------

```

extern gl: {
// indentation doesnt matter
}

extern gl:
  // it should be indent by at least 1 tab

def darken(input: vec3, value: float) -> vec3
  return input - value

def lighten(input, value)
  return input - value

# auto inline
lambda add(a, b): a + b

# explicit inline
@inline
def mul(a, b) # colon is optional if there is a new line.
  return a * b

@unfold
def sub(a, b): return a - b

import darken, lighten from color
import alpha


uniform texture: sampler2D
uniform color: vec3

varying vUv: vec2

def main():
  # for i in [0..2]:
  #   pass
  gl_FragColor = texture2D(texture, vUv).rgb
  gl_FragColor *= lighten(alpha(color, 0.5).rgb, 10) * darken(color)


```
