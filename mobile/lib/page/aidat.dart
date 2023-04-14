import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:flutter/material.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import '../api.dart';
import '../service.dart';
import '../store.dart';

class Aidat extends StatefulWidget {
  final UyeTahakkuk uyeTahakkuk;
  final Store store;
  final String uyeAd;
  final int uyeId;
  final int tahakkukId;
  const Aidat(BuildContext context, {super.key, required this.uyeTahakkuk, required this.store, required this.uyeAd, required this.uyeId, required this.tahakkukId});

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _Aidat();
  }
}

class _Aidat extends State<Aidat> {
  final _formKey = GlobalKey<FormState>();
  final aciklamacon = TextEditingController();
  late Api api;
  late LoadingDialog loadingdlg;

  late MoneyMaskedTextController tutarcon;

  @override
  void initState() {
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);

    widget.uyeTahakkuk.odeme_tarih ??= DateTime.now();

    aciklamacon.text = widget.uyeTahakkuk.aciklama;

    if (widget.uyeTahakkuk.ay == 0) {
      widget.uyeTahakkuk.ay = DateTime.now().month;
    }

    if (widget.uyeTahakkuk.yil == 0) {
      widget.uyeTahakkuk.yil = DateTime.now().year;
    }

    if (widget.uyeTahakkuk.tahakkuk_id == 0) {
      widget.uyeTahakkuk.tahakkuk_id = widget.tahakkukId;
      widget.uyeTahakkuk.odenen = widget.store.sabitler.tahakkuklar.firstWhere((element) {
        if (element.tahakkuk_id == widget.uyeTahakkuk.tahakkuk_id) {
          return true;
        } else {
          return false;
        }
      }).tutar;
    } else if (widget.uyeTahakkuk.muhasebe_id == 0) {
      widget.uyeTahakkuk.odenen = widget.uyeTahakkuk.borc;
    }

    tutarcon = MoneyMaskedTextController(thousandSeparator: ".", decimalSeparator: "", rightSymbol: "TL", precision: 0, initialValue: widget.uyeTahakkuk.odenen);

    if (widget.store.sabitler.yoklamalar.length == 1 && widget.uyeTahakkuk.uye_tahakkuk_id == 0) {
      widget.uyeTahakkuk.yoklama_id = widget.store.sabitler.yoklamalar[0].yoklama_id;
    }

    super.initState();
    loadingdlg = LoadingDialog(context);
  }

  List<Widget> btnGorup() {
    List<Widget> bgl = [
      Expanded(
          child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            int muhasebeId = 0;
            try {
              loadingdlg.push();
              muhasebeId = await aidatodemeal(api, widget.uyeTahakkuk, widget.uyeId);
              loadingdlg.pop();
              if (context.mounted) {
                Navigator.pop(context);
              }
            } catch (e) {
              if (loadingdlg.started) loadingdlg.pop();
              errorAlert(context, e.toString());
            } finally {
              setState(() {
                widget.uyeTahakkuk.muhasebe_id = muhasebeId;
              });
            }
          }
        },
        child: const Text("Kaydet"),
      ))
    ];
    if (widget.uyeTahakkuk.uye_tahakkuk_id > 0) {
      bgl.add(const SizedBox(width: 20));
      bgl.add(SizedBox(
        width: 50,
        child: ElevatedButton(
          onPressed: () {
            //Silme Buraya
            if (loadingdlg.started) {
              return;
            }
            yesNoDialog(context, text: "Bu ödeme kaydını silmek istediğinizden emin misiniz?", onYes: (() async {
              int muhasebeId = widget.uyeTahakkuk.muhasebe_id;
              try {
                if (widget.uyeTahakkuk.muhasebe_id > 0) {
                  loadingdlg.push();
                  await aidatodemesil(api, widget.uyeTahakkuk.muhasebe_id);
                  loadingdlg.pop();
                } else if (widget.uyeTahakkuk.uye_tahakkuk_id > 0) {
                  loadingdlg.push();
                  await aidatsil(api, widget.uyeTahakkuk.uye_tahakkuk_id);
                  widget.uyeTahakkuk.uye_tahakkuk_id = 0;
                  loadingdlg.pop();
                } else {
                  //sacmalik
                  return;
                }
                muhasebeId = 0;
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (loadingdlg.started) loadingdlg.pop();
                errorAlert(context, e.toString());
              } finally {
                setState(() {
                  widget.uyeTahakkuk.muhasebe_id = muhasebeId;
                });
              }
            }));
          },
          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
          child: const Text("Sil"),
        ),
      ));
    }
    return bgl;
  }

  @override
  Widget build(BuildContext context) {
    /*kurus mu kaldı aq*/

    //print([bilgi.uyeTahakkuk.tanim, bilgi.uyeTahakkuk.uye_tahakkuk_id]);
    int yil = DateTime.now().year;
    return uyeScaffold(
        uyeAd: widget.uyeAd,
        body: Form(
          key: _formKey,
          child: Column(children: [
            widget.uyeTahakkuk.uye_tahakkuk_id > 0
                ? Text("${widget.uyeTahakkuk.tanim} ${aylarText[widget.uyeTahakkuk.ay - 1]} / ${widget.uyeTahakkuk.yil}")
                : Row(children: [
                    SizedBox(
                        width: 90,
                        child: DropdownButtonFormField(
                            value: widget.uyeTahakkuk.ay,
                            items: aylarMenuItem,
                            onChanged: (int? value) {
                              if (value != null && value > 0) {
                                setState(() {
                                  widget.uyeTahakkuk.ay = value;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value == 0) {
                                return "Ay Seçin";
                              } else {
                                return null;
                              }
                            })),
                    const SizedBox(width: 10),
                    SizedBox(
                        width: 85,
                        child: DropdownButtonFormField(
                            items: [
                              const DropdownMenuItem<int>(value: 0, child: Text("[Seçiniz]")),
                              //DropdownMenuItem<int>(value: yil - 2, child: Text((yil - 2).toString())),
                              //DropdownMenuItem<int>(value: yil - 1, child: Text((yil - 1).toString())),
                              DropdownMenuItem<int>(value: yil, child: Text((yil).toString())),
                              DropdownMenuItem<int>(value: yil + 1, child: Text((yil + 1).toString())),
                              //DropdownMenuItem<int>(value: yil + 2, child: Text((yil + 2).toString()))
                            ],
                            value: widget.uyeTahakkuk.yil,
                            onChanged: (value) {
                              if (value != null && value > 0) {
                                setState(() {
                                  widget.uyeTahakkuk.yil = value;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null || value == 0) {
                                return "Yıl Seçin";
                              } else {
                                return null;
                              }
                            })),
                    const SizedBox(width: 10),
                    Expanded(
                        child: DropdownButtonFormField(
                      value: widget.uyeTahakkuk.yoklama_id,
                      items: yoklamaMenuItems(widget.store.sabitler.yoklamalar),
                      onChanged: (value) {
                        if (value != null && value > 0) {
                          setState(() {
                            widget.uyeTahakkuk.yoklama_id = value;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value == 0) {
                          return "Yoklama Seçin";
                        } else {
                          return null;
                        }
                      },
                    ))
                  ]),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    DateTime? dt = await showDatePicker(
                        context: context,
                        initialDate: widget.uyeTahakkuk.odeme_tarih ?? DateTime.now(),
                        firstDate: DateTime(yil - 2, 1, 1),
                        lastDate: DateTime(yil + 2, 1, 1));
                    if (dt != null) {
                      setState(() {
                        widget.uyeTahakkuk.odeme_tarih = dt;
                      });
                    }
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => const Color.fromARGB(255, 192, 180, 8))),
                  child: Text("Tarih :${widget.uyeTahakkuk.odeme_tarih != null ? dateFormater(widget.uyeTahakkuk.odeme_tarih!, "dd.MM.yyyy") : "Hatalı"}",
                      textAlign: TextAlign.left),
                ))
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                        decoration: const InputDecoration(labelText: "Tutar(TL)"),
                        controller: tutarcon,
                        keyboardType: TextInputType.number,
                        //inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                        onChanged: (value) {
                          setState(() {
                            widget.uyeTahakkuk.odenen = tutarcon.numberValue;
                          });
                        },
                        validator: (value) {
                          if ((value ?? "TL").trim() == "TL") {
                            return "Lütfen bir tutar girin";
                          } else {
                            return null;
                          }
                        }))
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: DropdownButtonFormField(
                  value: widget.uyeTahakkuk.kasa,
                  decoration: const InputDecoration(labelText: "Kasa"),
                  items: kasalar,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        widget.uyeTahakkuk.kasa = value;
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
                ))
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Açıklama",
                ),
                controller: aciklamacon,
                onChanged: (value) {
                  setState(() {
                    widget.uyeTahakkuk.aciklama = value;
                  });
                },
              )),
            ]),
            const SizedBox(height: 60),
            Row(children: btnGorup()),
          ]),
        ));
  }
}
