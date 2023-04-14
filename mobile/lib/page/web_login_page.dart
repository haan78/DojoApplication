import 'dart:convert';

import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/yoklama_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../service.dart';
import 'first_page.dart';
import '../store.dart';

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
    Store s = Provider.of<Store>(context, listen: false);
    _pageController = wconn(s);
    //if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  WebViewController wconn(Store s) {
    WebViewController c = WebViewController();
    c.setJavaScriptMode(JavaScriptMode.unrestricted);
    c.setBackgroundColor(const Color(0x00000000));
    c.loadRequest(Uri.parse(s.LoginUrl));
    c.setNavigationDelegate(NavigationDelegate(
      onPageFinished: (url) {
        c.runJavaScript(("setLoginData('${s.ApiUser}','${s.ApiPassword}','admin')"));
      },
    ));
    c.addJavaScriptChannel("MobileApp", onMessageReceived: (JavaScriptMessage message) async {
      final Map<String, dynamic> data = jsonDecode(message.message);
      s.id = data["uye_id"];
      s.UserStatus = data["durum"];
      s.UserName = data["ad"];
      s.ApiToken = "Bearer ${data["token"]}";
      s.ApiUser = data["email"];
      s.ApiPassword = data["password"];
      final api = Api(url: s.ApiUrl, authorization: s.ApiToken);
      s.sabitler = await sabitGetir(api);
      await writeSettings(s);
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FirstPage(store: s)));
        //Navigator.push(context, MaterialPageRoute(builder: (context) => YoklamaPage(store: s)));
      }
    });
    return c;
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
                AspectRatio(
                  aspectRatio: 1,
                  child: WebViewWidget(controller: _pageController),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: () async {
                          await forgetSettings();
                          _pageController.runJavaScript("setLoginData('','','admin')");
                        },
                        child: const Text("Beni Unut")),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        _pageController.reload();
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
