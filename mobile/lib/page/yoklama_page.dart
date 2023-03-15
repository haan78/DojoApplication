import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../store.dart';
import 'appwindow.dart';

class YoklamaPage extends StatefulWidget {
  const YoklamaPage({super.key});
  @override
  State<YoklamaPage> createState() {
    return _YoklamaPage();
  }
}

class _YoklamaPage extends State<YoklamaPage> {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<Store>(context);
    return Scaffold(
        drawer: app_drawer(context),
        appBar: AppBar(
          title: AppTitle,
          actions: const [],
        ),
        body: Padding(
            padding: AppPading,
            child: Column(
              children: [
                Row(
                  children: [Text(store.sabitler.yoklamalar[0].tanim)],
                ),
                const Expanded(
                  child: Text("aa"),
                )
              ],
            )));
  }
}
