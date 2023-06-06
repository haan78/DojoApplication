import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class RaporSeviyeBildirimi extends StatefulWidget {
  final Api api;
  const RaporSeviyeBildirimi({super.key, required this.api});

  @override
  State<StatefulWidget> createState() {
    return _RaporSeviyeBildirimi();
  }
}

class _RaporSeviyeBildirimi extends State<RaporSeviyeBildirimi> {
  List<SeviyeBildirim> listSeviyeBildirim = [];
  DateTime bitis = DateTime.now();
  DateTime baslangic = DateTime.now().subtract(const Duration(days: 90));
  final minTar = DateTime(buYil - 3, 1, 1);
  final maxTar = DateTime(buYil + 2, 1, 1);
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return FBuilder(
      future: rapor_seviyebildirim(widget.api, listSeviyeBildirim),
      builder: (data) {
        return Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        border: TableBorder.all(color: Colors.white),
                        columns: const [
                          DataColumn(label: Text("Sıra")),
                          DataColumn(label: Text("Ad")),
                          DataColumn(label: Text("EkfNo")),
                          DataColumn(label: Text("Doğum Tarihi")),
                          DataColumn(label: Text("Seviye")),
                          DataColumn(label: Text("Sınav Tarihi")),
                          DataColumn(label: Text("Açıklama"))
                        ],
                        rows: List<DataRow>.generate(listSeviyeBildirim.length,
                            (index) {
                          final sb = listSeviyeBildirim[index];
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString())),
                            DataCell(Text(sb.ad)),
                            DataCell(Text(sb.ekfno)),
                            DataCell(Text(
                                dateFormater(sb.dogum_tarih, "dd.MM.yyyy"))),
                            DataCell(Text(sb.seviye)),
                            DataCell(
                                Text(dateFormater(sb.tarih, "dd.MM.yyyy"))),
                            DataCell(Text(sb.aciklama))
                          ]);
                        }),
                      )))),
          ElevatedButton(
              onPressed: () async {
                if (loading) return;
                loading = true;
                try {
                  final excel = Excel.createExcel();
                  final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 0, rowIndex: 0))
                      .value = "Ad";
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 1, rowIndex: 0))
                      .value = "EkfNo";
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 2, rowIndex: 0))
                      .value = "Doğum Tarihi";
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 3, rowIndex: 0))
                      .value = "Seviye";
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 4, rowIndex: 0))
                      .value = "Sınav Tarihi";
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 5, rowIndex: 0))
                      .value = "Açıklama";
                  for (int i = 0; i < listSeviyeBildirim.length; i++) {
                    final sb = listSeviyeBildirim[i];
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 0, rowIndex: i + 1))
                        .value = sb.ad;
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 1, rowIndex: i + 1))
                        .value = sb.ekfno;
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 2, rowIndex: i + 1))
                        .value = dateFormater(sb.dogum_tarih, "dd/MM/yyyy");
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 3, rowIndex: i + 1))
                        .value = sb.seviye;
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 4, rowIndex: i + 1))
                        .value = dateFormater(sb.tarih, "dd/MM/yyyy");
                    sheet
                        .cell(CellIndex.indexByColumnRow(
                            columnIndex: 5, rowIndex: i + 1))
                        .value = sb.aciklama;
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
        ]);
      },
    );
  }
}
