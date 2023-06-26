import 'dart:math';
import 'package:snatch_card/class/card.dart';
import 'package:snatch_card/tool/source.dart';

class UserCards {
  int? id;
  int userId;
  List<Card> cards = [];

  UserCards({int? id, required this.userId, cards}) {
    this.id = id ?? DateTime.now().millisecondsSinceEpoch;
    this.cards = cards ?? [];
  }

  void randomCards(int num) {
    for (int i = 0; i < num; i++) {
      int cate = Random().nextInt(2);
      String val = cate == 0
          ? commonCardValue[Random().nextInt(commonCardValue.length)]
          : specialCardValue[Random().nextInt(specialCardValue.length)];

      cards.add(Card(category: cate, value: val));
    }
  }
}
