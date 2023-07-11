import 'package:dio/dio.dart';

class HttpRequest {
  Future<Response> GET(String url) async {
    Dio dio = Dio();
    return await dio.get("${API.serviceHost}$url");
  }

  Future<Response> GETByToken(String url, String token) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);
    return await dio.get("${API.serviceHost}$url");
  }

  Future<Response> POST(String url, Object params) async {
    Dio dio = Dio();
    return await dio.post("${API.serviceHost}$url", data: params);
  }

  Future<Response> POSTByToken(String url, String token, Object params) async {
    BaseOptions options = BaseOptions();
    options.headers["token"] = token;
    Dio dio = Dio(options);
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
}

class API {
  static const serviceHost = "http://139.159.234.134:8000";
  static const fileHost = "http://139.159.234.134:80/images/";

  // 用户
  static const getNickname = "/user/v1/getNickname";
  static const signUp = "/user/v1/register";
  static const login = "/user/v1/login";
  static const modify = "/user/v1/modify";
  static const search = "/user/v1/search";

  // 房间
  static const getRoomList = "/game/v1/getRoomList";
  static const createRoom = "/game/v1/createRoom";
  static const joinRoom = "/v1/userIntoRoom";
  static const getConnInfo = "/game/v1/getConnInfo";
  static const enterRoom = "/game/v1/userIntoRoom";
  static const selectRoom = "/game/v1/selectRoomServer";
}

class HTTPStatus {
  static const OK = 200;
  static const PAGE_NOT_FOUND = 404;
  static const SERVICE_INTERVAL = 500;
}
