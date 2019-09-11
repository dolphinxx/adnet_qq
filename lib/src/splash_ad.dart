import 'package:flutter/services.dart';
import 'constants.dart';
import 'adnet_qq_plugin.dart';

enum SplashAdEvent {
  onNoAd,
  onAdDismiss,
  onAdClosed,
  onAdPresent,
  onAdExposure,
//  onRequestPermissionsFailed,
}

typedef SplashAdEventCallback = Function(SplashAdEvent event, dynamic arguments);

class SplashAd {
  final String posId;

  /// splash background image, white if not specified.
  ///
  ///
  final String backgroundImage;

  final SplashAdEventCallback adEventCallback;

  MethodChannel _methodChannel;

  SplashAd(this.posId, {this.backgroundImage, this.adEventCallback}) {
    this._methodChannel = MethodChannel('$PLUGIN_ID/splash');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(adEventCallback != null) {
      SplashAdEvent event;
      switch (call.method) {
        case 'onNoAd':
          event = SplashAdEvent.onNoAd;
          break;
        case 'onAdDismiss':
          event = SplashAdEvent.onAdDismiss;
          break;
        case 'onAdClosed':
          event = SplashAdEvent.onAdClosed;
          break;
        case 'onAdPresent':
          event = SplashAdEvent.onAdPresent;
          break;
        case 'onAdExposure':
          event = SplashAdEvent.onAdExposure;
          break;
//        case 'onRequestPermissionsFailed':
//          event = SplashAdEvent.onRequestPermissionsFailed;
//          break;
      }
      adEventCallback(event, call.arguments);
    }
  }

  Future<void> showAd() async {
    await AdnetQqPlugin.channel.invokeMethod('showSplash', {'posId': posId, 'backgroundImage': backgroundImage,});
  }

  Future<void> closeAd() async {
    await AdnetQqPlugin.channel.invokeMethod('closeSplash');
  }
}