using System.Collections.Generic;
using UnityEngine;

namespace WindmillFarm.Water
{
    /// <summary>
    /// 让所有水面不再阻挡玩家。
    ///
    /// 水体包里的 Water 预制体带了 Collider，玩家走进去会被当成地板踩住（或直接卡住），
    /// 游泳就没法做了。这里在开场后把「玩家身上所有 Collider / CharacterController」
    /// 与「所有水面的 Collider」两两做 Physics.IgnoreCollision，
    /// 只影响玩家与水这一对，其它物体（荷叶、石头）的水面碰撞不受影响。
    ///
    /// 想连其它物体也不撞水，把 disableWaterColliders 勾上（直接关掉水面 Collider）。
    /// </summary>
    [DefaultExecutionOrder(-100)]
    [DisallowMultipleComponent]
    [AddComponentMenu("Water/Water Collision Filter")]
    public class WaterCollisionFilter : MonoBehaviour
    {
        [Tooltip("玩家 Tag")]
        public string playerTag = "Player";

        [Tooltip("勾上则直接禁用所有水面 Collider（连其它物体也不撞水）")]
        public bool disableWaterColliders;

        [Tooltip("每隔多少秒重新扫一遍（水面/玩家可能之后才生成）。0 = 只扫一次")]
        public float rescanInterval = 0.5f;

        [Tooltip("判定「这是水」用的材质属性名")]
        public string waterMaterialProbe = "_WaterfallTurbulencePose";

        static readonly List<Collider> s_playerColliders = new List<Collider>();
        static readonly HashSet<(Collider, Collider)> s_done = new HashSet<(Collider, Collider)>();

        float _nextScan;

        /// <summary>
        /// 场景里没有本组件时自动建一个，保证「水不挡玩家」默认生效。
        /// 不想要就手动放一个本组件并勾掉 enabled，或者删掉这个特性。
        /// </summary>
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        static void EnsureInScene()
        {
            if (Object.FindObjectOfType<WaterCollisionFilter>() != null) return;
            var go = new GameObject("[WaterCollisionFilter]");
            go.AddComponent<WaterCollisionFilter>();
            Object.DontDestroyOnLoad(go);
        }

        void Start()
        {
            Scan();
            _nextScan = Time.time + Mathf.Max(0.1f, rescanInterval);
        }

        void Update()
        {
            if (rescanInterval <= 0f) return;
            if (Time.time < _nextScan) return;
            _nextScan = Time.time + rescanInterval;
            Scan();
        }

        public void Scan()
        {
            var player = GameObject.FindGameObjectWithTag(playerTag);
            if (player == null) return;

            s_playerColliders.Clear();
            player.GetComponentsInChildren(true, s_playerColliders);
            if (s_playerColliders.Count == 0) return;

            int probeId = Shader.PropertyToID(waterMaterialProbe);

            foreach (Renderer r in Object.FindObjectsOfType<Renderer>())
            {
                if (r is ParticleSystemRenderer || r is SpriteRenderer) continue;
                if (!IsWaterRenderer(r, probeId)) continue;

                var cols = r.GetComponentsInChildren<Collider>(true);
                for (int i = 0; i < cols.Length; i++)
                {
                    Collider wc = cols[i];
                    if (wc == null) continue;

                    // 登记给相机避让（SphereCast 不受 IgnoreCollision 影响）
                    WaterSurface.RegisterWaterCollider(wc);

                    if (disableWaterColliders)
                    {
                        if (wc.enabled) wc.enabled = false;
                        continue;
                    }

                    for (int j = 0; j < s_playerColliders.Count; j++)
                    {
                        Collider pc = s_playerColliders[j];
                        if (pc == null || pc == wc) continue;

                        var key = (pc, wc);
                        if (!s_done.Add(key)) continue;

                        Physics.IgnoreCollision(pc, wc, true);
                    }
                }
            }
        }

        static bool IsWaterRenderer(Renderer r, int probeId)
        {
            Material[] mats = r.sharedMaterials;
            for (int i = 0; i < mats.Length; i++)
            {
                if (mats[i] != null && mats[i].HasProperty(probeId)) return true;
            }
            return false;
        }

        /// <summary>场景里重新洗牌（传送/换场景）后调用，清掉缓存重新建立忽略关系。</summary>
        public static void ResetCache()
        {
            s_done.Clear();
            s_playerColliders.Clear();
        }
    }
}
