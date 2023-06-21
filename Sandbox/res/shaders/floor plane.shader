
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;
layout(location = 1) in vec2 aTexCoords;
layout(location = 2) in vec3 aNormal;

out VS_OUT{
    vec3 FragPos;
    vec2 TexCoords;
    mat3 TBN;
} vs_out;

uniform mat4 uProjectionMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;

void main() {

    vs_out.TexCoords = aTexCoords;
    vs_out.FragPos = vec3(uModelMatrix * vec4(aPos, 1.0));
    vec3 Normal = mat3(transpose(inverse(uModelMatrix))) * aNormal;
    // Tangent and BiTangent
    // crossed with some arbitratily random numbers (unlikely the normal will be the same or opposite)
    vec3 Tangent = normalize(cross(vec3(0.09345, 0.398456, 0.39458), Normal));
    vec3 BiTangent = normalize(cross(-Tangent, Normal));
    vs_out.TBN = mat3(Tangent, BiTangent, normalize(Normal));

    gl_Position = uProjectionMatrix * uViewMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

uniform sampler2D uBaseTexture;
uniform sampler2D uRoughnessTexture;
uniform sampler2D uNormalTexture;
uniform float uTextureSampleSize;

uniform vec3 uCameraPos;

// lighting
uniform vec3 uLightPos;
uniform vec3 uLightColor;
uniform float uLightPower;

in VS_OUT{
    vec3 FragPos;
    vec2 TexCoords;
    mat3 TBN;
} fs_in;

void main() {

    // Normal mapping

    // Base color
    vec2 texCoords = fs_in.TexCoords.xy * uTextureSampleSize;
    vec4 color = texture(uBaseTexture, texCoords);

    // Basic diffuse lighting
    vec3 normal = texture(uNormalTexture, texCoords).xyz;
    normal = normal * 2.0 - 1.0;
    normal = normalize(fs_in.TBN * normal);
    vec3 lightDir = normalize(fs_in.FragPos - uLightPos);
    float diffuse = max(dot(normal, -lightDir), 0.0);

    // Basic specular lighting (with suuuper scuffed math that hopefully looks kinda like it works I guess.)
    float roughness = texture(uRoughnessTexture, texCoords).r;
    vec3 viewDir = normalize(fs_in.FragPos - uCameraPos);
    vec3 reflectDir = normalize(reflect(lightDir, normal));
    float specular = pow(max(dot(viewDir, -reflectDir), 0.0), pow(256.0, 1.0 - roughness));

    // Attenuation
    float attenuation = 1.0 / pow(length(uLightPos - fs_in.FragPos), 2.0);

    // Ambient
    vec3 ambient = 0.2 * color.rgb;

    vec3 lum = vec3(diffuse + specular) * uLightPower;
    lum *= attenuation;
    lum += ambient;

    FragColor = vec4(lum * color.rgb, 1.0f);

}