Shader "FaceLandmarkDetection/Games/BricksRender" {
    Properties {
        _StateTex ("State Input", 2D) = "black" {}
        _TextTex ("Text Block Image", 2D) = "black" {}
        _CamIn ("Camera Input", 2D) = "black" {}
        _GuideTex ("Camera Guide", 2D) = "black" {}
        _NoiseTex ("Noise Texture", 2D) = "black" {}
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
            Name "BricksRender"
            CGPROGRAM

            #include "UnityCustomRenderTexture.cginc"
            #include "ShaderGames.cginc"
            #include "BricksInc.cginc"
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment pixel_shader
            #pragma target 5.0

            float iTime;

            Texture2D<float4> _StateTex;
            sampler2D _CamIn;
            sampler2D _GuideTex;
            sampler2D _TextTex;
            sampler2D _NoiseTex;

            float2x2 rot2(float rot)
            {
                float sinRot;
                float cosRot;
                sincos(rot, sinRot, cosRot);
                return float2x2(cosRot, -sinRot, sinRot, cosRot);
            }

            // Created by inigo quilez - iq/2016
            // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

            //
            // Game rendering. Regular 2D distance field rendering.
            //

            //----------------

            #define shadowOffset float2(-0.03,0.03)

            //=================================================================================================
            // distance functions
            //=================================================================================================

            float udSegment( in float2 p, in float2 a, in float2 b )
            {
                float2 pa = p-a, ba = b-a;
                float h = saturate( dot(pa,ba)/dot(ba,ba) );
                return length( pa - ba*h );
            }

            float udHorizontalSegment( in float2 p, in float xa, in float xb, in float y )
            {
                float2 pa = p - float2(xa,y);
                float ba = xb - xa;
                pa.x -= ba*saturate( pa.x/ba );
                return length( pa );
            }

            float udRoundBox( in float2 p, in float2 c, in float2 b, in float r )
            {
                return length(max(abs(p-c)-b,0.0))-r;
            }

            float fastExp(in float x) {
                x = 0.2 * x + 1;
                return max(x*x*x, 0);
            }

            //=================================================================================================

            float doBrick( in int2 id, out float3 col, out float glo, out float2 cen )
            {
                float alp = 0.0;
                
                glo = 0.0;
                col = float3(0, 0, 0);
                cen = 0..xx;
                
                if( id.x>0 && id.x<13 && id.y>=0 && id.y<12 )
                {
                    float2 brickHere = _StateTex.Load(int3(txBricks.xy+id, 0)).xy;

                    alp = 1.0;
                    glo = 0.0;

                    if( brickHere.x < 0.5 )
                    {
                        float t = max(0.0,iTime-brickHere.y-0.1);
                        alp = fastExp(-2.0*t );
                        glo = fastExp(-4.0*t );
                    }
                     
                    if( alp>0.001 )
                    {
                        float fid = Hash(_NoiseTex, float3(id.xxx*3 + id.yyy*16) );
                        col = float3(0.5,0.5,0.6) + 0.4*sin( fid*2.0 + 4.5 + float3(0.0,1.0,1.0) );
                        [flatten]
                        if( Hash(_NoiseTex, fid.xxx*13.1)>0.35 )
                        {
                            col = 1.0 - 0.9*col;
                            col.xy += 0.2;
                        }
                    }
                    
                    cen = float2( -1.0 + float(id.x)*brickW + 0.5*brickW,
                                 1.0 - float(id.y)*brickH - 0.5*brickH );
                }

                return alp;
            }

            float4 pixel_shader (v2f_customrendertexture IN) : SV_TARGET
            {   
                float2 fragCoord = IN.globalTexcoord.xy *
                    float2(_CustomRenderTextureWidth, _CustomRenderTextureHeight);
                float2 uv = (IN.globalTexcoord.xy - 0.5) * 2.0;
                float px = 2.0/_CustomRenderTextureHeight;
                
                //------------------------
                // load game state
                //------------------------
                float2  ballPos   = LoadValue( _StateTex, txBallPosVel ).xy;
                float paddlePos   = LoadValue( _StateTex, txPaddlePos ).x;
                float4 points      = LoadValue( _StateTex, txPoints );
                float4 state      = LoadValue( _StateTex, txState );
                float3  lastHit   = LoadValue( _StateTex, txLastHit ).xyz;
                float4 calibrate = LoadValue( _StateTex, txCalibrate );
                state.y *= 30.0;
                iTime = state.y;
                
                //------------------------
                // draw
                //------------------------
                float3 col = 0..xxx;
                float3 emi = 0..xxx;
                
                // board
                {
                    col = float3(0.12,0.18,0.21)*(1.0-0.4*length( uv ));
                    col *= 1.0 - 0.1*smoothstep( 0.0,1.0,sin(uv.x*80.0)*sin(uv.y*80.0))*(1.0 - smoothstep( 1.0, 1.01, abs(uv.x) ) );
                }

                // face
                if (abs(uv.y + 0.34) < 0.5 && abs(uv.x) < 0.5)
                {
                    float2 faceUv = uv;
                    faceUv.y += 0.34;
                    faceUv = mul(rot2(1.57), faceUv);
                    faceUv += 0.5;
                    faceUv.y = 1.0 - faceUv.y;
                    float2 vigUv = faceUv * (1.0 - faceUv.yx);
                    float vig = (vigUv.x * vigUv.y * 10.0);
                    col = tex2D(_CamIn, faceUv).rgb * vig + col * (1.0 - vig);
                    if (floor(calibrate.x) == CAL_GUIDE ||
                        floor(calibrate.x) == CAL_VAL)
                    {
                        float4 guide = tex2D(_GuideTex, faceUv);
                        col = lerp(col, guide.rgb, guide.a);
                    }
                } 

                // bricks
                {
                    float b = brickW*0.17;

                    // soft shadow
                    {
                        float2 st = uv + shadowOffset;
                        int2 id = int2(floor( float2( (1.0+st.x)/brickW, (1.0-st.y)/brickH) ));

                        float3 bcol; float2 bcen; float bglo;

                        float sha = 0.0;
                        for( int j=-1; j<=1; j++ )
                        {
                            for( int i=-1; i<=1; i++ )
                            {
                                int2 idr = id + int2(i, j );
                                float alp = doBrick( idr, bcol, bglo, bcen );
                                float f = udRoundBox( st, bcen, 0.5*float2(brickW,brickH)-b, b );
                                float s = 1.0 - smoothstep( -brickH*0.5, brickH*1.0, f ); 
                                s = lerp( 0.0, s, alp );
                                sha = max( sha, s );
                            }
                        }
                        col = lerp( col, col*0.4, sha );
                    }
                

                    int2 id = int2(floor( float2( (1.0+uv.x)/brickW, (1.0-uv.y)/brickH) ));
                    
                    // shape
                    {
                        float3 bcol; float2 bcen; float bglo;
                        float alp = doBrick( id, bcol, bglo, bcen );
                        if( alp>0.0001 )
                        {
                            float f = udRoundBox( uv, bcen, 0.5*float2(brickW,brickH)-b, b );
                            bglo  += 0.6*smoothstep( -4.0*px, 0.0, f );

                            bcol *= 0.7 + 0.3*smoothstep( -4.0*px, -2.0*px, f );
                            bcol *= 0.5 + 1.7*bglo;
                            col = lerp( col, bcol, alp*(1.0-smoothstep( -px, px, f )) );
                        }
                    }
                    
                    //gather glow
                    for( int j=-1; j<=1; j++ )
                    {
                        for( int i=-1; i<=1; i++ )
                        {
                            int2 idr = id + int2(i, j );
                            float3 bcol = float3(0, 0, 0); float2 bcen; float bglo;
                            float alp = doBrick( idr, bcol, bglo, bcen );
                            float f = udRoundBox( uv, bcen, 0.5*float2(brickW,brickH)-b, b );
                            emi += bcol*bglo*fastExp(-600.0*f*f);
                        }
                    }
                }    
                
                
                // ball 
                {
                    float hit = fastExp(-4.0*(iTime-lastHit.y) );

                    // shadow
                    float f = 1.0-smoothstep( ballRadius*0.5, ballRadius*2.0, length( uv - ballPos + shadowOffset ) );
                    col = lerp( col, col*0.4, f );

                    // shape
                    f = length( uv - ballPos ) - ballRadius;
                    float3 bcol = float3(1.0,0.6,0.2);
                    bcol *= 1.0 + 0.7*smoothstep( -3.0*px, -1.0*px, f );
                    bcol *= 0.7 + 0.3*hit;
                    col = lerp( col, bcol, 1.0-smoothstep( 0.0, px, f ) );
                    
                    emi  += bcol*0.75*hit*fastExp(-500.0*f*f );
                }
                
                
                // paddle
                {
                    float hit = fastExp(-4.0*(iTime-lastHit.x) ) * sin(20.0*(iTime-lastHit.x));
                    float hit2 = fastExp(-4.0*(iTime-lastHit.x) );
                    float y = uv.y + 0.04*hit * (1.0-pow(abs(uv.x-paddlePos)/(paddleSize*0.5),2.0));

                    // shadow
                    float f = udHorizontalSegment( float2(uv.x,y)+shadowOffset, paddlePos-paddleSize*0.5,paddlePos+paddleSize*0.5,paddlePosY );
                    f = 1.0-smoothstep( paddleWidth*0.5*0.5, paddleWidth*0.5*2.0, f );
                    col = lerp( col, col*0.4, f );

                    // shape
                    f = udHorizontalSegment( float2(uv.x,y), paddlePos-paddleSize*0.5, paddlePos+paddleSize*0.5,paddlePosY ) - paddleWidth*0.5;
                    float3 bcol = float3(1.0,0.6,0.2);
                    bcol *= 1.0 + 0.7*smoothstep( -3.0*px, -1.0*px, f );
                    bcol *= 0.7 + 0.3*hit2;
                    col = lerp( col, bcol, 1.0-smoothstep( -px, px, f ) );
                    emi += bcol*0.75*hit2*fastExp( -500.0*f*f );

                }

                
                // borders
                {
                    float f = abs(abs(uv.x)-1.02);
                    f = min( f, udHorizontalSegment(uv,-1.0,1.0,1.0) );
                    f *= 2.0;
                    float a = 0.8 + 0.2*sin(2.6*iTime) + 0.1*sin(4.0*iTime);
                    float hit  = fastExp(-4.0*(iTime-lastHit.z) );
                    //
                    a *= 1.0-0.3*hit;
                    col += a*0.5*float3(0.6,0.30,0.1)*fastExp(- 30.0*f*f);
                    col += a*0.5*float3(0.6,0.35,0.2)*fastExp(-150.0*f*f);
                    col += a*1.7*float3(0.6,0.50,0.3)*fastExp(-900.0*f*f);
                }
                
                // score
                {
                    float f = float(PrintInt( (uv + float2(0.85, -0.05)) * 18.0, int(points.x), 3 ));
                    col = lerp( col, float3(1.0,1.0,1.0), f );
                }
                
                // add emmission
                col += emi;
                col *= col;

                // col += PrintInt((uv + float2(0.8, 0.0)) * 18.0, abs(points.y * 1000), 4);
                // col += PrintInt((uv + float2(0.8, 0.1)) * 18.0, abs(points.z * 1000), 4);
                // col += PrintInt((uv + float2(0.8, 0.2)) * 18.0, abs(points.w * 1000), 4);
                // col += PrintInt((uv + float2(0.8, 0.3)) * 18.0, abs(paddlePos * 1000), 4);

                return float4(col, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}