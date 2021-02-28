using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using System.Linq;

public abstract class ReadJSON : MonoBehaviour {

    /// <summary>
    ///
    /// Reads JSON File and stores coordinates in List / HashSet
    /// 
    /// </summary>
    

    //[SerializeField] string jsonFileNameTransfer = "test_positions";
    //public static string jsonFileName;

    ////public static List<Vector3> pointsV3 = new List<Vector3>();


    //void Start() {
    //    jsonFileName = jsonFileNameTransfer;
    //}


    public static List<Vector3> pointsV3(string jsonFileName) {

        List<Vector3> pointsV3 = new List<Vector3>();

        string path = Application.dataPath + "/JSON/" + jsonFileName + ".json";
        string jsonString = File.ReadAllText(path);

        ListOfPoints points = JsonUtility.FromJson<ListOfPoints>(jsonString);
        //Debug.Log(points.positions.Count);

        foreach (var point in points.positions) {

            //Debug.Log("x = " + point.x + " & y = " + point.y);

            pointsV3.Add(new Vector3(point.x, 0, point.y));

            /// Clear doubles
            pointsV3 = pointsV3.Distinct().ToList();

        }

        Debug.Log("Points read: " + points.positions.Count);

        return pointsV3;

    }
}


[System.Serializable]
public class ListOfPoints {
    public List<Points> positions;
}

[System.Serializable]
public class Points {
    public float x;
    public float y;
}