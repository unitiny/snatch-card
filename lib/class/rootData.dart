import 'package:flutter/material.dart';

class RootData extends InheritedWidget {
  final Object data;

  RootData({required this.data, required Widget child}) : super(child: child);

  @override
  bool updateShouldNotify(RootData oldWidget) => oldWidget.data != data;

  static of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RootData>();
  }
}
