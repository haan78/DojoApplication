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

  dynamic validateResponse(http.Response res) {
    message = "";
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
        return jres["data"];
      } else {
        message = jres["data"]["message"] as String;
        code = jres["data"]["code"] as int;
        throw Exception(message);
      }
    } else {
      throw Exception("Invalid Response");
    }
  }

  Future<dynamic> upload(String method, {required String path, int timeout = 20}) async {
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': authorization};
    try {
      Uri fullurl = Uri.parse("$url$method");
      final mpreq = http.MultipartRequest("POST", fullurl);
      mpreq.headers.addAll(headers);
      mpreq.files.add(await http.MultipartFile.fromPath("file", path));
      final res = await http.Response.fromStream(await mpreq.send());
      return validateResponse(res);
    } on Error catch (e) {
      throw ApiException(e.toString(), status, code: code);
    } on Exception catch (e) {
      throw ApiException(e.toString(), status, code: code);
    }
  }

  Future<dynamic> call(String method, {dynamic data, int tryit = 0, int timeout = 10}) async {
    try {
      http.Response res;
      headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': authorization};
      Uri fullurl = Uri.parse("$url$method");
      if (data != null) {
        res = await http.post(fullurl, headers: headers, body: jsonEncode(data));
      } else {
        res = await http.get(fullurl, headers: headers);
      }
      return validateResponse(res);
    } on Error catch (e) {
      throw ApiException(e.toString(), status, code: code);
    } on Exception catch (e) {
      throw ApiException(e.toString(), status, code: code);
    }
  }
}
