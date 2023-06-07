import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';

class RaporEldenTahsilat extends StatefulWidget {
  final Api api;
  const RaporEldenTahsilat({super.key, required this.api});

  @override
  State<StatefulWidget> createState() {
    return _RaporEldenTahsilat();
  }
}

class _RaporEldenTahsilat extends State<RaporEldenTahsilat> {
  DateTime bitis = DateTime.now();
  DateTime baslangic = DateTime.now().subtract(const Duration(days: 30));
  final minTar = DateTime(buYil - 2, 1, 1);
  final maxTar = DateTime(buYil + 1, 1, 1);
  bool loading = false;
  bool reload = true;
  String thasilatci = "";
  double toplam = 0.0;
  List<String> tahsilatcilar = [];

  Future<List<EldenTahsilat>> load() async {
    if (reload || tahsilatcilar.isEmpty) {
      tahsilatcilar = await tahsilatci_list(widget.api, baslangic, bitis);
      thasilatci = tahsilatcilar.isNotEmpty ? tahsilatcilar[0] : "";
      reload = false;
    }
    final data = await rapor_eldentahsilat(widget.api, thasilatci, baslangic, bitis);
    toplam = 0;
    for (int i = 0; i < data.length; i++) {
      toplam += data[i].tutar;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return FBuilder(
        future: load(),
        builder: ((data) {
          return Padding(
              padding: appPading,
              child: Column(
                children: [
                  Row(children: [
                    ElevatedButton(
                        onPressed: () async {
                          final dt = await showDatePicker(context: context, initialDate: baslangic, firstDate: minTar, lastDate: maxTar);
                          if (dt != null) {
                            if (bitis.difference(dt).inDays >= 0) {
                              setState(() {
                                reload = true;
                                baslangic = dt;
                              });
                            } else {
                              if (context.mounted) {
                                errorAlert(context, "Başlangıç tarihi bitiş tarihinden büyük olamaz");
                              }
                            }
                          }
                        },
                        child: Text("Başlangıc ${dateFormater(baslangic, "dd.MM.yyyy")}")),
                    const SizedBox(width: 10),
                    ElevatedButton(
                        onPressed: () async {
                          final dt = await showDatePicker(context: context, initialDate: baslangic, firstDate: minTar, lastDate: maxTar);
                          if (dt != null) {
                            if (baslangic.difference(dt).inDays < 0) {
                              setState(() {
                                reload = true;
                                bitis = dt;
                              });
                            } else {
                              if (context.mounted) {
                                errorAlert(context, "Bitiş tarihi başlangıçtan büyük olamaz");
                              }
                            }
                          }
                        },
                        child: Text("Bitiş ${dateFormater(bitis, "dd.MM.yyyy")}"))
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Tahsilatcı"),
                      const SizedBox(width: 10),
                      DropdownButton<String>(
                          value: thasilatci.isNotEmpty ? thasilatci : null,
                          items: List<DropdownMenuItem<String>>.generate(tahsilatcilar.length, (index) {
                            return DropdownMenuItem<String>(value: tahsilatcilar[index], child: Text(tahsilatcilar[index].isEmpty ? "[Belirtilmemiş]" : tahsilatcilar[index]));
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                thasilatci = value;
                                reload = false;
                              });
                            }
                          }),
                      const SizedBox(width: 20),
                      Text(
                        "Toplam ${toplam.toString()} TL",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text("Ad")),
                          DataColumn(label: Text("Tarih")),
                          DataColumn(label: Text("Tutar")),
                          DataColumn(label: Text("Tanım")),
                          DataColumn(label: Text("Ay")),
                          DataColumn(label: Text("Yıl")),
                          DataColumn(label: Text("Açıklama")),
                          DataColumn(label: Text("Zaman"))
                        ],
                        rows: List<DataRow>.generate(data.length, (index) {
                          final et = data[index];
                          return DataRow(cells: [
                            DataCell(Text(et.ad)),
                            DataCell(Text(dateFormater(et.tarih, "dd.MM.yyyy"))),
                            DataCell(Text(et.tutar.toString())),
                            DataCell(Text(et.tanim)),
                            DataCell(Text(et.ay > 0 ? trAy(et.ay) : "")),
                            DataCell(Text(et.yil > 0 ? et.yil.toString() : "")),
                            DataCell(Text(et.aciklama)),
                            DataCell(Text(dateFormater(et.zaman, "dd.MM.yyyy HH:mm:ss"))),
                          ]);
                        }),
                      ),
                    ),
                  ))
                ],
              ));
        }));
  }
}
