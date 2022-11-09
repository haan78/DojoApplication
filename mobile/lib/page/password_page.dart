import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/page/widget/app_bar_standart.dart';
import 'package:dojo_mobile/service.dart';

import '../api.dart';
import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() {
    return _PasswordPageState();
  }
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _old = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _repeat = TextEditingController();
  late Store store;
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    return Scaffold(
      appBar: appBarStandart(context),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
              child: Column(children: [
            const Text("Parola Değiştir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            TextField(
              controller: _old,
              obscureText: true,
              enableSuggestions: false,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Eski Parola"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _pass,
              obscureText: true,
              enableSuggestions: false,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Yeni Parola"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _repeat,
              obscureText: true,
              enableSuggestions: false,
              decoration: const InputDecoration(border: UnderlineInputBorder(), labelText: "Tekrar Yeni Parola"),
            ),
            const SizedBox(height: 10),
            SizedBox(
                width: 150,
                child: loading
                    ? const Text("Lütfen Bekleyin...")
                    : ElevatedButton(
                        onPressed: () {
                          if (_old.text.isEmpty) {
                            errorAlert(context, "Lütfen eski parolayı girin", caption: "Giriş Hatası");
                          } else if (_pass.text.trim().length < 6 || _pass.text.trim().length > 10) {
                            errorAlert(context, "Yeni parola en za 6 en fazla 10 karakter olabilir.", caption: "Giriş Hatası");
                          } else if (_pass.text.trim() != _repeat.text.trim()) {
                            errorAlert(context, "Parolnın tekrarı hatalı", caption: "Giriş Hatası");
                          } else {
                            Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
                            parolaDegistir(api, oldpass: _old.text.trim(), newpass: _pass.text.trim()).then((value) {
                              successAlert(
                                context,
                                "Parola başarıyla değiştirildi",
                                ok: () {
                                  Navigator.of(context).pop();
                                },
                              );
                            }).catchError((err) {
                              errorAlert(context, err.toString());
                            });
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [Icon(Icons.check_circle), Text("Değiştir")],
                        )))
          ]))),
    );
  }
}
