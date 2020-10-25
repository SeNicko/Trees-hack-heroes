import 'dart:async';

import 'package:flutter/services.dart';

StepCountProvider stepCountProvider = StepCountProvider();

class StepCountProvider {
  static const platform = const MethodChannel("android.app.trees/pedometer");

  // Streams
  StreamController<int> _streamController = StreamController<int>.broadcast();
  Stream<int> _stream;

  // Static fields
  bool _pedometerError = false;
  int _todaySteps;
  int _todayTrees;
  int _totalSteps;
  int _totalTrees;
  int _dailyGoal;

  // Getters
  bool get isPedometerError => _pedometerError;
  int get todaySteps => _todaySteps;
  int get todayTrees => _todayTrees;
  int get dailyGoal => _dailyGoal;
  int get totalSteps => _totalSteps;
  int get totalTrees => _totalTrees;
  Stream<int> get stream => _stream;

  StepCountProvider() {
    _stream = _streamController.stream;

    new Timer.periodic(const Duration(milliseconds: 100), (_) {
      // TODO: Jak będzie czas to zmienić to na eventchannels czy coś takiego
      _isPedometerError();
      _changeDateIfNeeded();
      _getTodaySteps();

      _getTodayTrees();
      _getTotalTrees();

      _getTotalSteps();
      _getDailyGoal();
    });
  }

  Future<void> _changeDateIfNeeded() async {
    try {
      await platform.invokeMethod("changeDateIfNeeded");
    } on PlatformException catch (_) {}
  }

  Future<void> _isPedometerError() async {
    try {
      _pedometerError = await platform.invokeMethod("isPedometerError");
    } on PlatformException catch (_) {}
  }

  Future<void> _getTodaySteps() async {
    try {
      _todaySteps = await platform.invokeMethod("getTodaySteps");
      if (_todaySteps == -1) _todaySteps = null;
    } on PlatformException catch (_) {
      stepCountProvider.startService();
    }

    _streamController.add(_todaySteps);
  }

  Future<void> _getTodayTrees() async {
    try {
      _todayTrees = await platform.invokeMethod("getTodayTrees");
    } on PlatformException catch (_) {}
  }

  Future<void> _getTotalSteps() async {
    try {
      _totalSteps = await platform.invokeMethod("getTotalSteps");
      if (_totalSteps == -1) _totalSteps = null;
    } on PlatformException catch (_) {}
  }

  Future<void> _getTotalTrees() async {
    try {
      _totalTrees = await platform.invokeMethod("getTotalTrees");
    } on PlatformException catch (_) {}
  }

  Future<void> _getDailyGoal() async {
    try {
      _dailyGoal = await platform.invokeMethod("getDailyGoal");
    } on PlatformException catch (_) {}
  }

  Future<void> save() async {
    try {
      await platform.invokeMethod("save");
    } on PlatformException catch (_) {}
  }

  Future<void> startService() async {
    try {
      await platform.invokeMethod("startService");
    } on PlatformException catch (_) {}
  }
}
