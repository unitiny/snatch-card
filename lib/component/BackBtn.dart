import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';

class BackBtn extends StatefulWidget {
  const BackBtn({super.key, this.onTap, required this.child});

  final GestureTapCallback? onTap;
  final Widget child;

  @override
  State<BackBtn> createState() => _BackBtnState();
}

class _BackBtnState extends State<BackBtn> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
            onPressed: widget.onTap,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                  // 根据状态返回相应的背景颜色
                  if (states.contains(MaterialState.pressed)) {
                    // 按下状态的背景颜色
                    return GameColor.background2;
                  } else if (states.contains(MaterialState.disabled)) {
                    // 禁用状态的背景颜色
                    return Colors.grey;
                  }
                  // 默认状态的背景颜色
                  return Colors.white;
                },
              ),
            ),
            child: widget.child)
      ],
    );
  }
}
