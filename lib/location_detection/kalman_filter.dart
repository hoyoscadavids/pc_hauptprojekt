import 'package:linalg/linalg.dart';

import 'kalman_filter_super.dart';

class KalmanFilter extends KalmanFilterSuper {
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

    Gd = Matrix([
      [deltaT, 0, secondIntegral, 0],
      [0, deltaT, 0, secondIntegral],
      [0, 0, firstIntegral, 0],
      [0, 0, 0, firstIntegral],
      [0, 0, deltaT, 0],
      [0, 0, 0, deltaT],
    ]);

    Q = Matrix([
      [_sigmaSquared(currentAccAccuracy), 0, 0, 0],
      [0, _sigmaSquared(currentAccAccuracy), 0, 0],
      [0, 0, _sigmaSquared(currentAccAccuracy), 0],
      [0, 0, 0, _sigmaSquared(currentAccAccuracy)],
    ]);

    R = Matrix([
      [_sigmaSquared(currentGpsAccuracy), 0, 0, 0],
      [0, _sigmaSquared(currentGpsAccuracy), 0, 0],
      [0, 0, _sigmaSquared(currentGpsAccuracy), 0],
      [0, 0, 0, _sigmaSquared(currentGpsAccuracy)]
    ]);

    QTerm = Gd * Q * Gd.transpose();
    // Predict
    xPredict = (Ad * xCorrect).toVector();
    pPredict = Ad * pCorrect * Ad.transpose() + QTerm;

    // Correct
    final S = C * pPredict * C.transpose() + R;
    final K = pPredict * C.transpose() * S.inverse();
    xCorrect = xPredict + (K * (y - ((C * xPredict)).toVector())).toVector();
    pCorrect = (Matrix.eye(6) - (K * C)) * pPredict;
  }
}
