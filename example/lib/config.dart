import 'package:flutter/foundation.dart';

Map config = defaultTargetPlatform == TargetPlatform.iOS ? {
  'appId': '1105344611',
  'unifiedBannerPosId': '1080958885885321',
  'nativeExpressPosId': '5030722621265924',
  'nativeExpressPosId2':'1020922903364636',
  'unifiedInterstitialPosId': '1050652855580392',
  'unifiedInterstitialFullScreenPosId': '1050652855580392',
  'splashPosId': '9040714184494018',
  'splashBackgroundImage': 'SplashImage'
} : {
  'appId': '1101152570',
  'unifiedBannerPosId': '4080052898050840',
  'nativeExpressPosId': '7030020348049331',
  'nativeExpressPosId2':'2000629911207832',
  'unifiedInterstitialPosId': '3040652898151811',
  'unifiedInterstitialFullScreenPosId': '4080298282218338',
  'splashPosId': '8863364436303842593',
  'splashBackgroundImage': 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/splash_bg'
};