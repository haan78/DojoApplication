import 'package:dojo_mobile/service.dart';
import 'package:dojo_mobile/tools/fotocek.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../api.dart';
import '../../store.dart';
import '../appwindow.dart';
import '../widget/alert.dart';

class KendokaBase extends StatefulWidget {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;

  final List<DropdownMenuItem<int>> ddTahakkular = [];
  KendokaBase({super.key, required this.sabitler, required this.bilgi, required this.store}) {
    for (final t in sabitler.tahakkuklar) {
      ddTahakkular.add(DropdownMenuItem(value: t.tahakkuk_id, child: Text(t.tanim)));
    }
    if (bilgi.uye_id == 0) {
      bilgi.durum = 'registered';
    }
  }

  @override
  State<StatefulWidget> createState() {
    return _KendokaBase();
  }
}

class _KendokaBase extends State<KendokaBase> {
  final _formKey = GlobalKey<FormState>();
  final tbas = DateTime(DateTime.now().year - 70, 1, 1);
  final tbit = DateTime(DateTime.now().year - 10, 1, 1);

  bool resimsecildi = true;
  bool tarihsecildi = true;
  late Api api;
  late Image buttonImage;
  late TextEditingController emailEdit;
  late TextEditingController ekfnoEdit;
  TextEditingController adEdit = TextEditingController();
  Uint8List? imgdata;
  String? imagePath;

  late LoadingDialog loadingdlg;

  @override
  void initState() {
    super.initState();
    loadingdlg = LoadingDialog(context);
    adEdit.text = widget.bilgi.ad;
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    ekfnoEdit = TextEditingController(text: widget.bilgi.ekfno);
    emailEdit = TextEditingController(text: widget.bilgi.email);
    buttonImage = uyeImageLoad(widget.store, widget.bilgi.uye_id, fit: BoxFit.fill);
    if (widget.bilgi.uye_id == 0) {
      resimsecildi = false;
      tarihsecildi = false;
    } else {
      resimsecildi = true;
      tarihsecildi = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextButton(
                style: TextButton.styleFrom(padding: const EdgeInsets.all(0), fixedSize: const Size(170, 250)),
                onPressed: () async {
                  final xfile = await fotoFile();
                  if (xfile != null) {
                    final bytes = await xfile.readAsBytes();
                    final path = xfile.path;
                    setState(() {
                      buttonImage = Image.memory(bytes, fit: BoxFit.fill);
                      imagePath = path;
                      resimsecildi = true;
                    });
                  }
                },
                child: buttonImage),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  flex: 2,
                  child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          widget.bilgi.ad = value;
                        });
                        //update(bilgi);
                      },
                      decoration: const InputDecoration(labelText: "Ad"),
                      controller: adEdit,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        } else {
                          return "Geçerli bir isim girin";
                        }
                      })),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      //height: 60,
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: "Cinsiyet"),
                          value: widget.bilgi.cinsiyet,
                          validator: (value) {
                            if (value == null || value == "") {
                              return "Cinsiyet seçimi gerekli";
                            } else {
                              return null;
                            }
                          },
                          items: const [DropdownMenuItem(value: "ERKEK", child: Text("Erkek")), DropdownMenuItem(value: "KADIN", child: Text("Kadın"))],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                widget.bilgi.cinsiyet = value;
                              });
                            }
                          }))),
            ]),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(labelText: "E-Posta"),
                keyboardType: TextInputType.emailAddress,
                controller: emailEdit,
                onChanged: (value) {
                  setState(() {
                    widget.bilgi.email = value;
                  });
                },
                validator: (value) {
                  if (value == null || !isEmail(value)) {
                    return "E-Posta formatı doğru değil";
                  } else {
                    return null;
                  }
                },
              )),
              TextButton(
                  onPressed: () async {
                    DateTime? dt;
                    if (tarihsecildi) {
                      dt = await showDatePicker(context: context, initialDate: widget.bilgi.dogum_tarih, firstDate: tbas, lastDate: tbit);
                    } else {
                      dt = await showDatePicker(context: context, initialDate: tbit, firstDate: tbas, lastDate: tbit);
                    }
                    if (dt != null) {
                      setState(() {
                        widget.bilgi.dogum_tarih = dt!;
                        tarihsecildi = true;
                      });
                    }
                  },
                  child: Column(
                    children: [const Text("Doğum Tarihi"), Text(tarihsecildi ? dateFormater(widget.bilgi.dogum_tarih, "dd.MM.yyyy") : "[Seçiniz]")],
                  ))
            ]),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: SizedBox(
                      child: widget.bilgi.uye_id > 0
                          ? DropdownButtonFormField(
                              decoration: const InputDecoration(labelText: "Durum"),
                              value: widget.bilgi.durum,
                              items: [
                                DropdownMenuItem(value: "active", enabled: (widget.bilgi.durum != "registered"), child: const Text("Aktif")),
                                DropdownMenuItem(value: "passive", enabled: (widget.bilgi.durum != "registered"), child: const Text("Pasif")),
                                DropdownMenuItem(
                                  value: "admin",
                                  enabled: (widget.bilgi.durum != "registered"),
                                  child: const Text("Admin"),
                                ),
                                DropdownMenuItem(value: "super-admin", enabled: (widget.bilgi.durum != "registered"), child: const Text("Süper-Admin")),
                                DropdownMenuItem(
                                  value: "registered",
                                  enabled: (widget.bilgi.durum == "registered"),
                                  child: const Text("Yeni Kayıt"),
                                )
                              ],
                              onChanged: (value) {
                                if (value != null && widget.bilgi.durum != "registered") {
                                  const adlist = ["admin", "super-admin"];
                                  if (widget.store.UserStatus != "super-admin" && (adlist.contains(value) || adlist.contains(widget.bilgi.durum))) {
                                    errorAlert(context, "Sadece Süper-Admin böyle bir değişikliği yapabilir");
                                  } else {
                                    setState(() {
                                      widget.bilgi.durum = value;
                                    });
                                  }
                                }
                              },
                            )
                          : null)),
              const SizedBox(width: 10),
              Expanded(
                  child: SizedBox(
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: "Üyelik Tipi"),
                          value: widget.bilgi.tahakkuk_id,
                          items: widget.ddTahakkular,
                          onChanged: ((value) {
                            if (value != null) {
                              setState(() {
                                widget.bilgi.tahakkuk_id = value;
                              });
                            }
                          }))))
            ]),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(
                  child: SizedBox(
                      child: TextFormField(
                decoration: const InputDecoration(labelText: "EKF no"),
                controller: ekfnoEdit,
                onChanged: (value) {
                  setState(() {
                    widget.bilgi.ekfno = value;
                  });
                },
              ))),
            ]),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () async {
                  if (loadingdlg.started) {
                    return;
                  }
                  if (!resimsecildi) {
                    errorAlert(context, "Lütfen üyenin fotoğrafını yükleyin");
                    return;
                  }

                  if (!tarihsecildi) {
                    errorAlert(context, "Lütfen üyenin doğum tarihini seçin");
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    try {
                      loadingdlg.push();
                      widget.bilgi.uye_id = await uyeKayit(api, ub: widget.bilgi, foto: imagePath);
                      loadingdlg.pop();
                      if (widget.bilgi.durum == "registered" && context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (err) {
                      if (loadingdlg.started) loadingdlg.pop();
                      errorAlert(context, err.toString());
                    }
                  }
                },
                child: const Text("Kaydet"))
          ],
        ));
  }
}
