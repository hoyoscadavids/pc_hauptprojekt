import 'package:linalg/linalg.dart';

class KalmanFilter {
  KalmanFilter(double deltaT, double initialGpsAccuracy) {
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
    _updateRMatrix(initialGpsAccuracy);
  }

  /// Noise Variance
  final accelerometerSigmaSquared = 0.05 * 0.05;

  // ignore: non_constant_identifier_names
  Matrix Ad;
  Matrix A;
  // ignore: non_constant_identifier_names
  Matrix Bd;
  Matrix B;
  Matrix C;
  Matrix D;
  // ignore: non_constant_identifier_names
  Matrix Gd;
  Matrix Q;
  Matrix R;

  void _updateRMatrix(double accuracy) {
    R = Matrix([
      [_gpsSigmaSquared(accuracy), 0],
      [0, _gpsSigmaSquared(accuracy)],
    ]);
  }

  double _gpsSigmaSquared(double accuracy) => accuracy * accuracy;
}
