import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snatch_card/source/userWS.dart';
import 'package:snatch_card/source/rootData.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/tool/lib.dart';
import 'package:snatch_card/tool/component.dart';
import 'package:snatch_card/class/room.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/source/http.dart';
import 'package:snatch_card/source/globalData.dart';
import 'package:snatch_card/router/router.dart' as PageRouter;
import 'package:supercharged/supercharged.dart';

class Comment {
  int id;
  int userId;
  int like = 0;
  String nickName;
  String time;
  String content;

  Comment(this.id, this.userId, this.nickName, this.time, this.content);
}

class CommentPage extends StatefulWidget {
  const CommentPage({super.key});

  @override
  State<CommentPage> createState() => _CreateRoomPage();
}

class _CreateRoomPage extends State<CommentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppBar(title: "留言板"),
      body: Center(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: GameColor.theme,
            child: const Column(children: [
              Expanded(flex: 13, child: Header()),
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
  int page = 1;
  int size = 10;
  List<Comment> list = [];

  Future<dynamic> commentList() async {
    try {
      String url = "${API.commentList}?page=$page&size=$size";
      Response res = await HttpRequest().GETByToken(url, token(context));

      List<Comment> temp = [];
      for (var elem in res.data) {
        Comment cm = Comment(elem["id"], elem["userId"], elem["nickName"],
            elem["time"], elem["content"]);
        temp.add(cm);
      }

      setState(() {
        list.addAll(temp);
      });
    } catch (e) {
      print(e);
      MyDialog().lightTip(context, "获取评论失败", canPop: false);
      // var res = getErr(e);
      // MyDialog().lightTip(context, "${res["err"]}");
    }
    return [];
  }

  sendComment(Comment cm) async {
    try {
      Response res = await HttpRequest().POSTByToken(API.commentAdd, token(context), FormData.fromMap({
        "nickName": cm.userId,
        "content": cm.content
      }));
      MyDialog().lightTip(context, "发送成功", canPop: false);
    }catch(e) {
      print(e);
      MyDialog().lightTip(context, "添加评论失败", canPop: false);

      // var res = getErr(e);
      // MyDialog().lightTip(context, "${res["err"]}");
    }
  }

  @override
  void initState() {
    super.initState();
    commentList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 8, child: CommentList(commentList: list)),
        Expanded(flex: 1, child: SendComment(callback: sendComment)),
      ],
    );
  }
}

class CommentList extends StatefulWidget {
  const CommentList({super.key, this.commentList, this.callback});

  final List<Comment>? commentList;
  final void Function()? callback;

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final ScrollController _scrollController = ScrollController();

  Widget _initElement(BuildContext context, int index) {
    return CommentElement(widget.commentList![index]);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        // widget.callback!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 15, bottom: 10),
        child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: widget.commentList?.length ?? 0,
            itemBuilder: _initElement));
  }
}

class CommentElement extends StatefulWidget {
  const CommentElement(this.comment, {super.key});

  final Comment comment;

  @override
  State<CommentElement> createState() => _CommentElementState();
}

class _CommentElementState extends State<CommentElement> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.comment.nickName,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(widget.comment.time,
              style:
                  const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
          const SizedBox(height: 20),
          Text(widget.comment.content,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}

class SendComment extends StatefulWidget {
  const SendComment({super.key, this.callback});
  final Function(Comment cm)? callback;

  @override
  State<SendComment> createState() => _SendCommentState();
}

class _SendCommentState extends State<SendComment> {
  String message = "";
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _editController = TextEditingController();

  Comment commentMsg(int userId, String nickname, String content) {
    return Comment(0, userId, nickname, "", content);
  }

  void sendMessage() {
    if (message != "") {
      User user = GlobalData().user(context);
      Comment cm = commentMsg(user.id, user.nickName!, message);
      widget.callback!(cm);
      setState(() {
        message = "";
        _editController.clear();
        FocusScope.of(context).unfocus();
        // dropMessage();
      });
    }
  }

  void dropMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: pageWidth(context) * 0.9,
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
      decoration: BoxDecoration(
        color: GameColor.dialog1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
              flex: 7,
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _editController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GameColor.green)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: GameColor.green)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                  onChanged: (value) {
                    message = value;
                  },
                  onEditingComplete: sendMessage,
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
              flex: 3,
              child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      backgroundColor: GameColor.green,
                      shape: const RoundedRectangleBorder(
                        //边框圆角
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                    onPressed: sendMessage,
                    child: const Text(
                      "添加评论",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )))
        ],
      ),
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
    return Container();
  }
}
