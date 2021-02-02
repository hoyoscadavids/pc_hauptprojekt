import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:linalg/linalg.dart';
import 'package:motion_sensors/motion_sensors.dart';
import 'package:sensors/sensors.dart';

class IMU {
  final globalAcceleration = ValueNotifier(Vector.fillColumn(3));

  Vector _localAcceleration = Vector.fillColumn(3);
  Vector _initialAcceleration = Vector.fillColumn(3);
  Vector _magnetometerEvent = Vector.fillColumn(3);
  Vector _gyroEvent = Vector.fillColumn(3);

  Vector _down = Vector.fillColumn(3);
  Vector _east = Vector.fillColumn(3);
  Vector _north = Vector.fillColumn(3);
  Vector _orientation = Vector.fillColumn(3);

  IMU() {
    accelerometerEvents.listen((acceleration) {
      _initialAcceleration = Vector.column([
        acceleration.x,
        acceleration.y,
        acceleration.z,
      ]);
    });

    userAccelerometerEvents.listen((acceleration) {
      _localAcceleration = Vector.column([
        acceleration.x,
        acceleration.y,
        acceleration.z,
      ]);
    });

    gyroscopeEvents.listen((gEvent) {
      _gyroEvent = Vector.column([
        gEvent.x,
        gEvent.y,
        gEvent.z,
      ]);
    });

    motionSensors.magnetometer.listen((magEvent) {
      _magnetometerEvent = Vector.column([
        magEvent.x,
        magEvent.y,
        magEvent.z,
      ]);
    });
  }

  void initializeImu() {
    setReferenceSystem();
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      _orientation += calculateOrientationChange(1 / 100);
      final rotatedAcceleration = rotateBackToOriginalSystem(_localAcceleration);
      calculateGlobalAcceleration(rotatedAcceleration);
    });
  }

  void calculateGlobalAcceleration(Vector rotatedAcceleration) {
    // Calculate X value in East coordinate
    final x = Vector.column([
      rotatedAcceleration[0] * _east[0],
      rotatedAcceleration[0] * _east[1],
      rotatedAcceleration[0] * _east[2],
    ]);

    // Calculate Y value in North coordinate
    final y = Vector.column([
      rotatedAcceleration[1] * _north[0],
      rotatedAcceleration[1] * _north[1],
      rotatedAcceleration[1] * _north[2],
    ]);

    // Calculate Z value in Down coordinate
    final z = Vector.column([
      rotatedAcceleration[2] * _down[0],
      rotatedAcceleration[2] * _down[1],
      rotatedAcceleration[2] * _down[2],
    ]);
    globalAcceleration.value = x + y + z;
  }

  Vector rotateBackToOriginalSystem(Vector acceleration) {
    Vector tempAcceleration = acceleration;
    // For x rotation
    final xRotationMatrix = Matrix([
      [1.0, 0.0, 0.0],
      [0.0, cos(_orientation[0]), -sin(_orientation[0])],
      [0.0, sin(_orientation[0]), cos(_orientation[0])]
    ]);

    tempAcceleration = (xRotationMatrix * acceleration).toVector();
    // For y rotation
    final yRotationMatrix = Matrix([
      [cos(_orientation[1]), 0.0, sin(_orientation[1])],
      [0.0, 1.0, 0.0],
      [-sin(_orientation[1]), 0.0, cos(_orientation[1])]
    ]);

    tempAcceleration = (yRotationMatrix * tempAcceleration).toVector();
    // For z rotation
    final zRotationMatrix = Matrix([
      [cos(_orientation[2]), -sin(_orientation[2]), 0.0],
      [sin(_orientation[2]), cos(_orientation[2]), 0.0],
      [0.0, 0.0, 1.0]
    ]);

    tempAcceleration = (zRotationMatrix * tempAcceleration).toVector();

    return tempAcceleration;
  }

  Vector calculateOrientationChange(double deltaTime) {
    return Vector.column([
      _gyroEvent[0] * deltaTime,
      _gyroEvent[1] * deltaTime,
      _gyroEvent[2] * deltaTime,
    ]);
  }

  void setReferenceSystem() {
    _down = ~_initialAcceleration.normalize();
    _east = _down.crossProduct(_magnetometerEvent).normalize();
    _north = _east.crossProduct(_down).normalize();

    print("Saved reference system as: ${_north.toString()}   "
        "${_east.toString()}    ${_down.toString()}");
  }
}
