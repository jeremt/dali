varying highp vec2 quad_coord;
varying highp vec2 tex_coord0;

uniform highp sampler2D texture0;

uniform highp float selectedHue;
uniform highp float hueTolerance;
uniform highp float selectedColorRate;

uniform bool noise;
uniform highp sampler2D texture1;
uniform highp vec2 noiseScale;

#define LUM_VECTOR vec3(0.2125, 0.7154, 0.0721)
#define BRIGHTNESS_COEFF (+12.0/255.0 + 1.0)
highp vec3 doisneauBW(highp vec3 rgb)
{
    highp float luminance = dot(rgb, LUM_VECTOR); // Desaturate
    // Curve (limit numbers of multiplication) + Brightness (multiplication by preprocessor)
    luminance = (0.067*BRIGHTNESS_COEFF) + luminance * ((0.986*BRIGHTNESS_COEFF) + luminance * ((-2.268*BRIGHTNESS_COEFF) + luminance * ((4.881*BRIGHTNESS_COEFF) + luminance * (-2.666*BRIGHTNESS_COEFF))));
    return vec3(luminance);
}

highp vec4 change_color(highp vec4 color)
{
    highp vec3 rgb = color.rgb;
    highp vec3 bw = doisneauBW(rgb);
    highp vec3 hsl = RGBToHSL(rgb);
    highp float d = hueDistance(hsl.x, selectedHue);
    highp float amount = smoothstep(hueTolerance, 0.0, d);
    // it's necessary to filter s<0.1 and l<0.1 and l>0.9 (i.e. -l<-0.9);
    highp vec3 filterDesaturated = linearstep(vec3(0.1, 0.1, 0.9), vec3(0.2, 0.2, 0.8), vec3(hsl.y, hsl.z, hsl.z));
    amount *= filterDesaturated.x * filterDesaturated.y * filterDesaturated.z;
    color.rgb = mix(bw, rgb, amount * selectedColorRate);

    if (noise)
    {
        highp vec3 noise_texture = texture2D(texture1, quad_coord * noiseScale).rgb;
        highp float noise_amount = linearstep(0.95, 0.70, bw.x);
        color.rgb *= mix(vec3(1.0), noise_texture, noise_amount);
    }

    return color;
}

void main()
{
    gl_FragColor = texture2D(texture0, tex_coord0);
    gl_FragColor = change_color(gl_FragColor);
}