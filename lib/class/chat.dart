import 'package:flutter/cupertino.dart';

class Chat {
  int id;
  int userId;
  String nickName;
  String image;
  String time;
  String content;

  Chat(
      this.id, this.userId, this.nickName, this.image, this.time, this.content);
}

class ChatList  extends ChangeNotifier {
  List<Chat> list = [];

  void add(Chat c) {
    list.add(c);
    notifyListeners();
  }

  void clean() {
    list = [];
  }
}