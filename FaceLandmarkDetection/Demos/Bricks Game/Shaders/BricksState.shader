﻿Shader "FaceLandmarkDetection/Games/BricksState" {
	Properties {
		_StateTex ("State Input", 2D) = "black" {}
		_ControlIn ("Head Rotation Input", 2D) = "black" {}
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
			Name "Bricks State"
			CGPROGRAM
			#include "UnityCustomRenderTexture.cginc"
			#include "BricksInc.cginc"
			#pragma vertex CustomRenderTextureVertexShader
			#pragma fragment pixel_shader
			#pragma target 5.0

			Texture2D<float4> _StateTex;
			Texture2D<float4> _ControlIn;
            sampler2D _NoiseTex;
			float4 _StateTex_TexelSize;

            RWStructuredBuffer<float4> buffer : register(u1);

            // Created by inigo quilez - iq/2016
            // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

            //
            // Gameplay computation.
            //
            // The gameplay buffer is 14x14 pixels. The whole game is run/played for each one of these
            // pixels. A filter in the end of the shader takes only the bit  of infomration that needs 
            // to be stored in each texl of the game-logic texture.

            #define gameSpeed    8.0
            #define inputSpeed   6.0

            #define iFrame state.y
            #define iTime state.y
            #define iTimeDelta 0.01
            //----------------------------------------------------------------------------------------------

            void StoreValue4( in int4 re, in int4 va, inout int4 fragColor, in int2 p )
            {
                fragColor = ( p.x>=re.x && p.y>=re.y && p.x<=re.z && p.y<=re.w ) ? va : fragColor;
            }

            // intersect a disk sweept in a linear segment with a line/plane. 
            float iPlane( in float2 ro, in float2 rd, float rad, float3 pla )
            {
                float a = dot( rd, pla.xy );
                if( a>0.0 ) return -1.0;
                float t = (rad - pla.z - dot(ro,pla.xy)) / a;
                //if( t>=1.0 ) t=-1.0;
                t = ( t>=1.0 ) ? -1.0 : t;
                return t;
            }

            // intersect a disk sweept in a linear segment with a box 
            float3 iBox( in float2 ro, in float2 rd, in float rad, in float2 bce, in float2 bwi ) 
            {
                float2 m = 1.0/rd;
                float2 n = m*(ro - bce);
                float2 k = abs(m)*(bwi+rad);
                float2 t1 = -n - k;
                float2 t2 = -n + k;
            	float tN = max( t1.x, t1.y );
            	float tF = min( t2.x, t2.y );
            	if( tN > tF || tF < 0.0) return -1.0.xxx;
                if( tN>=1.0 ) return -1.0.xxx;
            	float2 nor = -sign(rd)*step(t1.yx,t1.xy);
            	return float3( tN, nor );
            }

            //----------------------------------------------------------------------------------------------

			float4 pixel_shader (v2f_customrendertexture IN) : SV_TARGET
			{	
				float2 uv = IN.globalTexcoord.xy;
				int2 fragCoord = int2(uv * _StateTex_TexelSize.zw);
                float4 fragColor = 0..xxxx;
                //---------------------------------------------------------------------------------   
                // load game state.x
                //---------------------------------------------------------------------------------
                float4 balPosVel = LoadValue( _StateTex, txBallPosVel );
                float  paddlePos = LoadValue( _StateTex, txPaddlePos ).x;
                float  points    = LoadValue( _StateTex, txPoints ).x;
                float4 state     = LoadValue( _StateTex, txState );
                float3 lastHit   = LoadValue( _StateTex, txLastHit ).xyz;        // paddle, brick, wall
                float2 brick     = LoadValue( _StateTex, fragCoord ).xy;               // visible, hittime

                float3x3 look = 0.0;

                for (uint i = 0; i < 6; i++)
                {
                    look[0] += _ControlIn[uint2(0, i)];
                    look[1] += _ControlIn[uint2(1, i)];
                    look[2] += _ControlIn[uint2(2, i)];
                }
                look *= 0.1667;

                float angX = atan2(look[2][1], look[2][2]);
                // float angY = atan2(-look[2][0],
                //     sqrt(look[2][1] * look[2][1] + look[2][2] * look[2][2]));
                float angZ = atan2(look[1][0], look[0][0]);

                //buffer[0] = float4(angX, angY, angZ, 1.0);

                //---------------------------------------------------------------------------------
                // reset
                //---------------------------------------------------------------------------------
                
                bool reset = angX < -0.4;
                state.y = reset ? 0.0 : state.y + unity_DeltaTime.x;
                state.y = state.y + unity_DeltaTime.x;

                if( iFrame < 1 ) state.x = -1.0;
                
                if( state.x < -0.5 )
                {
                    state.x = 0.0;
                    balPosVel = float4(0.0,paddlePosY+ballRadius+paddleWidth*0.5+0.001, 0.6,1.0);
                    paddlePos = 0.0;
                    points = 0.0;
                    state.x = 0.0;
                    brick = float2(1.0,-5.0);
                    lastHit = -1.0.xxx;
                    
                    
                    if( fragCoord.x<1.0 || fragCoord.x>12.0 )
                    {
                        brick.x = 0.0;
                        brick.y = -10.0;
                    }
                }

                //---------------------------------------------------------------------------------
                // do game
                //---------------------------------------------------------------------------------

                // game over (or won), wait for space key press to resume
                if( state.x > 0.5 )
                {
                    state.x = reset ? -1.0 : state.x;
                }
                
                // if game mode (not game over), play game
                else if( state.x < 0.5 ) 
                {

                    //-------------------
                    // paddle
                    //-------------------
                    float oldPaddlePos = paddlePos;

                    // move with head rotation
                    paddlePos += 0.02*inputSpeed*angZ;

                    paddlePos = clamp( paddlePos, -1.0+0.5*paddleSize+paddleWidth*0.5, 1.0-0.5*paddleSize-paddleWidth*0.5 );

                    float moveTotal = sign( paddlePos - oldPaddlePos );

                    //-------------------
                    // ball
                    //-------------------
                    float dis = 0.01*gameSpeed*(iTimeDelta*60.0);
                    
                    // do up to 3 sweep collision detections (usually 0 or 1 will happen only)
                    for( int k=0; k<3; k++ )
                    {
                        int3 oid = int3(-1, -1, -1);
                        float2 nor;
                        float t = 1000.0;

                        // test walls
                        const float3 pla1 = float3(-1.0, 0.0,1.0 ); 
                        const float3 pla2 = float3( 1.0, 0.0,1.0 ); 
                        const float3 pla3 = float3( 0.0,-1.0,1.0 ); 
                        float t1 = iPlane( balPosVel.xy, dis*balPosVel.zw, ballRadius, pla1 ); if( t1>0.0         ) { t=t1; nor = pla1.xy; oid.x=1; }
                        float t2 = iPlane( balPosVel.xy, dis*balPosVel.zw, ballRadius, pla2 ); if( t2>0.0 && t2<t ) { t=t2; nor = pla2.xy; oid.x=2; }
                        float t3 = iPlane( balPosVel.xy, dis*balPosVel.zw, ballRadius, pla3 ); if( t3>0.0 && t3<t ) { t=t3; nor = pla3.xy; oid.x=3; }
                        
                        // test paddle
                        float3  t4 = iBox( balPosVel.xy, dis*balPosVel.zw, ballRadius, float2(paddlePos,paddlePosY), float2(paddleSize*0.5,paddleWidth*0.5) );

                        if( t4.x>0.0 && t4.x<t ) { t=t4.x; nor = t4.yz; oid.x=4;  }
                        
                        // test bricks
                        int2 idr = int2(floor( float2( (1.0+balPosVel.x)/brickW, (1.0-balPosVel.y)/brickH) ));
                        int2 vs = int2(sign(balPosVel.zw));

                        for( int j=0; j<3; j++ )
                        for( int i=0; i<3; i++ )
                        {
                            int2 id = idr + int2( vs.x*i,-vs.y*j);
                            if( id.x>=0 && id.x<13 && id.y>=0 && id.y<12 )
                            {
                                float brickHere = _StateTex.Load(int3(txBricks.xy+id, 0) ).x;
                                if( brickHere>0.5 )
                                {
                                    float2 ce = float2( -1.0 + float(id.x)*brickW + 0.5*brickW,
                                                     1.0 - float(id.y)*brickH - 0.5*brickH );
                                    float3 t5 = iBox( balPosVel.xy, dis*balPosVel.zw, ballRadius, ce, 0.5*float2(brickW,brickH) );
                                    if( t5.x>0.0 && t5.x<t )
                                    {
                                        oid = int3(5,id);
                                        t = t5.x;
                                        nor = t5.yz;
                                    }
                                }
                            }
                        }
                
                        // no collisions
                        if( oid.x<0 ) break;

                        
                        // bounce
                        balPosVel.xy += t*dis*balPosVel.zw;
                        dis *= 1.0-t;
                        
                        // did hit walls
                        if( oid.x<4 )
                        {
                            balPosVel.zw = reflect( balPosVel.zw, nor );
                            lastHit.z = iTime;
                        }
                        // did hit paddle
                        else if( oid.x<5 )
                        {
                            balPosVel.zw = reflect( balPosVel.zw, nor );
                            // borders bounce back
                                 if( balPosVel.x > (paddlePos+paddleSize*0.5) ) balPosVel.z =  abs(balPosVel.z);
                            else if( balPosVel.x < (paddlePos-paddleSize*0.5) ) balPosVel.z = -abs(balPosVel.z);
                            balPosVel.z += 0.37*moveTotal;
                            balPosVel.z += 0.11*Hash( _NoiseTex, iFrame.xxx*0.01 );
                            balPosVel.z = clamp( balPosVel.z, -0.9, 0.9 );
                            balPosVel.zw = normalize(balPosVel.zw);
                            
                            // 
                            lastHit.x = iTime;
                            lastHit.y = iTime;
                        }
                        // did hit a brick
                        else if( oid.x<6 )
                        {
                            balPosVel.zw = reflect( balPosVel.zw, nor );
                            lastHit.y = iTime;
                            points += 1.0;
                            if( points>143.5 )
                            {
                                state.x = 2.0; // won game!
                            }

                            if( all(fragCoord == (txBricks.xy+oid.yz)) )
                            {
                                brick = float2(0.0, iTime);
                            }
                        }
                    }
                    
                    balPosVel.xy += dis*balPosVel.zw;
                    
                    // detect miss
                    state.x = balPosVel.y<-1.0 ? 1.0 : state.x; // game over
                }
                
                //---------------------------------------------------------------------------------
                // store game state.x
                //---------------------------------------------------------------------------------

                StoreValue4( txBricks,     float4(brick,0.0,0.0),         fragColor, fragCoord );
                StoreValue ( txBallPosVel, balPosVel,                     fragColor, fragCoord );
                StoreValue ( txPaddlePos,  float4(paddlePos,0.0,0.0,0.0), fragColor, fragCoord );
                StoreValue ( txPoints,     float4(points,0.0,0.0,0.0),    fragColor, fragCoord );
                StoreValue ( txState,      state,                         fragColor, fragCoord );
                StoreValue ( txLastHit,    float4(lastHit,0.0),           fragColor, fragCoord );
                return fragColor;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}