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
  List<SeviyeBildirim> listSeviyeBildirim = [];
  DateTime bitis = DateTime.now();
  DateTime baslangic = DateTime.now().subtract(const Duration(days: 90));
  final minTar = DateTime(buYil - 3, 1, 1);
  final maxTar = DateTime(buYil + 2, 1, 1);

  @override
  void initState() {
    super.initState();
    loadingdlg = LoadingDialog(context);
    tbc = TabController(length: 3, vsync: this, initialIndex: 0);
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
  }

  Future<void> openExcel(String reportName, Excel excel) async {
    Directory tempDir = await getTemporaryDirectory();
    final fname = "${tempDir.path}/$reportName${dateFormater(DateTime.now(), "yyyyMMddHHmmss")}.xlsx";
    final file = File(fname);
    await file.writeAsBytes(excel.save(fileName: fname)!);

    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      if (context.mounted) errorAlert(context, result.message);
    }
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
                tabs: const [Tab(text: "Gelir\nGider"), Tab(text: "Seviye\nBildirimi"), Tab(text: "Genel Üye\nRaporu")],
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
                                    openExcel("gelirgider", excel);
                                  } catch (err) {
                                    if (context.mounted) errorAlert(context, err.toString());
                                  }

                                  ///data/user/0/com.example.dojoflu/cache/gelirgider20230417144247.xlsx
                                },
                                child: const Text("Excel Dökümanı .xlsx"))
                          ]));
                    }),
                Expanded(
                    child: FBuilder(
                  future: rapor_seviyebildirim(api, listSeviyeBildirim),
                  builder: (data) {
                    return Column(children: [
                      Expanded(
                          child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    border: TableBorder.all(color: Colors.black),
                                    columns: const [
                                      DataColumn(label: Text("Ad")),
                                      DataColumn(label: Text("EkfNo")),
                                      DataColumn(label: Text("Doğum Tarihi")),
                                      DataColumn(label: Text("Seviye")),
                                      DataColumn(label: Text("Sınav Tarihi")),
                                      DataColumn(label: Text("Açıklama"))
                                    ],
                                    rows: List<DataRow>.generate(listSeviyeBildirim.length, (index) {
                                      final sb = listSeviyeBildirim[index];
                                      return DataRow(cells: [
                                        DataCell(Text(sb.ad)),
                                        DataCell(Text(sb.ekfno)),
                                        DataCell(Text(dateFormater(sb.dogum_tarih, "dd.MM.yyyy"))),
                                        DataCell(Text(sb.seviye)),
                                        DataCell(Text(dateFormater(sb.tarih, "dd.MM.yyyy"))),
                                        DataCell(Text(sb.aciklama))
                                      ]);
                                    }),
                                  )))),
                      ElevatedButton(
                          onPressed: () async {
                            try {
                              final excel = Excel.createExcel();
                              final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = "Ad";
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = "EkfNo";
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = "Doğum Tarihi";
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = "Seviye";
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value = "Sınav Tarihi";
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = "Açıklama";
                              for (int i = 0; i < listSeviyeBildirim.length; i++) {
                                final sb = listSeviyeBildirim[i];
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2)).value = sb.ad;
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2)).value = sb.ekfno;
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2)).value = sb.dogum_tarih;
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2)).value = sb.seviye;
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 2)).value = sb.tarih;
                                sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 2)).value = sb.aciklama;
                              }
                              openExcel("gelirgider", excel);
                            } catch (err) {
                              if (context.mounted) errorAlert(context, err.toString());
                            }
                          },
                          child: const Text("Excel Dökümanı .xlsx"))
                    ]);
                  },
                )),
                Center(
                    child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final result = await rapor_geneluyeraporu(api);
                            final excel = Excel.createExcel();
                            final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1)).value = "Üye ID";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1)).value = "Ad";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1)).value = "Email";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1)).value = "Cinsiyet";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 1)).value = "Doğum Tarihi";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 1)).value = "EkfNo";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 1)).value = "Durum";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 1)).value = "Tahakkuk";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 1)).value = "Seviye";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: 1)).value = "Sınav Tarihi";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: 1)).value = "Borç Tutarı";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: 1)).value = "Borc Sayısı";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: 1)).value = "Devam Sayısı";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: 1)).value = "İlk Keiko";
                            sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: 1)).value = "Son Seiko";
                            for (int i = 0; i < result.length; i++) {
                              final r = result[i];
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 2)).value = r.uye_id;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 2)).value = r.ad;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 2)).value = r.email;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 2)).value = r.cinsiyet;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 2)).value = r.dogum_tarih;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 2)).value = r.ekfno;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 2)).value = r.durum;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: i + 2)).value = r.tahakkuk;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: i + 2)).value = r.seviye;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: i + 2)).value = r.sinav_tarih;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: i + 2)).value = r.borc_tutar;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: i + 2)).value = r.borc_sayi;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: i + 2)).value = r.devam_sayi;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: i + 2)).value = r.ilk;
                              sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: i + 2)).value = r.son;
                            }
                            openExcel("gelirgider", excel);
                          } catch (err) {
                            if (context.mounted) errorAlert(context, err.toString());
                          }
                        },
                        child: const Text("Excel Dökümanı .xlsx")))
              ]))
            ])));
  }
}
