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
  bool _adLoaded;
  bool _fullScreenAdLoaded;

  @override
  void initState() {
    super.initState();
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
                onPressed: () {
                  if(_ad == null) {
                    _ad = UnifiedInterstitialAd(widget.posId, adEventCallback: _adEventCallback);
                  }
                  _ad.loadAd();
                },
                child: Text('加载普通'),
              ),
              RaisedButton(
                onPressed: () {
                  if(_fullScreenAd == null) {
                    _fullScreenAd = UnifiedInterstitialAd(widget.fullScreenPosId, adEventCallback: _fullScreenAdEventCallback);
                  }
                  _fullScreenAd.loadFullScreenAd();
                },
                child: Text('加载全屏'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: _adLoaded == true ? () => _ad.showAd() : null,
                child: Text('显示广告'),
              ),
              RaisedButton(
                onPressed: _adLoaded == true ? () => _ad.showAdAsPopup() : null,
                child: Text('弹出广告'),
              ),
              RaisedButton(
                onPressed: _fullScreenAdLoaded == true ? () => _fullScreenAd.showFullScreenAd() : null,
                child: Text('弹出全屏'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  if(_adLoaded == true) {
                    _ad.closeAd();
                    _adLoaded = false;
                    _ad = null;
                  }
                  if(_fullScreenAdLoaded == true) {
                    _fullScreenAd.closeAd();
                    _fullScreenAdLoaded = false;
                    _fullScreenAd = null;
                  }
                  if(this.mounted) {
                    this.setState(() {
                    });
                  }
                },
                child: Text('关闭广告'),
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
      _adLoaded = true;
    } else if(event == UnifiedInterstitialAdEvent.onAdClosed) {
      _adLoaded = false;
    }
    if(this.mounted) {
      this.setState(() {
      });
    }
  }

  void _fullScreenAdEventCallback(UnifiedInterstitialAdEvent event, dynamic params) {
    events.insert(0, '${event.toString().split('.')[1]} ${params??""}');
    if(event == UnifiedInterstitialAdEvent.onAdReceived) {
      _fullScreenAdLoaded = true;
    } else if(event == UnifiedInterstitialAdEvent.onAdClosed) {
      _fullScreenAdLoaded = false;
    }
    if(this.mounted) {
      this.setState(() {
      });
    }
  }
}