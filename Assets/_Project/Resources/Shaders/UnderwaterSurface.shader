// 水下 · 水面「下表面」/ Snell 窗
// 用途：相机在水下时，补上从下方看到的水面。第三方水体包的水面是单面（_Cull=2，剔除背面），
//       从水下抬头水面整个消失，直接看到天空 —— 这是「看不出在水下」的根因。
//
// 物理依据（风格化实现）：
//   · 水→空气临界角 48.6°，视线与竖直夹角小于临界角 → 形成「Snell 窗」，透出天空；
//   · 窗外 → 全反射，看到的是水体自己的颜色。
//   · 波纹只扰动「看向上方的余弦」，让窗口边缘起伏，不做真实折射。
//
// 只在相机水下时由 UnderwaterSurfaceShell 启用，水上完全不参与渲染。
Shader "WindmillFarm/Underwater Surface"
{
    Properties
    {
        [Header(Snell Window)]
        _SkyColor ("Sky Color (near surface)", Color) = (0.749, 0.890, 0.925, 1)
        _ZenithColor ("Sky Color (zenith)", Color) = (0.235, 0.525, 0.580, 1)
        _SunColor ("Sun Color", Color) = (0.988, 0.969, 0.902, 1)
        _WindowAngle ("Critical Angle (deg)", Range(20, 80)) = 48.6
        _WindowSoftness ("Window Softness", Range(0.005, 0.25)) = 0.055
        _SunSharpness ("Sun Spot Sharpness", Range(2, 300)) = 48

        [Header(Total Reflection)]
        _ReflectColor ("Reflected Water Color", Color) = (0.122, 0.361, 0.482, 1)
        _ReflectBoost ("Reflect Brightness", Range(0, 2)) = 1

        [Header(Rim)]
        _RimColor ("Rim Color", Color) = (1, 0.945, 0.855, 1)
        _RimStrength ("Rim Strength", Range(0, 2)) = 0.6
        _RimWidth ("Rim Width", Range(0.005, 0.25)) = 0.05

        [Header(Waves)]
        _WaveScale ("Wave Scale (per meter)", Range(0.1, 12)) = 1.8
        _WaveSpeed ("Wave Speed", Range(0, 4)) = 0.55
        _WaveStrength ("Wave Strength", Range(0, 1)) = 0.35

        [Header(Blend)]
        _Opacity ("Reflection Opacity", Range(0, 1)) = 0.94
        _WindowOpacity ("Window Opacity", Range(0, 1)) = 0.42
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent+10"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "UnderwaterSurface"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            ZTest LEqual
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _SkyColor;
                float4 _ZenithColor;
                float4 _SunColor;
                float4 _ReflectColor;
                float4 _RimColor;
                float  _WindowAngle;
                float  _WindowSoftness;
                float  _SunSharpness;
                float  _ReflectBoost;
                float  _RimStrength;
                float  _RimWidth;
                float  _WaveScale;
                float  _WaveSpeed;
                float  _WaveStrength;
                float  _Opacity;
                float  _WindowOpacity;
            CBUFFER_END

            // 全局值（Shader.SetGlobalVector / SetGlobalFloat）必须放在 CBUFFER 之外，
            // 否则会被材质 CBUFFER 里的同名项覆盖成 0。
            float4 _UnderwaterSunDir;   // xyz = 指向太阳的方向（世界空间）
            float  _UnderwaterAmount;   // 0..1 由 UnderwaterCameraController 全局下发

            Varyings vert (Attributes v)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

                VertexPositionInputs pos = GetVertexPositionInputs(v.positionOS.xyz);
                o.positionCS = pos.positionCS;
                o.positionWS = pos.positionWS;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.positionWS);

                // ---- 波纹：三层不同频率/方向叠加，只用来扰动「看向上方的程度」 ----
                float t = _Time.y * _WaveSpeed;
                float2 p = i.positionWS.xz;
                float wave =
                    sin(p.x * _WaveScale + t) * 0.50 +
                    sin(p.y * _WaveScale * 1.37 - t * 0.8) * 0.30 +
                    sin((p.x + p.y) * _WaveScale * 0.61 + t * 1.6) * 0.20;

                float cosUp = saturate(viewDir.y);
                cosUp = saturate(cosUp + wave * _WaveStrength * 0.06);

                float cosCritical = cos(radians(_WindowAngle));
                float window = smoothstep(cosCritical, cosCritical + _WindowSoftness, cosUp);

                // ---- 窗内：透出去的天空 + 太阳亮斑 ----
                float3 sky = lerp(_SkyColor.rgb, _ZenithColor.rgb, saturate(viewDir.y));
                float sunDot = saturate(dot(viewDir, normalize(_UnderwaterSunDir.xyz)));
                float sun = pow(sunDot, _SunSharpness) + pow(sunDot, 8.0) * 0.18;
                float3 windowCol = sky + _SunColor.rgb * sun * 1.35;

                // ---- 窗外：全反射的水面色（亮暗随波纹起伏，模拟水面皱褶） ----
                float3 reflectCol = _ReflectColor.rgb * _ReflectBoost * (1.0 + wave * 0.35);
                reflectCol += _SkyColor.rgb * saturate(wave) * 0.06;

                float3 col = lerp(reflectCol, windowCol, window);

                // ---- 临界角附近的一圈暖白光环（吉卜力常见的水面亮边） ----
                float rim = saturate(1.0 - abs(cosUp - (cosCritical + _RimWidth * 0.5)) / _RimWidth);
                col += _RimColor.rgb * rim * _RimStrength;

                float alpha = lerp(_Opacity, _WindowOpacity, window);
                alpha *= saturate(_UnderwaterAmount);

                return float4(col, saturate(alpha));
            }
            ENDHLSL
        }
    }

    Fallback Off
}
