import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/page/game/scoreRank.dart';
import 'package:snatch_card/page/game/playCard.dart';
import 'package:snatch_card/class/game.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:audioplayers/audioplayers.dart';

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
  GlobalKey<RuleState> windowKey = GlobalKey();

  // 都以userId为key
  Map<int, User> userMap = {};
  Map<int, UserCards> cardMap = {};
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
              GlobalData().user(context).state = UserState.inHome;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PageRouter.Router(
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

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Room room = GlobalData().room(context);
    room.round != 0 ? game.totalRound = room.round : null;
    game.roomId = room.roomId;
    game.getTimer();

    video(player, Asset.relax, isloop: true, volume: 0.8);
    globalData = {
      "game": game,
      "userMap": userMap,
      "cardMap": cardMap,
      "dialogAction": dialogAction
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
            game.showWindow! ? Window() : Container(),
            Rule(key: windowKey)
          ],
        )),
        floatingActionButton: OtherOperators(
            callback: dialogAction,
            icon: game.showWindow! ? Icons.close : Icons.games),
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
                          builder: (context) => const PageRouter.Router(
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
        child: Column(children: [
          const Expanded(flex: 40, child: OtherPlayers()),
          const Expanded(flex: 60, child: SnatchCard()),
          Expanded(
              flex: 15,
              child: Selector<UserWS, UserWS>(
                  shouldRebuild: (pre, next) =>
                      next.isNotify(ServiceType.gameStateResponseType, id: 1) ||
                      next.isNotify(ServiceType.useSpecialCardResponseType,
                          id: 1),
                  selector: (context, provider) => provider,
                  builder: (context, userWS, child) {
                    return PlayArea(
                        user: userWS.user,
                        userCards: userWS.store["userCardsMap"]
                                ?[userWS.user.id] ??
                            UserCards(userId: userWS.user.id));
                  })),
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
  VoidCallback listener2 = () {};
  UserWS userWS = UserWS();

  void showToast() {
    if (userWS.isNotify(ServiceType.msgResponseType) ||
        userWS.isNotify(ServiceType.useSpecialCardResponseType, id: 3)) {
      if (userWS.store["tip"] != null && userWS.store["tip"] != "") {
        MyDialog().lightTip(context, userWS.store["tip"], display: 1000);
      }
    }
  }

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
    listener = showToast;
    listener2 = gameOver;
    userWS.addListener(listener);
    userWS.addListener(listener2);
  }

  @override
  void dispose() {
    userWS.removeListener(listener);
    userWS.removeListener(listener2);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class OtherPlayers extends StatefulWidget {
  const OtherPlayers({super.key});

  @override
  State<OtherPlayers> createState() => _OtherPlayersState();
}

class _OtherPlayersState extends State<OtherPlayers> {
  List<PlayArea> _initElements() {
    User user = GlobalData().user(context);
    UserWS userWS = GlobalData().userWS(context);

    List<User> userList = userWS.userList
        .where((element) =>
            element.id != user.id && element.userName != user.userName)
        .toList();

    List<PlayArea> list = [];
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

class PlayArea extends StatefulWidget {
  const PlayArea({super.key, required this.user, required this.userCards});

  final User user;
  final UserCards userCards;

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  List<Widget> _initElements() {
    List<Widget> list = [];
    for (var elem in widget.userCards.cards) {
      if (elem.category == CardCategory.special) {
        continue;
      }
      list.add(Column(children: [
        CardDom(
          card: elem,
        ),
        const SizedBox(height: 10)
      ]));
    }
    return list;
  }

  List<GameCard.Card> specialCard() {
    return widget.userCards.cards
        .where((element) => element.category == CardCategory.special)
        .toList();
  }

  void record() {
    // 记录user和card到全局变量里
    RootData.of(context)?.data["userMap"][widget.user.id] = widget.user;
    RootData.of(context)?.data["cardMap"][widget.user.id] = widget.userCards;
    if (GlobalData().debug) {
      printCard();
    }
  }

  void printCard() {
    print(widget.user.id);
    print("---------");
    widget.userCards.cards.forEach((element) {
      print("${element.id} - ${element.commonVal} - ${element.specialVal}");
    });
  }

  @override
  void initState() {
    super.initState();
    widget.userCards.userId = widget.user.id;
  }

  @override
  Widget build(BuildContext context) {
    record();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PlayerAvatar(user: widget.user, specialCard: specialCard()),
            const SizedBox(
              width: 10,
            ),
            ..._initElements(),
          ],
        ),
        Selector<UserWS, UserWS>(
            shouldRebuild: (pre, next) =>
                next.isNotify(ServiceType.scoreRankResponseType,
                    id: widget.user.id) ||
                next.isNotify(ServiceType.gameStateResponseType,
                    id: 10 + widget.user.id),
            // 4 + widget.user.id 防止用户id和其余组件id重复
            selector: (context, provider) => provider,
            builder: (context, userWS, child) {
              return SizedBox(
                  width: 70,
                  height: 60,
                  child: Center(
                      child: Text(
                    userWS.store["score"]?[widget.user.id] ?? "0",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.red),
                  )));
            }),
      ],
    );
  }
}

class PlayerAvatar extends StatefulWidget {
  const PlayerAvatar({super.key, required this.user, this.specialCard});

  final User user;
  final List<GameCard.Card>? specialCard;

  @override
  State<PlayerAvatar> createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> {
  List<bool> hasSpecial = [false, false, false, false];

  void getSpecial() {
    reset();
    if (widget.specialCard != null) {
      for (var card in widget.specialCard!) {
        switch (card.specialVal!) {
          case SpecialCardVal.redBombCard:
            hasSpecial[0] = true;
            break;
          case SpecialCardVal.yellowWildCard:
            hasSpecial[1] = true;
            break;
          case SpecialCardVal.greenSwapCard:
            hasSpecial[2] = true;
            break;
          case SpecialCardVal.blueModifyCard:
            hasSpecial[3] = true;
        }
      }
    }
  }

  void reset() {
    hasSpecial = [false, false, false, false];
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    getSpecial();
    return SizedBox(
        width: 70,
        height: 100,
        child: Column(
          children: [
            ClipOval(
              child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: hasSpecial[0]
                          ? const BorderSide(color: Colors.red, width: 7)
                          : const BorderSide(
                              color: GameColor.background2, width: 7),
                      bottom: hasSpecial[1]
                          ? const BorderSide(color: Colors.yellow, width: 7)
                          : const BorderSide(
                              color: GameColor.background2, width: 7),
                      left: hasSpecial[2]
                          ? const BorderSide(color: Colors.green, width: 7)
                          : const BorderSide(
                              color: GameColor.background2, width: 7),
                      right: hasSpecial[3]
                          ? const BorderSide(color: Colors.blue, width: 7)
                          : const BorderSide(
                              color: GameColor.background2, width: 7),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.black),
                    ),
                    child: const ClipOval(
                      child: UserAvatar(size: 40),
                    ),
                  )),
            ),
            Text(widget.user.nickName!,
                style: const TextStyle(overflow: TextOverflow.ellipsis))
          ],
        ));
  }
}

class CardDom extends StatefulWidget {
  const CardDom({super.key, required this.card});

  final GameCard.Card card;

  @override
  State<CardDom> createState() => _CardDomState();
}

class _CardDomState extends State<CardDom> {
  @override
  Widget build(BuildContext context) {
    if (widget.card.hasOwner!) {
      return const SizedBox(width: 45, height: 60);
    }
    return Container(
        width: 45,
        height: 60,
        decoration: BoxDecoration(
            color: widget.card.category == CardCategory.common
                ? Colors.white
                : widget.card.color(),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 1, color: Colors.black)),
        child: Center(
            child: widget.card.category == CardCategory.common
                ? Text(
                    widget.card.commonVal!,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  )
                : Icon(widget.card.icon())));
  }
}
