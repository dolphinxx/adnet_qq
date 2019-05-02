import 'package:flutter/material.dart' hide Banner;
import 'package:adnet_qq/adnet_qq.dart';

class UnifiedBannerAdDemo extends StatefulWidget {
  @override
  UnifiedBannerAdDemoState createState() => UnifiedBannerAdDemoState();
}

class UnifiedBannerAdDemoState extends State<UnifiedBannerAdDemo> {
  double adHeight;
  GlobalKey<UnifiedBannerAdState> _adKey = GlobalKey();

  TextEditingController _editingController;
  FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    this._editingController = TextEditingController(text: '4080052898050840');
    this._focusNode = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            height: adHeight??1,
            child: _editingController.text.length == 0 ? null : UnifiedBannerAd(_editingController.text, key: _adKey, onAdReceived: _onAdReceived,refreshOnCreate: true),
          ),
          Row(
            children: <Widget>[
              RaisedButton(
                onPressed: () => _adKey.currentState?.refreshAd(),
                child: Text('刷新广告'),
              ),
              RaisedButton(
                onPressed: () async {
                  await _adKey.currentState?.closeAd();
                  if(this.mounted) {
                    this.setState(() {adHeight = null;});
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
                child: TextField(
                  focusNode: _focusNode,
                  controller: _editingController,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onAdReceived(dynamic params) {
    if(this.mounted) {
      this.setState(() {
        adHeight = MediaQuery.of(context).size.width / 6.4;
      });
    }
  }
}