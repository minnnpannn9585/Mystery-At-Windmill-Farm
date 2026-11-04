using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 生成一条带弯曲与收缩的瀑布丝带网格（不是平板，顶点密度足够做顶点位移）。
    /// UV：u 横向 0..1，v 纵向 0..1（0 在底部，1 在顶部，与 Unity Quad 一致）。
    /// </summary>
    public static class WaterfallRibbonMesh
    {
        public const float DefaultWidth          = 3.6f;
        public const float DefaultHeight         = 6.4f;
        public const float DefaultCurveAmplitude = 0.25f;
        public const float DefaultCurveFrequency = 1.0f;
        public const float DefaultBottomTaper    = 0.86f;
        public const float DefaultTopTaper       = 1.0f;

        /// <summary>某个高度比例 v 处的局部 Z 偏移（丝带前后弯曲量），供摆放遮挡物时对齐用。</summary>
        public static float SampleDepth(float v,
                                        float curveAmplitude = DefaultCurveAmplitude,
                                        float curveFrequency = DefaultCurveFrequency)
        {
            float curveZ = Mathf.Sin(v * curveFrequency * Mathf.PI * 2f) * curveAmplitude;
            float kickZ  = -Mathf.Pow(1f - v, 2.2f) * curveAmplitude * 1.4f;
            float tuckZ  = Mathf.Pow(v, 4f) * curveAmplitude * 0.6f;
            // 顶端向后翻卷，水像是从岩沿上"兜"下来的
            float curlZ  = Mathf.Pow(Mathf.Max(0f, (v - 0.84f) / 0.16f), 1.6f) * curveAmplitude * 2.6f;
            return curveZ + kickZ + tuckZ + curlZ;
        }

        /// <summary>椭圆水面盘：平面 UV 映射（uv 直接对应 XZ），适合平铺水纹。</summary>
        public static Mesh BuildDisc(float radiusX = 3.0f, float radiusZ = 2.4f, int segments = 64)
        {
            segments = Mathf.Max(8, segments);

            var verts = new Vector3[segments + 1];
            var uvs   = new Vector2[segments + 1];
            var tris  = new int[segments * 3];

            verts[0] = Vector3.zero;
            uvs[0]   = new Vector2(0.5f, 0.5f);

            for (int i = 0; i < segments; i++)
            {
                float a = (float)i / segments * Mathf.PI * 2f;
                float x = Mathf.Cos(a) * radiusX;
                float z = Mathf.Sin(a) * radiusZ;
                verts[i + 1] = new Vector3(x, 0f, z);
                uvs[i + 1]   = new Vector2(0.5f + x / (2f * radiusX), 0.5f + z / (2f * radiusZ));
            }

            for (int i = 0; i < segments; i++)
            {
                tris[i * 3 + 0] = 0;
                tris[i * 3 + 1] = (i + 1) % segments + 1;
                tris[i * 3 + 2] = i + 1;
            }

            var mesh = new Mesh { name = "WaterDisc" };
            mesh.vertices  = verts;
            mesh.uv        = uvs;
            mesh.triangles = tris;
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
            return mesh;
        }

        public static Mesh Build(
            float width = DefaultWidth,
            float height = DefaultHeight,
            int widthSegments = 20,
            int heightSegments = 56,
            float curveAmplitude = DefaultCurveAmplitude,
            float curveFrequency = DefaultCurveFrequency,
            float bottomTaper = DefaultBottomTaper,
            float topTaper = DefaultTopTaper)
        {
            widthSegments = Mathf.Max(1, widthSegments);
            heightSegments = Mathf.Max(1, heightSegments);

            int vCount = (widthSegments + 1) * (heightSegments + 1);
            var verts = new Vector3[vCount];
            var uvs   = new Vector2[vCount];
            var tris  = new int[widthSegments * heightSegments * 6];

            for (int y = 0; y <= heightSegments; y++)
            {
                float v = (float)y / heightSegments;

                // 沿高度收缩/张开
                float taper = Mathf.Lerp(bottomTaper, topTaper, v);
                float depth = SampleDepth(v, curveAmplitude, curveFrequency);

                for (int x = 0; x <= widthSegments; x++)
                {
                    float u = (float)x / widthSegments;
                    int i = y * (widthSegments + 1) + x;

                    // 中间略向外鼓，边缘略收，形成微微外凸的弧面
                    float bulge = Mathf.Sin(u * Mathf.PI) * 0.10f;

                    verts[i] = new Vector3(
                        (u - 0.5f) * width * taper,
                        v * height,
                        depth + bulge);
                    uvs[i] = new Vector2(u, v);
                }
            }

            int t = 0;
            for (int y = 0; y < heightSegments; y++)
            {
                for (int x = 0; x < widthSegments; x++)
                {
                    int bl = y * (widthSegments + 1) + x;
                    int br = bl + 1;
                    int tl = bl + (widthSegments + 1);
                    int tr = tl + 1;

                    tris[t++] = bl; tris[t++] = tl; tris[t++] = tr;
                    tris[t++] = bl; tris[t++] = tr; tris[t++] = br;
                }
            }

            var mesh = new Mesh { name = "WaterfallRibbon" };
            mesh.vertices  = verts;
            mesh.uv        = uvs;
            mesh.triangles = tris;
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
            return mesh;
        }
    }
}
