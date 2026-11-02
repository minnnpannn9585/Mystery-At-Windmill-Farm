using UnityEngine;
using UnityEngine.UI;

namespace EggRescue
{
    /// <summary>Shared paper palette and a nine-sliced rounded rectangle for HUD and menu UI.</summary>
    public static class HudPaperStyle
    {
        // Interior fill of the dialoguePanel sprite; dialogue text uses the same #323232 ink.
        public static readonly Color Paper = new Color32(226, 199, 162, 255);
        public static readonly Color Ink = new Color32(50, 50, 50, 255);
        public static readonly Color KeyPaper = new Color32(245, 226, 200, 255);
        static Sprite _rounded;

        public static void Apply(Image image, bool keycap = false)
        {
            if (image == null) return;
            ApplyShape(image, keycap ? 16f / 3f : 16f);
            image.color = keycap ? KeyPaper : Paper;
        }

        /// <summary>Round a panel or button without changing its palette or interaction state.</summary>
        public static void ApplyShape(Image image, float radius = 16f)
        {
            if (image == null) return;
            image.sprite = RoundedRectangle();
            image.type = Image.Type.Sliced;
            image.fillCenter = true;
            image.preserveAspect = false;
            image.pixelsPerUnitMultiplier = 16f / Mathf.Max(1f, radius);
        }

        static Sprite RoundedRectangle()
        {
            if (_rounded != null) return _rounded;
            const int size = 64;
            const float radius = 16f;
            var texture = new Texture2D(size, size, TextureFormat.RGBA32, false)
            {
                name = "HUD Rounded Rectangle",
                filterMode = FilterMode.Bilinear,
                wrapMode = TextureWrapMode.Clamp,
                hideFlags = HideFlags.HideAndDontSave
            };
            var pixels = new Color32[size * size];
            for (var y = 0; y < size; y++)
            for (var x = 0; x < size; x++)
            {
                // One-pixel antialiasing at each rounded corner; straight edges stay opaque.
                var dx = Mathf.Max(Mathf.Abs(x + 0.5f - size * 0.5f) - (size * 0.5f - radius), 0f);
                var dy = Mathf.Max(Mathf.Abs(y + 0.5f - size * 0.5f) - (size * 0.5f - radius), 0f);
                var alpha = Mathf.Clamp01(radius + 0.5f - Mathf.Sqrt(dx * dx + dy * dy));
                pixels[y * size + x] = new Color32(255, 255, 255, (byte)Mathf.RoundToInt(alpha * 255f));
            }
            texture.SetPixels32(pixels);
            texture.Apply(false, true);
            _rounded = Sprite.Create(texture, new Rect(0f, 0f, size, size),
                Vector2.one * 0.5f, 100f, 0, SpriteMeshType.FullRect,
                new Vector4(radius, radius, radius, radius));
            _rounded.name = texture.name;
            _rounded.hideFlags = HideFlags.HideAndDontSave;
            return _rounded;
        }
    }
}
