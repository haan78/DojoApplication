// ignore: file_names
import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../api.dart';
import '../../store.dart';
import '../widget/alert.dart';

final _formKey = GlobalKey<FormState>();
// ignore: camel_case_types

class KendokaBase extends StatelessWidget {
  final UyeBilgi bilgi;
  final Store store;
  final UpdateParentData updateParentData;
  final Sabitler sabitler;
  final ImagePicker _imgpicker = ImagePicker();
  KendokaBase({super.key, required this.sabitler, required this.bilgi, required this.store, required this.updateParentData});

  @override
  Widget build(BuildContext context) {
    TextEditingController adEdit = TextEditingController(text: bilgi.ad);
    TextEditingController ekfnoEdit = TextEditingController(text: bilgi.ekfno);
    Image buttonImage = Image.memory(bilgi.image!, fit: BoxFit.fill);
    List<DropdownMenuItem<int>> ddTahakkular = [];
    for (final t in sabitler.tatakkuklar) {
      ddTahakkular.add(DropdownMenuItem(value: t.tahakkuk_id, child: Text(t.tanim)));
    }

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
                    bilgi.image = await xfile.readAsBytes();
                    updateParentData(bilgi, false);
                  }
                },
                child: buttonImage),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  flex: 2,
                  child: TextFormField(
                      onEditingComplete: () {
                        bilgi.ad = adEdit.value.text;
                        updateParentData(bilgi, false);
                      },
                      decoration: const InputDecoration(labelText: "Ad"),
                      controller: adEdit,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return null;
                        } else {
                          return "Ge??erli bir isim girin";
                        }
                      })),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: SizedBox(
                      //height: 60,
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: "Cinsiyet"),
                          value: bilgi.cinsiyet.isEmpty ? "" : bilgi.cinsiyet,
                          validator: (value) {
                            if (value == null || value == "") {
                              return "Cinsiyet se??imi gerekli";
                            } else {
                              return null;
                            }
                          },
                          items: const [DropdownMenuItem(value: "ERKEK", child: Text("Erkek")), DropdownMenuItem(value: "KADIN", child: Text("Kad??n"))],
                          onChanged: (value) {
                            if (value != null) {
                              bilgi.cinsiyet = value;
                              updateParentData(bilgi, false);
                            }
                          }))),
            ]),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: TextFormField(
                decoration: const InputDecoration(labelText: "E-Posta"),
                controller: TextEditingController(text: bilgi.email),
                validator: (value) {
                  if (value == null || !isEmail(value)) {
                    return "E-Posta format?? do??ru de??il";
                  } else {
                    return null;
                  }
                },
              )),
              TextButton(
                  onPressed: () async {
                    DateTime? dt =
                        await showDatePicker(context: context, initialDate: bilgi.dogum_tarih, firstDate: DateTime(1950, 1, 1), lastDate: DateTime(2012, 1, 1));
                    if (dt != null) {
                      bilgi.dogum_tarih = dt;
                      updateParentData(bilgi, false);
                    }
                  },
                  child: Column(
                    children: [const Text("Do??um Tarihi"), Text(dateFormater(bilgi.dogum_tarih, "dd.MM.yyyy"))],
                  ))
            ]),
            const SizedBox(height: 15),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(
                  child: SizedBox(
                      child: DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Durum"),
                value: bilgi.durum,
                items: const [
                  DropdownMenuItem(value: "active", child: Text("Aktif")),
                  DropdownMenuItem(value: "passive", child: Text("Pasif")),
                  DropdownMenuItem(
                    value: "admin",
                    child: Text("Admin"),
                  ),
                  DropdownMenuItem(value: "super-admin", child: Text("S??per-Admin"))
                ],
                onChanged: (value) {
                  if (value != null) {
                    const adlist = ["admin", "super-admin"];
                    if (store.UserStatus != "super-admin" && (adlist.contains(value) || adlist.contains(bilgi.durum))) {
                      errorAlert(context, "Sadece S??per-Admin b??yle bir de??i??ikli??i yapabilir");
                      return;
                    }
                    bilgi.durum = value;
                    updateParentData(bilgi, false);
                  }
                },
              ))),
              const SizedBox(width: 10),
              Expanded(
                  child: SizedBox(
                      child: DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: "??yelik Tipi"),
                          value: bilgi.tahakkuk_id,
                          items: ddTahakkular,
                          onChanged: ((value) {
                            if (value != null) {
                              bilgi.tahakkuk_id = value;
                              updateParentData(bilgi, false);
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
                onEditingComplete: () {
                  bilgi.ekfno = ekfnoEdit.value.text;
                  updateParentData(bilgi, false);
                },
              ))),
            ]),
            const SizedBox(height: 15),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print("Kay??t");
                  }
                },
                child: const Text("Kaydet"))
          ],
        ));
  }
}
