
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;

out VS_OUT{
    vec3 FragPos;
} vs_out;

uniform mat4 uProjectionMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uModelMatrix;

void main() {

    vs_out.FragPos = vec3(uModelMatrix * vec4(aPos, 1.0));
    gl_Position = uProjectionMatrix * uViewMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

void main()
{
	FragColor = vec4(1.0, 0.0, 1.0, 1.0);
}