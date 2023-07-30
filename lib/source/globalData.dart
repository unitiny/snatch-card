import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/tool/component.dart';

class GlobalData {
  bool debug = false;
  GlobalKey<RuleState> windowKey = GlobalKey();

  User user(BuildContext context) {
    return Provider.of<User>(context, listen: false);
  }

  Room room(BuildContext context) {
    return Provider.of<Room>(context, listen: false);
  }

  UserWS userWS(BuildContext context) {
    return Provider.of<UserWS>(context, listen: false);
  }
}
