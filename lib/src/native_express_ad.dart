import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

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
}

typedef NativeExpressAdEventCallback = Function(NativeExpressAdEvent event, dynamic arguments);

class NativeExpressAd extends StatefulWidget {

  final String posId;

  final NativeExpressAdEventCallback adEventCallback;

  final bool refreshOnCreate;

  NativeExpressAd(this.posId, {Key key, this.adEventCallback, this.refreshOnCreate}) : super(key: key);

  @override
  NativeExpressAdState createState() => NativeExpressAdState();
}

class NativeExpressAdState extends State<NativeExpressAd> {
  MethodChannel _methodChannel;

  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: '$PLUGIN_ID/native_express',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posId': widget.posId},
      creationParamsCodec: StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$PLUGIN_ID/native_express_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if(this.widget.refreshOnCreate == true) {
      this.refreshAd();
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
      }
      widget.adEventCallback(event, call.arguments);
    }
  }

  Future<void> closeAd() async {
    if(_methodChannel != null) {
      await _methodChannel.invokeMethod('close');
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
  final GlobalKey<NativeExpressAdState> adKey = GlobalKey();
  final NativeExpressAdEventCallback adEventCallback;

  NativeExpressAdWidget(this.posId, {this.adEventCallback});

  @override
  NativeExpressAdWidgetState createState() => NativeExpressAdWidgetState();
}

class NativeExpressAdWidgetState extends State<NativeExpressAdWidget> {
  double _height = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: NativeExpressAd(widget.posId, key: widget.adKey, adEventCallback: _adEventCallback,refreshOnCreate: true,),
    );
  }

  void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) async {
    if(widget.adEventCallback != null) {
      widget.adEventCallback(event, arguments);
    }
    if(event == NativeExpressAdEvent.onLayout && this.mounted) {
      this.setState(() {
        _height = MediaQuery.of(context).size.width * arguments['height'] / arguments['width'];
      });
      return;
    }
  }
}