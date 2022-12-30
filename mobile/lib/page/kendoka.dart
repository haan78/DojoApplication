// ignore_for_file: no_logic_in_create_state, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';

final _formKey = GlobalKey<FormState>();
UyeBilgi formUyeBilgi = UyeBilgi();
Sabitler formSabitler = Sabitler();

class Kendoka extends StatefulWidget {
  final int uye_id;
  const Kendoka(this.uye_id, {super.key});

  @override
  State<Kendoka> createState() {
    return _Kendoka(uye_id);
  }
}

class _Kendoka extends State<Kendoka> {
  final int uye_id;
  bool _reload = true;

  final ImagePicker _imgpicker = ImagePicker();

  _Kendoka(this.uye_id);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Store store = Provider.of<Store>(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
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
          Text(store.AppName)
        ],
      )),
      body: FutureBuilder<UyeBilgi>(
        future: yueBilgiGetir(store, uye_id, _reload),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            UyeBilgi ub = snapshot.data!;
            Image _buttonImage = Image.memory(ub.image!, fit: BoxFit.fill);
            List<DropdownMenuItem<int>> ddTahakkular = [];
            for (final t in formSabitler.tatakkuklar) {
              ddTahakkular.add(DropdownMenuItem(value: t.tahakkuk_id, child: Text(t.tanim)));
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextButton(
                          style: TextButton.styleFrom(padding: const EdgeInsets.all(0), fixedSize: const Size(170, 250)),
                          onPressed: () async {
                            XFile? xfile = await _imgpicker.pickImage(source: ImageSource.camera, maxHeight: 800, maxWidth: 600);
                            if (xfile != null) {
                              formUyeBilgi.image = await xfile.readAsBytes();

                              setState(() {
                                _reload = false;
                              });
                            }
                          },
                          child: _buttonImage),
                      const SizedBox(height: 15),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: "Ad"),
                              controller: TextEditingController(text: ub.ad),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  return null;
                                } else {
                                  return "Geçerli bir isim girin";
                                }
                              },
                              onChanged: (value) {
                                formUyeBilgi.ad = value;
                              },
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                            flex: 1,
                            child: SizedBox(
                                //height: 60,
                                child: DropdownButtonFormField(
                                    decoration: const InputDecoration(labelText: "Cinsiyet"),
                                    value: ub.cinsiyet.isEmpty ? "" : ub.cinsiyet,
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
                                        formUyeBilgi.cinsiyet = value;
                                        setState(() {
                                          _reload = false;
                                        });
                                      }
                                    }))),
                      ]),
                      const SizedBox(height: 15),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(
                            child: TextFormField(
                          decoration: const InputDecoration(labelText: "E-Posta"),
                          controller: TextEditingController(text: ub.email),
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
                              DateTime? dt =
                                  await showDatePicker(context: context, initialDate: ub.dogum_tarih, firstDate: DateTime(1950, 1, 1), lastDate: DateTime(2012, 1, 1));
                              if (dt != null) {
                                formUyeBilgi.dogum_tarih = dt;
                                setState(() {
                                  _reload = false;
                                });
                              }
                            },
                            child: Column(
                              children: [const Text("Doğum Tarihi"), Text(dateFormater(ub.dogum_tarih, "dd.MM.yyyy"))],
                            ))
                      ]),
                      const SizedBox(height: 15),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(
                            child: SizedBox(
                                child: DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: "Durum"),
                          value: ub.durum,
                          items: const [
                            DropdownMenuItem(value: "active", child: Text("Aktif")),
                            DropdownMenuItem(value: "passive", child: Text("Pasif")),
                            DropdownMenuItem(
                              value: "admin",
                              child: Text("Admin"),
                            ),
                            DropdownMenuItem(value: "super-admin", child: Text("Süper-Admin"))
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              const adlist = ["admin", "super-admin"];
                              if (store.UserStatus != "super-admin" && (adlist.contains(value) || adlist.contains(formUyeBilgi.durum))) {
                                errorAlert(context, "Sadece Süper-Admin böyle bir değişikliği yapabilir");
                                return;
                              }
                              formUyeBilgi.durum = value;

                              setState(() {
                                _reload = false;
                              });
                            }
                          },
                        ))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: SizedBox(
                                child: DropdownButtonFormField(
                                    decoration: const InputDecoration(labelText: "Üyelik Tipi"),
                                    value: ub.tahakkuk_id,
                                    items: ddTahakkular,
                                    onChanged: ((value) {
                                      if (value != null) {
                                        formUyeBilgi.tahakkuk_id = value;
                                        setState(() {
                                          _reload = false;
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
                          controller: TextEditingController(text: ub.ekfno),
                          onChanged: (value) {
                            formUyeBilgi.ekfno = value;
                          },
                        ))),
                      ]),
                      const SizedBox(height: 15),
                      ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              print("Kayıt");
                            }
                          },
                          child: const Text("Kaydet"))
                    ],
                  )),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading...");
          } else {
            return const Text("Service Error");
          }
        },
      ),
    );
  }
}

Future<UyeBilgi> yueBilgiGetir(Store store, int uye_id, bool reload) async {
  if (reload) {
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    formSabitler = await sabitGetir(api);
    if (uye_id > 0) {
      formUyeBilgi = await uyeBilgi(api, uye_id: uye_id);
    } else {
      formUyeBilgi = UyeBilgi();
      formUyeBilgi.cinsiyet = "ERKEK";
      formUyeBilgi.durum = "active";
      formUyeBilgi.tahakkuk_id = 1;
      formUyeBilgi.image = (await rootBundle.load("assets/kendoka.jpg")).buffer.asUint8List();
    }
  }

  return Future<UyeBilgi>(
    () {
      return formUyeBilgi;
    },
  );
}
