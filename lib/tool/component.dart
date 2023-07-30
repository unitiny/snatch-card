import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:snatch_card/class/user.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/source/platform.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/page/game/game.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snatch_card/compatible/ui/realUI.dart'
    if (dart.library.io) 'package:snatch_card/compatible/ui/fakeUI.dart';

typedef callBack<T> = void Function(T value);
typedef voidBack = void Function();

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

  Future lightTip(BuildContext context, String text, {bool canPop = true, int display = 1200}) {
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

  Future waitDialog(BuildContext context, {bool canPop = true, int display = 1200}) {
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
            elevation: 0,
            underline: Container(color: Colors.white),
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

class StartGame extends StatefulWidget {
  const StartGame({super.key});

  @override
  State<StartGame> createState() => _StartGameState();
}

class _StartGameState extends State<StartGame> {
  UserWS userWS = UserWS();
  voidBack listener = () {};

  void start() {
    if ((userWS.store["startGame"] != null &&
            userWS.store["startGame"] == true) ||
        userWS.isNotify(ServiceType.beginGameResponseType)) {
      GlobalData().room(context).state = RoomState.start;
      userWS.store["startGame"] = false;
      userWS.store = {};
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GamePage(),
          ),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    listener = start;
    // 监听游戏开始跳转
    userWS = GlobalData().userWS(context);
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

class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key, this.size});

  final double? size;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  @override
  Widget build(BuildContext context) {
    User user = GlobalData().user(context);
    if (user.isLocalAvatar()) {
      return Image.asset(user.avatar!,
          width: widget.size ?? 95,
          height: widget.size ?? 95,
          fit: BoxFit.cover);
    } else if (PlatformUtils.isWeb) {
      return WebImage(user.image(), widget.size ?? 95, widget.size ?? 95);
    } else {
      return Image.network(user.image(),
          width: widget.size ?? 95,
          height: widget.size ?? 95,
          fit: BoxFit.cover);
    }
  }
}

class ShowToast extends StatefulWidget {
  const ShowToast(
      {super.key, this.type = ServiceType.msgResponseType, this.callback});

  final int? type;
  final voidBack? callback;

  @override
  State<ShowToast> createState() => _ShowToastState();
}

class _ShowToastState extends State<ShowToast> {
  voidBack listener = () {};
  UserWS userWS = UserWS();

  void showToast() {
    if (userWS.isNotify(widget.type!)) {
      if (userWS.store["tip"] != null && userWS.store["tip"] != "") {
        MyDialog().lightTip(context, userWS.store["tip"], display: 500);
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

class Rule extends StatefulWidget {
  Rule({super.key, this.show = false});

  bool show;

  @override
  State<Rule> createState() => RuleState();
}

class RuleState extends State<Rule> {
  List<Map<String, String>> text = [
    {"title": "游戏介绍:", "content": "该游戏是一个多人抢牌游戏，玩家需要在限定的回合内尽可能多的得分"},
    {"title": "游戏流程:", "content": "进入游戏后，有三个阶段，1.抢卡回合 2.特殊卡回合 3.分数计算回合"},
    {
      "title": "游戏玩法:",
      "content":
          "抢卡回合中每位玩家最多抢两张普通卡和一张特殊卡\n玩家可以通过抢卡凑齐20点数得分，亦可以干扰其它玩家来获得分数\n若卡牌数大于6张，则销毁最先抢到的卡\n若自己卡堆卡牌总和大于20了（假设是X），系统会在分数计算阶段销毁该玩家的全部普通卡，并将生成一张的卡(该卡的值=X取余20)"
    },
    {
      "title": "游戏特殊卡:",
      "content":
          "红色炸弹卡:可以炸掉其他玩家卡堆里的一张卡\n黄色万能卡:选一张数字类型卡加入自己卡堆\n绿色交换卡:可以用自己一张卡与其他玩家交换\n蓝色修改卡:修改自己或者他人的数字类型卡"
    },
  ];

  List<Widget> _rules() {
    List<Widget> res = [];
    for (var elem in text) {
      res.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          elem["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          elem["content"]!,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8)
      ]));
    }
    return res;
  }

  void tap() {
    setState(() {
      widget.show = !widget.show;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox();
    }
    return Container(
        width: pageWidth(context),
        height: pageHeight(context),
        color: GameColor.background3,
        child: Center(
          child: Container(
            width: pageWidth(context) * 0.85,
            height: pageHeight(context) * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
                color: GameColor.background2,
                border: Border.all(width: 2, color: Colors.black45),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "游戏规则",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ..._rules(),
                    const SizedBox(height: 16.0),
                  ],
                ),
                Positioned(
                    bottom: 10,
                    right: 0,
                    child: BackBtn(
                        onTap: tap,
                        child: const Text(
                          "返回",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        )))
              ],
            ),
          ),
        ));
  }
}
