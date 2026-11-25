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
            /// <summary>多物体模式：该目标属于哪个 FlipObjectView。</summary>
            public FlipObjectView Owner;
        }

        /// <summary>多物体翻转框架里的一个运行期物件实例（§8.10）。</summary>
        sealed class FlipObjectView
        {
            public MiniGameFlipObject Spec;
            public RectTransform Rect;
            public RectTransform FaceFront;
            public RectTransform FaceBack;
            public RectTransform Edge;
            public float Angle;
            public bool Flipping;
            public float LastPointerX;
            public bool ShowingBack { get { return Angle > 90f; } }
            public bool IsDecoy { get { return Spec != null && Spec.IsDecoy; } }
        }

        static readonly Vector2 ObjectSize = new Vector2(460f, 400f);
        static readonly float[] Stops = { 0f, 180f };

        readonly List<TargetView> _targets = new List<TargetView>();
        readonly List<FaceView> _faces = new List<FaceView>();

        // ---- 多物体模式（Q02 等）----
        readonly List<FlipObjectView> _objects = new List<FlipObjectView>();
        bool UseMulti { get { return Content != null && Content.FlipObjects != null && Content.FlipObjects.Length > 0; } }

        // 二级提示的临时视觉：W-04 弧形箭头（原型用 "↻" 占位）+ 每个未点物件各自的高亮框。
        // 箭头只淡入淡出不响应点击（美术文档 §5.4 选项 C）；已确认目标不参与、不高亮。
        readonly List<TargetHighlight> _hintHighlights = new List<TargetHighlight>();
        readonly List<GameObject> _hintArrows = new List<GameObject>();
        Coroutine _hintArrowRoutine;

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
            if (UseMulti) { BuildMultiBoard(); return; }
            BuildSingleBoard();
        }

        void BuildSingleBoard()
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

        // ================= 多物体翻转框架（§8.10）=================
        // 每个 FlipObject 是独立可翻转物件；按 SortOrder 决定前后遮挡；
        // 干扰物（IsDecoy）不可翻、不可点。目标归属物件，只有「所属面朝前 且 未被遮挡」才可确认。

        void BuildMultiBoard()
        {
            // 先按层级排序建对象：SortOrder 小的先建（在下层），大的后建（盖在上面）
            var specs = new MiniGameFlipObject[Content.FlipObjects.Length];
            System.Array.Copy(Content.FlipObjects, specs, specs.Length);
            System.Array.Sort(specs, (a, b) => a.SortOrder.CompareTo(b.SortOrder));

            for (var i = 0; i < specs.Length; i++)
            {
                var spec = specs[i];
                var view = BuildFlipObject(spec);
                _objects.Add(view);
            }

            BuildMultiTargets();
            for (var i = 0; i < _objects.Count; i++) ApplyObjectAngle(_objects[i], 0f);
            // 建板后立刻按初始面刷新目标可点态：目标都挂在背面、物件正面朝上，
            // 所以两处黄圈开局必须隐藏、不可点、不拦截射线（否则既显示黄圈又挡住翻转拖拽）。
            RefreshMultiTargets();

            Judge.Total = Mathf.Max(1, _targets.Count);
        }

        FlipObjectView BuildFlipObject(MiniGameFlipObject spec)
        {
            var view = new FlipObjectView { Spec = spec };

            var rect = MiniGameUIKit.Panel(Body, "Flip_" + spec.Id, Color.clear, 0f, !spec.IsDecoy);
            // 坐标系必须和单物体路径一致：Body 的子节点以左上角为锚 (0,1)，
            // position 用 BodyPoint(美术坐标) = (x, -y)。之前误用 anchor=(0.5,0.5)
            // 把每个物件又多推了半个 Body，导致全部挤到右下角。
            MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                BodyPoint(spec.Pos.x, spec.Pos.y), spec.Size);
            rect.SetAsLastSibling(); // 后建的在上层（SortOrder 已排序）
            view.Rect = rect;

            if (!string.IsNullOrEmpty(spec.SpritePath))
            {
                // 有真贴图：正反各一张 SpriteArt（背面留空则复用正面）
                var artF = MiniGameUIKit.SpriteArt(rect, "FaceFront", spec.SpritePath, Color.white);
                MiniGameUIKit.Stretch(artF);
                view.FaceFront = artF;
                var artB = MiniGameUIKit.SpriteArt(rect, "FaceBack", spec.SpritePath,
                    MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.28f));
                MiniGameUIKit.Stretch(artB);
                view.FaceBack = artB;
            }
            else
            {
                var front = DrawFlipFace(rect, "FaceFront", spec, false);
                var back = DrawFlipFace(rect, "FaceBack", spec, true);
                view.FaceFront = front;
                view.FaceBack = back;
            }

            // 厚度条：翻转临界角出现，维持实心感（§8.3）
            var edge = MiniGameUIKit.Panel(rect, "Edge", MiniGameTheme.Deep, 0f);
            MiniGameUIKit.Place(edge, new Vector2(0.5f, 0.5f), new Vector2(0.5f, 0.5f),
                Vector2.zero, new Vector2(3f, spec.Size.y));
            edge.gameObject.SetActive(false);
            view.Edge = edge;

            return view;
        }

        /// <summary>
        /// 无贴图时的最简占位：矩形 = 圆角矩形，椭圆 = 大圆角矩形。
        /// 不画碎叶、不旋转、不自创配色——美术文档有 spritePath 后直接换真图（§8.11）。
        /// </summary>
        RectTransform DrawFlipFace(RectTransform parent, string name, MiniGameFlipObject spec, bool back)
        {
            var c = back ? MiniGameTheme.Alpha(MiniGameTheme.Deep, 0.28f) : spec.Color;
            var radius = spec.Shape == FlipShape.Rect ? 20f : 999f;
            var panel = MiniGameUIKit.Panel(parent, name, c, radius);
            MiniGameUIKit.Stretch(panel);
            return panel;
        }

        void BuildMultiTargets()
        {
            for (var i = 0; i < Content.Targets.Length; i++)
            {
                var spec = Content.Targets[i];
                var owner = FindObjectOwningTarget(spec.Id);
                var face = FaceContaining(spec.Id);

                var rect = MiniGameUIKit.Panel(Body, "Target_" + spec.Id,
                    MiniGameTheme.Alpha(MiniGameTheme.Yellow, 0.9f), 12f, true);
                // 与物件同样用左上锚 (0,1)，不能再偏移半个 Body
                MiniGameUIKit.Place(rect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                    BodyPoint(spec.Pos.x, spec.Pos.y), new Vector2(110f, 110f));
                rect.SetAsLastSibling();

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
                    Rail = AddRailSlot(spec.Label, i, hiddenUntilFound: true),
                    Owner = owner,
                });
            }
        }

        FlipObjectView FindObjectOwningTarget(string targetId)
        {
            for (var i = 0; i < _objects.Count; i++)
            {
                var faces = _objects[i].Spec.Faces;
                for (var j = 0; j < faces.Length; j++)
                {
                    var ids = faces[j].TargetIds;
                    for (var k = 0; k < ids.Length; k++)
                        if (ids[k] == targetId) return _objects[i];
                }
            }
            return null;
        }

        /// <summary>
        /// 是否有更高层的物件声明遮挡了 owner 的目标（多物体重叠关系，框架保留能力）。
        /// 约定：遮挡者 blocker 停在「正面」时盖住下层 owner 的目标，翻到背面则让开。
        /// Q02（v2.12）两件可交互物各自独立、互不遮挡，OccludesObjectId 全为空 —— 本函数恒返回 false。
        /// 该能力保留给将来确有层叠遮挡需求的局使用（如旧版的遮挡草叶方案）。
        /// </summary>
        bool IsTargetOccludedByOther(FlipObjectView owner)
        {
            if (owner == null) return false;
            for (var i = 0; i < _objects.Count; i++)
            {
                var blocker = _objects[i];
                if (blocker == owner || blocker.Spec.IsDecoy) continue;
                if (blocker.Spec.OccludesObjectId != owner.Spec.Id) continue;
                if (blocker.Spec.SortOrder <= owner.Spec.SortOrder) continue;
                if (!blocker.ShowingBack) return true;   // 遮挡者正面朝上 = 仍盖着
            }
            return false;
        }

        /// <summary>
        /// 多物体目标当前是否可确认：所属物件翻到目标所在面 且 未被更高层物件遮挡。
        /// 注意这里不能复用单物体的 IsFaceUp（它读全局 _angle），必须读目标所属物件自己的 Angle。
        /// </summary>
        bool CanConfirmMulti(TargetView t)
        {
            if (t.Confirmed || t.Owner == null) return false;
            // 目标所在面：从所属物件的 Faces 里找
            var face = FindFaceInObject(t.Owner, t.Spec.Id);
            if (face != null && face.Back != t.Owner.ShowingBack) return false;
            // 遮挡只作用于「被遮物件当前朝上的那一面」的目标（框架保留能力）。
            // Q02（v2.12）两物件互不遮挡、OccludesObjectId 全空，此判断恒不改变结果。
            if (face != null && face.Back && IsTargetOccludedByOther(t.Owner)) return false;
            return true;
        }

        MiniGameFace FindFaceInObject(FlipObjectView owner, string targetId)
        {
            var faces = owner.Spec.Faces;
            for (var i = 0; i < faces.Length; i++)
            {
                var ids = faces[i].TargetIds;
                for (var j = 0; j < ids.Length; j++)
                    if (ids[j] == targetId) return faces[i];
            }
            return null;
        }

        void ApplyObjectAngle(FlipObjectView v, float angle)
        {
            if (v == null || v.Rect == null) return;
            v.Angle = angle;
            var rad = angle * Mathf.Deg2Rad;
            var sx = Mathf.Max(0.12f, Mathf.Abs(Mathf.Cos(rad)));
            v.Rect.localScale = new Vector3(sx, 1f, 1f);

            var nearEdge = Mathf.Abs(angle - 90f) < 14f;
            if (v.Edge != null)
            {
                v.Edge.gameObject.SetActive(nearEdge && !v.IsDecoy);
                if (nearEdge)
                {
                    var k = 1f - Mathf.Abs(angle - 90f) / 14f;
                    v.Edge.sizeDelta = new Vector2(3f * k + 0.5f, v.Spec.Size.y);
                }
            }
            if (v.FaceFront != null) v.FaceFront.gameObject.SetActive(!v.ShowingBack);
            if (v.FaceBack != null) v.FaceBack.gameObject.SetActive(v.ShowingBack);
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
                    Rail = AddRailSlot(spec.Label, i, hiddenUntilFound: true),
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
            if (UseMulti) { TickMulti(dt); return; }
            TickSingle(dt);
        }

        void TickSingle(float dt)
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

        // ---- 多物体拖动 ----

        FlipObjectView _activeFlip;

        void TickMulti(float dt)
        {
            if (_activeFlip != null && _activeFlip.Flipping)
            {
                if (Input.GetMouseButtonUp(0))
                {
                    var v = _activeFlip;
                    v.Flipping = false;
                    var target = Mathf.Abs(v.Angle - Stops[0]) <= Mathf.Abs(v.Angle - Stops[1]) ? Stops[0] : Stops[1];
                    StartCoroutine(SnapObjectRoutine(v, v.Angle, target));
                    // 翻动遮挡草叶后，刷新所有目标的可点态
                    RefreshMultiTargets();
                }
                else
                {
                    var dx = Input.mousePosition.x - _activeFlip.LastPointerX;
                    _activeFlip.LastPointerX = Input.mousePosition.x;
                    var a = Mathf.Clamp(_activeFlip.Angle + dx * 0.6f, Stops[0] - 8f, Stops[1] + 8f);
                    ApplyObjectAngle(_activeFlip, a);
                }
                return;
            }

            if (!Input.GetMouseButtonDown(0)) return;
            // 翻面自由：线索点出现的区域照样能拖动翻面，不因线索点而缩小判定范围。
            // 旧代码在这里遇到「可确认目标」就 return，导致线索点黄圈盖住的那块无法翻回。
            // 现在统一交给 TopFlippableUnderPointer 的几何判定（不依赖射线/线索点）：
            //   - 拖动 → 翻面（Button.onClick 因 pointer 移出不会误确认）；
            //   - 纯点击 → Button.onClick 确认线索点，同时 snap 回原角度（角度不变、确认不丢）。

            // 命中一个可翻转物件（从最上层往下找，跳过干扰物）
            var hit = TopFlippableUnderPointer();
            if (hit == null) return;
            hit.Flipping = true;
            hit.LastPointerX = Input.mousePosition.x;
            _activeFlip = hit;
        }

        FlipObjectView TopFlippableUnderPointer()
        {
            for (var i = _objects.Count - 1; i >= 0; i--)
            {
                var v = _objects[i];
                if (!v.Spec.Flippable || v.IsDecoy) continue;
                RectTransformUtility.ScreenPointToLocalPointInRectangle(
                    v.Rect, Input.mousePosition, null, out var local);
                var r = new Rect(-v.Spec.Size.x * 0.5f - 20f, -v.Spec.Size.y * 0.5f - 20f,
                    v.Spec.Size.x + 40f, v.Spec.Size.y + 40f);
                if (r.Contains(local)) return v;
            }
            return null;
        }

        bool PointerNearTarget(TargetView t)
        {
            var screen = RectTransformUtility.WorldToScreenPoint(null, t.Rect.position);
            return Vector2.Distance(screen, (Vector2)Input.mousePosition) <= t.Spec.Radius;
        }

        System.Collections.IEnumerator SnapObjectRoutine(FlipObjectView v, float from, float to)
        {
            var t = 0f;
            const float duration = 0.18f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                var k = SpringReturn.EaseOutCubic(Mathf.Clamp01(t / duration));
                ApplyObjectAngle(v, Mathf.Lerp(from, to, k));
                yield return null;
            }
            ApplyObjectAngle(v, to);
            RefreshMultiTargets();
        }

        /// <summary>根据遮挡/翻面状态刷新多物体目标的可点态与可见性。</summary>
        void RefreshMultiTargets()
        {
            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                // 已确认的目标常亮（绿），其余只在「所属面朝前且未被遮挡」时显示黄圈可点。
                var up = t.Confirmed || CanConfirmMulti(t);
                t.Group.alpha = up ? 1f : 0f;
                // 不可见时必须关掉射线拦截，否则透明黄圈会盖住底下的物件，玩家拖不动去翻面。
                t.Group.blocksRaycasts = up;
                t.Button.interactable = up;
            }
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
            // 多物体：必须面朝前且未被遮挡；单物体：只看面
            var confirmable = UseMulti ? CanConfirmMulti(target) : IsFaceUp(target.FaceId);
            if (!confirmable) return;

            target.Confirmed = true;
            FlashHighlight(target.Rect, MiniGameTheme.Yellow, 3);
            var image = target.Rect.GetComponent<Image>();
            if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.9f);

            if (target.Rail != null)
            {
                RevealRail(target.Rail);
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
            if (UseMulti) { ApplyHintMulti(); return; }
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

        /// <summary>
        /// 多物体二级提示（W-04 选项 C）：只做视觉，不改文字。
        /// 逐个未确认目标：其所属物件若还没翻到目标面 → 在该物件上方渐显弧形箭头 + 高亮该物件；
        /// 两个物件都还没点、都还没翻 → 两个一起出现箭头、一起高亮。
        /// **已点过的目标整个跳过**（不高亮、不给箭头）；已翻到目标面但还没点的，只高亮物件不再给箭头。
        /// 箭头不响应点击（raycastTarget=false），淡入 1.5s 停留后淡出，不占可拖区域。
        /// </summary>
        void ApplyHintMulti()
        {
            ClearHintVisuals();

            var hintedOwners = new HashSet<FlipObjectView>();
            for (var i = 0; i < _targets.Count; i++)
            {
                var t = _targets[i];
                if (t.Confirmed) continue;                 // 已点过：不参与提示
                var owner = t.Owner;
                if (owner == null || owner.Rect == null) continue;
                if (!hintedOwners.Add(owner)) continue;     // 同一物件挂多目标时只处理一次

                var face = FindFaceInObject(owner, t.Spec.Id);
                var faceIsFront = face == null || face.Back == owner.ShowingBack; // 目标面是否已经朝前

                // 每个物件一个独立高亮实例：支持两件一起高亮（单个 _activeHighlight 做不到）。
                var hl = NewHighlight("HintHL_" + owner.Spec.Id);
                hl.Show(owner.Rect, MiniGameTheme.Yellow, 3f, 8f);
                _hintHighlights.Add(hl);

                // 未翻到目标面才给箭头；已翻好只高亮线索点。
                if (!faceIsFront)
                    SpawnHintArrow(owner);
            }

            if (_hintArrows.Count > 0)
                _hintArrowRoutine = StartCoroutine(FadeHintArrowsRoutine());
        }

        /// <summary>W-04 翻转箭头：直接用美术文档概念图 FlipArrow_W04（墨蓝弧形箭头、透明底）。
        /// 不接收点击；只在二级提示时淡入淡出（§5.4 选项 C）。资源缺失时回落 "↻" 文字占位。</summary>
        const string FlipArrowResource = "MiniGameArt/FlipArrow_W04";

        void SpawnHintArrow(FlipObjectView owner)
        {
            RectTransform arrowRect;
            var sprite = Resources.Load<Sprite>(FlipArrowResource);
            if (sprite != null)
            {
                arrowRect = MiniGameUIKit.SpriteArt(Body, "HintArrow_" + owner.Spec.Id,
                    FlipArrowResource, Color.white);
            }
            else
            {
                var label = MiniGameUIKit.Label(Body, "HintArrow_" + owner.Spec.Id, 64f,
                    MiniGameTheme.Deep, TextAlignmentOptions.Center);
                label.text = "↻";
                label.raycastTarget = false;
                arrowRect = label.rectTransform;
            }
            var group = arrowRect.gameObject.AddComponent<CanvasGroup>();
            group.alpha = 0f;
            group.blocksRaycasts = false;
            // 放在物件正上方（Body 左上锚坐标系）
            MiniGameUIKit.Place(arrowRect, new Vector2(0f, 1f), new Vector2(0.5f, 0.5f),
                BodyPoint(owner.Spec.Pos.x, owner.Spec.Pos.y - owner.Spec.Size.y * 0.5f - 42f),
                new Vector2(96f, 96f));
            arrowRect.SetAsLastSibling();
            _hintArrows.Add(arrowRect.gameObject);
        }

        /// <summary>箭头淡入 0.35s → 停留 1.5s → 淡出 0.4s（W-04 选项 C）。</summary>
        System.Collections.IEnumerator FadeHintArrowsRoutine()
        {
            var groups = new CanvasGroup[_hintArrows.Count];
            for (var i = 0; i < _hintArrows.Count; i++)
                groups[i] = _hintArrows[i].GetComponent<CanvasGroup>();

            const float fadeIn = 0.35f, hold = 1.5f, fadeOut = 0.4f;
            var t = 0f;
            while (t < fadeIn)
            {
                t += Time.unscaledDeltaTime;
                SetArrowAlpha(groups, Mathf.Clamp01(t / fadeIn));
                yield return null;
            }
            SetArrowAlpha(groups, 1f);
            yield return new WaitForSecondsRealtime(hold);
            t = 0f;
            while (t < fadeOut)
            {
                t += Time.unscaledDeltaTime;
                SetArrowAlpha(groups, 1f - Mathf.Clamp01(t / fadeOut));
                yield return null;
            }
            SetArrowAlpha(groups, 0f);
        }

        static void SetArrowAlpha(CanvasGroup[] groups, float a)
        {
            for (var i = 0; i < groups.Length; i++)
                if (groups[i] != null) groups[i].alpha = a;
        }

        /// <summary>清掉上一次二级提示留下的箭头与额外高亮，避免重复点击累积。</summary>
        void ClearHintVisuals()
        {
            if (_hintArrowRoutine != null) { StopCoroutine(_hintArrowRoutine); _hintArrowRoutine = null; }
            for (var i = 0; i < _hintArrows.Count; i++)
                if (_hintArrows[i] != null) Destroy(_hintArrows[i]);
            _hintArrows.Clear();
            for (var i = 0; i < _hintHighlights.Count; i++)
                if (_hintHighlights[i] != null) _hintHighlights[i].Hide();
            _hintHighlights.Clear();
        }

        FlipObjectView FindBlockerOf(FlipObjectView owner)
        {
            for (var i = 0; i < _objects.Count; i++)
            {
                var b = _objects[i];
                if (b == owner || b.Spec.IsDecoy) continue;
                if (b.Spec.OccludesObjectId == owner.Spec.Id && b.Spec.SortOrder > owner.Spec.SortOrder)
                    return b;
            }
            return null;
        }

        // ---------------- 进度 ----------------

        protected override void ApplyProgress(MiniGameProgress progress)
        {
            if (progress == null || string.IsNullOrEmpty(progress.MaskBase64)) return;
            SyncJudgeFromProgress(progress);

            // 单物体 "ids|angle"；多物体 "ids|a0,a1,..."（按 _objects 顺序）
            var raw = MagnifierBoard.Csv(progress.MaskBase64);
            var parts = raw.Split('|');
            var angles = parts.Length > 1 ? parts[1].Split(',') : new string[0];

            if (UseMulti)
            {
                for (var i = 0; i < _objects.Count && i < angles.Length; i++)
                {
                    float a;
                    if (float.TryParse(angles[i], out a)) ApplyObjectAngle(_objects[i], a);
                }
            }
            else if (angles.Length > 0)
            {
                float angle;
                if (float.TryParse(angles[0], out angle)) ApplyAngle(angle, true);
            }

            if (parts.Length > 0 && parts[0].Length > 0)
            {
                var ids = parts[0].Split(',');
                for (var i = 0; i < ids.Length; i++) RestoreConfirmed(ids[i]);
            }

            if (UseMulti) RefreshMultiTargets();
            else ApplyAngle(_angle, true);
        }

        void RestoreConfirmed(string id)
        {
            for (var t = 0; t < _targets.Count; t++)
            {
                if (_targets[t].Spec.Id != id) continue;
                var target = _targets[t];
                target.Confirmed = true;
                var image = target.Rect.GetComponent<Image>();
                if (image != null) image.color = MiniGameTheme.Alpha(MiniGameTheme.Green, 0.9f);
                if (target.Rail != null)
                {
                    RevealRail(target.Rail);
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

        public override MiniGameProgress CaptureProgress()
        {
            var progress = NewProgress();
            var ids = new List<string>();
            for (var i = 0; i < _targets.Count; i++)
                if (_targets[i].Confirmed) ids.Add(_targets[i].Spec.Id);

            string angles;
            if (UseMulti)
            {
                var parts = new List<string>();
                for (var i = 0; i < _objects.Count; i++)
                    parts.Add(Mathf.RoundToInt(_objects[i].Angle).ToString());
                angles = string.Join(",", parts.ToArray());
            }
            else angles = Mathf.RoundToInt(_angle).ToString();

            progress.MaskBase64 = MagnifierBoard.Encode(string.Join(",", ids.ToArray()) + "|" + angles);
            return progress;
        }
    }
}
