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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body:ListView(
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
            height: 200,
            color: Colors.blue,
          ),
          adRemoved ? Container() : Divider(),
          adRemoved ? Container() : Container(
            height: adHeight == null ? 1 : adHeight,
            child: NativeExpressAd(widget.posId, key: _adKey, adEventCallback: _adEventCallback,refreshOnCreate: true),
          ),
          Divider(),
          Container(
            height: 200,
            color: Colors.deepOrange,
          ),
          NativeExpressItem('2000629911207832'),
          Divider(),
          Container(
            height: 200,
            color: Colors.amberAccent,
          ),
        ],
      ),
    );
  }

  void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) async {
    if(event == NativeExpressAdEvent.onLayout && this.mounted) {
//      print(_adKey.currentState.getSize());
//      dynamic size = await _adKey.currentState.getSize();
//      print(size);
      this.setState(() {
        // 根据选择的广告位模板尺寸计算，这里是1280x720
        adHeight = MediaQuery.of(context).size.width * arguments['height'] / arguments['width'];
      });
      return;
    }
    if(event == NativeExpressAdEvent.onAdClosed) {
      this.setState(() {
        // or remove ad widget
        adRemoved = true;
      });
    }
  }
}

class NativeExpressItem extends StatefulWidget {
  final String posId;

  NativeExpressItem(this.posId);

  @override
  NativeExpressItemState createState() => NativeExpressItemState();
}

class NativeExpressItemState extends State<NativeExpressItem> {
  bool _removed = false;
  double _height = 1.0;

 @override
 Widget build(BuildContext context) {
   return _removed ? Container() : Column(
     children: <Widget>[
       Divider(),
       Container(
         height: _height,
         child: NativeExpressAd(widget.posId, adEventCallback: _adEventCallback,refreshOnCreate: true,),
       ),
     ],
   );
  }

 void _adEventCallback(NativeExpressAdEvent event, dynamic arguments) async {
   if(event == NativeExpressAdEvent.onLayout && this.mounted) {
     this.setState(() {
       _height = MediaQuery.of(context).size.width * arguments['height'] / arguments['width'];
     });
     return;
   }
   if(event == NativeExpressAdEvent.onAdClosed) {
     this.setState(() {
       // or remove ad widget
       _removed = true;
     });
   }
 }
}