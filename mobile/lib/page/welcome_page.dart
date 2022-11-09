// ignore_for_file: non_constant_identifier_names

import 'package:dojo_mobile/page/password_page.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/page/widget/app_bar_standart.dart';
import 'package:dojo_mobile/service.dart';

import '../api.dart';
import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() {
    return _WelcomePageState();
  }
}

class _WelcomePageState extends State<WelcomePage> {
  UyeBilgi? _ub;

  @override
  void initState() {
    super.initState();
  }

  Future<UyeBilgi> loaddata() async {
    Store store = Provider.of<Store>(context);
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    _ub ??= await uyeBilgi(api);
    return _ub!;
  }

  String trDate(DateTime dt) {
    String d = dt.day.toString().padLeft(2, "0");
    String m = dt.month.toString().padLeft(2, "0");
    String y = (dt.year < 2000 ? dt.year : dt.year - 2000).toString();
    return "$d.$m.$y";
  }

  Padding label({required String text, String title = ""}) {
    List<Widget> l = [];

    if (title.isNotEmpty) {
      l.add(Text(title, style: const TextStyle(fontWeight: FontWeight.bold)));
      l.add(const SizedBox(
        width: 5,
      ));
    }

    l.add(Text(text));

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: l),
    );
  }

  Widget label2(String title, {String text = "", bool vertical = true}) {
    return Padding(
        padding: vertical ? const EdgeInsets.only(right: 7) : const EdgeInsets.only(bottom: 7),
        child: vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 9), Text(text)],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 9), Text(text)]));
  }

  void keikolarigoster(
    int ay,
    int yil,
    int yoklama_id,
    List<UyeYoklama> yoklamalar,
  ) {
    String ayyilid = "$ay,$yil,$yoklama_id";
    String yn = "";
    List<Widget> lvc = [];
    for (final uy in yoklamalar) {
      if (uy.ayyilid == ayyilid) {
        lvc.add(Text(trDate(uy.tarih)));
        yn = uy.tanim;
      }
    }
    String cap = "${(yil - 2000)}-${ay.toString().padLeft(2, "0")}($yn)";
    infoAlert(context, caption: cap, child: Column(children: [Text("Dönem İçindeki Keikolar (${lvc.length})"), Column(children: lvc)]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarStandart(context, actions: [
        IconButton(
            onPressed: (() {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return const PasswordPage();
                },
              ));
            }),
            icon: const Icon(Icons.key_outlined))
      ]),
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder<UyeBilgi>(
              builder: ((context, AsyncSnapshot<UyeBilgi> snapshot) {
                if (snapshot.hasData) {
                  UyeBilgi ub = snapshot.data!;
                  List<Widget> lv = [];
                  double toplam = 0;
                  for (final t in ub.tahakuklar) {
                    toplam += (t.muhasebe_id == 0 ? t.borc : 0);
                    lv.add(Card(
                      color: Colors.red,
                      child: InkWell(
                          onTap: () {
                            keikolarigoster(t.ay, t.yil, t.yoklama_id, ub.yoklamalar);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: DefaultTextStyle(
                                style: const TextStyle(fontSize: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    label2("Dönem", text: "${(t.yil - 2000)}-${t.ay}"),
                                    label2("Tanım", text: "${t.tanim}-${t.yoklama}"),
                                    label2("Tutar(TL)", text: "${t.borc}"),
                                    label2("Tarih", text: trDate(t.tahakkuk_tarih))
                                  ],
                                )),
                          )),
                    ));
                  }
                  Image foto;
                  if (ub.image != null) {
                    foto = Image.memory(ub.image!, fit: BoxFit.fill, height: 170);
                  } else {
                    foto = const Image(image: AssetImage("assets/kendoka.jpg"), fit: BoxFit.fill, height: 170);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(ub.ad, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          foto,
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label(text: trDate(ub.dogum_tarih), title: "Doğum Tarihi"),
                              label(text: (ub.seviyeler.isNotEmpty ? ub.seviyeler[0].seviye : ""), title: "Seviye"),
                              label(text: ub.durum, title: "Durum"),
                              label(text: ub.tahkkuk, title: "Üyelik Tipi"),
                              label(text: ub.ekfno, title: "EKF NO"),
                              label(text: (ub.yoklamalar.isNotEmpty ? trDate(ub.yoklamalar[0].tarih) : "?"), title: "Son Antrenman"),
                              label(text: ub.son3Ay.toString(), title: "Son 3 Ay Ant. Say."),
                              label(text: ub.eksik_tahakkuk.toString(), title: "Eksik Tahakkuk")
                            ],
                          )
                        ]),
                        Flexible(
                            child: ListView(
                          padding: const EdgeInsets.all(8),
                          children: lv,
                        )),
                        Text(
                          "Toplam Borc $toplam TL",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.amber));
                }
              }),
              future: loaddata())),
    );
  }
}
