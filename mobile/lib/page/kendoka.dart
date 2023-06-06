import 'package:dojo_mobile/page/tabs/kendoka_aidat.dart';
import 'package:dojo_mobile/page/tabs/kendoka_base.dart';
import 'package:dojo_mobile/page/tabs/kendoka_seviye.dart';
import 'package:dojo_mobile/page/tabs/kendoka_yoklama.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';
import 'appwindow.dart';

UyeBilgi formUyeBilgi = UyeBilgi();
Sabitler formSabitler = Sabitler();
int _bottomNavIndex = 0;

class Kendoka extends StatefulWidget {
  final int uyeId;
  const Kendoka(this.uyeId, {super.key});

  @override
  State<Kendoka> createState() {
    return _Kendoka();
  }
}

class _Kendoka extends State<Kendoka> {
  bool _reload = true;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Widget getWigget(
      {required Sabitler sabitler,
      required UyeBilgi bilgi,
      required Store store}) {
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
      );
    } else if (_bottomNavIndex == 2) {
      return KendokaSeviye(
          sabitler: sabitler, bilgi: bilgi, store: store, uyeAd: bilgi.ad);
    } else {
      return KendokaYoklama(sabitler: sabitler, bilgi: bilgi, store: store);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.uyeId == 0) {
      _bottomNavIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Store store = Provider.of<Store>(context);
    return FBuilder<UyeBilgi>(
      future: yueBilgiGetir(store, widget.uyeId, _reload),
      builder: (data) {
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: appTitle(text: data.ad),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _reload = true;
                    });
                  },
                  icon: const Icon(Icons.refresh)),
              IconButton(
                  onPressed: () async {
                    if (data.email.isNotEmpty) {
                      await launchUrl(Uri(scheme: "mailto", path: data.email));
                    }
                  },
                  icon: const Icon(Icons.email))
            ],
          ),
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: getWigget(
                sabitler: formSabitler,
                bilgi: data,
                store: store,
              )),
          bottomNavigationBar: widget.uyeId > 0
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
                      BottomNavigationBarItem(
                          label: "Genel", icon: Icon(Icons.person)),
                      BottomNavigationBarItem(
                          label: "Aidatlar", icon: Icon(Icons.payments)),
                      BottomNavigationBarItem(
                          label: "Sinavlar", icon: Icon(Icons.card_membership)),
                      BottomNavigationBarItem(
                          label: "Keikolar", icon: Icon(Icons.checklist))
                    ])
              : null,
        );
      },
    );
  }
}

Future<UyeBilgi> yueBilgiGetir(Store store, int uyeId, bool reload) async {
  if (reload) {
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    formSabitler = store.sabitler;
    if (uyeId > 0) {
      formUyeBilgi = await uyeBilgi(api, uye_id: uyeId);
    } else {
      formUyeBilgi = UyeBilgi();
      formUyeBilgi.ad = "";
      formUyeBilgi.cinsiyet = "ERKEK";
      formUyeBilgi.durum = "registered";
      formUyeBilgi.tahakkuk_id = 1;
    }
  }

  return Future<UyeBilgi>(
    () {
      return formUyeBilgi;
    },
  );
}
