import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/createRoom.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPage();
}

class _RoomPage extends State<RoomPage> {
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
    // if (Provider.of<Room>(context).id == 0 &&
    //     Provider.of<Room>(context).roomId == 0) {
    //   return const Center(
    //       child: Text(
    //     "请创建或加入房间",
    //     style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    //   ));
    // }
    return GestureDetector(
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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();

  // List<Map<String, String>> chatRecord = [
  //   {"name": "3333", "content": "a"},
  //   {
  //     "name":
  //         "33ddsds我我33上这些对话框组件都提供了不同的样Flutter应用程序。CupertinoAlertDialog 包含一个标题、内容和一个或多个操作按钮，具有iOS的风格",
  //     "content": "dfsaf666",
  //   },
  //   {
  //     "name": "和嵌套不同的",
  //     "content": "个 AlertDialogdfffffsrfweeeeeeeeeeeerewrwerww "
  //   },
  //   {"name": "码演示了如何在Flutter中示一个简单的", "content": "SimpleDialog "},
  // ];
  List<Map<String, String>> chatRecord = [];

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

  void sendMessage() {
    if (message != "") {
      Map<String, String> msg = {
        "name": Provider.of<User>(context, listen: false).name!,
        "content": message
      };
      setState(() {
        chatRecord.add(msg);
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
      width: pageWidth(context) * 0.8,
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
      decoration: BoxDecoration(
        color: GameColor.dialog,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
              flex: 7,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatRecord.length,
                itemBuilder: Element,
              )),
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
  List<User> userList = [
    User(),
    User(),
    User(),
    User(),
    User(),
    User(),
    User(),
    User(),
  ];

  List<Player> _initElements() {
    List<Player> list = [];
    for (var element in userList) {
      list.add(Player(element));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      mainAxisSpacing: 0,
      crossAxisSpacing: 10,
      crossAxisCount: 4,
      childAspectRatio: 0.7,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
      children: _initElements(),
    );
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
    return Container(
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateRoomPage(
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
                  onPressed: () {},
                  child: const Text(
                    "开始",
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
                  onPressed: () {
                    Provider.of<User>(context, listen: false).state = UserState.inRoomReady;
                  },
                  child: const Text(
                    "准备",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )),
          ],
        ));
  }
}

class Player extends StatefulWidget {
  const Player(this.user, {super.key});

  final User user;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
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
                  child: Image.asset(widget.user.avatar!,
                      width: 60, height: 60, fit: BoxFit.cover)),
            ),
            Positioned(
                right: 0,
                top: 0,
                // TODO 切换准备图标
                child: SizedBox(
                    width: 23,
                    height: 23,
                    child:
                        SvgPicture.asset(Source.close, width: 15, height: 15)))
          ],
        ),
        Text(widget.user.name!, style: const TextStyle(fontSize: 16))
      ],
    ));
  }
}
