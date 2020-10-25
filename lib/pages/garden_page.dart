import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import "../utils/step_count_provider.dart";

class GardenPage extends StatefulWidget {
  @override
  _GardenPageState createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  static int _totalTrees = stepCountProvider.totalTrees;

  @override
  void initState() {
    super.initState();

    stepCountProvider.stream.listen((_) {
      if (!mounted) return;

      if (stepCountProvider.totalTrees != _totalTrees) {
        setState(() {
          _totalTrees = stepCountProvider.totalTrees;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> trees = [];

    Random random = new Random();

    for (int i = 0; i < _totalTrees; i++) {
      trees.add(Padding(
        padding: EdgeInsets.only(
            left: random
                .nextInt(MediaQuery.of(context).size.width.toInt() - 40 - 150)
                .toDouble()),
        child: SvgPicture.asset(
          "assets/images/tree/stage_6.svg",
          height: 150,
        ),
      ));
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  margin: EdgeInsets.only(right: 5),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: SvgPicture.asset(
                            "assets/images/tree/stage_1.svg",
                            height: 50.0),
                      ),
                      Text(
                        _totalTrees == null
                            ? "ładowanie"
                            : _totalTrees.toString(),
                        style: TextStyle(
                            fontSize: 64, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              Expanded(
                flex: 30,
                child: Container(
                    child: _totalTrees > 0
                        ? Stack(
                            alignment: Alignment.bottomLeft,
                            children: trees,
                          )
                        : Center(
                            child: Text(
                              "Nie masz żadnych drzew!",
                              style: Theme.of(context).textTheme.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                          )),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(color: Color(0xFF413022)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
