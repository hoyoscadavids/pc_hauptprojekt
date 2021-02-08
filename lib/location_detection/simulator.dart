import 'dart:math';

import 'package:linalg/linalg.dart';

class Simulator {
  // Simulates moving Position 1m per call
  static List<Vector> simulatePositions(double variance, int samples) {
    final simulatedPositions = <Vector>[];
    for (var i = 0; i < samples; i++) {
      final randomVariance = -variance + (Random().nextDouble() * (variance + 1));
      simulatedPositions.add(
        Vector.column(
          [
            variance + (i + randomVariance),
            variance + (i + randomVariance),
          ],
        ),
      );
    }
    return simulatedPositions;
  }

  // Simulates moving acceleration 0.01m/s2 per call
  static List<Vector> simulateAcceleration(double variance, int samples) {
    final simulatedPositions = <Vector>[];
    for (var i = 0; i < samples; i++) {
      final randomVariance = -variance + (Random().nextDouble() * (variance + 1));
      simulatedPositions.add(
        Vector.column(
          [
            0 + randomVariance,
            0 + randomVariance,
          ],
        ),
      );
    }
    return simulatedPositions;
  }
}
