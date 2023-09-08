import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';

class CommonAppBar extends AppBar {
  CommonAppBar({super.key, required String title})
      : super(
          centerTitle: true,
          backgroundColor: GameColor.theme,
          title: Text(title),
        );
}
