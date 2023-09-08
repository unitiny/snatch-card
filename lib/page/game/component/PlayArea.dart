import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/page/game/component/Cardom.dart';
import 'package:snatch_card/component/UserAvatar.dart';

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
            PositionTracker(userid: widget.user.id),
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
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    child: ClipOval(
                      child: UserAvatar(user: widget.user, size: 40),
                    ),
                  )),
            ),
            Text(widget.user.nickName!,
                style: const TextStyle(overflow: TextOverflow.ellipsis))
          ],
        ));
  }
}

class PositionTracker extends StatefulWidget {
  PositionTracker({super.key, required this.userid});

  final int userid;

  @override
  _PositionTrackerState createState() => _PositionTrackerState();
}

class _PositionTrackerState extends State<PositionTracker> {
  late OverlayEntry _overlayEntry;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateComponentPosition();
    });
  }

  void _updateComponentPosition() {
    RenderBox? componentBox = context.findRenderObject() as RenderBox?;
    if (componentBox != null) {
      Offset componentPosition = componentBox.localToGlobal(Offset.zero);
      RootData.of(context)?.data["userPositionMap"][widget.userid] =
          componentPosition;
    }
  }

  void _showOverlay(Offset componentPosition) {
    print(
        'Component Position: (${componentPosition.dx}, ${componentPosition.dy})');
    // _overlayEntry = OverlayEntry(
    //   builder: (context) {
    //     return Positioned(
    //       left: componentPosition.dx,
    //       top: componentPosition.dy,
    //       child: Container(
    //         width: 10,
    //         height: 10,
    //         color: Colors.blue.withOpacity(0.5),
    //         child: Center(
    //           child: Text('Component Position: (${componentPosition.dx}, ${componentPosition.dy})'),
    //         ),
    //       ),
    //     );
    //   },
    // );
    //
    // Overlay.of(context)?.insert(_overlayEntry);
  }

  @override
  void dispose() {
    // _overlayEntry.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
