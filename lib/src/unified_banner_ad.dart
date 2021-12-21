import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

enum UnifiedBannerAdEvent {
  onNoAd,
  onAdReceived,
  onAdExposure,
  onAdClosed,
  onAdClicked,
  onAdLeftApplication,
  /// iOS only
  onAdWillPresentFullScreenModal,
  /// iOS only
  onAdWillDismissFullScreenModal,
  /// iOS only
  onAdDidPresentFullScreenModal,
  /// iOS only
  onAdDidDismissFullScreenModal,
}

typedef UnifiedBannerAdEventCallback = Function(UnifiedBannerAdEvent event, dynamic arguments);

class UnifiedBannerAd extends StatefulWidget {
  /// 宽高比
  static const double ratio = 6.4;

  final String posId;

  final UnifiedBannerAdEventCallback? adEventCallback;

  final bool? refreshOnCreate;

  final int? refreshInterval;

  /// iOS only
  final bool? animated;

  const UnifiedBannerAd(this.posId, {Key? key, this.adEventCallback, this.refreshOnCreate, this.refreshInterval, this.animated}) : super(key: key);

  @override
  UnifiedBannerAdState createState() => UnifiedBannerAdState();
}

class UnifiedBannerAdState extends State<UnifiedBannerAd> {
  MethodChannel? _methodChannel;
  final UniqueKey _key = UniqueKey();
  @override
  Widget build(BuildContext context) {
    Map params = {};
    params['posId'] = widget.posId;
    if(widget.refreshInterval != null) {
      params['refreshInterval'] = widget.refreshInterval;
    }
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      if(widget.animated != null) {
        params['animated'] = widget.animated;
      }
      return UiKitView(
        key: _key,
        viewType: '$PLUGIN_ID/unified_banner',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: params,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return AndroidView(
      key: _key,
      viewType: '$PLUGIN_ID/unified_banner',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: params,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('$PLUGIN_ID/unified_banner_$id');
    _methodChannel!.setMethodCallHandler(_handleMethodCall);
    if(widget.refreshOnCreate == true) {
      refreshAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(widget.adEventCallback != null) {
      UnifiedBannerAdEvent? event;
      switch(call.method) {
        case 'onNoAd':
          event = UnifiedBannerAdEvent.onNoAd;
          break;
        case 'onAdReceived':
          event = UnifiedBannerAdEvent.onAdReceived;
          break;
        case 'onAdExposure':
          event = UnifiedBannerAdEvent.onAdExposure;
          break;
        case 'onAdClosed':
          event = UnifiedBannerAdEvent.onAdClosed;
          break;
        case 'onAdClicked':
          event = UnifiedBannerAdEvent.onAdClicked;
          break;
        case 'onAdLeftApplication':
          event = UnifiedBannerAdEvent.onAdLeftApplication;
          break;
        case 'onAdWillPresentFullScreenModal':
          event = UnifiedBannerAdEvent.onAdWillPresentFullScreenModal;
          break;
        case 'onAdWillDismissFullScreenModal':
          event = UnifiedBannerAdEvent.onAdWillDismissFullScreenModal;
          break;
        case 'onAdDidPresentFullScreenModal':
          event = UnifiedBannerAdEvent.onAdDidPresentFullScreenModal;
          break;
        case 'onAdDidDismissFullScreenModal':
          event = UnifiedBannerAdEvent.onAdDidDismissFullScreenModal;
          break;
        default:
          print('UnifiedBannerAd unknown event: ${call.method}');
      }
      if(event != null) {
        widget.adEventCallback!(event, call.arguments);
      }
    }
  }

  Future<void> closeAd() async {
    if(_methodChannel != null) {
      await _methodChannel!.invokeMethod('close');
    }
  }

  Future<void> refreshAd() async {
    if(_methodChannel != null) {
      await _methodChannel!.invokeMethod('refresh');
    }
  }

  @override
  void dispose() {
//    closeAd();
    super.dispose();
  }
}