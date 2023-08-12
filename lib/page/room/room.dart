// ignore_for_file: non_constant_identifier_names

import 'package:audioplayers/audioplayers.dart';
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
    if (userWS.WS != null) {
      userWS.getRoomMsg({}); // 通过房间信息获取其它用户信息
    }
  }

  @override
  Widget build(BuildContext context) {
    setUseState(context, UserState.inRoom);
    GlobalData().room(context).state = RoomState.wait;
    return Center(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: GameColor.theme,
          child: const Stack(
            children: [
              Column(children: [
                Expanded(flex: 2, child: Header()),
                Expanded(flex: 75, child: Body()),
                Expanded(flex: 2, child: Footer()),
              ]),
            ],
          )),
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
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const StartGame(),
        ShowToast(
            type: ServiceType.kickerResponseType,
            callback: () {
              GlobalData().room(context).clean();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PageRouter.Router(
                      pageIndex: 0,
                    ),
                  ),
                  (route) => false);
            }),
        const ShowToast()
      ],
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String message = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();

  Widget? Element(BuildContext context, int index) {
    List<Map<String, String>> chatRecord =
        GlobalData().room(context).chatRecord;
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
        dropMessage();
      });
    }
  }

  void dropMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    dropMessage();
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
                      GlobalData().room(context).chatRecord.add(msg);
                      userWS.store["talker"] = null;
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: GlobalData().room(context).chatRecord.length,
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
  Widget set() {
    return SizedBox(
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
        ));
  }

  Widget start() {
    return SizedBox(
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
                userWS.userList.length < GlobalData().room(context).totalNum) {
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
        ));
  }

  Widget prepare() {
    return SizedBox(
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
            UserWS userWS = GlobalData().userWS(context);
            userWS.userReadyState({
              "isReady":
                  userWS.user.state == UserState.inRoomReady ? false : true
            });
            if (userWS.user.state == UserState.inRoomReady) {
              userWS.user.state = UserState.inRoom;
              GlobalData().user(context).state = UserState.inRoom;
            } else {
              userWS.user.state = UserState.inRoomReady;
              GlobalData().user(context).state = UserState.inRoomReady;
            }
          },
          child: const Text(
            "准备",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ));
  }

  Widget quit() {
    return SizedBox(
        width: 100,
        height: 40,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: GameColor.cancel,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
          ),
          onPressed: () {
            GlobalData().room(context).clean();
            GlobalData().userWS(context).quitRoom({});
            GlobalData().user(context).state = UserState.inHome;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const PageRouter.Router(
                          pageIndex: 0,
                        )),
                (router) => false);
          },
          child: const Text(
            "退出",
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Room>(builder: (context, Room globalRoom, child) {
      // 只有房主才显示
      User user = GlobalData().user(context);
      Room room = GlobalData().room(context);
      List<Widget> content = [quit(), set(), start()];
      if (user.id != room.roomOwnerId) {
        content = [quit(), prepare()];
      }
      return Container(
          width: pageWidth(context) * 0.85,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [...content],
          ));
    });
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
                child: SvgPicture.asset(Asset.close, width: 15, height: 15))));
  }

  Widget RoomOwner() {
    if (GlobalData().room(context).roomOwnerId !=
        widget.user.id) {
      return const SizedBox();
    }
    return const Positioned(
        right: 0,
        bottom: 0,
        child: Icon(Icons.home, size: 25, color: GameColor.roomOwner));
  }

  Widget Prepare() {
    return Selector<UserWS, UserWS>(
        shouldRebuild: (pre, next) =>
            next.isNotify(ServiceType.roomInfoResponseType),
        selector: (context, provider) => provider,
        builder: (context, userWS, child) {
          if (widget.user.state == UserState.inRoomReady) {
            return Positioned(
              bottom: 0,
              child: Container(
                  width: 40,
                  decoration: const BoxDecoration(
                      color: GameColor.green,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: const Text(
                    "准备",
                    textAlign: TextAlign.center,
                  )),
            );
          }
          return Positioned(
            bottom: 0,
            child: Container(width: 40),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Column(
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        border: Border.all()),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // 设置圆角的半径
                        child: UserAvatar(user: widget.user,size: 60))),
                const SizedBox(height: 10)
              ],
            ),
            RoomOwner(),
            KickOut(),
            Prepare()
          ],
        ),
        Text(widget.user.nickName!,
            style:
                const TextStyle(fontSize: 16, overflow: TextOverflow.ellipsis))
      ],
    ));
  }
}
