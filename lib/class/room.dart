import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class Room extends ChangeNotifier {
  int id = 0;
  int roomId = 0;
  String roomName = "";
  int round = 0;
  int totalNum = 0;
  int homeownerId = 0;
  String homeownerName = "";
  List<int>? playersId;
  RoomState state = RoomState.wait;

  Room(
      {this.id = 0,
      this.roomId = 0,
      this.roomName = "",
      this.round = 0,
      this.state = RoomState.wait,
      this.totalNum = 0,
      this.homeownerId = 0,
      this.homeownerName = "",
      this.playersId});

  Room.randRoom() {
    id = DateTime.now().microsecondsSinceEpoch;
    roomId = Random().nextInt(100);
    roomName = randString("room-");
    round = 1 + Random().nextInt(9);
    state = Random().nextInt(2) == 0 ? RoomState.wait : RoomState.start;
    homeownerId = Random().nextInt(1000);
    homeownerName = randString("user-");
    totalNum = 1 + Random().nextInt(5);
    playersId ??= [];

    for (int i = 0; i < Random().nextInt(totalNum); i++) {
      playersId?.add(Random().nextInt(1000));
    }
  }

  update(
      {id,
      roomId,
      roomName,
      round,
      state,
      totalNum,
      homeownerId,
      homeownerName,
      playersId}) {
    this.id = id ?? this.id;
    this.roomId = roomId ?? this.roomId;
    this.roomName = roomName ?? this.roomName;
    this.round = round ?? this.round;
    this.state = state ?? this.state;
    this.totalNum = totalNum ?? this.totalNum;
    this.homeownerId = homeownerId ?? this.homeownerId;
    this.homeownerName = homeownerName ?? this.homeownerName;

    this.playersId = playersId ?? this.playersId;
    notifyListeners();
  }
}
