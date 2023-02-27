#version 440
layout(location = 0) in vec2 qt_TexCoord0; // Texture position input
layout(location = 0) out vec4 fragColor; // Fragment color output

// Input buffer - the two first elements are always the same!
// The rest are defined by the ShaderEffect element in the QML
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity; // Opacity of the fragment
    float time; // Time component to animate the wobble effect
    float frequency; // Wobble frequency
    float amplitude; // Wobble amplitude
};

// Source texture
layout(binding = 1) uniform sampler2D src;

void main()
{
    // Wobble effect
    highp vec2 p = sin(time + frequency * qt_TexCoord0);
    fragColor = texture(src, qt_TexCoord0 + amplitude * vec2(p.y, -p.x)) * qt_Opacity;
}
