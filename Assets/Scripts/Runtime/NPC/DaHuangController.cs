using UnityEngine;

namespace EggRescue
{
    public sealed class DaHuangController : MonoBehaviour
    {
        public GameObject sleepDog;
        public GameObject soberDog;

        bool? _lastSpotEnabled;
        bool? _lastAwake;

        bool IsRedRoofSpot { get { return gameObject.name == "大黄 2"; } }

        void Start() { AutoBind(); CheckDogState(); }

        void AutoBind()
        {
            if (sleepDog == null || soberDog == null)
            {
                var tfs = GetComponentsInChildren<Transform>(true);
                for (var i = 0; i < tfs.Length; i++)
                {
                    var n = tfs[i].name;
                    if (sleepDog == null && (n.Contains("sleep") || n.Contains("Sleep") || n.Contains("醉") || n.Contains("drunk")))
                        sleepDog = tfs[i].gameObject;
                    if (soberDog == null && (n.Contains("sober") || n.Contains("Sober") || n.Contains("醒") || n.Contains("awake")))
                        soberDog = tfs[i].gameObject;
                }
            }
        }

        void Update() { CheckDogState(); }

        void CheckDogState()
        {
            var dogStatus = GameState.GetInt("DogStatus", 1);
            var isChapter2 = dogStatus >= 4;
            var redRoof = IsRedRoofSpot;
            var spotEnabled = redRoof ? isChapter2 : !isChapter2;
            var isAwake = dogStatus >= 3;
            if (_lastSpotEnabled == spotEnabled && _lastAwake == isAwake) return;
            var spotChanged = _lastSpotEnabled.HasValue && _lastSpotEnabled.Value != spotEnabled;
            var awakeChanged = _lastAwake.HasValue && _lastAwake.Value != isAwake;
            _lastSpotEnabled = spotEnabled;
            _lastAwake = isAwake;
            InteractionUtil.SetInteractionEnabled(gameObject, spotEnabled);
            if (!spotEnabled)
            {
                if (spotChanged) AudioDirector.PlayParticle("vfx_characterChange", GetVfxPosition());
                if (sleepDog != null) sleepDog.SetActive(false);
                if (soberDog != null) soberDog.SetActive(false);
                return;
            }
            if (redRoof) ApplyAwake(true, spotChanged);
            else ApplyAwake(isAwake, spotChanged || awakeChanged);
        }

        void ApplyAwake(bool isAwake, bool playVfx)
        {
            if (playVfx) AudioDirector.PlayParticle("vfx_characterChange", GetVfxPosition());
            if (sleepDog != null) sleepDog.SetActive(!isAwake);
            if (soberDog != null) soberDog.SetActive(isAwake);
        }

        Vector3 GetVfxPosition()
        {
            if (soberDog != null && soberDog.activeSelf) return soberDog.transform.position;
            if (sleepDog != null && sleepDog.activeSelf) return sleepDog.transform.position;
            if (soberDog != null) return soberDog.transform.position;
            if (sleepDog != null) return sleepDog.transform.position;
            return transform.position;
        }
    }
}
