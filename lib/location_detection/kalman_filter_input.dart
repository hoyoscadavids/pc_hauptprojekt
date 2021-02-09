import 'package:linalg/linalg.dart';

abstract class KalmanFilterSuper {
  /// General Matrices for the Kalman Filter.
  Matrix A;
  Matrix B;

  /// Discrete Matrices for each step.
  Matrix Ad;
  Matrix Bd;
  Matrix C;
  Matrix D;
  Matrix Gd;
  Matrix Q;
  Matrix QTerm;
  Matrix R;
  final fourIdentity = Matrix.eye(4);

  /// Kalman Filter approximation
  ///
  /// Prediction Vector
  Vector xPredict;

  /// Prediction covariance Matrix
  Matrix pPredict;

  /// Correction Vector
  Vector xCorrect;

  /// Correction covariance Matrix
  Matrix pCorrect;
  void filter(
    Vector y,
    double currentGpsAccuracy,
    double currentAccAccuracy,
    double deltaT, {
    Vector u,
  });
}

class KalmanFilterWithInput extends KalmanFilterSuper {
  // TODO(shc): Calculate real deltaT?
  KalmanFilterWithInput(
    double initialGpsAccuracy,
    Vector initialPos,
    Vector initialAcc,
  ) {
    // Initialize at position 0 with no velocity
    xCorrect = Vector.column([
      ...initialPos.toList(),
      0,
      0,
    ]);

    // Initialize with the 1 Covariance
    pCorrect = Matrix.eye(4);
  }

  /// Squares the given accuracy
  double _sigmaSquared(double accuracy) => accuracy * accuracy;

  /// Performs a step of the Kalman Filter. This should be called every
  /// time one gets new Data.
  /// For Sensor Fusion this is every 1/100s for the Accelerometer and every 1s for
  /// the GPS.
  @override
  void filter(
    Vector y,
    double currentGpsAccuracy,
    double currentAccAccuracy,
    double deltaT, {
    Vector u,
  }) {
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

    final qPosSigma = currentAccAccuracy * deltaT * deltaT / 2;
    final qVelSigma = currentAccAccuracy * deltaT;
    Q = Matrix([
      [_sigmaSquared(qPosSigma), 0, qPosSigma * qVelSigma, 0],
      [0, _sigmaSquared(qPosSigma), 0, qPosSigma * qVelSigma],
      [0, 0, _sigmaSquared(qVelSigma), 0],
      [0, 0, 0, _sigmaSquared(qVelSigma)],
    ]);
    QTerm = Gd * Q * Gd.transpose();
    R = Matrix([
      [_sigmaSquared(currentGpsAccuracy), 0],
      [0, _sigmaSquared(currentGpsAccuracy)],
    ]);

    // Predict
    xPredict = (Ad * xCorrect).toVector() + (Bd * u).toVector();
    pPredict = Ad * pCorrect * Ad.transpose() + QTerm;

    // Correct
    final S = C * pPredict * C.transpose() + R;
    final K = pPredict * C.transpose() * S.inverse();
    xCorrect = xPredict + (K * (y - ((C * xPredict) - (D * u)).toVector())).toVector();
    pCorrect = (fourIdentity - (K * C)) * pPredict;
  }
}
