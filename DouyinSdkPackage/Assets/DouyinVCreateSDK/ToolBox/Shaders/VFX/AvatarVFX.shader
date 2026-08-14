// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Douyin/Avatar/VFX/AvatarVFX"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[Enum(Add,1,Blend,10)]_Blend_Mode("Blend_Mode", Float) = 10
		_Float19("Depth_Fade", Range( 0 , 10)) = 0
		[Header(___________________Base_________________________________________________________________________________________)]_BaseTex_Strength("BaseTex_Strength", Range( 1 , 5)) = 1
		_Float24("RGB_Offset", Range( -1 , 1)) = 0
		_Float3("Desaturate", Range( 0 , 1)) = 0
		[HDR]_Base_Tex_Color("Base_Tex_Color", Color) = (1,1,1,1)
		_Texturemm("Base_Tex", 2D) = "white" {}
		[Toggle(_KEYWORD9_ON)] _Keyword9("Open_Once_UV", Float) = 0
		_Float4("Base_Tex_Rotation", Float) = 0
		_BaseTex_U_Speed("BaseTex_U_Speed", Float) = 0
		_BaseTex_V_Speed("BaseTex_V_Speed", Float) = 0
		_TextureSample7("Base_Tex2", 2D) = "white" {}
		_Float45("Base_Tex2_Rotation", Float) = 0
		_Float39("Base_Tex2_U_Speed", Float) = 0
		_Float43("Base_Tex2_V_Speed", Float) = 0
		_Mask_Tex("Mask_Tex", 2D) = "white" {}
		_Float7("Mask_Tex_Rotation", Float) = 0
		[Header(___________________Disturbance_________________________________________________________________________________________)]_TextureSample0("Disturbance_Tex", 2D) = "white" {}
		_Disturbance_Tex_Rotation("Disturbance_Tex_Rotation", Float) = 0
		_Float0("Disturbance_U_Strength", Float) = 0
		_Float1("Disturbance_V_Strength", Float) = 0
		_Disturbance_Tex_U_Speed("Disturbance_Tex_U_Speed", Float) = 0
		_Disturbance_Tex_V_Speed("Disturbance_Tex_V_Speed", Float) = 0
		[Toggle(_KEYWORD5_ON)] _Keyword5("Open_Two_Disturbance", Float) = 0
		_TextureSample6("Disturbance_Tex2", 2D) = "white" {}
		_Float26("Disturbance_Tex2_Rotation", Float) = 0
		_Float23("Disturbance2_U_Strength", Float) = 0
		_Float25("Disturbance2_V_Strength", Float) = 0
		_Float28("Disturbance_Tex2_U_Speed", Float) = 0
		_Float29("Disturbance_Tex2_V_Speed", Float) = 0
		[Header(___________________Color_Mapping_______________________________________________________________________________________________)][Toggle(_KEYWORD0_ON)] _Keyword0("Open_ColorMapping", Float) = 0
		[KeywordEnum(Color,Texture)] _Keyword2("Color_Mapping_Mode", Float) = 1
		_Float8("Color_Mapping_Strength", Range( 0 , 1)) = 0
		_TextureSample1("Color_Mapping_Tex", 2D) = "white" {}
		_Color0("Color 0", Color) = (1,1,1,1)
		_Color1("Color 1", Color) = (1,1,1,1)
		[Header(___________________Dissolve_______________________________________________________________________________________________)][Toggle(_KEYWORD3_ON)] _Keyword3("Dissolve_Custom", Float) = 0
		[KeywordEnum(Soft,Hard)] _Keyword4("Dissolve_Mode", Float) = 0
		_TextureSample2("Dissolve_Tex", 2D) = "white" {}
		[Toggle(_KEYWORD1_ON)] _Keyword1("Dissolve_Tex_OneMinus", Float) = 0
		_Float12("Dissolve_Tex_Rotation", Float) = 0
		_Float11("Dissolve_Tex_Power", Range( 0 , 5)) = 1
		_Float10("Dissolve_Tex_Strength", Float) = 0
		_Dissolve_Tex_U_Speed("Dissolve_Tex_U_Speed", Float) = 0
		_Dissolve_Tex_V_Speed("Dissolve_Tex_V_Speed", Float) = 0
		_Float14("Dissolve_Edge_Size", Range( 0 , 0.1)) = 0
		[HDR]_Color2("Dissolve_Edge_Color", Color) = (1,1,1,1)
		_Float20("Disslve_Following_Distort1_U", Range( 0 , 1)) = 0
		_Float21("Disslve_Following_Distort1_V", Range( 0 , 1)) = 0
		_Float32("Disslve_Following_Distort2_U", Range( 0 , 1)) = 0
		_Float33("Disslve_Following_Distort2_V", Range( 0 , 1)) = 0
		[Header(___________________Fresnel_______________________________________________________________________________________________)]_Fresnel_Strength("Fresnel_Strength", Range( 0 , 1)) = 0
		[Toggle(_KEYWORD6_ON)] _Keyword6("Fresnel_Hard_Edge", Float) = 0
		[HDR]_Color3("Fresnel_Edge_Color", Color) = (1,1,1,1)
		_Float34("Fresnel_Edge_Size", Float) = 1
		_Float75("Fresnel_Centre_Size", Range( 0 , 1)) = 0
		_TextureSample8("Fresnel_Tex", 2D) = "white" {}
		_Vector11("Fresnel_Tex_UV_Speed", Vector) = (0,0,0,0)
		[Header(___________________Model_______________________________________________________________________________________________)]_Open_Model_Softedge("Open_Model_Softedge", Range( 0 , 1)) = 0
		_Float78("Model_Softedge_Strength", Range( 1 , 5)) = 1
		[Header(___________________Vertex_______________________________________________________________________________________________)]_Vertex_Offset_Strength("Vertex_Offset_Strength", Range( 0 , 1)) = 0
		_Vertex_Offset_XYZ("Vertex_Offset_X&Y&Z", Vector) = (0,0,0,0)
		_TextureSample13("Vertex_Tex", 2D) = "white" {}
		_Vector8("Vertex_Offset_X&Y&Z_Strength", Vector) = (0,0,0,0)
		_Float68("Vertex_Tex_Rotation", Float) = 0
		_Float67("Vertex_Tex_U_Speed", Float) = 0
		_Float64("Vertex_Tex_V_Speed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[HideInInspector] _CullMode("Cull Mode", Float) = 2
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull [_CullMode]
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		#pragma prefer_hlslcc gles
		#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal vulkan 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha [_Blend_Mode], One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _KEYWORD0_ON
			#pragma shader_feature_local _KEYWORD5_ON
			#pragma shader_feature_local _KEYWORD9_ON
			#pragma shader_feature_local _KEYWORD2_COLOR _KEYWORD2_TEXTURE
			#pragma shader_feature_local _KEYWORD4_SOFT _KEYWORD4_HARD
			#pragma shader_feature_local _KEYWORD1_ON
			#pragma shader_feature_local _KEYWORD3_ON
			#pragma shader_feature_local _KEYWORD6_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color1;
			float4 _Texturemm_ST;
			float4 _Color2;
			float4 _TextureSample6_ST;
			float4 _Color0;
			half4 _Color3;
			float4 _TextureSample0_ST;
			float4 _TextureSample7_ST;
			float4 _TextureSample8_ST;
			float4 _Mask_Tex_ST;
			float4 _TextureSample2_ST;
			float4 _TextureSample1_ST;
			float4 _TextureSample13_ST;
			float4 _Base_Tex_Color;
			half3 _Vertex_Offset_XYZ;
			half3 _Vector8;
			half2 _Vector11;
			half _Dissolve_Tex_U_Speed;
			half _Float33;
			half _Float20;
			float _BaseTex_Strength;
			half _Float32;
			half _Float21;
			half _Float34;
			half _Float12;
			half _Float14;
			half _Float10;
			half _Float75;
			half _Fresnel_Strength;
			half _Float7;
			half _Float11;
			half _Float19;
			half _Dissolve_Tex_V_Speed;
			float _Blend_Mode;
			half _Float24;
			half _Float3;
			half _Float67;
			half _Float64;
			half _Float68;
			half _Vertex_Offset_Strength;
			half _Float39;
			half _Float0;
			half _Disturbance_Tex_U_Speed;
			half _Disturbance_Tex_V_Speed;
			half _Disturbance_Tex_Rotation;
			float _Float23;
			half _Float28;
			half _Float29;
			float _Float26;
			float _Float25;
			half _Float1;
			half _Float43;
			half _Float45;
			half _BaseTex_U_Speed;
			half _BaseTex_V_Speed;
			half _Float4;
			half _Open_Model_Softedge;
			half _Float8;
			half _Float78;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			CBUFFER_START(AvatarLightingPreFrame)
				half4 _MainLightPosition2;
				half4 _MainLightColor2;			// x,y,z : ��ʶ̫������ɫ
				half _SliptEnvmentConfig;
			CBUFFER_END

			float4 GetMainLightDir()
			{
				return _MainLightColor2.a <= 0.001 ? _MainLightPosition : _MainLightPosition2;
			}

			float4 GetMainLightColor()
			{
				return _MainLightColor2.a <= 0.001 ? _MainLightColor : _MainLightColor2;
			}

			float GetEnvSplitFlag()
			{
				return _SliptEnvmentConfig;
			}
			sampler2D _TextureSample13;
			sampler2D _TextureSample7;
			sampler2D _TextureSample0;
			sampler2D _TextureSample6;
			sampler2D _Texturemm;
			sampler2D _TextureSample1;
			sampler2D _TextureSample2;
			sampler2D _TextureSample8;
			sampler2D _Mask_Tex;
			uniform float4 _CameraDepthTexture_TexelSize;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_TextureSample13 = v.ase_texcoord.xy * _TextureSample13_ST.xy + _TextureSample13_ST.zw;
				float2 break432 = uv_TextureSample13;
				float2 appendResult445 = (float2(( break432.x + frac( ( _Float67 * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Float64 ) ) + break432.y )));
				float cos448 = cos( ( ( _Float68 * PI ) / 180.0 ) );
				float sin448 = sin( ( ( _Float68 * PI ) / 180.0 ) );
				float2 rotator448 = mul( appendResult445 - half2( 0.5,0.5 ) , float2x2( cos448 , -sin448 , sin448 , cos448 )) + half2( 0.5,0.5 );
				float4 tex2DNode462 = tex2Dlod( _TextureSample13, float4( rotator448, 0, 0.0) );
				float3 appendResult457 = (float3(( _Vector8.x * tex2DNode462.r ) , ( tex2DNode462.r * _Vector8.y ) , ( tex2DNode462.r * _Vector8.z )));
				float3 VertexOffset464 = ( ( ( v.ase_normal * appendResult457 ) + _Vertex_Offset_XYZ ) * _Vertex_Offset_Strength );
				
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset464;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float3 appendResult10 = (float3(_Base_Tex_Color.r , _Base_Tex_Color.g , _Base_Tex_Color.b));
				float2 uv_TextureSample7 = IN.ase_texcoord3.xy * _TextureSample7_ST.xy + _TextureSample7_ST.zw;
				float2 break366 = uv_TextureSample7;
				float2 uv_TextureSample0 = IN.ase_texcoord3.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float2 appendResult96 = (float2(( uv_TextureSample0.x + frac( ( _Disturbance_Tex_U_Speed * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Disturbance_Tex_V_Speed ) ) + uv_TextureSample0.y )));
				float cos216 = cos( ( ( _Disturbance_Tex_Rotation * PI ) / 180.0 ) );
				float sin216 = sin( ( ( _Disturbance_Tex_Rotation * PI ) / 180.0 ) );
				float2 rotator216 = mul( appendResult96 - half2( 0.5,0.5 ) , float2x2( cos216 , -sin216 , sin216 , cos216 )) + half2( 0.5,0.5 );
				float4 tex2DNode74 = tex2D( _TextureSample0, rotator216 );
				float temp_output_76_0 = ( _Float0 * tex2DNode74.r );
				float raodongU223 = temp_output_76_0;
				float2 uv_TextureSample6 = IN.ase_texcoord3.xy * _TextureSample6_ST.xy + _TextureSample6_ST.zw;
				float2 appendResult277 = (float2(( uv_TextureSample6.x + frac( ( _Float28 * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Float29 ) ) + uv_TextureSample6.y )));
				float cos261 = cos( ( ( _Float26 * PI ) / 180.0 ) );
				float sin261 = sin( ( ( _Float26 * PI ) / 180.0 ) );
				float2 rotator261 = mul( appendResult277 - float2( 0.5,0.5 ) , float2x2( cos261 , -sin261 , sin261 , cos261 )) + float2( 0.5,0.5 );
				float4 tex2DNode254 = tex2D( _TextureSample6, rotator261 );
				#ifdef _KEYWORD5_ON
				float staticSwitch420 = ( _Float23 * tex2DNode254.r );
				#else
				float staticSwitch420 = 0.0;
				#endif
				float raodong2U280 = staticSwitch420;
				#ifdef _KEYWORD5_ON
				float staticSwitch421 = ( tex2DNode254.g * _Float25 );
				#else
				float staticSwitch421 = 0.0;
				#endif
				float raodong2V281 = staticSwitch421;
				float temp_output_78_0 = ( tex2DNode74.r * _Float1 );
				float raodongV224 = temp_output_78_0;
				float2 appendResult396 = (float2(( ( ( break366.x + frac( ( _Float39 * _TimeParameters.x ) ) ) + raodongU223 ) + raodong2U280 ) , ( raodong2V281 + ( raodongV224 + ( frac( ( _TimeParameters.x * _Float43 ) ) + break366.y ) ) )));
				float cos399 = cos( ( ( _Float45 * PI ) / 180.0 ) );
				float sin399 = sin( ( ( _Float45 * PI ) / 180.0 ) );
				float2 rotator399 = mul( appendResult396 - half2( 0.5,0.5 ) , float2x2( cos399 , -sin399 , sin399 , cos399 )) + half2( 0.5,0.5 );
				float3 BaseTex2416 = (tex2D( _TextureSample7, rotator399 )).rgb;
				float2 uv_Texturemm = IN.ase_texcoord3.xy * _Texturemm_ST.xy + _Texturemm_ST.zw;
				float2 break251 = uv_Texturemm;
				float4 texCoord346 = IN.ase_texcoord4;
				texCoord346.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch347 = ( texCoord346.z + break251.x );
				#else
				float staticSwitch347 = break251.x;
				#endif
				float temp_output_50_0 = ( staticSwitch347 + frac( ( _BaseTex_U_Speed * _TimeParameters.x ) ) );
				float clampResult354 = clamp( temp_output_50_0 , 0.0 , 1.0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch352 = clampResult354;
				#else
				float staticSwitch352 = temp_output_50_0;
				#endif
				#ifdef _KEYWORD9_ON
				float staticSwitch349 = ( break251.y + texCoord346.w );
				#else
				float staticSwitch349 = break251.y;
				#endif
				float temp_output_54_0 = ( frac( ( _TimeParameters.x * _BaseTex_V_Speed ) ) + staticSwitch349 );
				float clampResult355 = clamp( temp_output_54_0 , 0.0 , 1.0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch353 = clampResult355;
				#else
				float staticSwitch353 = temp_output_54_0;
				#endif
				float2 appendResult40 = (float2(( ( staticSwitch352 + raodong2U280 ) + temp_output_76_0 ) , ( temp_output_78_0 + ( staticSwitch353 + raodong2V281 ) )));
				float cos100 = cos( ( ( _Float4 * PI ) / 180.0 ) );
				float sin100 = sin( ( ( _Float4 * PI ) / 180.0 ) );
				float2 rotator100 = mul( appendResult40 - half2( 0.5,0.5 ) , float2x2( cos100 , -sin100 , sin100 , cos100 )) + half2( 0.5,0.5 );
				float temp_output_239_0 = ( 0.1 * _Float24 );
				float4 tex2DNode248 = tex2D( _Texturemm, rotator100 );
				float2 temp_cast_0 = (temp_output_239_0).xx;
				float4 appendResult232 = (float4(tex2D( _Texturemm, ( rotator100 + temp_output_239_0 ) ).r , tex2DNode248.g , tex2D( _Texturemm, ( rotator100 - temp_cast_0 ) ).b , tex2DNode248.a));
				float4 break238 = appendResult232;
				float3 appendResult12 = (float3(break238.x , break238.y , break238.z));
				float3 desaturateInitialColor98 = ( BaseTex2416 * appendResult12 );
				float desaturateDot98 = dot( desaturateInitialColor98, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar98 = lerp( desaturateInitialColor98, desaturateDot98.xxx, _Float3 );
				float3 temp_output_13_0 = ( appendResult10 * desaturateVar98 );
				float2 uv_TextureSample1 = IN.ase_texcoord3.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
				float2 texCoord157 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#if defined(_KEYWORD2_COLOR)
				float3 staticSwitch160 = ( ( (_Color0).rgb * ( 1.0 - texCoord157.x ) ) + ( texCoord157.x * (_Color1).rgb ) );
				#elif defined(_KEYWORD2_TEXTURE)
				float3 staticSwitch160 = (tex2D( _TextureSample1, uv_TextureSample1 )).rgb;
				#else
				float3 staticSwitch160 = (tex2D( _TextureSample1, uv_TextureSample1 )).rgb;
				#endif
				float3 blendOpSrc116 = staticSwitch160;
				float3 blendOpDest116 = temp_output_13_0;
				float3 lerpBlendMode116 = lerp(blendOpDest116,( blendOpSrc116 * blendOpDest116 ),_Float8);
				#ifdef _KEYWORD0_ON
				float3 staticSwitch120 = lerpBlendMode116;
				#else
				float3 staticSwitch120 = temp_output_13_0;
				#endif
				float3 temp_cast_1 = (0.0).xxx;
				float3 temp_cast_2 = (0.0).xxx;
				float2 uv_TextureSample2 = IN.ase_texcoord3.xy * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
				float2 appendResult138 = (float2(( ( ( uv_TextureSample2.x + frac( ( _Dissolve_Tex_U_Speed * _TimeParameters.x ) ) ) + ( raodongU223 * _Float20 ) ) + ( raodong2U280 * _Float32 ) ) , ( ( _Float33 * raodong2V281 ) + ( ( _Float21 * raodongV224 ) + ( frac( ( _TimeParameters.x * _Dissolve_Tex_V_Speed ) ) + uv_TextureSample2.y ) ) )));
				float cos140 = cos( ( ( _Float12 * PI ) / 180.0 ) );
				float sin140 = sin( ( ( _Float12 * PI ) / 180.0 ) );
				float2 rotator140 = mul( appendResult138 - half2( 0.5,0.5 ) , float2x2( cos140 , -sin140 , sin140 , cos140 )) + half2( 0.5,0.5 );
				float4 tex2DNode121 = tex2D( _TextureSample2, rotator140 );
				#ifdef _KEYWORD1_ON
				float staticSwitch132 = ( 1.0 - tex2DNode121.r );
				#else
				float staticSwitch132 = tex2DNode121.r;
				#endif
				float4 texCoord165 = IN.ase_texcoord4;
				texCoord165.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _KEYWORD3_ON
				float staticSwitch166 = texCoord165.x;
				#else
				float staticSwitch166 = _Float10;
				#endif
				float temp_output_195_0 = ( 1.0 - step( ( staticSwitch132 + _Float14 ) , staticSwitch166 ) );
				#if defined(_KEYWORD4_SOFT)
				float3 staticSwitch423 = temp_cast_1;
				#elif defined(_KEYWORD4_HARD)
				float3 staticSwitch423 = ( break238.w * ( saturate( ( temp_output_195_0 - ( 1.0 - step( staticSwitch132 , staticSwitch166 ) ) ) ) * (_Color2).rgb ) );
				#else
				float3 staticSwitch423 = temp_cast_1;
				#endif
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult303 = dot( ase_worldNormal , ase_worldViewDir );
				float fresnel310 = ( saturate( pow( abs( ( 1.0 - dotResult303 ) ) , _Float34 ) ) + _Float75 );
				#ifdef _KEYWORD6_ON
				float staticSwitch330 = step( 0.1 , fresnel310 );
				#else
				float staticSwitch330 = fresnel310;
				#endif
				float3 appendResult328 = (float3(_Color3.r , _Color3.g , _Color3.b));
				float2 uv_TextureSample8 = IN.ase_texcoord3.xy * _TextureSample8_ST.xy + _TextureSample8_ST.zw;
				float2 panner314 = ( _TimeParameters.x * _Vector11 + uv_TextureSample8);
				float3 OpenFresnel334 = ( staticSwitch330 * appendResult328 * tex2D( _TextureSample8, panner314 ).r * _Fresnel_Strength );
				
				float2 uv_Mask_Tex = IN.ase_texcoord3.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
				float cos109 = cos( ( ( _Float7 * PI ) / 180.0 ) );
				float sin109 = sin( ( ( _Float7 * PI ) / 180.0 ) );
				float2 rotator109 = mul( uv_Mask_Tex - half2( 0.5,0.5 ) , float2x2( cos109 , -sin109 , sin109 , cos109 )) + half2( 0.5,0.5 );
				#if defined(_KEYWORD4_SOFT)
				float staticSwitch422 = ( break238.w * pow( abs( ( staticSwitch132 + 1.0 + ( staticSwitch166 * -2.0 ) ) ) , _Float11 ) );
				#elif defined(_KEYWORD4_HARD)
				float staticSwitch422 = temp_output_195_0;
				#else
				float staticSwitch422 = ( break238.w * pow( abs( ( staticSwitch132 + 1.0 + ( staticSwitch166 * -2.0 ) ) ) , _Float11 ) );
				#endif
				float clampResult127 = clamp( staticSwitch422 , 0.0 , 1.0 );
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth217 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth217 = abs( ( screenDepth217 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Float19 ) );
				float clampResult219 = clamp( distanceDepth217 , 0.0 , 1.0 );
				float smoothstepResult339 = smoothstep( 0.15 , 1.0 , dotResult303);
				float oneminusfresnel341 = pow( smoothstepResult339 , _Float78 );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( ( staticSwitch120 * (IN.ase_color).rgb ) * _BaseTex_Strength ) + staticSwitch423 + OpenFresnel334 );
				float Alpha = ( ( IN.ase_color.a * _Base_Tex_Color.a * break238.w ) * tex2D( _Mask_Tex, rotator109 ).r * clampResult127 * clampResult219 * saturate( ( ( 1.0 - _Open_Model_Softedge ) + oneminusfresnel341 ) ) );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef _ALPHAACTOR_ON
					clip( Alpha - 0.05 );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#pragma multi_compile_instancing
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#pragma shader_feature_local _KEYWORD9_ON
			#pragma shader_feature_local _KEYWORD5_ON
			#pragma shader_feature_local _KEYWORD4_SOFT _KEYWORD4_HARD
			#pragma shader_feature_local _KEYWORD1_ON
			#pragma shader_feature_local _KEYWORD3_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Color1;
			float4 _Texturemm_ST;
			float4 _Color2;
			float4 _TextureSample6_ST;
			float4 _Color0;
			half4 _Color3;
			float4 _TextureSample0_ST;
			float4 _TextureSample7_ST;
			float4 _TextureSample8_ST;
			float4 _Mask_Tex_ST;
			float4 _TextureSample2_ST;
			float4 _TextureSample1_ST;
			float4 _TextureSample13_ST;
			float4 _Base_Tex_Color;
			half3 _Vertex_Offset_XYZ;
			half3 _Vector8;
			half2 _Vector11;
			half _Dissolve_Tex_U_Speed;
			half _Float33;
			half _Float20;
			float _BaseTex_Strength;
			half _Float32;
			half _Float21;
			half _Float34;
			half _Float12;
			half _Float14;
			half _Float10;
			half _Float75;
			half _Fresnel_Strength;
			half _Float7;
			half _Float11;
			half _Float19;
			half _Dissolve_Tex_V_Speed;
			float _Blend_Mode;
			half _Float24;
			half _Float3;
			half _Float67;
			half _Float64;
			half _Float68;
			half _Vertex_Offset_Strength;
			half _Float39;
			half _Float0;
			half _Disturbance_Tex_U_Speed;
			half _Disturbance_Tex_V_Speed;
			half _Disturbance_Tex_Rotation;
			float _Float23;
			half _Float28;
			half _Float29;
			float _Float26;
			float _Float25;
			half _Float1;
			half _Float43;
			half _Float45;
			half _BaseTex_U_Speed;
			half _BaseTex_V_Speed;
			half _Float4;
			half _Open_Model_Softedge;
			half _Float8;
			half _Float78;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			CBUFFER_START(AvatarLightingPreFrame)
				half4 _MainLightPosition2;
				half4 _MainLightColor2;			// x,y,z : ��ʶ̫������ɫ
				half _SliptEnvmentConfig;
			CBUFFER_END

			float4 GetMainLightDir()
			{
				return _MainLightColor2.a <= 0.001 ? _MainLightPosition : _MainLightPosition2;
			}

			float4 GetMainLightColor()
			{
				return _MainLightColor2.a <= 0.001 ? _MainLightColor : _MainLightColor2;
			}

			float GetEnvSplitFlag()
			{
				return _SliptEnvmentConfig;
			}
			sampler2D _TextureSample13;
			sampler2D _Texturemm;
			sampler2D _TextureSample6;
			sampler2D _TextureSample0;
			sampler2D _Mask_Tex;
			sampler2D _TextureSample2;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 uv_TextureSample13 = v.ase_texcoord.xy * _TextureSample13_ST.xy + _TextureSample13_ST.zw;
				float2 break432 = uv_TextureSample13;
				float2 appendResult445 = (float2(( break432.x + frac( ( _Float67 * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Float64 ) ) + break432.y )));
				float cos448 = cos( ( ( _Float68 * PI ) / 180.0 ) );
				float sin448 = sin( ( ( _Float68 * PI ) / 180.0 ) );
				float2 rotator448 = mul( appendResult445 - half2( 0.5,0.5 ) , float2x2( cos448 , -sin448 , sin448 , cos448 )) + half2( 0.5,0.5 );
				float4 tex2DNode462 = tex2Dlod( _TextureSample13, float4( rotator448, 0, 0.0) );
				float3 appendResult457 = (float3(( _Vector8.x * tex2DNode462.r ) , ( tex2DNode462.r * _Vector8.y ) , ( tex2DNode462.r * _Vector8.z )));
				float3 VertexOffset464 = ( ( ( v.ase_normal * appendResult457 ) + _Vertex_Offset_XYZ ) * _Vertex_Offset_Strength );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				
				o.ase_color = v.ase_color;
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				o.ase_texcoord3 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = VertexOffset464;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_Texturemm = IN.ase_texcoord2.xy * _Texturemm_ST.xy + _Texturemm_ST.zw;
				float2 break251 = uv_Texturemm;
				float4 texCoord346 = IN.ase_texcoord3;
				texCoord346.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch347 = ( texCoord346.z + break251.x );
				#else
				float staticSwitch347 = break251.x;
				#endif
				float temp_output_50_0 = ( staticSwitch347 + frac( ( _BaseTex_U_Speed * _TimeParameters.x ) ) );
				float clampResult354 = clamp( temp_output_50_0 , 0.0 , 1.0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch352 = clampResult354;
				#else
				float staticSwitch352 = temp_output_50_0;
				#endif
				float2 uv_TextureSample6 = IN.ase_texcoord2.xy * _TextureSample6_ST.xy + _TextureSample6_ST.zw;
				float2 appendResult277 = (float2(( uv_TextureSample6.x + frac( ( _Float28 * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Float29 ) ) + uv_TextureSample6.y )));
				float cos261 = cos( ( ( _Float26 * PI ) / 180.0 ) );
				float sin261 = sin( ( ( _Float26 * PI ) / 180.0 ) );
				float2 rotator261 = mul( appendResult277 - float2( 0.5,0.5 ) , float2x2( cos261 , -sin261 , sin261 , cos261 )) + float2( 0.5,0.5 );
				float4 tex2DNode254 = tex2D( _TextureSample6, rotator261 );
				#ifdef _KEYWORD5_ON
				float staticSwitch420 = ( _Float23 * tex2DNode254.r );
				#else
				float staticSwitch420 = 0.0;
				#endif
				float raodong2U280 = staticSwitch420;
				float2 uv_TextureSample0 = IN.ase_texcoord2.xy * _TextureSample0_ST.xy + _TextureSample0_ST.zw;
				float2 appendResult96 = (float2(( uv_TextureSample0.x + frac( ( _Disturbance_Tex_U_Speed * _TimeParameters.x ) ) ) , ( frac( ( _TimeParameters.x * _Disturbance_Tex_V_Speed ) ) + uv_TextureSample0.y )));
				float cos216 = cos( ( ( _Disturbance_Tex_Rotation * PI ) / 180.0 ) );
				float sin216 = sin( ( ( _Disturbance_Tex_Rotation * PI ) / 180.0 ) );
				float2 rotator216 = mul( appendResult96 - half2( 0.5,0.5 ) , float2x2( cos216 , -sin216 , sin216 , cos216 )) + half2( 0.5,0.5 );
				float4 tex2DNode74 = tex2D( _TextureSample0, rotator216 );
				float temp_output_76_0 = ( _Float0 * tex2DNode74.r );
				float temp_output_78_0 = ( tex2DNode74.r * _Float1 );
				#ifdef _KEYWORD9_ON
				float staticSwitch349 = ( break251.y + texCoord346.w );
				#else
				float staticSwitch349 = break251.y;
				#endif
				float temp_output_54_0 = ( frac( ( _TimeParameters.x * _BaseTex_V_Speed ) ) + staticSwitch349 );
				float clampResult355 = clamp( temp_output_54_0 , 0.0 , 1.0 );
				#ifdef _KEYWORD9_ON
				float staticSwitch353 = clampResult355;
				#else
				float staticSwitch353 = temp_output_54_0;
				#endif
				#ifdef _KEYWORD5_ON
				float staticSwitch421 = ( tex2DNode254.g * _Float25 );
				#else
				float staticSwitch421 = 0.0;
				#endif
				float raodong2V281 = staticSwitch421;
				float2 appendResult40 = (float2(( ( staticSwitch352 + raodong2U280 ) + temp_output_76_0 ) , ( temp_output_78_0 + ( staticSwitch353 + raodong2V281 ) )));
				float cos100 = cos( ( ( _Float4 * PI ) / 180.0 ) );
				float sin100 = sin( ( ( _Float4 * PI ) / 180.0 ) );
				float2 rotator100 = mul( appendResult40 - half2( 0.5,0.5 ) , float2x2( cos100 , -sin100 , sin100 , cos100 )) + half2( 0.5,0.5 );
				float temp_output_239_0 = ( 0.1 * _Float24 );
				float4 tex2DNode248 = tex2D( _Texturemm, rotator100 );
				float2 temp_cast_0 = (temp_output_239_0).xx;
				float4 appendResult232 = (float4(tex2D( _Texturemm, ( rotator100 + temp_output_239_0 ) ).r , tex2DNode248.g , tex2D( _Texturemm, ( rotator100 - temp_cast_0 ) ).b , tex2DNode248.a));
				float4 break238 = appendResult232;
				float2 uv_Mask_Tex = IN.ase_texcoord2.xy * _Mask_Tex_ST.xy + _Mask_Tex_ST.zw;
				float cos109 = cos( ( ( _Float7 * PI ) / 180.0 ) );
				float sin109 = sin( ( ( _Float7 * PI ) / 180.0 ) );
				float2 rotator109 = mul( uv_Mask_Tex - half2( 0.5,0.5 ) , float2x2( cos109 , -sin109 , sin109 , cos109 )) + half2( 0.5,0.5 );
				float2 uv_TextureSample2 = IN.ase_texcoord2.xy * _TextureSample2_ST.xy + _TextureSample2_ST.zw;
				float raodongU223 = temp_output_76_0;
				float raodongV224 = temp_output_78_0;
				float2 appendResult138 = (float2(( ( ( uv_TextureSample2.x + frac( ( _Dissolve_Tex_U_Speed * _TimeParameters.x ) ) ) + ( raodongU223 * _Float20 ) ) + ( raodong2U280 * _Float32 ) ) , ( ( _Float33 * raodong2V281 ) + ( ( _Float21 * raodongV224 ) + ( frac( ( _TimeParameters.x * _Dissolve_Tex_V_Speed ) ) + uv_TextureSample2.y ) ) )));
				float cos140 = cos( ( ( _Float12 * PI ) / 180.0 ) );
				float sin140 = sin( ( ( _Float12 * PI ) / 180.0 ) );
				float2 rotator140 = mul( appendResult138 - half2( 0.5,0.5 ) , float2x2( cos140 , -sin140 , sin140 , cos140 )) + half2( 0.5,0.5 );
				float4 tex2DNode121 = tex2D( _TextureSample2, rotator140 );
				#ifdef _KEYWORD1_ON
				float staticSwitch132 = ( 1.0 - tex2DNode121.r );
				#else
				float staticSwitch132 = tex2DNode121.r;
				#endif
				float4 texCoord165 = IN.ase_texcoord3;
				texCoord165.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				#ifdef _KEYWORD3_ON
				float staticSwitch166 = texCoord165.x;
				#else
				float staticSwitch166 = _Float10;
				#endif
				float temp_output_195_0 = ( 1.0 - step( ( staticSwitch132 + _Float14 ) , staticSwitch166 ) );
				#if defined(_KEYWORD4_SOFT)
				float staticSwitch422 = ( break238.w * pow( abs( ( staticSwitch132 + 1.0 + ( staticSwitch166 * -2.0 ) ) ) , _Float11 ) );
				#elif defined(_KEYWORD4_HARD)
				float staticSwitch422 = temp_output_195_0;
				#else
				float staticSwitch422 = ( break238.w * pow( abs( ( staticSwitch132 + 1.0 + ( staticSwitch166 * -2.0 ) ) ) , _Float11 ) );
				#endif
				float clampResult127 = clamp( staticSwitch422 , 0.0 , 1.0 );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth217 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth217 = abs( ( screenDepth217 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Float19 ) );
				float clampResult219 = clamp( distanceDepth217 , 0.0 , 1.0 );
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult303 = dot( ase_worldNormal , ase_worldViewDir );
				float smoothstepResult339 = smoothstep( 0.15 , 1.0 , dotResult303);
				float oneminusfresnel341 = pow( smoothstepResult339 , _Float78 );
				
				float Alpha = ( ( IN.ase_color.a * _Base_Tex_Color.a * break238.w ) * tex2D( _Mask_Tex, rotator109 ).r * clampResult127 * clampResult219 * saturate( ( ( 1.0 - _Open_Model_Softedge ) + oneminusfresnel341 ) ) );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	/*ase_lod*/
	CustomEditor "ParaMaterialEditor"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18912
2636;149;2477;1263;4688.8;1656.266;2.870339;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;271;-4606.583,-729.6969;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;83;-4663.983,319.8795;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;94;-4748.43,211.5769;Half;False;Property;_Disturbance_Tex_U_Speed;Disturbance_Tex_U_Speed;21;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-4760.627,446.8578;Half;False;Property;_Disturbance_Tex_V_Speed;Disturbance_Tex_V_Speed;22;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;274;-4803.375,-952.7108;Half;False;Property;_Float28;Disturbance_Tex2_U_Speed;28;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;275;-4792.175,-514.4648;Half;False;Property;_Float29;Disturbance_Tex2_V_Speed;29;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-4461.273,461.1118;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;272;-4408.583,-858.6969;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;90;-4455.425,214.0077;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-4402.145,-660.7697;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;81;-5121.405,265.4547;Inherit;False;0;74;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FractNode;503;-4268.458,-898.0388;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;210;-4008.746,692.1591;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;514;-4327.352,463.7583;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;513;-4299.352,140.7583;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;161;-4647.06,-12.27122;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;266;-3637.063,-488.2518;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;263;-4882.677,-773.4657;Inherit;False;0;254;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;211;-4037.22,590.4302;Half;False;Property;_Disturbance_Tex_Rotation;Disturbance_Tex_Rotation;18;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;504;-4266.458,-660.0388;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;264;-3709.448,-570.6361;Inherit;False;Property;_Float26;Disturbance_Tex2_Rotation;25;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;162;-4670.485,665.4194;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;265;-3420.755,-566.5594;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;269;-4116.158,-1042.631;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;268;-3479.755,-396.56;Inherit;False;Constant;_Float27;Float 27;42;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;270;-4138.896,-539.3724;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;212;-3787.487,714.3928;Half;False;Constant;_Float18;Float 18;16;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-4208.325,665.6287;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-4167.495,-56.58807;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-3711.878,563.8936;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;215;-3937.131,428.4308;Half;False;Constant;_Vector3;Vector 3;16;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;214;-3549.89,586.1266;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;262;-3310.389,-743.5877;Inherit;False;Constant;_Vector4;Vector 4;42;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;277;-3740.433,-845.9574;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;96;-3986.679,182.0665;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;267;-3273.755,-491.5597;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;261;-3049.031,-832.2865;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RotatorNode;216;-3403.339,284.146;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;258;-2766.219,-655.2217;Inherit;False;Property;_Float25;Disturbance2_V_Strength;27;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;257;-2765.521,-1049.619;Inherit;False;Property;_Float23;Disturbance2_U_Strength;26;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;77;-3140.473,68.4981;Half;False;Property;_Float0;Disturbance_U_Strength;19;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;74;-3135.642,237.0943;Inherit;True;Property;_TextureSample0;Disturbance_Tex;17;0;Create;False;0;0;0;False;1;Header(___________________Disturbance_________________________________________________________________________________________);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;346;-6914.579,244.2467;Inherit;True;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;250;-6504.785,280.985;Inherit;False;0;246;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;254;-2817.973,-860.7475;Inherit;True;Property;_TextureSample6;Disturbance_Tex2;23;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;80;-3107.972,476.1877;Half;False;Property;_Float1;Disturbance_V_Strength;20;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;259;-2470.518,-970.4036;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;363;-6454.155,603.9349;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-5555.354,155.2776;Half;False;Property;_BaseTex_U_Speed;BaseTex_U_Speed;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;289;-2473.555,-601.947;Inherit;False;Constant;_Float31;Float 31;47;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;251;-6240.23,281.3865;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;288;-2457.254,-1097.347;Inherit;False;Constant;_Float30;Float 30;47;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;144;-4024.767,1416.35;Half;False;Property;_Dissolve_Tex_U_Speed;Dissolve_Tex_U_Speed;43;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;362;-6484.088,65.11749;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;145;-4025.261,1646.978;Half;False;Property;_Dissolve_Tex_V_Speed;Dissolve_Tex_V_Speed;44;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-5555.354,458.9702;Half;False;Property;_BaseTex_V_Speed;BaseTex_V_Speed;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;148;-3949.083,1530.259;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-2792.119,76.78419;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-2782.473,415.4981;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;260;-2473.958,-768.9566;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;52;-5571.354,300.278;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;224;-2533.516,412.7162;Inherit;False;raodongV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;146;-3743.282,1398.231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;223;-2529.114,131.361;Inherit;False;raodongU;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;420;-2278.034,-1072.844;Inherit;False;Property;_Keyword5;Open_Two_Disturbance;23;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;147;-3719.348,1631.194;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;360;-5976.419,-137.2374;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-5315.354,396.2779;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;361;-5964.047,700.1824;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;141;-4414.569,1450.149;Inherit;True;0;121;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-5331.354,204.2777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;421;-2279.901,-727.3003;Inherit;False;Property;_Keyword5;Open_Two_Disturbance;24;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;-2014.277,-1067.955;Inherit;False;raodong2U;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;507;-3616.851,1306.787;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;226;-3463.477,1735.991;Inherit;False;224;raodongV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;506;-5173.919,502.635;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;349;-5694.494,674.602;Inherit;False;Property;_Keyword9;Open_Once_UV;57;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;-3548.952,1506.438;Half;False;Property;_Float20;Disslve_Following_Distort1_U;47;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;508;-3610.851,1760.787;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;281;-1981.752,-724.8729;Inherit;False;raodong2V;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;347;-5721.688,-166.792;Inherit;False;Property;_Keyword9;Open_Once_UV;8;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;230;-3547.952,1627.438;Half;False;Property;_Float21;Disslve_Following_Distort1_V;48;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;225;-3487.777,1423.425;Inherit;False;223;raodongU;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;150;-4025.207,1778.697;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;149;-4049.142,1323.934;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;505;-5209.919,103.635;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;50;-5073.909,-154.1745;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;54;-5081.557,753.3252;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;294;-3050.083,1720.827;Inherit;False;281;raodong2V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;228;-3252.929,1676.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;143;-3476.178,1842.599;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-3501.436,1198.254;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;293;-3054.237,1456.338;Inherit;False;280;raodong2U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;-3200.06,1397.665;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;296;-3126.362,1623.964;Half;False;Property;_Float33;Disslve_Following_Distort2_V;50;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;295;-3133.17,1534;Half;False;Property;_Float32;Disslve_Following_Distort2_U;49;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;221;-3028.188,1241.814;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;133;-2299.067,1789.502;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2266.124,1671.843;Half;False;Property;_Float12;Dissolve_Tex_Rotation;40;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;298;-2828.037,1619.804;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;424;-6480.987,2340.064;Inherit;True;0;462;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;222;-3058.884,1826.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;430;-5976.108,2435.937;Half;False;Property;_Float64;Vertex_Tex_V_Speed;66;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;427;-5976.108,2339.937;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;297;-2826.952,1471.193;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;354;-4900.156,-50.93587;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;355;-4908.324,823.0515;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;431;-5944.108,2259.938;Half;False;Property;_Float67;Vertex_Tex_U_Speed;65;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;353;-4721.555,746.4416;Inherit;False;Property;_Keyword9;Open_Once_UV;8;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2042.042,1827.478;Half;False;Constant;_Float13;Float 13;16;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;-5672.108,2291.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;135;-1992.442,1665.878;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;284;-3839.467,-46.75416;Inherit;True;280;raodong2U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;291;-2694.2,1316.478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;352;-4719.563,-151.0091;Inherit;False;Property;_Keyword9;Open_Once_UV;7;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;432;-6243.108,2340.937;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;285;-3846.664,885.2027;Inherit;False;281;raodong2V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;292;-2685.038,1738.113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;439;-5672.108,2403.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;428;-5744.108,2820.938;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;438;-5957.108,2204.937;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;429;-5749.108,2708.938;Half;False;Property;_Float68;Vertex_Tex_Rotation;64;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;435;-5907.108,2532.938;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-1800.442,1665.878;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;139;-2072.442,1504.878;Half;False;Constant;_Vector2;Vector 2;16;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;138;-2406.833,1392.808;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FractNode;509;-5541.802,2403.385;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;282;-3464.94,-152.2298;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;510;-5547.802,2292.385;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;104;-2064.704,622.8331;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;283;-3463.595,816.1249;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;103;-2060.937,536.3804;Half;False;Property;_Float4;Base_Tex_Rotation;7;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;440;-5484.824,2719.144;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1909.682,708.4833;Half;False;Constant;_Float5;Float 5;16;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;444;-5415.108,2173.937;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;441;-5409.108,2466.938;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-1846.916,549.7687;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-2430.758,-149.3351;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;75;-2442.705,782.6762;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;140;-1630.579,1392.529;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;437;-5504.108,2836.938;Half;False;Constant;_Float40;Float 40;37;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;445;-5267.109,2292.937;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;240;-1823.081,-107.6125;Half;False;Constant;_Float22;Float 22;38;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;106;-1711.158,677.9138;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;443;-5280.108,2692.938;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-778.903,1469.303;Half;False;Property;_Float10;Dissolve_Tex_Strength;42;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;102;-1831.026,388.5858;Half;False;Constant;_Vector0;Vector 0;16;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;40;-2021.915,258.6927;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;446;-5308.108,2550.938;Half;False;Constant;_Vector6;Vector 6;36;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;242;-1900.769,38.55948;Half;False;Property;_Float24;RGB_Offset;3;0;Create;False;0;0;0;False;0;False;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;121;-1319.725,1385.282;Inherit;True;Property;_TextureSample2;Dissolve_Tex;38;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;165;-767.9534,1561.956;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RotatorNode;100;-1560.124,293.6773;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;302;-3148.483,-1677.985;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StaticSwitch;166;-457.894,1490.883;Inherit;False;Property;_Keyword3;Dissolve_Custom;36;0;Create;False;0;0;0;False;1;Header(___________________Dissolve_______________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;183;-302.0152,1409.983;Half;False;Constant;_Float15;Float 15;30;0;Create;True;0;0;0;False;0;False;-2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;131;-966.3284,1443.693;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;239;-1563.717,-12.72951;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;448;-4851.109,2356.937;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;301;-3115.359,-1529.03;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;462;-4609.356,2329.188;Inherit;True;Property;_TextureSample13;Vertex_Tex;62;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;303;-2882.136,-1617.936;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;246;-1181.032,284.4452;Inherit;True;Property;_Texturemm;Base_Tex;6;0;Create;False;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RangedFloatNode;337;-2810.094,-1872.711;Half;False;Constant;_Float38;Float 38;100;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;243;-1185.603,-18.14016;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;182;-116.3457,1392.589;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;122;-121.7633,1307.848;Half;False;Constant;_Float9;Float 9;22;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;132;-765.7261,1316.885;Inherit;False;Property;_Keyword1;Dissolve_Tex_OneMinus;39;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;244;-1159.693,573.4847;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-2815.481,-1751.053;Half;False;Constant;_Float76;Float 76;100;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;463;-4519.291,2652.774;Half;False;Property;_Vector8;Vertex_Offset_X&Y&Z_Strength;63;0;Create;False;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;249;-899.6127,529.2006;Inherit;True;Property;_TextureSample5;Texture Sample 5;39;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;338;-2583.195,-1745.162;Half;False;Property;_Float78;Model_Softedge_Strength;59;0;Create;False;0;0;0;False;0;False;1;1;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;56.65211,1230.367;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;-4047.135,2607.752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;179;-790.7446,1753.83;Half;False;Property;_Float14;Dissolve_Edge_Size;45;0;Create;False;0;0;0;False;0;False;0;0;0;0.1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;247;-879.5652,45.14758;Inherit;True;Property;_TextureSample3;Texture Sample 3;37;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;339;-2477.911,-1892.934;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;452;-4051.135,2489.752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;248;-894.2897,282.5896;Inherit;True;Property;_TextureSample4;Texture Sample 4;38;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;455;-4053.135,2374.752;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;502;196.3409,1227.429;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;340;-2225.177,-1926.793;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;479;-4177.89,2186.221;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;113;-159.151,978.2435;Half;False;Property;_Float7;Mask_Tex_Rotation;16;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PiNode;114;-142.9676,1061.24;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;232;-498.8666,303.2274;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;129;48.5153,1444.491;Half;False;Property;_Float11;Dissolve_Tex_Power;41;0;Create;False;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;457;-3875.135,2409.752;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;180;-457.6753,1740.154;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;128;332.3215,1224.675;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;483;-3731.723,2623.501;Half;False;Property;_Vertex_Offset_XYZ;Vertex_Offset_X&Y&Z;61;0;Create;True;0;0;0;False;0;False;0,0,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;345;1529.36,860.5746;Half;False;Property;_Open_Model_Softedge;Open_Model_Softedge;58;0;Create;True;0;0;0;False;1;Header(___________________Model_______________________________________________________________________________________________);False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;181;-14.66,1675.212;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;110;83.42153,1003.006;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;341;-1786.486,-1934.29;Inherit;False;oneminusfresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;238;-264.9916,299.8255;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;111;76.03138,1102.616;Half;False;Constant;_Float6;Float 6;16;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;459;-3603.24,2335.347;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;482;-3635.695,2798.274;Half;False;Property;_Vertex_Offset_Strength;Vertex_Offset_Strength;60;0;Create;True;0;0;0;False;1;Header(___________________Vertex_______________________________________________________________________________________________);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;484;-3432.309,2530.768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;1659.295,946.343;Inherit;False;341;oneminusfresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;218;1277.897,781.0207;Half;False;Property;_Float19;Depth_Fade;1;0;Create;False;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;474;1794.759,859.7645;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;108;120.4216,820.0059;Half;False;Constant;_Vector1;Vector 1;16;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;112;242.4215,1017.006;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;115;71.1859,700.6726;Inherit;False;0;32;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;195;266.554,1674.603;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;1018.762,1110.729;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;472;1949.759,858.7645;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;109;551.9935,726.6768;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StaticSwitch;422;1213.847,1106.021;Inherit;False;Property;_Keyword4;Dissolve_Mode;37;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Soft;Hard;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;500;-3302.64,2687.744;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;18;913.8899,292.5878;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;217;1590.335,762.5832;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;7;535.2142,-31.4468;Inherit;False;Property;_Base_Tex_Color;Base_Tex_Color;5;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;464;-3099.284,2601.25;Inherit;False;VertexOffset;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;473;2078.759,852.7645;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;17;1148.665,412.3679;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;32;944.5807,697.4004;Inherit;True;Property;_Mask_Tex;Mask_Tex;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;127;1438.752,1111.967;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;219;1877.293,693.7531;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;371;-2184.407,2027.129;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;1176.943,1526.486;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;306;-2650.462,-1545.799;Half;False;Property;_Float34;Fresnel_Edge_Size;54;0;Create;False;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;318;-414.5388,-1677.807;Inherit;True;Property;_TextureSample8;Fresnel_Tex;56;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;12;60.80371,245.8957;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;76.1964,2350.509;Inherit;False;BaseTex2;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;407;-125.6927,2353.654;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;373;-1912.104,2289.288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;159;-5.556671,-611.6335;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;396;-1084.427,2197.133;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;157;-721.9698,-623.3471;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;328;-378.9035,-1308.728;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;201;1353.266,1401.215;Half;False;Constant;_Float17;Float 17;39;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;98;509.3637,221.9362;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;334;498.3585,-1464.667;Inherit;False;OpenFresnel;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;408;-1681.04,2139.736;Inherit;False;223;raodongU;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;155;-227.1858,-656.9219;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-1300.041,2062.119;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;415;-1487.109,2287.333;Inherit;False;281;raodong2V;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;372;-2178.406,2460.678;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;2209.197,608.976;Inherit;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;364;-2685.772,2158.489;Inherit;False;0;401;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;186;2730.79,321.8427;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;499;2990.057,146.7057;Inherit;False;Property;_Blend_Mode;Blend_Mode;0;1;[Enum];Create;True;0;2;Add;1;Blend;10;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;19;1545.734,284.2043;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;330;-477.7074,-1464.484;Inherit;False;Property;_Keyword6;Fresnel_Hard_Edge;52;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;209;757.2612,1972.046;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;305;-2577.677,-1623.015;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;326;-680.0518,-1235.661;Half;False;Property;_Color3;Fresnel_Edge_Color;53;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;-1720.932,-1560.625;Inherit;False;fresnel;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;406;-1034.977,2442.475;Half;False;Constant;_Vector5;Vector 5;67;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StaticSwitch;423;1534.637,1408.354;Inherit;False;Property;_Keyword4;Dissolve_Mode;38;0;Create;False;0;0;0;False;0;False;0;0;0;True;;KeywordEnum;2;Soft;Hard;Create;True;True;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;386;-1101.335,2770.057;Inherit;False;Constant;_Float47;Float 47;31;0;Create;True;0;0;0;False;0;False;180;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;188;-10.83424,1930.295;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;152;-706.0062,-494.4667;Inherit;False;Property;_Color1;Color 1;35;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-224.2613,-547.092;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;409;-1681.829,2331.01;Inherit;False;224;raodongV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;10;796.5115,-5.476339;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendOpsNode;116;1401.322,-218.2978;Inherit;False;Multiply;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;367;-2133.161,2357.87;Half;False;Property;_Float43;Base_Tex2_V_Speed;14;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;366;-2440.273,2163.156;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Vector2Node;313;-1066.273,-1654.725;Half;False;Property;_Vector11;Fresnel_Tex_UV_Speed;57;0;Create;False;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;196;271.2477,1930.407;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;307;-2419.061,-1622.465;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-993.6459,-1412.54;Inherit;False;310;fresnel;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;312;-1054.474,-1779.425;Inherit;False;0;318;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;40.64746,445.8135;Half;False;Property;_Float3;Desaturate;4;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;417;336.1484,220.8491;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;120;1872.829,-51.81143;Inherit;False;Property;_Keyword0;Open_ColorMapping;30;0;Create;False;0;0;0;False;1;Header(___________________Color_Mapping_______________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;158;-724.2146,-799.4115;Inherit;False;Property;_Color0;Color 0;34;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PiNode;382;-1492.967,2750.74;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;365;-2128.37,2225.126;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;383;-1492.387,2617.613;Half;False;Property;_Float45;Base_Tex2_Rotation;12;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;404;-1479.44,2455.999;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;311;-1021.374,-1521.526;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;320;-928.0966,-1291.024;Half;False;Constant;_Float35;Float 35;27;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;300;-2223.416,-1523.973;Half;False;Property;_Float75;Fresnel_Centre_Size;55;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;389;-1140.335,2611.057;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;494;2135.157,451.9611;Inherit;False;334;OpenFresnel;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;332;-210.8152,-1272.638;Half;False;Property;_Fresnel_Strength;Fresnel_Strength;51;0;Create;True;0;0;0;False;1;Header(___________________Fresnel_______________________________________________________________________________________________);False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;465;2814.035,473.5748;Inherit;False;464;VertexOffset;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;156;-410.1533,-612.3574;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;309;-1868.3,-1568.672;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;160;272.0423,-478.6113;Inherit;False;Property;_Keyword2;Color_Mapping_Mode;31;0;Create;False;0;0;0;False;0;False;0;1;1;True;;KeywordEnum;2;Color;Texture;Create;True;True;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;418;87.10889,160.9785;Inherit;False;416;BaseTex2;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;118;-84.11505,-393.1212;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;2440.82,245.5056;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;30;2033.948,348.1218;Inherit;False;Property;_BaseTex_Strength;BaseTex_Strength;2;0;Create;True;0;0;0;False;1;Header(___________________Base_________________________________________________________________________________________);False;1;1;1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;304;-2726.085,-1621.56;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;412;-1489.047,2163.124;Inherit;False;280;raodong2U;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;973.2612,1765.046;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;331;117.7899,-1474.531;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FractNode;512;-1810.009,2049.167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;197;504.1443,1713.998;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;314;-736.4731,-1712.425;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;151;-436.1508,-505.0945;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;377;-1663.528,2470.917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-2134.432,2098.241;Half;False;Property;_Float39;Base_Tex2_U_Speed;13;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;205;742.009,1701.582;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;401;-437.0481,2355.867;Inherit;True;Property;_TextureSample7;Base_Tex2;11;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;2214.063,162.8518;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotatorNode;399;-737.8909,2374.674;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;208;506.2612,2001.046;Inherit;False;Property;_Color2;Dissolve_Edge_Color;46;1;[HDR];Create;False;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;391;-1486.495,1984.795;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;1017.494,-6.904672;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;405;-908.9766,2655.475;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;511;-1807.009,2407.167;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;117;-390.7028,-395.9861;Inherit;True;Property;_TextureSample1;Color_Mapping_Tex;33;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;154;-459.8417,-726.3715;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;370;-1914.042,2162.924;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;375;-1699.724,1977.413;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;308;-2116.448,-1616.446;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;119;982.1738,-189.7187;Half;False;Property;_Float8;Color_Mapping_Strength;32;0;Create;False;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;411;-1294.066,2375.703;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;323;-698.329,-1371.431;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;5;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;919.7331,-74.32185;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;3140.27,325.8309;Half;False;True;-1;2;ParaMaterialEditor;0;3;Douyin/Avatar/VFX/AvatarVFX;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;True;-8;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;True;True;2;5;False;-1;10;True;499;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;111;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;  Use Shadow Threshold;0;Receive Shadows;0;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;87;0;83;0
WireConnection;87;1;95;0
WireConnection;272;0;274;0
WireConnection;272;1;271;0
WireConnection;90;0;94;0
WireConnection;90;1;83;0
WireConnection;273;0;271;0
WireConnection;273;1;275;0
WireConnection;503;0;272;0
WireConnection;514;0;87;0
WireConnection;513;0;90;0
WireConnection;161;0;81;1
WireConnection;504;0;273;0
WireConnection;162;0;81;2
WireConnection;265;0;264;0
WireConnection;265;1;266;0
WireConnection;269;0;263;1
WireConnection;269;1;503;0
WireConnection;270;0;504;0
WireConnection;270;1;263;2
WireConnection;92;0;514;0
WireConnection;92;1;162;0
WireConnection;91;0;161;0
WireConnection;91;1;513;0
WireConnection;213;0;211;0
WireConnection;213;1;210;0
WireConnection;214;0;213;0
WireConnection;214;1;212;0
WireConnection;277;0;269;0
WireConnection;277;1;270;0
WireConnection;96;0;91;0
WireConnection;96;1;92;0
WireConnection;267;0;265;0
WireConnection;267;1;268;0
WireConnection;261;0;277;0
WireConnection;261;1;262;0
WireConnection;261;2;267;0
WireConnection;216;0;96;0
WireConnection;216;1;215;0
WireConnection;216;2;214;0
WireConnection;74;1;216;0
WireConnection;254;1;261;0
WireConnection;259;0;257;0
WireConnection;259;1;254;1
WireConnection;363;0;346;4
WireConnection;251;0;250;0
WireConnection;362;0;346;3
WireConnection;76;0;77;0
WireConnection;76;1;74;1
WireConnection;78;0;74;1
WireConnection;78;1;80;0
WireConnection;260;0;254;2
WireConnection;260;1;258;0
WireConnection;224;0;78;0
WireConnection;146;0;144;0
WireConnection;146;1;148;0
WireConnection;223;0;76;0
WireConnection;420;1;288;0
WireConnection;420;0;259;0
WireConnection;147;0;148;0
WireConnection;147;1;145;0
WireConnection;360;0;362;0
WireConnection;360;1;251;0
WireConnection;58;0;52;0
WireConnection;58;1;59;0
WireConnection;361;0;251;1
WireConnection;361;1;363;0
WireConnection;53;0;51;0
WireConnection;53;1;52;0
WireConnection;421;1;289;0
WireConnection;421;0;260;0
WireConnection;280;0;420;0
WireConnection;507;0;146;0
WireConnection;506;0;58;0
WireConnection;349;1;251;1
WireConnection;349;0;361;0
WireConnection;508;0;147;0
WireConnection;281;0;421;0
WireConnection;347;1;251;0
WireConnection;347;0;360;0
WireConnection;150;0;141;2
WireConnection;149;0;141;1
WireConnection;505;0;53;0
WireConnection;50;0;347;0
WireConnection;50;1;505;0
WireConnection;54;0;506;0
WireConnection;54;1;349;0
WireConnection;228;0;230;0
WireConnection;228;1;226;0
WireConnection;143;0;508;0
WireConnection;143;1;150;0
WireConnection;142;0;149;0
WireConnection;142;1;507;0
WireConnection;227;0;225;0
WireConnection;227;1;229;0
WireConnection;221;0;142;0
WireConnection;221;1;227;0
WireConnection;298;0;296;0
WireConnection;298;1;294;0
WireConnection;222;0;228;0
WireConnection;222;1;143;0
WireConnection;297;0;293;0
WireConnection;297;1;295;0
WireConnection;354;0;50;0
WireConnection;355;0;54;0
WireConnection;353;1;54;0
WireConnection;353;0;355;0
WireConnection;434;0;431;0
WireConnection;434;1;427;0
WireConnection;135;0;134;0
WireConnection;135;1;133;0
WireConnection;291;0;221;0
WireConnection;291;1;297;0
WireConnection;352;1;50;0
WireConnection;352;0;354;0
WireConnection;432;0;424;0
WireConnection;292;0;298;0
WireConnection;292;1;222;0
WireConnection;439;0;427;0
WireConnection;439;1;430;0
WireConnection;438;0;432;0
WireConnection;435;0;432;1
WireConnection;137;0;135;0
WireConnection;137;1;136;0
WireConnection;138;0;291;0
WireConnection;138;1;292;0
WireConnection;509;0;439;0
WireConnection;282;0;352;0
WireConnection;282;1;284;0
WireConnection;510;0;434;0
WireConnection;283;0;353;0
WireConnection;283;1;285;0
WireConnection;440;0;429;0
WireConnection;440;1;428;0
WireConnection;444;0;438;0
WireConnection;444;1;510;0
WireConnection;441;0;509;0
WireConnection;441;1;435;0
WireConnection;105;0;103;0
WireConnection;105;1;104;0
WireConnection;72;0;282;0
WireConnection;72;1;76;0
WireConnection;75;0;78;0
WireConnection;75;1;283;0
WireConnection;140;0;138;0
WireConnection;140;1;139;0
WireConnection;140;2;137;0
WireConnection;445;0;444;0
WireConnection;445;1;441;0
WireConnection;106;0;105;0
WireConnection;106;1;107;0
WireConnection;443;0;440;0
WireConnection;443;1;437;0
WireConnection;40;0;72;0
WireConnection;40;1;75;0
WireConnection;121;1;140;0
WireConnection;100;0;40;0
WireConnection;100;1;102;0
WireConnection;100;2;106;0
WireConnection;166;1;126;0
WireConnection;166;0;165;1
WireConnection;131;0;121;1
WireConnection;239;0;240;0
WireConnection;239;1;242;0
WireConnection;448;0;445;0
WireConnection;448;1;446;0
WireConnection;448;2;443;0
WireConnection;462;1;448;0
WireConnection;303;0;302;0
WireConnection;303;1;301;0
WireConnection;243;0;100;0
WireConnection;243;1;239;0
WireConnection;182;0;166;0
WireConnection;182;1;183;0
WireConnection;132;1;121;1
WireConnection;132;0;131;0
WireConnection;244;0;100;0
WireConnection;244;1;239;0
WireConnection;249;0;246;0
WireConnection;249;1;244;0
WireConnection;123;0;132;0
WireConnection;123;1;122;0
WireConnection;123;2;182;0
WireConnection;456;0;462;1
WireConnection;456;1;463;3
WireConnection;247;0;246;0
WireConnection;247;1;243;0
WireConnection;339;0;303;0
WireConnection;339;1;337;0
WireConnection;339;2;336;0
WireConnection;452;0;462;1
WireConnection;452;1;463;2
WireConnection;248;0;246;0
WireConnection;248;1;100;0
WireConnection;455;0;463;1
WireConnection;455;1;462;1
WireConnection;502;0;123;0
WireConnection;340;0;339;0
WireConnection;340;1;338;0
WireConnection;232;0;247;1
WireConnection;232;1;248;2
WireConnection;232;2;249;3
WireConnection;232;3;248;4
WireConnection;457;0;455;0
WireConnection;457;1;452;0
WireConnection;457;2;456;0
WireConnection;180;0;132;0
WireConnection;180;1;179;0
WireConnection;128;0;502;0
WireConnection;128;1;129;0
WireConnection;181;0;180;0
WireConnection;181;1;166;0
WireConnection;110;0;113;0
WireConnection;110;1;114;0
WireConnection;341;0;340;0
WireConnection;238;0;232;0
WireConnection;459;0;479;0
WireConnection;459;1;457;0
WireConnection;484;0;459;0
WireConnection;484;1;483;0
WireConnection;474;0;345;0
WireConnection;112;0;110;0
WireConnection;112;1;111;0
WireConnection;195;0;181;0
WireConnection;130;0;238;3
WireConnection;130;1;128;0
WireConnection;472;0;474;0
WireConnection;472;1;343;0
WireConnection;109;0;115;0
WireConnection;109;1;108;0
WireConnection;109;2;112;0
WireConnection;422;1;130;0
WireConnection;422;0;195;0
WireConnection;500;0;484;0
WireConnection;500;1;482;0
WireConnection;217;0;218;0
WireConnection;464;0;500;0
WireConnection;473;0;472;0
WireConnection;17;0;18;4
WireConnection;17;1;7;4
WireConnection;17;2;238;3
WireConnection;32;1;109;0
WireConnection;127;0;422;0
WireConnection;219;0;217;0
WireConnection;371;0;366;0
WireConnection;204;0;238;3
WireConnection;204;1;206;0
WireConnection;318;1;314;0
WireConnection;12;0;238;0
WireConnection;12;1;238;1
WireConnection;12;2;238;2
WireConnection;416;0;407;0
WireConnection;407;0;401;0
WireConnection;373;0;365;0
WireConnection;373;1;367;0
WireConnection;159;0;155;0
WireConnection;159;1;153;0
WireConnection;396;0;410;0
WireConnection;396;1;411;0
WireConnection;328;0;326;1
WireConnection;328;1;326;2
WireConnection;328;2;326;3
WireConnection;98;0;417;0
WireConnection;98;1;99;0
WireConnection;334;0;331;0
WireConnection;155;0;154;0
WireConnection;155;1;156;0
WireConnection;410;0;391;0
WireConnection;410;1;412;0
WireConnection;372;0;366;1
WireConnection;33;0;17;0
WireConnection;33;1;32;1
WireConnection;33;2;127;0
WireConnection;33;3;219;0
WireConnection;33;4;473;0
WireConnection;186;0;29;0
WireConnection;186;1;423;0
WireConnection;186;2;494;0
WireConnection;19;0;18;0
WireConnection;330;1;322;0
WireConnection;330;0;323;0
WireConnection;209;0;208;0
WireConnection;305;0;304;0
WireConnection;310;0;309;0
WireConnection;423;1;201;0
WireConnection;423;0;204;0
WireConnection;188;0;132;0
WireConnection;188;1;166;0
WireConnection;153;0;157;1
WireConnection;153;1;151;0
WireConnection;10;0;7;1
WireConnection;10;1;7;2
WireConnection;10;2;7;3
WireConnection;116;0;160;0
WireConnection;116;1;13;0
WireConnection;116;2;119;0
WireConnection;366;0;364;0
WireConnection;196;0;188;0
WireConnection;307;0;305;0
WireConnection;307;1;306;0
WireConnection;417;0;418;0
WireConnection;417;1;12;0
WireConnection;120;1;13;0
WireConnection;120;0;116;0
WireConnection;404;0;409;0
WireConnection;404;1;377;0
WireConnection;389;0;383;0
WireConnection;389;1;382;0
WireConnection;156;0;157;1
WireConnection;309;0;308;0
WireConnection;309;1;300;0
WireConnection;160;1;159;0
WireConnection;160;0;118;0
WireConnection;118;0;117;0
WireConnection;29;0;20;0
WireConnection;29;1;30;0
WireConnection;304;0;303;0
WireConnection;206;0;205;0
WireConnection;206;1;209;0
WireConnection;331;0;330;0
WireConnection;331;1;328;0
WireConnection;331;2;318;1
WireConnection;331;3;332;0
WireConnection;512;0;370;0
WireConnection;197;0;195;0
WireConnection;197;1;196;0
WireConnection;314;0;312;0
WireConnection;314;2;313;0
WireConnection;314;1;311;0
WireConnection;151;0;152;0
WireConnection;377;0;511;0
WireConnection;377;1;372;0
WireConnection;205;0;197;0
WireConnection;401;1;399;0
WireConnection;20;0;120;0
WireConnection;20;1;19;0
WireConnection;399;0;396;0
WireConnection;399;1;406;0
WireConnection;399;2;405;0
WireConnection;391;0;375;0
WireConnection;391;1;408;0
WireConnection;13;0;10;0
WireConnection;13;1;98;0
WireConnection;405;0;389;0
WireConnection;405;1;386;0
WireConnection;511;0;373;0
WireConnection;154;0;158;0
WireConnection;370;0;419;0
WireConnection;370;1;365;0
WireConnection;375;0;371;0
WireConnection;375;1;512;0
WireConnection;308;0;307;0
WireConnection;411;0;415;0
WireConnection;411;1;404;0
WireConnection;323;0;320;0
WireConnection;323;1;322;0
WireConnection;2;2;186;0
WireConnection;2;3;33;0
WireConnection;2;5;465;0
ASEEND*/
//CHKSM=89747412D2672893410106542D910C37A0AB0D5A