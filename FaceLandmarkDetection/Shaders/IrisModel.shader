Shader "FaceLandmarkDetection/Iris Model"
{
    Properties
    {
        [Header(Weights)]
        _Weights ("Baked Weights", 2D) = "black" {}
        _KernelSize ("Kernel Size", Int) = 3
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
                bool flipEye = _Layer2[uint2(0, 0)].x < 0.5;

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
                uvZoom *= 0.225;
                uvZoom += eyeCentroid.yx + eyeCentroid.yx * 0.1125 - float2(0.09, 0.05625);

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

        Pass
        {
            Name "Camera Input"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            sampler2D        _CamIn;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _KernelSize;
            uint             _WeightID;
            uint             _BiasID;
            uint             _MultiplierID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                
                const uint widthMult = floor(_CustomRenderTextureWidth / _WHDM.x);
                
                const uint i = px.y % _WHDM.y;
                const uint j = px.x % _WHDM.x;
                const uint k = (px.x / _WHDM.x) + (px.y / _WHDM.y) * widthMult;

                float cl = 0.0f;
                const uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // kernel
                [unroll(3)]
                for (uint l = 0; l < _WHDM.z; l++) {
                    cl +=
                        getCameraVP(_CamIn, uint3(i0, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 0, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 1, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 2, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 0, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 1, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 2, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 0, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 1, l, k), _WHDM.z, _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 2, l, k), _WHDM.z, _KernelSize, _WeightID);
                }
                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));
                
                //if (i == 12 && j == 2 && k == 63)
                //buffer[0] = getConst(_Weights, uint4(0, 0, 0, 0), _WHDM.z, _KernelSize, _WeightID);
                buffer[0] = float4(_WHDM.z, _KernelSize, _WeightID, 0);

                return cl;
            }
            ENDCG
        }
    }
}
