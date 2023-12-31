
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;

out VS_OUT{
    vec3 FragPos;
} vs_out;

uniform mat4 uProjectionMatrix;

void main() {

    vs_out.FragPos = aPos;
    gl_Position = uProjectionMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

uniform vec3 uVolumeBoxMin;
uniform vec3 uVolumeBoxMax;

uniform vec3 uCameraPos;
uniform mat4 uViewMatrix;

uniform int uDensitySteps = 4; // default of 4
uniform float uDensity;

// lighting
uniform vec3 uLightPos;
uniform vec3 uLightColor;
uniform float uLightPower;

struct hitInfo
{
    bool hit;
    float tmin;
    float tmax;
};

hitInfo boxIntersect(vec3 rOrigin, vec3 rDir, vec3 bMin, vec3 bMax);

float DensityInBox(vec3 samplePoint, vec3 bMin, vec3 bMax);

in VS_OUT{
    vec3 FragPos;
} fs_in;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

float marchToLight(vec3 p)
{
    vec3 lightDir = normalize(uLightPos - p);
    //vec3 lightDir = normalize(vec3(1, 2, 0.3));
    hitInfo lightH = boxIntersect(p, lightDir, uVolumeBoxMin, uVolumeBoxMax);
    float lightStepSize = (lightH.tmax - lightH.tmin) / uDensitySteps;
    float densityToLight = 0.0;
    for (int s = 0; s < uDensitySteps; s++)
    {
        p += lightStepSize * lightDir;
        densityToLight += DensityInBox(p, uVolumeBoxMin, uVolumeBoxMax) * lightStepSize;
    }

    return exp(-densityToLight);
}

void main()
{
    vec3 origin = uCameraPos;
    vec3 viewDir = normalize(mat3(inverse(uViewMatrix)) * fs_in.FragPos);
    hitInfo h = boxIntersect(origin, viewDir, uVolumeBoxMin, uVolumeBoxMax);

    // split the volume into steps to sample the density at each step.
    float stepSize = (h.tmax - h.tmin) / uDensitySteps;
    vec3 p = origin + (h.tmin * viewDir);
    float transmittance = 1.0;
    float light = 0.0;

    for (int t = 0; t < uDensitySteps; t++)
    {
        p += stepSize * viewDir;
        float density = DensityInBox(p, uVolumeBoxMin, uVolumeBoxMax) * stepSize;
        if (density < 0.01)
            discard;

        // Get transmittance toward light source
        float lightTransmittance = marchToLight(p);

        light += density * transmittance * lightTransmittance;
        transmittance *= exp(-density);
    }

    if (transmittance > 0.99)
        discard;

    vec3 color = vec3(light);

	FragColor = vec4(color, 1.0);
}

hitInfo boxIntersect(vec3 rOrigin, vec3 rDir, vec3 bMin, vec3 bMax)
{
    hitInfo h;

    float tminx = (bMin.x - rOrigin.x) / rDir.x;
    float tminy = (bMin.y - rOrigin.y) / rDir.y;
    float tminz = (bMin.z - rOrigin.z) / rDir.z;

    float tmaxx = (bMax.x - rOrigin.x) / rDir.x;
    float tmaxy = (bMax.y - rOrigin.y) / rDir.y;
    float tmaxz = (bMax.z - rOrigin.z) / rDir.z;

    if (tminx > tmaxx) { tminx = tminx + tmaxx; tmaxx = tminx - tmaxx; tminx = tminx - tmaxx; }
    if (tminy > tmaxy) { tminy = tminy + tmaxy; tmaxy = tminy - tmaxy; tminy = tminy - tmaxy; }
    if (tminz > tmaxz) { tminz = tminz + tmaxz; tmaxz = tminz - tmaxz; tminz = tminz - tmaxz; }

    float tmin = max(tminx, tminy);
    float tmax = min(tmaxx, tmaxy);

    h.hit = !(tminx > tmaxy || tminy > tmaxx || tmin > tmaxz || tminz > tmax); // puke.

    h.tmin = max(max(tminz, tmin), 0.0);
    h.tmax = max(min(tmaxz, tmax), 0.0);

    return h;
}

float DensityInBox(vec3 samplePoint, vec3 bMin, vec3 bMax)
{
    vec3 center = (bMin + bMax) / 2.0;
    vec3 dimensions = bMax - bMin;

    float dist = length((samplePoint / dimensions) - center); // normalize the distance based on the dimensions

    float density = max(1 - dist, 0.0) * uDensity;

    return density; // maybe replace this with a noise sampler later on?
}