import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/component.dart';

class CreateRoomPage extends StatefulWidget {
  const CreateRoomPage({super.key});

  @override
  State<CreateRoomPage> createState() => _CreateRoomPage();
}

class _CreateRoomPage extends State<CreateRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: GameColor.theme,
          child: const Column(children: [
            Expanded(flex: 13, child: Header()),
            Expanded(flex: 75, child: Body()),
            Expanded(flex: 12, child: Footer()),
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
  List<String> peopleItems = ['Item 1', 'Item 2', 'Item 3', 'Item 4', 'Item 5'];
  List<String> roundItems = [
    'round 1',
    'round 2',
    'round 3',
    'round 4',
    'round 5'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
        child: Column(
          children: [
            const SizedBox(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: GameColor.border, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 2)),
                  labelText: '房间号',
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
                height: 50, child: DropInput(name: "总人数", items: peopleItems)),
            const SizedBox(height: 20),
            SizedBox(
                height: 50, child: DropInput(name: "回合数", items: roundItems)),
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
                          "创建房间",
                          style: TextStyle(fontSize: 16, color: Colors.black),
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
                        onPressed: () {},
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

