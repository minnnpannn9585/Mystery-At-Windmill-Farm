using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// T7 证词局的「重听」文本回顾浮层（技术文档 §12.6 / §12.6.1）。
    ///
    /// 关键口径：
    ///   · 不播音频、不重开对话树——只是一份可以慢慢读的完整聊天记录。
    ///   · 文本运行时从 DialogueDatabase 取原文，一个字不改、标点原样；本类不存副本。
    ///   · Content 只存「模块名 + DocTag 前缀」定位；按前缀取、按 id 排序，
    ///     这样 1-A#6b(id=200) 这类插入分支句也能完整收进来。
    ///   · 视觉上明确「这是回顾不是现场」：0.72 黑底、无立绘、纯文字、可滚动。
    /// </summary>
    public sealed class MiniGameReplay
    {
        readonly RectTransform _overlay;
        TMP_Text _log;

        public bool IsOpen { get { return _overlay != null && _overlay.gameObject.activeSelf; } }

        public MiniGameReplay(RectTransform parent)
        {
            _overlay = MiniGameUIKit.Node(parent, "ReplayOverlay");
            MiniGameUIKit.Stretch(_overlay);
            MiniGameUIKit.Scrim(_overlay);   // 0.72 黑底（§12.6）

            var panel = MiniGameUIKit.Panel(_overlay, "Panel", MiniGameTheme.Deep, 18f);
            MiniGameUIKit.Place(panel, Vector2.one * 0.5f, Vector2.one * 0.5f,
                Vector2.zero, new Vector2(1120f, 720f));

            var title = MiniGameUIKit.Label(panel, "Title", 26f, MiniGameTheme.Cream,
                TextAlignmentOptions.Left);
            MiniGameUIKit.Place(title.rectTransform, new Vector2(0f, 1f), new Vector2(0f, 1f),
                new Vector2(30f, -30f), new Vector2(700f, 44f));
            title.text = "重听这一段";

            var close = MiniGameUIKit.Btn(panel, "Close", "返回", MiniGameTheme.Yellow,
                MiniGameTheme.Deep, 20f);
            MiniGameUIKit.Place((RectTransform)close.transform, new Vector2(1f, 1f), new Vector2(1f, 1f),
                new Vector2(-30f, -30f), new Vector2(150f, 56f));

            // 滚动文字区：ScrollRect + Viewport + 一个 Text（§12.6 Q04 那种十来句必须能滚）。
            var viewport = MiniGameUIKit.Node(panel, "Viewport");
            MiniGameUIKit.Place(viewport, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -92f), new Vector2(1040f, 548f));
            var maskGo = new GameObject("Mask", typeof(RectTransform), typeof(CanvasRenderer), typeof(Image), typeof(Mask));
            maskGo.transform.SetParent(viewport, false);
            MiniGameUIKit.Stretch((RectTransform)maskGo.transform);
            var maskImg = maskGo.GetComponent<Image>();
            maskImg.color = new Color(1f, 1f, 1f, 0.02f);
            maskImg.raycastTarget = true;
            maskGo.GetComponent<Mask>().showMaskGraphic = false;

            var logGo = new GameObject("Log", typeof(RectTransform), typeof(TextMeshProUGUI));
            logGo.transform.SetParent(maskGo.transform, false);
            _log = logGo.GetComponent<TextMeshProUGUI>();
            var font = MiniGameTheme.Font;
            if (font != null) _log.font = font;
            _log.fontSize = 24f;
            _log.color = MiniGameTheme.Cream;
            _log.alignment = TextAlignmentOptions.TopLeft;
            _log.enableWordWrapping = true;
            _log.overflowMode = TextOverflowModes.Overflow;
            _log.raycastTarget = false;
            var logRect = _log.rectTransform;
            logRect.anchorMin = new Vector2(0f, 1f);
            logRect.anchorMax = new Vector2(1f, 1f);
            logRect.pivot = new Vector2(0.5f, 1f);
            logRect.offsetMin = new Vector2(8f, -4000f);
            logRect.offsetMax = new Vector2(-8f, 0f);

            var scroll = viewport.gameObject.AddComponent<ScrollRect>();
            scroll.content = logRect;
            scroll.viewport = (RectTransform)maskGo.transform;
            scroll.horizontal = false;
            scroll.vertical = true;
            scroll.movementType = ScrollRect.MovementType.Clamped;
            scroll.scrollSensitivity = 32f;

            close.onClick.AddListener(Close);
            _overlay.gameObject.SetActive(false);
        }

        /// <summary>按 Content 的模块名 + DocTag 前缀取原文并逐句显示。无数据时给出可见提示，不静默。</summary>
        public void Open(string module, string tag)
        {
            if (string.IsNullOrEmpty(module) || string.IsNullOrEmpty(tag))
            {
                _log.text = "（本局无重听记录）";
                _overlay.gameObject.SetActive(true);
                return;
            }

            var graph = DialogueDatabase.Get(module);
            if (graph == null)
            {
                _log.text = "（未找到对话记录：" + module + "）";
                _overlay.gameObject.SetActive(true);
                return;
            }

            var prefix = tag + "#";
            var lines = new List<KeyValuePair<int, DialogueNode>>();
            foreach (var kv in graph.Nodes)
            {
                var node = kv.Value;
                if (node == null) continue;
                if (node.DocTag == null || !node.DocTag.StartsWith(prefix)) continue;
                lines.Add(kv);
            }
            lines.Sort((a, b) => a.Key.CompareTo(b.Key));

            if (lines.Count == 0)
            {
                _log.text = "（未找到该段对话：" + tag + "）";
            }
            else
            {
                var sb = new System.Text.StringBuilder();
                for (var i = 0; i < lines.Count; i++)
                {
                    var node = lines[i].Value;
                    var speaker = string.IsNullOrEmpty(node.NpcName) ? "" : node.NpcName + "：";
                    sb.Append(speaker).Append(node.Dialogue);
                    if (i < lines.Count - 1) sb.Append('\n').Append('\n');
                }
                _log.text = sb.ToString();
            }

            var scroll = _overlay.GetComponentInChildren<ScrollRect>();
            if (scroll != null) scroll.verticalNormalizedPosition = 1f;   // 从第一句看起
            _overlay.SetAsLastSibling();
            _overlay.gameObject.SetActive(true);
        }

        public void Close()
        {
            if (_overlay != null) _overlay.gameObject.SetActive(false);
        }
    }
}
