import 'dart:convert';
import 'package:dio/dio.dart';
import '../page/game/game.dart';
import '../page/room/room.dart';
import '../page/home/home.dart';
import '../page/user/user.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/class/chat.dart';
import 'package:snatch_card/class/router.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/page/home/chat.dart';
import 'package:snatch_card/page/home/comment.dart';
import 'package:snatch_card/page/home/rank.dart';
import 'package:snatch_card/page/user/login.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/source/rabbitmq.dart';

import 'package:snatch_card/component/Rule.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mutex/mutex.dart';
import 'package:snatch_card/component/BackBtn.dart';
import 'package:snatch_card/component/CommonAppBar.dart';
import 'package:snatch_card/component/DraggableFab.dart';
import 'package:snatch_card/component/DropInput.dart';
import 'package:snatch_card/component/IconText.dart';
import 'package:snatch_card/component/MyDialog.dart';
import 'package:snatch_card/component/OtherOperators.dart';
import 'package:snatch_card/component/Reconnect.dart';
import 'package:snatch_card/component/Rule.dart';
import 'package:snatch_card/component/ShowToast.dart';
import 'package:snatch_card/component/StartGame.dart';
import 'package:snatch_card/component/UserAvatar.dart';

class RouterPage extends StatefulWidget {
  const RouterPage({super.key, this.pageIndex, this.title});

  final int? pageIndex;
  final String? title;

  @override
  State<RouterPage> createState() => _RouterPageState();
}

class _RouterPageState extends State<RouterPage> {
  MyRouter router = MyRouter();
  AudioPlayer player = AudioPlayer();
  GlobalKey<RuleState> windowKey = GlobalKey();

  // 检查用户状态,做登录，重连
  Future checkState() async {
    bool isLogin = await checkLogin();
    if (!isLogin && mounted) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false);
      return;
    }

    /*
    重连逻辑：
    1 router判断是否有连接，有则跳到房间页
    2 房间页显示重连按钮，点击后用userWS请求游戏状态
      在房间则渲染房间信息，在游戏则跳转
    3 进入游戏页主动请求游戏信息渲染
     */

    Room room = GlobalData().room(context);
    User user = GlobalData().user(context);
    // startWorldChat("chat.${user.id}");

    // 重连游戏，都跳到房间页面。用户点重连时再判断在房间还是游戏中
    Map<String, dynamic> connInfo = await checkUserState();
    print("用户连接信息: $connInfo");

    // 设置房间号，用户状态，重连ws
    if (room.id == 0 &&
        room.roomOwnerId == 0 &&
        connInfo["roomID"] != null &&
        connInfo["roomID"] != "" &&
        mounted) {
      // 重连WS,也可放在房间重连按钮那里重连
      await connectRoom(context);

      // 默认游戏中，使房间页面显示重连按钮
      room.roomId = int.parse(connInfo["roomID"]);
      user.serverState = UserState.inGame;
      user.setState(UserState.inGame);
      room.state = RoomState.start;

      setState(() {
        router.currentPage = 1; // 跳转到房间页
      });
    }
  }

  // 检查是否登录
  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("[token]:${prefs.getString('token')}"); // 获取用户信息

    if (prefs.getString('token') != null) {
      var payload = parseToken(prefs.getString('token')!);
      await getUser(prefs.getString('token')!, payload);

      final currentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTimeStamp > payload["exp"]) {
        return false;
      }
      return true;
    }
    return false;
  }

  // 检查是否游戏中
  Future<Map<String, dynamic>> checkUserState() async {
    try {
      Response res =
          await HttpRequest().GETByToken(API.getConnInfo, token(context));
      return res.data as Map<String, dynamic>;
    } catch (e) {
      print(e);
      MyDialog().lightTip(context, "获取游戏状态失败", canPop: false);
      return {};
    }
  }

  // 开启世界聊天
  Future<dynamic> startWorldChat(String queue) async {
    pushChat(String msg) {
      print("rabbitmqMsg: $msg");
      Map<String, dynamic> message = json.decode(msg);
      Chat chat = Chat(0, message["content"]["userID"], message["content"]["nickName"],
          message["content"]["image"], message["content"]["time"], message["content"]["content"]);

      // GlobalData().chatList(context).add(chat);
    }

    RabbitMQ().consumer("twenty_game.chat", queue, "chat", pushChat);
  }

  Future getUser(String token, Map<String, dynamic> payload) async {
    String url = "${API.search}?id=${payload["ID"]}";
    try {
      Response res = await HttpRequest().GETByToken(url, token);
      if (mounted) {
        GlobalData().user(context).update(
            id: res.data["id"],
            nickname: res.data["nickname"],
            username: res.data["username"],
            gender: res.data["gender"],
            avatar: res.data["image"],
            state: UserState.inHome,
            token: token);
      }
    } catch (e) {
      print(e);
    }
  }

  void onPress() {
    if (GlobalData().debug) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GamePage(),
          ),
          (route) => false);
    }
  }

  Widget chat() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        child: const Row(children: [
          Icon(Icons.chat, size: 30, color: Colors.black54),
        ]));
  }

  Widget rank() {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RankPage()),
          );
        },
        child: const Icon(Icons.signal_cellular_alt,
            size: 35, color: Colors.black54));
  }

  AppBar MyAppBar() {
    return AppBar(
      backgroundColor: GameColor.theme,
      title: Text(router.pages[router.currentPage]["title"] as String),
      centerTitle: true,
      actions: [
        chat(),
        rank(),
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: '0',
              child: Text('留言板'),
            ),
            const PopupMenuItem(
              value: '1',
              child: Text('游戏规则'),
            ),
          ],
          onSelected: (value) {
            if (value == '0') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CommentPage()),
              );
            } else if (value == '1') {
              windowKey.currentState!.tap();
            }
          },
          icon: const Icon(Icons.add_circle_outline_rounded,
              size: 35, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    router = GlobalData().router(context);
    router.currentPage = widget.pageIndex ?? 0;
    router.pages = [
      {"page": const HomePage(), "title": "Snatch Card"},
      {"page": const RoomPage(), "title": "Snatch Card"},
      {"page": const UserPage(), "title": "Snatch Card"},
      // {"page": GamePage(), "title": "Snatch Card"},
    ];

    router.pages[router.currentPage]["title"] =
        widget.title != null ? widget.title as String : "Snatch Card";

    video(player, Asset.background, isloop: true);
    checkState();
  }

  @override
  void dispose() {
    player.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: router.currentPage,
        onTap: (index) {
          setState(() {
            router.currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "大厅"),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: "房间"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "用户"),
          // BottomNavigationBarItem(icon: Icon(Icons.abc), label: "room1"),
          // BottomNavigationBarItem(icon: Icon(Icons.games), label: "game"),
        ],
      ),
      appBar: MyAppBar(),
      body: Center(
          child: Stack(
        children: [
          router.pages[router.currentPage]["page"] as Widget,
          Rule(
            key: windowKey,
            show: router.currentPage == 1 &&
                GlobalData().room(context).id != 0 &&
                router.showRuleNum < 1,
            callback: () {
              router.showRuleNum++;
            },
          )
        ],
      )),
      floatingActionButton:
          GlobalData().debug ? OtherOperators(callback: onPress) : null,
    );
  }
}
