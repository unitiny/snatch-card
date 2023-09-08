import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/page/room/createRoom.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/component/StartGame.dart';
import 'package:snatch_card/component/IconText.dart';
import 'package:snatch_card/component/MyDialog.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    setUseState(context, UserState.inHome);
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
    return const Column(children: [
      Expanded(flex: 9, child: CreateBtn()),
      Expanded(flex: 0, child: StartGame())
    ]);
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
  Timer? timer;

  void getRoomList() async {
    if (token(context) == "") {
      return;
    }
    Response res =
        await HttpRequest().GETByToken(API.getRoomList, token(context));
    if (res.statusCode == HTTPStatus.OK) {
      if (res.data["data"] == null) {
        return;
      }
      List<Room> rooms = [];
      for (var room in res.data["data"]) {
        // playersId 不需要在这里获取
        rooms.add(Room(
            roomId: room["roomID"],
            totalNum: room["maxUserNumber"],
            curNum: room["users"].length,
            roomOwnerId: room["roomOwner"],
            roomName: room["roomName"],
            round: room["gameCount"],
            state: room["roomWait"] ? RoomState.wait : RoomState.start,
            playersId: []));
      }
      if (mounted) {
        setState(() {
          allRoom = rooms;
          roomList = rooms;
        });
      }
    }
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

  void refresh() {
    getRoomList();
  }

  @override
  void initState() {
    super.initState();
    getRoomList();
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      refresh();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.85,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: Column(
        children: [
          Expanded(flex: 2, child: Search(callback: getSearch)),
          Expanded(
              flex: 8,
              child: RoomList(
                callback: refresh,
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
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                      onPressed: () {
                        widget.callback;
                      },
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
  const RoomList({super.key, this.roomList, this.callback});

  final List<Room>? roomList;
  final void Function()? callback;

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final ScrollController _scrollController = ScrollController();

  Widget _initElement(BuildContext context, int index) {
    return RoomElement(widget.roomList![index]);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        widget.callback!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: pageWidth(context) * 0.85,
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        decoration: const BoxDecoration(
            color: GameColor.background2,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView.builder(
            controller: _scrollController,
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
  // 这里代码写得有点乱，请求嵌套太多了
  void joinRoom() async {
    // 检查是否已在房间，否则要求退房再加入
    // if(GlobalData().user(context).state != UserState.inHome) {
    //   MyDialog().lightTip(context, "请先退出房间");
    //   return;
    // }
    MyDialog().waitDialog(context);
    String url = "${API.selectRoom}?room_id=${widget.room.roomId}";
    await HttpRequest().GETByToken(url, token(context)).then((res) async {
      // ignore: use_build_context_synchronously
      if (mounted) {
        url =
            "http://${res.data["server"]["serverInfo"]}${API.joinRoom}?room_id=${widget.room.roomId}";
        await HttpRequest()
            .PUTByToken(url, token(context), {}, otherUrl: url)
            .then((value) {
          // 建立连接
          User user = GlobalData().user(context);
          setUseState(context, UserState.inRoomReady);
          bool isConnect = GlobalData().userWS(context).connectWS(user,
              res.data["server"]["serverInfo"], widget.room.roomId.toString());
          GlobalData().room(context).id = widget.room.roomId;

          if (!isConnect) {
            MyDialog().lightTip(context, "网络连接失败");
            return;
          }
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return PageRouter.RouterPage(pageIndex: 1, title: widget.room.roomName);
          }), (route) => false);

        }).catchError((error) {
          var res = getErr(error);
          MyDialog().lightTip(context, "${res["err"]}");
        });

      }
    }).catchError((e) {
      var res = getErr(e);
      MyDialog().lightTip(context, "${res["err"]}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
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
                                  "${widget.room.curNum}/${widget.room.totalNum}",
                              space: 4),
                        ),
                        Expanded(
                          flex: 3,
                          child: IconText(
                              icon: const Icon(Icons.add),
                              img: widget.room.state == RoomState.wait
                                  ? Asset.radio1
                                  : Asset.radio2,
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
                onPressed: joinRoom,
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
      width: pageWidth(context) * 0.85,
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
