// 水下 · 浮游颗粒（程序化圆形，无需贴图）
// 粒子系统提供顶点色，这里只把 UV 变成"中心亮、边缘透明"的软圆点。
Shader "WindmillFarm/Underwater Mote"
{
    Properties
    {
        _Color ("Color", Color) = (0.965, 0.949, 0.886, 1)
        _Softness ("Edge Softness", Range(0.2, 6)) = 2.2
        _Intensity ("Intensity", Range(0, 4)) = 1.0
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Transparent+20"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "UnderwaterMote"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha One        // 加法混合：水下颗粒是"发光的小点"，不是实体
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
                float4 color      : COLOR;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float4 color      : COLOR;
                float2 uv         : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float  _Softness;
                float  _Intensity;
            CBUFFER_END

            float  _UnderwaterAmount;   // 全局值，不能放进 UnityPerMaterial

            Varyings vert (Attributes v)
            {
                Varyings o;
                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.color = v.color;
                o.uv = v.uv;
                return o;
            }

            float4 frag (Varyings i) : SV_Target
            {
                float2 d = i.uv * 2.0 - 1.0;
                float r = saturate(1.0 - length(d));
                float a = pow(r, _Softness);

                float3 col = _Color.rgb * i.color.rgb;
                float alpha = a * i.color.a * _Color.a * _UnderwaterAmount;
                return float4(col * _Intensity, saturate(alpha));
            }
            ENDHLSL
        }
    }

    Fallback Off
}
