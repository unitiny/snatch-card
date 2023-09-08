import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/page/game/chat.dart';
import 'package:snatch_card/page/game/scoreRank.dart';
import 'package:snatch_card/page/game/playCard.dart';
import 'package:snatch_card/page/game/component/PlayArea.dart';
import 'package:snatch_card/page/game/component/Cardom.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/class/game.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:audioplayers/audioplayers.dart';
import 'package:snatch_card/component/Rule.dart';
import 'package:snatch_card/component/DraggableFab.dart';
import 'package:snatch_card/component/IconText.dart';
import 'package:snatch_card/component/OtherOperators.dart';
import 'package:snatch_card/component/ShowToast.dart';

Game TheGame(BuildContext context) {
  return RootData.of(context)?.data["game"];
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePage();
}

class _GamePage extends State<GamePage> {
  Game game = Game();
  AudioPlayer player = AudioPlayer();

  // 通过key调用子组件方法
  GlobalKey<RuleState> windowKey = GlobalKey();

  // 都以userId为key
  Map<int, User> userMap = {};
  Map<int, UserCards> cardMap = {};
  Map<int, Offset> userPositionMap = {};
  Map<String, Object> globalData = {};

  AppBar MyAppBar() {
    return AppBar(
      backgroundColor: GameColor.theme,
      title: const Text("Snatch Card"),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: '0',
              child: Text('游戏规则'),
            ),
            const PopupMenuItem(
              value: '1',
              child: Text('退出房间'),
            ),
          ],
          onSelected: (value) {
            if (value == '0') {
              windowKey.currentState!.tap();
            } else if (value == '1') {
              UserWS userWS = GlobalData().userWS(context);
              userWS.clean();
              setUseState(context, UserState.inRoom);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PageRouter.RouterPage(
                      pageIndex: 0,
                    ),
                  ),
                  (route) => false);
            }
          },
          icon: const Icon(Icons.keyboard_control_rounded, size: 35),
        ),
      ],
    );
  }

  void dialogAction() {
    setState(() {
      game.showWindow = !game.showWindow!;
    });
  }

  void changeChatShow() {
    setState(() {
      game.showChat = !game.showChat!;
    });
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 主动获取信息渲染游戏
    GlobalData().userWS(context).getGameState({});

    Room room = GlobalData().room(context);
    room.round != 0 ? game.totalRound = room.round : null;
    game.roomId = room.roomId;
    game.getTimer();

    video(player, Asset.relax, isloop: true, volume: 0.8);
    globalData = {
      "game": game,
      "userMap": userMap,
      "cardMap": cardMap,
      "userPositionMap": userPositionMap,
      "dialogAction": dialogAction,
      "changeChatShow": changeChatShow
    };
  }

  @override
  Widget build(BuildContext context) {
    setUseState(context, UserState.inGame);
    return RootData(
      data: globalData,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyAppBar(),
        body: Center(
            child: Stack(
          children: [
            Container(
                width: double.infinity,
                height: double.infinity,
                color: GameColor.theme,
                child: const Column(children: [
                  Expanded(flex: 8, child: Header()),
                  Expanded(flex: 80, child: Body()),
                  Expanded(flex: 1, child: Footer()),
                ])),
            const ShowChatMsg(),
            game.showChat! ? ChatTool() : Container(),
            game.showWindow! ? Window() : Container(),
            Rule(key: windowKey)
          ],
        )),
        floatingActionButton: DraggableFab(OtherOperators(
            callback: dialogAction,
            icon: game.showWindow! ? Icons.close : Icons.games)),
      ),
    );
  }
}

class Window extends StatefulWidget {
  const Window({super.key});

  @override
  State<Window> createState() => _WindowState();
}

class _WindowState extends State<Window> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context),
      height: pageHeight(context),
      color: GameColor.background3,
      child: TheGame(context).curStage != GameStage.end
          ? const ControllerDialog()
          : const ScoreRankDialog(),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(5),
      color: GameColor.background1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (GlobalData().debug) {
                    GlobalData().userWS(context).clean();
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PageRouter.RouterPage(
                            pageIndex: 0,
                          ),
                        ),
                        (route) => false);
                  }
                },
                child: const IconText(
                  icon: Icon(Icons.play_arrow, color: Colors.white),
                  text: "阶段：",
                  space: 8,
                ),
              ),
              Selector<UserWS, UserWS>(
                  shouldRebuild: (pre, next) =>
                      next.isNotify(ServiceType.grabCardRoundResponseType,
                          id: 2) ||
                      next.isNotify(ServiceType.specialCardRoundResponseType,
                          id: 2),
                  selector: (context, provider) => provider,
                  builder: (context, userWS, child) {
                    var curStage = GameStage.bid;
                    if (userWS.store["grabCardRoundInfo"] == null &&
                        userWS.store["specialCardRoundInfo"] != null) {
                      curStage = GameStage.play;
                    }
                    return Text(
                      curStage,
                      style: TextStyle(
                          fontSize: 18,
                          color: curStage == GameStage.bid
                              ? Colors.red
                              : Colors.purple),
                    );
                  }),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (GlobalData().debug) {
                    Game game = TheGame(context);
                    game.curStage = GameStage.end;
                    game.listener.value = !game.listener.value;
                    RootData.of(context)?.data["dialogAction"]();
                  }
                },
                child: const IconText(
                  icon: Icon(Icons.settings, color: Colors.white),
                  text: "回合数：",
                  space: 8,
                ),
              ),
              Selector<UserWS, UserWS>(
                  shouldRebuild: (pre, next) =>
                      next.isNotify(ServiceType.gameStateResponseType, id: 4),
                  selector: (context, provider) => provider,
                  builder: (context, userWS, child) {
                    return Text(
                      userWS.store["gameCurCount"] != null
                          ? "${userWS.store["gameCurCount"]}/${userWS.store["gameCount"]}"
                          : "${TheGame(context).curRound}/${TheGame(context).totalRound}",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    );
                  }),
            ],
          )
        ],
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: const Column(children: [
          Expanded(flex: 40, child: OtherPlayers()),
          Expanded(flex: 60, child: SnatchCard()),
          Expanded(flex: 16, child: Self()),
          Expanded(flex: 4, child: Operations())
        ]));
  }
}

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  VoidCallback listener = () {};
  UserWS userWS = UserWS();

  void gameOver() {
    if (userWS.isNotify(ServiceType.gameOverResponseType)) {
      if (userWS.store["gameOver"] != null && userWS.store["gameOver"] != "") {
        Game game = TheGame(context);
        game.curStage = GameStage.end;
        game.listener.value = !game.listener.value;
        RootData.of(context)?.data["dialogAction"]();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userWS = GlobalData().userWS(context);
    listener = gameOver;
    userWS.addListener(listener);
  }

  @override
  void dispose() {
    userWS.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Stack(children: [ShowToast(msgOrigin: 1, display: 1000)]);
  }
}

class OtherPlayers extends StatefulWidget {
  const OtherPlayers({super.key});

  @override
  State<OtherPlayers> createState() => _OtherPlayersState();
}

class _OtherPlayersState extends State<OtherPlayers> {
  List<Widget> _initElements() {
    User user = GlobalData().user(context);
    UserWS userWS = GlobalData().userWS(context);

    List<User> userList = userWS.userList
        .where((element) =>
            element.id != user.id && element.userName != user.userName)
        .toList();

    List<Widget> list = [];
    for (var elem in userList) {
      list.add(PlayArea(
          user: elem,
          userCards: userWS.store["userCardsMap"]?[elem.id] ??
              UserCards(userId: elem.id)));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<UserWS, UserWS>(
        shouldRebuild: (pre, next) =>
            next.isNotify(ServiceType.gameStateResponseType, id: 2) ||
            next.isNotify(ServiceType.useSpecialCardResponseType, id: 2),
        selector: (context, provider) => provider,
        builder: (context, userWS, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _initElements(),
          );
        });
  }
}

class SnatchCard extends StatefulWidget {
  const SnatchCard({super.key});

  @override
  State<SnatchCard> createState() => _SnatchCardState();
}

class _SnatchCardState extends State<SnatchCard> {
  int second = 1;
  Timer? timer;
  Game game = Game();
  VoidCallback listener = () {};
  UserWS userWS = UserWS();

  // 局部刷新组件,原理是将要刷新的组件抽离成子组件，
  // 然后调用子组件的setState方法来触发局部更新
  StateSetter? timeState;

  List<Widget> _initElements(List<GameCard.Card> cards) {
    if (GlobalData().debug) {
      // UserCards userCards = UserCards(userId: 0);
      // userCards.randomCards(12);
      // cards = userCards.cards;
    }

    List<Widget> list = [];
    for (var elem in cards) {
      list.add(GestureDetector(
          onTap: () {
            if (elem.hasOwner!) {
              return;
            }
            AudioPlayer grab = AudioPlayer();
            video(grab, Asset.grab, volume: 0.06);
            GlobalData().userWS(context).grabCard({"cardID": elem.id});
          },
          child: Center(child: CardDom(card: elem))));
    }
    return list;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      second--;
      timeState!(() {});
      if (second == 0) {
        timer.cancel();
      }
    });
  }

  void updateTime() {
    if (userWS.isNotify(ServiceType.grabCardRoundResponseType) ||
        userWS.isNotify(ServiceType.specialCardRoundResponseType)) {
      timer?.cancel();
      second = 1;
      if (userWS.store["grabCardRoundInfo"] == null &&
          userWS.store["specialCardRoundInfo"] != null) {
        second = userWS.store["specialCardRoundInfo"];
      } else if (userWS.store["grabCardRoundInfo"] != null &&
          userWS.store["specialCardRoundInfo"] == null) {
        second = userWS.store["grabCardRoundInfo"];
      }
      startTimer();
      game.nextStage(userWS.store["curStage"]);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    userWS.removeListener(listener);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    userWS = GlobalData().userWS(context);
    listener = updateTime;
    userWS.addListener(listener);

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    game = TheGame(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const IconText(
              icon: Icon(Icons.punch_clock, color: Colors.black),
              space: 8,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              timeState = setState;
              return Text(
                "${second}s",
                style: const TextStyle(fontSize: 20, color: Colors.black),
              );
            })
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          decoration: const BoxDecoration(
              color: GameColor.background1,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Selector<UserWS, UserWS>(
              shouldRebuild: (pre, next) =>
                  next.isNotify(ServiceType.gameStateResponseType, id: 3),
              selector: (context, provider) => provider,
              builder: (context, userWS, child) {
                return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    double aspectRatio = 1.0; // 默认值
                    if (constraints.maxWidth > 0 && constraints.maxHeight > 0) {
                      var width = constraints.maxWidth / 4;
                      var height = constraints.maxHeight / 3;
                      aspectRatio = width / height;
                    }
                    return GridView.count(
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                      crossAxisCount: 4,
                      childAspectRatio: aspectRatio,
                      children: _initElements(userWS.store["randCards"] ?? []),
                    );
                  },
                );
              }),
        ))
      ],
    );
  }
}

class Self extends StatefulWidget {
  const Self({super.key});

  @override
  State<Self> createState() => _SelfState();
}

class _SelfState extends State<Self> {
  @override
  Widget build(BuildContext context) {
    return Selector<UserWS, UserWS>(
        shouldRebuild: (pre, next) =>
            next.isNotify(ServiceType.gameStateResponseType, id: 1) ||
            next.isNotify(ServiceType.useSpecialCardResponseType, id: 1),
        selector: (context, provider) => provider,
        builder: (context, userWS, child) {
          return Column(children: [
            PlayArea(
                user: userWS.user,
                userCards: userWS.store["userCardsMap"]?[userWS.user.id] ??
                    UserCards(userId: userWS.user.id))
          ]);
        });
  }
}

class Operations extends StatefulWidget {
  const Operations({super.key});

  @override
  State<Operations> createState() => _OperationsState();
}

class _OperationsState extends State<Operations> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            RootData.of(context)?.data["changeChatShow"]();
          },
          child: const Icon(Icons.chat, color: GameColor.btn2),
        )
      ],
    );
  }
}
