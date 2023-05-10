// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'page/message_page.dart';
import 'page/web_login_page.dart';
import 'package:json_theme/json_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final jstr = await rootBundle.loadString("assets/theme1.json");
  final jdyn = await jsonDecode(jstr);
  final theme = ThemeDecoder.decodeThemeData(jdyn);
  Provider prv = Provider<Store>(
    create: ((context) {
      return Store();
    }),
    child: MyApp(theme: theme),
  );
  runApp(prv);
}

class MyApp extends StatelessWidget {
  final ThemeData? theme;
  const MyApp({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Store>(
        future: LoadStore(),
        builder: (BuildContext context, AsyncSnapshot<Store> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
                theme: theme,
                home: const Scaffold(body: Center(child: Text("Loading..."))));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasError) {
              Store s = snapshot.data!;
              Provider.of<Store>(context).copy(s);
              return MaterialApp(
                theme: theme,
                home: const WebLoginPage(),
              );
            } else {
              return MessagePage(snapshot.error.toString(), MessageType.error);
            }
          } else {
            return const MessagePage(
                "Application settings can't read", MessageType.error);
          }
        });
  }
}
