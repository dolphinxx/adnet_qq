import 'package:flutter/services.dart';
import 'constants.dart';
import 'adnet_qq_plugin.dart';

enum SplashAdEvent {
  onNoAd,
  onAdDismiss,
  onAdPresent,
  onAdExposure,
  onAdLoaded,
  onAdClicked,
  onAdTick,
  /// android only
  onRequestPermissionsFailed,
  /// iOS only
  onAdClosed,
  /// iOS only
  onApplicationWillEnterBackground,
  /// iOS only
  onAdWillClose,
  /// iOS only
  onAdWillPresentFullScreenModal,
  /// iOS only
  onAdDidPresentFullScreenModal,
  /// iOS only
  onAdWillDismissFullScreenModal,

}

typedef SplashAdEventCallback = Function(SplashAdEvent event, dynamic arguments);

class SplashAd {
  final String posId;

  /// splash background image, white if not specified.
  ///
  ///
  final String backgroundImage;

  final int fetchDelay;

  final SplashAdEventCallback adEventCallback;

  MethodChannel _methodChannel;

  SplashAd(this.posId, {this.backgroundImage, this.fetchDelay, this.adEventCallback}) {
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
        case 'onAdLoaded':
          event = SplashAdEvent.onAdLoaded;
          break;
        case 'onAdClicked':
          event = SplashAdEvent.onAdClicked;
          break;
        case 'onAdTick':
          event = SplashAdEvent.onAdTick;
          break;
        case 'onRequestPermissionsFailed':
          event = SplashAdEvent.onRequestPermissionsFailed;
          break;
        case 'onApplicationWillEnterBackground':
          event = SplashAdEvent.onApplicationWillEnterBackground;
          break;
        case 'onAdWillClose':
          event = SplashAdEvent.onAdWillClose;
          break;
        case 'onAdWillPresentFullScreenModal':
          event = SplashAdEvent.onAdWillPresentFullScreenModal;
          break;
        case 'onAdDidPresentFullScreenModal':
          event = SplashAdEvent.onAdDidPresentFullScreenModal;
          break;
        case 'onAdWillDismissFullScreenModal':
          event = SplashAdEvent.onAdWillDismissFullScreenModal;
          break;
        default:
          print('SplashAd unknown event: ${call.method}');
      }
      adEventCallback(event, call.arguments);
    }
  }

  Future<void> showAd() async {
    await AdnetQqPlugin.channel.invokeMethod('showSplash', {'posId': posId, 'backgroundImage': backgroundImage, 'fetchDelay': fetchDelay});
  }

  Future<void> closeAd() async {
    await AdnetQqPlugin.channel.invokeMethod('closeSplash');
  }
}