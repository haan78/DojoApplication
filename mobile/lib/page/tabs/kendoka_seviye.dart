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

  const KendokaSeviye(
      {super.key,
      required this.sabitler,
      required this.bilgi,
      required this.store,
      required this.uyeAd});

  @override
  State<StatefulWidget> createState() {
    return _KendokaSeviye();
  }
}

int yil = DateTime.now().year;

class _KendokaSeviye extends State<KendokaSeviye> {
  UyeSeviye seviye = UyeSeviye();
  late LoadingDialog loadingdlg;
  late Api api;

  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    loadingdlg = LoadingDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(width: 3, color: Colors.black))),
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
                      child: Text(
                          "Tarih ${dateFormater(seviye.tarih, "dd.MM.yyyy")}"),
                      onPressed: () async {
                        DateTime? t = await showDatePicker(
                            context: context,
                            initialDate: seviye.tarih,
                            firstDate: DateTime(yil - 80, 1, 1),
                            lastDate: DateTime.now());
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
                      onPressed: () {
                        if (loadingdlg.started) {
                          return;
                        }
                        setState(() {
                          seviye = UyeSeviye();
                        });
                      },
                      style: warnBtnStyle,
                      child: const Text("Yeni")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () async {
                        if (seviye.seviye.isEmpty) {
                          errorAlert(context, "Bir seviye değeri gerekli",
                              caption: "Giriş Hatası");
                          return;
                        }
                        try {
                          loadingdlg.push();
                          await uyeSeviyeEkle(api,
                              uye_id: widget.bilgi.uye_id, us: seviye);
                          loadingdlg.pop();
                          final ind =
                              widget.bilgi.seviyeler.indexWhere((element) {
                            if (element.seviye == seviye.seviye) {
                              return true;
                            } else {
                              return false;
                            }
                          });
                          setState(() {
                            if (ind > -1) {
                              widget.bilgi.seviyeler[ind] = seviye;
                            } else {
                              widget.bilgi.seviyeler.add(seviye);
                              widget.bilgi.seviyeler.sort(
                                  (a, b) => -1 * a.tarih.compareTo(b.tarih));
                            }
                          });
                        } catch (err) {
                          errorAlert(context, err.toString());
                        } finally {
                          loadingdlg.pop();
                        }
                      },
                      style: goodBtnStyle,
                      child: const Text("Kaydet")),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () async {
                        if (seviye.seviye.isEmpty) {
                          return;
                        }
                        yesNoDialog(context,
                            text:
                                "Bu kaydı silmek istediğinizden emin misiniz?",
                            onYes: (() async {
                          try {
                            loadingdlg.push();
                            await uyeSeviyeSil(api,
                                uye_id: widget.bilgi.uye_id, us: seviye);
                            loadingdlg.pop();
                            setState(() {
                              widget.bilgi.seviyeler.remove(seviye);
                            });
                            seviye = UyeSeviye();
                          } catch (err) {
                            if (loadingdlg.started) loadingdlg.pop();
                            errorAlert(context, err.toString());
                          }
                        }));
                      },
                      style: badBtnStyle,
                      child: const Text("Sil"))
                ])
              ])),
        ),
        Expanded(
            child: ListView.builder(
          itemCount: widget.bilgi.seviyeler.length,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.all(5),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  tileColor: tileColorByIndex(index),
                  title: Text(
                      "${widget.bilgi.seviyeler[index].seviye} ${dateFormater(widget.bilgi.seviyeler[index].tarih, "dd.MM.yyyy")}"),
                  subtitle: Text(widget.bilgi.seviyeler[index].aciklama),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      setState(() {
                        seviye = widget.bilgi.seviyeler[index];
                      });
                    },
                  ),
                  visualDensity: const VisualDensity(vertical: -1),
                ));
          },
        ))
      ],
    );
  }
}
