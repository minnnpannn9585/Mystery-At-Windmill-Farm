using UnityEngine;

namespace EggRescue.MiniGame
{
    /// <summary>
    /// 指针携带物。§18.2.3 的第一个原语，七个模板全用：
    /// T1 镜片 / T2 草束 / T3 物件 / T4 图块 / T5 炭条 / T6 镊子 / T7 卡片。
    ///
    /// 只负责「把某个 RectTransform 跟着指针走」这一件事，判定交给 DropTarget / JudgeStep。
    /// 判定永远读 <see cref="LocalPosition"/>（未旋转的中心），倾斜只作用在显示上——
    /// 这样 T2 拎着甩的时候，中心入框的判定直觉不会被破坏（§7.3）。
    /// </summary>
    public sealed class CarryHandle
    {
        public RectTransform Target;
        public RectTransform Area;

        /// <summary>携带物 id（Q01 的「画着爱心的蛋」、T4 的格号等）。落点判定比它，不比名字。</summary>
        public string Id;

        /// <summary>位置平滑。默认 0.06；T1 0.12、T4 0.05（§18.2.5）。</summary>
        public float SmoothTime = MiniGameMotion.FollowSmoothTime;

        /// <summary>角度平滑，比位置慢才产生「甩」的滞后。仅在 MaxTilt &gt; 0 时生效。</summary>
        public float TiltSmoothTime = MiniGameMotion.TiltSmoothTime;

        /// <summary>角度 = clamp(−vx × 系数, ±MaxTilt)。T2 用 0.05 / 10°，T6 用 0.05 / 6°。</summary>
        public float TiltPerVelocity = 0.05f;

        /// <summary>0 = 不倾斜。</summary>
        public float MaxTilt;

        /// <summary>T5 的炭条进主区就跟手，不需要按下。</summary>
        public bool RequirePress = true;

        public bool ClampToArea = true;

        Vector2 _current;
        Vector2 _velocity;
        float _tilt;
        float _tiltVelocity;
        bool _active;
        bool _pressed;

        public bool Active { get { return _active; } }
        public bool Pressed { get { return _pressed; } }

        /// <summary>未旋转的中心点（局部坐标）。判定只用它。</summary>
        public Vector2 LocalPosition { get { return _current; } }

        public float Tilt { get { return _tilt; } }

        /// <summary>指针进入（或按下）。位置直接吸附到指针，避免起手时从旧位置滑过来。</summary>
        public void Begin(Vector2 localPoint)
        {
            _active = true;
            _pressed = true;
            _velocity = Vector2.zero;
            _tiltVelocity = 0f;
            _current = Clamp(localPoint);
            Apply();
        }

        /// <summary>每帧由 Board 驱动。dt 用 unscaled，暂停时手感不抖。</summary>
        public void MoveTo(Vector2 localPoint, float dt)
        {
            if (!_active || Target == null) return;
            var desired = Clamp(localPoint);
            var before = _current;
            if (dt <= 0f) dt = Time.unscaledDeltaTime;
            _current = Vector2.SmoothDamp(_current, desired, ref _velocity, Mathf.Max(0.0001f, SmoothTime),
                Mathf.Infinity, dt);

            if (MaxTilt > 0f)
            {
                var vx = (_current.x - before.x) / Mathf.Max(0.0001f, dt);
                var tiltTarget = Mathf.Clamp(-vx * TiltPerVelocity, -MaxTilt, MaxTilt);
                _tilt = Mathf.SmoothDampAngle(_tilt, tiltTarget, ref _tiltVelocity,
                    Mathf.Max(0.0001f, TiltSmoothTime), Mathf.Infinity, dt);
            }
            Apply();
        }

        /// <summary>松开。位置停在最后的状态，由 Board 决定弹回还是吸附。</summary>
        public void End()
        {
            _active = false;
            _pressed = false;
            _velocity = Vector2.zero;
        }

        /// <summary>外部改了位置（吸附到槽里）之后同步内部状态，避免下次起手跳一下。</summary>
        public void SyncTo(Vector2 localPoint)
        {
            _current = localPoint;
            _velocity = Vector2.zero;
            _tilt = 0f;
            _tiltVelocity = 0f;
            Apply();
        }

        void Apply()
        {
            if (Target == null) return;
            Target.anchoredPosition = _current;
            Target.localEulerAngles = new Vector3(0f, 0f, MaxTilt > 0f ? _tilt : 0f);
        }

        Vector2 Clamp(Vector2 p)
        {
            if (!ClampToArea || Area == null) return p;
            var r = Area.rect;
            // 允许携带物半径越界一半，太严会让边缘目标摸不到
            var half = Target != null ? Target.rect.size * 0.5f : Vector2.zero;
            return new Vector2(
                Mathf.Clamp(p.x, r.xMin + half.x * 0.5f, r.xMax - half.x * 0.5f),
                Mathf.Clamp(p.y, r.yMin + half.y * 0.5f, r.yMax - half.y * 0.5f));
        }
    }
}
