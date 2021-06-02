Shader "FaceLandmarkDetection/Iris Model"
{
    Properties
    {
        [Header(Weights)]
        _Weights ("Baked Weights", 2D) = "black" {}
        _WeightID ("Weight ID", Int) = 0
        _BiasID ("Bias ID", Int) = 0
        _MultiplierID ("Multiplier ID", Int) = 0
        [Header(Previous Layers)]
        _CamIn ("Camera Input", 2D) = "black" {}
        _Layer1 ("Layer Input 1", 2D) = "black" {}
        _Layer2 ("Layer Input 2", 2D) = "black" {}
        _Layer12WH ("[Width, Height, Width, Height]", Vector) =  (1, 1, 1, 1)
        [Header(Current Layer)]
        _WHDM ("[Width, Height, Loop Depth, Null]", Vector) = (1, 1, 0, 0)
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
            Name "Get Eyes"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            sampler2D         _CamIn;
            Texture2D<float>  _Layer1;
            Texture2D<float3> _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const float2 uv = IN.globalTexcoord.xy;

                // Swap between both eyes so only one network needed
                // for two eyes
                bool flipEye = false;

                // Right/Left coords for eye position from facemesh
                uint2 eyeNPos = flipEye ? uint2(9, 12) : uint2(27, 29);
                uint2 eyeSPos = flipEye ? uint2(6, 11) : uint2(30, 28);
                uint2 eyeEPos = flipEye ? uint2(9, 10) : uint2(9, 20);
                uint2 eyeWPos = flipEye ? uint2(21, 2) : uint2(33, 27);

                float2 eyeN = float2(_Layer1[eyeNPos], _Layer1[eyeNPos + uint2(1, 0)]);
                float2 eyeS = float2(_Layer1[eyeSPos], _Layer1[eyeSPos + uint2(1, 0)]);
                float2 eyeE = float2(_Layer1[eyeEPos], _Layer1[eyeEPos + uint2(1, 0)]);
                float2 eyeW = float2(_Layer1[eyeWPos], _Layer1[eyeWPos + uint2(1, 0)]);

                // Compute center
                float2 eyeCentroid = (eyeN + eyeS + eyeE + eyeW) * 0.25 / 192.0;
                float2 uvZoom = uv - eyeCentroid.yx;
                //uvZoom *= 0.2;
                //uvZoom += eyeCentroid.yx;

                float4 col = tex2D(_CamIn, uvZoom);
                // Flip eye
                if (all(uv.xy <= 0.01.xx))
                {
                    col = flipEye ? float4(1., 1., 1., 1.) : float4(0., 0., 0., 0.);
                }
                return col;
            }
            ENDCG
        }
    }
}
