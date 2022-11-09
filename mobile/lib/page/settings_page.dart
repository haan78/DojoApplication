import 'dart:io';

import 'package:dojo_mobile/page/widget/app_bar_standart.dart';

import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _url = TextEditingController();
  late Store store;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    _url.text = store.ApiUrl;
    return Scaffold(
      appBar: appBarStandart(context),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            TextButton(
                onPressed: () async {
                  await forgetSettings();
                  exit(0);
                },
                child: const Text("Kullanıcı ve Paraloayı Unut")),
            const SizedBox(height: 10),
            TextField(
              controller: _url,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Servis Adresi"),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 40,
              child: ElevatedButton(
                  onPressed: () async {
                    store.ApiUrl = _url.text.trim();
                    await writeSettings(store);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Kaydet")),
            )
          ])),
    );
  }
}
