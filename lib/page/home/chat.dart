import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/class/chat.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/component/CommonAppBar.dart';
import 'package:snatch_card/component/MyDialog.dart';
import 'package:snatch_card/component/UserAvatar.dart';

/// 已取消
/// rabbitmq实现逻辑：
/// 登录后后台开启消费者监听，将消息写入全局聊天列表中
/// 进入该页面每次下滑获取最新的10条信息
///
/// 使用长轮询方案
/// 用户首次进入同步聊天信息，然后开启长轮询监听最新消息
/// 每次监听完再开启下一轮长轮询，每次退出销毁长轮询请求

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _CreateRoomPage();
}

class _CreateRoomPage extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBar(title: "世界聊天"),
      body: Center(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: GameColor.theme,
            child: const Column(children: [
              // Expanded(flex: 13, child: Header()),
              Expanded(flex: 75, child: Body()),
              Expanded(flex: 3, child: Footer()),
            ])),
      ),
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
    return Container(
      padding: const EdgeInsets.all(2),
      child: const Image(image: AssetImage(Asset.logo)),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isListen = true;
  List<Chat> list = [];
  CancelToken cancelToken = CancelToken();

  void getChatList() async {
    try {
      // String url = "http://127.0.0.1:9006${API.chatList}";
      Response res =
          await HttpRequest().GETByToken(API.chatList, token(context));

      List<Chat> tmp = [];
      for (var elem in res.data) {
        var data = elem["content"];
        Chat chat = Chat(data["id"], data["user_id"], data["nickName"],
            data["image"], data["time"], data["content"]);
        tmp.add(chat);
      }
      setState(() {
        list = tmp;
      });
    } catch (e) {
      print(e);
      MyDialog().lightTip(context, "获取聊天记录失败", canPop: false);
    }
  }

  Future<dynamic> listen() async {
    while (isListen) {
      try {
        // String url = "http://127.0.0.1:9006${API.listen}";
        Response res = await HttpRequest()
            .GETByToken(API.listen, token(context), cancelToken: cancelToken);

        // if(!mounted) {
        //   continue;
        // }
        setState(() {
          var data = res.data["content"];
          Chat chat = Chat(data["id"], data["user_id"], data["nickName"],
              data["image"], data["time"], data["content"]);
          list.add(chat);
        });
      } catch (e) {
        print(e);
        MyDialog().lightTip(context, "获取最新聊天记录失败", canPop: false);
      }
    }
    return "listen";
  }

  @override
  void initState() {
    super.initState();
    getChatList();
    listen(); // 长轮询
  }

  @override
  void dispose() async {
    super.dispose();
    list = [];

    // 销毁异步网络请求
    isListen = false;
    cancelToken.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 8, child: ChatListBoard(chatList: list)),
        const Expanded(flex: 1, child: SendChat()),
      ],
    );
  }
}

class ChatListBoard extends StatefulWidget {
  const ChatListBoard({super.key, this.chatList, this.callback});

  final List<Chat>? chatList;
  final void Function(int opt, int index, List<Chat> cms)? callback;

  @override
  State<ChatListBoard> createState() => _ChatListBoardState();
}

class _ChatListBoardState extends State<ChatListBoard> {
  final ScrollController _scrollController = ScrollController();

  Widget _initElement(BuildContext context, int index) {
    return ChatElement(index, widget.chatList![index],
        callback: widget.callback);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 下滑到最底部
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
    return Container(
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: widget.chatList?.length ?? 0,
            itemBuilder: _initElement));
  }
}

class ChatElement extends StatefulWidget {
  const ChatElement(this.index, this.chat, {super.key, this.callback});

  final int index;
  final Chat chat;
  final void Function(int opt, int index, List<Chat> cms)? callback;

  @override
  State<ChatElement> createState() => _ChatElementState();
}

class _ChatElementState extends State<ChatElement> {
  @override
  Widget build(BuildContext context) {
    User user = User(
        id: widget.chat.userId,
        nickname: widget.chat.nickName,
        avatar: widget.chat.image);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all()),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // 设置圆角的半径
                  child: UserAvatar(user: user, size: 50))),
          const SizedBox(height: 10),
        ]),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(user.nickName!,
                  style: const TextStyle(
                      fontSize: 16, overflow: TextOverflow.ellipsis)),
              Text(widget.chat.time,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal, fontSize: 16))
            ]),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  color: user.id == GlobalData().user(context).id
                      ? GameColor.green
                      : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(10))),
              child: Text(widget.chat.content,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 20)),
            )
          ],
        ))
      ],
    );
  }
}

class SendChat extends StatefulWidget {
  const SendChat({super.key, this.callback});

  final Function(int opt, int index, List<Chat> cms)? callback;

  @override
  State<SendChat> createState() => _SendChatState();
}

class _SendChatState extends State<SendChat> {
  String message = "";
  final TextEditingController _editController = TextEditingController();

  Chat chatMsg(int userId, String nickname, String image, String content) {
    return Chat(0, userId, nickname, image, "", content);
  }

  void sendMessage() {
    if (message != "") {
      User user = GlobalData().user(context);
      Chat chat = chatMsg(user.id, user.nickName!, user.avatar!, message);
      sendChat(chat);
      setState(() {
        message = "";
        _editController.clear();
        FocusScope.of(context).unfocus();
        // dropMessage();
      });
    }
  }

  void sendChat(Chat cm) async {
    try {
      // String url = "http://127.0.0.1:9006${API.chatAdd}";
      Response res = await HttpRequest().POSTByToken(
          API.chatAdd,
          token(context),
          FormData.fromMap({
            "user_id": cm.userId,
            "nickName": cm.nickName,
            "image": cm.image,
            "content": cm.content
          }));

      // widget.callback!(0, 0, [cm]);
      MyDialog().lightTip(context, "发送成功", canPop: false, display: 300);
    } catch (e) {
      print(e);
      MyDialog().lightTip(context, "发送失败", canPop: false);
      // var res = getErr(e);
      // MyDialog().lightTip(context, "${res["err"]}");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.9,
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
        color: GameColor.dialog1,
        borderRadius: BorderRadius.circular(10),
      ),
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onPressed: sendMessage,
                    child: const Text(
                      "发送",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )))
        ],
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
    return Container();
  }
}
