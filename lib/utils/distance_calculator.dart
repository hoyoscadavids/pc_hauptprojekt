import 'dart:math';

import 'package:linalg/vector.dart';
import 'package:pc_hauptprojekt/location_detection/lat_lng.dart';

class DistanceCalculator {
  /// Calculates the distance in x and y of two Coordinates in degrees
  static Vector calculate(LatLng start, LatLng end) {
    final x = 6371000 * pi / 180 * cos(end.latitude) * (end.longitude - start.longitude);
    final y = 111190 * (end.latitude - start.latitude);
    return Vector.column([x, y]);
  }
}
