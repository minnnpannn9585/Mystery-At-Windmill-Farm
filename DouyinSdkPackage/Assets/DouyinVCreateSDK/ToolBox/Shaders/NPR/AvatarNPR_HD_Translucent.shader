// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Douyin/Avatar/Cartoon/AvatarNPR_HD_Translucent"
{
	Properties
	{
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[Enum(Off,0,On,1)]_Zwrite("Zwrite", Float) = 0
		[HideInInspector][Toggle(_ALPHAACTOR_ON)] _ALPHAACTOR("_ALPHAACTOR", Float) = 0
		[HideInInspector]_ActorRadius("ActorRadius", Range( 0 , 1)) = 0.4
		[Header(___________________BaseTex____________________________________________________________________________________________)]_BaseTex("BaseTex(A)Translucent", 2D) = "white" {}
		_BaseColor("BaseColor", Color) = (1,1,1,1)
		_ColorPower("ColorPower", Range( 0 , 20)) = 1
		_DarkColor("DarkColor", Color) = (0.9056604,0.8330367,0.8330367,0)
		_DarkRange("DarkRange", Range( -1 , 1)) = 0.2
		_DarkSoft("DarkSoft", Range( 0 , 1)) = 0.1
		_VertexColorAlphaFixDarkRange("VertexColorAlphaFixDarkRange", Range( 0 , 1)) = 0
		[Header(__________________Translucent____________________________________________________________________________________________)]_Translucent("Translucent", Range( 0 , 1)) = 1
		_FresnelPower("FresnelPower", Range( 0 , 30)) = 2
		_FresnelWidth("FresnelWidth", Range( 0 , 2)) = 0
		_FresnelBlendIntensity("FresnelBlendIntensity", Range( 0 , 1)) = 0
		_EdgeNormalMapIntensity("EdgeNormalMapIntensity", Range( 0 , 1)) = 0
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
		_ShadowMask("ShadowMask(R)", 2D) = "black" {}
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

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
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
			
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite [_Zwrite]
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
				float4 temp_output_390_0 = ( tex2D( _EmissiveTex, uv_EmissiveTex ) * _EmissiveColor * _EmissivePower );
				float2 texCoord535 = IN.ase_texcoord3.xy * _EmiBlendTiling + float2( 0,0 );
				float2 panner524 = ( 1.0 * _Time.y * _EmiBlendSpeed + texCoord535);
				float4 color777 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float4 mainlight787 = GetMainLightDir(  );
				float3 break6_g161 = (mainlight787).xyz;
				float3 appendResult8_g161 = (float3(break6_g161.x , 0.0 , break6_g161.z));
				float3 normalizeResult9_g161 = normalize( appendResult8_g161 );
				float temp_output_2_0_g161 = 0.6;
				float3 break12_g161 = ( normalizeResult9_g161 * sqrt( ( 1.0 - pow( temp_output_2_0_g161 , 2.0 ) ) ) );
				float3 appendResult11_g161 = (float3(break12_g161.x , temp_output_2_0_g161 , break12_g161.z));
				float dotResult299 = dot( tangentToWorldDir737 , appendResult11_g161 );
				float clampResult898 = clamp( (( ( dotResult299 + 1.0 ) * 0.5 )*_RampRange + 0.0) , 0.01 , 0.99 );
				float2 temp_cast_1 = (clampResult898).xx;
				float4 lerpResult565 = lerp( color777 , ( tex2D( _RampTex, temp_cast_1 ) * _RampColor ) , _RampBlend);
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float3 appendResult766 = (float3(tex2DNode217.r , tex2DNode217.g , tex2DNode217.b));
				float3 appendResult767 = (float3(_BaseColor.r , _BaseColor.g , _BaseColor.b));
				float3 temp_output_871_0 = saturate( ( appendResult766 * appendResult767 * _ColorPower ) );
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float3 lerpResult869 = lerp( temp_output_871_0 , (tex2DNode864).rgb , saturate( ( tex2DNode864.a * _BlendTex1Intensity ) ));
				float3 normalizeResult5_g162 = normalize( ( _WorldSpaceCameraPos - WorldPosition ) );
				float4 appendResult8_g162 = (float4(reflect( normalizeResult5_g162 , tangentToWorldDir737 ) , 0.0));
				float3 normalizeResult11_g162 = normalize( (mul( unity_WorldToCamera, appendResult8_g162 )).xyz );
				float3 break12_g162 = normalizeResult11_g162;
				float2 appendResult16_g162 = (float2(break12_g162.x , break12_g162.y));
				float4 temp_output_489_0 = ( tex2D( _MatcapTex, ( 1.0 - ( ( appendResult16_g162 / ( sqrt( ( break12_g162.z + 1.0 ) ) * 2.828427 ) ) + float2( 0.5,0.5 ) ) ) ) * _MatcapColor * ( _MatcapPower * 0.4 ) );
				float4 temp_cast_5 = (0.5).xxxx;
				float4 temp_output_827_0 = step( temp_output_489_0 , temp_cast_5 );
				float4 temp_cast_7 = (0.5).xxxx;
				float2 uv_MatcapMask = IN.ase_texcoord3.xy * _MatcapMask_ST.xy + _MatcapMask_ST.zw;
				float4 lerpResult833 = lerp( float4( lerpResult869 , 0.0 ) , ( ( ( float4( lerpResult869 , 0.0 ) * temp_output_489_0 * 2.0 ) * temp_output_827_0 ) + ( ( 1.0 - ( float4( ( 1.0 - lerpResult869 ) , 0.0 ) * ( 1.0 - temp_output_489_0 ) * 2.0 ) ) * ( 1.0 - temp_output_827_0 ) ) ) , ( ( _MatcapBlend * 0.1 ) * tex2D( _MatcapMask, uv_MatcapMask ).r ));
				#ifdef _USEMATCAP_ON
				float4 staticSwitch416 = lerpResult833;
				#else
				float4 staticSwitch416 = float4( lerpResult869 , 0.0 );
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
				float lerpResult781 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float temp_output_314_0 = ( 1.0 - saturate( ( ( dotResult299 + lerpResult781 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_561_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch558 = saturate( ( temp_output_314_0 + temp_output_561_0 ) );
				#else
				float staticSwitch558 = temp_output_314_0;
				#endif
				float4 lerpResult316 = lerp( staticSwitch475 , ( lerpResult565 * _DarkColor * staticSwitch416 ) , staticSwitch558);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult440 = dot( tangentToWorldDir737 , (ase_worldViewDir*1.0 + _RimOffset) );
				float2 uv_RimMask = IN.ase_texcoord3.xy * _RimMask_ST.xy + _RimMask_ST.zw;
				float4 mainlightColor788 = GetMainLightColor(  );
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag815 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag815);
				float4 temp_output_516_0 = ( ( lerpResult316 + ( saturate( ( ( 1.0 - ( dotResult440 + _RimLightRange ) ) / _RimLightSoft ) ) * _RimLightColor * tex2D( _RimMask, uv_RimMask ).b * _RimPower ) ) * mainlightColor788 * float4( lerpResult641 , 0.0 ) );
				
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( temp_output_390_0 * tex2D( _EmissiveBlendTex, panner524 ) ) + temp_output_516_0 ).rgb;
				float Alpha = temp_output_754_0;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
				float AlphaClipThreshold = 0.5;
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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
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
	SubShader
	{
		LOD 400

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
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
			
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite [_Zwrite]
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
				float4 temp_output_390_0 = ( tex2D( _EmissiveTex, uv_EmissiveTex ) * _EmissiveColor * _EmissivePower );
				float4 color777 = IsGammaSpace() ? float4(1,1,1,1) : float4(1,1,1,1);
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord4.xyz;
				float3 ase_worldNormal = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float4 mainlight787 = GetMainLightDir(  );
				float3 break6_g161 = (mainlight787).xyz;
				float3 appendResult8_g161 = (float3(break6_g161.x , 0.0 , break6_g161.z));
				float3 normalizeResult9_g161 = normalize( appendResult8_g161 );
				float temp_output_2_0_g161 = 0.6;
				float3 break12_g161 = ( normalizeResult9_g161 * sqrt( ( 1.0 - pow( temp_output_2_0_g161 , 2.0 ) ) ) );
				float3 appendResult11_g161 = (float3(break12_g161.x , temp_output_2_0_g161 , break12_g161.z));
				float dotResult299 = dot( tangentToWorldDir737 , appendResult11_g161 );
				float clampResult898 = clamp( (( ( dotResult299 + 1.0 ) * 0.5 )*_RampRange + 0.0) , 0.01 , 0.99 );
				float2 temp_cast_1 = (clampResult898).xx;
				float4 lerpResult565 = lerp( color777 , ( tex2D( _RampTex, temp_cast_1 ) * _RampColor ) , _RampBlend);
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float3 appendResult766 = (float3(tex2DNode217.r , tex2DNode217.g , tex2DNode217.b));
				float3 appendResult767 = (float3(_BaseColor.r , _BaseColor.g , _BaseColor.b));
				float3 temp_output_871_0 = saturate( ( appendResult766 * appendResult767 * _ColorPower ) );
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float3 lerpResult869 = lerp( temp_output_871_0 , (tex2DNode864).rgb , saturate( ( tex2DNode864.a * _BlendTex1Intensity ) ));
				float3 normalizeResult5_g162 = normalize( ( _WorldSpaceCameraPos - WorldPosition ) );
				float4 appendResult8_g162 = (float4(reflect( normalizeResult5_g162 , tangentToWorldDir737 ) , 0.0));
				float3 normalizeResult11_g162 = normalize( (mul( unity_WorldToCamera, appendResult8_g162 )).xyz );
				float3 break12_g162 = normalizeResult11_g162;
				float2 appendResult16_g162 = (float2(break12_g162.x , break12_g162.y));
				float4 temp_output_489_0 = ( tex2D( _MatcapTex, ( 1.0 - ( ( appendResult16_g162 / ( sqrt( ( break12_g162.z + 1.0 ) ) * 2.828427 ) ) + float2( 0.5,0.5 ) ) ) ) * _MatcapColor * ( _MatcapPower * 0.4 ) );
				float4 temp_cast_5 = (0.5).xxxx;
				float4 temp_output_827_0 = step( temp_output_489_0 , temp_cast_5 );
				float4 temp_cast_7 = (0.5).xxxx;
				float2 uv_MatcapMask = IN.ase_texcoord3.xy * _MatcapMask_ST.xy + _MatcapMask_ST.zw;
				float4 lerpResult833 = lerp( float4( lerpResult869 , 0.0 ) , ( ( ( float4( lerpResult869 , 0.0 ) * temp_output_489_0 * 2.0 ) * temp_output_827_0 ) + ( ( 1.0 - ( float4( ( 1.0 - lerpResult869 ) , 0.0 ) * ( 1.0 - temp_output_489_0 ) * 2.0 ) ) * ( 1.0 - temp_output_827_0 ) ) ) , ( ( _MatcapBlend * 0.1 ) * tex2D( _MatcapMask, uv_MatcapMask ).r ));
				#ifdef _USEMATCAP_ON
				float4 staticSwitch416 = lerpResult833;
				#else
				float4 staticSwitch416 = float4( lerpResult869 , 0.0 );
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
				float lerpResult781 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float temp_output_314_0 = ( 1.0 - saturate( ( ( dotResult299 + lerpResult781 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_561_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch558 = saturate( ( temp_output_314_0 + temp_output_561_0 ) );
				#else
				float staticSwitch558 = temp_output_314_0;
				#endif
				float4 lerpResult316 = lerp( staticSwitch475 , ( lerpResult565 * _DarkColor * staticSwitch416 ) , staticSwitch558);
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult440 = dot( tangentToWorldDir737 , (ase_worldViewDir*1.0 + _RimOffset) );
				float2 uv_RimMask = IN.ase_texcoord3.xy * _RimMask_ST.xy + _RimMask_ST.zw;
				float4 mainlightColor788 = GetMainLightColor(  );
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag815 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag815);
				float4 temp_output_516_0 = ( ( lerpResult316 + ( saturate( ( ( 1.0 - ( dotResult440 + _RimLightRange ) ) / _RimLightSoft ) ) * _RimLightColor * tex2D( _RimMask, uv_RimMask ).b * _RimPower ) ) * mainlightColor788 * float4( lerpResult641 , 0.0 ) );
				
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( temp_output_390_0 + temp_output_516_0 ).rgb;
				float Alpha = temp_output_754_0;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
				float AlphaClipThreshold = 0.5;
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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
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
	
SubShader
	{
		LOD 300

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
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
			
			Blend SrcAlpha OneMinusSrcAlpha, SrcAlpha OneMinusSrcAlpha
			ZWrite [_Zwrite]
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			Cull [_CullMode]
			

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
			sampler2D _ShadowMask;
			sampler2D _Normalmap;
			sampler2D _BlendTex1;


						
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
				float4 mainlightColor788 = GetMainLightColor(  );
				float2 uv_BaseTex = IN.ase_texcoord3.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float3 appendResult766 = (float3(tex2DNode217.r , tex2DNode217.g , tex2DNode217.b));
				float3 appendResult767 = (float3(_BaseColor.r , _BaseColor.g , _BaseColor.b));
				float3 temp_output_871_0 = saturate( ( appendResult766 * appendResult767 * _ColorPower ) );
				float lerpResult781 = lerp( _DarkRange , ( _DarkRange * IN.ase_color.a ) , _VertexColorAlphaFixDarkRange);
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float4 mainlight797 = GetMainLightDir(  );
				float3 break6_g160 = (mainlight797).xyz;
				float3 appendResult8_g160 = (float3(break6_g160.x , 0.0 , break6_g160.z));
				float3 normalizeResult9_g160 = normalize( appendResult8_g160 );
				float temp_output_2_0_g160 = 0.6;
				float3 break12_g160 = ( normalizeResult9_g160 * sqrt( ( 1.0 - pow( temp_output_2_0_g160 , 2.0 ) ) ) );
				float3 appendResult11_g160 = (float3(break12_g160.x , temp_output_2_0_g160 , break12_g160.z));
				float dotResult802 = dot( ase_worldNormal , appendResult11_g160 );
				float temp_output_804_0 = ( 1.0 - saturate( ( ( lerpResult781 + dotResult802 ) / _DarkSoft ) ) );
				float2 uv_ShadowMask = IN.ase_texcoord3.xy * _ShadowMask_ST.xy + _ShadowMask_ST.zw;
				float4 tex2DNode556 = tex2D( _ShadowMask, uv_ShadowMask );
				#ifdef _FILPSHADOWMASK_ON
				float staticSwitch563 = ( 1.0 - tex2DNode556.r );
				#else
				float staticSwitch563 = tex2DNode556.r;
				#endif
				float temp_output_561_0 = ( staticSwitch563 * _ShadowMaskPower );
				#ifdef _USESHADOWMASK_ON
				float staticSwitch801 = saturate( ( temp_output_804_0 + temp_output_561_0 ) );
				#else
				float staticSwitch801 = temp_output_804_0;
				#endif
				float4 lerpResult807 = lerp( float4( temp_output_871_0 , 0.0 ) , ( float4( temp_output_871_0 , 0.0 ) * _DarkColor ) , staticSwitch801);
				float3 shColorResult567 = SampleSH( float3( 0,0,0 ) );
				float splitFlag815 = GetEnvSplitFlag(  );
				float3 lerpResult641 = lerp( float3(1,1,1) , (saturate( shColorResult567 )*0.6 + 0.2) , splitFlag815);
				
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord3.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord5.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord6.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord3.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord7;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( mainlightColor788 * lerpResult807 * float4( lerpResult641 , 0.0 ) ).xyz;
				float Alpha = temp_output_754_0;
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
				float AlphaClipThreshold = 0.5;
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

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#pragma multi_compile_fog
			#define ASE_FOG 1
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
			float4 _BaseColor;
			float4 _RimLightColor;
			float4 _MatcapMask_ST;
			float4 _RimMask_ST;
			float4 _DarkColor;
			float4 _MatcapColor;
			float4 _SpecularColor01;
			float4 _BlendTex1_ST;
			float4 _EmissiveTex_ST;
			float4 _SpecularColor;
			float4 _RampColor;
			float4 _SpecularColor02;
			float4 _ShadowMask_ST;
			float4 _Normalmap_ST;
			float4 _EmissiveColor;
			float4 _BaseTex_ST;
			float4 _SpecularMask_ST;
			float2 _EmiBlendSpeed;
			float2 _EmiBlendTiling;
			float _RampBlend;
			float _ActorRadius;
			float _SpecularMaskRange01;
			float _ShadowMaskPower;
			float _RimOffset;
			float _DarkSoft;
			float _Zwrite;
			float _RimPower;
			float _RimLightSoft;
			float _Translucent;
			float _MatcapBlend;
			float _FresnelWidth;
			float _FresnelPower;
			float _FlipFresnel;
			float _FresnelBlendIntensity;
			float _RimLightRange;
			float _VertexColorAlphaFixDarkRange;
			float _EdgeNormalMapIntensity;
			float _SpecularSoft02;
			float _MatcapPower;
			float _EmissivePower;
			float _SpecularMaskRange02;
			float _SpecularSoft01;
			float _BlendTexAlpha;
			float _NormalIntensity;
			float _SpecularRange;
			float _SpecularPower;
			float _DarkRange;
			float _BlendTex1Intensity;
			float _ColorPower;
			float _RampRange;
			float _SpecularSoft;
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


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

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

				float2 uv_BaseTex = IN.ase_texcoord2.xy * _BaseTex_ST.xy + _BaseTex_ST.zw;
				float4 tex2DNode217 = tex2D( _BaseTex, uv_BaseTex );
				float temp_output_847_0 = saturate( ( tex2DNode217.a * _Translucent ) );
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 uv_Normalmap = IN.ase_texcoord2.xy * _Normalmap_ST.xy + _Normalmap_ST.zw;
				float3 unpack875 = UnpackNormalScale( tex2D( _Normalmap, uv_Normalmap ), _NormalIntensity );
				unpack875.z = lerp( 1, unpack875.z, saturate(_NormalIntensity) );
				float3 normalizeResult736 = normalize( unpack875 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
				float3 tangentToWorldDir737 = normalize( mul( ase_tangentToWorldFast, normalizeResult736 ) );
				float3 lerpResult884 = lerp( tangentToWorldDir737 , ase_worldNormal , _EdgeNormalMapIntensity);
				float dotResult849 = dot( ase_worldViewDir , lerpResult884 );
				float temp_output_853_0 = pow( abs( ( dotResult849 + _FresnelWidth ) ) , _FresnelPower );
				float lerpResult856 = lerp( ( 1.0 - temp_output_853_0 ) , temp_output_853_0 , _FlipFresnel);
				float lerpResult859 = lerp( temp_output_847_0 , ( lerpResult856 * temp_output_847_0 ) , _FresnelBlendIntensity);
				float2 uv_BlendTex1 = IN.ase_texcoord2.xy * _BlendTex1_ST.xy + _BlendTex1_ST.zw;
				float4 tex2DNode864 = tex2D( _BlendTex1, uv_BlendTex1 );
				float4 screenPos = IN.ase_texcoord6;
				float2 appendResult5_g39 = (float2(_ScreenParams.x , _ScreenParams.y));
				float smoothstepResult21_g39 = smoothstep( ( _ActorRadius - 0.2 ) , _ActorRadius , length( ( frac( ( ( (screenPos).xy / screenPos.w ) * appendResult5_g39 * float2( 0.25,0.25 ) ) ) - float2( 0.5,0.5 ) ) ));
				#ifdef _ALPHAACTOR_ON
				float staticSwitch13_g39 = ( 1.0 - smoothstepResult21_g39 );
				#else
				float staticSwitch13_g39 = 1.0;
				#endif
				float temp_output_754_0 = saturate( ( saturate( ( lerpResult859 + ( _BlendTexAlpha * tex2DNode864.a ) ) ) * staticSwitch13_g39 ) );
				
				float Alpha = temp_output_754_0;
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
	

	CustomEditor "ParaMaterialEditor"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18912
2560;0;2560;1371;-871.3998;1613.277;1.16184;True;True
Node;AmplifyShaderEditor.CommentaryNode;399;851.0546,-8.064751;Inherit;False;2438.082;561.7175;matcap;28;377;488;381;489;416;487;492;736;737;729;771;779;822;823;824;825;826;827;828;829;830;831;832;833;834;875;878;879;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;876;655.853,331.61;Inherit;False;Property;_NormalIntensity;NormalIntensity;21;0;Create;True;0;0;0;False;0;False;1;1;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;377;633.4944,145.816;Inherit;True;Property;_Normalmap;Normalmap;20;2;[Header];[Normal];Create;True;1;__________________Normalmap____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;True;bump;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnpackScaleNormalNode;875;931.324,160.9843;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;873;3175.368,-1645.301;Inherit;False;1872.476;910.8859;BlendTex1;28;886;887;884;850;343;870;865;869;867;868;872;861;859;862;863;858;864;860;856;857;855;853;854;852;851;849;847;888;;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;736;1155.994,156.5051;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;887;3154.583,-1058.75;Inherit;False;Property;_EdgeNormalMapIntensity;EdgeNormalMapIntensity;15;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;737;1310.232,137.4484;Inherit;False;Tangent;World;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;886;3156.432,-1202.499;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;884;3341.232,-1440.6;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;850;3327.067,-1607.001;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;849;3533.287,-1484.134;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;851;3371.243,-1343.988;Inherit;False;Property;_FresnelWidth;FresnelWidth;13;0;Create;True;0;0;0;False;0;False;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;852;3665.243,-1468.988;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;888;3776.31,-1518.074;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;400;2222.615,-1704.448;Inherit;False;622.6589;515.444;Basecolor;6;766;260;251;252;767;217;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;854;3587.462,-1286.93;Inherit;False;Property;_FresnelPower;FresnelPower;12;0;Create;True;0;0;0;False;0;False;2;2;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;853;3863.462,-1444.93;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;217;2263.814,-1658.773;Inherit;True;Property;_BaseTex;BaseTex(A)Translucent;4;1;[Header];Create;False;1;___________________BaseTex____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;775;2839.731,-1269.997;Inherit;False;Property;_Translucent;Translucent;11;1;[Header];Create;True;1;__________________Translucent____________________________________________________________________________________________;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;763;3144.091,-1385.958;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;855;4018.462,-1451.93;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;857;3883.462,-1328.93;Inherit;False;Property;_FlipFresnel;FlipFresnel;16;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;856;4172.46,-1390.93;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;847;3292.717,-1278.539;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;858;4343.46,-1342.93;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;860;4209.218,-1239.446;Inherit;False;Property;_FresnelBlendIntensity;FresnelBlendIntensity;14;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;863;4278.842,-1166.415;Inherit;False;Property;_BlendTexAlpha;BlendTexAlpha;18;0;Create;True;0;0;0;False;0;False;0;0;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;864;4224.842,-1095.415;Inherit;True;Property;_BlendTex1;BlendTex1;17;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;859;4496.562,-1302.684;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;862;4555.842,-1161.415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;861;4695.842,-1251.415;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;872;4819.655,-1249.771;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;734;5101.009,-731.6459;Inherit;True;AlphaActor;1;;39;92bf20db17d0d2b46abe078b3b0cece6;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;809;2954.25,-2277.79;Inherit;False;2618.624;609.1982;LODshader;15;789;791;794;795;796;797;798;799;800;801;802;803;804;805;807;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;644;4011.757,1107.537;Inherit;False;730.6221;410.9987;SH Sampler;6;608;747;748;641;567;815;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;469;2080.759,1580.346;Inherit;False;1737.255;454.986;RimLight;12;461;462;440;441;437;439;436;445;444;443;431;433;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;752;5367.583,-758.1015;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;398;3316.807,-5.925011;Inherit;False;1406.333;897.0668;Emissve;11;391;534;390;393;395;523;537;769;524;535;434;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;403;1243.026,-696.5774;Inherit;False;3088.906;660.9754;CartoonLight;27;316;558;774;773;561;563;562;305;317;732;730;299;318;307;304;556;475;308;306;313;560;314;780;781;782;783;787;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;429;2081.956,573.3625;Inherit;False;1222.921;982.5642;Specular;26;538;510;422;421;419;424;499;509;506;505;423;496;427;493;428;497;495;420;504;593;594;596;595;597;598;599;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;845;6297.788,1676.864;Inherit;False;426.7979;633;Stencil;8;838;839;840;841;842;843;844;835;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;401;1444.745,-1171.522;Inherit;False;1398.141;447.4977;Ramp;11;898;777;555;218;883;407;554;553;882;254;253;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;427;2240.357,719.8498;Inherit;False;Property;_SpecularSoft;SpecularSoft;46;0;Create;True;0;0;0;False;0;False;5;0.15;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;829;2719.208,433.3885;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;804;4377.19,-2047.529;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;475;3627.563,-640.8965;Inherit;False;Property;_UseSpecular;UseSpecular;42;0;Create;True;0;0;0;False;1;Header(__________________Specular____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;253;2325.653,-935.9548;Inherit;False;Property;_RampColor;RampColor;23;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;317;3315.333,-638.8862;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;307;2291.818,-351.4871;Inherit;False;Property;_DarkSoft;DarkSoft;9;0;Create;True;0;0;0;False;0;False;0.1;0.035;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;495;2069.759,1182.039;Inherit;False;Property;_SpecularMaskRange01;SpecularMaskRange01;49;0;Create;True;0;0;0;False;0;False;-0.2;0.5;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;879;1601.005,293.3507;Inherit;False;Constant;_Float2;Float 2;57;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;823;2553.6,82.65544;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DecodeEnvSplitFlagNode;815;4361.782,1437.957;Inherit;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;841;6507.586,1964.864;Inherit;False;Property;_StencilFail;StencilFail;64;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;420;2073.394,629.9371;Inherit;False;Property;_SpecularRange;SpecularRange;45;0;Create;True;0;0;0;False;0;False;-0.75;-0.763;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;782;1800.865,-311.9451;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;608;4186.966,1146.474;Inherit;False;Constant;_Vector0;Vector 0;48;0;Create;True;0;0;0;False;0;False;1,1,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;878;1775.005,232.3507;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;838;6506.586,1726.864;Inherit;False;Property;_StencilRef;StencilRef;61;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;419;2356.453,610.1498;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;877;3399.185,2137.499;Inherit;False;Property;_RimPower;RimPower;59;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;834;2593.444,241.4649;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;504;2863.547,1206.646;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;4070.724,180.6328;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;869;4865.842,-942.415;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;535;3506.833,484.5457;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;252;2711.274,-1397.004;Inherit;False;3;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;537;3335.212,489.8618;Inherit;False;Property;_EmiBlendTiling;EmiBlendTiling;40;0;Create;True;0;0;0;False;0;False;1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;2583.049,-906.6675;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;439;2132.526,1695.005;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;299;2131.215,-589.8134;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;748;4206.606,1303.03;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;776;2454.695,-761.5841;Inherit;False;Property;_RampBlend;RampBlend;25;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;487;1566.479,534.5511;Inherit;False;Property;_MatcapBlend;MatcapBlend;34;0;Create;True;0;0;0;False;0;False;1;0.434;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;780;1964.865,-273.9449;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;506;2142.455,1397.851;Inherit;False;Property;_SpecularMaskRange02;SpecularMaskRange02;52;0;Create;True;0;0;0;False;0;False;-0.1;-1;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;599;2563.635,630.9626;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;826;2402.869,380.4941;Inherit;False;Constant;_Float0;Float 0;46;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;524;3731.75,495.0615;Inherit;True;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;865;4559.842,-892.4152;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;732;1732.097,-564.7647;Inherit;False;FixLightHeight;-1;;161;38674e54ca9510a46bffe97b4729b4a5;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.6;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;754;5503.666,-759.2209;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;871;2881.48,-1399.992;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;556;2796.408,-324.1408;Inherit;True;Property;_ShadowMask;ShadowMask(R);27;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;827;2575.165,433.8141;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.5;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;598;2812.558,1455.713;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;795;4600.145,-1910.05;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;822;3024.669,272.455;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;488;1938.809,215.8684;Inherit;False;Property;_MatcapColor;MatcapColor;32;0;Create;True;0;0;0;False;0;False;1,1,1,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;516;4774.194,689.4302;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;555;1623.823,-954.4873;Inherit;False;Property;_RampRange;RampRange;24;0;Create;True;0;0;0;False;0;False;0.8;0.8;0.1;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;824;2418.801,233.2505;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;833;2959.894,91.827;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwizzleNode;730;1531.577,-564.9062;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;308;2671.665,-510.7237;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;897;5055.256,112.9858;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;881;1723.625,646.0081;Inherit;False;Constant;_Float3;Float 3;57;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;562;3083.205,-265.4572;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;779;1764.706,88.98219;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;510;3143.507,1104.95;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;789;5427.871,-1944.981;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;437;3458.433,1721.472;Inherit;False;Property;_RimLightColor;RimLightColor;55;0;Create;True;1;__________________RimLight____________________________________________________________________________________________;0;0;False;0;False;0,0,0,0;0.4708971,0.6365787,0.6981132,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;794;4108.35,-2037.873;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;883;1596.461,-1121.07;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;441;3053.436,1633.472;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;729;1563.599,133.9331;Inherit;False;BentMatcapNormal;-1;;162;111106acccbe7a249888e78d98d12562;0;1;1;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;830;2738.145,240.9398;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;791;4536.953,-2181.616;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;563;3233.484,-293.4583;Inherit;False;Property;_FilpShadowMask;FlipShadowMask;28;0;Create;False;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;783;1823.865,-158.9448;Inherit;False;Property;_VertexColorAlphaFixDarkRange;VertexColorAlphaFixDarkRange;10;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;880;1876.625,576.0081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;313;3454.834,-495.709;Inherit;False;Property;_DarkColor;DarkColor;7;0;Create;True;0;0;0;False;0;False;0.9056604,0.8330367,0.8330367,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;314;2829.966,-510.5428;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;593;2123.023,1280.08;Inherit;False;Property;_SpecularSoft01;SpecularSoft01;50;0;Create;True;0;0;0;False;0;False;50;50;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;870;4553.842,-1056.415;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;434;4391.036,685.1833;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;594;2494.023,1206.08;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;509;2430.71,1364.062;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;596;2505.842,1475.375;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;381;1928.584,31.62094;Inherit;True;Property;_MatcapTex;MatcapTex;31;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;306;2536.976,-507.3793;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;773;3614.123,-283.5952;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;747;4353.647,1272.672;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;0.6;False;2;FLOAT;0.2;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;433;2983.436,1876.472;Inherit;False;Property;_RimLightSoft;RimLightSoft;57;0;Create;True;0;0;0;False;0;False;0.2;0.101;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;839;6504.586,1802.864;Inherit;False;Property;_StencilFunc;StencilFunc;62;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;497;2641.73,1222.519;Inherit;False;Property;_SpecularColor01;SpecularColor01;48;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;595;2169.842,1486.375;Inherit;False;Property;_SpecularSoft02;SpecularSoft02;53;0;Create;True;0;0;0;False;0;False;50;50;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SampleSHNode;567;4035.432,1304.529;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;770;3342.99,1896.068;Inherit;True;Property;_RimMask;RimMask(B);54;1;[Header];Create;False;1;__________________RimLight____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;807;5140.637,-2120.812;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DotProductOpNode;802;3659.794,-2029.326;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeLightDirectionNode;797;2997.549,-1890.622;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;489;2232.584,47.62098;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;304;2387.043,-529.209;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeLightColorNode;788;4311.665,948.6445;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;867;4253.842,-837.415;Inherit;False;Property;_BlendTex1Intensity;BlendTex1Intensity;19;0;Create;True;0;0;0;False;0;False;0;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;565;2745.532,-924.6653;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;391;3623.809,37.15003;Inherit;True;Property;_EmissiveTex;EmissiveTex;36;1;[Header];Create;True;1;__________________Emissive____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;846;5317.952,535.8971;Inherit;False;Property;_Zwrite;Zwrite;0;1;[Enum];Create;True;0;2;Off;0;On;1;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;428;2716.984,640.8291;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;774;3730.778,-305.0768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;868;4697.842,-893.4152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;395;3700.387,404.993;Inherit;False;Property;_EmissivePower;EmissivePower;38;0;Create;True;0;0;0;False;0;False;1;0;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;798;3406.912,-2043.756;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;835;6347.788,1773.074;Inherit;False;Property;_StencilOP;StencilOP;60;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.StencilOp;False;1;Header(__________________Stencil____________________________________________________________________________________________);False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;422;2569.657,759.7985;Inherit;False;Property;_SpecularColor;SpecularColor;44;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6581524,0.9622641,0.8877704,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;796;4233.364,-2039.025;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;499;2356.899,1184.223;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;803;3221.467,-1897.816;Inherit;False;FLOAT3;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;424;3161.677,647.4779;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;558;3879.38,-360.0932;Inherit;False;Property;_UseShadowMask;UseShadowMask;26;0;Create;True;0;0;0;False;1;Header(__________________ShadowMask____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;538;2975.585,1048.946;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;832;2412.207,299.3281;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;772;1957.111,393.1478;Inherit;True;Property;_MatcapMask;MatcapMask(R);35;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;492;1500.632,209.6621;Inherit;False;Property;_MatcapPower;MatcapPower;33;0;Create;True;0;0;0;False;0;False;1;0.98;0.5;35;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;1964.728,-378.366;Inherit;False;Property;_DarkRange;DarkRange;8;0;Create;True;0;0;0;False;0;False;0.2;0.432;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;781;2133.865,-266.9449;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;445;3471.534,1637.605;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;443;2843.203,1633.138;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;831;2896.983,332.4804;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;534;3514.105,606.7371;Inherit;False;Property;_EmiBlendSpeed;EmiBlendSpeed;41;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;597;2653.978,1161.299;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;641;4585.287,1207.537;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;440;2615.436,1636.472;Inherit;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;462;2166.039,1844.201;Inherit;False;Property;_RimOffset;RimOffset;58;0;Create;True;0;0;0;False;0;False;0.16;0.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;771;2250.485,384.7231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;777;2582.546,-1132.136;Inherit;False;Constant;_Color1;Color 1;49;0;Create;True;0;0;0;False;0;False;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;444;3255.434,1636.472;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;397;5016.147,561.0407;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;393;3687.223,236.0085;Inherit;False;Property;_EmissiveColor;EmissiveColor;37;0;Create;True;0;0;0;False;0;False;1,1,1,1;0.1415093,0.1415093,0.1415093,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;461;2331.846,1710.267;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;431;2584.436,1889.472;Inherit;False;Property;_RimLightRange;RimLightRange;56;0;Create;True;0;0;0;False;0;False;0.9;0.984;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;251;2257.057,-1464.371;Inherit;False;Property;_BaseColor;BaseColor;5;0;Create;True;0;0;0;False;0;False;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;805;4734.195,-1919.08;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;423;2504.793,930.8828;Inherit;False;Property;_SpecularPower;SpecularPower;47;0;Create;True;0;0;0;False;0;False;1;0.042;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.DecodeLightDirectionNode;787;1289.614,-550.8457;Inherit;False;0;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;560;2944.705,-138.5075;Inherit;False;Property;_ShadowMaskPower;ShadowMaskPower;29;0;Create;True;0;0;0;False;0;False;1;1;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;825;2710.579,92.31619;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;523;3990.566,557.447;Inherit;True;Property;_EmissiveBlendTex;EmissiveBlendTex;39;1;[NoScaleOffset];Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;843;6504.586,2118.864;Inherit;False;Property;_StencilReadMask;StencilReadMask;66;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;493;2505.287,1002.605;Inherit;True;Property;_SpecularMask;SpecularMask(G);43;0;Create;False;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;561;3486.368,-272.5811;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;767;2536.001,-1438.767;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;801;4877.427,-1974.802;Inherit;False;Property;_UseShadowMask;UseShadowMask;26;0;Create;True;0;0;0;False;1;Header(__________________ShadowMask____________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;558;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;799;3926.354,-2072.873;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;840;6505.586,1882.864;Inherit;False;Property;_StencilZPass;StencilZPass;63;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;316;4187.039,-511.7802;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;769;4295.592,556.1985;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;842;6505.586,2039.864;Inherit;False;Property;_StencilZFail;StencilZFail;65;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;828;2397.902,458.0295;Inherit;False;Constant;_Float1;Float 1;46;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;421;2867.636,763.4667;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;416;3138.591,108.3318;Inherit;False;Property;_UseMatcap;UseMatcap;30;0;Create;True;0;0;0;False;1;Header(___________________Matcap_________________________________________________________________________________________________);False;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;318;3886.073,-482.0814;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;844;6502.586,2193.864;Inherit;False;Property;_StencilWriteMask;StencilWriteMask;67;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;260;2522.309,-1312.291;Inherit;False;Property;_ColorPower;ColorPower;6;0;Create;True;0;0;0;False;0;False;1;1;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;505;2614.362,1393.761;Inherit;False;Property;_SpecularColor02;SpecularColor02;51;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;3659.53,1688.872;Inherit;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;898;2119.216,-1101.487;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.01;False;2;FLOAT;0.99;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;800;3379.45,-1892.186;Inherit;False;FixLightHeight;-1;;160;38674e54ca9510a46bffe97b4729b4a5;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0.6;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;766;2564.647,-1628.439;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;496;2828.545,1050.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;407;1912.451,-1101.05;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;218;2270.848,-1138.522;Inherit;True;Property;_RampTex;RampTex;22;2;[Header];[NoScaleOffset];Create;True;1;__________________Ramp____________________________________________________________________________________________;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;553;1620.204,-1026.876;Inherit;False;Constant;_dotfix;dotfix;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;882;1469.962,-1100.257;Inherit;False;Constant;_Float4;Float 4;48;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;554;1777.204,-1101.876;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;812;5557.598,357.777;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;816;5666.561,-1513.762;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;100;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;813;5557.598,357.777;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;810;5685.105,332.6938;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;814;5557.598,357.777;Float;False;False;1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;743;5473.919,-708.8628;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=SRPDefaultUnlit;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;811;5666.561,-1670.184;Half;False;True;1;2;ParaMaterialEditor;300;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_Translucent;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;True;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;True;846;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;818;5666.561,-1513.762;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;342;5685.105,148.6939;Half;False;True;-1;2;ParaMaterialEditor;500;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_Translucent;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;True;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;True;0;True;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;True;True;False;255;False;838;255;False;843;255;False;844;7;False;839;1;False;840;1;False;841;1;False;842;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;2;True;846;True;3;False;847;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;817;5694.583,-763.7974;Half;False;True;0;2;ParaMaterialEditor;400;3;Douyin/Avatar/Cartoon/AvatarNPR_HD_Translucent;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;True;7;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;0;True;True;2;5;False;-1;10;False;-1;2;5;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;True;-8;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;True;1;True;846;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;1;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;742;5363.598,186.777;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;343;4008.388,-780.3983;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;744;5363.598,196.777;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;819;5666.561,-1513.762;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;820;5666.561,-1513.762;Float;False;False;0;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;875;0;377;0
WireConnection;875;1;876;0
WireConnection;736;0;875;0
WireConnection;737;0;736;0
WireConnection;884;0;737;0
WireConnection;884;1;886;0
WireConnection;884;2;887;0
WireConnection;849;0;850;0
WireConnection;849;1;884;0
WireConnection;852;0;849;0
WireConnection;852;1;851;0
WireConnection;888;0;852;0
WireConnection;853;0;888;0
WireConnection;853;1;854;0
WireConnection;763;0;217;4
WireConnection;763;1;775;0
WireConnection;855;0;853;0
WireConnection;856;0;855;0
WireConnection;856;1;853;0
WireConnection;856;2;857;0
WireConnection;847;0;763;0
WireConnection;858;0;856;0
WireConnection;858;1;847;0
WireConnection;859;0;847;0
WireConnection;859;1;858;0
WireConnection;859;2;860;0
WireConnection;862;0;863;0
WireConnection;862;1;864;4
WireConnection;861;0;859;0
WireConnection;861;1;862;0
WireConnection;872;0;861;0
WireConnection;752;0;872;0
WireConnection;752;1;734;0
WireConnection;829;0;827;0
WireConnection;804;0;796;0
WireConnection;475;1;317;0
WireConnection;475;0;424;0
WireConnection;317;0;565;0
WireConnection;317;1;416;0
WireConnection;823;0;869;0
WireConnection;823;1;489;0
WireConnection;823;2;826;0
WireConnection;878;0;492;0
WireConnection;878;1;879;0
WireConnection;419;0;299;0
WireConnection;419;1;420;0
WireConnection;834;0;824;0
WireConnection;834;1;832;0
WireConnection;834;2;826;0
WireConnection;504;0;493;2
WireConnection;504;1;598;0
WireConnection;390;0;391;0
WireConnection;390;1;393;0
WireConnection;390;2;395;0
WireConnection;869;0;871;0
WireConnection;869;1;870;0
WireConnection;869;2;868;0
WireConnection;535;0;537;0
WireConnection;252;0;766;0
WireConnection;252;1;767;0
WireConnection;252;2;260;0
WireConnection;254;0;218;0
WireConnection;254;1;253;0
WireConnection;299;0;737;0
WireConnection;299;1;732;0
WireConnection;748;0;567;0
WireConnection;780;0;305;0
WireConnection;780;1;782;4
WireConnection;599;0;419;0
WireConnection;599;1;427;0
WireConnection;524;0;535;0
WireConnection;524;2;534;0
WireConnection;865;0;864;4
WireConnection;865;1;867;0
WireConnection;732;1;730;0
WireConnection;754;0;752;0
WireConnection;871;0;252;0
WireConnection;827;0;489;0
WireConnection;827;1;828;0
WireConnection;598;0;596;0
WireConnection;795;0;804;0
WireConnection;795;1;561;0
WireConnection;822;0;825;0
WireConnection;822;1;831;0
WireConnection;516;0;434;0
WireConnection;516;1;788;0
WireConnection;516;2;641;0
WireConnection;824;0;869;0
WireConnection;833;0;869;0
WireConnection;833;1;822;0
WireConnection;833;2;771;0
WireConnection;730;0;787;0
WireConnection;308;0;306;0
WireConnection;897;0;390;0
WireConnection;897;1;516;0
WireConnection;562;0;556;1
WireConnection;779;0;729;0
WireConnection;510;0;538;0
WireConnection;510;1;505;0
WireConnection;510;2;504;0
WireConnection;789;0;788;0
WireConnection;789;1;807;0
WireConnection;789;2;641;0
WireConnection;794;0;799;0
WireConnection;794;1;307;0
WireConnection;883;0;299;0
WireConnection;883;1;882;0
WireConnection;441;0;443;0
WireConnection;729;1;737;0
WireConnection;830;0;834;0
WireConnection;791;0;871;0
WireConnection;791;1;313;0
WireConnection;563;1;556;1
WireConnection;563;0;562;0
WireConnection;880;0;487;0
WireConnection;880;1;881;0
WireConnection;314;0;308;0
WireConnection;870;0;864;0
WireConnection;434;0;316;0
WireConnection;434;1;436;0
WireConnection;594;0;499;0
WireConnection;594;1;593;0
WireConnection;509;0;499;0
WireConnection;509;1;506;0
WireConnection;596;0;509;0
WireConnection;596;1;595;0
WireConnection;381;1;779;0
WireConnection;306;0;304;0
WireConnection;306;1;307;0
WireConnection;773;0;314;0
WireConnection;773;1;561;0
WireConnection;747;0;748;0
WireConnection;807;0;871;0
WireConnection;807;1;791;0
WireConnection;807;2;801;0
WireConnection;802;0;798;0
WireConnection;802;1;800;0
WireConnection;489;0;381;0
WireConnection;489;1;488;0
WireConnection;489;2;878;0
WireConnection;304;0;299;0
WireConnection;304;1;781;0
WireConnection;565;0;777;0
WireConnection;565;1;254;0
WireConnection;565;2;776;0
WireConnection;428;0;599;0
WireConnection;774;0;773;0
WireConnection;868;0;865;0
WireConnection;796;0;794;0
WireConnection;499;0;419;0
WireConnection;499;1;495;0
WireConnection;803;0;797;0
WireConnection;424;0;317;0
WireConnection;424;1;510;0
WireConnection;558;1;314;0
WireConnection;558;0;774;0
WireConnection;538;0;421;0
WireConnection;538;1;497;0
WireConnection;538;2;496;0
WireConnection;832;0;489;0
WireConnection;781;0;305;0
WireConnection;781;1;780;0
WireConnection;781;2;783;0
WireConnection;445;0;444;0
WireConnection;443;0;440;0
WireConnection;443;1;431;0
WireConnection;831;0;830;0
WireConnection;831;1;829;0
WireConnection;597;0;594;0
WireConnection;641;0;608;0
WireConnection;641;1;747;0
WireConnection;641;2;815;0
WireConnection;440;0;737;0
WireConnection;440;1;461;0
WireConnection;771;0;880;0
WireConnection;771;1;772;1
WireConnection;444;0;441;0
WireConnection;444;1;433;0
WireConnection;397;0;769;0
WireConnection;397;1;516;0
WireConnection;461;0;439;0
WireConnection;461;2;462;0
WireConnection;805;0;795;0
WireConnection;825;0;823;0
WireConnection;825;1;827;0
WireConnection;523;1;524;0
WireConnection;561;0;563;0
WireConnection;561;1;560;0
WireConnection;767;0;251;1
WireConnection;767;1;251;2
WireConnection;767;2;251;3
WireConnection;801;1;804;0
WireConnection;801;0;805;0
WireConnection;799;0;781;0
WireConnection;799;1;802;0
WireConnection;316;0;475;0
WireConnection;316;1;318;0
WireConnection;316;2;558;0
WireConnection;769;0;390;0
WireConnection;769;1;523;0
WireConnection;421;0;428;0
WireConnection;421;1;422;0
WireConnection;421;2;423;0
WireConnection;421;3;493;2
WireConnection;416;1;869;0
WireConnection;416;0;833;0
WireConnection;318;0;565;0
WireConnection;318;1;313;0
WireConnection;318;2;416;0
WireConnection;436;0;445;0
WireConnection;436;1;437;0
WireConnection;436;2;770;3
WireConnection;436;3;877;0
WireConnection;898;0;407;0
WireConnection;800;1;803;0
WireConnection;766;0;217;1
WireConnection;766;1;217;2
WireConnection;766;2;217;3
WireConnection;496;0;493;2
WireConnection;496;1;597;0
WireConnection;407;0;554;0
WireConnection;407;1;555;0
WireConnection;218;1;898;0
WireConnection;554;0;883;0
WireConnection;554;1;553;0
WireConnection;811;2;789;0
WireConnection;811;3;754;0
WireConnection;342;2;397;0
WireConnection;342;3;754;0
WireConnection;817;2;897;0
WireConnection;817;3;754;0
ASEEND*/
//CHKSM=82E75399542996DF21BFC956D21EEC8EBC6D94E1