import 'package:flutter/material.dart';

import '../../api.dart';
import '../../service.dart';
import '../../store.dart';
import '../appwindow.dart';
import '../widget/alert.dart';

class KendokaSeviye extends StatefulWidget {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;
  final String uyeAd;

  const KendokaSeviye({super.key, required this.sabitler, required this.bilgi, required this.store, required this.uyeAd});

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _KendokaSeviye(sabitler: sabitler, bilgi: bilgi, store: store, uyeAd: uyeAd);
  }
}

int yil = DateTime.now().year;

class _KendokaSeviye extends State<KendokaSeviye> {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;
  final String uyeAd;
  UyeSeviye seviye = UyeSeviye();
  bool loading = false;
  _KendokaSeviye({required this.sabitler, required this.bilgi, required this.store, required this.uyeAd});

  @override
  Widget build(BuildContext context) {
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.black))),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(children: [
                Row(children: [
                  SizedBox(
                      width: 80,
                      child: DropdownButtonFormField(
                        value: seviye.seviye,
                        decoration: const InputDecoration(labelText: "Seviye"),
                        items: seviyeler,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              seviye.seviye = value;
                            });
                          }
                        },
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      child: Text("Tarih ${dateFormater(seviye.tarih, "dd.MM.yyyy")}"),
                      onPressed: () async {
                        DateTime? t = await showDatePicker(context: context, initialDate: seviye.tarih, firstDate: DateTime(yil - 80, 1, 1), lastDate: DateTime.now());
                        if (t != null) {
                          setState(() {
                            seviye.tarih = t;
                          });
                        }
                      },
                    ),
                  )
                ]),
                Row(children: [
                  Expanded(
                      child: TextFormField(
                    decoration: const InputDecoration(labelText: "Açıklama"),
                    controller: TextEditingController(text: seviye.aciklama),
                    onChanged: (value) {
                      seviye.aciklama = value;
                    },
                  ))
                ]),
                Dikey2,
                Row(children: [
                  ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                              setState(() {
                                seviye = UyeSeviye();
                              });
                            },
                      style: warnBtnStyle,
                      child: const Text("Yeni")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (seviye.seviye.isEmpty) {
                                errorAlert(context, "Bir seviye değeri gerekli", caption: "Giriş Hatası");
                                return;
                              }
                              setState(() {
                                loading = true;
                              });
                              await uyeSeviyeEkle(api, uye_id: bilgi.uye_id, us: seviye);
                              final ind = bilgi.seviyeler.indexWhere((element) {
                                if (element.seviye == seviye.seviye) {
                                  return true;
                                } else {
                                  return false;
                                }
                              });
                              if (ind > -1) {
                                bilgi.seviyeler[ind] = seviye;
                              } else {
                                bilgi.seviyeler.add(seviye);
                              }
                              setState(() {
                                loading = false;
                              });
                            },
                      style: goodBtnStyle,
                      child: const Text("Kaydet")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: loading
                          ? null
                          : () async {
                              if (seviye.seviye.isEmpty) {
                                return;
                              }
                              yesNoDialog(context, text: "Bu kaydı silmek istediğinizden emin misiniz?", onYes: (() async {
                                setState(() {
                                  loading = true;
                                });
                                await uyeSeviyeSil(api, uye_id: bilgi.uye_id, us: seviye);
                                bilgi.seviyeler.remove(seviye);
                                seviye = UyeSeviye();
                                setState(() {
                                  loading = false;
                                });
                              }));
                            },
                      style: badBtnStyle,
                      child: const Text("Sil"))
                ])
              ])),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: bilgi.seviyeler.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.all(5),
                child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      tileColor: tileColorByIndex(index),
                      leading: Text(bilgi.seviyeler[index].seviye),
                      title: Text(dateFormater(bilgi.seviyeler[index].tarih, "dd.MM.yyyy")),
                      subtitle: Text(bilgi.seviyeler[index].aciklama),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () {
                          setState(() {
                            seviye = bilgi.seviyeler[index];
                          });
                        },
                      ),
                      visualDensity: const VisualDensity(vertical: 1),
                    )));
          },
        ))
      ],
    );
  }
}
