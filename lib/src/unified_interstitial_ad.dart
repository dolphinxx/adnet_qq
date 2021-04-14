import 'package:flutter/services.dart';

import 'constants.dart';
import 'adnet_qq_plugin.dart';
import 'video_options.dart';

typedef UnifiedInterstitialAdEventCallback = Function(UnifiedInterstitialAdEvent event, dynamic arguments);
enum UnifiedInterstitialAdEvent {
  onNoAd,
  onAdReceived,
  onAdExposure,
  onAdClosed,
  onAdClicked,
  onAdLeftApplication,
  onAdOpened,
  /// android only
  onVideoCached,
  /// iOS only
  onAdWillPresentScreen,
  /// iOS only
  onAdDidPresentScreen,
  /// iOS only
  onAdWillDismissFullScreenModal,
  /// iOS only
  onAdDidDismissFullScreenModal,
  /// iOS only
  onAdPlayerStatusChanged,
  /// iOS only
  onAdWillPresentVideoVC,
  /// iOS only
  onAdDidPresentVideoVC,
  /// iOS only
  onAdWillDismissVideoVC,
  /// iOS only
  onAdDidDismissVideoVC,
}

class UnifiedInterstitialAd {
  final String posId;

  final AdVideoOptions? videoOptions;

  final UnifiedInterstitialAdEventCallback? adEventCallback;

  late final MethodChannel _methodChannel;

  UnifiedInterstitialAd(this.posId, {this.videoOptions, this.adEventCallback}) : _methodChannel = MethodChannel('$PLUGIN_ID/unified_interstitial_$posId') {
    _methodChannel.setMethodCallHandler(_handleMethodCall);
    AdnetQqPlugin.createUnifiedInterstitialAd(posId: posId, videoOptions: videoOptions);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(adEventCallback != null) {
      UnifiedInterstitialAdEvent? event;
      switch (call.method) {
        case 'onNoAd':
          event = UnifiedInterstitialAdEvent.onNoAd;
          break;
        case 'onAdReceived':
          event = UnifiedInterstitialAdEvent.onAdReceived;
          break;
        case 'onAdExposure':
          event = UnifiedInterstitialAdEvent.onAdExposure;
          break;
        case 'onAdClosed':
          event = UnifiedInterstitialAdEvent.onAdClosed;
          break;
        case 'onAdClicked':
          event = UnifiedInterstitialAdEvent.onAdClicked;
          break;
        case 'onAdLeftApplication':
          event = UnifiedInterstitialAdEvent.onAdLeftApplication;
          break;
        case 'onAdOpened':
          event = UnifiedInterstitialAdEvent.onAdOpened;
          break;
        case 'onVideoCached':
          event = UnifiedInterstitialAdEvent.onVideoCached;
          break;
        case 'onAdWillPresentScreen':
          event = UnifiedInterstitialAdEvent.onAdWillPresentScreen;
          break;
        case 'onAdDidPresentScreen':
          event = UnifiedInterstitialAdEvent.onAdDidPresentScreen;
          break;
        case 'onAdWillDismissFullScreenModal':
          event = UnifiedInterstitialAdEvent.onAdWillDismissFullScreenModal;
          break;
        case 'onAdDidDismissFullScreenModal':
          event = UnifiedInterstitialAdEvent.onAdDidDismissFullScreenModal;
          break;
        case 'onAdPlayerStatusChanged':
          event = UnifiedInterstitialAdEvent.onAdPlayerStatusChanged;
          break;
        case 'onAdWillPresentVideoVC':
          event = UnifiedInterstitialAdEvent.onAdWillPresentVideoVC;
          break;
        case 'onAdDidPresentVideoVC':
          event = UnifiedInterstitialAdEvent.onAdDidPresentVideoVC;
          break;
        case 'onAdWillDismissVideoVC':
          event = UnifiedInterstitialAdEvent.onAdWillDismissVideoVC;
          break;
        case 'onAdDidDismissVideoVC':
          event = UnifiedInterstitialAdEvent.onAdDidDismissVideoVC;
          break;
        default:
          print('UnifiedInterstitialAd unknown event: ${call.method}');
      }
      if(event != null) {
        adEventCallback!(event, call.arguments);
      }
    }
  }

  Future<void> loadAd() async {
    await _methodChannel.invokeMethod('load');
  }

  Future<void> loadFullScreenAd() async {
    await _methodChannel.invokeMethod('loadFullScreen');
  }

  Future<void> closeAd() async {
    await _methodChannel.invokeMethod('close');
  }

  Future<void> showAd() async {
    await _methodChannel.invokeMethod('show');
  }

  Future<void> showAdAsPopup() async {
    await _methodChannel.invokeMethod('popup');
  }

  Future<void> showFullScreenAd() async {
    await _methodChannel.invokeMethod('showFullScreen');
  }
}