// 水下 · 全屏介质层（雾 + 垂直亮度梯度 + 屏幕抖动）
//
// 为什么不用 ScriptableRendererFeature：
//   加 RendererFeature 必须改 Renderer Data 资产（FlatKit 的 Example Renderer），
//   而这个工程里那条链已经有 DepthNormals / Outline / Fog 三个 Feature，
//   手改 YAML 风险高、也没有回退开关。这里改用「相机前置全屏 Quad」：
//     · 顶点直接输出裁剪空间坐标（transform 不参与），天然铺满全屏；
//     · ZTest Always，不写深度，排在 Transparent+200 最后画；
//     · 在透明队列里可以采样 _CameraDepthTexture（URP 的软粒子也是这么做的）。
//
// 雾的颜色是「远亮近深」的反向雾：吉卜力的水下不是压暗，是溶进亮青。
Shader "WindmillFarm/Underwater Fog"
{
    Properties
    {
        _NearColor ("Near Fog Color", Color) = (0.435, 0.714, 0.788, 1)
        _FarColor ("Far Fog Color", Color) = (0.561, 0.796, 0.847, 1)
        _FogStart ("Fog Start (m)", Float) = 5.0
        _FogDensity ("Fog Density", Float) = 0.055
        _FogMax ("Max Fog", Range(0, 1)) = 0.92
        _BaseTint ("Base Tint (alpha)", Range(0, 0.5)) = 0.10
        _TopBoost ("Top Brightness (+)", Range(0, 1)) = 0.25
        _BottomFalloff ("Bottom Darken (-)", Range(0, 1)) = 0.20
        _Wobble ("Screen Wobble", Range(0, 0.01)) = 0.0018
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent+200"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "UnderwaterFog"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZTest Always
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes { float4 positionOS : POSITION; };
            struct Varyings   { float4 positionCS : SV_POSITION; };

            CBUFFER_START(UnityPerMaterial)
                float4 _NearColor;
                float4 _FarColor;
                float  _FogStart;
                float  _FogDensity;
                float  _FogMax;
                float  _BaseTint;
                float  _TopBoost;
                float  _BottomFalloff;
                float  _Wobble;
            CBUFFER_END

            float  _UnderwaterAmount;   // 全局值，不能放进 UnityPerMaterial

            Varyings vert (Attributes v)
            {
                Varyings o;
                // 直接写到裁剪空间：物体 transform 完全不参与，永远铺满全屏
                o.positionCS = float4(v.positionOS.xy, 0.0, 1.0);
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float2 uv = i.positionCS.xy / _ScaledScreenParams.xy;

                // ---- 场景深度 → 线性视距 ----
                float rawDepth = SampleSceneDepth(uv);
                float eyeDepth = LinearEyeDepth(rawDepth, _ZBufferParams);

                // ---- 距离雾（远亮近深） ----
                float d = max(0.0, eyeDepth - _FogStart);
                float fogT = saturate((1.0 - exp(-d * _FogDensity)) * _FogMax);

                // ---- 屏幕抖动：只动垂直梯度相位，不动深度，避免边缘撕裂 ----
                float wobble = sin(uv.x * 11.0 + _Time.y * 0.55) * sin(uv.y * 7.0 - _Time.y * 0.37);
                float gradUV = saturate(uv.y + wobble * _Wobble * 120.0);

                // ---- 垂直亮度：靠水面亮，靠水底暗 ----
                float grad = lerp(1.0 - _BottomFalloff, 1.0 + _TopBoost, gradUV);

                float3 col = lerp(_NearColor.rgb, _FarColor.rgb, fogT);
                float alpha = saturate((fogT + _BaseTint) * grad) * saturate(_UnderwaterAmount);

                return float4(col, alpha);
            }
            ENDHLSL
        }
    }

    Fallback Off
}
