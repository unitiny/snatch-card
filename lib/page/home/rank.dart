import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/component/CommonAppBar.dart';
import 'package:snatch_card/component/MyDialog.dart';
import 'package:snatch_card/component/UserAvatar.dart';

class Score {
  int userId;
  int score;
  int gametimes;
  int rank;
  String nickName;
  String image;

  Score(this.userId, this.nickName, this.image, this.score, this.gametimes,
      this.rank);

  Future getNickName(String token) async {
    try {
      String url = "${API.search}?id=$userId";
      Response res = await HttpRequest().GETByToken(url, token);
      print(res.data);
      nickName = res.data["nickname"];
    } catch (e) {
      print(e);
    }
  }
}

class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _CreateRoomPage();
}

class _CreateRoomPage extends State<RankPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CommonAppBar(title: "排行榜"),
      body: Center(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: GameColor.theme,
            child: const Column(children: [
              // Expanded(flex: 13, child: Header()),
              Expanded(flex: 75, child: Body()),
              Expanded(flex: 5, child: Footer()),
            ])),
      ),
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
    return const ScoreRank();
  }
}

class ScoreRank extends StatefulWidget {
  const ScoreRank({super.key});

  @override
  State<ScoreRank> createState() => _ScoreRankState();
}

class _ScoreRankState extends State<ScoreRank> {
  int pageIndex = 1;
  int pageSize = 10;
  List<Score> scoreRanks = [];

  Future getRanks() async {
    try {
      String url = "${API.getRanks}?pageIndex=$pageIndex&pageSize=$pageSize";
      Response res = await HttpRequest().GETByToken(url, token(context));
      print(res.data);

      List<Score> temp = [];
      for (var elem in res.data["data"]) {
        Score score = Score(elem["id"], elem["nickName"], elem["image"],
            elem["score"], elem["gametimes"], 1);
        temp.add(score);
      }
      setState(() {
        scoreRanks.addAll(temp);
      });
    } catch (e) {
      print(e);
      MyDialog().lightTip(context, "获取排行榜失败", canPop: false);
      // var res = getErr(e);
      // MyDialog().lightTip(context, "${res["err"]}");
    }
  }

  List<TableRow> ranks() {
    List<TableRow> res = [];
    for (var i = 0; i < scoreRanks.length; i++) {
      User user = User(avatar: scoreRanks[i].image);
      res.add(TableRow(children: [
        TableCell(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(children: [
            UserAvatar(size: 40, user: user),
            const SizedBox(width: 2),
            SizedBox(
              width: 70,
              child: Text(scoreRanks[i].nickName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.clip)),
            )
          ]),
        )),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text(scoreRanks[i].score.toString(),
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text("${scoreRanks[i].gametimes}",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Text("${i + 1}",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ]));
    }
    return res;
  }

  @override
  void initState() {
    super.initState();
    getRanks();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: pageWidth(context),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // const Text(
            //   "排行榜",
            //   style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 16.0),
            // const Divider(color: Colors.black, thickness: 2, height: 1),
            Table(
              columnWidths: const {
                0: FixedColumnWidth(120), // 第一列宽度为100
              },
              children: const [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "用户",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "分数",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "局数",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          "排名",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(120), // 第一列宽度为100
                },
                children: [...ranks()],
              ),
            )),
            const SizedBox(height: 16.0),
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
