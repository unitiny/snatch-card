import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/class/rootData.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key, this.effect = 0});

  final int? effect;

  @override
  State<CreateRoomPage> createState() => _CreateRoomPage();
}

class _CreateRoomPage extends State<CreateRoomPage> {
  @override
  Widget build(BuildContext context) {
    return RootData(
        data: widget.effect as Object,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: CommonAppBar(
                title: widget.effect == 0 ? 'CreateRoom' : 'UpdateRoom'),
            body: Center(
              child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: GameColor.theme,
                  child: const Column(children: [
                    Expanded(flex: 13, child: Header()),
                    Expanded(flex: 75, child: Body()),
                    Expanded(flex: 12, child: Footer()),
                  ])),
            )));
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
      child: const Image(image: AssetImage(Source.logo)),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<int> peopleItems = [1, 2, 3, 4, 5];
  List<String> roundItems = ['1', '2', '3', '4', '5'];

  Room? room = Room();

  @override
  Widget build(BuildContext context) {
    int effect = RootData.of(context)?.data;
    return Container(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: TextField(
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: GameColor.border, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2)),
                  labelText: '房间号',
                ),
                onChanged: (value) {
                  room?.roomId = int.parse(value);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: TextField(
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                      BorderSide(color: GameColor.border, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2)),
                  labelText: '房间名',
                ),
                onChanged: (value) {
                  room?.roomName = value;
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
                height: 50,
                child: DropInput<int>(
                    name: "总人数",
                    items: peopleItems,
                    callback: (value) {
                      room?.totalNum = int.parse(value);
                    })),
            const SizedBox(height: 20),
            SizedBox(
                height: 50,
                child: DropInput(
                    name: "回合数",
                    items: roundItems,
                    callback: (value) {
                      room?.round = int.parse(value);
                    })),
            const SizedBox(height: 50),
            Container(
              width: pageWidth(context),
              height: 50,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: UnconstrainedBox(
                  child: SizedBox(
                      width: 120,
                      height: 40,
                      child: Consumer<Room>(
                        builder: (context, Room globalRoom, child) =>
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GameColor.green,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  // 更新数据
                                  Provider.of<Room>(context, listen: false)
                                      .update(
                                          roomId: room?.roomId,
                                          roomName: room?.roomName,
                                          round: room?.round,
                                          totalNum: room?.totalNum);

                                  // 跳转
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PageRouter.Router(
                                          pageIndex: 1,
                                          title: room?.roomName,
                                        ),
                                      ),
                                      (route) => false);
                                },
                                child: child),
                        child: Text(
                          effect == 0 ? "创建房间" : "更新房间",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black),
                        ),
                      ))),
            ),
            const SizedBox(height: 20),
            Container(
              width: pageWidth(context),
              height: 50,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: UnconstrainedBox(
                  child: SizedBox(
                      width: 120,
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
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "取消创建",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ))),
            ),
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
