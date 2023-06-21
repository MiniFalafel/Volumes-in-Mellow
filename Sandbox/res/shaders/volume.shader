
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

uniform vec3 uVolumeBoxMin;
uniform vec3 uVolumeBoxMax;
uniform mat4 uInverseModelMatrix;

uniform vec3 uCameraPos;

uniform int uDensitySteps = 4; // default of 4
uniform float uDensity;

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

void main()
{
    vec3 origin = vec3(uInverseModelMatrix * vec4(uCameraPos, 1.0));
    vec3 viewDir = normalize(fs_in.FragPos - uCameraPos);
    viewDir = normalize(mat3(uInverseModelMatrix) * viewDir); // mat3 to remove the translation (because we were applying it twice).
    hitInfo h = boxIntersect(origin, viewDir, uVolumeBoxMin, uVolumeBoxMax);

    // split the volume into steps to sample the density at each step.
    float stepSize = (h.tmax - h.tmin) / uDensitySteps;
    vec3 p = origin + (h.tmin * viewDir);
    float totalDensity = 0.0f;
    for (int step = 0; step < uDensitySteps; step++)
    {
        totalDensity += DensityInBox(p + step * stepSize, uVolumeBoxMin, uVolumeBoxMax) * stepSize;
    }

    vec3 color = vec3(totalDensity);

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

    h.tmin = max(tminz, tmin);
    h.tmax = min(tmaxz, tmax);

    return h;
}

float DensityInBox(vec3 samplePoint, vec3 bMin, vec3 bMax)
{
    return uDensity;
}