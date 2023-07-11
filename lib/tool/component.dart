import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snatch_card/class/game.dart';
import 'package:snatch_card/page/game/game.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef callBack<T> = void Function(T value);

class DropInput<T> extends StatefulWidget {
  const DropInput(
      {super.key, this.name, required this.items, required this.callback});

  final String? name;
  final List<Object> items;
  final callBack<String> callback;

  @override
  State<DropInput> createState() => _DropInputState();
}

class _DropInputState extends State<DropInput> {
  Object? _selectedItem;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          right: 10.0,
          top: 10.0,
          bottom: 10.0,
          child: Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
          ),
        ),
        Container(
          width: pageWidth(context),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: GameColor.border),
            borderRadius: BorderRadius.circular(3),
          ),
          child: DropdownButton(
            icon: const Icon(
              Icons.arrow_drop_down, //将下三角图标替换为一个空白的 Icon
              color: Colors.transparent,
            ),
            hint: Container(
                padding: const EdgeInsets.only(left: 10),
                child: Text(widget.name!)),
            value: _selectedItem,
            items: widget.items.map((Object value) {
              return DropdownMenuItem(
                value: value,
                child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(value.toString())),
              );
            }).toList(),
            onChanged: (Object? selectedItem) {
              setState(() {
                _selectedItem = selectedItem;
                widget.callback(selectedItem.toString());
              });
            },
          ),
        )
      ],
    );
  }
}

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

class OtherOperators extends StatefulWidget {
  const OtherOperators({super.key, required this.callback, this.icon});

  final void Function() callback;
  final IconData? icon;

  @override
  State<OtherOperators> createState() => _OtherOperatorsState();
}

class _OtherOperatorsState extends State<OtherOperators> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      focusColor: Colors.blue[50],
      onPressed: widget.callback,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
      ),
      child: Icon(widget.icon ?? Icons.add),
    );
  }
}

class CommonAppBar extends AppBar {
  CommonAppBar({super.key, required String title})
      : super(
          centerTitle: true,
          backgroundColor: GameColor.theme,
          title: Text(title),
        );
}

class MyDialog {
  tipDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("提示"),
          content: const Text("确定删除吗？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("取消"),
            ),
            TextButton(onPressed: () {}, child: const Text("确定")),
          ],
        );
      },
    );
  }

  Future lightTip(BuildContext context, String text, {int display = 1200}) {
    Timer? timer;
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: GameColor.dialog3,
        builder: (BuildContext dialogContext) {
          // TODO 想实现弹窗根据内容宽度自适应的，但没实现。
          //  用过UnconstrainedBox(),Wrap,当前的Row方法，但只能约束宽度，而不能Dialog自适应宽度
          timer = Timer(Duration(milliseconds: display), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Dialog(
                  insetPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0))),
                  backgroundColor: GameColor.background2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          );
        }).then((value) {
      timer?.cancel();
    });
  }
}
