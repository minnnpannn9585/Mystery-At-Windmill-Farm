using System.Collections.Generic;
using UnityEngine;

namespace EggRescue
{
    public sealed class ClimbPathPoint : MonoBehaviour
    {
        public string pathId = "barn";
        public int pointIndex;
        public string unlockVarName = "E06_LadderPlaced";
        public GameObject targetVfx;

        sealed class PathState
        {
            public string UnlockVar;
            public bool Unlocked;
            public int ActiveIndex = -1;
            public readonly Dictionary<int, ClimbPathPoint> Points = new Dictionary<int, ClimbPathPoint>();
        }

        static readonly Dictionary<string, PathState> Paths = new Dictionary<string, PathState>();

        void Start()
        {
            PathState path;
            if (!Paths.TryGetValue(pathId, out path))
            {
                path = new PathState { UnlockVar = unlockVarName };
                Paths[pathId] = path;
            }
            path.Points[pointIndex] = this;
            Refresh(pathId);
        }

        void Update()
        {
            Refresh(pathId);
        }

        void OnTriggerEnter(Collider other)
        {
            if (!InteractionUtil.IsLocalPlayer(other)) return;
            Advance(pathId, pointIndex);
        }

        public static void Refresh(string pathKey)
        {
            PathState path;
            if (!Paths.TryGetValue(pathKey, out path) || path.Unlocked) return;
            if (!GameState.GetBool(path.UnlockVar)) return;
            path.Unlocked = true;
            path.ActiveIndex = 0;
            ClimbPathPoint first;
            if (path.Points.TryGetValue(0, out first))
                first.SetVfx(true);
        }

        public static void Advance(string pathKey, int fromIndex)
        {
            PathState path;
            if (!Paths.TryGetValue(pathKey, out path) || !path.Unlocked) return;
            if (path.ActiveIndex != fromIndex) return;
            ClimbPathPoint current;
            if (path.Points.TryGetValue(fromIndex, out current))
                current.SetVfx(false);
            var next = fromIndex + 1;
            ClimbPathPoint nextPoint;
            if (path.Points.TryGetValue(next, out nextPoint))
            {
                path.ActiveIndex = next;
                nextPoint.SetVfx(true);
            }
            else path.ActiveIndex = -1;
        }

        void SetVfx(bool visible)
        {
            var vfx = targetVfx != null ? targetVfx : (transform.Find("targetVfx") != null ? transform.Find("targetVfx").gameObject : null);
            if (vfx == null) return;
            vfx.SetActive(visible);
            if (!visible) return;
            var systems = vfx.GetComponentsInChildren<ParticleSystem>(true);
            for (var i = 0; i < systems.Length; i++)
            {
                systems[i].Clear(true);
                systems[i].Play(true);
            }
        }
    }
}
