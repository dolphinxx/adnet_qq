import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';

class NativeExpressAdDemo extends StatefulWidget {
  final String posId;

  NativeExpressAdDemo(this.posId);

  @override
  NativeExpressAdDemoState createState() => NativeExpressAdDemoState();
}

class NativeExpressAdDemoState extends State<NativeExpressAdDemo> {
  double adHeight;
  bool adRemoved = false;
  GlobalKey<NativeExpressAdState> _adKey = GlobalKey();
  List<String> events = List();

  @override
  void initState() {
    super.initState();
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
                  if(this.mounted) {
                    this.setState(() {
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
                child: Text(widget.posId,),
              ),
            ],
          ),
          Container(
            height: 30,
            color: Colors.blue,
          ),
          adRemoved ? Container() : Divider(),
          adRemoved ? Container() : Container(
            height: adHeight == null ? 1 : adHeight,
            child: NativeExpressAd(widget.posId, key: _adKey, requestCount: 5, adEventCallback: _adEventCallback,refreshOnCreate: true),
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
      adHeight = MediaQuery.of(context).size.width * arguments['height'] / arguments['width'];
    } else if(event == NativeExpressAdEvent.onAdClosed) {
      // remove ad widget
      adRemoved = true;
    }
    if(this.mounted) {
      this.setState(() {
      });
    }
  }
}