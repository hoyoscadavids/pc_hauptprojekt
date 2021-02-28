using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//[RequireComponent(typeof(CollectCoordinates))]
[RequireComponent(typeof(ReadJSON))]

public class BuildLevel : MonoBehaviour {

    /// <summary>
    ///
    /// Use coordinates to build a level
    /// 
    /// </summary>


    [SerializeField] GameObject prefab;

    //[SerializeField] float radius = 0.2f;

    //List<Vector3> coordinates;
    //List<Vector3> superCleanedCoordinates = new List<Vector3>();

    GameObject firstObject, secondObject;

    [SerializeField] string jsonFileName = "test_positions";

    [SerializeField] float radius = 0.05f;


    void Update() {

        if (Input.GetMouseButtonUp(0) || Input.GetKeyDown(KeyCode.Space)) {

            //ClearClearedCoordinates();
            //SortCoordinates();

            //foreach (Vector3 pos in superCleanedCoordinates) {
            //    Instantiate(prefab, new Vector3(pos.x, 0.2f, pos.z), Quaternion.identity);
            //}

            List<Vector3> points = ClearCoordinates.Points(ReadJSON.pointsV3(jsonFileName), radius);

            firstObject = Instantiate(prefab, points[0], Quaternion.identity);
            secondObject = Instantiate(prefab, points[1], Quaternion.LookRotation(points[1] - points[0], Vector3.up));

            for (byte i = 2; i < points.Count; i++) {
                Instantiate(prefab, points[i], Quaternion.LookRotation(points[i] - points[i - 1], Vector3.up));
                //transform.LookAt(superCleanedCoordinates[i - 1]
            }

            firstObject.transform.LookAt(secondObject.transform);

            Debug.Log("Points built: " + points.Count);

        }

    }


    //void ClearClearedCoordinates() {

    //    //coordinates = CollectCoordinates.clearedCoordinates;

    //    for (int i = 0; i < coordinates.Count; i++) {

    //        superCleanedCoordinates.Add(CollectCoordinates.clearedCoordinates[i]);

    //        //if (i > 0) {

    //        //    if (Vector3.Distance(coordinates[i], superCleanedCoordinates[superCleanedCoordinates.Count - 1]) >= radius) {
    //        //        superCleanedCoordinates.Add(CollectCoordinates.clearedCoordinates[i]);
    //        //    }

    //        //}

    //        //else {
    //        //    superCleanedCoordinates.Add(CollectCoordinates.clearedCoordinates[0]);
    //        //}

    //    }

    //    Debug.Log(superCleanedCoordinates.Count);

    //}


    //void SortCoordinates() {

    //    for (int i = 0; i < superCleanedCoordinates.Count; i++) {
    //        if (i > 0) {

    //            if ((superCleanedCoordinates[i].z >= superCleanedCoordinates[i - 1].z + radius || superCleanedCoordinates[i].z >= superCleanedCoordinates[i - 1].z - radius)
    //                && superCleanedCoordinates[i].x < superCleanedCoordinates[i - 1].x + radius || superCleanedCoordinates[i].x < superCleanedCoordinates[i - 1].x - radius) {
    //                superCleanedCoordinates[i] = new Vector3(superCleanedCoordinates[i - 1].x, 0, superCleanedCoordinates[i].z);
    //            }

    //            else {
    //                superCleanedCoordinates[i] = new Vector3(superCleanedCoordinates[i].x, 0, superCleanedCoordinates[i - 1].z);
    //            }

    //        }
    //    }

    //}


    //void InstantiatePrefab() {

    //    for (int i = 0; i < CollectCoordinates.clearedCoordinates.Count; i++) {

    //        Vector3 pos = new Vector3(CollectCoordinates.clearedCoordinates[i].x, 0.1f, CollectCoordinates.clearedCoordinates[i].z);

    //        if (i == 0) {
    //            Instantiate(prefab, pos, Quaternion.identity);
    //        }

    //        else {

    //            //if ()

    //        }

    //    }

    //}

}