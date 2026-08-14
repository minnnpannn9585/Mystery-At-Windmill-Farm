// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Douyin/Avatar/Cartoon/AvatarNPR_HD_AlphaTest"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector][Toggle(_ALPHAACTOR_ON)] _ALPHAACTOR("_ALPHAACTOR", Float) = 0
		[HideInInspector]_ActorRadius("ActorRadius", Range( 0 , 1)) = 0.4
		[Header(___________________BaseTex____________________________________________________________________________________________)]_BaseTex("BaseTex(A)Alpha", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1,1,1,0)
		_ColorPower("ColorPower", Range( 0 , 20)) = 1
		_DarkColor("DarkColor", Color) = (0.9056604,0.8330367,0.8330367,0)
		_DarkRange("DarkRange", Range( -1 , 1)) = 0.2
		_DarkSoft("DarkSoft", Range( 0 , 5)) = 0.1
		_VertexColorAlphaFixDarkRange("VertexColorAlphaFixDarkRange", Range( 0 , 1)) = 0
		[Header(__________________Alpha____________________________________________________________________________________________)]_Alpha("Alpha", Range( 0 , 1)) = 1
		_AlphaClip("AlphaClip", Range( 0 , 1)) = 0.5
		_FresnelPower("FresnelPower", Range( 0 , 30)) = 2
		_FresnelWidth("FresnelWidth", Range( 0 , 2)) = 0
		_FresnelBlendIntensity("FresnelBlendIntensity", Range( 0 , 1)) = 0
		_EdgeNormalMapIntensity1("EdgeNormalMapIntensity", Range( 0 , 1)) = 0
		_FlipFresnel("FlipFresnel", Range( 0 , 1)) = 0
		_BlendTex1("BlendTex1", 2D) = "white" {}
		_BlendTexAlpha("BlendTexAlpha", Range( 0 , 10)) = 0
		_BlendTex1Intensity("BlendTex1Intensity", Range( 0 , 5)) = 0
		[Header(__________________Normalmap____________________________________________________________________________________________)][Normal]_Normalmap("Normalmap", 2D) = "bump" {}
		_NormalIntensity("NormalIntensity", Range( 0 , 10)) = 1
		[Header(__________________Ramp____________________________________________________________________________________________)][NoScaleOffset]_RampTex("RampTex", 2D) = "white" {}
		_RampColor("RampColor", Color) = (1,1,1,0)
		_RampRange("RampRange", Range( 0.1 , 5)) = 0.8
		_RampBlend("RampBlend", Range( 0 , 1)) = 1
		[Header(__________________ShadowMask____________________________________________________________________________________________)][Toggle(_USESHADOWMASK_ON)] _UseShadowMask("UseShadowMask", Float) = 0
		_ShadowMask("ShadowMask(R)", 2D) = "white" {}
		[Toggle(_FILPSHADOWMASK_ON)] _FilpShadowMask("FlipShadowMask", Float) = 0
		_ShadowMaskPower("ShadowMaskPower", Range( 0 , 5)) = 1
		[Header(___________________Matcap_________________________________________________________________________________________________)][Toggle(_USEMATCAP_ON)] _UseMatcap("UseMatcap", Float) = 0
		[NoScaleOffset]_MatcapTex("MatcapTex", 2D) = "white" {}
		_MatcapColor("MatcapColor", Color) = (1,1,1,0)
		_MatcapPower("MatcapPower", Range( 0.5 , 35)) = 1
		_MatcapBlend("MatcapBlend", Range( 0 , 10)) = 1
		_MatcapMask("MatcapMask(R)", 2D) = "white" {}
		[Header(__________________Emissive____________________________________________________________________________________________)]_EmissiveTex("EmissiveTex", 2D) = "black" {}
		_EmissiveColor("EmissiveColor", Color) = (1,1,1,1)
		_EmissivePower("EmissivePower", Range( 0 , 20)) = 1
		[NoScaleOffset]_EmissiveBlendTex("EmissiveBlendTex", 2D) = "white" {}
		_EmiBlendTiling("EmiBlendTiling", Vector) = (1,1,0,0)
		_EmiBlendSpeed("EmiBlendSpeed", Vector) = (0,0,0,0)
		[Header(__________________Specular____________________________________________________________________________________________)][Toggle(_USESPECULAR_ON)] _UseSpecular("UseSpecular", Float) = 0
		_SpecularMask("SpecularMask(G)", 2D) = "white" {}
		_SpecularColor("SpecularColor", Color) = (1,1,1,0)
		_SpecularRange("SpecularRange", Range( -1 , 0)) = -0.75
		_SpecularSoft("SpecularSoft", Range( 0 , 50)) = 5
		_SpecularPower("SpecularPower", Range( 0 , 3)) = 1
		_SpecularColor01("SpecularColor01", Color) = (0,0,0,0)
		_SpecularMaskRange01("SpecularMaskRange01", Range( -1 , 0)) = -0.2
		_SpecularSoft01("SpecularSoft01", Range( 0 , 100)) = 50
		_SpecularColor02("SpecularColor02", Color) = (0,0,0,0)
		_SpecularMaskRange02("SpecularMaskRange02", Range( -1 , 0)) = -0.1
		_SpecularSoft02("SpecularSoft02", Range( 0 , 100)) = 50
		[Header(__________________RimLight____________________________________________________________________________________________)]_RimMask("RimMask(B)", 2D) = "white" {}
		_RimLightColor("RimLightColor", Color) = (0,0,0,0)
		_RimLightRange("RimLightRange", Range( 0 , 2)) = 0.9
		_RimLightSoft("RimLightSoft", Range( 0 , 5)) = 0.2
		_RimOffset("RimOffset", Float) = 0.16
		_RimPower("RimPower", Range( 0 , 20)) = 1
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
		LOD 500

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" }
		
		Cull Back
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
			Tags { "LightMode"="UniversalForward" "RenderPipeline"="UniversalRenderPipeline" "RenderType"="Opaque" }
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
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
			#pragma shader_feature_local _USESPECULAR_ON
			#pragma shader_feature _USEMATCAP_ON
			#pragma shader_feature_local _USESHADOWMASK_ON
			#pragma shader_feature_local _FILPSHADOWMASK_ON
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_color : COLOR;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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
			sampler2D _EmissiveTex;
			sampler2D _EmissiveBlendTex;
			sampler2D _RampTex;
			sampler2D _Normalmap;
			sampler2D _BaseTex;
			sampler2D _BlendTex1;
			sampler2D _MatcapTex;
			sampler2D _MatcapMask;
			sampler2D _SpecularMask;
			sampler2D _ShadowMask;
			sampler2D _RimMask;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord4.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord5.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_tangent : TANGENT;
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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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
				float2 uv_EmissiveTex = IN.ase_texcoord3.xy * _EmissiveTex_ST.xy + _EmissiveTex_ST.zw;
				float2 texCoord535 = IN.ase_texcoord3.xy * _EmiBlendTiling + float2( 0,0 );
				float2 panner524 = ( 1.0 * _Time.y * _EmiBlendSpeed + texCoord535);
				float4 temp_output_856_0 = ( ( tex2D( _EmissiveTex, uv_EmissiveTex ) * _EmissiveColor * _EmissivePower ) * tex2D( _EmissiveBlendTex, panner524 ) );
				float4 color824 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float4 mainlight894 = GetMainLightDir(  );
				float3 break6_g170 = (mainlight894).xyz;
				float3 appendResult8_g170 = (float3(break6_g170.x , 0.0 , break6_g170.z));
				float3 normalizeResult9_g170 = normalize( appendResult8_g170 );
				float temp_output_2_0_g170 = 0.6;
				float3 break12_g170 = ( normalizeResult9_g170 * sqrt( ( 1.0 - pow( temp_output_2_0_g170 , 2.0 ) ) ) );
				float3 appendResult11_g170 = (float3(break12_g170.x , temp_output_2_0_g170 , break12_g170.z));
				float dotResult299 = dot( tangentToWorldDir384 , appendResult11_g170 );
				float clampResult987 = clamp( (( ( dotResult299 + 1.0 ) * 0.5 )*_RampRange + 0.0) , 0.01 , 0.99 );
				float2 temp_cast_1 = (clampResult987).xx;
				float4 lerpResult565 = lerp( color824 , ( tex2D( _RampTex, temp_cast_1 ) * _RampColor ) , _RampBlend);
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float3 lerpResult965 = lerp( (( tex2DNode217 * _BaseColor * _ColorPower )).rgb , (tex2DNode959).rgb , saturate( ( tex2DNode959.a * _BlendTex1Intensity ) ));
				float3 normalizeResult5_g169 = normalize( ( _WorldSpaceCameraPos - WorldPosition ) );
				float4 appendResult8_g169 = (float4(reflect( normalizeResult5_g169 , tangentToWorldDir384 ) , 0.0));
				float3 normalizeResult11_g169 = normalize( (mul( unity_WorldToCamera, appendResult8_g169 )).xyz );
				float3 break12_g169 = normalizeResult11_g169;
				float2 appendResult16_g169 = (float2(break12_g169.x , break12_g169.y));
				float4 temp_output_489_0 = ( tex2D( _MatcapTex, ( 1.0 - ( ( appendResult16_g169 / ( sqrt( ( break12_g169.z + 1.0 ) ) * 2.828427 ) ) + float2( 0.5,0.5 ) ) ) ) * _MatcapColor * ( _MatcapPower * 0.4 ) );
				float4 temp_cast_5 = (0.5).xxxx;
				float4 temp_output_937_0 = step( temp_output_489_0 , temp_cast_5 );
				float4 temp_cast_7 = (0.5).xxxx;
				float2 uv_MatcapMask = IN.ase_texcoord3.xy * _MatcapMask_ST.xy + _MatcapMask_ST.zw;
				float4 lerpResult943 = lerp( float4( lerpResult965 , 0.0 ) , ( ( ( float4( lerpResult965 , 0.0 ) * temp_output_489_0 * 2.0 ) * temp_output_937_0 ) + ( ( 1.0 - ( float4( ( 1.0 - lerpResult965 ) , 0.0 ) * ( 1.0 - temp_output_489_0 ) * 2.0 ) ) * ( 1.0 - temp_output_937_0 ) ) ) , ( ( _MatcapBlend * 0.1 ) * tex2D( _MatcapMask, uv_MatcapMask ).r ));
				#ifdef _USEMATCAP_ON
				float4 staticSwitch416 = lerpResult943;
				#else
				float4 staticSwitch416 = float4( lerpResult965 , 0.0 );
				#endif
				float4 temp_output_317_0 = ( lerpResult565 * staticSwitch416 );
				float temp_output_419_0 = ( dotResult299 + _SpecularRange );
				float2 uv_SpecularMask = IN.ase_texcoord3.xy * _SpecularMask_ST.xy + _SpecularMask_ST.zw;
				float4 tex2DNode493 = tex2D( _SpecularMask, uv_SpecularMask );
				float temp_output_499_0 = ( temp_output_419_0 + _SpecularMaskRange01 );
				float4 lerpResult538 = lerp( ( saturate( ( temp_output_419_0 * _SpecularSoft ) ) * _SpecularColor * _SpecularPower * tex2DNode493.g ) , _SpecularColor01 , ( tex2DNode493.g * saturate( ( temp_output_499_0 * _SpecularSoft01 ) ) ));
				float4 lerpResult510 = lerp( lerpResult538 , _SpecularColor02 , ( tex2DNode493.g * saturate( ( ( temp_output_499_0 + _SpecularMaskRange02 ) * _SpecularSoft02 ) ) ));
				#ifdef _USESPECULAR_ON
				float4 staticSwitch475 = ( temp_output_317_0 + lerpResult510 );
				#else
				float4 staticSwitch475 = temp_output_317_0;
				#endif
				float lerpResult885 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float temp_output_314_0 = ( 1.0 - saturate( ( ( dotResult299 + lerpResult885 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_820_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch558 = saturate( ( temp_output_314_0 + temp_output_820_0 ) );
				#else
				float staticSwitch558 = temp_output_314_0;
				#endif
				float4 lerpResult316 = lerp( staticSwitch475 , ( lerpResult565 * _DarkColor * staticSwitch416 ) , staticSwitch558);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult440 = dot( tangentToWorldDir384 , (ase_worldViewDir*1.0 + _RimOffset) );
				float2 uv_RimMask = IN.ase_texcoord3.xy * _RimMask_ST.xy + _RimMask_ST.zw;
				float4 mainlightColor895 = GetMainLightColor(  );
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag923 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag923);
				
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( temp_output_856_0 + ( ( lerpResult316 + ( saturate( ( ( 1.0 - ( dotResult440 + _RimLightRange ) ) / _RimLightSoft ) ) * _RimLightColor * tex2D( _RimMask, uv_RimMask ).b * _RimPower ) ) * mainlightColor895 * float4( lerpResult641 , 0.0 ) ) ).rgb;
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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

			sampler2D _BaseTex;
			sampler2D _Normalmap;
			sampler2D _BlendTex1;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

	
	}
	SubShader
	{
		LOD 400

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" }
		
		Cull Back
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
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
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
			#pragma shader_feature_local _USESHADOWMASK_ON
			#pragma shader_feature_local _FILPSHADOWMASK_ON
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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
			sampler2D _BaseTex;
			sampler2D _BlendTex1;
			sampler2D _ShadowMask;
			sampler2D _EmissiveTex;
			sampler2D _EmissiveBlendTex;
			sampler2D _Normalmap;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;

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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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
				float4 mainlightColor895 = GetMainLightColor(  );
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float3 lerpResult965 = lerp( (( tex2DNode217 * _BaseColor * _ColorPower )).rgb , (tex2DNode959).rgb , saturate( ( tex2DNode959.a * _BlendTex1Intensity ) ));
				float lerpResult885 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float4 mainlight901 = GetMainLightDir(  );
				float3 break6_g168 = (mainlight901).xyz;
				float3 appendResult8_g168 = (float3(break6_g168.x , 0.0 , break6_g168.z));
				float3 normalizeResult9_g168 = normalize( appendResult8_g168 );
				float temp_output_2_0_g168 = 0.6;
				float3 break12_g168 = ( normalizeResult9_g168 * sqrt( ( 1.0 - pow( temp_output_2_0_g168 , 2.0 ) ) ) );
				float3 appendResult11_g168 = (float3(break12_g168.x , temp_output_2_0_g168 , break12_g168.z));
				float dotResult904 = dot( ase_worldNormal , appendResult11_g168 );
				float temp_output_907_0 = ( 1.0 - saturate( ( ( lerpResult885 + dotResult904 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_820_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch918 = saturate( ( temp_output_907_0 + temp_output_820_0 ) );
				#else
				float staticSwitch918 = temp_output_907_0;
				#endif
				float4 lerpResult919 = lerp( float4( lerpResult965 , 0.0 ) , ( float4( lerpResult965 , 0.0 ) * _DarkColor ) , staticSwitch918);
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag923 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag923);
				float4 temp_output_906_0 = ( mainlightColor895 * lerpResult919 * float4( lerpResult641 , 0.0 ) );
				float2 uv_EmissiveTex = IN.ase_texcoord3.xy * _EmissiveTex_ST.xy + _EmissiveTex_ST.zw;
				float2 texCoord535 = IN.ase_texcoord3.xy * _EmiBlendTiling + float2( 0,0 );
				float2 panner524 = ( 1.0 * _Time.y * _EmiBlendSpeed + texCoord535);
				float4 temp_output_856_0 = ( ( tex2D( _EmissiveTex, uv_EmissiveTex ) * _EmissiveColor * _EmissivePower ) * tex2D( _EmissiveBlendTex, panner524 ) );
				
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( temp_output_906_0 + temp_output_856_0 ).xyz;
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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

			sampler2D _BaseTex;
			sampler2D _Normalmap;
			sampler2D _BlendTex1;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

	
	}
	
SubShader
	{
		LOD 300

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" "Queue"="AlphaTest" }
		
		Cull Back
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
			
			Blend One Zero, One Zero
			ZWrite On
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
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
			#pragma shader_feature_local _USESHADOWMASK_ON
			#pragma shader_feature_local _FILPSHADOWMASK_ON
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_texcoord7 : TEXCOORD7;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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
			sampler2D _BaseTex;
			sampler2D _BlendTex1;
			sampler2D _ShadowMask;
			sampler2D _Normalmap;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord5.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord6.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord7 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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
				float4 ase_color : COLOR;
				float4 ase_tangent : TANGENT;

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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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
				float4 mainlightColor895 = GetMainLightColor(  );
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float3 lerpResult965 = lerp( (( tex2DNode217 * _BaseColor * _ColorPower )).rgb , (tex2DNode959).rgb , saturate( ( tex2DNode959.a * _BlendTex1Intensity ) ));
				float lerpResult885 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float4 mainlight901 = GetMainLightDir(  );
				float3 break6_g168 = (mainlight901).xyz;
				float3 appendResult8_g168 = (float3(break6_g168.x , 0.0 , break6_g168.z));
				float3 normalizeResult9_g168 = normalize( appendResult8_g168 );
				float temp_output_2_0_g168 = 0.6;
				float3 break12_g168 = ( normalizeResult9_g168 * sqrt( ( 1.0 - pow( temp_output_2_0_g168 , 2.0 ) ) ) );
				float3 appendResult11_g168 = (float3(break12_g168.x , temp_output_2_0_g168 , break12_g168.z));
				float dotResult904 = dot( ase_worldNormal , appendResult11_g168 );
				float temp_output_907_0 = ( 1.0 - saturate( ( ( lerpResult885 + dotResult904 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_820_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch918 = saturate( ( temp_output_907_0 + temp_output_820_0 ) );
				#else
				float staticSwitch918 = temp_output_907_0;
				#endif
				float4 lerpResult919 = lerp( float4( lerpResult965 , 0.0 ) , ( float4( lerpResult965 , 0.0 ) * _DarkColor ) , staticSwitch918);
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag923 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag923);
				float4 temp_output_906_0 = ( mainlightColor895 * lerpResult919 * float4( lerpResult641 , 0.0 ) );
				
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = temp_output_906_0.xyz;
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL
			#pragma multi_compile __ _ALPHAACTOR_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
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
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseTex_ST;
			float4 _RampColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _SpecularColor;
			float4 _SpecularMask_ST;
			float4 _SpecularColor01;
			float4 _SpecularColor02;
			float4 _RimLightColor;
			float4 _MatcapColor;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _EmissiveTex_ST;
			float4 _ShadowMask_ST;
			float4 _DarkColor;
			float4 _BaseColor;
			float4 _BlendTex1_ST;
			float2 _EmiBlendTiling;
			float2 _EmiBlendSpeed;
			float _SpecularSoft01;
			float _MatcapPower;
			float _SpecularPower;
			float _SpecularSoft02;
			float _SpecularSoft;
			float _SpecularRange;
			float _RimOffset;
			float _RimLightRange;
			float _MatcapBlend;
			float _RimLightSoft;
			float _SpecularMaskRange01;
			float _SpecularMaskRange02;
			float _EmissivePower;
			float _RampRange;
			float _ColorPower;
			float _BlendTex1Intensity;
			float _DarkRange;
			float _VertexColorAlphaFixDarkRange;
			float _DarkSoft;
			float _ShadowMaskPower;
			float _ActorRadius;
			float _RampBlend;
			float _BlendTexAlpha;
			float _FresnelBlendIntensity;
			float _NormalIntensity;
			float _Alpha;
			float _EdgeNormalMapIntensity1;
			float _FresnelPower;
			float _FlipFresnel;
			float _AlphaClip;
			float _FresnelWidth;
			float _RimPower;
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

			sampler2D _BaseTex;
			sampler2D _Normalmap;
			sampler2D _BlendTex1;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
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

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;

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
				o.ase_tangent = v.ase_tangent;
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
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_955_0 = saturate( ( tex2DNode217.a * _Alpha ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack972 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack972.z = lerp( 1, unpack972.z, saturate(_NormalIntensity) );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir384 = normalize( mul( ase_tangentToWorldFast, unpack972 ) );
				float3 lerpResult986 = lerp( tangentToWorldDir384 , ase_worldNormal , _EdgeNormalMapIntensity1);
				float dotResult947 = dot( ase_worldViewDir , lerpResult986 );
				float temp_output_951_0 = pow( abs( ( dotResult947 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult954 = lerp( ( 1.0 - temp_output_951_0 ) , temp_output_951_0 , _FlipFresnel);
				float lerpResult960 = lerp( temp_output_955_0 , ( lerpResult954 * temp_output_955_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode959 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g138 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g138 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g138 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g138 = ( 1.0 - smoothstepResult21_g138 );
				#else
				float staticSwitch13_g138 = 1.0;
				#endif
				float temp_output_970_0 = saturate( ( saturate( ( lerpResult960 + ( _BlendTexAlpha * tex2DNode959.a ) ) ) * staticSwitch13_g138 ) );
				
				float Alpha = temp_output_970_0;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

	
	}
	

	CustomEditor "ParaMaterialEditor"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18912
2560;0;2560;1371;-986.1746;1547.089;1.6;True;True
Node;AmplifyShaderEditor.CommentaryNode;399;436.1701,-13.16695;Inherit;False;2842.323;716.499;matcap;31;932;941;940;939;937;938;936;944;942;934;377;381;833;488;834;492;935;487;933;489;816;815;384;943;416;971;972;977;978;979;980;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;971;537.3217,397.8039;Inherit;False;Property;_NormalIntensity;NormalIntensity;21;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;377;476.8569,198.1328;Inherit;True;Property;_Normalmap;Normalmap;20;2;[Header];[Normal];Create;True;1;__________________Normalmap____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;972;864.3217,247.8039;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;985;3030.13,-1567.34;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;984;2947.865,-1432.107;Inherit;False;Property;_EdgeNormalMapIntensity1;EdgeNormalMapIntensity;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;945;3197.118,-1675.103;Inherit;False;1756.476;923.8859;BlendTex1;28;968;967;966;965;964;963;962;961;960;959;958;957;956;954;953;952;951;950;949;948;947;946;343;344;345;955;983;986;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TransformDirectionNode;384;1116.127,206.022;Inherit;False;Tangent;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;946;3251.118,-1658.103;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;986;3234.389,-1525.865;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;948;3287.993,-1411.79;Inherit;False;Property;_FresnelWidth;FresnelWidth;13;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;947;3439.037,-1513.936;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;950;3580.993,-1502.79;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;949;3493.212,-1316.732;Inherit;False;Property;_FresnelPower;FresnelPower;12;0;Create;True;0;0;0;False;0;False;2;2;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;983;3700.138,-1599.732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;400;2128.412,-1693.926;Inherit;False;558.6589;518.444;Basecolor;4;260;217;251;252;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;217;2178.412,-1643.926;Inherit;True;Property;_BaseTex;BaseTex(A)Alpha;3;1;[Header];Create;False;1;___________________BaseTex____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;974;2756.275,-1233.392;Inherit;False;Property;_Alpha;Alpha;10;1;[Header];Create;True;1;__________________Alpha____________________________________________________________________________________________;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;951;3769.212,-1474.732;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;953;3924.212,-1481.732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;952;3789.212,-1358.732;Inherit;False;Property;_FlipFresnel;FlipFresnel;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;975;3034.275,-1275.392;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;954;4078.211,-1420.732;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;955;3232.935,-1251.818;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;957;4114.968,-1269.248;Inherit;False;Property;_FresnelBlendIntensity;FresnelBlendIntensity;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;958;4184.591,-1196.217;Inherit;False;Property;_BlendTexAlpha;BlendTexAlpha;18;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;956;4249.209,-1372.732;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;959;4130.592,-1125.217;Inherit;True;Property;_BlendTex1;BlendTex1;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;961;4461.591,-1191.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;960;4402.312,-1332.486;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;962;4601.591,-1281.217;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;854;5039.612,622.8298;Inherit;False;AlphaActor;0;;138;92bf20db17d0d2b46abe078b3b0cece6;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;963;4725.405,-1279.573;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;401;1550.111,-1168.722;Inherit;False;1475.176;434.5357;Ramp;13;987;981;982;553;554;407;555;565;825;218;253;254;824;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;398;3316.807,-5.925011;Inherit;False;1431.718;885.8992;Emissve;10;534;524;523;535;395;390;537;393;391;856;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;469;2700.755,1954.153;Inherit;False;1766.055;541.3859;RimLight;13;814;443;437;441;444;439;436;462;445;433;440;461;431;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;403;1558.124,-706.7764;Inherit;False;2833.037;670.8929;CartoonLight;27;558;556;318;314;562;560;304;308;305;307;313;316;317;475;563;306;299;745;730;820;822;823;883;884;885;886;894;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;429;3109.814,928.0593;Inherit;False;1222.921;982.5642;Specular;26;538;510;422;421;419;424;499;509;506;505;423;496;427;493;428;497;495;420;504;593;594;596;595;597;598;599;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;931;5189.947,334.02;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;644;4392.764,1130.416;Inherit;False;633.4209;403.8587;SH Sampler;6;567;608;788;790;641;923;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;922;2938.206,-2555.305;Inherit;False;2938.089;792.8103;LODshader;17;897;341;918;917;920;907;904;906;903;908;909;902;901;919;910;911;905;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;5078.703,474.6581;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;4874.377,978.5336;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;820;3527.114,-277.0332;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;461;2951.843,2084.075;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;883;2199.095,-250.7495;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;424;4189.536,1002.175;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;933;2362.771,71.43435;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;3199.161,-631.1042;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;593;3136.881,1629.777;Inherit;False;Property;_SpecularSoft01;SpecularSoft01;50;0;Create;True;0;0;0;False;0;False;50;50;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;4073.724,194.6328;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;316;4214.403,-482.3137;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;423;3532.651,1285.58;Inherit;False;Property;_SpecularPower;SpecularPower;47;0;Create;True;0;0;0;False;0;False;1;0.042;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;433;3612.433,2261.281;Inherit;False;Property;_RimLightSoft;RimLightSoft;57;0;Create;True;0;0;0;False;0;False;0.2;0.101;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;445;4091.532,2011.412;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;313;2800.095,-393.8016;Inherit;False;Property;_DarkColor;DarkColor;6;0;Create;True;0;0;0;False;0;False;0.9056604,0.8330367,0.8330367,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;790;4550.289,1306.951;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;420;3101.252,984.6335;Inherit;False;Property;_SpecularRange;SpecularRange;45;0;Create;True;0;0;0;False;0;False;-0.75;-0.763;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;902;3222.174,-2095.097;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;495;3097.617,1536.736;Inherit;False;Property;_SpecularMaskRange01;SpecularMaskRange01;49;0;Create;True;0;0;0;False;0;False;-0.2;0.5;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;608;4511.866,1163.353;Inherit;False;Constant;_Vector0;Vector 0;48;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;596;3533.7,1830.072;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;730;1801.539,-297.9193;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;462;2786.035,2218.01;Inherit;False;Property;_RimOffset;RimOffset;58;0;Create;True;0;0;0;False;0;False;0.16;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeLightColorNode;895;4557.382,1034.395;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;497;3669.588,1577.216;Inherit;False;Property;_SpecularColor01;SpecularColor01;48;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;595;3197.7,1841.072;Inherit;False;Property;_SpecularSoft02;SpecularSoft02;53;0;Create;True;0;0;0;False;0;False;50;50;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;391;3627.809,30.15003;Inherit;True;Property;_EmissiveTex;EmissiveTex;36;1;[Header];Create;True;1;__________________Emissive____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;908;4217.323,-2271.483;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;3384.757,1538.92;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;939;2520.528,391.4173;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;970;5366.359,391.4402;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;910;3910.306,-2305.331;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;299;2273.575,-565.6318;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;318;3477.605,-506.8843;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;886;2237.857,-96.31665;Inherit;False;Property;_VertexColorAlphaFixDarkRange;VertexColorAlphaFixDarkRange;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;308;2861.015,-481.1523;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;597;3681.836,1515.996;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;523;3968.866,498.647;Inherit;True;Property;_EmissiveBlendTex;EmissiveBlendTex;39;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;967;4603.591,-923.2166;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;3122.313,1748.548;Inherit;False;Property;_SpecularMaskRange02;SpecularMaskRange02;52;0;Create;True;0;0;0;False;0;False;-0.1;-1;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;516;5065.059,1007.812;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;909;4092.307,-2270.331;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;911;4584.105,-2142.508;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;419;3384.311,964.8466;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;565;2877.762,-939.4848;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;407;1955.331,-1073.421;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;505;3642.22,1748.458;Inherit;False;Property;_SpecularColor02;SpecularColor02;51;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;919;5145.003,-2293.903;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ComponentMaskNode;969;2755.697,-1379.213;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;920;4579.016,-2490.235;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;555;1717.499,-915.7078;Inherit;False;Property;_RampRange;RampRange;24;0;Create;True;0;0;0;False;0;False;0.8;0.8;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;553;1648.082,-992.2469;Inherit;False;Constant;_dotfix;dotfix;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;554;1820.082,-1074.247;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;982;1697.735,-1093.948;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;421;3895.494,1118.164;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;599;3591.493,985.6595;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;2487.982,-336.5942;Inherit;False;Property;_DarkSoft;DarkSoft;8;0;Create;True;0;0;0;False;0;False;0.1;0.035;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;443;3459.299,2095.346;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;976;4165.113,2469.202;Inherit;False;Property;_RimPower;RimPower;59;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;251;2193.854,-1453.849;Inherit;False;Property;_BaseColor;BaseColor;4;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;535;3513.833,471.5457;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;598;3822.091,1788.42;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;745;1959.522,-292.2901;Inherit;False;FixLightHeight;-1;;170;38674e54ca9510a46bffe97b4729b4a5;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.6;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;504;3891.405,1561.343;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;439;2752.522,2068.813;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;594;3521.881,1560.777;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;2597,-481;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;487;1323.545,432.7551;Inherit;False;Property;_MatcapBlend;MatcapBlend;34;0;Create;False;0;0;0;False;0;False;1;0.434;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;814;3919.219,2267.459;Inherit;True;Property;_RimMask;RimMask(B);54;1;[Header];Create;False;1;__________________RimLight____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;306;2736,-480;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;965;4771.593,-972.2164;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;932;2797.065,250.9871;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;538;4003.443,1403.643;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;493;3533.145,1357.302;Inherit;True;Property;_SpecularMask;SpecularMask(G);43;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;941;2681.854,310.2851;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;822;3656.226,-339.0834;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;856;4291.474,479.4138;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;815;1720.276,479.9265;Inherit;True;Property;_MatcapMask;MatcapMask(R);35;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;944;2402.665,239.445;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;968;4159.592,-867.2164;Inherit;False;Property;_BlendTex1Intensity;BlendTex1Intensity;19;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;2638.419,-931.6356;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;253;2341.652,-912.3548;Inherit;False;Property;_RampColor;RampColor;23;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;416;2985.978,36.55581;Inherit;False;Property;_UseMatcap;UseMatcap;30;0;Create;True;0;0;0;False;1;Header(___________________Matcap_________________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;422;3597.515,1114.495;Inherit;False;Property;_SpecularColor;SpecularColor;44;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6581524,0.9622641,0.8877704,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;441;3673.433,2007.28;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;816;2013.453,381.4275;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;2548.998,-1382.582;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;560;3256.781,-120.909;Inherit;False;Property;_ShadowMaskPower;ShadowMaskPower;29;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;2211.488,-326.3843;Inherit;False;Property;_DarkRange;DarkRange;7;0;Create;True;0;0;0;False;0;False;0.2;0.432;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;509;3427.568,1731.759;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;562;3102.243,-172.2254;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;943;2836.915,61.93018;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;427;3268.215,1074.547;Inherit;False;Property;_SpecularSoft;SpecularSoft;46;0;Create;True;0;0;0;False;0;False;5;0.15;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;488;1699.281,255.6946;Inherit;False;Property;_MatcapColor;MatcapColor;32;0;Create;False;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;884;2378.857,-211.3167;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;918;4861.386,-2207.26;Inherit;False;Property;_UseShadowMask;UseShadowMask;26;0;Create;True;0;0;0;False;1;Header(__________________ShadowMask____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;558;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;496;3856.403,1405.305;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;907;4361.15,-2279.987;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;2240.387,-1293.41;Inherit;False;Property;_ColorPower;ColorPower;5;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;934;2256.866,200.3954;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;940;2532.341,241.745;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;980;1395.152,231.4401;Inherit;False;Constant;_Float3;Float 3;57;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;903;3380.157,-2089.468;Inherit;False;FixLightHeight;-1;;168;38674e54ca9510a46bffe97b4729b4a5;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.6;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;431;3201.433,2264.281;Inherit;False;Property;_RimLightRange;RimLightRange;56;0;Create;True;0;0;0;False;0;False;0.9;0.984;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;885;2547.857,-204.3167;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SampleSHNode;567;4410.431,1310.308;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;942;2216.178,279.007;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;834;1597.996,90.31705;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DecodeEnvSplitFlagNode;923;4589.945,1401.979;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;314;3039.743,-502.3484;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;437;4060.431,2100.281;Inherit;False;Property;_RimLightColor;RimLightColor;55;0;Create;True;1;__________________RimLight____________________________________________________________________________________________;0;0;False;0;False;0,0,0,0;0.4708971,0.6365787,0.6981132,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;824;2625.846,-1123.333;Inherit;False;Constant;_Color1;Color 1;47;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;428;3744.842,995.5255;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;935;2519.75,81.09512;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DecodeLightDirectionNode;894;1567.571,-280.6754;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;833;1313.801,15.4931;Inherit;False;BentMatcapNormal;-1;;169;111106acccbe7a249888e78d98d12562;0;1;1;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;930;5179.402,-282.4196;Inherit;False;Property;_AlphaClip;AlphaClip;11;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;978;1441.152,503.4401;Inherit;False;Constant;_Float2;Float 2;57;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;510;4171.366,1459.647;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;440;3235.433,2010.28;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;558;3930.787,-395.6712;Inherit;False;Property;_UseShadowMask;UseShadowMask;26;0;Create;True;0;0;0;False;1;Header(__________________ShadowMask____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;218;2274.046,-1105.322;Inherit;True;Property;_RampTex;RampTex;22;2;[Header];[NoScaleOffset];Create;True;1;__________________Ramp____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;964;4465.591,-922.2166;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;475;3545.813,-622.8191;Inherit;False;Property;_UseSpecular;UseSpecular;42;0;Create;True;0;0;0;False;1;Header(__________________Specular____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;788;4662.896,1242.519;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.6;False;2;FLOAT;0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;444;3875.43,2010.28;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;906;5360.997,-2113.146;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;393;3694.223,218.0085;Inherit;False;Property;_EmissiveColor;EmissiveColor;37;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.1415094,0.1415094,0.1415094,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;4279.527,2062.68;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;2125.53,70.51308;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;987;2143.187,-1074.859;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0.99;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;917;4718.155,-2151.538;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;929;5818.351,-996.7856;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;938;2215.549,428.6585;Inherit;False;Constant;_Float0;Float 0;46;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;904;3643.749,-2261.784;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;641;4888.59,1194.216;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldNormalVector;905;3390.868,-2276.213;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector2Node;534;3514.105,606.7371;Float;False;Property;_EmiBlendSpeed;EmiBlendSpeed;41;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;823;3787.555,-339.9495;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;936;2218.54,348.4724;Inherit;False;Constant;_Float1;Float 1;46;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;981;1568.735,-1074.948;Inherit;False;Constant;_Float4;Float 4;48;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;979;1571.152,181.4401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;537;3332.212,489.8618;Float;False;Property;_EmiBlendTiling;EmiBlendTiling;40;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ComponentMaskNode;966;4459.591,-1086.217;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;556;2771.954,-223.7468;Inherit;True;Property;_ShadowMask;ShadowMask(R);27;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;492;1278.979,154.3542;Inherit;False;Property;_MatcapPower;MatcapPower;33;0;Create;False;0;0;0;False;0;False;1;0.98;0.5;35;0;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeLightDirectionNode;901;2988.206,-2077.853;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;395;3656.387,389.993;Inherit;False;Property;_EmissivePower;EmissivePower;38;0;Create;True;0;0;0;False;0;False;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;937;2376.485,392.0679;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;381;1789.131,52.51306;Inherit;True;Property;_MatcapTex;MatcapTex;31;1;[NoScaleOffset];Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;977;1594.152,433.4401;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;524;3731.75,495.0615;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;825;2549.347,-821.3382;Inherit;False;Property;_RampBlend;RampBlend;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;563;3263.131,-277.38;Inherit;False;Property;_FilpShadowMask;FlipShadowMask;28;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;926;5471.958,-1320.756;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;896;5342.896,670.3017;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;342;5526.515,402.7989;Float;False;True;-1;2;ParaMaterialEditor;500;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_AlphaTest;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;False;True;0;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;0;False;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;3;LightMode=UniversalForward;RenderPipeline=UniversalRenderPipeline;RenderType=Opaque=RenderType;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;343;4008.388,-780.3983;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;341;4281.979,-132.4763;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;900;5342.896,670.3017;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;927;5471.958,-1320.756;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;928;5471.958,-1320.756;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;345;4008.388,-780.3983;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;344;4008.388,-780.3983;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;899;5342.896,670.3017;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;898;5342.896,670.3017;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;925;5981.831,-1003.621;Half;False;True;0;2;ParaMaterialEditor;400;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_AlphaTest;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;897;5520.359,-2120.756;Half;False;True;1;2;ParaMaterialEditor;300;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_AlphaTest;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=AlphaTest=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;False;True;1;1;False;-1;0;False;-1;1;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;0;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;924;5471.958,-1320.756;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;100;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;972;0;377;0
WireConnection;972;1;971;0
WireConnection;384;0;972;0
WireConnection;986;0;384;0
WireConnection;986;1;985;0
WireConnection;986;2;984;0
WireConnection;947;0;946;0
WireConnection;947;1;986;0
WireConnection;950;0;947;0
WireConnection;950;1;948;0
WireConnection;983;0;950;0
WireConnection;951;0;983;0
WireConnection;951;1;949;0
WireConnection;953;0;951;0
WireConnection;975;0;217;4
WireConnection;975;1;974;0
WireConnection;954;0;953;0
WireConnection;954;1;951;0
WireConnection;954;2;952;0
WireConnection;955;0;975;0
WireConnection;956;0;954;0
WireConnection;956;1;955;0
WireConnection;961;0;958;0
WireConnection;961;1;959;4
WireConnection;960;0;955;0
WireConnection;960;1;956;0
WireConnection;960;2;957;0
WireConnection;962;0;960;0
WireConnection;962;1;961;0
WireConnection;963;0;962;0
WireConnection;931;0;963;0
WireConnection;931;1;854;0
WireConnection;397;0;856;0
WireConnection;397;1;516;0
WireConnection;434;0;316;0
WireConnection;434;1;436;0
WireConnection;820;0;563;0
WireConnection;820;1;560;0
WireConnection;461;0;439;0
WireConnection;461;2;462;0
WireConnection;424;0;317;0
WireConnection;424;1;510;0
WireConnection;933;0;965;0
WireConnection;933;1;489;0
WireConnection;933;2;936;0
WireConnection;317;0;565;0
WireConnection;317;1;416;0
WireConnection;390;0;391;0
WireConnection;390;1;393;0
WireConnection;390;2;395;0
WireConnection;316;0;475;0
WireConnection;316;1;318;0
WireConnection;316;2;558;0
WireConnection;445;0;444;0
WireConnection;790;0;567;0
WireConnection;902;0;901;0
WireConnection;596;0;509;0
WireConnection;596;1;595;0
WireConnection;730;0;894;0
WireConnection;908;0;909;0
WireConnection;499;0;419;0
WireConnection;499;1;495;0
WireConnection;939;0;937;0
WireConnection;970;0;931;0
WireConnection;910;0;885;0
WireConnection;910;1;904;0
WireConnection;299;0;384;0
WireConnection;299;1;745;0
WireConnection;318;0;565;0
WireConnection;318;1;313;0
WireConnection;318;2;416;0
WireConnection;308;0;306;0
WireConnection;597;0;594;0
WireConnection;523;1;524;0
WireConnection;967;0;964;0
WireConnection;516;0;434;0
WireConnection;516;1;895;0
WireConnection;516;2;641;0
WireConnection;909;0;910;0
WireConnection;909;1;307;0
WireConnection;911;0;907;0
WireConnection;911;1;820;0
WireConnection;419;0;299;0
WireConnection;419;1;420;0
WireConnection;565;0;824;0
WireConnection;565;1;254;0
WireConnection;565;2;825;0
WireConnection;407;0;554;0
WireConnection;407;1;555;0
WireConnection;919;0;965;0
WireConnection;919;1;920;0
WireConnection;919;2;918;0
WireConnection;969;0;252;0
WireConnection;920;0;965;0
WireConnection;920;1;313;0
WireConnection;554;0;982;0
WireConnection;554;1;553;0
WireConnection;982;0;299;0
WireConnection;982;1;981;0
WireConnection;421;0;428;0
WireConnection;421;1;422;0
WireConnection;421;2;423;0
WireConnection;421;3;493;2
WireConnection;599;0;419;0
WireConnection;599;1;427;0
WireConnection;443;0;440;0
WireConnection;443;1;431;0
WireConnection;535;0;537;0
WireConnection;598;0;596;0
WireConnection;745;1;730;0
WireConnection;504;0;493;2
WireConnection;504;1;598;0
WireConnection;594;0;499;0
WireConnection;594;1;593;0
WireConnection;304;0;299;0
WireConnection;304;1;885;0
WireConnection;306;0;304;0
WireConnection;306;1;307;0
WireConnection;965;0;969;0
WireConnection;965;1;966;0
WireConnection;965;2;967;0
WireConnection;932;0;935;0
WireConnection;932;1;941;0
WireConnection;538;0;421;0
WireConnection;538;1;497;0
WireConnection;538;2;496;0
WireConnection;941;0;940;0
WireConnection;941;1;939;0
WireConnection;822;0;314;0
WireConnection;822;1;820;0
WireConnection;856;0;390;0
WireConnection;856;1;523;0
WireConnection;944;0;934;0
WireConnection;944;1;942;0
WireConnection;944;2;936;0
WireConnection;254;0;218;0
WireConnection;254;1;253;0
WireConnection;416;1;965;0
WireConnection;416;0;943;0
WireConnection;441;0;443;0
WireConnection;816;0;977;0
WireConnection;816;1;815;1
WireConnection;252;0;217;0
WireConnection;252;1;251;0
WireConnection;252;2;260;0
WireConnection;509;0;499;0
WireConnection;509;1;506;0
WireConnection;562;0;556;1
WireConnection;943;0;965;0
WireConnection;943;1;932;0
WireConnection;943;2;816;0
WireConnection;884;0;305;0
WireConnection;884;1;883;4
WireConnection;918;1;907;0
WireConnection;918;0;917;0
WireConnection;496;0;493;2
WireConnection;496;1;597;0
WireConnection;907;0;908;0
WireConnection;934;0;965;0
WireConnection;940;0;944;0
WireConnection;903;1;902;0
WireConnection;885;0;305;0
WireConnection;885;1;884;0
WireConnection;885;2;886;0
WireConnection;942;0;489;0
WireConnection;834;0;833;0
WireConnection;314;0;308;0
WireConnection;428;0;599;0
WireConnection;935;0;933;0
WireConnection;935;1;937;0
WireConnection;833;1;384;0
WireConnection;510;0;538;0
WireConnection;510;1;505;0
WireConnection;510;2;504;0
WireConnection;440;0;384;0
WireConnection;440;1;461;0
WireConnection;558;1;314;0
WireConnection;558;0;823;0
WireConnection;218;1;987;0
WireConnection;964;0;959;4
WireConnection;964;1;968;0
WireConnection;475;1;317;0
WireConnection;475;0;424;0
WireConnection;788;0;790;0
WireConnection;444;0;441;0
WireConnection;444;1;433;0
WireConnection;906;0;895;0
WireConnection;906;1;919;0
WireConnection;906;2;641;0
WireConnection;436;0;445;0
WireConnection;436;1;437;0
WireConnection;436;2;814;3
WireConnection;436;3;976;0
WireConnection;489;0;381;0
WireConnection;489;1;488;0
WireConnection;489;2;979;0
WireConnection;987;0;407;0
WireConnection;917;0;911;0
WireConnection;929;0;906;0
WireConnection;929;1;856;0
WireConnection;904;0;905;0
WireConnection;904;1;903;0
WireConnection;641;0;608;0
WireConnection;641;1;788;0
WireConnection;641;2;923;0
WireConnection;823;0;822;0
WireConnection;979;0;492;0
WireConnection;979;1;980;0
WireConnection;966;0;959;0
WireConnection;937;0;489;0
WireConnection;937;1;938;0
WireConnection;381;1;834;0
WireConnection;977;0;487;0
WireConnection;977;1;978;0
WireConnection;524;0;535;0
WireConnection;524;2;534;0
WireConnection;563;1;556;1
WireConnection;563;0;562;0
WireConnection;342;2;397;0
WireConnection;342;3;970;0
WireConnection;342;4;930;0
WireConnection;925;2;929;0
WireConnection;925;3;970;0
WireConnection;925;4;930;0
WireConnection;897;2;906;0
WireConnection;897;3;970;0
WireConnection;897;4;930;0
ASEEND*/
//CHKSM=C8B46D6C27FC08B0A591F1C6A85E1F35EBED6126