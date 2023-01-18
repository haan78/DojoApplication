import 'package:dojo_mobile/page/appwindow.dart';
import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/services.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';

class UyeTahakkukBilgi {
  final UyeTahakkuk uyeTahakkuk;
  final String uyeAd;
  final Store store;
  final int uyeId;
  UyeTahakkukBilgi({required this.uyeTahakkuk, required this.uyeAd, required this.uyeId, required this.store});
}

class Payment extends StatefulWidget {
  final UyeTahakkukBilgi bilgi;
  const Payment(BuildContext context, {super.key, required this.bilgi});

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _Peyment(bilgi);
  }
}

class _Peyment extends State<Payment> {
  final UyeTahakkukBilgi bilgi;
  bool loading = false;
  _Peyment(this.bilgi);

  List<Widget> btnGorup() {
    if (bilgi.uyeTahakkuk.uye_tahakkuk_id == 0) {
      return <Widget>[
        Expanded(
            child: ElevatedButton(
          onPressed: loading ? null : () {},
          child: const Text("Kaydet"),
        ))
      ];
    } else {
      return <Widget>[
        Expanded(
            child: ElevatedButton(
          onPressed: loading
              ? null
              : () {
                  setState(() {
                    loading = true;
                  });
                },
          child: const Text("Kaydet"),
        )),
        const SizedBox(width: 20),
        SizedBox(
          width: 50,
          child: ElevatedButton(
            onPressed: loading
                ? null
                : () {
                    yesNoDialog(context, text: "Bu ödeme kaydını silmek istediğinizden emin misiniz?", onYes: (() {
                      setState(() {
                        loading = true;
                      });
                    }));
                  },
            style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
            child: const Text("Sil"),
          ),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutarcon = MoneyMaskedTextController(
        thousandSeparator: ".",
        decimalSeparator: "",
        rightSymbol: "TL",
        precision: 0,
        initialValue: bilgi.uyeTahakkuk.muhasebe_id > 0 ? bilgi.uyeTahakkuk.odenen : bilgi.uyeTahakkuk.borc); /*kurus mu kaldı aq*/

    //print([bilgi.uyeTahakkuk.tanim, bilgi.uyeTahakkuk.uye_tahakkuk_id]);
    int yil = DateTime.now().year;
    return Scaffold(
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
            Text(bilgi.uyeAd)
          ],
        )),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Row(
                children: [
                  Expanded(
                      child: DropdownButtonFormField(
                          value: bilgi.uyeTahakkuk.tanim,
                          decoration: InputDecoration(labelText: "Tanım", enabled: bilgi.uyeTahakkuk.uye_tahakkuk_id == 0),
                          items: const [
                            DropdownMenuItem(value: "", child: Text("[Seçiniz]")),
                            DropdownMenuItem(value: "Tam Aidat", child: Text("Tam Aidat")),
                            DropdownMenuItem(value: "Öğrenci Aidat", child: Text("Öğrenci Aidat")),
                            DropdownMenuItem(value: "Öğrenci Sınav", child: Text("Öğrenci Sınav")),
                            DropdownMenuItem(value: "Tam Sınav", child: Text("Tam Sınav")),
                            DropdownMenuItem(value: "Satış", child: Text("Satış")),
                            DropdownMenuItem(value: "Bağış", child: Text("Bağış")),
                            DropdownMenuItem(value: "Etkinlik Katılımı", child: Text("Etkinlik Katılım")),
                            DropdownMenuItem(value: "Yolculuk Ödemesi", child: Text("Yolculuk Ödemesi")),
                            DropdownMenuItem(value: "Diğer", child: Text("Diğer")),
                          ],
                          onChanged: bilgi.uyeTahakkuk.uye_tahakkuk_id == 0
                              ? (value) {
                                  if (value != null) {
                                    if (bilgi.uyeTahakkuk.uye_tahakkuk_id == 0) {
                                      bilgi.uyeTahakkuk.tanim = value.toString();
                                      //print([bilgi.uyeTahakkuk.tanim, bilgi.uyeTahakkuk.tanim.contains("Aidat")]);
                                    }
                                    setState(() {});
                                  }
                                }
                              : null))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                  children: bilgi.uyeTahakkuk.tanim.contains("Aidat")
                      ? [
                          const Text("Dönem:"),
                          const SizedBox(width: 20),
                          SizedBox(
                              width: 100,
                              child: DropdownButtonFormField(
                                  items: Aylar,
                                  value: bilgi.uyeTahakkuk.ay,
                                  onChanged: (value) {
                                    if (value != null) {
                                      bilgi.uyeTahakkuk.ay = value;
                                      setState(() {});
                                    }
                                  })),
                          const SizedBox(width: 20),
                          SizedBox(
                              width: 100,
                              child: DropdownButtonFormField(
                                  items: [
                                    DropdownMenuItem(value: yil - 2, child: Text((yil - 2).toString())),
                                    DropdownMenuItem(value: yil - 1, child: Text((yil - 1).toString())),
                                    DropdownMenuItem(value: yil, child: Text((yil).toString())),
                                    DropdownMenuItem(value: yil + 1, child: Text((yil + 1).toString())),
                                    const DropdownMenuItem(value: 0, child: Text("[Seçiniz]")),
                                  ],
                                  value: bilgi.uyeTahakkuk.yil,
                                  onChanged: (value) {
                                    if (value != null) {
                                      bilgi.uyeTahakkuk.yil = value;
                                      setState(() {});
                                    }
                                  }))
                        ]
                      : [const Text("Aidat Harici Ödeme")]),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () async {
                      DateTime? dt = await showDatePicker(
                          context: context, initialDate: bilgi.uyeTahakkuk.tahakkuk_tarih, firstDate: DateTime(yil - 3, 1, 1), lastDate: DateTime(yil + 3, 1, 1));
                      if (dt != null) {
                        bilgi.uyeTahakkuk.tahakkuk_tarih = dt;
                        setState(() {});
                      }
                    },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => Color.fromARGB(255, 192, 180, 8))),
                    child: Text("Tarih :${dateFormater(bilgi.uyeTahakkuk.tahakkuk_tarih, "dd.MM.yyyy")}", textAlign: TextAlign.left),
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    decoration: const InputDecoration(labelText: "Tutar"),
                    controller: tutarcon,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                  ))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: DropdownButtonFormField(
                          value: bilgi.uyeTahakkuk.kasa,
                          decoration: const InputDecoration(labelText: "Kasa"),
                          items: const [
                            DropdownMenuItem(value: "", child: Text("[Seçiniz]")),
                            DropdownMenuItem(value: "Elden", child: Text("Elden")),
                            DropdownMenuItem(value: "Sayman Banka", child: Text("Sayman Banka")),
                            DropdownMenuItem(value: "Dernek Banka", child: Text("Dernek Banka"))
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              bilgi.uyeTahakkuk.kasa = value;
                              setState(() {});
                            }
                          }))
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                    child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Açıklama",
                  ),
                  controller: TextEditingController(text: bilgi.uyeTahakkuk.aciklama),
                  onChanged: (value) {
                    bilgi.uyeTahakkuk.aciklama = value;
                    setState(() {});
                  },
                )),
              ]),
              const SizedBox(height: 60),
              Row(children: btnGorup()),
            ])));
  }
}
