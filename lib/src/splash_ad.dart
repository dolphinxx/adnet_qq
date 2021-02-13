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

  /// splash container's background image.
  ///
  /// for android, it is the resource identifier(`packageName:resourcesName[-configQualifier]/fileNameWithoutExtension`)
  ///
  /// for iOS, it is the name of an assets
  final String backgroundImage;

  /// splash container's background color.
  ///
  /// It's an integer representing the color in the default sRGB color space, same as the `Color` in flutter. Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue.
  ///
  ///
  final int backgroundColor;

  final int fetchDelay;

  final SplashAdEventCallback adEventCallback;

  MethodChannel _methodChannel;

  SplashAd(this.posId, {this.backgroundImage, this.backgroundColor, this.fetchDelay, this.adEventCallback}) {
    _methodChannel = MethodChannel('$PLUGIN_ID/splash');
    _methodChannel.setMethodCallHandler(_handleMethodCall);
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
    await AdnetQqPlugin.channel.invokeMethod('showSplash', {'posId': posId, 'backgroundImage': backgroundImage, 'backgroundColor': backgroundColor, 'fetchDelay': fetchDelay});
  }

  Future<void> closeAd() async {
    await AdnetQqPlugin.channel.invokeMethod('closeSplash');
  }
}