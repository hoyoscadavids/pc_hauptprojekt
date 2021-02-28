using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawLine : MonoBehaviour {


    public GameObject linePrefab;
    public GameObject currentLine;

    public LineRenderer lr;
    public List<Vector3> fingerPos;


    void Update() {

        if (Input.GetMouseButtonUp(0)) {
            DrawThatLine();
        }

        if (Input.GetMouseButton(0)) {

            Vector3 currentFingerPos = Camera.main.ScreenToWorldPoint(Input.mousePosition);

            if (Vector3.Distance(currentFingerPos, fingerPos[fingerPos.Count - 1]) > .1f) {
                UpdateLine(currentFingerPos);
            }

        }

    }


    void DrawThatLine() {

        currentLine = Instantiate(linePrefab, Vector3.zero, Quaternion.identity);
        lr = currentLine.GetComponent<LineRenderer>();
        fingerPos.Clear();
        fingerPos.Add(Camera.main.ScreenToViewportPoint(Input.mousePosition));
        fingerPos.Add(Camera.main.ScreenToViewportPoint(Input.mousePosition));
        lr.SetPosition(0, fingerPos[0]);
        lr.SetPosition(1, fingerPos[1]);

    }


    void UpdateLine(Vector3 newFingerPos) {

        fingerPos.Add(newFingerPos);
        lr.positionCount++;
        lr.SetPosition(lr.positionCount - 1, newFingerPos);

    }

}