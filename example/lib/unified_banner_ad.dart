import 'package:adnet_qq/adnet_qq.dart';
import 'package:flutter/material.dart' hide Banner;

class UnifiedBannerAdDemo extends StatefulWidget {
  final String posId;

  UnifiedBannerAdDemo(this.posId);

  @override
  UnifiedBannerAdDemoState createState() => UnifiedBannerAdDemoState();
}

class UnifiedBannerAdDemoState extends State<UnifiedBannerAdDemo> {
  bool _adClosed = false;
  GlobalKey<UnifiedBannerAdState> _adKey = GlobalKey();

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
          Container(
            height: _adClosed ? 0 : MediaQuery.of(context).size.width / UnifiedBannerAd.ratio,
            child: _adClosed ? Container() : UnifiedBannerAd(widget.posId, key: _adKey, adEventCallback: _adEventCallback,refreshOnCreate: true),
          ),

          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  this.setState(() {
                    this._adClosed = false;
                  });
                  _adKey.currentState?.refreshAd();
                },
                child: Text('刷新广告'),
              ),
              RaisedButton(
                onPressed: () async {
                  await _adKey.currentState?.closeAd();
                  if(this.mounted) {
                    this.setState(() {_adClosed = true;});
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
                child: Text(widget.posId),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _adEventCallback(UnifiedBannerAdEvent event, dynamic arguments) {
    if(event == UnifiedBannerAdEvent.onAdClosed) {
      if(this.mounted) {
        this.setState(() {
          _adClosed = true;
        });
      }
    }
  }

}