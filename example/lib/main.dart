import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:adnet_qq/adnet_qq.dart';
import 'unified_banner_ad.dart';
import 'native_express_ad.dart';
import 'native_express_ad_widget.dart';
import 'unified_interstitial_ad.dart';
import 'darkness.dart';

Map config = defaultTargetPlatform == TargetPlatform.iOS ? {
  'appId': '1105344611',
  'unifiedBannerPosId': '1080958885885321',
  'nativeExpressPosId': '5030722621265924',
  'nativeExpressPosId2':'1020922903364636',
  'unifiedInterstitialPosId': '1050652855580392',
  'unifiedInterstitialFullScreenPosId': '1050652855580392',
  'splashPosId': '9040714184494018',
  'splashBackgroundImage': 'SplashImage'
} : {
  'appId': '1101152570',
  'unifiedBannerPosId': '4080052898050840',
  'nativeExpressPosId': '7030020348049331',
  'nativeExpressPosId2':'2000629911207832',
  'unifiedInterstitialPosId': '3040652898151811',
  'unifiedInterstitialFullScreenPosId': '4080298282218338',
  'splashPosId': '8863364436303842593',
  'splashBackgroundImage': 'com.whaleread.flutter.plugin.adnet_qq_example:mipmap/splash_bg'
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    AdnetQqPlugin.config(appId: config['appId'], requestReadPhoneState: 0, requestAccessFineLocation: 0, adChannel: 1).then((_) => SplashAd(config['splashPosId'], backgroundImage: config['splashBackgroundImage'],).showAd());
  } on PlatformException {
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  ThemeMode _themeMode = ThemeMode.light;
  List<String> splashEvents = List();

  @override
  void initState() {
    super.initState();
    darknessNotifier.addListener(() {
      if(this.mounted) {
        setState(() {
          _themeMode = darknessNotifier.value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
                  return UnifiedBannerAdDemo(config['unifiedBannerPosId']);
                })),
                child: Text('横幅2.0'),
              ),
              RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
                  return NativeExpressAdDemo(config['nativeExpressPosId']);
                })),
                child: Text('原生模板'),
              ),
              RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
                  return NativeExpressAdWidgetDemo(config['nativeExpressPosId2']);
                })),
                child: Text('原生模板 widget'),
              ),
              RaisedButton(
                onPressed: () => navigatorKey.currentState.push(MaterialPageRoute(builder: (context) {
                  return UnifiedInterstitialAdDemo(config['unifiedInterstitialPosId'], config['unifiedInterstitialFullScreenPosId']);
                })),
                child: Text('插屏2.0'),
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