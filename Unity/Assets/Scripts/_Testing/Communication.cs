using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Communication : SocketFloat {


    float[] testData = new float[3];

    Vector3[] coordinates;


    void Start() {
        for (int i = 0; i < testData.Length; i++) {
            testData[i] = (i + 1) * 1.1f;
        }    
    }


    void Update() {

        if (Input.GetKeyDown(KeyCode.Space)) {

            ServerRequest(testData);
            ConvertTransmittedDataToArrayOfVector3(dataIn);

        }

    }


    void ConvertTransmittedDataToArrayOfVector3(float[] rawCoordinates) {

        coordinates = new Vector3[rawCoordinates.Length / 3];

        for (int i = 0; i < coordinates.Length; i ++) {

            coordinates[i] = new Vector3(rawCoordinates[i * 3], 0, rawCoordinates[(i * 3) + 2]);

        }

        /// Testing
        foreach(Vector3 vec in coordinates) {
            Debug.Log(vec);
        }

    }

}