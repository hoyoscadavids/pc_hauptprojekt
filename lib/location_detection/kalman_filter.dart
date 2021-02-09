﻿import 'package:linalg/linalg.dart';

import 'kalman_filter_input.dart';

class KalmanFilter extends KalmanFilterSuper {
  // TODO(shc): Calculate real deltaT?
  KalmanFilter(
    double initialGpsAccuracy,
    Vector initialPos,
    Vector initialAcc,
  ) {
    // Initialize at position 0 with no velocity
    xCorrect = Vector.column([
      ...initialPos.toList(),
      0,
      0,
      ...initialAcc.toList(),
    ]);

    // Initialize with the 1 Covariance
    pCorrect = Matrix.eye(6);
  }

  /// Updates the covariances Matrix for the accuracy of the GPS
  void _updateNoiseMatrix(double gpsAccuracy, double accAccuracy) {
    R = Matrix([
      [_sigmaSquared(gpsAccuracy), 0, 0, 0],
      [0, _sigmaSquared(gpsAccuracy), 0, 0],
      [0, 0, _sigmaSquared(accAccuracy), 0],
      [0, 0, 0, _sigmaSquared(accAccuracy)],
    ]);
  }

  /// Squares the given accuracy
  double _sigmaSquared(double accuracy) => accuracy * accuracy;

  /// Performs a step of the Kalman Filter. This should be called every
  /// time one gets new Data.
  /// For Sensor Fusion this is every 1/100s for the Accelerometer and every 1s for
  /// the GPS.
  void filter(
    Vector y,
    double currentGpsAccuracy,
    double currentAccAccuracy,
    double deltaT, {
    Vector u,
  }) {
    final firstIntegral = deltaT * deltaT / 2;
    final secondIntegral = deltaT * deltaT * deltaT / 6;
    Ad = Matrix([
      [1, 0, deltaT, 0, firstIntegral, 0],
      [0, 1, 0, deltaT, 0, firstIntegral],
      [0, 0, 1, 0, deltaT, 0],
      [0, 0, 0, 1, 0, deltaT],
      [0, 0, 0, 0, 1, 0],
      [0, 0, 0, 0, 0, 1],
    ]);
    C = Matrix([
      [1, 0, 0, 0, 0, 0],
      [0, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 1, 0],
      [0, 0, 0, 0, 0, 1]
    ]);
    _updateNoiseMatrix(currentGpsAccuracy, currentAccAccuracy);
    R = Matrix.eye(4);

    // Predict
    xPredict = (Ad * xCorrect).toVector();
    pPredict = Ad * pCorrect * Ad.transpose();

    // Correct
    final S = C * pPredict * C.transpose() + R;
    final K = pPredict * C.transpose() * S.inverse();
    xCorrect = xPredict + (K * (y - ((C * xPredict)).toVector())).toVector();
    pCorrect = (Matrix.eye(6) - (K * C)) * pPredict;
  }
}

/* With Acceleration as input vector
A = Matrix([
      [0, 0, 1, 0],
      [0, 0, 0, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
    Ad = Matrix([
      [1, 0, deltaT, 0],
      [0, 1, 0, deltaT],
      [0, 0, 1, 0],
      [0, 0, 0, 1],
    ]);
    B = Matrix([
      [0, 0],
      [0, 0],
      [1, 0],
      [0, 1]
    ]);
    Bd = Matrix([
      [deltaT * deltaT / 2, 0],
      [0, deltaT * deltaT / 2],
      [deltaT, 0],
      [0, deltaT]
    ]);
    C = Matrix([
      [1, 0, 0, 0],
      [0, 1, 0, 0]
    ]);
    D = Matrix([
      [deltaT * deltaT / 2, 0],
      [0, deltaT * deltaT / 2]
    ]);
    Gd = Matrix([
      [deltaT * deltaT / 2, 0],
      [0, deltaT * deltaT / 2],
      [deltaT, 0],
      [0, deltaT]
    ]);
    Q = Matrix([
      [accelerometerSigmaSquared, 0],
      [0, accelerometerSigmaSquared]
    ]);
    QTerm = Gd * Q * Gd.transpose();
    _updateRMatrix(initialGpsAccuracy);

    // Initialize at position 0 with no velocity
    xCorrect = Vector.fillColumn(4);

    // Initialize with the 0 Covariance
    pCorrect = Matrix([
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
    ]);
 */
