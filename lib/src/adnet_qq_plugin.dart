import 'dart:async';

import 'package:adnet_qq/src/video_options.dart';
import 'package:flutter/services.dart';

import 'constants.dart';

class AdnetQqPlugin {
  static const MethodChannel channel = MethodChannel(PLUGIN_ID);

  static bool _initialized = false;

  static bool get initialized => _initialized;

  /// [appId] appId from `adnet.qq.com`
  ///
  /// [requestReadPhoneState] whether request READ_PHONE_STATE (android only), 0: no, 1: yes, 2: force(exit app when user reject this permission), default 0
  ///
  /// [requestAccessFineLocation] whether request ACCESS_FINE_LOCATION (android only), 0: no, 1: yes, 2: force(exit app when user reject this permission), default 0
  ///
  /// [adChannel] is one of follows, default to `999`:
  /// - 1	百度
  /// - 2	头条
  /// - 3	广点通
  /// - 4	搜狗
  /// - 5	其他网盟
  /// - 6	oppo
  /// - 7	vivo
  /// - 8	华为
  /// - 9	应用宝
  /// - 10	小米
  /// - 11	金立
  /// - 12	百度手机助手
  /// - 13	魅族
  /// - 14	AppStore
  /// - 999	其他
  ///
  static Future<bool> config({required String appId, int requestReadPhoneState = 0, int requestAccessFineLocation = 0, int? adChannel}) async {
    if(_initialized) {
      return true;
    }
    bool result = await channel.invokeMethod('config', {'appId': appId, 'requestReadPhoneState': requestReadPhoneState, 'requestAccessFineLocation': requestAccessFineLocation, 'adChannel': adChannel}) ?? false;
    if(result == true) {
      _initialized = true;
    }
    return result;
  }

  /// create a UnifiedInterstitialAd, and communicate with it through channel Id '$PLUGIN_ID/unified_interstitial_$posId'
  static Future<bool> createUnifiedInterstitialAd({required String posId, AdVideoOptions? videoOptions}) async {
    return await channel.invokeMethod<bool>('createUnifiedInterstitialAd', {'posId': posId, ...videoOptions?.getOptions()??{}, 'androidOptions': videoOptions?.getAndroidOptions(), 'iOSOptions': videoOptions?.getIOSOptions()}) ?? false;
  }
}