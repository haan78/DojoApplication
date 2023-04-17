import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../api.dart';
import '../store.dart';
import 'appwindow.dart';

class RaporlarPage extends StatefulWidget {
  final Store store;
  const RaporlarPage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _RaporlarPage();
  }
}

class _RaporlarPage extends State<RaporlarPage> with TickerProviderStateMixin {
  late TabController tbc;
  late Api api;
  late LoadingDialog loadingdlg;

  List<GelirGiderDetay> listGelirGiderDetay = [];
  DateTime bitis = DateTime.now();
  DateTime baslangic = DateTime.now().subtract(const Duration(days: 90));
  final minTar = DateTime(buYil - 3, 1, 1);
  final maxTar = DateTime(buYil + 2, 1, 1);

  @override
  void initState() {
    super.initState();
    loadingdlg = LoadingDialog(context);
    tbc = TabController(length: 4, vsync: this, initialIndex: 0);
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: appDrawer(context),
        appBar: AppBar(title: appTitle(text: "Raporlar")),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              TabBar(
                onTap: (value) {},
                labelColor: Colors.black,
                controller: tbc,
                labelStyle: const TextStyle(fontSize: 11),
                tabs: const [Tab(text: "Gelir\nGider"), Tab(text: "Borçlular"), Tab(text: "Gelmeyenler"), Tab(text: "Seviye\nBildirimi")],
              ),
              Expanded(
                  child: TabBarView(controller: tbc, children: [
                FBuilder<void>(
                    future: rapor_gelirgider_detay(api, baslangic, bitis, listGelirGiderDetay),
                    builder: (data) {
                      return Padding(
                          padding: appPading,
                          child: Column(children: [
                            Row(children: [
                              ElevatedButton(
                                  onPressed: () async {
                                    final dt = await showDatePicker(context: context, initialDate: baslangic, firstDate: minTar, lastDate: maxTar);
                                    if (dt != null) {
                                      if (bitis.difference(dt).inDays >= 0) {
                                        setState(() {
                                          baslangic = dt;
                                        });
                                      } else {
                                        if (context.mounted) errorAlert(context, "Başlangıç tarihi bitiş tarihinden büyük olamaz");
                                      }
                                    }
                                  },
                                  child: Text("Başlangıc ${dateFormater(baslangic, "dd.MM.yyyy")}")),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                  onPressed: () async {
                                    final dt = await showDatePicker(context: context, initialDate: baslangic, firstDate: minTar, lastDate: maxTar);
                                    if (dt != null) {
                                      if (bitis.difference(dt).inDays < 0) {
                                        setState(() {
                                          bitis = dt;
                                        });
                                      } else {
                                        if (context.mounted) errorAlert(context, "Bitiş tarihi başlangıçtan büyük olamaz");
                                      }
                                    }
                                  },
                                  child: Text("Bitiş ${dateFormater(bitis, "dd.MM.yyyy")}"))
                            ]),
                            Expanded(
                                child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: DataTable(
                                            border: TableBorder.all(color: Colors.black),
                                            columns: const [
                                              DataColumn(label: Text("Ad")),
                                              DataColumn(label: Text("Tarih")),
                                              DataColumn(label: Text("Tanım")),
                                              DataColumn(label: Text("Kasa")),
                                              DataColumn(label: Text("Tutar")),
                                              DataColumn(label: Text("Tür")),
                                              DataColumn(label: Text("Tahsilatcı")),
                                              DataColumn(label: Text("Açıklama"))
                                            ],
                                            rows: List<DataRow>.generate(listGelirGiderDetay.length, (index) {
                                              final ggd = listGelirGiderDetay[index];
                                              final dr = DataRow(cells: [
                                                DataCell(Text(ggd.ad)),
                                                DataCell(Text(dateFormater(ggd.tarih, "dd.MM.yyyy"))),
                                                DataCell(Text(ggd.tanim)),
                                                DataCell(Text(ggd.kasa)),
                                                DataCell(Text(ggd.tutar.toString())),
                                                DataCell(Text(ggd.tur)),
                                                DataCell(Text(ggd.tahsilatci)),
                                                DataCell(Text(ggd.aciklama))
                                              ]);
                                              return dr;
                                            }))))),
                            ElevatedButton(
                                onPressed: () async {
                                  try {
                                    loadingdlg.push();
                                    final excel = Excel.createExcel();
                                    final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = "Ad";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = "Tarih";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = "Tanım";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = "Kasa";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value = "Tutar";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = "Tür";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1)).value = "Tahsilatcı";
                                    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 1)).value = "Açıklama";
                                    for (int i = 0; i < listGelirGiderDetay.length; i++) {
                                      final row = listGelirGiderDetay[i];
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2)).value = row.ad;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2)).value = row.tarih;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2)).value = row.tanim;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2)).value = row.kasa;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 2)).value = row.tutar;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 2)).value = row.tur;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 2)).value = row.tahsilatci;
                                      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 2)).value = row.aciklama;
                                    }
                                    Directory tempDir = await getTemporaryDirectory();
                                    final fname = "${tempDir.path}/gelirgider${dateFormater(DateTime.now(), "yyyyMMddHHmmss")}.xlsx";
                                    final file = File(fname);
                                    await file.writeAsBytes(excel.save(fileName: fname)!);
                                    await OpenFile.open(file.path);
                                    //final result = excel.save();
                                    //print(result);
                                    loadingdlg.pop();
                                  } catch (err) {
                                    if (loadingdlg.started) loadingdlg.pop();
                                    if (context.mounted) errorAlert(context, err.toString());
                                  }

                                  ///data/user/0/com.example.dojoflu/cache/gelirgider20230417144247.xlsx
                                },
                                child: const Text("Excel File .xlsx"))
                          ]));
                    }),
                Text("2"),
                Text("3"),
                Text("4")
              ]))
            ])));
  }
}
