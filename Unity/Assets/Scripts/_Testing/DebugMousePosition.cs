using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugMousePosition : MonoBehaviour {



    void Start() {

    }


    void Update() {

        if (Input.GetMouseButtonDown(0)) {
            //Debug.Log(Camera.main.ScreenToWorldPoint(Input.mousePosition));
            Debug.Log(Input.mousePosition);
        }

    }

}