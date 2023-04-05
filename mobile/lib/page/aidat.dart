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
  const Aidat(BuildContext context, {super.key, required this.uyeTahakkuk, required this.store, required this.uyeAd, required this.uyeId});

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _Aidat();
  }
}

class _Aidat extends State<Aidat> {
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final aciklamacon = TextEditingController();
  late Api api;

  late MoneyMaskedTextController tutarcon;

  @override
  void initState() {
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    widget.uyeTahakkuk.odeme_tarih ??= DateTime.now();

    aciklamacon.text = widget.uyeTahakkuk.aciklama;
    if (widget.uyeTahakkuk.muhasebe_id == 0) {
      widget.uyeTahakkuk.odenen = widget.uyeTahakkuk.borc;
    }
    tutarcon = MoneyMaskedTextController(thousandSeparator: ".", decimalSeparator: "", rightSymbol: "TL", precision: 0, initialValue: widget.uyeTahakkuk.odenen);
    super.initState();
  }

  List<Widget> btnGorup() {
    List<Widget> bgl = [
      Expanded(
          child: ElevatedButton(
        onPressed: loading
            ? null
            : () async {
                if (_formKey.currentState!.validate()) {
                  int muhasebeId = 0;
                  setState(() {
                    loading = true;
                  });
                  try {
                    muhasebeId = await aidatodemeal(api, widget.uyeTahakkuk, widget.uyeId);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    errorAlert(context, e.toString());
                  } finally {
                    setState(() {
                      loading = false;
                      widget.uyeTahakkuk.muhasebe_id = muhasebeId;
                    });
                  }
                }
              },
        child: const Text("Kaydet"),
      ))
    ];
    if (widget.uyeTahakkuk.muhasebe_id > 0) {
      bgl.add(const SizedBox(width: 20));
      bgl.add(SizedBox(
        width: 50,
        child: ElevatedButton(
          onPressed: loading
              ? null
              : () {
                  //Silme Buraya
                  yesNoDialog(context, text: "Bu ödeme kaydını silmek istediğinizden emin misiniz?", onYes: (() async {
                    setState(() {
                      loading = true;
                    });
                    int muhasebeId = widget.uyeTahakkuk.muhasebe_id;
                    try {
                      await aidatsil(api, widget.uyeTahakkuk.muhasebe_id);
                      muhasebeId = 0;
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      errorAlert(context, e.toString());
                    } finally {
                      setState(() {
                        widget.uyeTahakkuk.muhasebe_id = muhasebeId;
                        loading = false;
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
            Text("${widget.uyeTahakkuk.tanim} ${aylarText[widget.uyeTahakkuk.ay - 1]} / ${widget.uyeTahakkuk.yil}"),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                  onPressed: () async {
                    DateTime? dt = await showDatePicker(
                        context: context, initialDate: widget.uyeTahakkuk.odeme_tarih!, firstDate: DateTime(yil - 3, 1, 1), lastDate: DateTime(yil + 3, 1, 1));
                    if (dt != null) {
                      setState(() {
                        widget.uyeTahakkuk.odeme_tarih = dt;
                      });
                    }
                  },
                  style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => const Color.fromARGB(255, 192, 180, 8))),
                  child: Text("Tarih :${dateFormater(widget.uyeTahakkuk.odeme_tarih!, "dd.MM.yyyy")}", textAlign: TextAlign.left),
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
