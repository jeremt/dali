dali
====

Simplified shader language inspired by Python like syntax.

The language will be written by iteration from the original GLSL language syntax.

Features that will be added (more or less in this order):

- Shader combinaison
- Import
- Change syntax to be more "python-like"
- Inference and default values
- Compiler instruction (@unfold, @inline, @enable(GL_ALPHA_TEST)...)
- Debug (something like print_at_pixel 4, 4, my_vec3)

Possible syntaxes examples
--------------------------

Just a little improvement of the C syntax:

```dali

#import filters
#import colortools : hsl_to_rgb, rgb_to_hsl

#ifdef GL_ES
#define mediump
#endif

// Valid GLSL
vec3 darken(vec3 input, float value) {
  return input - value
}

// Type inference
lighten(input, value) {
  return input - value
}

// auto inline
add(a, b) => a + b

// explicit inline
inline mul(a, b) {
  return a * b
}

unfold sub(a, b) { return a - b }

#import color : darken, lighten
#import alpha

uniform sampler2D texture
uniform color = vec3(1.0, 1.0, 1.0) // type infered

varying vec2 vUv

#enable GL_ALPHA_TEST
#disable GL_DEPTH_TEST

main() {
  for i in [0..2] {
    // do something...
  }
  if i == 0 {
    color = vec3(0)
  }
  color = rgb_to_hsl(hsl_to_rgb(vec3(0.1, 0.2, 0.3)))
  color = filters.bw(color)
  gl_FragColor = texture2D(texture, vUv).rgb
  gl_FragColor *= lighten(alpha(color, 0.5).rgb, 10) * darken(color)
}

```

Or, (only possible if we add a context to pegjs grammar)

```python

import filters
import colortools : hsl_to_rgb, rgb_to_hsl

glsl: {
// indentation doesnt matter
#ifdef GL_ES
#define mediump
#endif
}

glsl:
  // it should be indent by 1 tab
  #ifdef GL_ES
  #define mediump
  #endif

def darken(input: vec3, value: float): -> vec3
  return input - value

def lighten(input, value):
  return input - value

# auto inline
lambda add(a, b): a + b

# explicit inline
@inline
def mul(a, b): # colon is optional if there is a new line.
  return a * b

@unfold
def sub(a, b): return a - b

import color : darken, lighten
import alpha

uniform texture: sampler2D
uniform color: vec3 = vec3(1.0, 1.0, 1.0)

varying vUv: vec2

@enable(GL_ALPHA_TEST)
@disable(GL_DEPTH_TEST)
def main():
  # for i in [0..2]:
  #   pass
  color = rgb_to_hsl(hsl_to_rgb(vec3(0.1, 0.2, 0.3)))
  color = filters.bw(color)
  gl_FragColor = texture2D(texture, vUv).rgb
  gl_FragColor *= lighten(alpha(color, 0.5).rgb, 10) * darken(color)


```
