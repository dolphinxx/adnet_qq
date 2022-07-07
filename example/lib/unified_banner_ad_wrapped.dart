import 'package:adnet_qq/adnet_qq.dart';
import 'package:adnet_qq_example/darkness.dart';
import 'package:flutter/material.dart' hide Banner;

import 'ad_wrapper.dart';

class UnifiedBannerAdWrappedDemo extends StatefulWidget {
  final String posId;

  UnifiedBannerAdWrappedDemo(this.posId);

  @override
  UnifiedBannerAdWrappedDemoState createState() => UnifiedBannerAdWrappedDemoState();
}

class UnifiedBannerAdWrappedDemoState extends State<UnifiedBannerAdWrappedDemo> {
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
          AdWidget(builder: (context, onClosed, Key key) {
            return Center(
              child: AspectRatio(
                aspectRatio: UnifiedBannerAd.ratio,
                child: UnifiedBannerAd(
                  widget.posId,
                  refreshOnCreate: true,
                  key: _adKey,
                  adEventCallback: (event, args) {
                    if(event == UnifiedBannerAdEvent.onAdClosed || event == UnifiedBannerAdEvent.onNoAd) {
                      onClosed();
                    }
                  },
                ),
              ),
            );
          },),
          Expanded(
            child: ColoredBox(
              color: Colors.deepOrange,
              child: SizedBox.expand(
                child: Row(
                  children: <Widget>[
                    Text('广告位ID：'),
                    Expanded(
                      child: Text(widget.posId),
                    ),
                  ],
                ),
              ),
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
}