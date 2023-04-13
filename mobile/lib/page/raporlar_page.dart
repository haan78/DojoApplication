import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../store.dart';

class RaporlarPage extends StatefulWidget {
  final Store store;
  const RaporlarPage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _RaporlarPage();
  }
}

class _RaporlarPage extends State<RaporlarPage> with TickerProviderStateMixin {
  late TabController tbc;
  late Api api;
  @override
  void initState() {
    super.initState();
    tbc = TabController(length: 5, vsync: this, initialIndex: 0);
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: appDrawer(context),
        appBar: AppBar(title: appTitle(text: "Raporlar")),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            TabBar(
              labelStyle: const TextStyle(fontSize: 12),
              labelColor: Colors.black,
              controller: tbc,
              isScrollable: true,
              tabs: const [
                Tab(text: "Gelir\nGider"),
                Tab(text: "Katılım"),
                Tab(
                  text: "Alacaklar",
                ),
                Tab(text: "Gelmeyenler"),
                Tab(text: "Seviye\nBildirimi")
              ],
            ),
            Expanded(
                child: TabBarView(controller: tbc, children: [
              Text("1"),
              Text("2"),
              Text("3"),
              Text("4"),
              Text("5"),
            ]))
          ]),
        ));
  }
}
