import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/page/appwindow.dart';

import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<FirstPage> {
  late Store store;
  AppWindow activeWindow = AppWindow.uyeler;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: scaffoldKey,
        drawer: app_drawer(store.AppName, context, scaffoldKey, (aw) {
          setState(() {
            activeWindow = aw;
          });
        }),
        appBar: AppBar(
            title: Row(
          children: [
            Image.asset(
              "assets/logo.png",
              fit: BoxFit.contain,
              height: 32,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(store.AppName)
          ],
        )),
        body: getWindow(activeWindow));
  }
}

Widget getWindow(AppWindow aw) {
  switch (aw) {
    case AppWindow.uyeler:
      return const Text("Üyeler");
    case AppWindow.harcamalar:
      return const Text("Harcamalar");
    case AppWindow.yoklamalar:
      return const Text("Yoklamalar");
    case AppWindow.ayarlar:
      return const Text("Ayarlar");
    default:
      return const Text("Default");
  }
}
