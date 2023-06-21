
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

float getSpecularFromRoughness(float r, float maxSpec)
{
    return pow(256.0, 1.0 - r);
    //return maxSpec - (maxSpec * r); // just interpolate I guess
}

void main() {

    // Base color
    vec2 texCoords = fs_in.TexCoords.xy * uTextureSampleSize;
    vec4 color = texture(uBaseTexture, texCoords);

    // Basic diffuse lighting
    vec3 normal = normalize(fs_in.Normal);
    vec3 lightDir = normalize(fs_in.FragPos - uLightPos);
    float diffuse = max(dot(normal, -lightDir), 0.0);

    // Basic specular lighting (with suuuper scuffed math that hopefully looks kinda like it works I guess.)
    float roughness = texture(uRoughnessTexture, texCoords).r;
    vec3 viewDir = normalize(fs_in.FragPos - uCameraPos);
    vec3 reflectDir = normalize(reflect(lightDir, normal));
    float specular = pow(max(dot(viewDir, -reflectDir), 0.0), pow(256.0, 1.0 - roughness));

    // Attenuation
    float attenuation = 1.0 / pow(length(uLightPos - fs_in.FragPos), 2.0);

    vec3 lum = uLightColor * (diffuse + specular) * uLightPower * attenuation;

    FragColor = vec4(lum * color.rgb, 1.0f);// vec4(fs_in.TexCoords, 0.0, 1.0);

}