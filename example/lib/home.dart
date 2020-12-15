import 'package:flutter/material.dart';
import 'package:adnet_qq/adnet_qq.dart';
import 'unified_banner_ad.dart';
import 'native_express_ad.dart';
import 'native_express_ad_widget.dart';
import 'unified_interstitial_ad.dart';
import 'config.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<String> splashEvents = List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return UnifiedBannerAdDemo(config['unifiedBannerPosId']);
              })),
              child: Text('横幅2.0'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NativeExpressAdDemo(config['nativeExpressPosId']);
              })),
              child: Text('原生模板'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NativeExpressAdWidgetDemo(config['nativeExpressPosId2']);
              })),
              child: Text('原生模板 widget'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return UnifiedInterstitialAdDemo(config['unifiedInterstitialPosId'], config['unifiedInterstitialFullScreenPosId']);
              })),
              child: Text('插屏2.0'),
            ),
            RaisedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/splash'),
              child: Text('Splash页'),
            ),
            RaisedButton(
              onPressed: () => SplashAd(config['splashPosId'], backgroundImage: config['splashBackgroundImage'], adEventCallback: _splashAdEventCallback).showAd(),
              child: Text('开屏+背景图'),
            ),
            RaisedButton(
              onPressed: () => SplashAd(config['splashPosId'], backgroundColor: Colors.pink.value, adEventCallback: _splashAdEventCallback).showAd(),
              child: Text('开屏+背景色'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: splashEvents.length,
                itemBuilder: (context, index) {
                  return Text(splashEvents[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _splashAdEventCallback(SplashAdEvent event, dynamic arguments) async {
    splashEvents.insert(0, '${event.toString().split('.')[1]} ${arguments??""}');
    if(this.mounted) {
      this.setState(() {
      });
    }
  }
}
