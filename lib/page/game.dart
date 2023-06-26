import 'package:flutter/material.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/component.dart';
import 'dart:math';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePage();
}

class _GamePage extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: GameColor.theme,
          child: const Column(children: [
            Expanded(flex: 8, child: Header()),
            Expanded(flex: 80, child: Body()),
            Expanded(flex: 1, child: Footer()),
          ])),
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(5),
      color: GameColor.background1,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              IconText(
                icon: Icon(Icons.punch_clock, color: Colors.white),
                text: "倒计时：",
                space: 8,
              ),
              Text(
                "5s",
                style: TextStyle(height: 0, fontSize: 20, color: Colors.white),
              ),
            ],
          ),
          Row(
            children: [
              IconText(
                icon: Icon(Icons.settings, color: Colors.white),
                text: "回合数：",
                space: 8,
              ),
              Text(
                "6/14",
                style: TextStyle(height: 0, fontSize: 20, color: Colors.white),
              )
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
          const Expanded(flex: 30, child: SnatchCard()),
          Expanded(flex: 15, child: PlayArea(user: User())),
        ]));
  }
}

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
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
  List<User> userList = [
    User(),
    User(),
    User(),
  ];

  List<PlayArea> _initElements() {
    List<PlayArea> list = [];
    for (var elem in userList) {
      list.add(PlayArea(user: elem));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _initElements(),
    );
  }
}

class SnatchCard extends StatefulWidget {
  const SnatchCard({super.key});

  @override
  State<SnatchCard> createState() => _SnatchCardState();
}

class _SnatchCardState extends State<SnatchCard> {
  List<Widget> _initElements() {
    UserCards userCards = UserCards(userId: 0);
    userCards.randomCards(4 + Random().nextInt(3));

    List<Widget> list = [];
    for (var elem in userCards.cards) {
      list.add(Column(children: [
        const SizedBox(height: 10),
        CardDom(
          card: elem,
        )
      ]));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      decoration: const BoxDecoration(
          color: GameColor.background1,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: GridView.count(
        mainAxisSpacing: 0,
        crossAxisSpacing: 10,
        crossAxisCount: 3,
        childAspectRatio: 1.4,
        children: _initElements(),
      ),
    );
  }
}

class PlayArea extends StatefulWidget {
  const PlayArea({super.key, required this.user});

  final User user;

  @override
  State<PlayArea> createState() => _PlayAreaState();
}

class _PlayAreaState extends State<PlayArea> {
  List<Widget> _initElements() {
    UserCards userCards = UserCards(userId: 0);
    userCards.randomCards(Random().nextInt(6));

    List<Widget> list = [];
    for (var elem in userCards.cards) {
      list.add(Column(children: [
        CardDom(
          card: elem,
        ),
        const SizedBox(height: 10)
      ]));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PlayerAvatar(user: widget.user),
        const SizedBox(
          width: 10,
        ),
        ..._initElements()
      ],
    );
  }
}

class PlayerAvatar extends StatefulWidget {
  const PlayerAvatar({super.key, required this.user});

  final User user;

  @override
  State<PlayerAvatar> createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(50)),
              border: Border.all(width: 1, color: GameColor.background1)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(50), // 设置圆角的半径
              child: Image.asset(widget.user.avatar!,
                width: 40, height: 40, fit: BoxFit.cover),
          )
        ),
        Text(widget.user.name!)
      ],
    );
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
    return Column(
      children: [
        Container(
          width: 45,
          height: 60,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(width: 3, color: GameColor.background2)),
          child: Center(
            child: Text(
              widget.card.value!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
