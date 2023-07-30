// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snatch_card/main.dart';

void main() async {
  var a = [1,2];

  await test1();
  print("object222");
  await Future.delayed(const Duration(milliseconds: 500), () {});

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {});
}

Future test1() async {
  int a = 0;
  while (true) {
    await Future.delayed(const Duration(milliseconds: 500), () {
      a++;
    });
    if (a == 5) {
      print("object1111111");
      break;
    }
  }
  print("object");
}
