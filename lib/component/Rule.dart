import 'package:flutter/material.dart';
import 'package:snatch_card/component/BackBtn.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';

class Rule extends StatefulWidget {
  Rule({super.key, this.show = false, this.callback});

  bool show;
  Function()? callback;

  @override
  State<Rule> createState() => RuleState();
}

class RuleState extends State<Rule> {
  List<Map<String, String>> text = [
    {"title": "游戏介绍:", "content": "该游戏是一个多人抢牌游戏，玩家需要在限定的回合内尽可能多的得分"},
    {"title": "游戏流程:", "content": "进入游戏后，有三个阶段，1.抢卡回合 2.特殊卡回合 3.分数计算回合"},
    {
      "title": "游戏玩法:",
      "content":
      "抢卡回合中每位玩家最多抢两张普通卡和一张特殊卡\n玩家可以通过抢卡凑齐20点数得分，亦可以干扰其它玩家来获得分数\n若卡牌数大于6张，则销毁最先抢到的卡\n若自己卡堆卡牌总和大于20了（假设是X），系统会在分数计算阶段销毁该玩家的全部普通卡，并将生成一张的卡(该卡的值=X取余20)"
    },
    {
      "title": "游戏特殊卡:",
      "content":
      "红色炸弹卡:可以炸掉其他玩家卡堆里的一张卡\n黄色万能卡:选一张数字类型卡加入自己卡堆\n绿色交换卡:可以用自己一张卡与其他玩家交换\n蓝色修改卡:修改自己或者他人的数字类型卡"
    },
  ];

  List<Widget> _rules() {
    List<Widget> res = [];
    for (var elem in text) {
      res.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          elem["title"]!,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          elem["content"]!,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 8)
      ]));
    }
    return res;
  }

  void tap() {
    widget.callback!();
    setState(() {
      widget.show = !widget.show;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return const SizedBox();
    }
    return Container(
        width: pageWidth(context),
        height: pageHeight(context),
        color: GameColor.background3,
        child: Center(
          child: Container(
            width: pageWidth(context) * 0.85,
            height: pageHeight(context) * 0.85,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            decoration: BoxDecoration(
                color: GameColor.background2,
                border: Border.all(width: 2, color: Colors.black45),
                borderRadius: const BorderRadius.all(Radius.circular(20))),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "游戏规则",
                          style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    ..._rules(),
                    const SizedBox(height: 16.0),
                  ],
                ),
                Positioned(
                    bottom: 10,
                    right: 0,
                    child: BackBtn(
                        onTap: tap,
                        child: const Text(
                          "返回",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        )))
              ],
            ),
          ),
        ));
  }
}
