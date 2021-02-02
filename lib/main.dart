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
    Future.delayed(Duration(milliseconds: 100), () {
      imu.initializeImu();
      Timer.periodic(Duration(seconds: 1), (timer) async {
        await gps.determinePosition();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    imu.globalAcceleration.addListener(() {
      text = "East " +
          imu.globalAcceleration.value[0].toInt().toString() +
          "\n\n" +
          "North " +
          imu.globalAcceleration.value[1].toInt().toString() +
          "\n\n" +
          "Down " +
          imu.globalAcceleration.value[2].toInt().toString();
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
