#if UNITY_EDITOR
using EggRescue.MiniGame.Boards;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.EditorTools
{
    /// <summary>
    /// 编辑器里执行小游戏时，自动出现在屏幕左侧的调试菜单。
    /// 当前只有 T7 的加 / 减卡片，用来验证堆叠、悬浮置顶与判定。
    /// 整份代码被 UNITY_EDITOR 包住，不会进正式包。
    /// </summary>
    public sealed class MiniGameDebugMenu : MonoBehaviour
    {
        static MiniGameDebugMenu _instance;

        RectTransform _panel;
        TMP_Text _status;
        Button _add;
        Button _remove;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void AutoCreate()
        {
            if (_instance != null) return;
            var go = new GameObject("MiniGameDebugMenu", typeof(RectTransform), typeof(Canvas),
                typeof(CanvasScaler), typeof(GraphicRaycaster), typeof(MiniGameDebugMenu));
            DontDestroyOnLoad(go);
            _instance = go.GetComponent<MiniGameDebugMenu>();
            _instance.Build();
        }

        void Build()
        {
            var canvas = GetComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            // 小游戏画布 400 / 黑底 -100：菜单取 900，永远压在最上面
            canvas.sortingOrder = 900;

            var scaler = GetComponent<CanvasScaler>();
            scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
            scaler.screenMatchMode = CanvasScaler.ScreenMatchMode.Expand;
            scaler.referenceResolution = new Vector2(MiniGameTheme.RefWidth, MiniGameTheme.RefHeight);

            _panel = MiniGameUIKit.Panel(transform, "Panel",
                new Color(0.07f, 0.09f, 0.11f, 0.94f), 12f, true);
            _panel.anchorMin = _panel.anchorMax = new Vector2(0f, 0.5f);
            _panel.pivot = new Vector2(0f, 0.5f);
            _panel.anchoredPosition = new Vector2(18f, 40f);
            _panel.sizeDelta = new Vector2(210f, 232f);

            var title = MiniGameUIKit.Label(_panel, "Title", 22f, MiniGameTheme.Cream);
            MiniGameUIKit.Place(title.rectTransform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -16f), new Vector2(190f, 38f));
            title.text = "T7 调试菜单";

            _status = MiniGameUIKit.Label(_panel, "Status", 19f, MiniGameTheme.Yellow);
            MiniGameUIKit.Place(_status.rectTransform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -64f), new Vector2(190f, 36f));

            _add = MiniGameUIKit.Btn(_panel, "Add", "+1 卡", MiniGameTheme.Yellow, MiniGameTheme.Deep, 20f);
            MiniGameUIKit.Place((RectTransform)_add.transform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -122f), new Vector2(180f, 52f));
            _add.onClick.AddListener(() => Apply(true));

            _remove = MiniGameUIKit.Btn(_panel, "Remove", "-1 卡", MiniGameTheme.Cream, MiniGameTheme.Deep, 20f);
            MiniGameUIKit.Place((RectTransform)_remove.transform, new Vector2(0.5f, 1f), new Vector2(0.5f, 1f),
                new Vector2(0f, -184f), new Vector2(180f, 52f));
            _remove.onClick.AddListener(() => Apply(false));

            _panel.gameObject.SetActive(false);
        }

        void Update()
        {
            var board = MiniGameHost.IsOpen ? FindObjectOfType<TestimonyBoard>() : null;
            var show = board != null;
            if (_panel != null) _panel.gameObject.SetActive(show);
            if (!show) return;

            if (_status != null)
                _status.text = "卡片 " + board.CardCount + (board.IsStacked ? " · 堆叠" : " · 平铺");
            if (_remove != null) _remove.interactable = board.CardCount > 1;
        }

        void Apply(bool add)
        {
            var board = FindObjectOfType<TestimonyBoard>();
            if (board == null) return;
            if (add) board.DebugAddCard();
            else board.DebugRemoveCard();
        }
    }
}
#endif
