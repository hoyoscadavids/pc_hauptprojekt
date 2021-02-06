import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pc_hauptprojekt/location_detection/IMU.dart';
import 'package:sensors/sensors.dart';

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
  String text = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      imu.initializeImu();
      Timer.periodic(Duration(seconds: 1), (timer) async {
        final position = await gps.determinePosition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    imu.globalAcceleration.addListener(() {
      text = "East " +
          imu.globalAcceleration.value[0].toString() +
          "\n\n" +
          "North " +
          imu.globalAcceleration.value[1].toString();
      setState(() {});
    });

    return Scaffold(
      body: Center(
        child: RaisedButton(
          onPressed: () {},
          child: Text(text),
        ),
      ),
    );
  }
}
