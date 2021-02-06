import 'dart:async';

import 'package:flutter/material.dart';
import 'package:linalg/linalg.dart';
import 'package:pc_hauptprojekt/location_detection/IMU.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter.dart';
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
        primarySwatch: Colors.blue,
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

  KalmanFilter kalmanFilter;

  /// Reference Vector for the Position in LatLng
  LatLng positionReference;
  Vector currentGpsPosition;
  Vector currentAcceleration;
  double currentGpsAccuracy;

  int timeOffset = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: _onStart,
          child: Text("Start"),
        ),
      ),
    );
  }

  void _onStart() async {
    // Read Initial position
    final initialPosition = await gps.determinePosition();

    // Set reference values
    imu.setReferenceSystem();
    positionReference = LatLng(
      initialPosition.latitude,
      initialPosition.longitude,
    );

    // Initialize Kalman Filter
    kalmanFilter = KalmanFilter(
      1 / 100,
      initialPosition.accuracy,
    );

    // Perform Reading and filtering every 1/100 seconds.
    Timer.periodic(Duration(milliseconds: 10), (timer) async {
      currentAcceleration = imu.getAcceleration();

      // Check the GPS every 1s
      if (timeOffset >= 100) {
        // If new dta from GPS, use it.
        final calculatedPosition = await gps.determinePosition();
        currentGpsPosition = DistanceCalculator.calculate(
          positionReference,
          LatLng(calculatedPosition.latitude, calculatedPosition.longitude),
        );
        timeOffset = 0;
      } else {
        // If not new Data from GPS, use the predicted location.
        currentGpsPosition = Vector.column([
          kalmanFilter.xCorrect[0],
          kalmanFilter.xCorrect[1],
        ]);
        timeOffset++;
      }

      kalmanFilter.filter(
        currentGpsPosition,
        currentAcceleration,
        currentGpsAccuracy,
      );
    });
  }
}
