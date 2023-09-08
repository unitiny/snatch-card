import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class Game extends ChangeNotifier {
  int? id;
  int? roomId;
  int curRound = 0;
  int? totalRound;
  int? timer = 0;
  bool? showWindow = false;
  bool? showChat = false;
  String? curStage = GameStage.deal; // 阶段
  ValueNotifier<bool> listener = ValueNotifier(false);

  Game({this.id, this.roomId, this.totalRound}) {
    id ??= randId();
    roomId ??= Random().nextInt(100);
    totalRound ??= 3 + Random().nextInt(10);
  }

  getTimer() {
    timer = 3 + Random().nextInt(10);
    // timer = 1 + Random().nextInt(3);
  }

  nextStage(String stage) {
    curStage = stage;
    stage == GameStage.bid ? curRound++ : null;
    listener.value = !listener.value;
  }
}
