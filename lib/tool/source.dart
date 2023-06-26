import 'package:flutter/material.dart';

class GameColor {
  static const Color theme = Color.fromRGBO(140, 178, 194, 1);

  // static const Color background = Color.fromRGBO(140, 178, 194, 1);
  static const Color green = Color.fromRGBO(151, 208, 145, 1);
  static const Color background1 = Color.fromRGBO(46, 73, 83, 0.33);
  static const Color background2 = Color.fromRGBO(112, 147, 163, 1);
  static const Color border = Color.fromRGBO(240, 239, 238, 1);
  static const Color cancel = Color.fromRGBO(220, 178, 154, 1);
  static const Color dialog = Color.fromRGBO(46, 73, 83, 0.6);
}

class Source {
  static const String radio1 = "lib/assets/svg/radio1.svg";
  static const String radio2 = "lib/assets/svg/radio2.svg";

  static const String close = "lib/assets/svg/close-circle-fill.svg";
  static const String ready = "lib/assets/svg/check-fill.svg";

  static const String logo = "lib/assets/img/logo.png";
  static const String avatar = "lib/assets/img/avatar.png";
  static const String avatar1 = "lib/assets/img/gopher.png";
}

enum Category { common, special }

enum RoomState { wait, start }

enum UserState { inHome, inRoomReady, inRoom, inGame }

List<String> commonCardValue = ["1", "2", "3", "4", "5", "6"];
List<String> specialCardValue = ["A", "B", "C"];
