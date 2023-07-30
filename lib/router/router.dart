import 'package:flutter/material.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/user/login.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:audioplayers/audioplayers.dart';
import '../page/game/game.dart';
import '../page/room/room.dart';
import '../page/home/home.dart';
import '../page/user/user.dart';

class Router extends StatefulWidget {
  const Router({super.key, this.pageIndex, this.title});

  final int? pageIndex;
  final String? title;

  @override
  State<Router> createState() => _RouterState();
}

class _RouterState extends State<Router> {
  int currentPage = 0;
  AudioPlayer player = AudioPlayer();
  GlobalKey<RuleState> windowKey = GlobalKey();
  List<Map<String, Object>> pages = [
    {"page": const HomePage(), "title": "Snatch Card"},
    {"page": const RoomPage(), "title": "Snatch Card"},
    {"page": const UserPage(), "title": "Snatch Card"},
    // {"page": GamePage(), "title": "Snatch Card"},
  ];

  Future<bool> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("[token]:${prefs.getString('token')}");
    if (prefs.getString('token') != null) {
      var payload = parseToken(prefs.getString('token')!);
      getUser(prefs.getString('token')!, payload);
      final currentTimeStamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (currentTimeStamp > payload["exp"]) {
        return false;
      }
      return true;
    }
    return false;
  }

  void getUser(String token, Map<String, dynamic> payload) async {
    String url = "${API.search}?id=${payload["ID"]}";
    HttpRequest().GETByToken(url, token).then((res) {
      GlobalData().user(context).update(
          id: res.data["id"],
          nickname: res.data["nickname"],
          username: res.data["username"],
          gender: res.data["gender"],
          avatar: res.data["image"],
          state: UserState.inHome,
          token: token);
    });
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

  AppBar MyAppBar() {
    return AppBar(
      backgroundColor: GameColor.theme,
      title: Text(pages[currentPage]["title"] as String),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: '0',
              child: Text('游戏规则'),
            ),
          ],
          onSelected: (value) {
            if (value == '0') {
              windowKey.currentState!.tap();
            }
          },
          icon: const Icon(Icons.keyboard_control_rounded, size: 35),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.pageIndex ?? 0;
    pages[currentPage]["title"] =
        widget.title != null ? widget.title as String : "Snatch Card";

    video(player, Asset.background, isloop: true);
    checkLogin().then((isLogin) {
      if (!isLogin) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
            (route) => false);
      }
    });
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
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: "room"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "user"),
          // BottomNavigationBarItem(icon: Icon(Icons.abc), label: "room1"),
          // BottomNavigationBarItem(icon: Icon(Icons.games), label: "game"),
        ],
      ),
      appBar: MyAppBar(),
      body: Center(
          child: Stack(
        children: [
          pages[currentPage]["page"] as Widget,
          Rule(
              key: windowKey,
              show: currentPage == 1 && GlobalData().room(context).id != 0)
        ],
      )),
      floatingActionButton:
          GlobalData().debug ? OtherOperators(callback: onPress) : null,
    );
  }
}
