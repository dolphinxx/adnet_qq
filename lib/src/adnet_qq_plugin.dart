import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

class AdnetQqPlugin {
  static const MethodChannel channel =
      const MethodChannel(PLUGIN_ID);

  /// [appId] appId from `adnet.qq.com`
  ///
  /// [requestReadPhoneState] whether request READ_PHONE_STATE (android only), 0: no, 1: yes, 2: force(exit app when user reject this permission), default 0
  ///
  /// [requestAccessFineLocation] whether request ACCESS_FINE_LOCATION (android only), 0: no, 1: yes, 2: force(exit app when user reject this permission), default 0
  static Future<bool> config({@required String appId, int requestReadPhoneState: 0, int requestAccessFineLocation: 0}) async {
    return await channel.invokeMethod('config', {'appId': appId, 'requestReadPhoneState': requestReadPhoneState, 'requestAccessFineLocation': requestAccessFineLocation});
  }

  /// create a UnifiedInterstitialAd, and communicate with it through channel Id '$PLUGIN_ID/unified_interstitial_$posId'
  static Future<bool> createUnifiedInterstitialAd({@required String posId}) async {
    return await channel.invokeMethod('createUnifiedInterstitialAd', {'posId': posId});
  }
}