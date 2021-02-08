import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linalg/linalg.dart';
import 'package:pc_hauptprojekt/location_detection/IMU.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter_input.dart';
import 'package:pc_hauptprojekt/location_detection/lat_lng.dart';
import 'package:pc_hauptprojekt/utils/distance_calculator.dart';

import 'location_detection/gps.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final imu = IMU();
  final gps = Gps();
  final positions = <Vector>[];
  KalmanFilter kalmanFilter;

  double newT;
  double oldT;

  /// Reference Vector for the Position in LatLng
  LatLng positionReference;
  Vector currentGpsPosition;
  Vector currentAcceleration;
  double currentGpsAccuracy;

  int timeOffset = 0;

  String text = "Start";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: positions.isEmpty
            ? RaisedButton(
                onPressed: _onStart,
                child: Text(text),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: PositionPainter(positions),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(text),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  void _onStart() async {
    oldT = DateTime.now().millisecondsSinceEpoch.toDouble();
    newT = oldT;
    // Read Initial position
    final initialPosition = await gps.determinePosition();
    currentGpsAccuracy = initialPosition.accuracy;
    // Set reference values
    imu.setReferenceSystem();
    positionReference = LatLng(
      initialPosition.latitude,
      initialPosition.longitude,
    );

    // Initialize Kalman Filter
    kalmanFilter = KalmanFilter(
      initialPosition.accuracy,
    );

    // Perform Reading and filtering every 1/100 seconds.
    Timer.periodic(Duration(milliseconds: 10), (timer) async {
      oldT = newT;
      newT = DateTime.now().millisecondsSinceEpoch.toDouble();
      final deltaT = newT - oldT;
      currentAcceleration = imu.getAcceleration();

      // Check the GPS every 1s
      if (timeOffset >= 100) {
        // If new dta from GPS, use it.
        final calculatedPosition = await gps.determinePosition();
        currentGpsAccuracy = calculatedPosition.accuracy;
        currentGpsPosition = DistanceCalculator.calculate(
          positionReference,
          LatLng(calculatedPosition.latitude, calculatedPosition.longitude),
        );
        timeOffset = 0;
      } else {
        timeOffset++;
      }
      kalmanFilter.filter(
        Vector.column([
          0, 0,
          // ...currentGpsPosition.toList(),
          ...currentAcceleration.toList(),
        ]),
        currentGpsAccuracy,
        deltaT / 1000,
      );
    });

    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        //positions.clear();
        positions.add(kalmanFilter.xCorrect);
        text = "GPS Accuracy: $currentGpsAccuracy\n"
            "Estimated P/V/A ${kalmanFilter.xCorrect}\n"
            "Unfiltered Acceleration: $currentAcceleration\n";
      });
    });
  }
}

class PositionPainter extends CustomPainter {
  PositionPainter(this.positions);
  final List<Vector> positions;
  static const modifier = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final points = positions
        .map((position) => Offset(
              position[0] * modifier,
              -position[1] * modifier,
            ))
        .toList();

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
