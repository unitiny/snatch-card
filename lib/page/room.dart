import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';

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
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Column(
          children: [
            Expanded(flex: 4, child: Chat()),
            Expanded(flex: 5, child: People()),
            Expanded(flex: 1, child: OperateBoard()),
          ],
        ));
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
          const Expanded(flex: 7, child: ChatList()),
          const SizedBox(height: 2),
          Expanded(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Expanded(
                      flex: 7,
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: GameColor.green)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: GameColor.green)),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                          ),
                        ),
                      )),
                  SizedBox(width: 10),
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
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                              ),
                            ),
                            onPressed: () {},
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
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
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
    return const Placeholder();
  }
}

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  List<Map<String, String>> chatRecord = [
    {"name": "3333", "content": "a"},
    {
      "name":
          "33ddsds我我33上这些对话框组件都提供了不同的样Flutter应用程序。CupertinoAlertDialog 包含一个标题、内容和一个或多个操作按钮，具有iOS的风格",
      "content": "dfsaf666",
    },
    {
      "name": "和嵌套不同的",
      "content": "个 AlertDialogdfffffsrfweeeeeeeeeeeerewrwerww "
    },
    {"name": "码演示了如何在Flutter中示一个简单的", "content": "SimpleDialog "},
  ];

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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chatRecord.length,
      itemBuilder: Element,
    );
  }
}
