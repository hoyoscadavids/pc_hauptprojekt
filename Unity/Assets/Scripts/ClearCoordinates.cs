using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class ClearCoordinates : MonoBehaviour {


    public static List<Vector3> Points(List<Vector3> points, float radius) {

        List<Vector3> clearedPoints = new List<Vector3>();

        for (int i = 0; i < points.Count; i++) {

            if (i > 0) {

                if (Vector3.Distance(points[i], clearedPoints[clearedPoints.Count - 1]) >= radius) {
                    clearedPoints.Add(points[i]);
                }

            }

            else {
                clearedPoints.Add(points[0]);
            }

        }

        Debug.Log("Old pointcount: " + points.Count + ", new pointcount: " + clearedPoints.Count);

        return clearedPoints;

    }


}