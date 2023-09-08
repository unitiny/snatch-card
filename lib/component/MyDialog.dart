import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';

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

  Future lightTip(BuildContext context, String text,
      {bool canPop = true, int display = 1200}) {
    // 如果当前有弹窗，则清空之前的弹窗
    while (canPop && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Timer? timer;
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: GameColor.dialog3,
        builder: (BuildContext dialogContext) {
          // TODO 想实现弹窗根据内容宽度自适应的，但没实现。
          //  用过UnconstrainedBox(),Wrap,当前的Row方法，但只能约束宽度，而不能Dialog自适应宽度

          if(text == "") {
            return Container();
          }
          timer = Timer(Duration(milliseconds: display), () {
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 150),
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

  Future waitDialog(BuildContext context,
      {bool canPop = true, int display = 1200}) {
    // 如果当前有弹窗，则清空之前的弹窗
    while (canPop && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Timer? timer;
    return showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: GameColor.dialog3,
        builder: (BuildContext dialogContext) {
          // TODO 想实现弹窗根据内容宽度自适应的，但没实现。
          //  用过UnconstrainedBox(),Wrap,当前的Row方法，但只能约束宽度，而不能Dialog自适应宽度
          timer = Timer(Duration(milliseconds: display), () {
            if (context.mounted && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          });
          return const SizedBox(
              height: 100.0,
              child: Center(
                child: CircularProgressIndicator(),
              ));
        }).then((value) {
      timer?.cancel();
    });
  }
}
