Shader "FaceLandmarkDetection/BlendValues"
{
    Properties
    {
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

            RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float3> _FaceRotate;
            Texture2D<float3> _FaceMeshTex;
            Texture2D<float3> _BrowContourTex;
            Texture2D<float3> _IrisTex;
            Texture2D<float> _isFace;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                float4 col = 0.0;

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
                float3 mouthSp1 = _FaceMeshTex[uint2(9, 4)].yxz;
                float3 mouthSp2 = _FaceMeshTex[uint2(0, 7)].yxz;

                // Mouth open
                float3 mouthOpen1 = _FaceMeshTex[uint2(0, 1)].yxz;
                float3 mouthOpen2 = _FaceMeshTex[uint2(1, 1)].yxz;

                // Mouth center
                float3 mouthC = (mouthOpen1 + mouthOpen2) * 0.5;

                // Blink Left
                float3 blinkL1 = _BrowContourTex[uint2(3, 0)].yxz;
                float3 blinkL2 = _BrowContourTex[uint2(3, 1)].yxz;

                // Blink Right
                float3 blinkR1 = _BrowContourTex[uint2(3, 9)].yxz;
                float3 blinkR2 = _BrowContourTex[uint2(3, 10)].yxz;

                // Eye Left
                float3 eyeLIn = _BrowContourTex[uint2(0, 0)].yxz;
                float3 eyeLOut = _BrowContourTex[uint2(7, 0)].yxz;

                // Eye Right
                float3 eyeRIn = _BrowContourTex[uint2(7, 9)].yxz;
                float3 eyeROut = _BrowContourTex[uint2(0, 9)].yxz;

                // Brow Left
                float3 browLIn = _BrowContourTex[uint2(0, 8)].yxz;
                float3 browLOut = _BrowContourTex[uint2(4, 8)].yxz;

                // Brow Right
                float3 browRIn = _BrowContourTex[uint2(4, 17)].yxz;
                float3 browROut = _BrowContourTex[uint2(0, 17)].yxz;

                // Iris Left
                float3 irisL = _IrisTex[uint2(0, 0)].yxz;

                // Iris Right
                float3 irisR = _IrisTex[uint2(1, 0)].yxz;

                float4 mouthOpShSmFr;
                mouthOpShSmFr.x = distance(mouthOpen1, mouthOpen2);
                mouthOpShSmFr.y = distance(mouthSp1, mouthSp2);
                mouthOpShSmFr.z = (mouthOpen1.y + mouthOpen2.y) * 0.5 - mouthC.y;
                mouthOpShSmFr.w = mouthC.y - (mouthOpen1.y + mouthOpen2.y) * 0.5;

                buffer[0] = irisL.xyzz;

                StoreValue(txBlendRot0, float4(look[0], 0.0), col, px);
                StoreValue(txBlendRot1, float4(look[1], 0.0), col, px);
                StoreValue(txBlendRot2, float4(look[2], 0.0), col, px);
                StoreValue(txMouthOpShSmFr, mouthOpShSmFr, col, px);

                return col;
            }
            ENDCG
        }
    }
}
