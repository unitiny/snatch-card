import 'dart:math';
import 'package:flutter/material.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class Card {
  int? id;
  bool? isChoose = false;
  bool? hasOwner = false; // 只作用于卡堆的牌
  String? commonVal = "0";
  CardCategory? category = CardCategory.common;
  String? specialVal = SpecialCardVal.redBombCard;

  Card(
      {int? id,
      this.isChoose,
      this.hasOwner,
      this.category,
      this.commonVal,
      this.specialVal}) {
    this.id = id ?? randId();
    isChoose ??= false;
    hasOwner ??= false;
  }

  IconData icon() {
    switch (specialVal) {
      case SpecialCardVal.redBombCard:
        return Icons.flash_on;
      case SpecialCardVal.yellowWildCard:
        return Icons.all_inclusive;
      case SpecialCardVal.greenSwapCard:
        return Icons.swap_horizontal_circle;
      case SpecialCardVal.blueModifyCard:
        return Icons.edit;
      default:
        return Icons.add;
    }
  }

  Color color() {
    switch (specialVal) {
      case SpecialCardVal.redBombCard:
        return Colors.red;
      case SpecialCardVal.yellowWildCard:
        return Colors.yellow;
      case SpecialCardVal.greenSwapCard:
        return Colors.green;
      case SpecialCardVal.blueModifyCard:
        return Colors.blue;
      default:
        return Colors.red;
    }
  }

  String getSpecialVal(int type) {
    if (type == 1) {
      return SpecialCardVal.yellowWildCard;
    } else if (type == 2) {
      return SpecialCardVal.redBombCard;
    } else if (type == 4) {
      return SpecialCardVal.blueModifyCard;
    } else if (type == 8) {
      return SpecialCardVal.greenSwapCard;
    }
    return SpecialCardVal.yellowWildCard;
  }

  String randomSpecialVal() {
    switch (Random().nextInt(4)) {
      case 0:
        return SpecialCardVal.redBombCard;
      case 1:
        return SpecialCardVal.yellowWildCard;
      case 2:
        return SpecialCardVal.greenSwapCard;
      case 3:
        return SpecialCardVal.blueModifyCard;
      default:
        return SpecialCardVal.redBombCard;
    }
  }

  Card copy() {
    return Card(
        id: id,
        isChoose: isChoose,
        hasOwner: hasOwner,
        category: category,
        commonVal: commonVal,
        specialVal: specialVal);
  }

  // 写错了，没用。不管什么情况都会触发dealFunc,那switch没什么意义了
  // 想强行用，就得传入四个dealFunc，还不如直接switch
  void dealBySpecialVal(String val, void Function() dealFunc) {
    switch (val) {
      case SpecialCardVal.redBombCard:
        dealFunc();
        break;
      case SpecialCardVal.yellowWildCard:
        dealFunc();
        break;
      case SpecialCardVal.greenSwapCard:
        dealFunc();
        break;
      case SpecialCardVal.blueModifyCard:
        dealFunc();
    }
  }
}
