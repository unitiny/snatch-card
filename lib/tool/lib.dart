import 'dart:math';
import 'package:flutter/material.dart';

double pageWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double pageHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

String randString(String prefix) {
  int num = Random().nextInt(100);
  return "$prefix$num";
}