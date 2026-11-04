// 风格化交互瀑布 / 水面
// 复刻自 Unity Shader Graph 教程 "Interactive Waterfall"（BV1S1iBYpEip / YT _52bbARO6HY）
//
// 核心算法（与原教程等价）：
//   1. 顶点世界坐标 - 交互物世界坐标（原教程 Custom Function "Subtract Vertex Position"）
//   2. Sphere Mask：球内 = 洞
//   3. 垂直向下条带：交互物 Y 以下、XZ 距离 < topDown_Radius 的区域也挖掉
//      （对应原教程 Split -> Comparison(Greater 0) -> Branch 的"正负半空间"遮罩）
//   4. cut = max(disc, strip)；alpha = 1 - cut；洞口边缘出亮边 -> Emission
//   5. 附加风格化外观：双层流动噪波、泡沫、菲涅尔
Shader "Custom/StylizedInteractiveWater"
{
    Properties
    {
        [Header(Water)]
        _ShallowColor ("Shallow Color", Color) = (0.42, 0.86, 0.96, 1)
        _DeepColor ("Deep Color", Color) = (0.13, 0.52, 0.78, 1)
        _FoamColor ("Foam Color", Color) = (0.90, 0.99, 1.0, 1)
        _Alpha ("Base Alpha", Range(0, 1)) = 0.80
        _FlowSpeed ("Flow Speed", Float) = 1.4
        _ScrollTiling ("Flow Tiling (XY)", Vector) = (1.2, 2.4, 0, 0)
        _NoiseScale ("Noise Scale", Float) = 7.0
        _StreakAmount ("Streak Amount", Range(0, 1)) = 0.75
        _FoamAmount ("Foam Amount", Range(0, 1)) = 0.60
        _TopFoamHeight ("Top Foam Height", Range(0, 1)) = 0.14

        [Header(Texture)]
        _MainTex ("Water Flow (RGB)", 2D) = "white" {}
        _FoamMask ("Foam Mask (R)", 2D) = "black" {}
        _TexBlend ("Texture Blend", Range(0, 1)) = 1
        _TexTiling ("Texture Tiling (XY)", Vector) = (1, 1, 0, 0)
        _TexScroll ("Texture Scroll (deprecated)", Float) = 0.10

        [Header(Texture Warp)]
        // 贴图是从视频里截的单帧，不是四方连续，绝不能整张沿 V 平移：
        // 那样边缘会周期性暴露接缝，而且贴图内容本身有固定的上下方向，滑过去就是"倒流"。
        // 改成「静态锚定 + 原地扰动」：UV 不产生净位移，只被世界空间流动噪波推着翻卷。
        _TexWarp ("Texture Warp 扰动幅度(UV)", Range(0, 0.35)) = 0.10
        _TexWarpSpeed ("Texture Warp Speed", Float) = 0.55

        [Header(Rapids Flow)]
        // 参考 AZURE Nature 的 AN_Water_Rapids（AN_Water.shader 第 718~777 行）：
        //   世界坐标沿流向投影 -> 沿流向 stretch 拉伸 -> 双层噪声随流向推进
        //   -> 冲击中心径向湍流 -> foam steps 量化
        // 瀑布的流向是世界 -Y，所以主轴取 Y，横轴取 X。
        _FlowStretch ("Flow Stretch 沿流向拉伸", Range(1, 20)) = 7.0
        _FlowFoamScale ("Rapids Foam Scale", Range(0.5, 10)) = 3.0
        _FlowTurbulence ("Rapids Turbulence", Range(0, 2)) = 1.0
        _FlowContrast ("Rapids Foam Contrast", Range(0, 0.95)) = 0.55
        _ImpactCenter ("Impact Center (World XYZ)", Vector) = (0, 0, 0, 0)
        _ImpactRadius ("Impact Radius", Range(0, 30)) = 3.0
        _ImpactStrength ("Impact Strength", Range(0, 2)) = 1.0
        _FoamSteps ("Rapids Foam Steps", Range(1, 4)) = 2

        [Header(Foam Boil)]
        // 泡沫内部的浓淡涌动：形状与边界保持硬边不动，只让带内密度起伏。
        // 相位挂在世界坐标上 —— 会蠕动，但绝不会随相机转动而漂移。
        _FoamBoil ("Foam Boil 泡沫扰动", Range(0, 1)) = 0.40
        _FoamBoilSpeed ("Foam Boil Speed", Float) = 0.9

        [Header(Fresnel)]
        _RimColor ("Rim Color", Color) = (0.75, 0.98, 1.0, 1)
        // 菲涅尔是「视角相关」项：会给水面加一圈随相机转动而移动的亮边，
        // 画面里看起来就是"白色部分在乱动"。风格化平涂不需要它，默认关闭。
        // 真要一点立体感，把 _RimStrength 调到 0.1~0.3，同时把 _RimPower 调大。
        _RimPower ("Rim Power", Float) = 8.0
        _RimStrength ("Rim Strength", Range(0, 2)) = 0.0

        [Header(Vertex Wave)]
        _WaveAmplitude ("Wave Amplitude", Float) = 0.09
        _WaveFrequency ("Wave Frequency", Float) = 1.2
        _WaveSpeed ("Wave Speed", Float) = 1.0

        [Header(Interaction)]
        _Radius ("Radius", Float) = 1.0
        _TopDownRadius ("topDown_Radius", Float) = 1.0
        _TailLength ("Tail Length (0 = infinite)", Float) = 0
        _ClipSoft ("Clip Softness", Range(0.001, 0.5)) = 0.12
        // 洞口白沫环的半宽（世界单位）：环以洞口边界为中心向内外各延伸这么多。
        _FoamEdgeWidth ("Hole Foam Half Width", Float) = 0.22

        [Header(Contact Foam)]
        // 几何足迹法：由 WaterContactSource 每帧推入接触物的水平足迹，
        // 水面在足迹轮廓处生成白色浮沫。与渲染管线无关，任何情况下都可用。
        // _ContactFalloff 现在表示「边缘过渡宽度占带宽的比例」：
        //   0.10~0.20 → 硬边（视频那种边界分明的白沫）
        //   0.5 以上  → 柔和渐变
        _ContactFalloff ("Contact Edge Softness", Range(0.02, 1)) = 0.16
        _ContactStrength ("Contact Strength", Range(0, 2)) = 1.0
        _ContactEdgeNoise ("Contact Edge Noise", Range(0, 1)) = 0.55
        // 可选：叠加基于 _CameraDepthTexture 的自动接触浮沫（需要深度图可用）
        [Toggle] _UseSceneDepth ("Use Scene Depth Contact", Float) = 0
        _ContactDepth ("Scene Depth Contact Width", Float) = 1.2
        _ReceiveInteraction ("Receive Interaction", Range(0, 1)) = 1
        _EdgeColor ("Hole Edge Color", Color) = (0.92, 1.0, 1.0, 1)
        _EdgeWidth ("Hole Edge Width", Float) = 0.18
        _EdgeStrength ("Hole Edge Strength", Range(0, 4)) = 1.2

        [Header(Debug)]
        // 0=正常  1=contact  2=rapidsFoam  3=texFoam  4=foamBase
        _DebugMode ("Debug Mode", Range(0, 4)) = 0
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
            #pragma multi_compile_instancing

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _ShallowColor;
                float4 _DeepColor;
                float4 _FoamColor;
                float4 _RimColor;
                float4 _EdgeColor;
                float4 _ScrollTiling;
                float  _Alpha;
                float  _FlowSpeed;
                float  _NoiseScale;
                float  _StreakAmount;
                float  _FoamAmount;
                float  _TopFoamHeight;
                float  _RimPower;
                float  _RimStrength;
                float  _Radius;
                float  _TopDownRadius;
                float  _TailLength;
                float  _ClipSoft;
                float  _EdgeWidth;
                float  _EdgeStrength;
                float  _WaveAmplitude;
                float  _WaveFrequency;
                float  _WaveSpeed;
                float  _FoamEdgeWidth;
                float  _ReceiveInteraction;
                float  _ContactDepth;
                float  _ContactFalloff;
                float  _ContactStrength;
                float  _ContactEdgeNoise;
                float  _UseSceneDepth;
                float4 _TexTiling;
                float  _TexBlend;
                float  _TexScroll;
                float  _TexWarp;
                float  _TexWarpSpeed;
                float  _FlowStretch;
                float  _FlowFoamScale;
                float  _FlowTurbulence;
                float  _FlowContrast;
                float4 _ImpactCenter;
                float  _ImpactRadius;
                float  _ImpactStrength;
                float  _FoamSteps;
                float  _FoamBoil;
                float  _FoamBoilSpeed;
                float  _DebugMode;
            CBUFFER_END

            TEXTURE2D(_MainTex);     SAMPLER(sampler_MainTex);
            TEXTURE2D(_FoamMask);    SAMPLER(sampler_FoamMask);

            // 深度纹理的纹素尺寸（Unity 为绑定到 _CameraDepthTexture 的全局纹理自动填充）
            float4 _CameraDepthTexture_TexelSize;

            // ---- 由 C# 每帧写入的全局量（InteractiveWaterInteractor.cs）----
            // xyz = 交互物世界坐标
            float4 _IW_ObjectPosition;
            // x = Radius, y = topDown_Radius, z = tailLength(<=0 无限), w = enabled
            float4 _IW_Params;

            // 由 WaterContactSource 每帧写入的接触物足迹（最多 8 个）
            // A = (世界 x, 世界 z, 本地半宽 x, 本地半宽 z)
            // B = (cos(yaw), sin(yaw), 浮沫带宽, 是否启用)
            float4 _IW_ContactA[8];
            float4 _IW_ContactB[8];

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float2 uv         : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            // ---------------- noise ----------------
            float HASH11(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
            }

            float VALNOISE(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                f = f * f * (3.0 - 2.0 * f);
                float a = HASH11(i);
                float b = HASH11(i + float2(1.0, 0.0));
                float c = HASH11(i + float2(0.0, 1.0));
                float d = HASH11(i + float2(1.0, 1.0));
                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            float FBM(float2 p)
            {
                float v = 0.0;
                float amp = 0.5;
                [unroll]
                for (int k = 0; k < 4; k++)
                {
                    v += amp * VALNOISE(p);
                    p = p * 2.03 + 11.7;
                    amp *= 0.5;
                }
                return v;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                // 顶点横向摆动：顶部固定、越靠近底部摆幅越大，做出水帘的柔性
                float3 posOS = IN.positionOS.xyz;
                float  falloff = 1.0 - IN.uv.y;
                float  wt = _Time.y * _WaveSpeed;
                posOS.x += sin(IN.uv.y * _WaveFrequency * 6.28318 + wt) * _WaveAmplitude * falloff;
                posOS.z += cos(IN.uv.y * _WaveFrequency * 3.14159 + wt * 0.7) * _WaveAmplitude * 0.45 * falloff;

                VertexPositionInputs pos = GetVertexPositionInputs(posOS);
                VertexNormalInputs nrm   = GetVertexNormalInputs(IN.normalOS);

                OUT.positionCS = pos.positionCS;
                OUT.positionWS = pos.positionWS;
                OUT.normalWS   = nrm.normalWS;
                OUT.uv         = IN.uv;
                return OUT;
            }

            // 屏幕 UV：优先用深度纹理自身尺寸反推（与其内容自洽），
            // 拿不到时回退到 URP 的 _ScaledScreenParams。
            // 手动 Camera.Render() / 编辑器中 _ScaledScreenParams 可能与实际 RT 不一致，
            // 直接用会导致采样到错误位置、深度恒为 0（远平面）。
            float2 ContactScreenUV(float2 positionCS)
            {
                float2 texel = _CameraDepthTexture_TexelSize.xy;
                float2 size  = (texel.x > 1e-7 && texel.y > 1e-7)
                             ? rcp(texel)
                             : GetScaledScreenParams().xy;
                float2 uv = positionCS * rcp(max(size, float2(1.0, 1.0)));
                #if UNITY_UV_STARTS_AT_TOP
                uv.y = 1.0 - uv.y;
                #endif
                return uv;
            }

            // 球洞 ∪ 向下条带，带软边；soft 为相对半径的过渡比例
            float CutMask(float d3, float d2, float r, float tr, float below, float inTail, float soft)            {
                float disc  = 1.0 - smoothstep(r * (1.0 - soft), r, d3);
                float strip = (1.0 - smoothstep(tr * (1.0 - soft), tr, d2)) * below * inTail;

                // 平滑并集：球洞与向下条带交界处自然过渡（避免出现矩形框）
                float h = saturate(0.5 + 0.5 * (strip - disc) / 0.18);
                return saturate(lerp(disc, strip, h) + 0.18 * h * (1.0 - h));
            }

            float4 frag(Varyings IN) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(IN);

                float3 wp = IN.positionWS;
                float2 uv = IN.uv;
                float  t  = _Time.y * _FlowSpeed;

                // 世界空间噪波，给泡沫边界「咬边」。
                // 相位挂在世界坐标上缓慢滚动 —— 边界会自己蠕动（扰动），
                // 但因为是世界空间的，绝不会随相机转动而移动。
                // （之前"白色部分随相机乱动"的真因有两个：菲涅尔是视角相关项；
                //   以及咬边用了 UV/屏幕空间的滚动噪波。两者都已排除。）
                float2 boilOff = float2(-t * _FoamBoilSpeed * 0.35, t * _FoamBoilSpeed * 0.55);
                float nEdge    = FBM(wp.xz * 7.0 + boilOff);        // 小物体高频
                float nLow     = FBM(wp.xz * 3.0 + boilOff * 0.6);  // 大物体低频
                // 泡沫边缘过渡宽度占带宽的比例（越小越硬）
                float edgeSoft = saturate(_ContactFalloff);

                // 泡沫内部的浓淡涌动：只改带内密度，不改边界锐利度。
                // 注意不能写成 saturate(x * 1.1)：带内本来就是满 1，乘大于 1 会被钳住，
                // 看起来还是一块死白的平涂。必须让它能降到 1 以下才有"沸腾"的观感。
                float boilA  = FBM(wp.xz * 2.4 + float2(-t * 0.62, t * 0.41));
                float boilB  = FBM(wp.xz * 6.1 + float2(t * 1.05, -t * 0.83));
                float grit   = saturate(boilA * 0.62 + boilB * 0.48);
                float boilShape = smoothstep(0.26, 0.72, grit);
                float boilMod = lerp(1.0, 0.42 + 0.62 * boilShape, saturate(_FoamBoil));

                // ---------------- 1. 交互剪裁 ----------------
                float enabled = saturate(_IW_Params.w) * saturate(_ReceiveInteraction);
                float radius  = max(_IW_Params.x > 0.0001 ? _IW_Params.x : _Radius, 0.0001);
                float tr      = max(_IW_Params.y > 0.0001 ? _IW_Params.y : _TopDownRadius, 0.0001);
                float tail    = _IW_Params.z > 0.0 ? _IW_Params.z : _TailLength;
                float soft    = max(_ClipSoft, 0.001);

                float3 op  = _IW_ObjectPosition.xyz;
                float  d3  = distance(wp, op);

                // 垂直向下条带用的水平距离（加噪波让边界不呆板）
                float2 dxz    = abs(wp.xz - op.xz);
                float  d2     = max(dxz.x, dxz.y) + (nLow - 0.5) * 0.12;
                float  below  = 1.0 - smoothstep(-0.03, 0.03, wp.y - op.y);
                float  inTail = tail > 0.0 ? smoothstep(op.y - tail, op.y - tail + 0.5, wp.y) : 1.0;

                float crisp = CutMask(d3, d2, radius, tr, below, inTail, soft);
                float cut   = crisp * enabled;

                // ---- 洞口内缘的白色浮沫环 ----
                // 与 cube 接触浮沫完全同一套逻辑：几何距离 → 噪波咬边 → 窄区间硬切。
                // （之前用两个不同 soft 的 CutMask 相减再二值化，环是个死板的正圆，没有起伏。）
                float sdSphere = d3 - radius;                 // 球洞的 signed distance
                float sdStrip  = d2 - tr;                     // 向下条带的 signed distance
                sdStrip = lerp(sdStrip + 1e3, sdStrip, saturate(below * inTail)); // 球心上方时推远

                // 平滑并集用与顺序无关的标准 polynomial smooth-min。
                // 注意：不能照抄 CutMask 里那套 —— 那边是 0..1 的 mask，语义相反，
                // 直接搬会把球洞上方的 SDF 推成 +1000，白环整个消失。
                const float hk = 0.18;
                float hq = max(hk - abs(sdSphere - sdStrip), 0.0) / hk;
                float sdHole = min(sdSphere, sdStrip) - hq * hq * hk * 0.25;

                float bw  = max(_FoamEdgeWidth, 0.001);       // 环半宽（世界单位）
                // 球洞环周长 ~6m，用低频噪波才不会有密集锯齿
                float wob = (nLow - 0.5) * bw * _ContactEdgeNoise * 1.8;
                float bd  = abs(sdHole) + wob;
                float band = (1.0 - smoothstep(bw * (1.0 - edgeSoft), bw, bd)) * enabled * boilMod;

                // ---------------- 2. 流动水体 ----------------
                // 纵向拉伸的流线噪波：X 方向高频、Y 方向低频 => 往下淌的水柱感
                // 注意符号：uv.y=1 在顶部、0 在底部，要「往下流」必须让采样坐标随时间
                // 递增（+t），写成 -t 的话图案会往上跑 —— 就是之前"流向反了"的成因。
                float2 nuv = uv * _ScrollTiling.xy;
                float sc = max(_NoiseScale, 0.01);

                float n1 = FBM(float2(nuv.x * sc * 0.55, nuv.y * sc * 0.10 + t * 0.8));
                float n2 = FBM(float2(nuv.x * sc * 1.70 + n1 * 0.9, nuv.y * sc * 0.28 + t * 1.9));
                // FBM 均值在 0.5 附近，阈值抬高才能切出"细白线"而不是一层雾
                float streak = saturate((n2 - 0.54) * 3.2) * _StreakAmount;

                // 横向波纹扰动，避免噪波过于"云状"
                float ripple = sin(nuv.y * 16.0 + t * 2.4 + n1 * 5.0) * 0.5 + 0.5;

                // 纵向明暗：越靠下越深（Quad 的 uv.y=1 在上）
                float depthT = 1.0 - uv.y;
                float3 col = lerp(_ShallowColor.rgb, _DeepColor.rgb,
                                  saturate(depthT * 0.9 + n1 * 0.22 - ripple * 0.10));

                // ---- AN_Water_Rapids 风格的程序化流向泡沫 ----
                // 世界坐标沿流向投影。AN_Water 是水平水面，主轴取 xz；
                // 瀑布是竖直面，主轴必须换成 -Y。这里按表面法线的"水平度"两者自动切换，
                // 同一个 shader 才能既服务 fall 又服务 pool。
                float  upness = saturate(abs(normalize(IN.normalWS).y));
                float  along  = lerp(-wp.y, wp.z, upness);   // 沿流向：竖直面往下、水平面往 +Z
                float  across =  wp.x;

                // 先把世界米换算成「噪声单元数」，再用 _FlowStretch 单独压低流向频率。
                // 关键：_FlowFoamScale 必须按「单元/米」理解，否则 6 米高的瀑布上
                // 只剩不到 1 个单元，泡沫会退化成横贯整片的色块（白色全挤在某一层）。
                float  cellScale = max(_FlowFoamScale, 0.01);
                float  stretch   = max(_FlowStretch, 1.0);
                float2 flowUV = float2(across * cellScale, along * cellScale / stretch);
                // 相位递减 => 图案朝 along 增大方向（下游）推进。方向不会反。
                flowUV.y -= t * 0.90;
                // 横向低频摆动：水纹不是笔直下落。
                // 用噪声而不用 sin —— sin 会在空间上形成规则横纹，看起来像梳齿。
                flowUV.x += (FBM(float2(along * 0.35, t * 0.22)) - 0.5) * 1.6;

                float rapidsBroad = FBM(float2(flowUV.x * 0.95, flowUV.y));
                float rapidsFine  = FBM(float2(flowUV.x * 2.10 + 31.7, flowUV.y * 2.60 + 11.3));
                // FBM 的均值就在 0.5 附近，直接拿来当泡沫会糊成一整片白
                // （实测会把水体的 #37B9D1 冲成 #8BE2F6）。
                // 必须用高阈值把它切成稀疏的细长水纹，这才是视频里那种白色刷痕。
                float shapeRaw = rapidsBroad * 0.78 + rapidsFine * 0.34;
                float thr = lerp(0.82, 0.44, saturate(_FlowContrast));
                float foamShape = smoothstep(thr, thr + 0.14, shapeRaw);

                // 湍流强度：冲击中心球状衰减 ∪ 沿落体方向递增（AN_Water 的 impactT / heightT）
                float impactDist = length(wp - _ImpactCenter.xyz);
                float impactT    = (1.0 - saturate(impactDist / max(_ImpactRadius, 0.001))) * _ImpactStrength;
                float dropT      = saturate(1.0 - uv.y) * (1.0 - upness);   // 0=顶端 1=底端，水平面上不参与
                float turbulence = saturate(max(impactT, dropT * 0.60) + 0.18) * _FlowTurbulence;

                float rapidsFoam = foamShape * turbulence;
                // 分阶量化：制造风格化的"块状"白沫（AN_Water_Rapids 的 Foam Steps）
                float foamSteps = max(floor(_FoamSteps), 1.0);
                rapidsFoam = floor(rapidsFoam * foamSteps + 0.5) / foamSteps;
                // 稀疏细沫不做量化，否则会多出一层硬边
                rapidsFoam = saturate(rapidsFoam + rapidsFine * 0.10);

                // ---- 视频提取贴图（_MainTex / _FoamMask）----
                // 不再整张沿 V 平移。贴图是从视频截的单帧、非四方连续，
                // 整体平移会周期性暴露接缝，而且贴图自带上下方向，滑过去就是倒流。
                // 改为「静态锚定 + 原地扰动」：UV 只被世界空间流动噪波推着翻卷，无净位移。
                float  warpAlong = lerp(wp.y, wp.z, upness);   // 竖直面顺流轴是 y，水平面是 z
                float2 warpN;
                warpN.x = FBM(float2(wp.x * 1.60, warpAlong * 0.55 + t * _TexWarpSpeed)) - 0.5;
                warpN.y = FBM(float2(wp.x * 1.10 + 7.3, warpAlong * 0.42 + t * _TexWarpSpeed * 1.35)) - 0.5;

                // 扰动幅度按 UV 四边衰减到 0，保证永远采不到贴图边界之外
                float2 edgeFade = smoothstep(0.0, 0.20, uv) * smoothstep(0.0, 0.20, 1.0 - uv);

                // 竖直面（瀑布）直接用丝带 UV；水平面（水池）用盘 UV，
                // 但盘 UV 会把贴图上下两条白边扫成两圈静止的白硬环 ——
                // 所以水池只取贴图内部平坦的青色中段，白色交给程序化泡沫。
                float2 uvFall = uv * _TexTiling.xy;
                float2 uvPool = lerp(float2(0.20, 0.20), float2(0.80, 0.80), uv);
                float2 uvTex  = lerp(uvFall, uvPool, upness) + warpN * _TexWarp * edgeFade;

                float3 texCol  = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uvTex).rgb;
                float  texFoam = SAMPLE_TEXTURE2D(_FoamMask, sampler_FoamMask, uvTex).r;

                // sRGB 采样后是线性值，直接用；未指定贴图时 texCol 为白，靠 _TexBlend 关掉
                col = lerp(col, texCol, _TexBlend);

                // 菲涅尔加亮
                float3 viewDirWS = normalize(GetWorldSpaceViewDir(wp));
                float  fres = pow(1.0 - saturate(dot(normalize(IN.normalWS), viewDirWS)), _RimPower);
                col += _RimColor.rgb * fres * _RimStrength;

                // 泡沫：顶部横向 foam 带 + 纵向流线 foam
                float topFoam  = smoothstep(1.0 - _TopFoamHeight, 1.0, uv.y) * _FoamAmount * (0.55 + 0.45 * n2);
                float foamBase = saturate(topFoam + streak * _FoamAmount);

                // 贴图白纹的浓淡被 rapids 脉动调制 —— 这就是"白色水流有扰动"：
                // 形状（哪里是白水）来自贴图，翻涌（白水在激烈冲击）来自程序化流向泡沫。
                // 再乘 boilMod，贴图自带的那两条静止白边才不会是一块平涂。
                float texFoamLive = texFoam * saturate(0.50 + rapidsFoam * 1.40) * boilMod;

                float foam = lerp(foamBase, max(foamBase, texFoamLive), _TexBlend);
                foam = saturate(foam + rapidsFoam * 0.55);

                // ---------------- 3. 接触浮沫 ----------------
                // 3a. 几何足迹法：WaterContactSource 每帧推入「接触水面的物体」的水平足迹，
                //     用有向矩形 SDF 求出水线轮廓，泡沫带骑在轮廓两侧。
                //     这条路径完全不依赖深度图，任何渲染器配置下都成立。
                float contact = 0.0;
                [unroll]
                for (int ci = 0; ci < 8; ci++)
                {
                    float4 A = _IW_ContactA[ci];
                    float4 Bc = _IW_ContactB[ci];
                    if (Bc.w < 0.5) continue;

                    float2 p = wp.xz - A.xy;
                    float2 l = float2(dot(p, Bc.xy), dot(p, float2(-Bc.y, Bc.x)));
                    float2 dd = abs(l) - A.zw;
                    float  sd = length(max(dd, 0.0)) + min(max(dd.x, dd.y), 0.0);

                    // 噪波只改轮廓的起伏，不改边界的锐利度
                    float w   = max(Bc.z, 0.001);
                    float wob = (nEdge - 0.5) * w * _ContactEdgeNoise * 1.8;
                    float d   = abs(sd) + wob;

                    // 带内一律满白；只在 (1-edgeSoft)*w → w 这段很窄的区间落回 0
                    contact = max(contact, 1.0 - smoothstep(w * (1.0 - edgeSoft), w, d));
                }
                // 带内密度涌动：边界硬边与形状保持不动，只有带内浓淡在起伏，
                // 这样浮沫不会是一块完全静止的死白（pool / fall 都吃这一项）。
                contact = saturate(contact * boilMod) * _ContactStrength;

                // 3b. 可选：基于场景深度的自动接触浮沫（需要 _CameraDepthTexture 可用）
                if (_UseSceneDepth > 0.5)
                {
                    float2 screenUV = ContactScreenUV(IN.positionCS.xy);
                    float  sceneEye = LinearEyeDepth(SampleSceneDepth(screenUV), _ZBufferParams);
                    float  gapT     = saturate(max(sceneEye - IN.positionCS.w, 0.0) / max(_ContactDepth, 0.001));
                    float  dc = 1.0 - smoothstep(1.0 - edgeSoft, 1.0, gapT);
                    contact = max(contact, dc * _ContactStrength);
                }

                // ---- 调试可视化 ----
                if (_DebugMode > 0.5)
                {
                    if (_DebugMode < 1.5) return float4(contact, contact, contact, 1.0);
                    if (_DebugMode < 2.5) return float4(rapidsFoam, rapidsFoam, rapidsFoam, 1.0);
                    if (_DebugMode < 3.5) return float4(texFoam, texFoam, texFoam, 1.0);
                    return float4(foamBase, foamBase, foamBase, 1.0);
                }

                float3 emission = _EdgeColor.rgb * (contact * 0.30 + band * 0.45);

                // ---------------- 4. 合成 ----------------
                // 洞口内缘的厚泡沫环（band）本来就落在 cut 造成的全透明区域里，
                // 只并进 foam 是看不见的 —— 必须同时把 alpha 拉回来，白环才立得住。
                foam = saturate(max(max(foam, contact), band));
                col  = lerp(col, _FoamColor.rgb, foam);

                float alpha = (1.0 - cut) * _Alpha;
                alpha = saturate(alpha
                                 + foam * 0.35 * (1.0 - cut)
                                 + contact * 0.55 * (1.0 - cut)
                                 + band * 0.95);

                col += emission;

                return float4(col, alpha);
            }
            ENDHLSL
        }
    }

    FallBack "Universal Render Pipeline/Unlit"
}
