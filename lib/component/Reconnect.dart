import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/page/game/game.dart';

class Reconnect extends StatefulWidget {
  const Reconnect({super.key});

  @override
  State<Reconnect> createState() => _ReconnectState();
}

class _ReconnectState extends State<Reconnect> {
  UserWS userWS = UserWS();
  void Function() listener = () {};

  void reconnect() {
    if (userWS.store["state"] != null &&
        userWS.isNotify(ServiceType.stateInfoResponseType)) {
      // 0房间中 1游戏中
      if (userWS.store["state"] == 0) {
        GlobalData().room(context).update(state: RoomState.wait);
        GlobalData().user(context).serverState = UserState.inRoom;
        setUseState(context, UserState.inRoomReady);
      } else if (userWS.store["state"] == 1) {
        GlobalData().user(context).serverState = UserState.inGame;
        GlobalData().room(context).update(state: RoomState.start);
        GlobalData().userWS(context).clean(); // 清理之前堆积的信息

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const GamePage(),
            ),
                (route) => false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    listener = reconnect;
    // 监听游戏开始跳转
    userWS = GlobalData().userWS(context);
    userWS.addListener(listener);
  }

  @override
  void dispose() {
    userWS.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
