#ifndef __MLCOMMON__
#define __MLCOMMON__

float3 findCenteroid(float3x3 M)
{
    return float3(M[0][0] + M[1][0] + M[2][0],
        M[0][1] + M[1][1] + M[2][1],
        M[0][2] + M[1][2] + M[2][2]) / 3.0;
}

float sdCircle( float2 p, float r )
{
    return length(p) - r;
}

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

void StoreValue(in uint2 txPos, in float4 value, inout float4 col,
    in uint2 fragPos)
{
    col = all(fragPos == txPos) ? value : col;
}

#endif