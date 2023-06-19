import 'dart:convert';

import 'package:dojo_mobile/api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../service.dart';
import 'first_page.dart';
import '../store.dart';

import 'package:url_launcher/url_launcher.dart';

class WebLoginPage extends StatelessWidget {
  const WebLoginPage({super.key});

  WebViewController wconn(BuildContext context, Store s) {
    WebViewController c = WebViewController();
    c.setJavaScriptMode(JavaScriptMode.unrestricted);
    c.loadRequest(Uri.parse(s.LoginUrl));
    c.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        c.runJavaScript(("setLoginData('${s.ApiUser}','${s.ApiPassword}','mobile')"));
      },
    ));
    c.addJavaScriptChannel("MobileApp", onMessageReceived: (JavaScriptMessage message) async {
      final Map<String, dynamic> data = jsonDecode(message.message);
      s.UserStatus = data["durum"];
      s.UserName = data["ad"];
      s.ApiToken = "Bearer ${data["token"]}";
      s.ApiUser = data["email"];
      s.ApiPassword = data["password"] ?? "";
      final api = Api(url: s.ApiUrl, authorization: s.ApiToken);
      s.sabitler = await sabitGetir(api);
      await writeSettings(s);
      if (context.mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FirstPage(store: s)));
      }
    });
    return c;
  }

  @override
  Widget build(BuildContext context) {
    Store s = Provider.of<Store>(context, listen: false);
    WebViewController pageController = wconn(context, s);
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
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
                Text(Provider.of<Store>(context).AppName)
              ],
            )),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                SizedBox(height: 400, child: WebViewWidget(controller: pageController)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await forgetSettings();
                          s.UserName = "";
                          s.ApiPassword = "";
                          pageController.runJavaScript("setLoginData('${s.ApiUser}','${s.ApiPassword}','mobile')");
                        },
                        child: const Text("Beni Unut")),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        pageController.reload();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          launchUrl(Uri.parse(s.HostUrl));
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
