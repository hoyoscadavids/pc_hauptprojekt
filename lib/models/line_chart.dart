/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:linalg/vector.dart';
import 'package:pc_hauptprojekt/location_detection/kalman_filter.dart';
import 'package:pc_hauptprojekt/location_detection/simulator.dart';

class SimpleLineChart extends StatelessWidget {
  SimpleLineChart(this.seriesList, {this.animate});
  final List<charts.Series<Coordinates, double>> seriesList;
  final bool animate;

  static Simulator simulator;
  static final errorList = <Coordinates>[];

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withSampleData() {
    return new SimpleLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  /// Creates a [LineChart] with sample data and no transition.
  factory SimpleLineChart.withErrorData() {
    return new SimpleLineChart(
      _createSampleDataError(),
      // Disable animations for image tests.
      animate: false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(seriesList, animate: animate, );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<Coordinates, double>> _createSampleData() {
    // Simulation Data
    final posVar = 20.0;
    final accVar = 0.05;
    final deltaT = 1.0;
    simulator = Simulator();
    simulator.simulate(accVar, posVar, 1000, deltaT);

    final simulatedKalman = KalmanFilter(
      posVar,
      Vector.column([0, 0]),
      Vector.column([0, 0]),
    );
    /*final simulatedKalman = KalmanFilterWithInput(
      posVar,
      Vector.column([0, 0]),
      Vector.column([0, 0]),
    );*/

    final filteredPositions = <Vector>[];
    for (var i = 0; i < simulator.positions.length; i++) {
      simulatedKalman.filter(
        Vector.column(
          [
            ...simulator.positions[i].toList(),
            ...simulator.accelerations[i].toList(),
          ],
        ),
        posVar,
        accVar,
        deltaT,
      );
      filteredPositions.add(simulatedKalman.xCorrect);
    }
    final list = List.generate(simulator.positions.length, (index) => index.toDouble());
    final realData = simulator.realPositions.map((e) => Coordinates(e[0], e[1])).toList();
    final noisyData = simulator.positions.map((e) => Coordinates(e[0], e[1])).toList();
    final filteredData = filteredPositions.map((e) => Coordinates(e[0], e[1])).toList();

    errorList.clear();
    for (var i = 0; i < filteredData.length; i++) {
      errorList.add(Coordinates(filteredData[i].x - realData[i].x, filteredData[i].y - realData[i].y));
    }

    return [
      charts.Series<Coordinates, double>(
        id: 'Noisy Positions',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Coordinates sales, _) => list[_],
        measureFn: (Coordinates sales, _) => sales.y,
        data: noisyData,
      ),
      charts.Series<Coordinates, double>(
        id: 'Real Positions',
        colorFn: (_, __) => charts.MaterialPalette.black,
        domainFn: (Coordinates sales, _) => list[_],
        measureFn: (Coordinates sales, _) => sales.y,
        data: realData,
      ),
      charts.Series<Coordinates, double>(
        id: 'Filtered Positions',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (Coordinates sales, _) => list[_],
        measureFn: (Coordinates sales, _) => sales.y,
        data: filteredData,
      ),
    ];
  }

  static List<charts.Series<Coordinates, double>> _createSampleDataError() {
    final list = List.generate(errorList.length, (index) => index.toDouble());

    return [
      charts.Series<Coordinates, double>(
        id: 'Error',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (Coordinates sales, _) => list[_],
        measureFn: (Coordinates sales, _) => sales.y,
        data: errorList,
      ),
    ];
  }
}

/// Sample linear data type.
class Coordinates {
  final double x;
  final double y;

  Coordinates(this.x, this.y);
}
