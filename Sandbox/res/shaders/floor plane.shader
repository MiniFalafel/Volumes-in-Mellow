
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoords;
layout(location = 2) in vec3 aNormal;

out VS_OUT{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 Normal;
} vs_out;

uniform mat4 uProjectionMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;

void main() {

    vs_out.TexCoords = aTexCoords;
    vs_out.FragPos = vec3(uModelMatrix * vec4(aPos, 1.0));
    vs_out.Normal = mat3(transpose(inverse(uModelMatrix))) * aNormal;
    gl_Position = uProjectionMatrix * uViewMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

uniform sampler2D uBaseTexture;
uniform sampler2D uRoughnessTexture;
uniform float uTextureSampleSize;

uniform vec3 uCameraPos;

// lighting
uniform vec3 uLightPos;
uniform vec3 uLightColor;
uniform float uLightPower;

in VS_OUT{
    vec3 FragPos;
    vec2 TexCoords;
    vec3 Normal;
} fs_in;

void main() {

    // Base color
    vec4 color = texture(uBaseTexture, fs_in.TexCoords.xy * uTextureSampleSize);

    // Basic diffuse lighting
    vec3 normal = normalize(fs_in.Normal);
    vec3 lightDir = normalize(fs_in.FragPos - uLightPos);
    vec3 diffuse = color.rgb * max(dot(normal, -lightDir), 0.0);

    FragColor = vec4(diffuse, 1.0f);// vec4(fs_in.TexCoords, 0.0, 1.0);

}