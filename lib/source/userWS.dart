import 'package:flutter/cupertino.dart';
import 'package:snatch_card/class/card.dart';
import 'package:snatch_card/class/userCard.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:snatch_card/class/user.dart';
import 'package:snatch_card/tool/source.dart';
import 'package:snatch_card/source/http.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:mutex/mutex.dart';

class Tip {
  int stateType;
  String msgData;

  Tip(this.stateType, this.msgData);
}

class UserWS extends ChangeNotifier {
  static const host = "ws://139.159.234.134:8000";
  static const socket = "/v1/connectSocket";
  final Mutex _lock = Mutex();
  WebSocketChannel? WS;
  User user = User();
  List<User> userList = [];
  Map<String, dynamic> store = {}; // 储存的数据
  List<Map<String, dynamic>> msgList = []; // 消息队列
  Map<int, Map<String, dynamic>> res = {}; // 返回的数据
  Map<int, Function(Map<String, dynamic>)> dealFunc = {};

  UserWS() {
    // 被动处理函数
    dealFunc[ServiceType.checkHealthMsg] = checkHealth;
    dealFunc[ServiceType.chatResponseType] = chatResponse;
    dealFunc[ServiceType.msgResponseType] = msgResponse;
    dealFunc[ServiceType.errResponseMsgType] = errResponse;
    dealFunc[ServiceType.stateInfoResponseType] = stateInfoResponse;
    dealFunc[ServiceType.roomInfoResponseType] = roomInfoResponse;
    dealFunc[ServiceType.kickerResponseType] = kickerResponse;
    dealFunc[ServiceType.beginGameResponseType] = beginGameResponse;
    dealFunc[ServiceType.gameStateResponseType] = gameStateResponse;
    dealFunc[ServiceType.useSpecialCardResponseType] = useSpecialCardResponse;
    dealFunc[ServiceType.useItemResponseType] = useItemResponse;
    dealFunc[ServiceType.scoreRankResponseType] = scoreRankResponse;
    dealFunc[ServiceType.gameOverResponseType] = gameOverResponse;
    dealFunc[ServiceType.grabCardRoundResponseType] = grabCardRoundResponse;
    dealFunc[ServiceType.specialCardRoundResponseType] =
        specialCardRoundResponse;
  }

  bool connectWS(User user, String host, String roomId) {
    if (host == "" || roomId == "") {
      return false;
    }
    try {
      this.user = user;
      String url = "ws://$host$socket?room_id=$roomId&token=${user.token}";
      print("[connectWS]: $url");

      Map<String, dynamic>? headers = {};
      headers["token"] = user.token;
      WS = WebSocketChannel.connect(Uri.parse(url));
      WS?.stream.listen(receiveData, onError: onError, onDone: onDone);

      // startHealth();
      return true;
    } catch (e) {
      print("[connectWS] fail: $e");
      return false;
    }
  }

  bool isNotify(int type, {int? id = 1}) {
    // print("$type, $msgList");
    if (msgList.isEmpty) {
      return false;
    }

    for (var msg in msgList) {
      // 找到对应消息，并判断是否有消费过
      if (msg["type"] == type) {
        int index = msg["consumer"].indexOf(id);
        if (index == -1) {
          msg["consumer"].add(id);
          return true;
        }
      }
    }
    return false;
  }

  void receiveData(data) async {
    print("websocket-data:$data");

    Map<String, dynamic> msg = json.decode(data);
    res[msg["msgType"]] = msg;

    // 步骤不能错，先处理完数据，再将消息加入消息队列，最后才通知组件渲染
    await dealFunc[msg["msgType"]]!({"msgType": msg["msgType"]});
    addMsg(msg["msgType"]);
    notify();
  }

  Future notify() async {
    await _lock.acquire();
    try {
      // 等待渲染完成再开始下一个通知
      await SchedulerBinding.instance.endOfFrame;
      notifyListeners();
    } finally {
      _lock.release();
    }
  }

  void onError(err) {
    print("websocket-err: $err\n");
  }

  void onDone() {
    print("websocket-onDone\n");
  }

  void send(Object data) {
    if (WS != null && WS?.closeCode == null) {
      WS?.sink.add(json.encode(data));
    }
  }

  void addMsg(int msgType) {
    // 不重要消息不放入队列
    List<int> notAddType = [ServiceType.checkHealthMsg];
    for (var type in notAddType) {
      if (type == msgType) {
        return;
      }
    }

    // 如果大于10条，清除旧消息
    if (msgList.length > 10) {
      msgList.removeRange(0, msgList.length - 10);
    }

    Map<String, dynamic> msg = {"type": msgType, "consumer": []};
    msgList.add(msg);
  }

  /*
   主动获取
   */
  void startHealth() {
    Timer.periodic(Duration(seconds: 4), (timer) {
      health({});
    });
  }

  dynamic health(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.checkHealthMsg,
    };
    send(j);
  }

  dynamic chatMsg(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.chatMsg,
      "chatMsgData": {"userID": user.id, "data": params["content"]}
    };
    send(j);
  }

  dynamic getStateMsg(Map<String, dynamic> params) {
    var j = {"type": ClientType.getState};
    send(j);
  }

  dynamic quitRoom(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.quitRoomMsg,
    };
    send(j);
    // Future.delayed(const Duration(milliseconds: 300), () {
    //   WS?.sink.close(0, "主动断开连接");
    // });
  }

  dynamic updateRoom(Map<String, dynamic> params) {
    var j = {"type": ClientType.updateRoomMsg, "updateData": params};
    send(j);
  }

  dynamic userReadyState(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.userReadyStateMsg,
      "readyStateData": {"isReady": params["isReady"]}
    };
    send(j);
  }

  dynamic getRoomMsg(Map<String, dynamic> params) {
    var j = {"type": ClientType.getRoomMsg};
    send(j);
  }

  dynamic beginGame(Map<String, dynamic> params) {
    var j = {"type": ClientType.roomBeginGameMsg};
    send(j);
    return;
  }

  dynamic grabCard(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.grabCardMsg,
      "getCardData": {"getCardID": params["cardID"]}
    };
    send(j);
    return;
  }

  dynamic useSpecialCard(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.useSpecialCardMsg,
      "useSpecialData": {
        "specialCardID": params["specialCardID"] ?? 0,
        "addCardData": {"needNumber": params["needNumber"] ?? 0},
        "updateCardData": {
          "targetUserID": params["targetUserID"] ?? 0,
          "cardID": params["cardID"] ?? 0,
          "updateNumber": params["updateNumber"] ?? 0,
        },
        "deleteCardData": {
          "targetUserID": params["targetUserID"] ?? 0,
          "cardID": params["cardID"] ?? 0,
        },
        "changeCardData": {
          "cardID": params["cardID"] ?? 0,
          "targetUserID": params["targetUserID"] ?? 0,
          "targetCard": params["targetCard"] ?? 0,
        },
      }
    };
    send(j);
    return;
  }

  dynamic getGameState(Map<String, dynamic> params) {
    var j = {
      "type": ClientType.getGameState,
    };
    send(j);
    return;
  }

  /*
   被动处理
   */
  dynamic checkHealth(Map<String, dynamic> params) {
    // print("checkHealthMsg...");
  }

  dynamic chatResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["talker"] = getUser(data["chatInfo"]["userID"]).nickName;
    store["talkerID"] = data["chatInfo"]["userID"];
    store["chatMsg"] = data["chatInfo"]["chatMsgData"];
  }

  dynamic msgResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["tip"] = Tip(data["msgInfo"]["stateType"], data["msgInfo"]["msgData"]);
  }

  dynamic errResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
  }

  dynamic stateInfoResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["state"] = data["getStateInfo"]["state"];
  }

  dynamic roomInfoResponse(Map<String, dynamic> params) async {
    Map<String, dynamic> data = res[params["msgType"]]!;
    if (data["roomInfo"]["users"] == null) {
      return;
    }

    userList = [];
    for (var user in data["roomInfo"]["users"]) {
      userList.add(User(
          id: user["ID"],
          nickname: user["nickname"],
          username: user["username"],
          gender: user["gender"],
          avatar: user["image"],
          state: user["ready"] ? UserState.inRoomReady : UserState.inRoom));
    }
  }

  dynamic kickerResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    if (user.id == data["kickerInfo"]["ID"]) {
      store["tip"] = Tip(0, "你已被踢出房间");
    }
  }

  dynamic beginGameResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["startGame"] = true;
  }

  dynamic gameStateResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;

    UserCards getUserCards(Map<String, dynamic> user) {
      UserCards cards = UserCards(userId: user["userID"]);
      for (var baseCard in user["baseCards"]) {
        cards.cards.add(Card(
            id: baseCard["CardID"],
            category: CardCategory.common,
            commonVal: baseCard["Number"].toString()));
      }

      for (var specialCard in user["specialCards"]) {
        cards.cards.add(Card(
            id: specialCard["CardID"],
            category: CardCategory.special,
            specialVal: Card().getSpecialVal(specialCard["Type"])));
      }
      return cards;
    }

    if (data["gameStateInfo"]["users"] != null) {
      // 获取用户列表
      if (userList.isEmpty) {
        userList = [];
        for (var user in data["gameStateInfo"]["users"]) {
          userList.add(User(
              id: user["userID"],
              nickname: user["nickname"],
              username: user["username"],
              gender: user["gender"],
              avatar: user["image"],
              state: UserState.inGame));
        }
      }

      // 获取用户卡牌
      Map<int, UserCards> userCards = {};
      store["score"] = {};
      for (var user in data["gameStateInfo"]["users"]) {
        userCards[user["userID"]] = getUserCards(user);
        store["score"][user["userID"]] = user["score"].toString(); // 用户分数
      }
      store["userCardsMap"] = userCards;
    }

    // 获取卡推的卡牌
    if (data["gameStateInfo"]["randCard"] != null) {
      List<Card> cards = [];
      for (var card in data["gameStateInfo"]["randCard"]) {
        if (card["type"] == 0) {
          cards.add(Card(
              id: card["cardID"],
              category: CardCategory.common,
              commonVal: card["baseCardCardInfo"]["Number"].toString(),
              hasOwner: card["hasOwner"]));
        } else {
          cards.add(Card(
              id: card["cardID"],
              category: CardCategory.special,
              specialVal: Card().getSpecialVal(card["specialCardInfo"]["Type"]),
              hasOwner: card["hasOwner"]));
        }
      }
      store["randCards"] = cards;
    }

    // 当前回合数
    store["gameCurCount"] = data["gameStateInfo"]["gameCurCount"];
    store["gameCount"] = data["gameStateInfo"]["gameCount"];
  }

  dynamic useSpecialCardResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    if (store["userCardsMap"] != null) {
      // 使用对应特殊卡
      String specialCardType =
          Card().getSpecialVal(data["useSpecialCardInfo"]["specialCardType"]);
      var userID = data["useSpecialCardInfo"]["userID"];
      User originUser = getUser(userID);

      switch (specialCardType) {
        case SpecialCardVal.redBombCard:
          // 可以炸掉其他玩家卡堆里的一张卡
          var deleteCardData = data["useSpecialCardInfo"]["deleteCardData"];
          var targetUserID = deleteCardData["targetUserID"];
          User targetUser = getUser(targetUserID);

          List<Card> cards = store["userCardsMap"][targetUserID].cards;
          bool found = false;
          String cardVal = "";
          cards.removeWhere((element) {
            if (!found) {
              if (element.id == deleteCardData["cardID"]) {
                found = true;
                cardVal = element.commonVal!;
              }
              return found;
            }
            return false;
          });

          store["userCardsMap"][targetUserID].cards = cards;
          String msgData = "${originUser.nickName}使用$specialCardType炸掉了${targetUser.nickName}的普通卡$cardVal";
          store["tip"] = Tip(1, msgData);
          break;
        case SpecialCardVal.yellowWildCard:
          // 任意选一张数字类型卡加入自己卡堆
          List<Card> cards = store["userCardsMap"][userID].cards;
          cards.add(Card(
              id: data["useSpecialCardInfo"]["addCardData"]["cardID"],
              category: CardCategory.common,
              commonVal: data["useSpecialCardInfo"]["addCardData"]["needNumber"]
                  .toString()));
          store["userCardsMap"][userID].cards = cards;
          String msgData = "${originUser.nickName}使用$specialCardType，获得一张普通卡${data["useSpecialCardInfo"]["addCardData"]["needNumber"]}";
          store["tip"] = Tip(1, msgData);
          break;
        case SpecialCardVal.greenSwapCard:
          // 可以用自己一张卡与其他玩家交换
          var selfCards = store["userCardsMap"][userID].cards;

          var changeCardData = data["useSpecialCardInfo"]["changeCardData"];
          var targetUserID = changeCardData["targetUserID"];
          var targetCards = store["userCardsMap"][targetUserID].cards;
          User targetUser = getUser(targetUserID);

          int selfIndex = 0;
          int targetIndex = 0;
          for (var i = 0; i < selfCards.length; i++) {
            if (selfCards[i].id == changeCardData["cardID"]) {
              selfIndex = i;
              break;
            }
          }
          for (var i = 0; i < targetCards.length; i++) {
            if (targetCards[i].id == changeCardData["targetCard"]) {
              targetIndex = i;
              break;
            }
          }
          String msgData = "${originUser.nickName}使用$specialCardType\n${selfCards[selfIndex].commonVal} -> ${targetUser.nickName}\n${originUser.nickName} <- ${targetCards[targetIndex].commonVal}";
          store["tip"] = Tip(1, msgData);

          // 交换卡
          var tempCard = targetCards[targetIndex].copy();
          targetCards[targetIndex] = selfCards[selfIndex].copy();
          selfCards[selfIndex] = tempCard;

          store["userCardsMap"][userID].cards = selfCards;
          store["userCardsMap"][targetUserID].cards = targetCards;
          break;
        case SpecialCardVal.blueModifyCard:
          // 修改一张自己或者他人的数字类型卡
          var updateCardData = data["useSpecialCardInfo"]["updateCardData"];
          var targetUserID = updateCardData["targetUserID"];
          User targetUser = getUser(targetUserID);

          List<Card> cards = store["userCardsMap"][targetUserID].cards;
          var originVal = "";
          for (var card in cards) {
            if (card.id == updateCardData["cardID"]) {
              originVal = card.commonVal!;
              card.commonVal = updateCardData["updateNumber"].toString();
              break;
            }
          }
          store["userCardsMap"][targetUserID].cards = cards;
          String msgData = "${originUser.nickName}使用$specialCardType\n${targetUser.nickName}的普通卡$originVal -> ${updateCardData["updateNumber"]}";
          store["tip"] = Tip(1, msgData);
          break;
      }

      // 删除使用的特殊卡
      List<Card> cards = store["userCardsMap"][userID].cards;
      bool found = false;
      cards.removeWhere((element) {
        if (!found) {
          found = element.category == CardCategory.special &&
              element.specialVal == specialCardType;
          return found;
        }
        return false;
      });
      store["userCardsMap"][userID].cards = cards;
    }
  }

  dynamic useItemResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
  }

  dynamic scoreRankResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["score"] = {};
    var rank = data["scoreRankInfo"]["rank"];
    for (var elem in rank) {
      var userID = elem["UserID"];
      var score = elem["Score"];
      store["score"][userID] = score.toString();
    }
  }

  dynamic gameOverResponse(Map<String, dynamic> params) async {
    Map<String, dynamic> data = res[params["msgType"]]!;
    await Future.delayed(const Duration(milliseconds: 200), () {
      store["gameOver"] = true;
    });
  }

  dynamic grabCardRoundResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["curStage"] = GameStage.bid;
    store["grabCardRoundInfo"] =
        (data["grabCardRoundInfo"]["duration"] / 1000000000).round();
    store["specialCardRoundInfo"] = null;
  }

  dynamic specialCardRoundResponse(Map<String, dynamic> params) {
    Map<String, dynamic> data = res[params["msgType"]]!;
    store["curStage"] = GameStage.play;
    store["specialCardRoundInfo"] =
        (data["specialCardRoundInfo"]["duration"] / 1000000000).round();
    store["grabCardRoundInfo"] = null;
  }

  dynamic getAllUser(Map<String, dynamic> params) async {
    Map<String, dynamic> data = res[params["msgType"]]!;
  }

  // 辅助函数
  User getUser(int userId) {
    return userList.where((element) => element.id == userId).first;
  }

  void reset() {
    clean();
    user.clean();
    userList = [];
    WS?.sink.close();
  }

  void clean() {
    store = {}; // 储存的数据
    msgList = []; // 消息队列
    res = {}; // 返回的数据
  }
}

class ClientType {
  static const checkHealthMsg = 100;
  static const chatMsg = 101;
  static const getState = 102;

  static const quitRoomMsg = 200;
  static const updateRoomMsg = 201;
  static const getRoomMsg = 202;
  static const userReadyStateMsg = 203;
  static const roomBeginGameMsg = 204;

  static const itemMsg = 300;
  static const grabCardMsg = 301;
  static const useSpecialCardMsg = 302;
  static const getGameState = 303;
}

class ServiceType {
  static const checkHealthMsg = 100;
  static const chatResponseType = 101;
  static const msgResponseType = 102;
  static const errResponseMsgType = 103;
  static const stateInfoResponseType = 104;

  static const roomInfoResponseType = 200;
  static const kickerResponseType = 201;
  static const beginGameResponseType = 202;

  static const gameStateResponseType = 300;
  static const useSpecialCardResponseType = 301;
  static const useItemResponseType = 302;
  static const scoreRankResponseType = 303;
  static const gameOverResponseType = 304;
  static const grabCardRoundResponseType = 305;
  static const specialCardRoundResponseType = 306;
}
