import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/store.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'appwindow.dart';

class BilgiPage extends StatelessWidget {
  final Store store;
  const BilgiPage({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(title: appTitle(text: "Hakkında")),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/bilgiimg.jpg"),
              const Text("Version $appVersion"),
              const SizedBox(height: 20),
              const Text("Yazılımcı: Ali Barış Öztürk"),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () async {
                    await launchUrl(Uri(scheme: "mailto", path: programerEmail));
                  },
                  child: const Text(programerEmail)),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: () async {
                    launchUrl(Uri.parse(store.WebUrl));
                  },
                  child: const Text("Web Sayfası"))
            ],
          )),
    );
  }
}
