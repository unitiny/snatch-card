import 'package:flutter/cupertino.dart';

class MyRouter extends ChangeNotifier {
  int currentPage = 0;
  int showRuleNum = 0;
  List<Map<String, Object>> pages = [];

  MyRouter({this.pages = const []});

  clean() {
    currentPage = 0;
    showRuleNum = 0;
    pages = [];
  }
}