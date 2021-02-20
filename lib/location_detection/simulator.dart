import 'dart:math';

import 'package:linalg/linalg.dart';

class Simulator {
  final realPositions = <Vector>[];
  final positions = <Vector>[];
  final accelerations = <Vector>[];
  void simulate(double accVar, double posVar, int samples, double deltaT) {
    positions.clear();
    accelerations.clear();

    for (var i = 0; i < samples; i++) {
      var randomAccX = (Random().nextDouble() * 5);
      var randomAccY = (Random().nextDouble() * 5);
    /*  if (i > samples / 2) {
        randomAccX = -randomAccX;
        randomAccY = -randomAccY;
      }*/
      accelerations.add(Vector.column([randomAccX, 100]));
    }

    for (var i = 0; i < samples; i++) {
      var lastPos = Vector.column([0, 0]);
      if (i != 0) {
        lastPos = Vector.column([realPositions[i - 1][0], realPositions[i - 1][1]]);
      }
      realPositions.add(Vector.column([
        lastPos[0] + accelerations[i][0] * deltaT * deltaT / 2,
        lastPos[1] + accelerations[i][1] * deltaT * deltaT / 2
      ]));
    }

    for (var i = 0; i < samples; i++) {
      final randomVarianceAcc = (Random().nextDouble() * accVar) - accVar / 2;
      accelerations[i][0] += randomVarianceAcc;
      accelerations[i][1] += randomVarianceAcc;

      var lastPos = Vector.column([0, 0]);
      if (i != 0) {
        lastPos = Vector.column([realPositions[i - 1][0], realPositions[i - 1][1]]);
      }

      if (i % 100 == 0) {
        positions.add(Vector.column([
          lastPos[0] + accelerations[i][0] * deltaT * deltaT / 2,
          lastPos[1] + accelerations[i][1] * deltaT * deltaT / 2
        ]));
      } else {
        positions.add(positions[i - 1]);
      }

      final randomVariancePos = (Random().nextDouble() * posVar) - posVar / 2;
      positions[i][0] += randomVariancePos;
      positions[i][1] += randomVariancePos;
    }
  }
}
