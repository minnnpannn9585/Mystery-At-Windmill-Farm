using UnityEngine;

[ExecuteAlways]
public class PainterlyBounds : MonoBehaviour
{
    private static readonly int MinYID =
        Shader.PropertyToID("_PainterlyMinY");

    private static readonly int HeightID =
        Shader.PropertyToID("_PainterlyHeight");

    private MaterialPropertyBlock block;


    private void OnEnable()
    {
        RefreshBounds();
    }


    private void OnValidate()
    {
        RefreshBounds();
    }


    [ContextMenu("Refresh Painterly Bounds")]
    public void RefreshBounds()
    {
        Renderer[] renderers =
            GetComponentsInChildren<Renderer>(true);

        if (renderers.Length == 0)
            return;


        Bounds bounds = renderers[0].bounds;

        for (int i = 1; i < renderers.Length; i++)
        {
            bounds.Encapsulate(renderers[i].bounds);
        }


        float minY = bounds.min.y;
        float height = Mathf.Max(bounds.size.y, 0.0001f);


        if (block == null)
            block = new MaterialPropertyBlock();


        foreach (Renderer r in renderers)
        {
            block.Clear();

            r.GetPropertyBlock(block);

            block.SetFloat(MinYID, minY);
            block.SetFloat(HeightID, height);

            r.SetPropertyBlock(block);
        }
    }
}