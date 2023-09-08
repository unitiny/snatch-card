import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/component/BackBtn.dart';
import 'package:snatch_card/component/MyDialog.dart';
import 'package:snatch_card/component/UserAvatar.dart';
import 'package:snatch_card/page/game/component/Cardom.dart';

typedef TapEvent = void Function(int nextPage);

class ControllerDialog extends StatefulWidget {
  const ControllerDialog({super.key});

  @override
  State<ControllerDialog> createState() => _ControllerDialogState();
}

class _ControllerDialogState extends State<ControllerDialog> {
  List<Widget> page = [];
  Map<String, Object> pageData = {
    "dialogIndex": 0,
    "specialCardVal": "",
    "userId": 0,
    "sourceCard": GameCard.Card(),
    "sourceCard1": GameCard.Card(),
    "targetCard": GameCard.Card()
  };

  UserCards getSelfCards() {
    int userId = GlobalData().user(context).id;
    return RootData.of(context)?.data["cardMap"][userId];
  }

  Widget content() {
    return page[pageData["dialogIndex"] as int];
  }

  void changePage(int page) {
    setState(() {
      if (page < 0) {
        int num = pageData["dialogIndex"] as int;
        pageData["dialogIndex"] = num + page;
        return;
      }
      pageData["dialogIndex"] = page;
    });
  }

  @override
  void initState() {
    super.initState();
    page = [
      ChooseSpecialCard(onTap: changePage),
      ChoosePlayer(onTap: changePage),
      ChooseCommonCard(onTap: changePage)
    ];
    pageData["getSelfCards"] = getSelfCards ?? UserCards(userId: 0);
  }

  @override
  Widget build(BuildContext context) {
    pageData["dialogAction"] = RootData.of(context)?.data["dialogAction"];
    pageData["cardMap"] = RootData.of(context)?.data["cardMap"];

    return RootData(
        data: pageData,
        child: Center(
          child: Container(
              width: pageWidth(context) * 0.85,
              height: pageHeight(context) * 0.7,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              decoration: BoxDecoration(
                  color: GameColor.background2,
                  border: Border.all(width: 2, color: Colors.black45),
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: content()),
        ));
  }
}

class ChooseSpecialCard extends StatefulWidget {
  const ChooseSpecialCard({super.key, this.onTap});

  final TapEvent? onTap;

  @override
  State<ChooseSpecialCard> createState() => _ChooseSpecialCardState();
}

class _ChooseSpecialCardState extends State<ChooseSpecialCard> {
  UserCards userCards = UserCards(userId: 0);
  List<GameCard.Card> allSpecialCard = [
    GameCard.Card(
        category: CardCategory.special, specialVal: SpecialCardVal.redBombCard),
    GameCard.Card(
        category: CardCategory.special,
        specialVal: SpecialCardVal.yellowWildCard),
    GameCard.Card(
        category: CardCategory.special,
        specialVal: SpecialCardVal.greenSwapCard),
    GameCard.Card(
        category: CardCategory.special,
        specialVal: SpecialCardVal.blueModifyCard),
  ];

  List<Widget> _initElements() {
    List<Widget> list = [];
    List<int> count = [0, 0, 0, 0];
    for (var elem in userCards.getSpecialCards()) {
      switch (elem.specialVal!) {
        case SpecialCardVal.redBombCard:
          count[0]++;
          break;
        case SpecialCardVal.yellowWildCard:
          count[1]++;
          break;
        case SpecialCardVal.greenSwapCard:
          count[2]++;
          break;
        case SpecialCardVal.blueModifyCard:
          count[3]++;
      }
    }

    for (int i = 0; i < count.length; i++) {
      list.add(GestureDetector(
          onTap: () {
            if (count[i] == 0) {
              MyDialog().lightTip(context, "没有该特殊卡");
              return;
            }
            if (widget.onTap != null) {
              RootData.of(context)?.data["specialCardVal"] =
                  allSpecialCard[i].specialVal;
              if (allSpecialCard[i].specialVal ==
                  SpecialCardVal.yellowWildCard) {
                widget.onTap!(2); // 只能用于自己，直接跳到选卡界面
              } else {
                widget.onTap!(1);
              }
            }
          },
          child: Column(
            children: [
              CardDom(card: allSpecialCard[i]),
              Text(
                "${allSpecialCard[i].specialVal}*${count[i]}",
                style: const TextStyle(color: Colors.black, fontSize: 16),
              )
            ],
          )));
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    userCards.randSpecialCards(4 + Random().nextInt(5));
  }

  @override
  Widget build(BuildContext context) {
    userCards = RootData.of(context)?.data["getSelfCards"]();

    return Center(
        child: Column(
      children: [
        const Expanded(
            flex: 2,
            child: Text(
              "请选择要使用的特殊卡",
              style: TextStyle(color: Colors.white, fontSize: 20),
            )),
        const SizedBox(height: 10),
        Expanded(
            flex: 8,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                double aspectRatio = 1.0; // 默认值
                if (constraints.maxWidth > 0 && constraints.maxHeight > 0) {
                  var width = constraints.maxWidth;
                  var height = constraints.maxHeight;
                  aspectRatio = width / height;
                }
                return GestureDetector(
                  child: GridView.count(
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 10,
                    crossAxisCount: 2,
                    childAspectRatio: aspectRatio,
                    children: _initElements(),
                  ),
                );
              },
            ))
      ],
    ));
  }
}

class ChoosePlayer extends StatefulWidget {
  const ChoosePlayer({super.key, this.onTap});

  final TapEvent? onTap;

  @override
  State<ChoosePlayer> createState() => _ChoosePlayerState();
}

class _ChoosePlayerState extends State<ChoosePlayer> {
  List<Widget> _initElements() {
    List<Widget> list = [];
    UserWS userWS = GlobalData().userWS(context);

    for (var user in userWS.userList) {
      // 交换特殊卡省略自己头像
      if ((RootData.of(context)?.data["specialCardVal"] ==
                  SpecialCardVal.greenSwapCard ||
              RootData.of(context)?.data["specialCardVal"] ==
                  SpecialCardVal.redBombCard) &&
          user.id == userWS.user.id) {
        continue;
      }
      list.add(Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                      border: Border.all(width: 1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // 设置圆角的半径
                        child: UserAvatar(user: user, size: 60)),
                  ),
                  Text(user.nickName!, style: const TextStyle(fontSize: 16))
                ],
              ),
              Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onTap != null) {
                        RootData.of(context)?.data["chooseUserId"] = user.id;
                        widget.onTap!(2);
                      }
                    },
                    child: SizedBox(
                        width: 90,
                        height: 90,
                        child: Container(color: GameColor.dialog3 // 不能去掉
                            )),
                  )),
            ],
          )
        ],
      ));
    }
    return list;
  }

  void onTap() {
    if (widget.onTap != null) {
      widget.onTap!(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        const Expanded(
            flex: 2,
            child: Text(
              "请选择要作用的玩家",
              style: TextStyle(color: Colors.white, fontSize: 20),
            )),
        const SizedBox(height: 10),
        Expanded(
            flex: 8,
            child: GridView.count(
              mainAxisSpacing: 0,
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              children: _initElements(),
            )),
        BackBtn(onTap: onTap, child: const Icon(Icons.arrow_back))
      ],
    ));
  }
}

class ChooseCommonCard extends StatefulWidget {
  const ChooseCommonCard({super.key, this.onTap});

  final TapEvent? onTap;

  @override
  State<ChooseCommonCard> createState() => _ChooseCommonCardState();
}

class _ChooseCommonCardState extends State<ChooseCommonCard> {
  UserCards userCards = UserCards(userId: 0);
  UserCards userCards1 = UserCards(userId: 0);
  List<GameCard.Card> allCommonCards = [];

  void onTap() {
    if (widget.onTap != null) {
      if (RootData.of(context)?.data["specialCardVal"] ==
          SpecialCardVal.yellowWildCard) {
        widget.onTap!(0);
        return;
      }
      widget.onTap!(-1);
    }
  }

  void chooseCard(GameCard.Card card) {
    setState(() {
      card.isChoose != null ? card.isChoose = !card.isChoose! : null;
    });
  }

  void clearChoose() {
    userCards.clearChoose();
    userCards1.clearChoose();
    for (var card in allCommonCards) {
      card.isChoose = false;
    }
  }

  UserCards getUserCards(int userId) {
    return RootData.of(context)?.data["cardMap"][userId];
  }

  int getSpecialCardID(int userID, String val) {
    return getUserCards(userID)
        .cards
        .firstWhere(
            (element) =>
                element.category == CardCategory.special &&
                element.specialVal == val,
            orElse: () => GameCard.Card())
        .id!;
  }

  void setData(
      GameCard.Card? source, GameCard.Card? source1, GameCard.Card? target) {
    if (source != null) {
      RootData.of(context)?.data["sourceCard"] = source.copy();
    }
    if (source1 != null) {
      RootData.of(context)?.data["sourceCard1"] = source1.copy();
    }
    if (target != null) {
      RootData.of(context)?.data["targetCard"] = target.copy();
    }

    var specialCardVal = RootData.of(context)?.data["specialCardVal"];
    var userId = GlobalData().user(context).id;
    var targetUserId = RootData.of(context)?.data["chooseUserId"];
    var sourceCard = RootData.of(context)?.data["sourceCard"];
    var sourceCard1 = RootData.of(context)?.data["sourceCard1"];
    var targetCard = RootData.of(context)?.data["targetCard"];
    // print(
    //     "setData: $specialCard,${sourceCard.isChoose}, ${sourceCard1.isChoose}, ${targetCard.isChoose}");
    // print(RootData.of(context)?.data["sourceCard"].isChoose);

    if (specialCardVal == SpecialCardVal.redBombCard && sourceCard.isChoose) {
      print("使用炸弹卡");
      GlobalData().userWS(context).useSpecialCard({
        "specialCardID": getSpecialCardID(userId, SpecialCardVal.redBombCard),
        "cardID": sourceCard.id,
        "targetUserID": targetUserId
      });
      RootData.of(context)?.data["dialogAction"]();
    } else if (specialCardVal == SpecialCardVal.yellowWildCard &&
        targetCard.isChoose) {
      print("使用万能卡");
      GlobalData().userWS(context).useSpecialCard({
        "specialCardID":
            getSpecialCardID(userId, SpecialCardVal.yellowWildCard),
        "needNumber": int.parse(targetCard.commonVal)
      });
      RootData.of(context)?.data["dialogAction"]();
    } else if (specialCardVal == SpecialCardVal.greenSwapCard &&
        sourceCard.isChoose &&
        sourceCard1.isChoose) {
      print("使用交换卡");
      GlobalData().userWS(context).useSpecialCard({
        "specialCardID": getSpecialCardID(userId, SpecialCardVal.greenSwapCard),
        "cardID": sourceCard.id,
        "targetUserID": targetUserId,
        "targetCard": sourceCard1.id
      });
      RootData.of(context)?.data["dialogAction"]();
    } else if (specialCardVal == SpecialCardVal.blueModifyCard &&
        sourceCard.isChoose &&
        targetCard.isChoose) {
      print("使用修改卡");
      GlobalData().userWS(context).useSpecialCard({
        "specialCardID":
            getSpecialCardID(userId, SpecialCardVal.blueModifyCard),
        "cardID": sourceCard.id,
        "targetUserID": targetUserId,
        "updateNumber": int.parse(targetCard.commonVal)
      });
      RootData.of(context)?.data["dialogAction"]();
    }
  }

  List<Widget> _initElements(List<GameCard.Card> cards, int source) {
    List<Widget> list = [];
    for (var card in cards) {
      list.add(GestureDetector(
          onTap: () {
            // 清空所有选择
            for (var element in cards) {
              element.isChoose = false;
            }

            chooseCard(card);
            source == 0 ? setData(card, null, null) : setData(null, card, null);
          },
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: card.isChoose != null && card.isChoose!
                      ? Border.all(width: 2, color: Colors.yellow)
                      : null,
                ),
                child: CardDom(card: card),
              )
            ],
          )));
    }
    return list;
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          // 清空所有选择
          for (var element in allCommonCards) {
            element.isChoose = false;
          }

          chooseCard(allCommonCards[index]);
          setData(null, null, allCommonCards[index]);
        },
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
              border: allCommonCards[index].isChoose != null &&
                      allCommonCards[index].isChoose!
                  ? Border.all(width: 2, color: Colors.yellow)
                  : null,
            ),
            child: CardDom(card: allCommonCards[index]),
          )
        ]));
  }

  List<Widget> sourceCard(
      String title, List<GameCard.Card> cards, int source, double bottom) {
    return [
      Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          )),
      const SizedBox(height: 10),
      Expanded(
          flex: 12,
          child: GridView.count(
            mainAxisSpacing: 0,
            crossAxisSpacing: 10,
            crossAxisCount: 3,
            children: _initElements(cards, source),
          )),
      SizedBox(height: bottom),
    ];
  }

  List<Widget> targetCard() {
    return [
      const Expanded(
          flex: 2,
          child: Text(
            "目标点数",
            style: TextStyle(color: Colors.white, fontSize: 20),
          )),
      Expanded(
          flex: 8,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              itemCount: allCommonCards.length,
              itemBuilder: _itemBuilder)),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> content() {
    switch (RootData.of(context)?.data["specialCardVal"]) {
      case SpecialCardVal.redBombCard:
        userCards = getUserCards(RootData.of(context)?.data["chooseUserId"]);
        return [...sourceCard("请选择要作用的卡牌", userCards.getCommonCards(), 0, 20)];
      case SpecialCardVal.yellowWildCard:
        userCards = RootData.of(context)?.data["getSelfCards"]();
        return [...targetCard()];
      case SpecialCardVal.greenSwapCard:
        userCards = RootData.of(context)?.data["getSelfCards"]();
        userCards1 = getUserCards(RootData.of(context)?.data["chooseUserId"]);
        return [
          ...sourceCard("请选择自己的卡牌", userCards.getCommonCards(), 0, 20),
          ...sourceCard("请选择对方的卡牌", userCards1.getCommonCards(), 1, 0)
        ];
      case SpecialCardVal.blueModifyCard:
        userCards = getUserCards(RootData.of(context)?.data["chooseUserId"]);
        return [
          ...sourceCard("请选择要作用的卡牌", userCards.getCommonCards(), 0, 20),
          ...targetCard()
        ];
      default:
        return [];
    }
  }

  @override
  void initState() {
    super.initState();
    userCards.randomCards(6);
    userCards1.randomCards(6);
    allCommonCards = userCards.createAllCommonCards();
  }

  @override
  void dispose() {
    clearChoose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ...content(),
        BackBtn(onTap: onTap, child: const Icon(Icons.arrow_back))
      ],
    ));
  }
}
