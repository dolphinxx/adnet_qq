import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
import 'video_options.dart';

enum NativeExpressAdEvent {
  onLayout,
  onNoAd,
  onAdLoaded,
  onRenderFail,
  onRenderSuccess,
  onAdExposure,
  onAdClicked,
  onAdClosed,
  onAdLeftApplication,
  onAdOpenOverlay,
  onAdCloseOverlay,
  /// iOS only
  onAdDidPresentScreen,
  /// iOS only
  onAdWillDismissScreen,
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

typedef NativeExpressAdEventCallback = Function(NativeExpressAdEvent event, dynamic arguments);

class NativeExpressAd extends StatefulWidget {

  final String posId;

  /// ad count to request, default value is 5
  final int requestCount;

  final AdVideoOptions videoOptions;

  final NativeExpressAdEventCallback adEventCallback;

  final bool refreshOnCreate;

  const NativeExpressAd(this.posId, {Key key, this.requestCount = 5, this.adEventCallback, this.refreshOnCreate, this.videoOptions}) : super(key: key);

  @override
  NativeExpressAdState createState() => NativeExpressAdState();
}

class NativeExpressAdState extends State<NativeExpressAd> {
  MethodChannel _methodChannel;
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        key: _key,
        viewType: '$PLUGIN_ID/native_express',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {'posId': widget.posId, 'count': widget.requestCount, ...widget.videoOptions?.getOptions()??{}, 'iOSOptions': widget.videoOptions?.getIOSOptions()},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return AndroidView(
      key: _key,
      viewType: '$PLUGIN_ID/native_express',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posId': widget.posId, 'count': widget.requestCount, ...widget.videoOptions?.getOptions()??{}, 'androidOptions': widget.videoOptions?.getAndroidOptions()},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('$PLUGIN_ID/native_express_$id');
    _methodChannel.setMethodCallHandler(_handleMethodCall);
    if(widget.refreshOnCreate == true) {
      refreshAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(widget.adEventCallback != null) {
      NativeExpressAdEvent event;
      switch (call.method) {
        case 'onLayout':
          event = NativeExpressAdEvent.onLayout;
          break;
        case 'onNoAd':
          event = NativeExpressAdEvent.onNoAd;
          break;
        case 'onAdLoaded':
          event = NativeExpressAdEvent.onAdLoaded;
          break;
        case 'onRenderFail':
          event = NativeExpressAdEvent.onRenderFail;
          break;
        case 'onRenderSuccess':
          event = NativeExpressAdEvent.onRenderSuccess;
          break;
        case 'onAdExposure':
          event = NativeExpressAdEvent.onAdExposure;
          break;
        case 'onAdClicked':
          event = NativeExpressAdEvent.onAdClicked;
          break;
        case 'onAdClosed':
          event = NativeExpressAdEvent.onAdClosed;
          break;
        case 'onAdLeftApplication':
          event = NativeExpressAdEvent.onAdLeftApplication;
          break;
        case 'onAdOpenOverlay':
          event = NativeExpressAdEvent.onAdOpenOverlay;
          break;
        case 'onAdCloseOverlay':
          event = NativeExpressAdEvent.onAdCloseOverlay;
          break;
        case 'onAdDidPresentScreen':
          event = NativeExpressAdEvent.onAdDidPresentScreen;
          break;
        case 'onAdWillDismissScreen':
          event = NativeExpressAdEvent.onAdWillDismissScreen;
          break;
        case 'onAdPlayerStatusChanged':
          event = NativeExpressAdEvent.onAdPlayerStatusChanged;
          break;
        case 'onAdWillPresentVideoVC':
          event = NativeExpressAdEvent.onAdWillPresentVideoVC;
          break;
        case 'onAdDidPresentVideoVC':
          event = NativeExpressAdEvent.onAdDidPresentVideoVC;
          break;
        case 'onAdWillDismissVideoVC':
          event = NativeExpressAdEvent.onAdWillDismissVideoVC;
          break;
        case 'onAdDidDismissVideoVC':
          event = NativeExpressAdEvent.onAdDidDismissVideoVC;
          break;
        default:
          print('NativeExpressAd unknown event: ${call.method}');
      }
      widget.adEventCallback(event, call.arguments);
    }
  }

  Future<void> closeAd() async {
    if(_methodChannel != null) {
      try {
        await _methodChannel.invokeMethod('close');
      } catch (_) {
        // ad may be already closed.
      }
      _methodChannel = null;
    }
  }

  Future<void> refreshAd() async {
    if(_methodChannel != null) {
      await _methodChannel.invokeMethod('refresh');
    }
  }

//  /// map of {width, height}
//  Future<Map> getSize() async {
//    if(_methodChannel != null) {
//      return await _methodChannel.invokeMethod('getSize');
//    }
//    return null;
//  }

  @override
  void dispose() {
   closeAd();
    super.dispose();
  }
}

class NativeExpressAdWidget extends StatefulWidget {
  final String posId;
  final int requestCount;
  final AdVideoOptions videoOptions;
  final GlobalKey<NativeExpressAdState> adKey;
  final NativeExpressAdEventCallback adEventCallback;
  final double loadingHeight;

  /// [loadingHeight] should be above 0, otherwise the ad may not be loaded.
  NativeExpressAdWidget(this.posId, {GlobalKey<NativeExpressAdState> adKey, this.requestCount, this.videoOptions, this.adEventCallback, this.loadingHeight = 1.0}):adKey = adKey??GlobalKey();

  @override
  NativeExpressAdWidgetState createState() => NativeExpressAdWidgetState(height: loadingHeight);
}

class NativeExpressAdWidgetState extends State<NativeExpressAdWidget> {
  double _height;
  NativeExpressAd _ad;

  NativeExpressAdWidgetState({double height}):_height = height;

  @override
  void initState() {
    super.initState();
    _ad = NativeExpressAd(widget.posId, key: widget.adKey, requestCount: widget.requestCount, videoOptions: widget.videoOptions, adEventCallback: _adEventCallback,refreshOnCreate: true,);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: _ad,
    );
  }

  void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) async {
    if(widget.adEventCallback != null) {
      widget.adEventCallback(event, arguments);
    }
    if(event == NativeExpressAdEvent.onAdClosed) {
      if(mounted) {
        setState(() {
          _height = widget.loadingHeight??0;
        });
      }
      return;
    }
    if(event == NativeExpressAdEvent.onLayout && mounted) {
      if(arguments['width'] > 0 && arguments['height'] > 0) {
        setState(() {
          _height = MediaQuery.of(context).size.width * arguments['height'] / arguments['width'];
        });
      }
      return;
    }
  }
}