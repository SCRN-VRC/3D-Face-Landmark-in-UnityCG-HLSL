#ifndef __IRIS__
#define __IRIS__

#include "MLCommon.cginc"

// Texel locations for procustes analysis
#define txIrisRotation0          uint2(0, 0)
#define txIrisRotation1          uint2(1, 0)
#define txIrisRotation2          uint2(2, 0)
#define txIrisScaleYNorm         uint2(3, 0)
#define txIrisXCentroid          uint2(4, 0)
#define txIrisYCentroid          uint2(5, 0)

// The inital position of three points in the iris tracking
static const float3x3 eyeLInit =
{
    0.226, 0.794, 0.134,
    0.771, 0.753, -0.095,
    0.621, 0.176, -0.218
};

static const float3x3 eyeRInit = 
{
    0.283, 0.835, 0.201,
    0.802, 0.723, -0.122,
    0.524, 0.168, -0.282
};

// Baked weight positions

static const float4 irisWeight[227] = 
{
    411, 597, 9, 32,       // const0
    136, 597, 1, 64,       // const1
    132, 597, 1, 64,       // const2
    927, 641, 64, 1,       // const3
    116, 597, 1, 64,       // const4
    445, 597, 1, 32,       // const5
    800, 576, 32, 64,       // const6
    1013, 576, 9, 64,       // const7
    512, 384, 512, 64,       // const8
    81, 597, 9, 64,       // const9
    671, 641, 128, 1,       // const10
    102, 597, 1, 64,       // const11
    915, 653, 64, 1,       // const12
    114, 597, 1, 64,       // const13
    118, 597, 1, 64,       // const14
    120, 597, 1, 64,       // const15
    670, 642, 128, 1,       // const16
    27, 597, 9, 64,       // const17
    63, 597, 9, 64,       // const18
    192, 213, 64, 128,       // const19
    256, 213, 64, 128,       // const20
    798, 643, 128, 1,       // const21
    140, 597, 1, 64,       // const22
    851, 653, 64, 1,       // const23
    144, 597, 1, 64,       // const24
    864, 576, 32, 64,       // const25
    963, 0, 1, 128,       // const26
    210, 597, 64, 32,       // const27
    965, 0, 1, 128,       // const28
    787, 653, 64, 1,       // const29
    448, 213, 64, 128,       // const30
    723, 653, 64, 1,       // const31
    256, 533, 128, 64,       // const32
    995, 576, 9, 64,       // const33
    138, 597, 1, 64,       // const34
    670, 640, 1, 2,       // const35
    442, 597, 1, 32,       // const36
    974, 0, 1, 128,       // const37
    134, 597, 1, 64,       // const38
    131, 597, 1, 64,       // const39
    0, 405, 512, 64,       // const40
    788, 645, 128, 1,       // const41
    986, 576, 9, 64,       // const42
    851, 652, 64, 1,       // const43
    129, 597, 1, 64,       // const44
    723, 652, 64, 1,       // const45
    126, 597, 1, 64,       // const46
    128, 213, 64, 128,       // const47
    146, 597, 64, 32,       // const48
    64, 213, 64, 128,       // const49
    659, 652, 64, 1,       // const50
    980, 0, 1, 128,       // const51
    0, 597, 9, 64,       // const52
    979, 0, 1, 128,       // const53
    0, 213, 64, 128,       // const54
    438, 597, 1, 32,       // const55
    990, 642, 32, 1,       // const56
    897, 128, 64, 128,       // const57
    833, 128, 64, 128,       // const58
    640, 512, 128, 64,       // const59
    117, 597, 1, 64,       // const60
    851, 651, 64, 1,       // const61
    976, 0, 1, 128,       // const62
    659, 651, 64, 1,       // const63
    973, 0, 1, 128,       // const64
    972, 0, 1, 128,       // const65
    769, 128, 64, 128,       // const66
    113, 597, 1, 64,       // const67
    896, 576, 27, 64,       // const68
    512, 448, 256, 64,       // const69
    970, 0, 1, 128,       // const70
    1004, 576, 9, 64,       // const71
    112, 597, 1, 64,       // const72
    109, 597, 1, 64,       // const73
    108, 597, 1, 64,       // const74
    991, 640, 32, 1,       // const75
    950, 576, 9, 64,       // const76
    959, 576, 9, 64,       // const77
    420, 597, 9, 32,       // const78
    659, 640, 1, 8,       // const79
    658, 640, 1, 15,       // const80
    104, 597, 1, 64,       // const81
    141, 597, 1, 64,       // const82
    441, 597, 1, 32,       // const83
    641, 128, 64, 128,       // const84
    9, 597, 9, 64,       // const85
    274, 597, 64, 32,       // const86
    128, 469, 128, 64,       // const87
    100, 597, 1, 64,       // const88
    962, 0, 1, 128,       // const89
    915, 649, 64, 1,       // const90
    788, 647, 128, 1,       // const91
    577, 128, 64, 128,       // const92
    439, 597, 1, 32,       // const93
    90, 597, 9, 64,       // const94
    1022, 576, 1, 64,       // const95
    916, 647, 64, 1,       // const96
    916, 646, 64, 1,       // const97
    964, 0, 1, 128,       // const98
    833, 0, 64, 128,       // const99
    787, 650, 128, 1,       // const100
    769, 0, 64, 128,       // const101
    705, 0, 64, 128,       // const102
    45, 597, 9, 64,       // const103
    106, 597, 1, 64,       // const104
    926, 642, 64, 1,       // const105
    967, 0, 1, 128,       // const106
    968, 0, 1, 128,       // const107
    110, 597, 1, 64,       // const108
    897, 0, 64, 128,       // const109
    0, 533, 128, 64,       // const110
    971, 0, 1, 128,       // const111
    512, 576, 128, 64,       // const112
    659, 650, 128, 1,       // const113
    577, 0, 64, 128,       // const114
    768, 512, 128, 64,       // const115
    977, 0, 1, 128,       // const116
    119, 597, 1, 64,       // const117
    512, 320, 512, 64,       // const118
    338, 597, 64, 32,       // const119
    991, 641, 32, 1,       // const120
    123, 597, 1, 64,       // const121
    981, 0, 1, 128,       // const122
    125, 597, 1, 64,       // const123
    926, 643, 64, 1,       // const124
    916, 644, 64, 1,       // const125
    128, 597, 1, 64,       // const126
    512, 512, 128, 64,       // const127
    440, 597, 1, 32,       // const128
    977, 576, 9, 64,       // const129
    513, 128, 64, 128,       // const130
    133, 597, 1, 64,       // const131
    787, 649, 128, 1,       // const132
    787, 648, 128, 1,       // const133
    641, 0, 64, 128,       // const134
    18, 597, 9, 64,       // const135
    640, 576, 128, 64,       // const136
    139, 597, 1, 64,       // const137
    915, 648, 64, 1,       // const138
    961, 0, 1, 128,       // const139
    788, 646, 128, 1,       // const140
    143, 597, 1, 64,       // const141
    787, 652, 64, 1,       // const142
    978, 0, 1, 128,       // const143
    101, 597, 1, 64,       // const144
    915, 652, 64, 1,       // const145
    660, 645, 128, 1,       // const146
    402, 597, 9, 32,       // const147
    384, 213, 64, 128,       // const148
    256, 469, 128, 64,       // const149
    444, 597, 1, 32,       // const150
    659, 653, 64, 1,       // const151
    975, 0, 1, 128,       // const152
    660, 644, 128, 1,       // const153
    990, 643, 32, 1,       // const154
    670, 643, 128, 1,       // const155
    798, 642, 128, 1,       // const156
    105, 597, 1, 64,       // const157
    968, 576, 9, 64,       // const158
    896, 512, 128, 64,       // const159
    659, 654, 64, 1,       // const160
    320, 213, 64, 128,       // const161
    137, 597, 1, 64,       // const162
    799, 641, 128, 1,       // const163
    896, 448, 128, 64,       // const164
    932, 576, 9, 64,       // const165
    671, 640, 128, 1,       // const166
    122, 597, 1, 64,       // const167
    969, 0, 1, 128,       // const168
    384, 533, 128, 64,       // const169
    111, 597, 1, 64,       // const170
    788, 644, 128, 1,       // const171
    145, 597, 1, 64,       // const172
    941, 576, 9, 64,       // const173
    832, 576, 32, 64,       // const174
    799, 640, 128, 1,       // const175
    915, 650, 64, 1,       // const176
    0, 0, 512, 213,       // const177
    121, 597, 1, 64,       // const178
    768, 448, 128, 64,       // const179
    103, 597, 1, 64,       // const180
    429, 597, 9, 32,       // const181
    512, 0, 1, 213,       // const182
    130, 597, 1, 64,       // const183
    36, 597, 9, 64,       // const184
    443, 597, 1, 32,       // const185
    705, 128, 64, 128,       // const186
    142, 597, 1, 64,       // const187
    723, 651, 64, 1,       // const188
    0, 341, 512, 64,       // const189
    659, 648, 128, 1,       // const190
    135, 597, 1, 64,       // const191
    916, 645, 64, 1,       // const192
    128, 533, 128, 64,       // const193
    982, 0, 1, 128,       // const194
    72, 597, 9, 64,       // const195
    927, 640, 64, 1,       // const196
    513, 0, 64, 128,       // const197
    107, 597, 1, 64,       // const198
    384, 469, 128, 64,       // const199
    915, 651, 64, 1,       // const200
    659, 649, 128, 1,       // const201
    99, 597, 1, 64,       // const202
    512, 256, 512, 64,       // const203
    1023, 576, 1, 64,       // const204
    54, 597, 9, 64,       // const205
    966, 0, 1, 128,       // const206
    115, 597, 1, 64,       // const207
    660, 647, 128, 1,       // const208
    787, 651, 64, 1,       // const209
    146, 640, 512, 15,       // const210
    923, 576, 9, 64,       // const211
    124, 597, 1, 64,       // const212
    127, 597, 1, 64,       // const213
    660, 646, 128, 1,       // const214
    768, 576, 32, 64,       // const215
    0, 469, 128, 64,       // const216
    662, 640, 1, 4,       // const217
    661, 640, 1, 4,       // const218
    660, 640, 1, 4,       // const219
    667, 640, 1, 4,       // const220
    663, 640, 1, 4,       // const221
    664, 640, 1, 4,       // const222
    665, 640, 1, 4,       // const223
    666, 640, 1, 4,       // const224
    668, 640, 1, 4,       // const225
    669, 640, 1, 4,       // const226
};

/* 
float testGen(uint3 pos)
{
    float r;
    if (pos.z == 0)
        r = (pos.x / 63.0) * (pos.y / 63.0);
    else if (pos.z == 1)
        r = ((63.0 - pos.x) / 63.0) * (pos.y / 63.0);
    else
        r = (pos.x / 63.0) * ((63.0 - pos.y) / 63.0);
    return r;
}

float test(uint x, uint y, uint z)
{
    if (x >= 64 || y >= 64) return 0.0;
    return testGen(uint3(x, y, z));
}
*/

// Same padding
float getLayerSP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    if (any(off.xy == 0) || any(off.xy > lim)) return 0.0;
    off.xy -= 1;
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    float rtn = tex[pos];
    rtn = rtn > 100000.0 ? rtn - 10000000.0 : rtn;
    return rtn;
}

// Valid padding
float getLayerVP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    if (any(off.xy >= lim)) return 0.0;
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    float rtn = tex[pos];
    rtn = rtn > 100000.0 ? rtn - 10000000.0 : rtn;
    return rtn;
}

// No padding
float getLayerNP(Texture2D<float> tex, uint3 off, uint2 lim, uint2 mult)
{
    uint2 pos;
    pos.x = off.y + (off.z % mult.x) * lim;
    pos.y = off.x + (off.z / mult.x) * lim;
    float rtn = tex[pos];
    rtn = rtn > 100000.0 ? rtn - 10000000.0 : rtn;
    return rtn;
}

// Conv2D weights getter
float getConst(Texture2D<float> tex, uint4 off, uint kernSize, uint ID)
{
    uint2 pos;
    pos.x = off.w + off.z * kernSize + off.y * kernSize * kernSize;
    pos.y = off.x;
    return tex[irisWeight[ID].xy + pos];
}

// Depth-wise Conv2D weights getter
float getConst(Texture2D<float> tex, uint3 off, uint ID)
{
    uint2 pos;
    pos.x = off.z + off.y * 3;
    pos.y = off.x;
    return tex[irisWeight[ID].xy + pos];
}

// Bias/Activation slope getter
float getConst(Texture2D<float> tex, uint2 off, uint ID)
{
    return tex[irisWeight[ID].xy + off];
}

#endif