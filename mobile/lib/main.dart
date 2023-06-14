import 'dart:convert';

import 'package:dojo_mobile/page/appwindow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'page/message_page.dart';
import 'page/web_login_page.dart';
//import 'package:json_theme/json_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //final theme = ThemeDecoder.decodeThemeData(jdyn);
  Provider prv = Provider<Store>(
    create: ((context) {
      return Store();
    }),
    child: const MyApp(),
  );
  runApp(prv);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FBuilder<Store>(
        future: LoadStore(),
        builder: (Store s) {
          Provider.of<Store>(context).copy(s);
          return MaterialApp(
            darkTheme: ThemeData(brightness: Brightness.dark),
            themeMode: ThemeMode.dark,
            home: const WebLoginPage(),
          );
        });
  }
}
