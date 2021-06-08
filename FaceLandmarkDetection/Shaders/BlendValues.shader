Shader "FaceLandmarkDetection/BlendValues"
{
    Properties
    {
        _isFace ("Face Flag", 2D) = "black" {}
        _FaceRotate ("Face Rotations Input", 2D) = "black" {}
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
            #pragma target 5.0

            #include "UnityCG.cginc"
            #include "svd_hlsl.cginc"

            //RWStructuredBuffer<float4> buffer : register(u1);
            Texture2D<float3> _FaceRotate;
            Texture2D<float3> _FaceMeshTex;
            Texture2D<float3> _BrowContourTex;
            Texture2D<float3> _EyeTex;
            Texture2D<float> _isFace;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {

                return 0;
            }
            ENDCG
        }
    }
}
