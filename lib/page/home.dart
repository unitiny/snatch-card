import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snatch_card/tool/lib.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.8,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20))),
      child: const Column(
        children: [
          Expanded(flex: 2, child: Search()),
          Expanded(flex: 8, child: RoomList())
        ],
      ),
    );
  }
}

class Search extends StatefulWidget {
  const Search({super.key});

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
            const Expanded(
                flex: 7,
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GameColor.green)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: GameColor.green)),
                      labelText: '房间号',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                    ),
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
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final List<String> entries = <String>[
    'A',
    'B',
    'C',
    'A',
    'B',
    'C',
    'A',
    'B',
    'C'
  ];
  final List<int> colorCodes = <int>[
    600,
    500,
    100,
    600,
    500,
    100,
    600,
    500,
    100
  ];

  Widget _initElement(BuildContext context, int index) {
    return RoomElement(entries[index], colorCodes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: pageWidth(context) * 0.8,
        padding: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
            color: GameColor.background2,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: entries.length,
            itemBuilder: _initElement));
  }
}

class RoomElement extends StatefulWidget {
  const RoomElement(this.value, this.colorCode, {super.key});

  final String value;
  final int colorCode;

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
          const Expanded(
              flex: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  Row(
                    children: [
                      IconText(icon: Icons.home, text: "1306"),
                      IconText(icon: Icons.group, text: "3/6"),
                      IconText(img: Source.radio, text: "待开始"),
                    ],
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
                    // //边框颜色
                    // side: BorderSide(
                    //   color: Colors.deepPurple,
                    //   width: 1,
                    // ),
                    //边框圆角
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
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, this.icon, this.text, this.img});

  final IconData? icon;
  final String? text;
  final String? img;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon != null
            ? Icon(icon, color: Colors.green)
            : SizedBox(width: 15,height: 15,child: SvgPicture.asset(img!, width: 15, height: 15)),
        Text(text!),
        const SizedBox(
          width: 4,
        )
      ],
    );
  }
}
