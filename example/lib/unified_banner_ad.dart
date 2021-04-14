import 'package:adnet_qq/adnet_qq.dart';
import 'package:adnet_qq_example/darkness.dart';
import 'package:flutter/material.dart' hide Banner;

class UnifiedBannerAdDemo extends StatefulWidget {
  final String posId;

  UnifiedBannerAdDemo(this.posId);

  @override
  UnifiedBannerAdDemoState createState() => UnifiedBannerAdDemoState();
}

class UnifiedBannerAdDemoState extends State<UnifiedBannerAdDemo> {
  bool _adClosed = false;
  final GlobalKey<UnifiedBannerAdState> _adKey = GlobalKey();
  List<String> events = [];

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
              ElevatedButton(
                onPressed: (){
                  setState(() {
                    _adClosed = false;
                  });
                  _adKey.currentState?.refreshAd();
                },
                child: Text('刷新广告'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _adKey.currentState?.closeAd();
                  if(mounted) {
                    setState(() {_adClosed = true;});
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
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.pinkAccent,
          onPressed: () {
        toggleDarkness();
      }),
    );
  }

  void _adEventCallback(UnifiedBannerAdEvent event, dynamic arguments) {
    events.insert(0, '${event.toString().split('.')[1]} ${arguments??""}');
    if(event == UnifiedBannerAdEvent.onAdClosed) {
      _adClosed = true;
    }
    if(mounted) {
      setState(() {});
    }
  }

}