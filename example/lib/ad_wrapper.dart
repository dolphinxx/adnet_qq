import 'package:flutter/material.dart';

typedef AdBuilder = Widget Function(BuildContext context, VoidCallback onClosed, Key key);
class AdWidget extends StatefulWidget {
  final AdBuilder builder;
  final EdgeInsetsGeometry? margin;
  const AdWidget({Key? key, required this.builder, this.margin}) : super(key: key);

  @override
  _AdWidgetState createState() => _AdWidgetState();
}

class _AdWidgetState extends State<AdWidget> with SingleTickerProviderStateMixin {
  bool closed = false;
  final Key _adKey = GlobalKey();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 200))..value = 1.0;
    _animation = CurveTween(curve: Curves.fastOutSlowIn).animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(closed) {
      return const SizedBox.shrink();
    }
    Widget result = SizeTransition(
      sizeFactor: _animation,
      child: widget.builder(context, onClosed, _adKey),
    );
    if(widget.margin != null) {
      result = Padding(
        padding: widget.margin!,
        child: result,
      );
    }
    return result;
  }

  void onClosed() {
    _controller.reverse().then((_) {
      if(mounted) {
        setState(() {
          closed = true;
        });
      }
    });
  }
}