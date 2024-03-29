import 'dart:async';
import 'dart:math' show min;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
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
  /// iOS only
  onAdDidPresentScreen,
  /// iOS only
  onAdWillDismissScreen,
  /// iOS only
  onAdWillPresentScreen,
  /// iOS only
  onAdDidDismissScreen,
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

  final AdVideoOptions? videoOptions;

  final NativeExpressAdEventCallback? adEventCallback;

  final bool? refreshOnCreate;

  const NativeExpressAd(this.posId, {Key? key, int? requestCount, this.adEventCallback, this.refreshOnCreate, this.videoOptions}) : requestCount = requestCount??5,super(key: key);

  @override
  NativeExpressAdState createState() => NativeExpressAdState();
}

class NativeExpressAdState extends State<NativeExpressAd> {
  MethodChannel? _methodChannel;
  final UniqueKey _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    String viewType = '$PLUGIN_ID/native_express';
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        key: _key,
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: {'posId': widget.posId, 'count': widget.requestCount, ...widget.videoOptions?.getOptions()??{}, 'iOSOptions': widget.videoOptions?.getIOSOptions()},
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return PlatformViewLink(
      key: _key,
      viewType: viewType,
      surfaceFactory:
          (BuildContext context, PlatformViewController controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams _params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: _params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: {'posId': widget.posId, 'count': widget.requestCount, ...widget.videoOptions?.getOptions()??{}, 'androidOptions': widget.videoOptions?.getAndroidOptions()},
          creationParamsCodec: const StandardMessageCodec(),
        )
          ..addOnPlatformViewCreatedListener(_params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();
      },
    );
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('$PLUGIN_ID/native_express_$id');
    _methodChannel!.setMethodCallHandler(_handleMethodCall);
    if(widget.refreshOnCreate == true) {
      refreshAd();
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if(widget.adEventCallback != null) {
      NativeExpressAdEvent? event;
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
        case 'onAdDidPresentScreen':
          event = NativeExpressAdEvent.onAdDidPresentScreen;
          break;
        case 'onAdWillDismissScreen':
          event = NativeExpressAdEvent.onAdWillDismissScreen;
          break;
        case 'onAdWillPresentScreen':
          event = NativeExpressAdEvent.onAdWillPresentScreen;
          break;
        case 'onAdDidDismissScreen':
          event = NativeExpressAdEvent.onAdDidDismissScreen;
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
      if(event != null) {
        widget.adEventCallback!(event, call.arguments);
      }
    }
  }

  Future<void> closeAd() async {
    if(_methodChannel != null) {
      try {
        await _methodChannel!.invokeMethod('close');
      } catch (_) {
        // ad may be already closed.
      }
      _methodChannel = null;
    }
  }

  Future<void> refreshAd() async {
    if(_methodChannel != null) {
      await _methodChannel!.invokeMethod('refresh');
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
  final int? requestCount;
  final AdVideoOptions? videoOptions;
  final GlobalKey<NativeExpressAdState>? adKey;
  final NativeExpressAdEventCallback? adEventCallback;
  final double loadingHeight;

  /// [loadingHeight] should be above 0, otherwise the ad may not be loaded.
  NativeExpressAdWidget(this.posId, {Key? key, this.adKey, this.requestCount, this.videoOptions, this.adEventCallback, double? loadingHeight}):loadingHeight = loadingHeight?? 1.0,super(key: key);

  @override
  NativeExpressAdWidgetState createState() => NativeExpressAdWidgetState(height: loadingHeight);
}

class NativeExpressAdWidgetState extends State<NativeExpressAdWidget> with SingleTickerProviderStateMixin {
  late final GlobalKey<NativeExpressAdState>? _adKey;
  double _height;
  late AnimationController _controller;
  late Animation<double> _animation;

  NativeExpressAdWidgetState({required double height}):_height = height;

  @override
  void initState() {
    super.initState();
    _adKey = widget.adKey ?? GlobalKey();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300), value: 1.0);
    _animation = _controller.drive(CurveTween(curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_height == null) {
      return const SizedBox.shrink();
    }
    return SizeTransition(
      sizeFactor: _animation,
      child: SizedBox(
        height: _height,
        child: NativeExpressAd(widget.posId, key: _adKey, requestCount: widget.requestCount, videoOptions: widget.videoOptions, adEventCallback: _adEventCallback,refreshOnCreate: true,),
      ),
    );
  }

  void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) {
    if(widget.adEventCallback != null) {
      widget.adEventCallback!(event, arguments);
    }
    if(event == NativeExpressAdEvent.onAdClosed || event == NativeExpressAdEvent.onNoAd) {
      _controller.reverse().then((value) {
        if(mounted) {
          setState(() {
            _height = 0;
          });
        }
      });
      return;
    }
    if(event == NativeExpressAdEvent.onLayout && mounted) {
      if(arguments['width'] as double > 0 && arguments['height'] as double > 0) {
        double _initialHeight = _height;
        setState(() {
          _height = MediaQuery.of(context).size.width * (arguments['height'] as double) / (arguments['width'] as double);
          _controller.value = min(1.0, _initialHeight / _height);
        });
        _controller.forward();
      }
      return;
    }
  }
}