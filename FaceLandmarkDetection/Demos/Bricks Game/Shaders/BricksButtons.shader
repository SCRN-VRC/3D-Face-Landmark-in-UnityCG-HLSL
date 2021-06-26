Shader "FaceLandmarkDetection/Games/BricksButtons"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _StateTex ("State Input", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "ShaderGames.cginc"
            #include "BricksInc.cginc"


            #define SMOOTH(r) (lerp(1.0, 0.0, smoothstep(0.9, 1.0, r)))

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

            Texture2D<float4> _StateTex;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float drawRing(float2 uv, float2 center, float r1, float r2, float amount)
            {
                uv = uv - center;
                float r = sqrt(dot(uv, uv));
                float2 theta = (1.0 + (atan2(uv.x, uv.y) / UNITY_PI)) / 2.0;
                return (SMOOTH(r / r2) - SMOOTH(r / r1)) *
                    (theta > amount ? 0.0 : 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                if (unity_OrthoParams.w) discard;

                float4 touch     = LoadValue( _StateTex, txTouch );
                float4 calibrate = LoadValue( _StateTex, txCalibrate );
                float4 start     = LoadValue( _StateTex, txStart );

                float2 uv = i.uv;
                uv.y = uv.y * 0.5 + 0.5;

                uint buttonState = floor((uv.x < 0.5) ? calibrate.x : start.x);
                // button disable
                uv.y -= (buttonState != WAIT_INPUT) ? 0.5 : 0.0;

                float4 col = tex2D(_MainTex, uv);

                // touched buttons
                if (touch.z > 0.5 && buttonState == WAIT_INPUT)
                {
                    float2 ringUV = i.uv * float2(8.0, 1.0);
                    float ring = drawRing(ringUV, float2(2.0 + 4.0 * (touch.z - 1.0), 0.5), 0.3, 0.5,
                        saturate(touch.w));
                    col = lerp(col, ring.rrrr, ring);
                }

                col.rgb *= col.a;
                return col;
            }
            ENDCG
        }
    }
}
