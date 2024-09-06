
using System;
using UnityEngine;
public class LightAnim : MonoBehaviour
{
    public float speed = 30f;

    private void Start()
    {
        transform.eulerAngles = Vector3.zero;
        transform.rotation = Quaternion.identity;

    }

    private void Update()
    {
        Vector3 diagonalAxis = new Vector3(1, 1, 0).normalized;

        // Rotate around the diagonal axis at 'speed' degrees per second
        transform.Rotate(diagonalAxis, speed * Time.deltaTime);
    }

}
