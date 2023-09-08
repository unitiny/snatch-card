import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/component/ChatBubble.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

/// 聊天设计
/// 组件本身有打开关闭功能
/// 选择某一快捷消息后，触发回调函数，传入需要的数据
/// 回调函数通过userWS，发送广播消息
/// 收到消息触发Selector，将用户聊天展示组件重新渲染

class ChatTool extends StatefulWidget {
  const ChatTool({super.key});

  @override
  State<ChatTool> createState() => _ChatToolState();
}

class _ChatToolState extends State<ChatTool> {
  List<String> chatMsg = [
    "666",
    "哎哟",
    "厉害",
    "无敌！",
    "祝你好运",
    "别搞我了",
  ];

  List<Widget> chatElements() {
    List<Widget> list = [];
    for (var i = 0; i < chatMsg.length; i++) {
      list.add(GestureDetector(
          onTap: () {
            GlobalData().userWS(context).chatMsg({"content": chatMsg[i]});
            RootData.of(context)?.data["changeChatShow"]();
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(chatMsg[i],
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 18))
            ]),
          )));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          RootData.of(context)?.data["changeChatShow"]();
        },
        child: Container(
            width: pageWidth(context),
            height: pageHeight(context),
            color: GameColor.background3,
            child: Column(
              children: [
                SizedBox(height: pageHeight(context) * 0.6),
                InkWell(
                    onTap: () {
                      print("object");
                    },
                    child: Center(
                      child: Container(
                          width: pageWidth(context) * 0.9,
                          height: pageHeight(context) * 0.2,
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          decoration: BoxDecoration(
                              color: GameColor.background2,
                              border:
                                  Border.all(width: 2, color: Colors.black45),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              double aspectRatio = 1.0; // 默认值
                              if (constraints.maxWidth > 0 &&
                                  constraints.maxHeight > 0) {
                                var width = constraints.maxWidth / 3;
                                var height = constraints.maxHeight / 2;
                                aspectRatio = width / height;
                              }
                              return GridView.count(
                                mainAxisSpacing: 0,
                                crossAxisSpacing: 0,
                                crossAxisCount: 3,
                                childAspectRatio: aspectRatio,
                                children: chatElements(),
                              );
                            },
                          )),
                    ))
              ],
            )));
  }
}

/// 聊天展示组件：独立一层铺满屏幕，默认透明隐藏且点击穿透。
/// 显示时根据用户头像位置展示。头像位置构建完成后获取
class ShowChatMsg extends StatefulWidget {
  const ShowChatMsg({super.key});

  @override
  State<ShowChatMsg> createState() => _ShowChatMsgState();
}

class _ShowChatMsgState extends State<ShowChatMsg> {
  List<Widget> chatList = [];
  Timer? _timer;
  bool inRemove = false;

  void addChat(String msg, Offset offset) {
    if (msg == "" || offset.dx == 0 && offset.dy == 0) {
      return;
    }
    chatList.add(
        ChatBubble(message: msg, left: offset.dx + 30, top: offset.dy - 70));
    removeChat();
  }

  // 每秒移除一个消息
  void removeChat() async {
    _timer = Timer(const Duration(milliseconds: 1200), () {
      inRemove = true;
      if (mounted) {
        setState(() {
          chatList = [];
        });
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: GameColor.empty,
        child: Selector<UserWS, UserWS>(
            shouldRebuild: (pre, next) =>
                next.isNotify(ServiceType.chatResponseType),
            selector: (context, provider) => provider,
            builder: (context, userWS, child) {
              var userid = userWS.store["talkerID"];
              if (userid == null || userWS.store["chatMsg"] == null) {
                return Container(); // 第一次初始化不展示
              }

              // 移除状态能防止循环触发addChat
              if (!inRemove) {
                Offset offset =
                    RootData.of(context)?.data["userPositionMap"][userid] ?? Offset(0, 0);
                addChat(userWS.store["chatMsg"], offset);
              } else {
                inRemove = false;
              }
              return Stack(children: chatList);
            }),
      ),
    );
  }
}
