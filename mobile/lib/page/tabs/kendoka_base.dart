import 'dart:developer';

import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api.dart';
import '../../store.dart';
import '../appwindow.dart';
import '../widget/alert.dart';

final _formKey = GlobalKey<FormState>();
// ignore: camel_case_types

class KendokaBase extends StatefulWidget {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;

  final List<DropdownMenuItem<int>> ddTahakkular = [];
  KendokaBase({super.key, required this.sabitler, required this.bilgi, required this.store}) {
    for (final t in sabitler.tatakkuklar) {
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
  final ImagePicker _imgpicker = ImagePicker();
  bool loading = false;
  late Api api;
  late Image buttonImage;
  late TextEditingController emailEdit;
  late TextEditingController ekfnoEdit;
  int yil = DateTime.now().year;
  TextEditingController adEdit = TextEditingController();

  @override
  void initState() {
    super.initState();
    adEdit.text = widget.bilgi.ad;
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    ekfnoEdit = TextEditingController(text: widget.bilgi.ekfno);
    emailEdit = TextEditingController(text: widget.bilgi.email);
    buttonImage = Image.memory(widget.bilgi.image!, fit: BoxFit.fill);
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
                  XFile? xfile = await _imgpicker.pickImage(source: ImageSource.camera, maxHeight: 800, maxWidth: 600);
                  if (xfile != null) {
                    //formUyeBilgi.image = await xfile.readAsBytes();
                    final bytes = await xfile.readAsBytes();
                    setState(() {
                      widget.bilgi.image = bytes;
                      widget.bilgi.file_type = xfile.mimeType ?? "";
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
                    DateTime t = widget.bilgi.dogum_tarih;
                    if (widget.bilgi.uye_id == 0) {
                      t = DateTime(yil - 10, 1, 1);
                    }
                    DateTime? dt = await showDatePicker(context: context, initialDate: t, firstDate: DateTime(yil - 70, 1, 1), lastDate: DateTime(yil - 10, 1, 1));
                    if (dt != null) {
                      widget.bilgi.dogum_tarih = dt;
                    }
                  },
                  child: Column(
                    children: [const Text("Doğum Tarihi"), Text(dateFormater(widget.bilgi.dogum_tarih, "dd.MM.yyyy"))],
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
                              items: widget.bilgi.uye_id > 0
                                  ? const [
                                      DropdownMenuItem(value: "active", child: Text("Aktif")),
                                      DropdownMenuItem(value: "passive", child: Text("Pasif")),
                                      DropdownMenuItem(
                                        value: "admin",
                                        child: Text("Admin"),
                                      ),
                                      DropdownMenuItem(value: "super-admin", child: Text("Süper-Admin"))
                                    ]
                                  : const [DropdownMenuItem(value: "registered", child: Text("Yeni Kayıt"))],
                              onChanged: (value) {
                                if (value != null) {
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
                onPressed: loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });

                          uyeKayit(api, ub: widget.bilgi);
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                child: const Text("Kaydet"))
          ],
        ));
  }
}
