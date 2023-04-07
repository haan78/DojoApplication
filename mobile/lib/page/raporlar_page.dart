import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:flutter/material.dart';

import '../store.dart';

class RaporlarPage extends StatefulWidget {
  final Store store;
  const RaporlarPage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _RaporlarPage();
  }
}

class _RaporlarPage extends State<RaporlarPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(title: appTitle(text: "Raporlar"), actions: []),
      body: Text("ok"),
    );
  }
}
