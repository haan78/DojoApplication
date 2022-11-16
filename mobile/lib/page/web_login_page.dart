import 'dart:convert';
import 'dart:io';

import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_page.dart';
import 'settings_page.dart';
import '../store.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebLoginPage extends StatefulWidget {
  const WebLoginPage({super.key});

  @override
  State<WebLoginPage> createState() {
    return _WebLoginPageState();
  }
}

class _WebLoginPageState extends State<WebLoginPage> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController(text: "");
  bool rememberme = false;
  bool first = true;

  @override
  void initState() {
    first = true;
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  JavascriptChannel getMessage(BuildContext context) {
    Store s = Provider.of<Store>(context, listen: false);
    return JavascriptChannel(
        name: "MobileApp",
        onMessageReceived: (JavascriptMessage message) {
          final Map<String, dynamic> data = jsonDecode(message.message);
          s.id = data["uye_id"];
          s.UserStatus = data["durum"];
          s.UserName = data["ad"];
          s.ApiToken = "Bearer ${data["token"]}";
          s.ApiUser = data["email"];
          StatefulWidget page;
          if (s.UserStatus == "admin") {
            page = const AdminPage();
          } else {
            page = const WelcomePage();
          }
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    Store s = Provider.of<Store>(context, listen: false);
    if (first) {
      _user.text = s.ApiUser;
      _pass.text = s.ApiPassword;
      first = false;
    }

    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
                height: 48,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(Provider.of<Store>(context).AppName)
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const SettingsPage();
                    },
                  ));
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: WebView(
                initialUrl: s.host,
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>{getMessage(context)},
              ),
            ))
        /*,*/
        );
  }
}
