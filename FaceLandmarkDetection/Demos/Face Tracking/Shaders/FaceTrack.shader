Shader "FaceLandmarkDetection/FaceTrack"
{
    Properties
    {
        _BlendValTex ("Blend Values Texture", 2D) = "black" {}
        _MaskRotate ("Rotation Mask", 2D) = "black" {}

        _BlinkRightTex ("Blink Right Texture", 2D) = "black" {}
        _BlinkLeftTex ("Blink Left Texture", 2D) = "black" {}
        _MouthOpenTex ("Mouth Open Texture", 2D) = "black" {}
        _MouthShrinkTex ("Mouth Shrink Texture", 2D) = "black" {}
        _MouthSmileTex ("Mouth Smile Texture", 2D) = "black" {}
        _MouthFrownTex ("Mouth Frown Texture", 2D) = "black" {}
        _BrowLeftInTex ("Brow Left In Texture", 2D) = "black" {}
        _BrowLeftOutTex ("Brow Left Out Texture", 2D) = "black" {}
        _BrowRightInTex ("Brow Right In Texture", 2D) = "black" {}
        _BrowRightOutTex ("Brow Right Out Texture", 2D) = "black" {}
        _IrisLeftXTex ("Iris Left X Texture", 2D) = "black" {}
        _IrisLeftYTex ("Iris Left Y Texture", 2D) = "black" {}
        _IrisRightXTex ("Iris Right X Texture", 2D) = "black" {}
        _IrisRightYTex ("Iris Right Y Texture", 2D) = "black" {}

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
        Texture2D<float3> _BlinkRightTex;
        Texture2D<float3> _BlinkLeftTex;
        Texture2D<float3> _MouthOpenTex;
        Texture2D<float3> _MouthShrinkTex;
        Texture2D<float3> _MouthSmileTex;
        Texture2D<float3> _MouthFrownTex;
        Texture2D<float3> _BrowLeftInTex;
        Texture2D<float3> _BrowLeftOutTex;
        Texture2D<float3> _BrowRightInTex;
        Texture2D<float3> _BrowRightOutTex;
        Texture2D<float3> _IrisLeftXTex;
        Texture2D<float3> _IrisLeftYTex;
        Texture2D<float3> _IrisRightXTex;
        Texture2D<float3> _IrisRightYTex;

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

            v.vertex.xyz = v.vertex.xyz + _BlinkRightTex[px] *
                _BlendValTex[txEyeBlinkLR].y;
            v.vertex.xyz = v.vertex.xyz + _BlinkLeftTex[px] *
                _BlendValTex[txEyeBlinkLR].x;
            v.vertex.xyz = v.vertex.xyz + _MouthOpenTex[px] *
                _BlendValTex[txMouthOpShSmFl].x;
            v.vertex.xyz = v.vertex.xyz + _MouthShrinkTex[px] *
                _BlendValTex[txMouthOpShSmFl].y;
            v.vertex.xyz = v.vertex.xyz +
                lerp(_MouthFrownTex[px], _MouthSmileTex[px], _BlendValTex[txMouthOpShSmFl].z);
            v.vertex.xyz = v.vertex.xyz + _BrowLeftInTex[px] *
                _BlendValTex[txBrowLRInOut].x;
            v.vertex.xyz = v.vertex.xyz + _BrowLeftOutTex[px] *
                _BlendValTex[txBrowLRInOut].y;
            v.vertex.xyz = v.vertex.xyz + _BrowRightInTex[px] *
                _BlendValTex[txBrowLRInOut].z;
            v.vertex.xyz = v.vertex.xyz + _BrowRightOutTex[px] *
                _BlendValTex[txBrowLRInOut].w;
            v.vertex.xyz = v.vertex.xyz + _IrisLeftXTex[px] *
                _BlendValTex[txIrisLRXY].x;
            v.vertex.xyz = v.vertex.xyz + _IrisLeftYTex[px] *
                _BlendValTex[txIrisLRXY].y;
            v.vertex.xyz = v.vertex.xyz + _IrisRightXTex[px] *
                _BlendValTex[txIrisLRXY].z;
            v.vertex.xyz = v.vertex.xyz + _IrisRightYTex[px] *
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
