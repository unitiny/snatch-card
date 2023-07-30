import 'dart:math';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/class/card.dart';
import 'package:snatch_card/tool/source.dart';

class UserCards {
  int? id;
  int userId;
  List<Card> cards = [];

  UserCards({int? id, required this.userId, cards}) {
    this.id = id ?? randId();
    this.cards = cards ?? [];
  }

  List<Card> getCommonCards() {
    return cards
        .where((element) => element.category == CardCategory.common)
        .toList();
  }

  List<Card> getSpecialCards() {
    return cards
        .where((element) => element.category == CardCategory.special)
        .toList();
  }

  void randomCards(int num) {
    for (int i = 0; i < num; i++) {
      CardCategory cate;
      String val;

      if (Random().nextInt(2) == 0) {
        cate = CardCategory.common;
        val = commonCardValue[Random().nextInt(commonCardValue.length)];
        cards.add(Card(category: cate, commonVal: val));
      } else {
        cate = CardCategory.special;
        cards.add(Card(category: cate, specialVal: Card().randomSpecialVal()));
      }
    }
  }

  void randSpecialCards(int num) {
    for (int i = 0; i < num; i++) {
      CardCategory cate = CardCategory.special;
      cards.add(Card(category: cate, specialVal: Card().randomSpecialVal()));
    }
  }

  List<Card> createAllCommonCards() {
    List<Card> commonCards = [];
    for (int i = 0; i < 9; i++) {
      CardCategory cate = CardCategory.common;
      commonCards.add(Card(category: cate, commonVal: "${i + 1}"));
    }
    return commonCards;
  }

  void addCard(List<Card> card) {
    cards.addAll(card);
  }

  void clearChoose() {
    for (var card in cards) {
      card.isChoose = false;
    }
  }
}
