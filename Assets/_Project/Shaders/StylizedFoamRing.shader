// 溅落泡沫盘：环形/径向衰减的白色泡沫，用于瀑布底部与水面接触处
Shader "Custom/StylizedFoamRing"
{
    Properties
    {
        _Color ("Foam Color", Color) = (1, 1, 1, 1)
        _InnerRadius ("Inner Radius (0-1)", Range(0, 1)) = 0.0
        _OuterRadius ("Outer Radius (0-1)", Range(0, 1)) = 1.0
        _Softness ("Softness", Range(0.01, 1)) = 0.45
        _Opacity ("Opacity", Range(0, 1)) = 0.9
        _NoiseScale ("Noise Scale", Float) = 9
        _NoiseSpeed ("Noise Speed", Float) = -0.6
        _NoiseStrength ("Noise Strength", Range(0, 1)) = 0.65
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float  _InnerRadius;
                float  _OuterRadius;
                float  _Softness;
                float  _Opacity;
                float  _NoiseScale;
                float  _NoiseSpeed;
                float  _NoiseStrength;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            float HASH11(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
            }

            float VALNOISE(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                return lerp(lerp(HASH11(i), HASH11(i + float2(1, 0)), f.x),
                            lerp(HASH11(i + float2(0, 1)), HASH11(i + float2(1, 1)), f.x), f.y);
            }

            float FBM2(float2 p)
            {
                float v = 0.0, a = 0.5;
                [unroll]
                for (int k = 0; k < 3; k++)
                {
                    v += a * VALNOISE(p);
                    p = p * 2.1 + 7.3;
                    a *= 0.5;
                }
                return v;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                // 用 UV 到中心的距离做径向衰减（平面 / 圆柱顶面都能用）
                float2 c = IN.uv - 0.5;
                float  r = saturate(length(c) * 2.0);

                float outer = 1.0 - smoothstep(_OuterRadius - _Softness, _OuterRadius, r);
                float inner = smoothstep(_InnerRadius, _InnerRadius + _Softness * 0.5, r);
                float ring  = outer * inner;

                float n = FBM2(IN.uv * _NoiseScale + float2(0.0, _Time.y * _NoiseSpeed));
                n = lerp(1.0, n, _NoiseStrength);

                float a = saturate(ring * n) * _Opacity;
                return float4(_Color.rgb, a);
            }
            ENDHLSL
        }
    }

    FallBack "Universal Render Pipeline/Unlit"
}
