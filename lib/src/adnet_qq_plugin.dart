import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class AdnetQqPlugin {
  static const MethodChannel _channel =
      const MethodChannel(PLUGIN_ID);

  static Future<bool> config({@required String appId}) async {
    return await _channel.invokeMethod('config', {'appId': appId});
  }

  /// create a UnifiedInterstitialAd, and communicate with it through channel Id '$PLUGIN_ID/unified_interstitial_$posId'
  static Future<bool> createUnifiedInterstitialAd({@required String posId}) async {
    return await _channel.invokeMethod('createUnifiedInterstitialAd', {'posId': posId});
  }
}