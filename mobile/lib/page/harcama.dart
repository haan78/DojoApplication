import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/service.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../store.dart';
import 'appwindow.dart';

class Harcama extends StatefulWidget {
  final Store store;
  final String uyeAd;
  final int uyeId;
  final MuhasebeDiger muhasebe;

  const Harcama(BuildContext context, {super.key, required this.store, required this.uyeAd, required this.uyeId, required this.muhasebe});
  @override
  State<StatefulWidget> createState() {
    return _Harcama();
  }
}

class _Harcama extends State<Harcama> {
  final int yil = DateTime.now().year;
  final _formKey = GlobalKey<FormState>();
  final aciklamacon = TextEditingController();
  late Api api;
  late LoadingDialog loadingdlg;

  late MoneyMaskedTextController tutarcon;
  late TextEditingController belgecon;

  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    widget.muhasebe.tarih = DateTime.now();
    aciklamacon.text = widget.muhasebe.aciklama;
    tutarcon = MoneyMaskedTextController(thousandSeparator: ".", decimalSeparator: ",", rightSymbol: "TL", precision: 2, initialValue: widget.muhasebe.tutar);
    belgecon = TextEditingController(text: widget.muhasebe.belge);
  }

  @override
  Widget build(BuildContext context) {
    loadingdlg = LoadingDialog(context);
    return uyeScaffold(
        uyeAd: widget.uyeAd,
        body: Form(
            key: _formKey,
            child: Column(children: [
              DropdownButtonFormField(
                  decoration: const InputDecoration(labelText: "Türü"),
                  value: widget.muhasebe.muhasebe_tanim_id,
                  items: getMuhasebeTanimItems(widget.store.sabitler.muhasebeTanimlar, MuhasebeTanimEnum.gider),
                  onChanged: ((value) {
                    if (value != null) {
                      setState(() {
                        if (value > 0) {
                          final mt = widget.store.sabitler.muhasebeTanimlar.firstWhere((element) => value == element.muhasebe_tanim_id);
                          widget.muhasebe.tanim = mt.tanim;
                          widget.muhasebe.muhasebe_tanim_id = value;
                        } else {
                          widget.muhasebe.tanim = "";
                          widget.muhasebe.muhasebe_tanim_id = 0;
                        }
                      });
                    }
                  }),
                  validator: (value) {
                    if (value == null || value == 0) {
                      return "Lütfen bir ödeme türü seçin";
                    } else {
                      return null;
                    }
                  }),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  DateTime? dt = await showDatePicker(context: context, initialDate: widget.muhasebe.tarih, firstDate: DateTime(yil - 3, 1, 1), lastDate: DateTime(yil + 3, 1, 1));
                  if (dt != null) {
                    setState(() {
                      widget.muhasebe.tarih = dt;
                    });
                  }
                },
                child: Text("Tarih :${dateFormater(widget.muhasebe.tarih, "dd.MM.yyyy")}", textAlign: TextAlign.left),
              ),
              DropdownButtonFormField(
                value: widget.muhasebe.kasa,
                decoration: const InputDecoration(labelText: "Kasa"),
                items: kasalar,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      widget.muhasebe.kasa = value;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Lütfen bir kasa seçin";
                  } else {
                    return null;
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Açıklama",
                ),
                controller: aciklamacon,
                onChanged: (value) {
                  setState(() {
                    widget.muhasebe.aciklama = value;
                  });
                },
              ),
              TextFormField(
                  decoration: const InputDecoration(labelText: "Tutar(TL)"),
                  controller: tutarcon,
                  keyboardType: TextInputType.number,
                  //inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                  onChanged: (value) {
                    setState(() {
                      widget.muhasebe.tutar = tutarcon.numberValue;
                    });
                  },
                  validator: (value) {
                    if ((value ?? "TL").trim() == "TL") {
                      return "Lütfen bir tutar girin";
                    } else {
                      return null;
                    }
                  }),
              TextFormField(
                decoration: const InputDecoration(labelText: "Belge No"),
                controller: belgecon,
                onChanged: (value) {
                  setState(() {
                    widget.muhasebe.belge = value.trim();
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    child: const Text("Harcamayı Kaydet"),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        int muhasebeId = 0;
                        try {
                          loadingdlg.push();
                          muhasebeId = await digerodemeal(api, widget.muhasebe, widget.uyeId, negative: true);
                          loadingdlg.pop();
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (loadingdlg.started) loadingdlg.pop();
                          errorAlert(context, e.toString());
                        } finally {
                          setState(() {
                            widget.muhasebe.muhasebe_id = muhasebeId;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: widget.muhasebe.muhasebe_id == 0
                        ? null
                        : () async {
                            //Silme Buraya
                            yesNoDialog(context, text: "Bu ödeme kaydını silmek istediğinizden emin misiniz?", onYes: (() async {
                              int muhasebeId = widget.muhasebe.muhasebe_id;
                              try {
                                loadingdlg.push();
                                await odemesil(api, widget.muhasebe.muhasebe_id);
                                loadingdlg.pop();
                                muhasebeId = 0;
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                if (loadingdlg.started) loadingdlg.pop();
                                errorAlert(context, e.toString());
                              } finally {
                                setState(() {
                                  widget.muhasebe.muhasebe_id = muhasebeId;
                                });
                              }
                            }));
                          },
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
                    child: const Text("Sil"),
                  )
                ],
              )
            ])));
  }
}
