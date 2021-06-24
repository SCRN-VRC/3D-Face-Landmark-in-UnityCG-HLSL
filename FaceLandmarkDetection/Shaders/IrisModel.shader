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

            //RWStructuredBuffer<float4> buffer : register(u1);
            sampler2D         _CamIn;
            Texture2D<float>  _Layer1;
            Texture2D<float3> _Layer2;
            Texture2D<float3> _Weights; // Use this texture for the face rotations

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const float2 uv = IN.globalTexcoord.xy;

                // Swap between both eyes so only one network needed
                // for two eyes
                bool flipEye = abs(_Layer2[uint2(0, 0)] - 0.1337) < 0.001;

                // Right/Left coords for eye position from facemesh
                uint2 eyeNPos = flipEye ? uint2(9, 12) : uint2(27, 29);
                uint2 eyeSPos = flipEye ? uint2(6, 11) : uint2(30, 28);
                uint2 eyeEPos = flipEye ? uint2(9, 10) : uint2(9, 20);
                uint2 eyeWPos = flipEye ? uint2(21, 2) : uint2(33, 27);

                float2 eyeN = float2(_Layer1[eyeNPos], _Layer1[eyeNPos + uint2(1, 0)]);
                float2 eyeS = float2(_Layer1[eyeSPos], _Layer1[eyeSPos + uint2(1, 0)]);
                float2 eyeE = float2(_Layer1[eyeEPos], _Layer1[eyeEPos + uint2(1, 0)]);
                float2 eyeW = float2(_Layer1[eyeWPos], _Layer1[eyeWPos + uint2(1, 0)]);

                // Undo rotation
                float3x3 look = 0.0;

                for (uint i = 0; i < 6; i++)
                {
                    look[0] += _Weights[uint2(0, i)];
                    look[1] += _Weights[uint2(1, i)];
                    look[2] += _Weights[uint2(2, i)];
                }
                look *= 0.1667;

                // float angX = atan2(look[2][1], look[2][2]);
                float angY = atan2(-look[2][0],
                     sqrt(look[2][1] * look[2][1] + look[2][2] * look[2][2]));
                float angZ = atan2(look[1][0], look[0][0]);

                //buffer[0] = float4(dot(_Layer2[uint2(0, 0)], 0.3333.xxx).xxxx);

                // Compute center
                float2 eyeCentroid = (eyeN + eyeS + eyeE + eyeW) * 0.25 / 192.0;
                float2 uvZoom = uv - eyeCentroid.yx;
                uvZoom *= 0.3;
                uvZoom = mul(rot2(angZ), uvZoom);
                uvZoom += eyeCentroid.yx + eyeCentroid.yx * 0.15 - float2(0.12, 0.07);

                float4 col = tex2D(_CamIn, uvZoom);
                // Flip eye
                if (all(uv.xy <= 0.01.xx))
                {
                    col = flipEye ? 1..xxxx : 0.1337.xxxx;
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

            //RWStructuredBuffer<float4> buffer : register(u1);
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

                float cl = 0.0;
                const uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;
                // 3x3 kernel
                [unroll(3)]
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl +=
                        getCameraVP(_CamIn, uint3(i0, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 0, 0), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 0, 1), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 0, 2), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 1, 0), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 1, 1), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 1, 2), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 2, 0), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 2, 1), _KernelSize, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(k, l, 2, 2), _KernelSize, _WeightID);

                        // test(i0, j0, l) * getConst(_Weights, uint4(k, l, 0, 0), _KernelSize, _WeightID) +
                        // test(i0, j1, l) * getConst(_Weights, uint4(k, l, 0, 1), _KernelSize, _WeightID) +
                        // test(i0, j2, l) * getConst(_Weights, uint4(k, l, 0, 2), _KernelSize, _WeightID) +
                        // test(i1, j0, l) * getConst(_Weights, uint4(k, l, 1, 0), _KernelSize, _WeightID) +
                        // test(i1, j1, l) * getConst(_Weights, uint4(k, l, 1, 1), _KernelSize, _WeightID) +
                        // test(i1, j2, l) * getConst(_Weights, uint4(k, l, 1, 2), _KernelSize, _WeightID) +
                        // test(i2, j0, l) * getConst(_Weights, uint4(k, l, 2, 0), _KernelSize, _WeightID) +
                        // test(i2, j1, l) * getConst(_Weights, uint4(k, l, 2, 1), _KernelSize, _WeightID) +
                        // test(i2, j2, l) * getConst(_Weights, uint4(k, l, 2, 2), _KernelSize, _WeightID);
                }

                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));
                
                //if (i == 12 && j == 2 && k == 63)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += tex2D(_CamIn, float2(0, 0)).x < 0.5 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "conv2D1x1Stride1"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
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

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                float cl = 0.0;

                // 1x1 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }

                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));
                
                //if (i == 1 && j == 0 && k == 62)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "depthConv2D3x3"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _KernelSize;
            uint             _WeightID;
            uint             _BiasID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                
                const uint widthMult = floor(_CustomRenderTextureWidth / _WHDM.x);
                
                const uint i = px.y % _WHDM.y;
                const uint j = px.x % _WHDM.x;
                const uint k = (px.x / _WHDM.x) + (px.y / _WHDM.y) * widthMult;

                const uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                // 3x3 kernel
                float cl =
                    getLayerSP(_Layer1, uint3(i0, j0, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 0, 0), _WeightID) +
                    getLayerSP(_Layer1, uint3(i0, j1, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 0, 1), _WeightID) +
                    getLayerSP(_Layer1, uint3(i0, j2, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 0, 2), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j0, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 1, 0), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j1, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 1, 1), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j2, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 1, 2), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j0, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 2, 0), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j1, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 2, 1), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j2, k), _Layer12WH.xy, mult1) * getConst(_Weights, uint3(k, 2, 2), _WeightID);
                
                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);
                
                //if (i == 15 && j == 14 && k == 55)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "conv2D1x1Stride1Add"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            Texture2D<float> _Layer2;
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

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                uint2 PLD2;
                _Layer2.GetDimensions(PLD2.x, PLD2.y);
                const uint2 mult2 = PLD2 / _Layer12WH.zw;

                float cl = 0.0;

                // 1x1 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }

                // bias + skip in
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID) +
                    getLayerNP(_Layer2, uint3(i, j, k), _Layer12WH.zw, mult2);

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));

                //if (i == 7 && j == 6 && k == 127)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "conv2D2x2Stride2"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
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

                const uint i0 = i * 2, i1 = i0 + 1;
                const uint j0 = j * 2, j1 = j0 + 1;

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                float cl = 0.0;

                // 2x2 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl +=
                        getLayerNP(_Layer1, uint3(i0, j0, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 0, 0), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(i0, j1, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 0, 1), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j0, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 1, 0), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j1, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 1, 1), _KernelSize, _WeightID);
                }
                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));

                //if (i == 1 && j == 0 && k == 62)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "maxPool2x2Stride2Padded"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            Texture2D<float> _Layer2;
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

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                uint2 PLD2;
                _Layer2.GetDimensions(PLD2.x, PLD2.y);
                const uint2 mult2 = PLD2 / _Layer12WH.zw;

                float cl = 0.0;

                // 1x1 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }

                // max pool
                const uint i0 = i * 2, i1 = i0 + 1;
                const uint j0 = j * 2, j1 = j0 + 1;

                // pad extra layers with 0
                float mp = 0.0;
                if (k < _WHDM.z)
                {
                    mp = max4(getLayerNP(_Layer2, uint3(i0, j0, k), _Layer12WH.zw, mult2),
                        getLayerNP(_Layer2, uint3(i0, j1, k), _Layer12WH.zw, mult2),
                        getLayerNP(_Layer2, uint3(i1, j0, k), _Layer12WH.zw, mult2),
                        getLayerNP(_Layer2, uint3(i1, j1, k), _Layer12WH.zw, mult2));
                }

                // bias + skip in
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID) + mp;

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));

                //if (i == 15 && j == 14 && k == 127)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "maxPool2x2Stride2NoPad"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            Texture2D<float> _Layer2;
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

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                uint2 PLD2;
                _Layer2.GetDimensions(PLD2.x, PLD2.y);
                const uint2 mult2 = PLD2 / _Layer12WH.zw;

                float cl = 0.0;

                // 1x1 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }

                // max pool
                const uint i0 = i * 2, i1 = i0 + 1;
                const uint j0 = j * 2, j1 = j0 + 1;

                float mp = max4(getLayerNP(_Layer2, uint3(i0, j0, k), _Layer12WH.zw, mult2),
                    getLayerNP(_Layer2, uint3(i0, j1, k), _Layer12WH.zw, mult2),
                    getLayerNP(_Layer2, uint3(i1, j0, k), _Layer12WH.zw, mult2),
                    getLayerNP(_Layer2, uint3(i1, j1, k), _Layer12WH.zw, mult2));

                // bias + skip in
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID) + mp;

                // activation
                cl = PRelu(cl, getConst(_Weights, uint2(k, 0), _MultiplierID));

                //if (i == 15 && j == 14 && k == 127)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "conv2D2x2Stride1"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
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

                const uint k = px.x + px.y * _WHDM.x;

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                float cl = 0.0;

                // 2x2 kernel
                for (uint l = 0; l < _WHDM.z; l++)
                {
                    cl +=
                        getLayerNP(_Layer1, uint3(0, 0, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 0, 0), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(0, 1, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 0, 1), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(1, 0, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 1, 0), _KernelSize, _WeightID) +
                        getLayerNP(_Layer1, uint3(1, 1, l), _Layer12WH.xy, mult1) * getConst(_Weights, uint4(k, l, 1, 1), _KernelSize, _WeightID);
                }
                // bias
                cl = cl + getConst(_Weights, uint2(0, k), _BiasID);

                //if (k == 14)
                //    buffer[0] = cl;

                if (all(px == 0))
                {
                    // Left/Right eye flag
                    cl += _Layer1[uint2(0, 0)] < 100000.0 ? 0.0 : 10000000.0;
                }
                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "LR Eyes"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float>   _Layer1;
            Texture2D<float4>  _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                uint eyeIndex = _Layer1[uint2(0, 0)] < 100000.0 ? 0 : 1;

                float4 col = _Layer2[px];
                
                if (eyeIndex == px.x)
                {
                    col.r = _Layer1[uint2(0, px.y)];
                    col.r = col.r > 100000.0 ? col.r - 10000000.0 : col.r;
                    col.r /= 64.0;
                    col.g = _Layer1[uint2(1, px.y)] / 64.0;
                    col.b = _Layer1[uint2(2, px.y)] / 64.0;
                    // Flip the right eye back
                    col.r = eyeIndex ? col.r : 1.0 - col.r;
                }

                //if (px.x == 1)
                //buffer[0] = float4(eyeIndex.xxxx);

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "LR Brows Contours"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            Texture2D<float>   _Layer1;
            Texture2D<float4>  _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                uint eyeIndex = _Layer1[uint2(0, 0)] < 100000.0 ? 0 : 1;

                float4 col = _Layer2[px];
                
                if (eyeIndex == (px.y / 9))
                {
                    uint h = px.x + (px.y - (px.y / 9) * 9) * 8;
                    col.r = _Layer1[uint2(0, h)];
                    col.r = col.r > 100000.0 ? col.r - 10000000.0 : col.r;
                    col.r /= 64.0;
                    col.g = _Layer1[uint2(1, h)] / 64.0;
                    col.b = _Layer1[uint2(2, h)] / 64.0;
                    // Flip the right eye back
                    col.r = eyeIndex ? col.r : 1.0 - col.r;
                }

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "Procrustes Analysis"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #include "svd_hlsl.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float3> _Layer1;
            Texture2D<float3> _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                bool leftSide = px.x < 8;
                float4 col = 0.0;

                if (px.y == 0)
                {
                    float3x3 X;
                    X[0] = _Layer1[uint2(0, 7 + (leftSide ? 0 : 9))];
                    X[1] = _Layer1[uint2(5, 7 + (leftSide ? 0 : 9))];
                    X[2] = _Layer1[uint2(3, 8 + (leftSide ? 0 : 9))];

                    float3x3 Y = leftSide ? eyeLInit : eyeRInit;

                    const float3 muX = findCenteroid(X);
                    const float3 muY = findCenteroid(Y);

                    float3x3 X0;
                    float3x3 Y0;
                    uint i, j;
                    for (i = 0; i < 3; i++)
                    {
                        X0[i] = X[i] - muX;
                        Y0[i] = Y[i] - muY;
                    }

                    // squared error
                    float ssX = 0.0;
                    float ssY = 0.0;
                    [unroll]
                    for (i = 0; i < 3; i++)
                    {
                        [unroll]
                        for (j = 0; j < 3; j++)
                        {
                            ssX += X0[i][j] * X0[i][j];
                            ssY += Y0[i][j] * Y0[i][j];
                        }
                    }

                    // centred Frobenius norm
                    const float normX = sqrt(ssX);
                    const float normY = sqrt(ssY);

                    // scale to equal (unit) norm
                    [unroll]
                    for (i = 0; i < 3; i++)
                    {
                        [unroll]
                        for (j = 0; j < 3; j++)
                        {
                            X0[i][j] /= normX;
                            Y0[i][j] /= normY;
                        }
                    }

                    // Singular value decomposition of a 3x3 matrix
                    float3x3 A = mul(transpose(X0), Y0);
                    float3x3 U;
                    float3 D;
                    float3x3 Vt;
                    GetSVD3D(A, U, D, Vt);
                    
                    // solve optimum rotation matrix of Y
                    float3x3 V = transpose(Vt);
                    float3x3 T = mul(V, transpose(U));

                    bool have_reflection = determinant(T) < 0.0;
                    if (have_reflection != false)
                    {
                        V[0][2] = -V[0][2];
                        V[1][2] = -V[1][2];
                        V[2][2] = -V[2][2];
                        D[2] = -D[2];
                        T = mul(V, transpose(U));
                    }

                    const float traceTA = D[0] + D[1] + D[2];

                    StoreValue(txIrisRotation0 + uint2(leftSide ? 0 : 8, 0),
                        float4(T[0], 0.0), col, px);
                    StoreValue(txIrisRotation1 + uint2(leftSide ? 0 : 8, 0),
                        float4(T[1], 0.0), col, px);
                    StoreValue(txIrisRotation2 + uint2(leftSide ? 0 : 8, 0),
                        float4(T[2], 0.0), col, px);
                    StoreValue(txIrisScaleYNorm + uint2(leftSide ? 0 : 8, 0),
                        float4(traceTA * normX, normY, 0.0, 0.0), col, px);
                    StoreValue(txIrisXCentroid + uint2(leftSide ? 0 : 8, 0),
                        float4(muX, 0.0), col, px);
                    StoreValue(txIrisYCentroid + uint2(leftSide ? 0 : 8, 0),
                        float4(muY, 0.0), col, px);
                }
                else
                {
                    // Keep history for smoothing
                    col.rgb = _Layer2[uint2(px.x, px.y - 1)];
                }

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "Reverse Rotation"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float3> _Layer1;
            Texture2D<float3> _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                
                uint2 texWH;
                _Layer1.GetDimensions(texWH.x, texWH.y);

                // iris or brow texture
                bool isIris = (texWH.x == 2);
                bool leftSide = isIris ? (px.x == 0) : (px.y < 9);

                float3 pos = _Layer1[px];
                // The iris depth fucks with the SVD rotation
                pos.z = isIris ? 0.0 : pos.z;

                float3 YCentroid = 0.0;
                float3 XCentroid = 0.0;
                float2 scaleYNorm = 0.0;
                float3x3 look = 0.0;

                for (uint i = 0; i < 6; i++)
                {
                    look[0] += _Layer2[txIrisRotation0 + uint2(leftSide ? 0 : 8, 0)];
                    look[1] += _Layer2[txIrisRotation1 + uint2(leftSide ? 0 : 8, 0)];
                    look[2] += _Layer2[txIrisRotation2 + uint2(leftSide ? 0 : 8, 0)];
                    YCentroid += _Layer2[txIrisYCentroid + uint2(leftSide ? 0 : 8, 0)];
                    XCentroid += _Layer2[txIrisXCentroid + uint2(leftSide ? 0 : 8, 0)];
                    scaleYNorm += _Layer2[txIrisScaleYNorm + uint2(leftSide ? 0 : 8, 0)].xy;
                }

                look *= 0.1667;
                YCentroid *= 0.1667;
                XCentroid *= 0.1667;
                scaleYNorm *= 0.1667;

                // Reverse the rotation, scale, and translation
                pos.xyz = (pos.xyz - YCentroid) / scaleYNorm.y;
                pos.xyz = scaleYNorm.x * mul(look, pos.xyz) + XCentroid;

                return float4(pos, 0.0);
            }
            ENDCG
        }

        Pass
        {
            Name "Flip Right Eye"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "IrisInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            sampler2D  _Layer1;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                /*
                    ​Image of proportionally cropped left eye with
                    eyebrow (or horizontally flipped right eye) with a
                    25% margin on each side and size 64x64
                */
                const float2 uv = IN.globalTexcoord.xy;

                bool flipEye = abs(tex2D(_Layer1, 0..xx).x - 0.1337) < 0.001;
                float2 flippedUV = uv;
                flippedUV.y = flipEye ? flippedUV.y : 1.0 - flippedUV.y;

                float4 col = tex2D(_Layer1, flippedUV);
                if (all(uv.xy <= 0.01.xx))
                {
                    col = flipEye ? 0.1337.xxxx : 1..xxxx;
                }
                return col;
            }
            ENDCG
        }
    }
}
