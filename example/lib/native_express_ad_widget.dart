import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';
import 'config.dart';

class NativeExpressAdWidgetDemo extends StatefulWidget {
  NativeExpressAdWidgetDemo();

  @override
  NativeExpressAdWidgetDemoState createState() => NativeExpressAdWidgetDemoState();
}

class NativeExpressAdWidgetDemoState extends State<NativeExpressAdWidgetDemo> {
  double adHeight;
  bool adRemoved = false;
  final GlobalKey<NativeExpressAdState> _adKey = GlobalKey();
  List<String> events = [];

  String posId;

  @override
  void initState() {
    super.initState();
    posId = config['nativeExpressPosId'].first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  setState(() {
                    adHeight = null;
                    adRemoved = false;
                  });
                  _adKey.currentState?.refreshAd();
                },
                child: Text('刷新广告'),
              ),
              RaisedButton(
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
                child: Text(posId),
              ),
            ],
          ),
          Container(
            height: 30,
            color: Colors.deepOrange,
          ),
          Divider(),
          NativeExpressAdWidget(posId, adKey: _adKey, adEventCallback: _adEventCallback,),
          Divider(),
          Container(
            height: 30,
            color: Colors.amberAccent,
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
    if(mounted) {
      setState(() {});
    }
  }
}