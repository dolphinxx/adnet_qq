import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adnet_qq/adnet_qq.dart';
import 'unified_banner_ad.dart';
import 'native_express_ad.dart';
import 'unified_interstitial_ad.dart';

void main() {
  try {
    AdnetQqPlugin.config(appId: '1101152570').then((_) => SplashAd('8863364436303842593', backgroundImage: 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/splash_bg').showAd());
  } on PlatformException {
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return UnifiedBannerAdDemo('4080052898050840');
              })),
              child: Text('横幅2.0'),
            ),
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return NativeExpressAdDemo('7030020348049331');
              })),
              child: Text('原生模板'),
            ),
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return UnifiedInterstitialAdDemo('3040652898151811');
              })),
              child: Text('插屏2.0'),
            ),
          ],
        ),
      ),
    );
  }
}