import 'dart:math';

import 'package:linalg/linalg.dart';
import 'package:normal/normal.dart';

class Simulator {
  final realPositions = <Vector>[];
  final positions = <Vector>[];
  final accelerations = <Vector>[];
  final realAccelerations = <Vector>[];
  final realVelocities = <Vector>[];
  void simulate(double accVar, double posVar, int samples, double deltaT) {
    positions.clear();
    realPositions.clear();
    realAccelerations.clear();
    realVelocities.clear();

    for (var i = 0; i < samples; i++) {
      var lastVel = Vector.column([0, 0]);

      accelerations.add(Vector.column([0.05, 0.05]));
      realAccelerations.add(Vector.column([0.05, 0.05]));
      if (i != 0) {
        lastVel = Vector.column([realVelocities[i - 1][0], realVelocities[i - 1][1]]);
      }
      realVelocities.add(Vector.column([
        lastVel[0] + accelerations[i][0] * deltaT,
        lastVel[1] + accelerations[i][1] * deltaT,
      ]));
    }

    for (var i = 0; i < samples; i++) {
      var lastPos = Vector.column([0, 0]);
      if (i != 0) {
        lastPos = Vector.column([realPositions[i - 1][0], realPositions[i - 1][1]]);
      }
      realPositions.add(Vector.column([
        lastPos[0] + realVelocities[i][0] * deltaT,
        lastPos[1] + realVelocities[i][1] * deltaT,
      ]));
      if (i % 100 == 0) {
        positions.add(Vector.column([
          lastPos[0] + realVelocities[i][0] * deltaT,
          lastPos[1] + realVelocities[i][1] * deltaT,
        ]));
      } else {
        positions.add(positions[i - 1]);
      }
    }

    final randomVarianceAcc = Normal.generate(
      samples,
      mean: 0,
      variance: accVar,
    );
    final randomVariancePos = Normal.generate(
      samples,
      mean: 0,
      variance: posVar,
    );
    // Add noise
    for (var i = 0; i < samples; i++) {
      accelerations[i][0] += randomVarianceAcc[i];
      accelerations[i][1] += randomVarianceAcc[i];

      positions[i][0] += randomVariancePos[i];
      positions[i][1] += randomVariancePos[i];
    }
  }
}
