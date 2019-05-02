import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';
enum SplashAdEvent {
  onNoAd,
  onAdDismiss,
  onAdPresent,
  onAdExposure,
  onRequestPermissionsFailed,
}
class SplashAd extends StatefulWidget {

  final String posId;

  final ValueSetter<SplashAdEvent> adEventCallback;

  final bool showOnCreate;

  SplashAd(this.posId, {Key key, this.adEventCallback, this.showOnCreate,}) : super(key: key);

  @override
  SplashAdState createState() => SplashAdState();
}

class SplashAdState extends State<SplashAd> {
  MethodChannel _methodChannel;
  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: '$PLUGIN_ID/splash',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posId': widget.posId},
      creationParamsCodec: StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$PLUGIN_ID/splash_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if(this.widget.showOnCreate == true) {
      this.showAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(widget.adEventCallback != null) {
      SplashAdEvent event;
      switch (call.method) {
        case 'onNoAd':
          event = SplashAdEvent.onNoAd;
          break;
        case 'onAdDismiss':
          event = SplashAdEvent.onAdDismiss;
          break;
        case 'onAdPresent':
          event = SplashAdEvent.onAdPresent;
          break;
        case 'onAdExposure':
          event = SplashAdEvent.onAdExposure;
          break;
        case 'onRequestPermissionsFailed':
          event = SplashAdEvent.onRequestPermissionsFailed;
          break;
      }
      widget.adEventCallback(event);
    }
  }

  Future<void> showAd() async {
    if(_methodChannel != null) {
      await _methodChannel.invokeMethod('show');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}