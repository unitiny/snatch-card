import 'package:flutter/material.dart';

const String UserToken =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJRCI6MywiZXhwIjoxNjg4NjEzMTY3LCJpc3MiOiJwcGVldyIsIm5iZiI6MTY4ODE4MTE2N30.7OB4yy3N9z1vO-s17LtKHuVMsLKfzjO72hlXdw7mpbQ";

class GameColor {
  static const Color theme = Color.fromRGBO(140, 178, 194, 1);

  // static const Color background = Color.fromRGBO(140, 178, 194, 1);
  static const Color green = Color.fromRGBO(151, 208, 145, 1);
  static const Color background1 = Color.fromRGBO(46, 73, 83, 0.33);
  static const Color background2 = Color.fromRGBO(112, 147, 163, 1);
  static const Color background3 = Color.fromRGBO(112, 147, 163, 0.33);
  static const Color border = Color.fromRGBO(240, 239, 238, 1);
  static const Color cancel = Color.fromRGBO(220, 178, 154, 1);
  static const Color dialog1 = Color.fromRGBO(46, 73, 83, 0.6);
  static const Color dialog2 = Color.fromRGBO(121, 138, 121, 1.0);
  static const Color dialog3 = Color.fromRGBO(0, 0, 0, 0);
  static const Color btn = Color.fromRGBO(183, 233, 253, 1.0);
  static const Color roomOwner = Color.fromRGBO(46, 73, 83, 1);
}

class Asset {
  static const String radio1 = "lib/assets/svg/radio1.svg";
  static const String radio2 = "lib/assets/svg/radio2.svg";

  static const String close = "lib/assets/svg/close-circle-fill.svg";
  static const String ready = "lib/assets/svg/check-fill.svg";

  static const String logo = "lib/assets/img/logo.png";
  static const String avatar = "lib/assets/img/avatar.png";
  static const String avatar1 = "lib/assets/img/gopher.png";

  static const String relax = "lib/assets/video/relax.mp3";
  static const String grab = "lib/assets/video/grab.wav";
  static const String background = "lib/assets/video/background.mp3";
}

// 服务端
// 1 增加卡
// 2 删除卡
// 4 更新卡
// 8 交换卡
class SpecialCardVal {
  static const String redBombCard = "炸弹卡";
  static const String yellowWildCard = "万能卡";
  static const String greenSwapCard = "交换卡";
  static const String blueModifyCard = "修改卡";
}

class GameStage {
  static const String deal = "发牌阶段";
  static const String bid = "抢牌阶段";
  static const String play = "出牌阶段";
  static const String end = "结算阶段";
}

enum CardCategory { common, special }

enum RoomState { wait, start, notExist}

enum UserState { inHome, inRoomReady, inRoom, inGame }

List<String> commonCardValue = ["1", "2", "3", "4", "5", "6"];
List<String> specialCardValue1 = ["A", "B", "C", "D"];
