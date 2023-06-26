import 'package:flutter/cupertino.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class User extends ChangeNotifier {
  int id = 0;
  String? name;
  String? avatar;
  UserState? state;

  User({int? id, String? name, String? avatar, UserState? state}) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch;
    this.name = name ?? randString("user-");
    this.avatar = avatar ?? Source.avatar1;
    this.state = state ?? UserState.inHome;
  }
}
