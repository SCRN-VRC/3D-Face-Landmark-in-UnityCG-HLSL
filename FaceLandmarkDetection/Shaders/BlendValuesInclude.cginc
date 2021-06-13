#ifndef __BLENDVALUES__
#define __BLENDVALUES__

#define txBlendRot0                       uint2(0, 0)
#define txBlendRot1                       uint2(1, 0)
#define txBlendRot2                       uint2(2, 0)
#define txMouthOpShSmFl                   uint2(3, 0)
#define txEyeBlinkLR                      uint2(4, 0)
#define txBrowLRInOut                     uint2(5, 0)
#define txIrisLRXY                        uint2(6, 0)

#define txBakedBlinkRight                 uint2(0, 0)
#define txBakedBlinkLeft                  uint2(128, 0)
#define txBakedBrowRightIn                uint2(256, 0)
#define txBakedBrowRightOut               uint2(384, 0)
#define txBakedBrowLeftIn                 uint2(512, 0)
#define txBakedBrowLeftOut                uint2(0, 128)
#define txBakedIrisRightIn                uint2(128, 128)
#define txBakedIrisRightOut               uint2(256, 128)
#define txBakedIrisRightUp                uint2(384, 128)
#define txBakedIrisRightDown              uint2(512, 128)
#define txBakedIrisLeftIn                 uint2(0, 256)
#define txBakedIrisLeftOut                uint2(128, 256)
#define txBakedIrisLeftUp                 uint2(256, 256)
#define txBakedIrisLeftDown               uint2(384, 256)
#define txBakedMouthOpen                  uint2(512, 256)
#define txBakedMouthShrink                uint2(0, 384)
#define txBakedMouthSmile                 uint2(128, 384)
#define txBakedMouthFrown                 uint2(256, 384)

float3 tanSpaceOffset(float3 bakedPos, float blendVal, float3 normal, float3 tangent, float3 binormal)
{
    return ((bakedPos.x * normal) + (bakedPos.y * tangent) + (bakedPos.z * binormal)) * blendVal;
}

#endif