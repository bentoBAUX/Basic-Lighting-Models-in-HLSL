using UnityEngine;
public class LightAnim : MonoBehaviour
{
    public float speed = 30f;

    private Quaternion targetRotation;

    private void Start()
    {
        transform.eulerAngles = Vector3.zero;
        targetRotation = Quaternion.identity;
    }

    private void LateUpdate()
    {
        Vector3 diagonalAxis = new Vector3(1, 1, 0).normalized;
        targetRotation *= Quaternion.AngleAxis(speed * Time.deltaTime, diagonalAxis);
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, 0.1f);
    }

}
