// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/page/createRoom.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: const RoomCard(),
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
    return const CreateBtn();
  }
}

class RoomCard extends StatefulWidget {
  const RoomCard({super.key});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  String? searchText = "";
  List<Room> allRoom = [];
  List<Room> roomList = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 10; i++) {
      allRoom.add(Room.randRoom());
    }
    roomList = allRoom;
  }

  void getSearch(value) {
    setState(() {
      searchText = value;
      roomList = allRoom
          .where((e) =>
              e.roomId.toString().contains(searchText!) ||
              e.roomName.contains(searchText!))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.8,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          Expanded(flex: 2, child: Search(callback: getSearch)),
          Expanded(
              flex: 8,
              child: RoomList(
                roomList: roomList,
              ))
        ],
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key, this.callback});

  final ValueChanged<String>? callback;

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 7,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GameColor.green)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GameColor.green)),
                      labelText: '房间号或房间名字',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
                    onChanged: widget.callback,
                  ),
                )),
            Expanded(
                flex: 3,
                child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        backgroundColor: GameColor.green,
                        shape: const RoundedRectangleBorder(
                          //边框圆角
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "搜索",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    )))
          ],
        ));
  }
}

class RoomList extends StatefulWidget {
  const RoomList({super.key, this.roomList});

  final List<Room>? roomList;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  Widget _initElement(BuildContext context, int index) {
    return RoomElement(widget.roomList![index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: pageWidth(context) * 0.8,
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        decoration: const BoxDecoration(
            color: GameColor.background2,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: widget.roomList!.length,
            itemBuilder: _initElement));
  }
}

class RoomElement extends StatefulWidget {
  const RoomElement(this.room, {super.key});

  final Room room;

  @override
  State<RoomElement> createState() => _RoomElementState();
}

class _RoomElementState extends State<RoomElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.room.roomName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Container(
                    margin: const EdgeInsets.only(right: 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: IconText(
                            icon: const Icon(Icons.home, color: Colors.green),
                            text: "${widget.room.roomId}",
                            space: 4,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: IconText(
                              icon:
                                  const Icon(Icons.group, color: Colors.green),
                              text:
                                  "${widget.room.playersId?.length}/${widget.room.totalNum}",
                              space: 4),
                        ),
                        Expanded(
                          flex: 3,
                          child: IconText(
                              icon: const Icon(Icons.add),
                              img: widget.room.state == RoomState.wait
                                  ? Source.radio1
                                  : Source.radio2,
                              text: widget.room.state == RoomState.wait
                                  ? "待开始"
                                  : "游戏中",
                              space: 4),
                        ),
                      ],
                    ),
                  )
                ],
              )),
          Expanded(
              flex: 3,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: GameColor.green,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "加入",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ))
        ],
      ),
    );
  }
}

class CreateBtn extends StatefulWidget {
  const CreateBtn({super.key});

  @override
  State<CreateBtn> createState() => _CreateBtnState();
}

class _CreateBtnState extends State<CreateBtn> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.8,
      margin: const EdgeInsets.all(10),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateRoomPage()),
                  );
                },
                child: const Text(
                  "创建房间",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ))),
    );
  }
}
