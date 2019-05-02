import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';

class UnifiedInterstitialAdDemo extends StatefulWidget {
  final String posId;

  UnifiedInterstitialAdDemo(this.posId);

  @override
  UnifiedInterstitialAdDemoState createState() => UnifiedInterstitialAdDemoState();
}

class UnifiedInterstitialAdDemoState extends State<UnifiedInterstitialAdDemo> {
  UnifiedInterstitialAd _ad;

  @override
  void initState() {
    super.initState();
    _ad = UnifiedInterstitialAd(widget.posId, adEventCallback: _adEventCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () => _ad.loadAd(),
                child: Text('加载广告'),
              ),
              RaisedButton(
                onPressed: () => _ad.closeAd(),
                child: Text('关闭广告'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () => _ad.showAd(),
                child: Text('显示广告'),
              ),
              RaisedButton(
                onPressed: () => _ad.showAdAsPopup(),
                child: Text('弹出广告'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text('广告位ID：'),
              Expanded(
                child: Text(widget.posId,),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _adEventCallback(UnifiedInterstitialAdEvent event, dynamic params) {
    print('ad event: $event');
    if(event == UnifiedInterstitialAdEvent.onAdReceived) {
      _ad.showAd();
    }
  }
}