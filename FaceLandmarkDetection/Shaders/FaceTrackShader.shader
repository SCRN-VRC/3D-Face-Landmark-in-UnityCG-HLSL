Shader "FaceLandmarkDetection/FaceTrackShader"
{
    Properties
    {
        _isFace ("Face Flag", 2D) = "black" {}
        _FaceRotate ("Face Rotations Input", 2D) = "black" {}
        _MaskRotate ("Rotation Mask", 2D) = "black" {}
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _FaceRotate;
        sampler2D _MaskRotate;
        sampler2D _isFace;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        
        void vert (inout appdata_full v) {
            // // Rotate if input is a face
            // if (tex2Dlod(_isFace, float4(0, 0, 0, 0)).r > 0.5)
            // {
                float3x3 look;

                look[0] = tex2Dlod(_FaceRotate, float4(0.00, 0, 0, 0)).rgb;
                look[1] = tex2Dlod(_FaceRotate, float4(0.25, 0, 0, 0)).rgb;
                look[2] = tex2Dlod(_FaceRotate, float4(0.50, 0, 0, 0)).rgb;
                float rotMask = 1.0 - tex2Dlod(_MaskRotate, float4(v.texcoord.xy, 0, 0)).r;
                v.vertex.xyz = lerp(v.vertex.xyz, mul(look, v.vertex.xyz), rotMask);
            // }
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
