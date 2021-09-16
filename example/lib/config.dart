import 'package:flutter/foundation.dart';

Map config = defaultTargetPlatform == TargetPlatform.iOS ? {
  'appId': '1105344611',
  'unifiedBannerPosId': '1080958885885321',
  'nativeExpressPosId': [
    '5030722621265924',
    '1020922903364636',
  ],
  'unifiedInterstitialPosId': ['1050652855580392'],
  'splashPosId': '9040714184494018',
  // 'splashPosId': '8071800142568576',
  'splashBackgroundImage': 'SplashImage',
  'splashLogo': 'AppIcon',
} : {
  'appId': '1101152570',
  'unifiedBannerPosId': '4080052898050840',
  'nativeExpressPosId': [
    '7030020348049331',
    '6090892202222287',
    '8040197282727229',
    // '6040749702835933',
    // '7050291272634146',
    // '2060699242425877',
    // '9020995282824131',
    // '9000662439294066',
    '2000629911207832'
  ],
  'unifiedInterstitialPosId': [
    '3040652898151811',
    // 图文+视频 大规格
    '4080298282218338',
    // 图文+视频 小规格
    '1050691202717808',
    // 视频，大规格（竖版视频）
    '4090398252717676',
    // 视频，大规格（横版视频）
    '4090791272610625',
    // 小规格
    '8020259898964453'
  ],
  'splashPosId': '8863364436303842593',
  'splashBackgroundImage': 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/splash_bg',
  'splashLogo': 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/ic_launcher',
};