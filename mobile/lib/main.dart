// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'page/message_page.dart';
import 'page/login_page.dart';

void main() {
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
    return FutureBuilder<Store>(
        future: LoadStore(),
        builder: (BuildContext context, AsyncSnapshot<Store> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
                home: Scaffold(body: Center(child: Text("Loading..."))));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasError) {
              Store s = snapshot.data!;
              Provider.of<Store>(context).copy(s);
              return const MaterialApp(
                //theme: ,
                home: LoginPage(),
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
