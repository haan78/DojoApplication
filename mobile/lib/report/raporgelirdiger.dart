import 'package:dojo_mobile/service/servicemethods.dart';
import 'package:dojo_mobile/service/servicetypes.dart';
import 'package:dojo_mobile/tools/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class RaporGelirGider extends StatefulWidget {
  final Api api;
  const RaporGelirGider({super.key, required this.api});

  @override
  State<StatefulWidget> createState() {
    return _RaporGelirGider();
  }
}

class _RaporGelirGider extends State<RaporGelirGider> {
  List<GelirGiderDetay> listGelirGiderDetay = [];
  DateTime bitis = DateTime.now();
  DateTime baslangic = DateTime.now().subtract(const Duration(days: 90));
  final minTar = DateTime(buYil - 3, 1, 1);
  final maxTar = DateTime(buYil + 2, 1, 1);
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return FBuilder<void>(
        future: rapor_gelirgider_detay(widget.api, baslangic, bitis, listGelirGiderDetay),
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
                        final dt = await showDatePicker(context: context, initialDate: bitis, firstDate: minTar, lastDate: maxTar);
                        if (dt != null) {
                          if (dt.difference(baslangic).inDays >= 0) {
                            setState(() {
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
                      if (loading) return;
                      loading = true;
                      try {
                        final excel = Excel.createExcel();
                        final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = "Ad";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = "Tarih";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = "Tanım";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = "Kasa";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0)).value = "Tutar";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0)).value = "Tür";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0)).value = "Tahsilatcı";
                        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0)).value = "Açıklama";
                        for (int i = 0; i < listGelirGiderDetay.length; i++) {
                          final row = listGelirGiderDetay[i];
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1)).value = row.ad;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1)).value = dateFormater(row.tarih, "dd/MM/yyyy");
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1)).value = row.tanim;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1)).value = row.kasa;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1)).value = row.tutar;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1)).value = row.tur;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1)).value = row.tahsilatci;
                          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1)).value = row.aciklama;
                        }
                        openExcel(context, "gelirgider", excel);
                      } catch (err) {
                        if (context.mounted) {
                          errorAlert(context, err.toString());
                        }
                      }
                      loading = false;
                    },
                    child: const Text("Excel Dökümanı .xlsx"))
              ]));
        });
  }
}
