import 'package:linalg/linalg.dart';

class KalmanFilter {
  // TODO(shc): Calculate real deltaT?
  KalmanFilter(
    double deltaT,
    double initialGpsAccuracy,
  ) {
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
  }

  /// Noise Variance
  final accelerometerSigmaSquared = 0.05 * 0.05;

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

  /// Updates the covariances Matrix for the accuracy of the GPS
  void _updateRMatrix(double accuracy) {
    R = Matrix([
      [_sigmaSquared(accuracy), 0],
      [0, _sigmaSquared(accuracy)],
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
    Vector u,
    double currentGpsAccuracy,
  ) {
    _updateRMatrix(currentGpsAccuracy);

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
