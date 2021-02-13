import 'package:adnet_qq_example/home.dart';
import 'package:adnet_qq_example/splash_ad.dart';
import 'package:flutter/material.dart';

import 'darkness.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.light;


  @override
  void initState() {
    super.initState();
    darknessNotifier.addListener(() {
      if(mounted) {
        setState(() {
          _themeMode = darknessNotifier.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      routes: {
        '/': (context) => HomeWidget(),
        '/splash': (context) => SplashWidget(),
      },
      initialRoute: '/splash',
    );
  }
}