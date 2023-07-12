import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/report/raporeldentahsilat.dart';
import 'package:dojo_mobile/report/raporgelirdiger.dart';
import 'package:dojo_mobile/report/raporseviyebildirimi.dart';
import 'package:dojo_mobile/report/raporuye.dart';
import 'package:flutter/material.dart';

import '../tools/api.dart';
import '../store.dart';
import 'appwindow.dart';

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

    tbc = TabController(length: 4, vsync: this, initialIndex: 0);
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
                onTap: (value) {},
                controller: tbc,
                labelColor: Colors.blueAccent.shade700,
                tabs: const [Tab(text: "Gelir\nGider"), Tab(text: "Seviye\nBildirimi"), Tab(text: "Üye\nRaporu"), Tab(text: "Elden\nTahsilat")],
              ),
              Expanded(child: TabBarView(controller: tbc, children: [RaporGelirGider(api: api), RaporSeviyeBildirimi(api: api), RaporUye(api: api), RaporEldenTahsilat(api: api)]))
            ])));
  }
}
