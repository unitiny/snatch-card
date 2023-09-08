import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/chat.dart';
import 'package:snatch_card/class/router.dart';

// ignore: library_prefixes
import 'router/router.dart' as PageRouter;
import 'tool/source.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => User()),
          ChangeNotifierProvider(create: (context) => Room(playersId: [])),
          ChangeNotifierProvider(create: (context) => UserWS()),
          ChangeNotifierProvider(create: (context) => MyRouter()),
        ],
        child: MaterialApp(
          title: '抢牌游戏',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: GameColor.theme),
            useMaterial3: true,
          ),
          home: const PageRouter.RouterPage(),
        ));
  }
}
