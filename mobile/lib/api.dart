import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiResponse {
  bool success = true;
  int status = 0;
  dynamic data;
}

class ApiUserInfo {}

class ApiException implements Exception {
  int status;
  int code;
  String message;
  ApiException(this.message, this.status, {this.code = 0});

  @override
  String toString() {
    return message;
  }
}

typedef ApiErrCallback = void Function(String message)?;

class Api {
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    "Authorization": "", //Bearer
  };

  String authorization;
  String url;
  bool success = false;
  int status = 0;
  int code = 0;
  String message = "";

  Api({required this.url, required this.authorization});

  static String basic(String username, String password) {
    String basic = base64.encode("$username:$password".codeUnits);
    String auth = "Basic $basic";
    return auth;
  }

  Future<dynamic> call(String method, {dynamic data, int tryit = 0, int timeout = 10}) async {
    dynamic response;
    message = "";
    try {
      http.Response res;
      headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': authorization};
      //["authorization"] = authorization;
      //print(authorization);
      /*if (tryit > 0) {
        headers["Keep-Alive"] = "timeout=$timeout, max=$tryit";
      }*/
      Uri fullurl = Uri.parse("$url$method");
      if (data != null) {
        res = await http.post(fullurl, headers: headers, body: jsonEncode(data));
      } else {
        res = await http.get(fullurl, headers: headers);
      }
      status = res.statusCode;
      final Map<String, dynamic> jres;
      try {
        jres = jsonDecode(res.body);
      } catch (ex0) {
        throw Exception("Service response ${ex0.toString()}");
      }
      if (jres.containsKey("success") && jres.containsKey("data") && jres.containsKey("status")) {
        if (res.headers.containsKey("authorization")) {
          authorization = res.headers["authorization"]!;
        }
        success = jres["success"] as bool;
        if (success) {
          response = jres["data"];
        } else {
          message = jres["data"]["message"] as String;
          code = jres["data"]["code"] as int;
        }
      } else {
        message = "";
      }
      if (message.isNotEmpty) {
        throw Exception(message);
      }
      //throw Exception("test");
      return response;
    } catch (ex) {
      throw ApiException(ex.toString(), status, code: code);
    }
  }
}
