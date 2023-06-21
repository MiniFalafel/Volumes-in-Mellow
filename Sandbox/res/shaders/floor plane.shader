
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoords;

out VS_OUT{
    vec2 TexCoords;
    vec3 FragPos;
} vs_out;

uniform mat4 uProjectionMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;

void main() {

    vs_out.TexCoords = aTexCoords;
    vs_out.FragPos = vec3(uModelMatrix * vec4(aPos, 1.0));
    gl_Position = uProjectionMatrix * uViewMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

in VS_OUT{
    vec2 TexCoords;
    vec3 FragPos;
} fs_in;

void main() {

    FragColor = vec4(fs_in.TexCoords, 0.0, 1.0);

}