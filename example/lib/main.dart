import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:adnet_qq/adnet_qq.dart';
import 'unified_banner_ad.dart';
import 'native_express_ad.dart';
import 'unified_interstitial_ad.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  bool _splashAdDismissed = false;
  bool _splashAdPresent = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    try {
      await AdnetQqPlugin.config(appId: '1101152570');
    } on PlatformException {
    }
  }

  @override
  Widget build(BuildContext context) {
    return _splashAdDismissed ? MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: <Widget>[
            RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
              return UnifiedBannerAdDemo();
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
    ) : MaterialApp(
      navigatorKey: navigatorKey,
      home: WillPopScope(
        onWillPop: () async => false,
        child: Container(
          child: SplashAd('8863364436303842593', showOnCreate: true, adEventCallback: _handleAdEvent,),
        ),
      ),
    );
  }

  void _handleAdEvent(SplashAdEvent event) {
    switch(event) {
      case SplashAdEvent.onNoAd:
      case SplashAdEvent.onAdDismiss:
      if(this.mounted) {
        this.setState(() {_splashAdDismissed = true;});
      }
      break;
      case SplashAdEvent.onAdPresent:
        this._splashAdPresent = true;
        break;
      case SplashAdEvent.onRequestPermissionsFailed:
      // 因为我们不强制用户授权，防止广告加载出现意外导致一直停留在splash界面，用户拒绝授权5秒后如果还没有加载广告也没有关闭广告，则隐藏splash
        Future.delayed(Duration(seconds: 5), () {
          if(_splashAdDismissed == false && _splashAdPresent != true && this.mounted) {
            this.setState(() {_splashAdDismissed = true;});
          }
        });
        break;
      case SplashAdEvent.onAdExposure:
        break;
    }
  }
}