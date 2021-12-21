import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';
import 'config.dart';

class UnifiedInterstitialAdDemo extends StatefulWidget {
  UnifiedInterstitialAdDemo();

  @override
  UnifiedInterstitialAdDemoState createState() => UnifiedInterstitialAdDemoState();
}

class UnifiedInterstitialAdDemoState extends State<UnifiedInterstitialAdDemo> {
  UnifiedInterstitialAd? _ad;
  List<String> events = [];
  bool? _adLoaded;
  bool isFullScreen = false;
  late String posId;
  List<String> posIds = config['unifiedInterstitialPosId'] as List<String>;

  @override
  void initState() {
    super.initState();
    posId = posIds.first;
  }

  @override
  void dispose() {
    _ad?.closeAd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  if(_ad != null) {
                    await _ad!.closeAd();
                  }
                  isFullScreen = false;
                  _ad = UnifiedInterstitialAd(posId, adEventCallback: _adEventCallback);
                  _ad!.loadAd();
                },
                child: Text('加载普通'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if(_ad != null) {
                    await _ad!.closeAd();
                  }
                  isFullScreen = true;
                  _ad = UnifiedInterstitialAd(posId, adEventCallback: _adEventCallback);
                  _ad!.loadFullScreenAd();
                },
                child: Text('加载全屏'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: _adLoaded == true && !isFullScreen ? () => _ad?.showAd() : null,
                child: Text('显示广告'),
              ),
              ElevatedButton(
                onPressed: _adLoaded == true && !isFullScreen ? () => _ad?.showAdAsPopup() : null,
                child: Text('弹出广告'),
              ),
              ElevatedButton(
                onPressed: _adLoaded == true && isFullScreen ? () => _ad?.showFullScreenAd() : null,
                child: Text('弹出全屏'),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  if(_adLoaded == true) {
                    await _ad?.closeAd();
                    _adLoaded = false;
                    _ad = null;
                  }
                  if(mounted) {
                    setState(() {});
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
                child: CupertinoPicker(
                  itemExtent: 42,
                  onSelectedItemChanged: (index) {
                    posId = posIds[index];
                  },
                  children: posIds.map((_) => ListTile(title: Text(_),)).toList(),
                ),
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
    if(event == UnifiedInterstitialAdEvent.onRenderSuccess) {
      _adLoaded = true;
    } else if(event == UnifiedInterstitialAdEvent.onAdClosed) {
      _adLoaded = false;
      _ad = null;
    }
    if(mounted) {
      setState(() {});
    }
  }
}