import 'package:flutter/material.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/page/game/game.dart';

class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame> {
  UserWS userWS = UserWS();
  void Function() listener = () {};

  void start() {
    if ((userWS.store["startGame"] != null &&
        userWS.store["startGame"] == true) ||
        userWS.isNotify(ServiceType.beginGameResponseType)) {
      GlobalData().room(context).state = RoomState.start;
      GlobalData().user(context).serverState = UserState.inGame;
      setUseState(context, UserState.inGame);

      userWS.store["startGame"] = false;
      userWS.store = {};
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GamePage(),
          ),
              (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    listener = start;
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
