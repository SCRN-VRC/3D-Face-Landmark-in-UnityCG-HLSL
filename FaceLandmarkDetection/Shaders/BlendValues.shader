Shader "FaceLandmarkDetection/BlendValues"
{
    Properties
    {
        _Buffer ("Blend Buffer", 2D) = "black" {}
        _isFace ("Face Flag", 2D) = "black" {}
        _FaceRotate ("Face Rotations Input", 2D) = "black" {}
        _FaceMeshTex ("Face Mesh Points", 2D) = "black" {}
        _BrowContourTex ("Brow Countors Points", 2D) = "black" {}
        _IrisTex ("Iris Points", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "ForceNoShadowCasting"="True" "IgnoreProjector"="True" }
        Lighting Off
        Fog { Mode Off }
        Blend One Zero
        ZTest Never

        Pass
        {
            Name "Blendshape Values Calculation"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCustomRenderTexture.cginc"
            #include "MLCommon.cginc"
            #include "BlendValuesInclude.cginc"

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float4> _Buffer;
            Texture2D<float3> _FaceRotate;
            Texture2D<float3> _FaceMeshTex;
            Texture2D<float3> _BrowContourTex;
            Texture2D<float3> _IrisTex;
            Texture2D<float> _isFace;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                float4 col = 0.0;

                if (px.y == 1)
                {
                    px.y -= 1;
                    // Rotations
                    float3x3 look = 0.0;
                    for (uint i = 0; i < 6; i++)
                    {
                        look[0] += _FaceRotate[uint2(0, i)];
                        look[1] += _FaceRotate[uint2(1, i)];
                        look[2] += _FaceRotate[uint2(2, i)];
                    }
                    look *= 0.1667;

                    // Face flag
                    float faceFlag = _isFace[uint2(0, 0)];

                    // Mouth spread
                    float3 mouthSp1 = _FaceMeshTex[uint2(5, 4)];
                    float3 mouthSp2 = _FaceMeshTex[uint2(1, 22)];

                    // Mouth open
                    float3 mouthOpen1 = _FaceMeshTex[uint2(0, 1)];
                    float3 mouthOpen2 = _FaceMeshTex[uint2(1, 1)];

                    // Mouth center
                    float3 mouthC = (mouthOpen1 + mouthOpen2) * 0.5;

                    // Blink Right
                    float3 blinkR1 = _BrowContourTex[uint2(4, 0)];
                    float3 blinkR2 = _BrowContourTex[uint2(4, 1)];
                    //float3 eyeRTop = _BrowContourTex[uint2(4, 3)];

                    // Blink Left
                    float3 blinkL1 = _BrowContourTex[uint2(4, 9)];
                    float3 blinkL2 = _BrowContourTex[uint2(4, 10)];
                    //float3 eyeLTop = _BrowContourTex[uint2(4, 12)];

                    // Eye Right
                    float3 eyeRIn = _BrowContourTex[uint2(7, 0)];
                    float3 eyeROut = _BrowContourTex[uint2(0, 0)];

                    // Eye Left
                    float3 eyeLIn = _BrowContourTex[uint2(7, 9)];
                    float3 eyeLOut = _BrowContourTex[uint2(0, 9)];

                    // Brow Right
                    float3 browRIn = _BrowContourTex[uint2(5, 8)];
                    float3 browROut = _BrowContourTex[uint2(0, 8)];

                    // Brow Left
                    float3 browLIn = _BrowContourTex[uint2(5, 17)];
                    float3 browLOut = _BrowContourTex[uint2(0, 17)];

                    // Iris Right
                    float3 irisR = _IrisTex[uint2(0, 0)];
                    irisR.z = (eyeRIn.z + eyeROut.z) * 0.5;

                    // Iris Left
                    float3 irisL = _IrisTex[uint2(1, 0)];
                    irisL.z = (eyeLIn.z + eyeLOut.z) * 0.5;

                    float4 mouthOpShSmFl;
                    /*
                        Mouth Open
                        Unclamped Range: (1.0, 14.0)
                        Shape: Closed, Open
                    */
                    mouthOpShSmFl.x = distance(mouthOpen1, mouthOpen2);
                    mouthOpShSmFl.x = (mouthOpShSmFl.x - 1.0) / 13.0;

                    /*
                        Mouth Spread
                        Unclamped Range: (25.0, 70.0)
                        Shape: Normal, narrow
                    */
                    mouthOpShSmFl.y = distance(mouthSp1, mouthSp2);
                    mouthOpShSmFl.y = 1.0 - ((mouthOpShSmFl.y - 25.0) / 45.0);

                    /*
                        Smile
                        Unclamped Range: (0.0, 1.6, 5.0)
                        Shape: Frown, neutral, smile
                    */
                    mouthOpShSmFl.z = mouthC.y - (mouthSp1.y + mouthSp2.y) * 0.5;
                    mouthOpShSmFl.z = mouthOpShSmFl.z <= 1.6 ?
                        (mouthOpShSmFl.z * 0.3215) : 0.5 + ((mouthOpShSmFl.z - 1.6) / 3.4) * 0.5;
                    mouthOpShSmFl.z = mouthOpShSmFl.z * 0.5 + 0.25;

                    /*
                        isFace flag
                        Range: (0.0, 1.0)
                        Not face, is face
                    */
                    mouthOpShSmFl.w = faceFlag;

                    float4 eyeBlinkLR;
                    /*
                        Blink Left
                        Unclamped Range: (5.0, 8.5)
                        Shape: Closed, open
                    */
                    eyeBlinkLR.x = distance(blinkL1, blinkL2) * 64;
                    eyeBlinkLR.x = smoothstep(0.0, 1.0, 1.0 - saturate((eyeBlinkLR.x - 5.0) / 3.5));
                    
                    /*
                        Blink Right
                        Unclamped Range: (5.0, 8.5)
                        Shape: Closed, open
                    */
                    eyeBlinkLR.y = distance(blinkR1, blinkR2) * 64;
                    eyeBlinkLR.y = smoothstep(0.0, 1.0, 1.0 - saturate((eyeBlinkLR.y - 5.0) / 3.5));
                    eyeBlinkLR.zw = 0.0;
                    
                    //buffer[0] = float4(eyeBlinkLR);

                    float4 browLRInOut;
                    /*
                        Brow Left Inside
                        Unclamped Range: (0.25, 0.32)
                        Shape: Normal, down
                    */
                    browLRInOut.x = distance(browLIn, eyeLIn);
                    browLRInOut.x = 1.0 - ((browLRInOut.x - 0.25) / 0.1);

                    /*
                        Brow Left Outside
                        Unclamped Range: (0.27, 0.30)
                        Shape: Normal, down
                    */
                    browLRInOut.y = distance(browLOut, eyeLOut);
                    browLRInOut.y = 1.0 - ((browLRInOut.y - 0.25) / 0.1);

                    /*
                        Brow Right Inside
                        Unclamped Range: (0.23, 0.30)
                        Shape: Normal, down
                    */
                    browLRInOut.z = distance(browRIn, eyeRIn);
                    browLRInOut.z = 1.0 - ((browLRInOut.z - 0.23) / 0.1);

                    /*
                        Brow Right Outside
                        Unclamped Range: (0.23, 0.30)
                        Shape: Normal, down
                    */
                    browLRInOut.w = distance(browROut, eyeROut);
                    browLRInOut.w = 1.0 - ((browLRInOut.w - 0.23) / 0.1);

                    float4 irisLRXY;

                    /*
                        Iris Left X
                        Unclamped Range: (0.1, 0.25)
                        Shape: Closer, further from inner eye position
                    */
                    irisLRXY.x = distance(eyeLIn, irisL);
                    irisLRXY.x = saturate((irisLRXY.x - 0.1) / 0.15);

                    /*
                        Iris Left Y
                        Unclamped Range: (0.07, 0.14)
                        Shape: Down, up
                    */
                    irisLRXY.y = distance(blinkL1, irisL);
                    irisLRXY.y = saturate((irisLRXY.y - 0.07) / 0.07) * 0.8 + 0.1;

                    /*
                        Iris Right X
                        Unclamped Range: (0.1, 0.25)
                        Shape: Closer, further from inner eye position
                    */
                    irisLRXY.z = distance(eyeRIn, irisR);
                    irisLRXY.z = saturate((irisLRXY.z - 0.1) / 0.15);

                    /*
                        Iris Right Y
                        Unclamped Range: (0.07, 0.14)
                        Shape: Down, up
                    */
                    irisLRXY.w = distance(blinkR1, irisR);
                    irisLRXY.w = saturate((irisLRXY.w - 0.07) / 0.07) * 0.8 + 0.1;

                    StoreValue(txBlendRot0, float4(look[0], 0.0), col, px);
                    StoreValue(txBlendRot1, float4(look[1], 0.0), col, px);
                    StoreValue(txBlendRot2, float4(look[2], 0.0), col, px);
                    StoreValue(txMouthOpShSmFl, mouthOpShSmFl, col, px);
                    StoreValue(txEyeBlinkLR, eyeBlinkLR, col, px);
                    StoreValue(txBrowLRInOut, browLRInOut, col, px);
                    StoreValue(txIrisLRXY, irisLRXY, col, px);
                }
                else if (px.y == 0)
                {
                    // Skip smoothing the rotation since it's already
                    // smoothed in another CRT
                    if (px.x < 3)
                    {
                        col = _Buffer[uint2(px.x, px.y + 1)];
                        return col;
                    }
                    // Smoothing the blend shape values
                    for (uint i = 2; i < 5; i++)
                    {
                        col += _Buffer[uint2(px.x, i)];
                    }
                    col *= 0.3333;
                }
                else
                {
                    col = _Buffer[uint2(px.x, px.y - 1)];
                }
                return col;
            }
            ENDCG
        }
    }
}
