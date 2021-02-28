
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