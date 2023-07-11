import 'dart:math';
import 'dart:convert';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/class/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/globalData.dart';

double pageWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double pageHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

String token(BuildContext context) {
  return GlobalData().user(context).token ?? "";
}

int roomId(BuildContext context) {
  return GlobalData().room(context).roomId ?? 0;
}

int randId() {
  return DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000);
}

int randNum(int len) {
  int num = 1;
  for (int i = 0; i < len - 1; i++) {
    num *= 10;
  }
  return num + Random().nextInt((num * 10 - num));
}

String randString(String prefix) {
  int num = Random().nextInt(100);
  return "$prefix$num";
}

void printList<T>(List<T> arr) {
  String res = "";
  for (var val in arr) {
    res += "$val ";
  }
  print(res);
}

typedef equalWay<T> = bool Function(int i, T val);

void addNew<T>(List<T> arr, T val, {equalWay<T>? f}) {
  f ??= (int i, T val) => arr[i] == val; // 默认函数

  for (int i = 0; i < arr.length; i++) {
    if (f(i, val)) {
      return;
    }
  }
  arr.add(val);
}

T copy<T>(T source) {
  return json.decode(json.encode(source));
}

List<T> copyList<T>(List<T> arr) {
  List<T> res = [];
  for (var elem in arr) {
    res.add(copy<T>(elem));
  }
  return res;
}



