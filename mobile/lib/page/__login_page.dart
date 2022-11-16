import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_page.dart';
import 'settings_page.dart';
import '../store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pass = TextEditingController(text: "");
  bool rememberme = false;
  bool first = true;

  @override
  void initState() {
    first = true;
    super.initState();
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
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            const Text(
              'Üye Girişi',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 54, 20, 6)),
            ),
            TextField(
              controller: _user,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Kullanıcı"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pass,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Parola"),
            ),
            const SizedBox(height: 15),
            TextButton(
                onPressed: () {
                  setState(() {
                    rememberme = !rememberme;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon((rememberme ? Icons.check_box : Icons.check_box_outline_blank)), const Text("Beni hatirla")],
                )),
            const SizedBox(height: 10),
            SizedBox(
              width: 300,
              height: 40,
              child: ElevatedButton(
                  onPressed: () async {
                    s.ApiUser = _user.text;
                    s.ApiPassword = _pass.text;
                    Api api = Api(url: s.ApiUrl, authorization: Api.basic(s.ApiUser, s.ApiPassword));
                    try {
                      dynamic response = await api.call("/token");
                      s.id = response["uye_id"];
                      s.UserStatus = response["durum"];
                      s.UserName = response["ad"];
                      StatefulWidget page;
                      if (s.UserStatus == "admin") {
                        page = const AdminPage();
                      } else {
                        page = const WelcomePage();
                      }

                      s.ApiToken = api.authorization;

                      if (rememberme) {
                        await writeSettings(s);
                      }
                      if (mounted) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
                      }
                    } on ApiException catch (ex) {
                      // ignore: avoid_print
                      errorAlert(context, ex.toString());
                    }
                  },
                  child: const Text("Giriş")),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [TextButton(onPressed: () {}, child: const Text("Yeni Kayıt")), TextButton(onPressed: () {}, child: const Text("Şifremi Bilmiyorum"))],
            )
          ]),
        )
        /*,*/
        );
  }
}
