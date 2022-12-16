import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'first_page.dart';
import '../store.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late WebViewController _pageController;
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
        onMessageReceived: (JavascriptMessage message) async {
          final Map<String, dynamic> data = jsonDecode(message.message);
          s.id = data["uye_id"];
          s.UserStatus = data["durum"];
          s.UserName = data["ad"];
          s.ApiToken = "Bearer ${data["token"]}";
          s.ApiUser = data["email"];
          s.ApiPassword = data["password"];
          await writeSettings(s);
          if (mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FirstPage()));
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
        )),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: WebView(
                    initialUrl: s.LoginUrl,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: <JavascriptChannel>{getMessage(context)},
                    onWebViewCreated: (WebViewController controller) {
                      _pageController = controller;
                    },
                    onPageFinished: (url) async {
                      _pageController.runJavascript("setLoginData('${s.ApiUser}','${s.ApiPassword}','admin')");
                      //_pageController.runJavascriptReturningResult(javaScriptString)
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await forgetSettings();
                          _pageController.runJavascript("setLoginData('','','admin')");
                        },
                        child: const Text("Beni Unut")),
                    TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse(s.WebUrl));
                        },
                        child: const Text("Bireysel"))
                  ],
                )
              ],
            ))
        /*,*/
        );
  }
}
