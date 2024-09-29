using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class OutlineManager : MonoBehaviour
{
    [SerializeField] private Shader shader;

    private Material material;

    [SerializeField] private Color OutlineColour;
    [SerializeField] [Range (1,5)]private float EdgeMultiplier = 1;
    [SerializeField] [Range (0,2)]private float EdgeThickness = 1;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (material == null)
            material = new Material(shader);

        material.SetColor("_OutlineColour", OutlineColour);
        material.SetFloat("_EdgeMultiplier", EdgeMultiplier);
        material.SetFloat("_EdgeThickness", EdgeThickness);

        Graphics.Blit(source, destination, material);
    }
}
