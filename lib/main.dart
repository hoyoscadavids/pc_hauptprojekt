import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:linalg/linalg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pc_hauptprojekt/location_detection/IMU.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter_super.dart';
import 'package:pc_hauptprojekt/location_detection/lat_lng.dart';
import 'package:pc_hauptprojekt/models/line_chart.dart';
import 'package:pc_hauptprojekt/models/positions.dart';
import 'package:pc_hauptprojekt/utils/distance_calculator.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final imu = IMU();
  final gps = Gps();
  final filteredPositions = <Vector>[];
  final realPositions = <Vector>[];
  final jsonPositions = <Vector>[];

  final gpsPositionsChart = <Coordinates>[];
  final filteredPositionsChart = <Coordinates>[];
  final deltaTimes = <double>[];

  KalmanFilterSuper kalmanFilter;

  double newT;
  double oldT;

  /// Reference Vector for the Position in LatLng
  LatLng positionReference;
  Vector currentGpsPosition;
  Vector currentAcceleration;
  double currentGpsAccuracy;

  int timeOffset = 0;

  String text = "Start";
  bool started = false;

  Timer loopTimer;
  final shouldSimulate = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: shouldSimulate
            ? PageView(
                children: [
                  SimpleLineChart.withSampleData(),
                  SimpleLineChart.withErrorData(),
                ],
              )
            : !started
                ? PageView(
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 50,
                          child: RaisedButton(
                            color: Colors.purple,
                            onPressed: _onStart,
                            child: Text(
                              'Start',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Stack(
                        children: [
                          SimpleLineChart(
                            [
                              charts.Series<Coordinates, double>(
                                id: 'GPS Positions',
                                colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                                domainFn: (Coordinates sales, _) => deltaTimes[_],
                                measureFn: (Coordinates sales, _) => sales.x,
                                data: gpsPositionsChart,
                              ),
                              charts.Series<Coordinates, double>(
                                id: 'Filtered Positions',
                                colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
                                domainFn: (Coordinates sales, _) => deltaTimes[_],
                                measureFn: (Coordinates sales, _) => sales.x,
                                data: filteredPositionsChart,
                              ),
                            ],
                          ),
                          Positioned(
                            left: 50,
                            top: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.purple,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "X Position (m)  vs Time (s)",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          SimpleLineChart(
                            [
                              charts.Series<Coordinates, double>(
                                id: 'GPS Positions',
                                colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
                                domainFn: (Coordinates sales, _) => deltaTimes[_],
                                measureFn: (Coordinates sales, _) => sales.y,
                                data: gpsPositionsChart,
                              ),
                              charts.Series<Coordinates, double>(
                                id: 'Filtered Positions',
                                colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
                                domainFn: (Coordinates sales, _) => deltaTimes[_],
                                measureFn: (Coordinates sales, _) => sales.y,
                                data: filteredPositionsChart,
                              ),
                            ],
                          ),
                          Positioned(
                            left: 50,
                            top: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.purple,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Y Position (m)  vs Time (s)",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Stack(
                    alignment: Alignment.center,
                    fit: StackFit.expand,
                    children: [
                      Container(
                        child: GridPaper(
                          color: Colors.black.withOpacity(0.1),
                          interval: 100,
                          divisions: 1,
                        ),
                      ),
                      Center(
                        child: CustomPaint(
                          painter: PositionPainter(
                            filteredPositions,
                            realPositions,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 48),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(text),
                              RaisedButton(
                                onPressed: () async {
                                  final jsonPositions = <Pos>[];
                                  filteredPositions.forEach((element) {
                                    jsonPositions.add(Pos(element[0], element[1]));
                                  });
                                  filteredPositions.clear();
                                  realPositions.clear();
                                  final jsonData = Positions(jsonPositions);
                                  final directory = await getApplicationDocumentsDirectory();
                                  final file = File("${directory.path}/positions.json");

                                  file.writeAsString(jsonEncode(jsonData.toJson()));
                                  setState(() {
                                    loopTimer.cancel();
                                    loopTimer = null;
                                    started = false;
                                  });
                                },
                                child: Text('Stop'),
                              )
                            ],
                          ),
                        ),
                      ),
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
    currentGpsPosition = Vector.fillColumn(2);

    // Set reference values
    imu.setReferenceSystem();
    positionReference = LatLng(
      initialPosition.latitude,
      initialPosition.longitude,
    );

    // Initialize Kalman Filter
    /* kalmanFilter = KalmanFilter(
      initialPosition.accuracy,
      Vector.fillColumn(2),
      Vector.fillColumn(2),
    );*/
    kalmanFilter = KalmanFilter(
      initialPosition.accuracy,
      Vector.fillColumn(2),
      Vector.fillColumn(2),
    );
    setState(() {
      started = true;
    });
    // Perform Reading and filtering every 1/100 seconds.
    loopTimer = Timer.periodic(Duration(milliseconds: 10), (timer) async {
      oldT = newT;
      newT = DateTime.now().millisecondsSinceEpoch.toDouble();
      final deltaT = newT - oldT;
      currentAcceleration = imu.getAcceleration();
      if (deltaTimes.isEmpty)
        deltaTimes.add(deltaT / 1000);
      else {
        deltaTimes.add(deltaT / 1000 + deltaTimes[deltaTimes.length - 1]);
      }
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
        realPositions.add(currentGpsPosition);
      } else {
        timeOffset++;
      }

      gpsPositionsChart.add(Coordinates(
        currentGpsPosition[0],
        currentGpsPosition[1],
      ));

      kalmanFilter.filter(
        Vector.column([
          ...currentGpsPosition.toList(),
          ...currentAcceleration.toList(),
        ]),
        currentGpsAccuracy,
        0.05,
        deltaT / 1000,
      );

      filteredPositionsChart.add(Coordinates(
        kalmanFilter.xCorrect[0],
        kalmanFilter.xCorrect[1],
      ));

      if (timeOffset >= 50) {
        jsonPositions.add(kalmanFilter.xCorrect);
      }
      /* kalmanFilter.filter(
        Vector.column([
          ...currentGpsPosition.toList(),
        ]),
        currentGpsAccuracy,
        0.01,
        deltaT / 1000,
        u: currentAcceleration,
      );*/
      setState(() {
        //positions.clear();
        filteredPositions.add(kalmanFilter.xCorrect);
        text = "GPS Accuracy: $currentGpsAccuracy\n"
            "Estimated P \n${kalmanFilter.xCorrect[0]}\n${kalmanFilter.xCorrect[1]}\n\n"
            "Unfiltered Position: $currentGpsPosition\n";
      });
    });
  }
}

class PositionPainter extends CustomPainter {
  PositionPainter(this.positions, this.realPositions);
  final List<Vector> positions;
  final List<Vector> realPositions;
  static const modifier = 1;

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
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, points, paint);

    final realPoints = realPositions
        .map((position) => Offset(
              position[0] * modifier,
              -position[1] * modifier,
            ))
        .toList();

    final realPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(PointMode.points, realPoints, realPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
