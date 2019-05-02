import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class UnifiedBannerAd extends StatefulWidget {

  final String posId;

  final ValueSetter onAdReceived;

  final bool refreshOnCreate;

  UnifiedBannerAd(this.posId, {Key key, this.onAdReceived, this.refreshOnCreate}) : super(key: key);

  @override
  UnifiedBannerAdState createState() => UnifiedBannerAdState();
}

class UnifiedBannerAdState extends State<UnifiedBannerAd> {
  MethodChannel _methodChannel;
  @override
  Widget build(BuildContext context) {
    return AndroidView(
      viewType: '$PLUGIN_ID/unified_banner',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: {'posId': widget.posId},
      creationParamsCodec: StandardMessageCodec(),
    );
  }

  void _onPlatformViewCreated(int id) {
    this._methodChannel = MethodChannel('$PLUGIN_ID/unified_banner_$id');
    this._methodChannel.setMethodCallHandler(_handleMethodCall);
    if(this.widget.refreshOnCreate == true) {
      this.refreshAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    switch(call.method) {
      case 'onAdReceived':
        if(widget.onAdReceived != null) {
          widget.onAdReceived(call.arguments);
        }
        break;
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

  @override
  void dispose() {
    closeAd();
    super.dispose();
  }
}