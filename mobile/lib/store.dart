// ignore_for_file: non_constant_identifier_names
import 'package:dojo_mobile/service.dart';
import 'package:flutter/foundation.dart';
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
  String LoginUrl = "";
  String WebUrl = "";
  String HostUrl = "";
  Sabitler sabitler = Sabitler();

  int id = 0;
  void copy(Store s) {
    AppName = s.AppName;
    ApiUser = s.ApiUser;
    ApiPassword = s.ApiPassword;
    ApiUrl = s.ApiUrl;
    LoginUrl = s.LoginUrl;
    WebUrl = s.WebUrl;
    ApiToken = s.ApiToken;
    UserStatus = s.UserStatus;
    UserName = s.UserName;
    HostUrl = s.HostUrl;
    id = s.id;
  }
}

Future<Store> LoadStore() async {
  Store s = Store();
  String jdata = await rootBundle
      .loadString("assets/defaults.${kDebugMode ? "debug" : "release"}.json");

  final Map<String, dynamic> data = jsonDecode(jdata);
  s.HostUrl = data["Host"].toString();
  s.AppName = data["Name"].toString();
  s.ApiUrl = s.HostUrl + data["Service"];
  s.LoginUrl = s.HostUrl + data["Login"];
  s.WebUrl = data["Web"];

  const storage = FlutterSecureStorage();

  s.ApiUser = await storage.read(key: "ApiUser") ?? "";
  s.ApiPassword = await storage.read(key: "ApiPassword") ?? "";
  s.ApiToken = await storage.read(key: "ApiToken") ?? "";
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
  if (s.ApiToken.isNotEmpty) {
    await storage.write(key: "ApiToken", value: s.ApiToken);
  }
}
