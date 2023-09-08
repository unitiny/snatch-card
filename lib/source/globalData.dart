import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/router.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/component/Rule.dart';

class GlobalData {
  bool debug = true;
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

  MyRouter router(BuildContext context) {
    return Provider.of<MyRouter>(context, listen: false);
  }

  void clean(BuildContext context) {
    Provider.of<User>(context, listen: false).clean();
    Provider.of<Room>(context, listen: false).clean();
    Provider.of<UserWS>(context, listen: false).reset();
    Provider.of<MyRouter>(context, listen: false).clean();
    return;
  }
}
