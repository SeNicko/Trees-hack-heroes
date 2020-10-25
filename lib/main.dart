import "package:flutter/material.dart";

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import "package:app/views/app_view.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Permission.activityRecognition.request().then((_) async {
    runApp(App());
  });
}

class App extends StatelessWidget {
  final Color _mainGreen = Color(0xFF60A625);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF9FFFB),
        systemNavigationBarIconBrightness: Brightness.dark));

    return MaterialApp(
      theme: ThemeData(
        primaryColor: _mainGreen,
        backgroundColor: Color(0xFFF9FFFB),
        accentColor: _mainGreen,
        colorScheme: ColorScheme.light(
          primary: _mainGreen,
          onPrimary: Color(0xFF697E72),
          surface: Color(0xFFE7EFEA),
          onSurface: _mainGreen,
        ),
        textTheme: TextTheme(
            headline1: TextStyle(
                fontSize: 72.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D4637)),
            bodyText1: TextStyle(
                fontSize: 30.0,
                color: Color(0xFF2D4637),
                fontWeight: FontWeight.bold),
            bodyText2: TextStyle(
                fontSize: 20.0,
                color: Color(0xFF2D4637),
                fontWeight: FontWeight.w500)),
      ),
      home: AppView(),
    );
  }
}
