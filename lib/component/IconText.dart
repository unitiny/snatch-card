import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class IconText extends StatelessWidget {
  const IconText(
      {super.key,
        required this.icon,
        this.text,
        this.img,
        this.space,
        this.fontWeight = FontWeight.w400});

  final Icon icon;
  final String? text;
  final String? img;
  final double? space;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        img == null
            ? icon
            : SizedBox(
            width: 15,
            height: 15,
            child: SvgPicture.asset(img!, width: 15, height: 15)),
        SizedBox(
          width: space != null ? space! / 2 : 0,
        ),
        Text(
          text ?? "",
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: fontWeight),
        ),
        SizedBox(
          width: space != null ? space! : 0,
        )
      ],
    );
  }
}
