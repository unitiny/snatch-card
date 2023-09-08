import 'package:flutter/material.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/tool/source.dart';

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
