import 'package:flutter/material.dart';
import '../page/game.dart';
import '../page/room.dart';
import '../page/home.dart';
import '../style/game_color.dart';

class Router extends StatefulWidget {
  const Router({super.key});

  @override
  State<Router> createState() => _RouterState();
}

class _RouterState extends State<Router> {
  int currentPage = 0;
  List<Widget> page = const [
    HomePage(),
    RoomPage(),
    GamePage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: GameColor.theme,
        title: const Text("Snatch Card")
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (index) {
          setState(() {
            currentPage = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "home"),
          BottomNavigationBarItem(icon: Icon(Icons.room), label: "room"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "game"),
        ],
      ),
      body: Center(
        child: page[currentPage]
      ),
    );
  }
}
