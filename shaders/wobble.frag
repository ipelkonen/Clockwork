#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    float frequency;
    float amplitude;
};

layout(binding = 1) uniform sampler2D src;

void main()
{
    highp vec2 p = sin(time + frequency * qt_TexCoord0);
    fragColor = texture(src, qt_TexCoord0 + amplitude * vec2(p.y, -p.x)) * qt_Opacity;
}
