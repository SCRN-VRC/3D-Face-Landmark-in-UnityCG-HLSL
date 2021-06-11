#ifndef __LANDMARK__
#define __LANDMARK__

#include "MLCommon.cginc"

// Texel locations for procustes analysis
#define txRotation0          uint2(0, 0)
#define txRotation1          uint2(1, 0)
#define txRotation2          uint2(2, 0)
#define txScaleYNorm         uint2(3, 0)
#define txXCentroid          uint2(4, 0)
#define txYCentroid          uint2(5, 0)

// The inital position of three points on face mesh
static const float3x3 fmInitPos =
{
    49.013, 36.537, 8.433,
    91.133, 74.9, 8.0,
    136.065, 37.026, 7.810
};

// Baked weight positions

static const float4 faceWeight[118] = 
{
    // X, Y, W, H
    1292, 416, 16, 27,        // Const 0
    1373, 416, 1, 16,        // Const 1
    1356, 416, 16, 16,        // Const 2
    1375, 416, 1, 16,        // Const 3
    1340, 416, 16, 16,        // Const 4
    1374, 416, 1, 16,        // Const 5
    1308, 416, 32, 16,        // Const 6
    1210, 416, 32, 32,        // Const 7
    1286, 416, 1, 32,        // Const 8
    1178, 416, 32, 32,        // Const 9
    1283, 416, 1, 32,        // Const 10
    1114, 416, 32, 32,        // Const 11
    1279, 416, 1, 32,        // Const 12
    1275, 416, 1, 32,        // Const 13
    1050, 416, 64, 32,        // Const 14
    1046, 416, 1, 64,        // Const 15
    980, 416, 64, 64,        // Const 16
    1047, 416, 1, 64,        // Const 17
    916, 416, 64, 64,        // Const 18
    1045, 416, 1, 64,        // Const 19
    788, 416, 128, 64,        // Const 20
    785, 416, 1, 128,        // Const 21
    267, 416, 128, 128,        // Const 22
    1392, 288, 1, 128,        // Const 23
    1163, 288, 128, 128,        // Const 24
    1394, 288, 1, 128,        // Const 25
    1035, 288, 128, 128,        // Const 26
    1396, 288, 1, 128,        // Const 27
    907, 288, 128, 128,        // Const 28
    1398, 288, 1, 128,        // Const 29
    779, 288, 128, 128,        // Const 30
    1400, 288, 1, 128,        // Const 31
    651, 288, 128, 128,        // Const 32
    1402, 288, 1, 128,        // Const 33
    267, 288, 128, 128,        // Const 34
    779, 416, 1, 128,        // Const 35
    395, 288, 128, 128,        // Const 36
    1146, 416, 32, 32,        // Const 37
    782, 416, 1, 128,        // Const 38
    1355, 288, 32, 128,        // Const 39
    1287, 416, 1, 32,        // Const 40
    523, 416, 128, 128,        // Const 41
    1291, 416, 1, 32,        // Const 42
    786, 416, 1, 128,        // Const 43
    523, 288, 128, 128,        // Const 44
    781, 416, 1, 128,        // Const 45
    1242, 416, 32, 32,        // Const 46
    1284, 416, 1, 32,        // Const 47
    395, 416, 128, 128,        // Const 48
    1388, 288, 1, 128,        // Const 49
    651, 416, 128, 128,        // Const 50
    1387, 288, 1, 128,        // Const 51
    1291, 288, 32, 128,        // Const 52
    1288, 416, 1, 32,        // Const 53
    1323, 288, 32, 128,        // Const 54
    1281, 416, 1, 32,        // Const 55
    1376, 416, 1, 16,        // Const 56
    1370, 468, 16, 9,        // Const 57
    1372, 416, 1, 16,        // Const 58
    1354, 468, 16, 9,        // Const 59
    1377, 416, 1, 16,        // Const 60
    1402, 454, 2, 4,        // Const 61
    1338, 468, 16, 9,        // Const 62
    1278, 416, 1, 32,        // Const 63
    1372, 441, 32, 9,        // Const 64
    1280, 416, 1, 32,        // Const 65
    1306, 468, 32, 9,        // Const 66
    1282, 416, 1, 32,        // Const 67
    1402, 450, 2, 4,        // Const 68
    1306, 459, 32, 9,        // Const 69
    1049, 416, 1, 64,        // Const 70
    1308, 432, 64, 9,        // Const 71
    1044, 416, 1, 64,        // Const 72
    1308, 441, 64, 9,        // Const 73
    1048, 416, 1, 64,        // Const 74
    1402, 458, 2, 4,        // Const 75
    1306, 450, 64, 9,        // Const 76
    787, 416, 1, 128,        // Const 77
    1172, 484, 128, 9,        // Const 78
    784, 416, 1, 128,        // Const 79
    1178, 475, 128, 9,        // Const 80
    780, 416, 1, 128,        // Const 81
    1050, 466, 128, 9,        // Const 82
    1399, 288, 1, 128,        // Const 83
    1050, 457, 128, 9,        // Const 84
    1397, 288, 1, 128,        // Const 85
    1178, 448, 128, 9,        // Const 86
    1395, 288, 1, 128,        // Const 87
    1044, 484, 128, 9,        // Const 88
    1393, 288, 1, 128,        // Const 89
    1178, 457, 128, 9,        // Const 90
    1391, 288, 1, 128,        // Const 91
    1178, 466, 128, 9,        // Const 92
    1390, 288, 1, 128,        // Const 93
    1285, 416, 1, 32,        // Const 94
    1370, 450, 32, 9,        // Const 95
    1276, 416, 1, 32,        // Const 96
    0, 0, 1404, 288,        // Const 97
    0, 576, 1404, 1,        // Const 98
    1402, 462, 1, 2,        // Const 99
    916, 480, 128, 9,        // Const 100
    1370, 459, 32, 9,        // Const 101
    0, 577, 1, 1,        // Const 102
    1338, 459, 32, 9,        // Const 103
    1050, 475, 128, 9,        // Const 104
    1274, 416, 1, 32,        // Const 105
    1050, 448, 128, 9,        // Const 106
    1389, 288, 1, 128,        // Const 107
    1277, 416, 1, 32,        // Const 108
    1401, 288, 1, 128,        // Const 109
    266, 288, 1, 266,        // Const 110
    788, 480, 128, 9,        // Const 111
    1403, 288, 1, 128,        // Const 112
    0, 288, 266, 288,        // Const 113
    1372, 432, 32, 9,        // Const 114
    1290, 416, 1, 32,        // Const 115
    1289, 416, 1, 32,        // Const 116
    783, 416, 1, 128,        // Const 117
};

// float testGen(uint3 pos)
// {
//     float r;
//     if (pos.z == 0)
//         r = (pos.x / 191.0) * (pos.y / 191.0);
//     else if (pos.z == 1)
//         r = ((191.0 - pos.x) / 191.0) * (pos.y / 191.0);
//     else
//         r = (pos.x / 191.0) * ((191.0 - pos.y) / 191.0);
//     return r;
// }

// float test(uint x, uint y, uint z)
// {
//     if (x >= 192 || y >= 192) return 0.0;
//     return testGen(uint3(x, y, z));
// }

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

// Conv2D weights getter
float getConst(Texture2D<float> tex, uint4 off, uint depth, uint ID)
{
    uint2 pos;
    pos.x = off.w;
    pos.y = off.z + off.y * depth + off.x * depth * 3;
    return tex[faceWeight[ID].xy + pos];
}

// Depth-wise Conv2D weights getter
float getConst(Texture2D<float> tex, uint3 off, uint ID)
{
    uint2 pos;
    pos.x = off.z;
    pos.y = off.y + off.x * 3;
    return tex[faceWeight[ID].xy + pos];
}

// Batch normalization weights getter
float getConst(Texture2D<float> tex, uint2 off, uint ID)
{
    return tex[faceWeight[ID].xy + off.yx];
}

// Bias/Multiplier getter
float getConst(Texture2D<float> tex, uint off, uint ID, bool flip)
{
    uint2 pos = flip ? uint2(off, 0) : uint2(0, off);
    return tex[faceWeight[ID].xy + pos];
}

#endif