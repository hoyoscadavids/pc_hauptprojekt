import 'dart:math';

import 'package:linalg/linalg.dart';

class Simulator {
  final realPositions = <Vector>[];
  final positions = <Vector>[];
  final accelerations = <Vector>[];
  void simulate(double accVar, double posVar, int samples) {
    positions.clear();
    accelerations.clear();

    for (var i = 0; i < samples; i++) {
      accelerations.add(Vector.column([i / 10, i / 10]));
    }
    for (var i = 0; i < samples; i++) {

      realPositions.add(Vector.column(
          [accelerations[i][0] * accelerations[i][0] / 2, accelerations[i][1] * accelerations[i][1] / 2]));
    }

    for (var i = 0; i < samples; i++) {
      final randomVarianceAcc = (Random().nextDouble() * accVar) - accVar / 2;
      accelerations[i][1] += randomVarianceAcc;

      positions.add(Vector.column(
          [accelerations[i][0] * accelerations[i][0] / 2, accelerations[i][1] * accelerations[i][1] / 2]));
      final randomVariancePos = (Random().nextDouble() * posVar) - posVar / 2;
      positions[i][1] += randomVariancePos;
    }
  }
}
