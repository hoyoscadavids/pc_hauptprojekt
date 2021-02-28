using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BuildDungeon : MonoBehaviour {

    /// <summary>
    ///
    /// Use coordinates to build a level
    /// 
    /// </summary>


    //[SerializeField] GameObject testPrefab;
    [SerializeField] GameObject topOpen, rightOpen, bottomOpen, leftOpen;
    [SerializeField] GameObject topBottomOpen, leftRightOpen;
    [SerializeField] GameObject topRightOpen, rightBottomOpen, bottomLeftOpen, leftTopOpen;

    [SerializeField] string jsonFileName = "test_positions";

    [SerializeField] float radius = 0.1f;


    void Start() {

        List<Vector3> points = ClearForDungeon.Points(ReadJSON.pointsV3(jsonFileName), radius);

        if (points[1].x > points[0].x) {
            Instantiate(rightOpen, points[0], Quaternion.identity);
        }

        else if (points[1].x < points[0].x) {
            Instantiate(leftOpen, points[0], Quaternion.identity);
        }

        else if (points[1].z > points[0].z) {
            Instantiate(topOpen, points[0], Quaternion.identity);
        }

        else { 
            Instantiate(bottomOpen, points[0], Quaternion.identity);
        }

        for (int i = 1; i < points.Count - 1; i++) {

            //Instantiate(testPrefab, points[i], Quaternion.identity);

            //if ((points[i].x > points[i - 1].x && points[i].x < points[i + 1].x) ||
            //    (points[i].x < points[i - 1].x && points[i].x > points[i + 1].x)) {
            //    Instantiate(leftRightOpen, points[i], Quaternion.identity);
            //}

            //else if ((points[i].z > points[i - 1].z && points[i].z < points[i + 1].z) ||
            //    (points[i].z < points[i - 1].z && points[i].z > points[i + 1].z)) {
            //    Instantiate(topBottomOpen, points[i], Quaternion.identity);
            //}

            if (points[i].x > points[i - 1].x) {
                if (points[i].x < points[i + 1].x) {
                    Instantiate(leftRightOpen, points[i], Quaternion.identity);
                }

                else if (points[i].z > points[i + 1].z) {
                    Instantiate(bottomLeftOpen, points[i], Quaternion.identity);
                }

                else {
                    Instantiate(leftTopOpen, points[i], Quaternion.identity);
                }
            }

            else if (points[i].x < points[i - 1].x) {
                if (points[i].x > points[i + 1].x) {
                    Instantiate(leftRightOpen, points[i], Quaternion.identity);
                }

                else if (points[i].z > points[i + 1].z) {
                    Instantiate(rightBottomOpen, points[i], Quaternion.identity);
                }

                else {
                    Instantiate(topRightOpen, points[i], Quaternion.identity);
                }
            }

            else if (points[i].z > points[i - 1].z) {
                if (points[i].x > points[i + 1].x) {
                    Instantiate(bottomLeftOpen, points[i], Quaternion.identity);
                }

                else if (points[i].x < points[i + 1].x) {
                    Instantiate(rightBottomOpen, points[i], Quaternion.identity);
                }

                else {
                    Instantiate(topBottomOpen, points[i], Quaternion.identity);
                }
            }

            else {
                if (points[i].x > points[i + 1].x) {
                    Instantiate(leftTopOpen, points[i], Quaternion.identity);
                }

                else if (points[i].x < points[i + 1].x) {
                    Instantiate(topRightOpen, points[i], Quaternion.identity);
                }

                else if (points[i].z > points[i + 1].z) {
                    Instantiate(topBottomOpen, points[i], Quaternion.identity);
                }
            }

        }

        if (points[points.Count - 1].x > points[points.Count - 2].x) {
            Instantiate(leftOpen, points[points.Count - 1], Quaternion.identity);
        }

        else if (points[points.Count - 1].x < points[points.Count - 2].x) {
            Instantiate(rightOpen, points[points.Count - 1], Quaternion.identity);
        }

        else if (points[points.Count - 1].z > points[points.Count - 2].z) {
            Instantiate(bottomOpen, points[points.Count - 1], Quaternion.identity);
        }

        else {
            Instantiate(topOpen, points[points.Count - 1], Quaternion.identity);
        }

    }

}