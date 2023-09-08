import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/source/userWS.dart';

import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/class/card.dart' as GameCard;
import 'package:snatch_card/class/userCard.dart';
import 'package:snatch_card/page/game/game.dart';
import 'package:snatch_card/component/BackBtn.dart';
import 'package:snatch_card/source/globalData.dart';

class ScoreRank {
  String nickName;
  String score;
  int? rank;

  ScoreRank(this.nickName, this.score, {this.rank});

  bool compareScore(String s) {
    return int.parse(score) > int.parse(s);
  }
}

class ScoreRankDialog extends StatefulWidget {
  const ScoreRankDialog({super.key});

  @override
  State<ScoreRankDialog> createState() => _ScoreRankDialogState();
}

class _ScoreRankDialogState extends State<ScoreRankDialog> {
  List<ScoreRank> scoreRanks = [];

  List<TableRow> ranks() {
    List<TableRow> res = [];
    sortScore(scoreRanks);

    for (var i = 0; i < scoreRanks.length; i++) {
      res.add(TableRow(children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(scoreRanks[i].nickName,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(scoreRanks[i].score,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("${scoreRanks[i].rank}",
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ]));
    }
    return res;
  }

  void sortScore(List<ScoreRank> scores) {
    int n = scores.length;

    // 冒泡排序
    for (int i = 0; i < n - 1; i++) {
      for (int j = 0; j < n - i - 1; j++) {
        // 按分数从高到低排序
        if (int.parse(scores[j].score) < int.parse(scores[j + 1].score)) {
          ScoreRank temp = scores[j];
          scores[j] = scores[j + 1];
          scores[j + 1] = temp;
        }
      }
    }

    // 赋值排名
    int rank = 1;
    for (int i = 0; i < n; i++) {
      scores[i].rank = rank;
      if (i < n - 1 && scores[i].score != scores[i + 1].score) {
        rank++;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    UserWS userWS = GlobalData().userWS(context);
    for (var user in userWS.userList) {
      scoreRanks.add(ScoreRank(user.nickName!, userWS.store["score"]?[user.id]));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: pageWidth(context) * 0.85,
        height: pageHeight(context) * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        decoration: BoxDecoration(
            color: GameColor.background2,
            border: Border.all(width: 2, color: Colors.black45),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "排行榜",
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                const Divider(
                  color: Colors.black,
                  thickness: 2,
                  height: 1,
                ),
                Table(
                  children: [
                    const TableRow(
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "昵称",
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
                              "排名",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...ranks(),
                  ],
                ),
                const SizedBox(height: 16.0),
              ],
            ),
            Positioned(
                bottom: 10,
                right: 0,
                child: BackBtn(
                    onTap: () {
                      // 服务器用户状态暂时在这修改
                      GlobalData().user(context).serverState = UserState.inRoom;
                      GlobalData().user(context).state = UserState.inRoom;
                      UserWS userWS = GlobalData().userWS(context);
                      userWS.clean();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PageRouter.RouterPage(
                              pageIndex: 1,
                              title: GlobalData().room(context).roomName,
                            ),
                          ),
                          (route) => false);
                    },
                    child: const Text(
                      "退出游戏",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    )))
          ],
        ),
      ),
    );
  }
}
