using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class CollectCoordinates : MonoBehaviour {

    /// <summary>
    ///
    /// Collect Coordinates via MouseInputs and store them in a list
    /// 
    /// </summary>


    List<Vector3> coordinates = new List<Vector3>();
    public static List<Vector3> clearedCoordinates = new List<Vector3>();

    public static HashSet<Vector3> coordinatesHS = new HashSet<Vector3>();


    void Start() {

    }


    void Update() {

        if (Input.GetMouseButton(0)) {
            coordinates.Add(Camera.main.ScreenToWorldPoint(Input.mousePosition));
            coordinatesHS.Add(Camera.main.ScreenToWorldPoint(Input.mousePosition));
            clearedCoordinates = coordinates.Distinct().ToList();
        }

        if (Input.GetMouseButtonUp(0)) {
            Debug.Log("List: " + clearedCoordinates.Count);
            Debug.Log("HasSet: " + coordinatesHS.Count);
        }



    }

}