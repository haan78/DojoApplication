import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../api.dart';
import '../../service.dart';
import '../../store.dart';
import '../appwindow.dart';

class KendokaYoklama extends StatefulWidget {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;

  const KendokaYoklama({super.key, required this.sabitler, required this.bilgi, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _KendokaYoklama();
  }
}

class _KendokaYoklama extends State<KendokaYoklama> {
  late Api api;
  late LoadingDialog loadingdlg;
  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    loadingdlg = LoadingDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("Son üç ay içinde ${widget.bilgi.son3Ay} antrenmana katılmış"),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.all(3),
              child: ListView.builder(
                  itemCount: widget.bilgi.yoklamalar.length,
                  itemBuilder: (context, index) {
                    final tar = dateFormater(widget.bilgi.yoklamalar[index].tarih, "dd.MM.yyyy");
                    final tanim = widget.bilgi.yoklamalar[index].tanim;
                    return Padding(
                        padding: const EdgeInsets.all(3),
                        child: ElevatedButton(
                          onPressed: () {
                            yesNoDialog(context, text: "Bu yoklama kaydını silmek istediğinizden emin misiniz?", title: "Onay", onYes: () async {
                              try {
                                loadingdlg.push();
                                await uyeYoklama(api,
                                    yoklama_id: widget.bilgi.yoklamalar[index].yoklama_id, uye_id: widget.bilgi.uye_id, tarih: widget.bilgi.yoklamalar[index].tarih);
                                loadingdlg.pop();
                                widget.bilgi.yoklamalar.removeAt(index);
                              } catch (ex) {
                                errorAlert(context, ex.toString());
                              } finally {
                                loadingdlg.pop();
                              }
                            });
                          },
                          child: Text("$tar/$tanim"),
                        ));
                  })))
    ]);
  }
}
