import 'package:app/utils/step_count_provider.dart';
import "package:flutter/material.dart";
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/step_count_provider.dart';

class Tree extends StatefulWidget {
  _TreeState createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  static int _dailyGoal;
  static int _steps;
  static int _totalTrees = 0;

  static const List<String> _assetNames = <String>[
    "assets/images/tree/stage_1.svg",
    "assets/images/tree/stage_2.svg",
    "assets/images/tree/stage_3.svg",
    "assets/images/tree/stage_4.svg",
    "assets/images/tree/stage_5.svg",
    "assets/images/tree/stage_6.svg",
  ];

  Widget getTree() {
    int stage = 0;
    double size = 0;

    if (_steps != null && _dailyGoal != null) {
      stage = ((_steps / _dailyGoal) * (_assetNames.length))
              .floor()
              .clamp(0, _assetNames.length - 1) %
          _assetNames.length;
      size = ((80 + (20 * stage)) + ((200 - 80) / _dailyGoal) * _steps)
          .clamp(0, 261.0);
    } else {
      size = 80;
    }

    return SvgPicture.asset(
      _assetNames[stage],
      height: size,
    );
  }

  @override
  void initState() {
    super.initState();

    stepCountProvider.stream.listen((steps) {
      if (!mounted) return;

      setState(() {
        _dailyGoal = stepCountProvider.dailyGoal == 0
            ? 1
            : stepCountProvider.dailyGoal; // Prevent dividing by 0
        _steps = _dailyGoal != null ? steps % _dailyGoal : 1;
        _totalTrees = stepCountProvider.totalTrees;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int growthPercent = _steps == null || _dailyGoal == null
        ? 0
        : ((100 * _steps) / _dailyGoal).round();

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(alignment: Alignment.bottomCenter, children: [
            SvgPicture.asset(
              "assets/images/tree/ground.svg",
              width: constraints.maxWidth - 120,
            ),
            Padding(
                padding: EdgeInsets.only(bottom: constraints.maxWidth * 0.05),
                child: getTree())
          ]),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                _steps == null
                    ? (stepCountProvider.isPedometerError == true
                        ? "błąd pedometru"
                        : "ładowanie danych")
                    : "$growthPercent%",
                style:
                    TextStyle(fontSize: constraints.maxWidth > 380 ? 20 : 16),
                textAlign: TextAlign.center,
              ))
        ],
      );
    });
  }
}
