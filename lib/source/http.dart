import 'package:dio/dio.dart';
import 'package:snatch_card/page/home/chat.dart';

class HttpRequest {
  Future<Response> GET(String url) async {
    Dio dio = Dio();
    return await dio.get("${API.serviceHost}$url");
  }

  Future<Response> GETByToken(String url, String token,
      {String? otherUrl, CancelToken? cancelToken}) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);

    if (otherUrl != null) {
      return await dio.get(otherUrl, cancelToken: cancelToken);
    }
    return await dio.get("${API.serviceHost}$url", cancelToken: cancelToken);
  }

  Future<Response> POST(String url, Object params) async {
    Dio dio = Dio();
    return await dio.post("${API.serviceHost}$url", data: params);
  }

  Future<Response> POSTByToken(String url, String token, Object params, {String? otherUrl}) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);

    if (otherUrl != null) {
      return await dio.post(otherUrl, data: params);
    }
    return await dio.post("${API.serviceHost}$url", data: params);
  }

  Future<Response> PUT(String url, Object params) async {
    Dio dio = Dio();
    return await dio.put("${API.serviceHost}$url", data: params);
  }

  Future<Response> PUTByToken(String url, String token, Object params,
      {String? otherUrl}) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);
    if (otherUrl != null) {
      return await dio.put(otherUrl, data: params);
    }
    return await dio.put("${API.serviceHost}$url", data: params);
  }

  Future<Response> DELETE(String url, Object params) async {
    Dio dio = Dio();
    return await dio.delete("${API.serviceHost}$url", data: params);
  }

  Future<Response> DELETEByToken(String url, String token, Object params,
      {String? otherUrl}) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);
    if (otherUrl != null) {
      return await dio.delete(otherUrl, data: params);
    }
    return await dio.delete("${API.serviceHost}$url", data: params);
  }
}

class API {
  static const serviceHost = "http://139.159.234.134:8000";
  static const fileHost = "http://139.159.234.134:7999/images/";

  // 用户
  static const getNickname = "/user/v1/getNickname";
  static const signUp = "/user/v1/register";
  static const login = "/user/v1/login";
  static const modify = "/user/v1/modify";
  static const search = "/user/v1/search";

  // 房间和游戏
  static const getRoomList = "/game/v1/getRoomList";
  static const createRoom = "/game/v1/createRoom";
  static const joinRoom = "/v1/userIntoRoom";
  static const getConnInfo = "/game/v1/getConnInfo";
  static const enterRoom = "/game/v1/userIntoRoom";
  static const selectRoom = "/game/v1/selectRoomServer";
  static const getRanks = "/game/v1/getRanks";

  // 文件
  static const uploadImage = "/file/v1/uploadImage";
  static const downloadImage = "/file/v1/downloadImage";

  // 大厅
  static const commentList = "/hall/v1/comment";
  static const commentAdd = "/hall/v1/comment/add";
  static const commentUpdate = "/hall/v1/comment/update";
  static const commentDel = "/hall/v1/comment/del";

  static const chatAdd = "/hall/v1/chat/addChat";
  static const chatList = "/hall/v1/chat/chatList";
  static const listen = "/hall/v1/chat/listen";
}

class HTTPStatus {
  static const OK = 200;
  static const PAGE_NOT_FOUND = 404;
  static const SERVICE_INTERVAL = 500;
}
