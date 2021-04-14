import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';
import 'config.dart';

class NativeExpressAdDemo extends StatefulWidget {
  NativeExpressAdDemo();

  @override
  NativeExpressAdDemoState createState() => NativeExpressAdDemoState();
}

class NativeExpressAdDemoState extends State<NativeExpressAdDemo> {
  double? adHeight;
  bool adRemoved = false;
  GlobalKey<NativeExpressAdState> _adKey = GlobalKey();
  List<String> events = [];

  late String posId;
  List<String> posIds = config['nativeExpressPosId'] as List<String>;

  @override
  void initState() {
    super.initState();
    posId = posIds.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    adHeight = null;
                    adRemoved = false;
                  });
                  _adKey.currentState?.refreshAd();
                },
                child: Text('刷新广告'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _adKey.currentState?.closeAd();
                  if(mounted) {
                    setState(() {
                      adRemoved = true;
                      adHeight = null;
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
                child: CupertinoPicker(
                  itemExtent: 42,
                  onSelectedItemChanged: (index) {
                    posId = posIds[index];
                    _adKey.currentState?.closeAd();
                    adHeight = null;
                    _adKey = GlobalKey();
                    if(mounted) {
                      setState(() {});
                    }
                  },
                  children: posIds.map((_) => ListTile(title: Text(_),)).toList(),
                ),
              ),
            ],
          ),
          Container(
            height: 30,
            color: Colors.blue,
          ),
          adRemoved ? Container() : Divider(),
          adRemoved ? Container() : Container(
            height: adHeight ?? 1,
            child: NativeExpressAd(posId, key: _adKey, requestCount: 5, adEventCallback: _adEventCallback,refreshOnCreate: true),
          ),
          Divider(),
          Container(
            height: 30,
            color: Colors.deepOrange,
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

  void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) async {
    events.insert(0, '${event.toString().split('.')[1]} ${arguments??""}');
    if(event == NativeExpressAdEvent.onLayout) {
      adHeight = MediaQuery.of(context).size.width * (arguments['height'] as double) / (arguments['width'] as double);
    } else if(event == NativeExpressAdEvent.onAdClosed) {
      // remove ad widget
      adRemoved = true;
    }
    if(mounted) {
      setState(() {});
    }
  }
}