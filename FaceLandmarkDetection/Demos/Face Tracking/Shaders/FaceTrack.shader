Shader "FaceLandmarkDetection/FaceTrack"
{
    Properties
    {
        _BlendValTex ("Blend Values Texture", 2D) = "black" {}
        _MaskRotate ("Rotation Mask", 2D) = "black" {}
        _BakedBlendTex ("Baked Blendshapes", 2D) = "black" {}

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
        #include "../../../Shaders/BlendValuesInclude.cginc"

        Texture2D<float4> _BlendValTex;
        Texture2D<float3> _BakedBlendTex;

        sampler2D _MaskRotate;

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

            uint2 px;
            px.x = vertexID % 128;
            px.y = vertexID / 128;

            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBlinkRight] *
                _BlendValTex[txEyeBlinkLR].y;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBlinkLeft] *
                _BlendValTex[txEyeBlinkLR].x;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedMouthOpen] *
                _BlendValTex[txMouthOpShSmFl].x;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedMouthShrink] *
                _BlendValTex[txMouthOpShSmFl].y;
            v.vertex.xyz = v.vertex.xyz +
                lerp(_BakedBlendTex[px + txBakedMouthFrown],
                    _BakedBlendTex[px + txBakedMouthSmile],
                    _BlendValTex[txMouthOpShSmFl].z);
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBrowLeftIn] *
                _BlendValTex[txBrowLRInOut].x;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBrowLeftOut] *
                _BlendValTex[txBrowLRInOut].y;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBrowRightIn] *
                _BlendValTex[txBrowLRInOut].z;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedBrowRightOut] *
                _BlendValTex[txBrowLRInOut].w;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedIrisLeftIn] *
                _BlendValTex[txIrisLRXY].x;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedIrisLeftUp] *
                _BlendValTex[txIrisLRXY].y;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedIrisRightIn] *
                _BlendValTex[txIrisLRXY].z;
            v.vertex.xyz = v.vertex.xyz + _BakedBlendTex[px + txBakedIrisRightUp] *
                _BlendValTex[txIrisLRXY].w;

            float3x3 look;

            look[0] = _BlendValTex[txBlendRot0];
            look[1] = _BlendValTex[txBlendRot1];
            look[2] = _BlendValTex[txBlendRot2];
            float rotMask = 1.0 - tex2Dlod(_MaskRotate, float4(v.texcoord.xy, 0, 0)).r;
            v.vertex.xyz = lerp(v.vertex.xyz, mul(v.vertex.xyz, look), rotMask);

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
