// ignore_for_file: non_constant_identifier_names
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class Store {
  String AppName = "";
  String ApiUrl = "";
  String ApiToken = "";
  String ApiUser = "";
  String ApiPassword = "";
  String UserStatus = "";
  String UserName = "";
  String host = "";
  int id = 0;
  void copy(Store s) {
    AppName = s.AppName;
    ApiUser = s.ApiUser;
    ApiPassword = s.ApiPassword;
    ApiUrl = s.ApiUrl;
    host = s.host;
    ApiToken = s.ApiToken;
    UserStatus = s.UserStatus;
    UserName = s.UserName;
    id = s.id;
  }
}

Future<Store> LoadStore() async {
  Store s = Store();
  String jdata = await rootBundle.loadString("assets/defaults.json");
  final Map<String, dynamic> data = jsonDecode(jdata);

  if (data.containsKey("AppName")) {
    s.AppName = data["AppName"].toString();
  }
  if (data.containsKey("host")) {
    s.host = data["host"];
  }

  const storage = FlutterSecureStorage();

  s.ApiUser = await storage.read(key: "ApiUser") ?? "";
  s.ApiPassword = await storage.read(key: "ApiPassword") ?? "";
  s.host = await storage.read(key: "host") ?? s.host;
  s.ApiUrl = "${s.host}/service.php";
  return s;
}

Future<void> forgetSettings() async {
  const storage = FlutterSecureStorage();
  await storage.deleteAll();
}

Future<void> writeSettings(Store s) async {
  const storage = FlutterSecureStorage();
  await storage.write(key: "ApiUser", value: s.ApiUser);
  await storage.write(key: "ApiPassword", value: s.ApiPassword);
  await storage.write(key: "host", value: s.host);
}
