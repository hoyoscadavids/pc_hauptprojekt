using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClearForDungeon : MonoBehaviour {


    public static List<Vector3> Points(List<Vector3> points, float tileSize) {

        List<Vector3> dungeonPoints = new List<Vector3>();

        for (int i = 0; i < points.Count; i++) {

            if (i > 0) {

                if ((points[i].z >= dungeonPoints[dungeonPoints.Count - 1].z + tileSize) &&
                    (points[i].x < dungeonPoints[dungeonPoints.Count - 1].x + tileSize || points[i].x > dungeonPoints[dungeonPoints.Count - 1].x - tileSize)) {

                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z + tileSize));

                }

                else if ((points[i].z <= dungeonPoints[dungeonPoints.Count - 1].z - tileSize) &&
                    (points[i].x < dungeonPoints[dungeonPoints.Count - 1].x + tileSize || points[i].x > dungeonPoints[dungeonPoints.Count - 1].x - tileSize)) {

                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z - tileSize));

                }

                else if ((points[i].x >= dungeonPoints[dungeonPoints.Count - 1].x + tileSize) &&
                    (points[i].z < dungeonPoints[dungeonPoints.Count - 1].z + tileSize || points[i].z > dungeonPoints[dungeonPoints.Count - 1].z - tileSize)) {

                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x + tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z));

                }

                else if ((points[i].x <= dungeonPoints[dungeonPoints.Count - 1].x - tileSize) &&
                    (points[i].z < dungeonPoints[dungeonPoints.Count - 1].z + tileSize || points[i].z > dungeonPoints[dungeonPoints.Count - 1].z - tileSize)) {

                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x - tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z));

                }

                else if ((points[i].z >= dungeonPoints[dungeonPoints.Count - 1].z + tileSize) && (points[i].x >= dungeonPoints[dungeonPoints.Count - 1].x + tileSize)) {
                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x + tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z + tileSize));
                }

                else if ((points[i].z >= dungeonPoints[dungeonPoints.Count - 1].z + tileSize) && (points[i].x <= dungeonPoints[dungeonPoints.Count - 1].x - tileSize)) {
                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x - tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z + tileSize));
                }

                else if ((points[i].z <= dungeonPoints[dungeonPoints.Count - 1].z - tileSize) && (points[i].x >= dungeonPoints[dungeonPoints.Count - 1].x + tileSize)) {
                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x + tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z - tileSize));
                }

                else if ((points[i].z <= dungeonPoints[dungeonPoints.Count - 1].z - tileSize) && (points[i].x <= dungeonPoints[dungeonPoints.Count - 1].x - tileSize)) {
                    dungeonPoints.Add(new Vector3(dungeonPoints[dungeonPoints.Count - 1].x - tileSize, 0.01f, dungeonPoints[dungeonPoints.Count - 1].z - tileSize));
                }

            }

            else {
                dungeonPoints.Add(new Vector3(points[0].x, 0.01f, points[0].z));
            }

        }

        Debug.Log("Old pointcount: " + points.Count + ", new pointcount: " + dungeonPoints.Count);

        return dungeonPoints;

    }


}