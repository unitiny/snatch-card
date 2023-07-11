// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/page/game/game.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/room/createRoom.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPage();
}

class _RoomPage extends State<RoomPage> {
  @override
  void initState() {
    super.initState();
    UserWS userWS = GlobalData().userWS(context);
    userWS.getRoomMsg({}); // 通过房间信息获取其它用户信息
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: GameColor.theme,
          child: const Column(children: [
            Expanded(flex: 2, child: Header()),
            Expanded(flex: 75, child: Body()),
            Expanded(flex: 2, child: Footer()),
          ])),
    );
  }
}

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  Widget build(BuildContext context) {
    // return const Placeholder();
    return Container();
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Room>(
      builder: (context, Room globalRoom, child) {
        if (GlobalData().room(context).id == 0 &&
            GlobalData().room(context).roomId == 0) {
          return const Center(
              child: Text(
            "请创建或加入房间",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ));
        }
        return Container(child: child);
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: const Column(
              children: [
                Expanded(flex: 4, child: Chat()),
                Expanded(flex: 5, child: People()),
                Expanded(flex: 1, child: OperateBoard()),
              ],
            )),
      ),
    );
  }
}

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  UserWS userWS = UserWS();
  VoidCallback listener = () {};

  void start() {
    if ((userWS.store["startGame"] != null &&
            userWS.store["startGame"] == true) ||
        userWS.isNotify(ServiceType.beginGameResponseType)) {
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

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String message = "";
  List<Map<String, String>> chatRecord = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();

  Widget? Element(BuildContext context, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${chatRecord[index]['name']!}:",
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            )),
        Text(chatRecord[index]['content']!,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            )),
      ],
    );
  }

  Map<String, String> userMessage(String nickname, String content) {
    return {"name": nickname, "content": content};
  }

  void sendMessage() {
    if (message != "") {
      var msg = userMessage(GlobalData().user(context).nickName!, message);
      GlobalData().userWS(context).chatMsg(msg);
      setState(() {
        message = "";
        _editController.clear();
        FocusScope.of(context).unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.85,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      decoration: BoxDecoration(
        color: GameColor.dialog1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
              flex: 7,
              child: Selector<UserWS, UserWS>(
                  shouldRebuild: (pre, next) =>
                      next.isNotify(ServiceType.chatResponseType),
                  selector: (context, provider) => provider,
                  builder: (context, userWS, child) {
                    if (userWS.store["talker"] != null) {
                      var msg = userMessage(
                          userWS.store["talker"], userWS.store["chatMsg"]);
                      chatRecord.add(msg);
                      userWS.store["talker"] = null;
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: chatRecord.length,
                      itemBuilder: Element,
                    );
                  })),
          const SizedBox(height: 2),
          Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _editController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: GameColor.green)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: GameColor.green)),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                          onChanged: (value) {
                            message = value;
                          },
                          onEditingComplete: sendMessage,
                        ),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 3,
                      child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              backgroundColor: GameColor.green,
                              shape: const RoundedRectangleBorder(
                                //边框圆角
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                            onPressed: sendMessage,
                            onLongPress: () {
                              GlobalData().userWS(context).quitRoom({});
                              return;
                            },
                            child: const Text(
                              "发送",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          )))
                ],
              )),
        ],
      ),
    );
  }
}

class People extends StatefulWidget {
  const People({super.key});

  @override
  State<People> createState() => _PeopleState();
}

class _PeopleState extends State<People> {
  List<Player> _initElements(List<User> userList) {
    List<Player> list = [];
    for (var element in userList) {
      list.add(Player(element));
    }
    return list;
  }

  @override
  void dispose() {
    super.dispose(); // 一定要放到最后
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<UserWS, UserWS>(
        shouldRebuild: (pre, next) =>
            next.isNotify(ServiceType.roomInfoResponseType),
        selector: (context, provider) => provider,
        builder: (context, userWS, child) {
          // 更新房间信息
          Room room = GlobalData().room(context);
          room.update(
              roomId: userWS.res[ServiceType.roomInfoResponseType]?["roomInfo"]
                  ?["roomID"],
              roomName: userWS.res[ServiceType.roomInfoResponseType]
                  ?["roomInfo"]?["roomName"],
              round: userWS.res[ServiceType.roomInfoResponseType]?["roomInfo"]
                  ?["gameCount"],
              totalNum: userWS.res[ServiceType.roomInfoResponseType]
                  ?["roomInfo"]?["maxUserNumber"],
              roomOwnerId: userWS.res[ServiceType.roomInfoResponseType]
                  ?["roomInfo"]?["roomOwner"],
              roomOwnerName: userWS.userList
                  .firstWhere(
                      (e) =>
                          e.id == userWS.res[ServiceType.roomInfoResponseType]?["roomInfo"]?["roomOwner"],
                      orElse: () => User())
                  .nickName,
              playersId: userWS.userList.map((e) => e.id).toList());

          return GridView.count(
            mainAxisSpacing: 0,
            crossAxisSpacing: 10,
            crossAxisCount: 4,
            childAspectRatio: 0.7,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            children: _initElements(userWS.userList),
          );
        });
  }
}

class OperateBoard extends StatefulWidget {
  const OperateBoard({super.key});

  @override
  State<OperateBoard> createState() => _OperateBoardState();
}

class _OperateBoardState extends State<OperateBoard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<Room>(
        builder: (context, Room globalRoom, child) {
          // 只有房主才显示
          User user = GlobalData().user(context);
          Room room = GlobalData().room(context);
          if (user.id != room.roomOwnerId) {
            return Container();
          }
          return Container(child: child);
        },
        child: Container(
            width: pageWidth(context) * 0.82,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColor.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () {
                        GlobalData().userWS(context).clean();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CreateRoomPage(
                                      effect: 1,
                                    )));
                      },
                      child: const Text(
                        "设置",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )),
                SizedBox(
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColor.green,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        // 检查能否开始游戏 条件：房主，房间满人，ws连接正常
                        UserWS userWS = GlobalData().userWS(context);
                        if (userWS.user.id != GlobalData().user(context).id ||
                            userWS.WS == null ||
                            userWS.userList.length <
                                GlobalData().room(context).totalNum) {
                          MyDialog().lightTip(context, "无法开始");
                          return;
                        }

                        userWS.beginGame({});
                        // Future.delayed(Duration(seconds: 1), () {
                        //   MyDialog().lightTip(context, "即将开始");
                        // }).then((value) {
                        //
                        // });
                      },
                      child: const Text(
                        "开始",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )),
                // SizedBox(
                //     width: 100,
                //     height: 40,
                //     child: ElevatedButton(
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: GameColor.green,
                //         shape: const RoundedRectangleBorder(
                //           borderRadius: BorderRadius.all(
                //             Radius.circular(10),
                //           ),
                //         ),
                //       ),
                //       onPressed: () {
                //         GlobalData().user(context).state =
                //             UserState.inRoomReady;
                //       },
                //       child: const Text(
                //         "准备",
                //         style: TextStyle(fontSize: 16, color: Colors.black),
                //       ),
                //     )),
              ],
            )));
  }
}

class Player extends StatefulWidget {
  const Player(this.user, {super.key});

  final User user;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  Widget KickOut() {
    if (GlobalData().room(context).roomOwnerId !=
        GlobalData().user(context).id) {
      return const SizedBox();
    }
    return Positioned(
        right: 0,
        top: 0,
        // TODO 以后再完善踢人，切换准备图标功能
        child: GestureDetector(
            onTap: () {
              if (GlobalData().user(context).id == widget.user.id) {
                return;
              }
              GlobalData().userWS(context).updateRoom({
                "kicker": widget.user.id,
              });
            },
            child: SizedBox(
                width: 23,
                height: 23,
                child: SvgPicture.asset(Source.close, width: 15, height: 15))));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all()),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // 设置圆角的半径
                  child: widget.user.avatar! == Source.avatar1
                      ? Image.asset(widget.user.avatar!,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : Image.network(widget.user.image(),
                          width: 60, height: 60, fit: BoxFit.cover)),
            ),
            KickOut()
          ],
        ),
        Text(widget.user.userName!, style: const TextStyle(fontSize: 16))
      ],
    ));
  }
}
