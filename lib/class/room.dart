import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class Room extends ChangeNotifier {
  int id = 0;
  int roomId = 0;
  String roomName = "";
  int round = 0;
  int totalNum = 0;
  int curNum = 0;
  int roomOwnerId = 0;
  String roomOwnerName = "";
  List<int> playersId = [];
  List<Map<String, String>> chatRecord = [];
  RoomState state = RoomState.wait;

  Room(
      {this.id = 0,
      this.roomId = 0,
      this.roomName = "",
      this.round = 0,
      this.state = RoomState.wait,
      this.totalNum = 0,
      this.curNum = 0,
      this.roomOwnerId = 0,
      this.roomOwnerName = "",
      required this.playersId});

  Room.randRoom() {
    id = randId();
    roomId = Random().nextInt(100);
    roomName = randString("room-");
    round = 1 + Random().nextInt(9);
    state = Random().nextInt(2) == 0 ? RoomState.wait : RoomState.start;
    roomOwnerId = Random().nextInt(1000);
    roomOwnerName = randString("user-");
    totalNum = 1 + Random().nextInt(5);

    for (int i = 0; i < Random().nextInt(totalNum); i++) {
      playersId.add(Random().nextInt(1000));
    }
    curNum = playersId.length;
  }

  update(
      {id,
      roomId,
      roomName,
      round,
      state,
      totalNum,
      curNum,
      roomOwnerId,
      roomOwnerName,
      playersId}) {
    this.id = id ?? this.id;
    this.roomId = roomId ?? this.roomId;
    this.roomName = roomName ?? this.roomName;
    this.round = round ?? this.round;
    this.state = state ?? this.state;
    this.totalNum = totalNum ?? this.totalNum;
    this.roomOwnerId = roomOwnerId ?? this.roomOwnerId;
    this.roomOwnerName = roomOwnerName ?? this.roomOwnerName;
    this.playersId = playersId ?? this.playersId;
    this.curNum = curNum ?? this.curNum;

    SchedulerBinding.instance.endOfFrame.then((value){
      notifyListeners();
    });
  }

  clean() {
    id = 0;
    roomId = 0;
    roomName = "";
    round = 0;
    state = RoomState.notExist;
    totalNum = 0;
    roomOwnerId = 0;
    roomOwnerName = "";
    playersId = [];
    curNum = 0;
  }

  randRoom(int ownerId) {
    id = randNum(3);
    roomId = randNum(3);
    roomName = randString("room");
    round = 10 + Random().nextInt(5);
    totalNum = 1;
    roomOwnerId = ownerId;
    curNum = 1;
  }
}
