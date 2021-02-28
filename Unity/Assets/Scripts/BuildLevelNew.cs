using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuildLevelNew : MonoBehaviour {

    /// <summary>
    ///
    /// Use coordinates to build a level
    /// 
    /// </summary>


    [SerializeField] GameObject prefab;

    GameObject firstObject, secondObject;

    [SerializeField] string jsonFileName = "test_positions";

    [SerializeField] float radius = 0.05f;


    void Start() {

        List<Vector3> points = ClearCoordinates.Points(ReadJSON.pointsV3(jsonFileName), radius);

        firstObject = Instantiate(prefab, points[0], Quaternion.identity);
        secondObject = Instantiate(prefab, points[1], Quaternion.LookRotation(points[1] - points[0], Vector3.up));

        for (int i = 2; i < points.Count; i++) {
            Instantiate(prefab, points[i], Quaternion.LookRotation(points[i] - points[i - 1], Vector3.up));
            //transform.LookAt(superCleanedCoordinates[i - 1]
        }

        firstObject.transform.LookAt(secondObject.transform);

    }

}