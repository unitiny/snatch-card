import 'package:flutter/material.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/page/user/login.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/source/globalData.dart';
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
  List<Map<String, Object>> pages = [
    {"page": HomePage(), "title": "Snatch Card"},
    {"page": RoomPage(), "title": "Snatch Card"},
    {"page": UserPage(), "title": "Snatch Card"},
    // {"page": GamePage(), "title": "Snatch Card"},
  ];

  bool checkLogin() {
    if (GlobalData().user(context).token == "") {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
        builder: (BuildContext context) {
          return LoginScreen();
        },
      ), (route) => false);
      return false;
    }
    return true;
  }

  void onPress() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const GamePage(),
        ),
        (route) => false);
  }

  @override
  void initState() {
    super.initState();
    currentPage = widget.pageIndex ?? 0;
    pages[currentPage]["title"] =
        widget.title != null ? widget.title as String : "Snatch Card";
  }

  @override
  Widget build(BuildContext context) {
    if (GlobalData().user(context).token == "") {
      return LoginScreen();
    }

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
      appBar: CommonAppBar(title: pages[currentPage]["title"] as String),
      body: Center(child: pages[currentPage]["page"] as Widget),
      floatingActionButton: OtherOperators(callback: onPress),
    );
  }
}
