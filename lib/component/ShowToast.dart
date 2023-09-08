import 'package:flutter/material.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/component/MyDialog.dart';
import 'package:snatch_card/source/globalData.dart';

class ShowToast extends StatefulWidget {
  const ShowToast(
      {super.key, this.type = ServiceType.msgResponseType,
        this.msgOrigin = 0,
        this.callback,
        this.display = 500});

  final int? type;
  final int? msgOrigin; // 0房间 1游戏
  final int? display;
  final void Function()? callback;

  @override
  State<ShowToast> createState() => _ShowToastState();
}

class _ShowToastState extends State<ShowToast> {
  void Function() listener = () {};
  UserWS userWS = UserWS();

  void showToast() {
    if (userWS.isNotify(widget.type!)) {
      if (userWS.store["tip"] != null &&
          userWS.store["tip"].msgData != "" &&
          userWS.store["tip"].stateType == widget.msgOrigin) {
        MyDialog().lightTip(context, userWS.store["tip"].msgData, display: widget.display!);
        if (widget.callback != null) {
          widget.callback!();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userWS = GlobalData().userWS(context);
    listener = showToast;
    userWS.addListener(listener);
  }

  @override
  void dispose() {
    userWS.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
