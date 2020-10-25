import 'package:app/utils/step_count_provider.dart';
import 'package:flutter/material.dart';

import "../widgets/tree_widget.dart";

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int _steps;
  static int _dailyGoal;

  @override
  void initState() {
    super.initState();

    stepCountProvider.stream.listen((steps) {
      if (!mounted) return;

      setState(() {
        _steps = steps;
        _dailyGoal = stepCountProvider.dailyGoal;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Text goalText = Text(
        _dailyGoal == null
            ? "ładowanie"
            : "Dzisiejszy cel to $_dailyGoal kroków!",
        style: TextStyle(fontSize: constraints.maxWidth > 380 ? 20 : 16),
      );

      Text stepText = Text(
        _steps == null ? "ładowanie" : _steps.toString(),
        style: TextStyle(fontSize: constraints.maxWidth > 380 ? 72 : 60),
      );

      return Center(
        child: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Column(
                    children: [goalText, stepText],
                  ),
                ),
                Tree(),
              ]),
        ),
      );
    });
  }
}
