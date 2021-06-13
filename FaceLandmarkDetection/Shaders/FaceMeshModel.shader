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

        /*
            Python/MATLAB implementation of procrustes
            https://stackoverflow.com/questions/18925181/procrustes-analysis-with-numpy
        
            We want to undo the rotations to best measure the face mesh deformations
        */
        Pass
        {
            Name "Procrustes Analysis"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "LandmarkInclude.cginc"
            #include "svd_hlsl.cginc"
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

                float4 col = 0;

                // Between eyes
                // Z + 23.0 to make the normal direction face forward
                const float3 p6 = { _Layer1[uint2(18, 0)], _Layer1[uint2(19, 0)], _Layer1[uint2(20, 0)] + 23.0};

                // Right Head
                const float3 p103 = { _Layer1[uint2(36, 7)], _Layer1[uint2(37, 7)], _Layer1[uint2(38, 7)] };

                // Left Head
                const float3 p332 = { _Layer1[uint2(21, 25)], _Layer1[uint2(22, 25)], _Layer1[uint2(23, 25)] };

                if (px.y == 0)
                {
                    // Procrustes Analysis
                    // Find the rotation/translation/scale to map Y to X
                    float3x3 X = fmInitPos;
                    float3x3 Y = { p103, p6, p332 };

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
                    // why flipped? I don't know but it works
                    float3x3 V = transpose(Vt);
                    float3x3 T = mul(transpose(U), V);

                    bool have_reflection = determinant(T) < 0.0;
                    if (have_reflection != false)
                    {
                        V[0][2] = -V[0][2];
                        V[1][2] = -V[1][2];
                        V[2][2] = -V[2][2];
                        D[2] = -D[2];
                        T = mul(transpose(U), V);
                    }

                    const float traceTA = D[0] + D[1] + D[2];

                    StoreValue(txRotation0, float4(T[0], 0.0), col, px);
                    StoreValue(txRotation1, float4(T[1], 0.0), col, px);
                    StoreValue(txRotation2, float4(T[2], 0.0), col, px);
                    StoreValue(txScaleYNorm, float4(traceTA * normX, normY, 0.0, 0.0), col, px);
                    StoreValue(txXCentroid, float4(muX, 0.0), col, px);
                    StoreValue(txYCentroid, float4(muY, 0.0), col, px);
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
            #include "LandmarkInclude.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            #pragma target 5.0

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float>  _Layer1;
            Texture2D<float3> _Layer2;

            float4 frag(v2f_customrendertexture IN) : COLOR
            {
                const uint2 px = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);

                float3 pos;
                pos.x = _Layer1[uint2(px.x * 3, px.y)];
                pos.y = _Layer1[uint2(px.x * 3 + 1, px.y)];
                pos.z = _Layer1[uint2(px.x * 3 + 2, px.y)];

                float3 YCentroid = 0.0;
                float3 XCentroid = 0.0;
                float2 scaleYNorm = 0.0;
                float3x3 look = 0.0;

                for (uint i = 0; i < 6; i++)
                {
                    look[0] += _Layer2[uint2(0, i)];
                    look[1] += _Layer2[uint2(1, i)];
                    look[2] += _Layer2[uint2(2, i)];
                    YCentroid += _Layer2[uint2(5, i)];
                    XCentroid += _Layer2[uint2(4, i)];
                    scaleYNorm += _Layer2[uint2(3, i)].xy;
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
    }
}