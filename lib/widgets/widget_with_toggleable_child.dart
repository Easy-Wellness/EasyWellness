import 'package:flutter/material.dart';

/// The child is shown by default
class WidgetWithToggleableChild extends StatefulWidget {
  WidgetWithToggleableChild({
    Key? key,
    required this.builder,
  }) : super(key: key);

  final Widget Function(WidgetWithToggleableChildState) builder;

  @override
  WidgetWithToggleableChildState createState() =>
      WidgetWithToggleableChildState();
}

class WidgetWithToggleableChildState extends State<WidgetWithToggleableChild> {
  bool show = true;

  void toggleShow(bool b) => this.setState(() => show = b);

  @override
  Widget build(BuildContext context) {
    if (show)
      return widget.builder(this);
    else
      return Container();
  }
}
