#ifndef __MLCOMMON__
#define __MLCOMMON__

float2x2 rot2(float rot)
{
    float sinRot;
    float cosRot;
    sincos(rot, sinRot, cosRot);
    return float2x2(cosRot, -sinRot, sinRot, cosRot);
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

#endif