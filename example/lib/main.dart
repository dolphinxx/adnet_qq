import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adnet_qq/adnet_qq.dart';
import 'unified_banner_ad.dart';
import 'native_express_ad.dart';
import 'unified_interstitial_ad.dart';

Map config = defaultTargetPlatform == TargetPlatform.iOS ? {
  'appId': '1105344611',
  'unifiedBannerPosId': '1080958885885321',
  'nativeExpressPosId': '5030722621265924',
  'nativeExpressPosId2':'1020922903364636',
  'unifiedInterstitialPosId': '1050652855580392',
  'splashPosId': '9040714184494018',
  'splashBackgroundImage': 'LaunchImage'
} : {
  'appId': '1101152570',
  'unifiedBannerPosId': '4080052898050840',
  'nativeExpressPosId': '7030020348049331',
  'nativeExpressPosId2':'2000629911207832',
  'unifiedInterstitialPosId': '3040652898151811',
  'splashPosId': '8863364436303842593',
  'splashBackgroundImage': 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/splash_bg'
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AdnetQqPlugin.config(appId: config['appId'], requestReadPhoneState: 0, requestAccessFineLocation: 0).then((_) => SplashAd(config['splashPosId'], backgroundImage: config['splashBackgroundImage']).showAd());
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
              return UnifiedBannerAdDemo(config['unifiedBannerPosId']);
              })),
              child: Text('横幅2.0'),
            ),
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return NativeExpressAdDemo(config['nativeExpressPosId']);
              })),
              child: Text('原生模板'),
            ),
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return UnifiedInterstitialAdDemo(config['unifiedInterstitialPosId']);
              })),
              child: Text('插屏2.0'),
            ),
          ],
        ),
      ),
    );
  }
}