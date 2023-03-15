// ignore_for_file: no_logic_in_create_state, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:dojo_mobile/page/message_page.dart';
import 'package:dojo_mobile/page/tabs/kendokaAidat.dart';
import 'package:dojo_mobile/page/tabs/kendoka_base.dart';
import 'package:dojo_mobile/page/tabs/kendoka_seviye.dart';
import 'package:dojo_mobile/page/tabs/kendoka_yoklama.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';

UyeBilgi formUyeBilgi = UyeBilgi();
Sabitler formSabitler = Sabitler();
int _bottomNavIndex = 0;

class Kendoka extends StatefulWidget {
  final int uye_id;
  const Kendoka(this.uye_id, {super.key});

  @override
  State<Kendoka> createState() {
    return _Kendoka(uye_id);
  }
}

class _Kendoka extends State<Kendoka> {
  final int uye_id;
  bool _reload = true;
  // ignore: prefer_function_declarations_over_variables

  _Kendoka(this.uye_id);
  void updateData(UyeBilgi ub, bool reload) {
    formUyeBilgi = ub;
    _reload = reload;
    setState(() {});
  }

  Widget getWigget({required Sabitler sabitler, required UyeBilgi bilgi, required Store store, required UpdateParentData updateParentData}) {
    if (_bottomNavIndex == 0) {
      return KendokaBase(
        sabitler: formSabitler,
        bilgi: bilgi,
        store: store,
      );
    } else if (_bottomNavIndex == 1) {
      return KendokaAidat(
        sabitler: formSabitler,
        bilgi: bilgi,
        store: store,
        updateParentData: updateData,
        uyeAd: bilgi.ad,
      );
    } else if (_bottomNavIndex == 2) {
      return KendokaSeviye(sabitler: sabitler, bilgi: bilgi, store: store, uyeAd: bilgi.ad);
    } else {
      return KendokaYoklama(sabitler: sabitler, bilgi: bilgi, store: store);
    }
  }

  @override
  void initState() {
    super.initState();
    if (uye_id == 0) {
      _bottomNavIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Store store = Provider.of<Store>(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return FutureBuilder<UyeBilgi>(
      future: yueBilgiGetir(store, uye_id, _reload),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          UyeBilgi ub = snapshot.data!;
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
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
                  Text(ub.ad)
                ],
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      setState(() {
                        _reload = true;
                      });
                    },
                    icon: const Icon(Icons.refresh))
              ],
            ),
            body: Padding(
                padding: const EdgeInsets.all(10),
                child: getWigget(
                  sabitler: formSabitler,
                  bilgi: ub,
                  store: store,
                  updateParentData: updateData,
                )),
            bottomNavigationBar: uye_id > 0
                ? BottomNavigationBar(
                    currentIndex: _bottomNavIndex,
                    onTap: (int index) {
                      if (mounted) {
                        setState(() {
                          _bottomNavIndex = index;
                          _reload = false;
                        });
                      }
                    },
                    type: BottomNavigationBarType.fixed,
                    items: const [
                        BottomNavigationBarItem(label: "Genel", icon: Icon(Icons.person)),
                        BottomNavigationBarItem(label: "Aidatlar", icon: Icon(Icons.payments)),
                        BottomNavigationBarItem(label: "Sinavlar", icon: Icon(Icons.card_membership)),
                        BottomNavigationBarItem(label: "Keikolar", icon: Icon(Icons.checklist))
                      ])
                : null,
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const MessagePage("Loading...", MessageType.info);
        } else {
          return const MessagePage("Error", MessageType.error);
        }
      },
    );
  }
}

Future<UyeBilgi> yueBilgiGetir(Store store, int uye_id, bool reload) async {
  if (reload) {
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    formSabitler = store.sabitler;
    if (uye_id > 0) {
      formUyeBilgi = await uyeBilgi(api, uye_id: uye_id);
    } else {
      formUyeBilgi = UyeBilgi();
      formUyeBilgi.ad = "Yeni Üye";
      formUyeBilgi.cinsiyet = "ERKEK";
      formUyeBilgi.durum = "registered";
      formUyeBilgi.tahakkuk_id = 1;
      formUyeBilgi.image = (await rootBundle.load("assets/kendoka.jpg")).buffer.asUint8List();
      formUyeBilgi.file_type = "image/jpeg";
    }
  }

  return Future<UyeBilgi>(
    () {
      return formUyeBilgi;
    },
  );
}
