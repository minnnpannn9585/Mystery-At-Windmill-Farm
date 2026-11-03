using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace EggRescue.MiniGame.Boards
{
    /// <summary>
    /// T3 翻转查验（§8）。Q12（白石双面）/ Q02（炭块）/ Q15（碗）/ Q18（桶）。
    ///
    /// 关键取舍：**转的不是贴图，是宽度 + 一次换图**（§8.3）。
    /// 压扁 1 → 0.12、0.12 → 1，中间 90° 那一帧换面并立起 3px 厚度条；
    /// 硬转贴图会「纸片化」，这正是 19-文档要求白石翻转时维持实心轮廓的原因。
    ///
    /// 物件不能跟着指针走（那是拖拽模板的做法），所以这块不走骨架的 carry：
    /// 在 TickBoard 里自己读按住 / 位移 / 松手，只把「停在哪一档」交给判定。
    /// </summary>
    public sealed class RotateBoard : MiniGameBoard
    {
        sealed class FaceView
        {
            public MiniGameFace Spec;
            public Image Skin;
        }

        sealed class TargetView
        {
            public MiniGameTarget Spec;
            public string FaceId;
            public RectTransform Rect;
            public Button Button;
            public CanvasGroup Group;
            public RectTransform Rail;
            public bool Confirmed;
        }

        static readonly Vector2 ObjectSize = new Vector2(460f, 400f);
        static readonly float[] Stops = { 0f, 180f };

        readonly List<TargetView> _targets = new List<TargetView>();
        readonly List<FaceView> _faces = new List<FaceView>();

        RectTransform _object;
        RectTransform _edge;
        Button _objectButton;
        float _angle;
        float _targetAngle;
        bool _dragging;
        float _lastPointerX;

        bool ShowingBack { get { return _angle > 90f; } }

        protected override string FooterText { get { return "翻转 ｜ 左右拖动 · 点击细节"; } }

        protected override void BuildBoard()
        {
            var center = BodyPoint(MiniGameTheme.Body.width * 0.5f, MiniGameTheme.Body.height * 0.5f - 20f);

            _object = MiniGameUIKit.Panel(Body, "Object", MiniGameTheme.Cream, 24f, true);
            MiniGameUIKit.Place(_object, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f), center, ObjectSize);
            _objectButton = _object.gameObject.AddComponent<Button>();
            _objectButton.targetGraphic = _object.GetComponent<Image>();
            _objectButton.transition = Selectable.Transition.None;
            // 物件本体只是「可按住的地方」，不做点击语义；真正的点击落在目标上
            _objectButton.onClick.AddListener(() => { });

            // 两面：正面奶白、背面冷一点。M3 换成真贴图。
            var front = MiniGameUIKit.Panel(_object, "FaceFront", MiniGameTheme.Cream, 20f);
            MiniGameUIKit.Stretch(front);
            var back = MiniGameUIKit.Panel(_object, "FaceBack", MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.28f), 20f);
            MiniGameUIKit.Stretch(back);

            _faces.Add(new FaceView { Spec = FaceOf(false), Skin = front.GetComponent<Image>() });
            _faces.Add(new FaceView { Spec = FaceOf(true), Skin = back.GetComponent<Image>() });

            // 厚度条：只在 80°–100° 之间出现，让「侧过来」有实体感
            _edge = MiniGameUIKit.Panel(_object, "Edge", MiniGameTheme.Deep, 0f);
            MiniGameUIKit.Place(_edge, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                Vector2.zero, new Vector2(3f, ObjectSize.y));
            _edge.gameObject.SetActive(false);

            BuildTargets();
            ApplyAngle(0f, true);

            Judge.Total = Mathf.Max(1, _targets.Count);
        }

        MiniGameFace FaceOf(bool back)
        {
            for (var i = 0; i < Content.Faces.Length; i++)
                if (Content.Faces[i].Back == back) return Content.Faces[i];
            return null;
        }

        void BuildTargets()
        {
            for (var i = 0; i < Content.Targets.Length; i++)
            {
                var spec = Content.Targets[i];
                var face = FaceContaining(spec.Id);

                // 目标坐标是主区美术坐标，物件中心固定在主区中心 —— 换成物件内局部坐标
                var local = BodyPoint(spec.Pos.x, spec.Pos.y)
                            - BodyPoint(MiniGameTheme.Body.width * 0.5f, MiniGameTheme.Body.height * 0.5f - 20f);

                var rect = MiniGameUIKit.Panel(_object, "Target_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.9f), 12f, true);
                MiniGameUIKit.Place(rect, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                    local, new Vector2(110f, 110f));

                var group = rect.gameObject.AddComponent<CanvasGroup>();
                var button = rect.gameObject.AddComponent<Button>();
                button.targetGraphic = rect.GetComponent<Image>();
                var captured = i;
                button.onClick.AddListener(() => OnTargetClicked(captured));

                _targets.Add(new TargetView
                {
                    Spec = spec,
                    FaceId = face != null ? face.Id : null,
                    Rect = rect,
                    Button = button,
                    Group = group,
                    Rail = AddRailSlot(spec.Label, i),
                });
            }
        }

        MiniGameFace FaceContaining(string targetId)
        {
            for (var i = 0; i < Content.Faces.Length; i++)
            {
                var ids = Content.Faces[i].TargetIds;
                for (var j = 0; j < ids.Length; j++)
                    if (ids[j] == targetId) return Content.Faces[i];
            }
            return null;
        }

        // ---------------- 拖动与角度 ----------------

        protected override void TickBoard(float dt)
        {
            if (_dragging)
            {
                if (Input.GetMouseButtonUp(0))
                {
                    _dragging = false;
                    SnapToNearestStop();
                }
                else
                {
                    var dx = Input.mousePosition.x - _lastPointerX;
                    _lastPointerX = Input.mousePosition.x;
                    _angle = Mathf.Clamp(_angle + dx * 0.6f, Stops[0] - 8f, Stops[1] + 8f);
                    ApplyAngle(_angle, false);
                }
                return;
            }

            if (!Input.GetMouseButtonDown(0)) return;
            if (!PointerOnObject()) return;

            // 点在目标上就交给目标按钮，不要同时开始转物件
            if (TargetUnderPointer()) return;

            _dragging = true;
            _lastPointerX = Input.mousePosition.x;

            // 有确认过的一面就把起手角度放在那一面，避免每次进来都从正面开始
            _targetAngle = _angle;
        }

        bool PointerOnObject()
        {
            Vector2 local;
            if (!MiniGameUIKit.TryGetLocalPoint(Body, Input.mousePosition, out local)) return false;
            var center = BodyPoint(MiniGameTheme.Body.width * 0.5f, MiniGameTheme.Body.height * 0.5f - 20f);
            var r = new Rect(center.x - ObjectSize.x * 0.5f - 20f, center.y - ObjectSize.y * 0.5f - 20f,
                ObjectSize.x + 40f, ObjectSize.y + 40f);
            return r.Contains(local);
        }

        bool TargetUnderPointer()
        {
            Vector2 local;
            if (!MiniGameUIKit.TryGetLocalPoint(Body, Input.mousePosition, out local)) return false;
            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                if (t.Confirmed || !IsFaceUp(t.FaceId)) continue;
                var p = t.Rect.transform.position;
                var screen = RectTransformUtility.WorldToScreenPoint(null, p);
                if (Vector2.Distance(screen, (Vector2)Input.mousePosition) <= 60f) return true;
            }
            return false;
        }

        void SnapToNearestStop()
        {
            _targetAngle = Mathf.Abs(_angle - Stops[0]) <= Mathf.Abs(_angle - Stops[1]) ? Stops[0] : Stops[1];
            StartCoroutine(SnapRoutine());
        }

        System.Collections.IEnumerator SnapRoutine()
        {
            var from = _angle;
            var t = 0f;
            const float duration = 0.18f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = SpringReturn.EaseOutCubic(Mathf.Clamp01(t / duration));
                ApplyAngle(Mathf.Lerp(from, _targetAngle, k), false);
                yield return null;
            }
            ApplyAngle(_targetAngle, false);
        }

        /// <summary>压扁 → 换图 → 展开。实心厚度条只在临界角出现。</summary>
        void ApplyAngle(float angle, bool immediate)
        {
            _angle = angle;

            var rad = angle * Mathf.Deg2Rad;
            var cos = Mathf.Abs(Mathf.Cos(rad));
            var sx = Mathf.Max(0.12f, cos);
            _object.localScale = new Vector3(sx, 1f, 1f);

            var nearEdge = Mathf.Abs(angle - 90f) < 14f;
            _edge.gameObject.SetActive(nearEdge);
            if (nearEdge)
            {
                var k = 1f - Mathf.Abs(angle - 90f) / 14f;
                _edge.sizeDelta = new Vector2(3f * k + 0.5f, ObjectSize.y);
            }

            var back = angle > 90f;
            for (var i = 0; i < _faces.Count; i++)
            {
                var face = _faces[i];
                var isBack = face.Spec != null && face.Spec.Back;
                if (face.Skin != null) face.Skin.enabled = isBack == back;
            }

            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                var up = !t.Confirmed && IsFaceUp(t.FaceId);
                // 未翻到该面时描边不出现，避免「点了没反应」（§8.5）
                t.Group.alpha = up ? 1f : 0f;
                t.Button.interactable = up;
            }
        }

        bool IsFaceUp(string faceId)
        {
            if (string.IsNullOrEmpty(faceId)) return true;
            var face = FindFace(faceId);
            if (face == null) return true;
            return face.Back == ShowingBack;
        }

        MiniGameFace FindFace(string id)
        {
            for (var i = 0; i < Content.Faces.Length; i++)
                if (Content.Faces[i].Id == id) return Content.Faces[i];
            return null;
        }

        // ---------------- 判定 ----------------

        void OnTargetClicked(int index)
        {
            if (index < 0 || index >= _targets.Count) return;
            var target = _targets[index];
            if (target.Confirmed || !IsFaceUp(target.FaceId)) return;

            target.Confirmed = true;
            FlashHighlight(target.Rect, MiniGameTheme.Yellow, 3);
            var image = target.Rect.GetComponent<Image>();
            if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.9f);

            if (target.Rail != null)
            {
                var label = target.Rail.GetComponentInChildren<TMP_Text>();
                if (label != null)
                {
                    label.text = "✓ " + target.Spec.Label;
                    label.color = MiniGameTheme.DarkGreen;
                }
            }

            Judge.Advance();
        }

        protected override JudgeResult OnJudge()
        {
            // 与 T1 同理：T3 的判定在点击里，没有落位这一步
            return JudgeResult.No("rotate-uses-click");
        }

        // ---------------- 提示 ----------------

        protected override void ApplyHint(int level, string text)
        {
            if (level < 2) return;
            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                if (t.Confirmed) continue;
                if (IsFaceUp(t.FaceId))
                {
                    ShowHighlight(t.Rect, MiniGameTheme.Yellow, 3f);
                    return;
                }
                // 目标在另一面：点亮物件本体，提示「得翻过去」
                ShowHighlight(_object, MiniGameTheme.Blue, 3f);
                return;
            }
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            // "ids|angle"
            var raw = MagnifierBoard.Csv(progress.MaskBase64);
            var parts = raw.Split('|');
            if (parts.Length > 1)
            {
                float angle;
                if (float.TryParse(parts[1], out angle)) ApplyAngle(angle, true);
            }
            if (parts.Length == 0 || parts[0].Length == 0) return;

            var ids = parts[0].Split(',');
            for (var i = 0; i < ids.Length; i++)
            {
                for (var t = 0; t < _targets.Count; t++)
                {
                    if (_targets[t].Spec.Id != ids[i]) continue;
                    var target = _targets[t];
                    target.Confirmed = true;
                    var image = target.Rect.GetComponent<Image>();
                    if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.9f);
                    if (target.Rail != null)
                    {
                        var label = target.Rail.GetComponentInChildren<TMP_Text>();
                        if (label != null)
                        {
                            label.text = "✓ " + target.Spec.Label;
                            label.color = MiniGameTheme.DarkGreen;
                        }
                    }
                    break;
                }
            }
            ApplyAngle(_angle, true);
        }

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var ids = new List<string>();
            for (var i = 0; i < _targets.Count; i++)
                if (_targets[i].Confirmed) ids.Add(_targets[i].Spec.Id);
            progress.MaskBase64 = MagnifierBoard.Encode(
                string.Join(",", ids.ToArray()) + "|" + Mathf.RoundToInt(_angle));
            return progress;
        }
    }
}
