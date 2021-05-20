Shader "FaceLandmarkDetection/FaceMesh Model"
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
            Name "Camera Input"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            sampler2D        _CamIn;
            uint4            _WHDM;
            uint4            _Layer12WH;
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

                // stride = 2
                const uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;

                float cl = 0.0;
                // kernel
                [unroll(3)]
                for (uint l = 0; l < _WHDM.z; l++) {
                    cl +=
                        getCameraVP(_CamIn, uint3(i0, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 0, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 1, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i0, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(0, 2, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 0, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 1, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i1, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(1, 2, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j0, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 0, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j1, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 1, l, k), _WHDM.z, _WeightID) +
                        getCameraVP(_CamIn, uint3(i2, j2, l), _Layer12WH.xy) * getConst(_Weights, uint4(2, 2, l, k), _WHDM.z, _WeightID);

                        // test(i0, j0, l) * getConst(_Weights, uint4(0, 0, l, k), _WHDM.z, _WeightID) +
                        // test(i0, j1, l) * getConst(_Weights, uint4(0, 1, l, k), _WHDM.z, _WeightID) +
                        // test(i0, j2, l) * getConst(_Weights, uint4(0, 2, l, k), _WHDM.z, _WeightID) +
                        // test(i1, j0, l) * getConst(_Weights, uint4(1, 0, l, k), _WHDM.z, _WeightID) +
                        // test(i1, j1, l) * getConst(_Weights, uint4(1, 1, l, k), _WHDM.z, _WeightID) +
                        // test(i1, j2, l) * getConst(_Weights, uint4(1, 2, l, k), _WHDM.z, _WeightID) +
                        // test(i2, j0, l) * getConst(_Weights, uint4(2, 0, l, k), _WHDM.z, _WeightID) +
                        // test(i2, j1, l) * getConst(_Weights, uint4(2, 1, l, k), _WHDM.z, _WeightID) +
                        // test(i2, j2, l) * getConst(_Weights, uint4(2, 2, l, k), _WHDM.z, _WeightID);
                }
                // bias
                cl = cl + getConst(_Weights, k, _BiasID, false);

                // activation
                cl = relu(cl) + relu(-cl) * getConst(_Weights, k, _MultiplierID, false);

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Depth-wise Conv2D Stride 1"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _WeightID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                
                const uint widthMult = floor(_CustomRenderTextureWidth / _WHDM.x);

                const uint i = px.y % _WHDM.y;
                const uint j = px.x % _WHDM.x;
                const uint k = (px.x / _WHDM.x) + (px.y / _WHDM.y) * widthMult;

                // stride = 1
                const uint i0 = i, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j, j1 = j0 + 1, j2 = j0 + 2;

                uint2 PLD;
                _Layer1.GetDimensions(PLD.x, PLD.y);
                const uint2 mult = PLD / _Layer12WH.xy;

                float cl =
                    getLayerSP(_Layer1, uint3(i0, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 0, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i0, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 1, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i0, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 2, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 0, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 1, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i1, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 2, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 0, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 1, k), _WeightID) +
                    getLayerSP(_Layer1, uint3(i2, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 2, k), _WeightID);

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Depth-wise Conv2D Stride 2"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _WeightID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                
                const uint widthMult = floor(_CustomRenderTextureWidth / _WHDM.x);

                const uint i = px.y % _WHDM.y;
                const uint j = px.x % _WHDM.x;
                const uint k = (px.x / _WHDM.x) + (px.y / _WHDM.y) * widthMult;

                // stride = 2
                const uint i0 = i * 2, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = j * 2, j1 = j0 + 1, j2 = j0 + 2;

                uint2 PLD;
                _Layer1.GetDimensions(PLD.x, PLD.y);
                const uint2 mult = PLD / _Layer12WH.xy;

                float cl =
                    getLayerVP(_Layer1, uint3(i0, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 0, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i0, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 1, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i0, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 2, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i1, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 0, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i1, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 1, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i1, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 2, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i2, j0, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 0, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i2, j1, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 1, k), _WeightID) +
                    getLayerVP(_Layer1, uint3(i2, j2, k), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 2, k), _WeightID);

                //if (i == 1 && j == 2 && k == 32) buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Batch Normalization"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            Texture2D<float> _Layer2;
            uint4            _WHDM;
            uint4            _Layer12WH;
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
                for (uint l = 0; l < _WHDM.z; l++) {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }
                // bias + add another layer
                cl = cl + getConst(_Weights, k, _BiasID, false) +
                    getLayerNP(_Layer2, uint3(i, j, k), _Layer12WH.zw, mult2);

                // activation
                cl = relu(cl) + relu(-cl) * getConst(_Weights, k, _MultiplierID, false);

                //if (i == 2 && j == 1 && k == 31) buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Max Pool Batch Normalization"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            Texture2D<float> _Layer2;
            uint4            _WHDM;
            uint4            _Layer12WH;
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
                
                // stride = 2
                const uint i0 = i * 2, i1 = i0 + 1;
                const uint j0 = j * 2, j1 = j0 + 1;

                float cl = 0.0;

                uint2 PLD1;
                _Layer1.GetDimensions(PLD1.x, PLD1.y);
                const uint2 mult1 = PLD1 / _Layer12WH.xy;

                uint2 PLD2;
                _Layer2.GetDimensions(PLD2.x, PLD2.y);
                const uint2 mult2 = PLD2 / _Layer12WH.zw;

                if (k < _WHDM.z) {
                    cl = max4(getLayerNP(_Layer1, uint3(i0, j0, k), _Layer12WH.xy, mult1),
                            getLayerNP(_Layer1, uint3(i0, j1, k), _Layer12WH.xy, mult1),
                            getLayerNP(_Layer1, uint3(i1, j0, k), _Layer12WH.xy, mult1),
                            getLayerNP(_Layer1, uint3(i1, j1, k), _Layer12WH.xy, mult1));
                }

                float bn = 0.0;
                // 1x1 kernel
                for (uint l = 0; l < _WHDM.z; l++) {
                    bn += getLayerNP(_Layer2, uint3(i, j, l), _Layer12WH.zw, mult2) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }
                // bias + add another layer
                cl = cl + bn + getConst(_Weights, k, _BiasID, false);

                // activation
                cl = relu(cl) + relu(-cl) * getConst(_Weights, k, _MultiplierID, false);

                //if (i == 1 && j == 2 && k == 31) buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "1x1 Conv2D"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
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
                for (uint l = 0; l < _WHDM.z; l++) {
                    cl += getLayerNP(_Layer1, uint3(i, j, l), _Layer12WH.xy, mult1) *
                        getConst(_Weights, uint2(l, k), _WeightID);
                }
                // bias + add another layer
                cl = cl + getConst(_Weights, k, _BiasID, false);

                // activation
                cl = relu(cl) + relu(-cl) * getConst(_Weights, k, _MultiplierID, false);

                //if (i == 2 && j == 1 && k == 31) buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Face Flag Output"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _WeightID;
            uint             _BiasID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                // stride = 0
                const uint i0 = 0, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = 0, j1 = j0 + 1, j2 = j0 + 2;

                float cl = 0.0;

                uint2 PLD;
                _Layer1.GetDimensions(PLD.x, PLD.y);
                const uint2 mult = PLD / _Layer12WH.xy;

                for (uint l = 0; l < _WHDM.z; l++) {
                    cl +=
                        getLayerNP(_Layer1, uint3(i0, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 0, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i0, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 1, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i0, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(0, 2, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 0, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 1, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(1, 2, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 0, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 1, l), _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint3(2, 2, l), _WeightID);
                }

                cl = sigmoid(cl + getConst(_Weights, 0, _BiasID, false));

                //buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Face Mesh Output"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Weights;
            Texture2D<float> _Layer1;
            uint4            _WHDM;
            uint4            _Layer12WH;
            uint             _WeightID;
            uint             _BiasID;

            float frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                const uint k = px.x + px.y * uint(_CustomRenderTextureWidth);

                // stride = 0
                const uint i0 = 0, i1 = i0 + 1, i2 = i0 + 2;
                const uint j0 = 0, j1 = j0 + 1, j2 = j0 + 2;

                float cl = 0.0;

                uint2 PLD;
                _Layer1.GetDimensions(PLD.x, PLD.y);
                const uint2 mult = PLD / _Layer12WH.xy;

                for (uint l = 0; l < _WHDM.z; l++) {
                    cl +=
                        getLayerNP(_Layer1, uint3(i0, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(0, 0, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i0, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(0, 1, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i0, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(0, 2, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(1, 0, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(1, 1, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i1, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(1, 2, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j0, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(2, 0, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j1, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(2, 1, l, k), _WHDM.z, _WeightID) +
                        getLayerNP(_Layer1, uint3(i2, j2, l), _Layer12WH.xy, mult) * getConst(_Weights, uint4(2, 2, l, k), _WHDM.z, _WeightID);
                }

                cl = cl + getConst(_Weights, k, _BiasID, true);

                //if (k == 1010) buffer[0] = cl.xxxx;

                return cl;
            }
            ENDCG
        }

        Pass
        {
            Name "Draw Points"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float>  _Layer1;
            Texture2D<float3> _Layer2;
            sampler2D         _CamIn;
            float4            _CamIn_TexelSize;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const float2 uv = IN.globalTexcoord.xy;
                float4 col = tex2D(_CamIn, uv);
                uint2 texWH;
                _Layer1.GetDimensions(texWH.x, texWH.y);

                float d = 1000.0;

                for (uint k = 0; k < texWH.x; k += 3) {
                    for (uint j = 0; j < texWH.y; j++) {
                        float x = _Layer1[uint2(k, j)];
                        float y = _Layer1[uint2(k + 1, j)];
                        //float z = _Layer1[uint2(k + 2, j)];

                        d = min(d, sdCircle(uv - float2(y, x) / _CamIn_TexelSize.zw, 0.0055));
                    }
                }

                col = lerp(col, float4(1, 1, 1, 1), 1.0-smoothstep(0.001,0.005,abs(d)));
                d = 1000.0;

                // // Reverse rotation debug
                // _Layer2.GetDimensions(texWH.x, texWH.y);
                // for (uint k = 0; k < texWH.x; k ++) {
                //     for (uint j = 0; j < texWH.y; j++) {
                //         float2 pos = _Layer2[uint2(k, j)].rg;
                //         //float z = _Layer1[uint2(k + 2, j)];

                //         d = min(d, sdCircle(uv - pos.yx / _CamIn_TexelSize.zw, 0.0055));
                //     }
                // }

                // col = lerp(col, float4(1, 0, 1, 0), 1.0-smoothstep(0.001,0.005,abs(d)));

                return col;
            }
            ENDCG
        }

        Pass
        {
            Name "Calculate Vectors"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Layer1;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                float4 col = 0;

                // Between eyes
                const float3 p6 = { _Layer1[uint2(18, 0)], _Layer1[uint2(19, 0)], _Layer1[uint2(20, 0)] };

                // Right Head
                const float3 p103 = { _Layer1[uint2(36, 7)], _Layer1[uint2(37, 7)], _Layer1[uint2(38, 7)] };

                // Left Head
                const float3 p332 = { _Layer1[uint2(21, 25)], _Layer1[uint2(22, 25)], _Layer1[uint2(23, 25)] };

                float3 vEyeToRH = p6 - p103;
                float3 vEyetoLH = p6 - p332;
                float3 vFace = normalize(cross(vEyeToRH, vEyetoLH));

                float3 centerHead = (p103 + p332) * 0.5;
                float3 vUp = normalize(p6 - centerHead);

                if (px.y == 0)
                {
                    // Rotate head forward cause the head leans back a little
                    vFace.yz = mul(rot2(0.5), vFace.yz);
                    vUp.yz = mul(rot2(0.5), vUp.yz);
                    float3x3 lookDir = lookAt(vFace, vUp);
                    col.rgb = lookDir[min(px.x, 2)];
                }
                else if (px.y == 1)
                {
                    // Keep unmodified values
                    float3x3 lookDir = lookAt(vFace, vUp);
                    col.rgb = lookDir[min(px.x, 2)];
                }
                else if (all(px == uint2(0, 2)))
                {
                    uint2 texWH;
                    _Layer1.GetDimensions(texWH.x, texWH.y);

                    float3 fCentroid = 0.0;
                    // Get fCentroid
                    for (uint k = 0; k < texWH.x; k += 3) {
                        for (uint j = 0; j < texWH.y; j++) {
                            fCentroid.x += _Layer1[uint2(k, j)];
                            fCentroid.y += _Layer1[uint2(k + 1, j)];
                            fCentroid.z += _Layer1[uint2(k + 2, j)];
                        }
                    }

                    col.rgb = fCentroid / 468.0;
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
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float> _Layer1;
            Texture2D<float3> _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                float3 pos;
                pos.x = _Layer1[uint2(px.x * 3, px.y)];
                pos.y = _Layer1[uint2(px.x * 3 + 1, px.y)];
                pos.z = _Layer1[uint2(px.x * 3 + 2, px.y)];

                float3 fCentroid = _Layer2[uint2(0, 2)].rgb;

                float3x3 look;

                look[0] = _Layer2[uint2(0, 0)].rgb;
                look[1] = _Layer2[uint2(1, 0)].rgb;
                look[2] = _Layer2[uint2(2, 0)].rgb;

                // Reverse the rotation
                pos.xyz = mul(pos.xyz - fCentroid, look) + fCentroid;

                return float4(pos, 0.0);
            }
            ENDCG
        }
    }
}