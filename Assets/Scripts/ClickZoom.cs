using UnityEngine;

public class ClickZoom : MonoBehaviour
{
    public Camera mainCamera;
    public float zoomSpeed = 2f;
    public float zoomDistance = 5f;
    public Transform target;

    private Vector3 originalCameraPosition;
    private bool zooming = false;
    private bool unzooming = false;

    void Start()
    {
        originalCameraPosition = mainCamera.transform.position;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            Ray ray = mainCamera.ScreenPointToRay(Input.mousePosition);
            RaycastHit hit;

            if (Physics.Raycast(ray, out hit))
            {

                if (hit.collider != null && hit.collider.CompareTag("Sphere"))
                {
                    target = hit.collider.transform;
                    zooming = true;
                    Debug.Log(hit.collider.gameObject.name);
                }
            }
        }

        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            unzooming = true;
        }

        if (zooming)
        {
            ZoomToTarget();
        }

        if (unzooming)
        {
            ResetZoom();
        }


    }

    void ZoomToTarget()
    {
        if (target != null)
        {
            Vector3 targetPosition = target.position - (target.forward * zoomDistance + target.up * 0.2f); // Adjusted for text, so that the ball and name are in the center of the screen.
            mainCamera.transform.position = Vector3.Lerp(mainCamera.transform.position, targetPosition, Time.deltaTime * zoomSpeed);

            // Optional: You can stop zooming once the camera reaches the desired position
            if (Vector3.Distance(mainCamera.transform.position, targetPosition) < 0.1f)
            {
                zooming = false;
            }
        }
    }

    public void ResetZoom()
    {
        mainCamera.transform.position = Vector3.Lerp(mainCamera.transform.position, originalCameraPosition, Time.deltaTime * zoomSpeed);

        if (Vector3.Distance(mainCamera.transform.position, originalCameraPosition) < 0.1f)
        {
            unzooming = false;
        }

        target = null;
    }
}
