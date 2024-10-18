using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class MaterialColorController : MonoBehaviour
{
    [System.Serializable]
    public class ShaderMaterial
    {
        public Material material;
        public string colorProperty = "_DiffuseColour";
    }

    public List<ShaderMaterial> materialsList = new List<ShaderMaterial>();

    [Header("Color Settings")]
    public Color newColor = Color.white;

    void OnEnable()
    {
        PopulateMaterialsByTag("Sphere");
    }

    void PopulateMaterialsByTag(string tag)
    {
        materialsList.Clear();
        GameObject[] spheres = GameObject.FindGameObjectsWithTag(tag);

        foreach (GameObject sphere in spheres)
        {
            Renderer renderer = sphere.GetComponent<Renderer>();

            if (renderer != null)
            {
                foreach (Material mat in renderer.sharedMaterials)
                {
                    ShaderMaterial shaderMaterial = new ShaderMaterial();
                    shaderMaterial.material = mat;
                    shaderMaterial.colorProperty = "_DiffuseColour";
                    materialsList.Add(shaderMaterial);
                }
            }
        }
    }

    public void ApplyColor()
    {
        foreach (ShaderMaterial shaderMaterial in materialsList)
        {
            if (shaderMaterial.material.HasProperty(shaderMaterial.colorProperty))
            {
                shaderMaterial.material.SetColor(shaderMaterial.colorProperty, newColor);
            }
            else
            {
                Debug.LogWarning("Material does not have color property: " + shaderMaterial.colorProperty);
            }
        }
    }

    void OnValidate()
    {
        ApplyColor();
    }
}
