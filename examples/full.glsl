
#ifdef GL_ES
#define highp
#define mediump
#define lowp
#endif

#define UP vec3(0, 1, 0)
#define MAX(a, b) (a > b ? a : b)

#define MIN(a, b) \
  a < b ? a : b

uniform highp sampler2D texture;
uniform mediump vec4 color;
varying vec4 vColor;
varying vec2 vUv;

const float a = 0.2;

struct Light {
  vec3 position;
  float intensity;
};

vec3 darken(vec3 color, float rate ) {
  return color + rate;
}

void main() {
  vec3 px = texture2D(texture, vUv).rgb;
  float truc;
  color *= 2;
  if (vColor == vec4(0, 0, 0, 1))
    gl_FragColor = vec4(0.5);
  else if (true)
    gl_FragColor = vec4(0.3);
  else if (vColor == vec4(0.2)) {
    gl_FragColor = vec4(0.4);
  }
  else
    gl_FragColor = vec4(0.2);
  for (int i = 0; i < 4; ++i) {
    gl_FragColor.a *= i / vec2(10.0).x;
  }
  gl_FragColor = color * (vec4(1, 0, 0, 1) - 1) / 2;
}

// uniform color: vec4
// varying vColor: vec4

// struct Light:
//   position: vec3
//   intensity: float

// # typed
// def darken(color: vec3, rate: float): -> vec3
//   return color + rate

// # inferred
// def darken(color, rate):
//   return color + rate

// def main():
//   if vColor == vec4(0, 0, 0, 1):
//     gl_FragColor = vec4(0.5)
//   elif true:
//     gl_FragColor = vec4(0.3)
//   elif vColor == vec4(0.2):
//     gl_FragColor = vec4(0.4)
//   else:
//     gl_FragColor = vec4(0.2)
//   for i in [0..4]:
//     gl_FragColor.a *= i / vec2(10.0).x
//   gl_FragColor = color * (vec4(1, 0, 0, 1) - 1) / 2
