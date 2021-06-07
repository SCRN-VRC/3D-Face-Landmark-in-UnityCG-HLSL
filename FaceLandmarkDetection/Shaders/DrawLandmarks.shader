Shader "FaceLandmarkDetection/DrawLandmarks"
{
    Properties
    {
        _CamIn ("Camera Input", 2D) = "black" {}
        _FaceMeshTex ("Face Mesh Points", 2D) = "black" {}
        _BrowContourTex ("Brow Countors Points", 2D) = "black" {}
        _EyeTex ("Eye Points", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "MLCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _CamIn;
            Texture2D<float> _FaceMeshTex;
            Texture2D<float3> _BrowContourTex;
            Texture2D<float3> _EyeTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                const float2 uv = i.uv;
                float4 col = tex2D(_CamIn, uv);
                uint2 texWH;
                _FaceMeshTex.GetDimensions(texWH.x, texWH.y);
                float d = 1000.0;

                for (uint k = 0; k < texWH.x; k += 3) {
                    for (uint j = 0; j < texWH.y; j++) {
                        float x = _FaceMeshTex[uint2(k, j)];
                        float y = _FaceMeshTex[uint2(k + 1, j)];
                        //float z = _FaceMeshTex[uint2(k + 2, j)];

                        d = min(d, sdCircle(uv - float2(y, x) / 192.0, 0.0055));
                    }
                }

                col = lerp(col, float4(1, 1, 1, 1), 1.0-smoothstep(0.001,0.005,abs(d)));
                d = 1000.0;

                bool flipEye = false;

                // Right coords for eye position from facemesh
                uint2 eyeNPos = uint2(9, 12);
                uint2 eyeSPos = uint2(6, 11);
                uint2 eyeEPos = uint2(9, 10);
                uint2 eyeWPos = uint2(21, 2);

                float2 eyeN = float2(_FaceMeshTex[eyeNPos], _FaceMeshTex[eyeNPos + uint2(1, 0)]);
                float2 eyeS = float2(_FaceMeshTex[eyeSPos], _FaceMeshTex[eyeSPos + uint2(1, 0)]);
                float2 eyeE = float2(_FaceMeshTex[eyeEPos], _FaceMeshTex[eyeEPos + uint2(1, 0)]);
                float2 eyeW = float2(_FaceMeshTex[eyeWPos], _FaceMeshTex[eyeWPos + uint2(1, 0)]);

                float2 eyeCentroid[2];

                // Compute center
                eyeCentroid[1] = (eyeN + eyeS + eyeE + eyeW) * 0.25 / 192.0;
                //d = min(d, sdCircle(uv - eyeCentroid[0].yx, 0.0055));

                // Left coords for eye position from facemesh
                eyeNPos = uint2(27, 29);
                eyeSPos = uint2(30, 28);
                eyeEPos = uint2(9, 20);
                eyeWPos = uint2(33, 27);

                eyeN = float2(_FaceMeshTex[eyeNPos], _FaceMeshTex[eyeNPos + uint2(1, 0)]);
                eyeS = float2(_FaceMeshTex[eyeSPos], _FaceMeshTex[eyeSPos + uint2(1, 0)]);
                eyeE = float2(_FaceMeshTex[eyeEPos], _FaceMeshTex[eyeEPos + uint2(1, 0)]);
                eyeW = float2(_FaceMeshTex[eyeWPos], _FaceMeshTex[eyeWPos + uint2(1, 0)]);
                
                eyeCentroid[0] = (eyeN + eyeS + eyeE + eyeW) * 0.25 / 192.0;
                //d = min(d, sdCircle(uv - eyeCentroid[1].yx, 0.0055));

                _BrowContourTex.GetDimensions(texWH.x, texWH.y);

                for (uint k = 0; k < texWH.x; k++)
                {
                    for (uint l = 0; l < texWH.y; l++)
                    {
                        float2 pos = _BrowContourTex[uint2(k, l)].yx;
                        d = min(d, sdCircle(uv - (pos * 0.225 + eyeCentroid[l / 9].yx - eyeCentroid[l / 9].yx * 0.1125 - float2(0.09, 0.05625)), 0.0055));
                    }
                }

                col = lerp(col, float4(0, 0, 1, 0), 1.0-smoothstep(0.001,0.005,abs(d)));
                d = 1000.0;

                _EyeTex.GetDimensions(texWH.x, texWH.y);

                for (uint k = 0; k < texWH.x; k++)
                {
                    for (uint l = 0; l < texWH.y; l++)
                    {
                        float2 pos = _EyeTex[uint2(k, l)].yx;
                        d = min(d, sdCircle(uv - (pos * 0.225 + eyeCentroid[k].yx - eyeCentroid[k].yx * 0.1125 - float2(0.09, 0.05625)), 0.0055));
                    }
                }

                col = lerp(col, float4(1, 0, 0, 0), 1.0-smoothstep(0.001,0.005,abs(d)));
                
                return col;
            }
            ENDCG
        }
    }
}
