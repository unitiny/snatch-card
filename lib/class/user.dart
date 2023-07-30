import 'package:flutter/cupertino.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/source/http.dart';

class User extends ChangeNotifier {
  int id = 0;
  String? userName;
  String? nickName;
  bool? gender;
  String? avatar;
  UserState? state;
  int? delay;
  String? token;

  User(
      {int? id,
        String? username,
        String? nickname,
        String? avatar,
        UserState? state,
        int? delay,
        String? token,
        bool? gender}) {
    this.id = id ?? randId();
    this.userName = username ?? randNum(3).toString();
    this.nickName = nickname ?? randString("user-");
    this.avatar = avatar ?? Asset.avatar1;
    this.state = state ?? UserState.inHome;
    this.delay = delay ?? 0;
    this.token = token ?? "";
    this.gender = gender ?? true;
  }

  update(
      {int? id,
        String? username,
        String? nickname,
        String? avatar,
        UserState? state,
        int? delay,
        String? token,
        bool? gender}) {
    this.id = id ?? this.id;
    this.userName = username ?? this.userName;
    this.nickName = nickname ?? this.nickName;
    this.avatar = avatar ?? this.avatar;
    this.state = state ?? this.state;
    this.delay = delay ?? this.delay;
    this.token = token ?? this.token;
    this.gender = gender ?? this.gender;
  }

  String image() {
    return "${API.fileHost}$avatar";
  }

  bool isLocalAvatar() {
    if (avatar == "/" || avatar == "") {
      avatar = Asset.avatar1;
    }
    if (avatar!.contains("lib/assets/")) {
      return true;
    }
    return false;
  }

  void setState(UserState state) {
    this.state = state;
    notifyListeners();
  }
}

// 直接放入userWS中，因此取消
// class AllUser extends ChangeNotifier {
//   List<User> users = [];
//
//   AllUser({required this.users});
// }
