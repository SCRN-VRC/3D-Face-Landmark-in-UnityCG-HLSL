#ifndef GAMES_INC
#define GAMES_INC

float Hash( sampler2D iChannel0, in float3 x )
{
    float3 p = floor(x);
    float3 f = frac(x);
    f = f*f*(3.0-2.0*f);
    
    float2 uv = (p.xy+float2(37.0,17.0)*p.z) + f.xy;
    float2 rg = tex2Dlod( iChannel0, float4((uv+ 0.5)/256.0, 0.0, -100.0) ).yx;
    return lerp( rg.x, rg.y, f.z );
}

float4 LoadValue( in Texture2D<float4> tex, in int2 re )
{
    return tex.Load(int3(re, 0));
}

void StoreValue( in int2 txPos, in float4 value, inout float4 col, in int2 fragPos )
{
    col = all(fragPos == txPos) ? value : col;
}

float3 TitleHexagon(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 7 && coord.x < 64) {
        coord.y += 42;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 YouWin(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 6 && coord.x < 42) {
        coord.y += 36;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 Score(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 28) {
        coord.y += 31;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 Ready(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 29) {
        coord.y += 26;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 Lives(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 24) {
        coord.y += 21;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 GaveOver(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 6 && coord.x < 62) {
        coord.y += 15;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 CPU(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 17) {
        coord.y += 10;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 Player(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 33) {
        coord.y += 5;
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

float3 FireToJoin(in Texture2D<float4> text, in uint2 pos, in uint2 fragCoord) {
    uint2 coord = uint2(fragCoord.x - pos.x, fragCoord.y - pos.y);
    if (coord.y < 5 && coord.x < 56) {
        return text.Load(uint3(coord, 0)).xyz;
    }
    else return 0..xxx;
}

#if SHADER_API_D3D11
// Digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
static const int font[10] = {0x75557, 0x22222, 0x74717, 0x74747, 0x11574, 0x71747, 0x71757, 0x74444, 0x75757, 0x75747};
static const uint powers[5] = {1, 10, 100, 1000, 10000};
float PrintInt( in float2 uv, in uint value, in int maxDigits )
{
    if( abs(uv.y-0.5)<0.5 )
    {
        int iu = int(floor(uv.x));
        if( iu>=0 && iu<maxDigits )
        {
            int n = (value/powers[maxDigits-iu-1]) % 10;
            uv.x = frac(uv.x);//(uv.x-float(iu)); 
            int2 p = int2(floor(uv*float2(4.0,5.0)));
            return float((font[n] >> (p.x+p.y*4)) & 1);
        }
        else return 0.0;
    } else return 0.0;
}
#else
// Digit data by P_Malin (https://www.shadertoy.com/view/4sf3RN)
static const int font[10] = {0x75557, 0x22222, 0x74717, 0x74747, 0x11574, 0x71747, 0x71757, 0x74444, 0x75757, 0x75747};
static const uint powers[5] = {1, 10, 100, 1000, 10000};
float PrintInt( in float2 uv, in uint value, in int maxDigits )
{
    if( abs(uv.y-0.5)<0.5 )
    {
        int iu = int(floor(uv.x));
        if( iu>=0 && iu<maxDigits )
        {
            uint n = (value/powers[maxDigits-iu-1]) % 10;
            uv.x = frac(uv.x);//(uv.x-float(iu)); 
            int2 p = int2(floor(uv*float2(4.0,5.0)));
            return float(round((font[n] / pow(2, p.x+p.y*5 - p.y)) % 1));
        }
        else return 0.0;
    } else return 0.0;
}
#endif

#endif