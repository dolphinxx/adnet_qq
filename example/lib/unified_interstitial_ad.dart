import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';

class UnifiedInterstitialAdDemo extends StatefulWidget {
  final String posId;
  final String fullScreenPosId;

  UnifiedInterstitialAdDemo(this.posId, this.fullScreenPosId);

  @override
  UnifiedInterstitialAdDemoState createState() => UnifiedInterstitialAdDemoState();
}

class UnifiedInterstitialAdDemoState extends State<UnifiedInterstitialAdDemo> {
  UnifiedInterstitialAd _ad;
  UnifiedInterstitialAd _fullScreenAd;
  List<String> events = List();

  @override
  void initState() {
    super.initState();
    _ad = UnifiedInterstitialAd(widget.posId, adEventCallback: _adEventCallback);
    _fullScreenAd = UnifiedInterstitialAd(widget.fullScreenPosId, adEventCallback: _adEventCallback);
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
              RaisedButton(
                onPressed: () => _fullScreenAd.loadFullScreenAd(),
                child: Text('加载全屏'),
              ),
              RaisedButton(
                onPressed: () => _fullScreenAd.showFullScreenAd(),
                child: Text('显示全屏'),
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Text(events[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _adEventCallback(UnifiedInterstitialAdEvent event, dynamic params) {
    events.insert(0, '${event.toString().split('.')[1]} ${params??""}');
    if(event == UnifiedInterstitialAdEvent.onAdReceived) {
      _ad.showAd();
    }
    if(this.mounted) {
      this.setState(() {
      });
    }
  }
}