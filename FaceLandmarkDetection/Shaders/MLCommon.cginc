#ifndef __MLCOMMON__
#define __MLCOMMON__

float2x2 rot2(float rot)
{
    float sinRot;
    float cosRot;
    sincos(rot, sinRot, cosRot);
    return float2x2(cosRot, -sinRot, sinRot, cosRot);
}

float PRelu(float x, float s)
{
    return x >= 0.0 ? x : x * s;
}

float relu(float x)
{
    return max(0.0, x);
}

float sigmoid(float x)
{
    return 1.0 / (1.0 + exp(-x));
}

float max4(float a, float b, float c, float d)
{
    return max(a, max(b, max(c, d)));
}

float getCameraVP(sampler2D tex, uint3 off, uint2 lim)
{
    if (any(off.xy >= lim)) return 0.0;
    return tex2D(tex, float2(off.xy / (lim - 1.0)))[off.z];
}

// Same padding
float getLayerSP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    if (any(off.xy == 0) || any(off.xy > lim)) return 0.0;
    off.xy -= 1;
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    return tex[pos];
}

// Valid padding
float getLayerVP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    if (any(off.xy >= lim)) return 0.0;
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    return tex[pos];
}

// No padding
float getLayerNP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    return tex[pos];
}

#endif