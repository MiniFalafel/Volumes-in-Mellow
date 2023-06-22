
-- vertex
#version 330 core
layout(location = 0) in vec3 aPos;

out VS_OUT{
    vec3 FragPos;
} vs_out;

uniform mat4 uProjectionMatrix;
uniform mat4 uViewMatrix;

void main() {

    vs_out.FragPos = aPos;
    gl_Position = uProjectionMatrix * uViewMatrix * vec4(vs_out.FragPos, 1.0);

}

-- fragment
#version 330 core

out vec4 FragColor;

uniform vec3 uVolumeBoxMin;
uniform vec3 uVolumeBoxMax;

uniform vec3 uCameraPos;

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

float transmittance(float density)
{
    return exp(-density); 
}

in VS_OUT{
    vec3 FragPos;
} fs_in;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    vec3 origin = uCameraPos;
    vec3 viewDir = normalize(fs_in.FragPos - uCameraPos);
    hitInfo h = boxIntersect(origin, viewDir, uVolumeBoxMin, uVolumeBoxMax);

    // split the volume into steps to sample the density at each step.
    float stepSize = (h.tmax - h.tmin) / uDensitySteps;
    vec3 p = origin + (h.tmin * viewDir);
    float totalDensity = 0.0f;
    float totalLight = 0.0f;
    for (int step = 0; step < uDensitySteps; step++)
    {
        vec3 samplePos = p + step * stepSize;
        totalDensity += DensityInBox(samplePos, uVolumeBoxMin, uVolumeBoxMax) * stepSize;

        // Sample incoming light
        vec3 lightDir = normalize(samplePos - uLightPos);
        hitInfo outRayHit = boxIntersect(samplePos, -lightDir, uVolumeBoxMin, uVolumeBoxMax);
        float subStepSize = (outRayHit.tmax - outRayHit.tmin) / uDensitySteps;
        float totalSampleDensity = 0.0f;
        for (int subSampleStep = 0; subSampleStep < uDensitySteps; subSampleStep++)
        {
            vec3 subSPoint = samplePos + step * subStepSize;
            totalSampleDensity += DensityInBox(subSPoint, uVolumeBoxMin, uVolumeBoxMax) * subStepSize;
        }
        float tmn = transmittance(totalSampleDensity);
        totalLight += tmn * transmittance(totalDensity);
    }

    float t = transmittance(totalDensity);
    if (rand(normalize(fs_in.FragPos - uCameraPos).xy) < t)
        discard;

    vec3 color = vec3(1.0, 0.0, 1.0);

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
    return uDensity; // maybe replace this with a noise sampler later on?
}