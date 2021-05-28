Shader "FaceLandmarkDetection/FaceTrack"
{
    Properties
    {
        _isFace ("Face Flag", 2D) = "black" {}
        _FaceRotate ("Face Rotations Input", 2D) = "black" {}
        _MaskRotate ("Rotation Mask", 2D) = "black" {}
        _FacePositions ("Face Positions Input", 2D) = "black" {}
        _BlinkRightTex ("Blink Right Texture", 2D) = "black" {}
        _BlinkRightSlider ("Test Blink Right", Range(0, 1)) = 0
        _BlinkLeftTex ("Blink Left Texture", 2D) = "black" {}
        _BlinkLeftSlider ("Test Blink Left", Range(0, 1)) = 0
        _MouthOpenTex ("Mouth Open Texture", 2D) = "black" {}
        _MouthOpenSlider ("Test Mouth Open", Range(0, 1)) = 0
        _MouthShrinkTex ("Mouth Shrink Texture", 2D) = "black" {}
        _MouthShrinkSlider ("Test Mouth Shrink", Range(0, 1)) = 0

        [Enum(Off, 0, Front, 1, Back, 2)] _Culling ("Culling Mode", Int) = 2
        _Cutoff("Cutout", Range(0,1)) = .5
        _MainTex("Texture", 2D) = "white" {}
        [hdr] _Color("Albedo", Color) = (1,1,1,1)
        [Gamma] _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Cull [_Culling]

        CGINCLUDE
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityPBSLighting.cginc"

            Texture2D<float3> _FaceRotate;
            Texture2D<float3> _FacePositions;
            Texture2D<float3> _BlinkRightTex;
            Texture2D<float3> _BlinkLeftTex;
            Texture2D<float3> _MouthOpenTex;
            Texture2D<float3> _MouthShrinkTex;
            Texture2D<float> _isFace;
            sampler2D _MaskRotate;

            float _BlinkRightSlider;
            float _BlinkLeftSlider;
            float _MouthOpenSlider;
            float _MouthShrinkSlider;

            float4 _Color;
            float _Metallic;
            float _Smoothness;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;

            struct v2f
            {
                #ifndef UNITY_PASS_SHADOWCASTER
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 wPos : TEXCOORD0;
                SHADOW_COORDS(3)
                #else
                V2F_SHADOW_CASTER;
                #endif
                float2 uv : TEXCOORD1;
            };

            v2f vert(appdata_base v, uint vertexID : SV_VertexID)
            {
                v2f o;

                // // Rotate if input is a face
                // if (_isFace, float4(0, 0, 0, 0)).r > 0.5)
                // {

                    // Mouth spread
                    float3 p61 = _FacePositions[uint2(9, 4)];
                    float3 p91 = _FacePositions[uint2(0, 7)];

                    // Mouth open
                    float3 p13 = _FacePositions[uint2(0, 1)];
                    float3 p14 = _FacePositions[uint2(1, 1)];

                    // Blink Right
                    float3 p159 = _FacePositions[uint2(3, 12)];
                    float3 p145 = _FacePositions[uint2(2, 11)];

                    // Blink Left
                    float3 p386 = _FacePositions[uint2(9, 29)];
                    float3 p374 = _FacePositions[uint2(10, 28)];

                    float MSD = (distance(p61, p91) - 8.8) / 6.0;
                    float MOD = distance(p13, p14) / 8.0 - 0.3;
                    float BRD = 1.0 - distance(p159, p145) / 6.0;
                    float BLD = 1.0 - distance(p386, p374) / 6.0;

                    uint2 px;
                    px.x = vertexID % 128;
                    px.y = vertexID / 128;

                    v.vertex.xyz = v.vertex.xyz + _BlinkRightTex[px] *
                        (_BlinkRightSlider + BRD);
                    v.vertex.xyz = v.vertex.xyz + _BlinkLeftTex[px] *
                        (_BlinkLeftSlider + BLD);
                    v.vertex.xyz = v.vertex.xyz + _MouthOpenTex[px] *
                        (_MouthOpenSlider + MOD);
                    v.vertex.xyz = v.vertex.xyz + _MouthShrinkTex[px] *
                        (_MouthShrinkSlider + MSD);

                    float3x3 look;

                    look[0] = (_FaceRotate[uint2(0, 0)] + _FaceRotate[uint2(0, 2)] + _FaceRotate[uint2(0, 3)]) * 0.3333;
                    look[1] = (_FaceRotate[uint2(1, 0)] + _FaceRotate[uint2(1, 2)] + _FaceRotate[uint2(1, 3)]) * 0.3333;
                    look[2] = (_FaceRotate[uint2(2, 0)] + _FaceRotate[uint2(2, 2)] + _FaceRotate[uint2(2, 3)]) * 0.3333;
                    float rotMask = 1.0 - tex2Dlod(_MaskRotate, float4(v.texcoord.xy, 0, 0)).r;
                    v.vertex.xyz = lerp(v.vertex.xyz, mul(look, v.vertex.xyz), rotMask);
                // }

                #ifdef UNITY_PASS_SHADOWCASTER
                TRANSFER_SHADOW_CASTER_NOPOS(o, o.pos);
                #else
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityWorldToClipPos(o.wPos);
                o.normal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                #endif
                o.uv = TRANSFORM_TEX(v.texcoord.xy, _MainTex);
                return o;
            }

            #ifndef UNITY_PASS_SHADOWCASTER
            float4 frag(v2f i) : SV_TARGET
            {
                float3 normal = normalize(i.normal);
                float4 texCol = tex2D(_MainTex, i.uv) * _Color;
                clip(texCol.a - _Cutoff);

                float2 uv = i.uv;

                UNITY_LIGHT_ATTENUATION(attenuation, i, i.wPos.xyz);

                float3 specularTint;
                float oneMinusReflectivity;
                float smoothness = _Smoothness;
                float3 albedo = DiffuseAndSpecularFromMetallic(
                    texCol, _Metallic, specularTint, oneMinusReflectivity
                );
                
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.wPos);
                UnityLight light;
                light.color = attenuation * _LightColor0.rgb;
                light.dir = normalize(UnityWorldSpaceLightDir(i.wPos));
                UnityIndirect indirectLight;
                #ifdef UNITY_PASS_FORWARDADD
                indirectLight.diffuse = indirectLight.specular = 0;
                #else
                indirectLight.diffuse = max(0, ShadeSH9(float4(normal, 1)));
                float3 reflectionDir = reflect(-viewDir, normal);
                Unity_GlossyEnvironmentData envData;
                envData.roughness = 1 - smoothness;
                envData.reflUVW = reflectionDir;
                indirectLight.specular = Unity_GlossyEnvironment(
                    UNITY_PASS_TEXCUBE(unity_SpecCube0), unity_SpecCube0_HDR, envData
                );
                #endif

                float3 col = UNITY_BRDF_PBS(
                    albedo, specularTint,
                    oneMinusReflectivity, smoothness,
                    normal, viewDir,
                    light, indirectLight
                );

                #ifdef UNITY_PASS_FORWARDADD
                return float4(col, 0);
                #else
                return float4(col, 1);
                #endif
            }
            #else
            float4 frag(v2f i) : SV_Target
            {
                float alpha = _Color.a;
                if (_Cutoff > 0)
                    alpha *= tex2D(_MainTex, i.uv).a;
                clip(alpha - _Cutoff);
                SHADOW_CASTER_FRAGMENT(i)
            }
            #endif
        ENDCG

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase_fullshadows
            #pragma multi_compile UNITY_PASS_FORWARDBASE
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend One One
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile UNITY_PASS_FORWARDADD
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #pragma multi_compile UNITY_PASS_SHADOWCASTER
            ENDCG
        }
    }
}
