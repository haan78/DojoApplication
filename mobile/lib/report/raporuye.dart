import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:dojo_mobile/service.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class RaporUye extends StatelessWidget {
  final Api api;

  const RaporUye({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
            onPressed: () async {
              try {
                final result = await rapor_geneluyeraporu(api);
                final excel = Excel.createExcel();
                final sheet = excel.sheets[excel.getDefaultSheet()!]!;
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
                    .value = "Üye ID";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
                    .value = "Ad";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
                    .value = "Email";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0))
                    .value = "Cinsiyet";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0))
                    .value = "Doğum Tarihi";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0))
                    .value = "EkfNo";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0))
                    .value = "Durum";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0))
                    .value = "Tahakkuk";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: 0))
                    .value = "Seviye";
                sheet
                    .cell(
                        CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: 0))
                    .value = "Sınav Tarihi";
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 10, rowIndex: 0))
                    .value = "Borç Tutarı";
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 11, rowIndex: 0))
                    .value = "Borc Sayısı";
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 12, rowIndex: 0))
                    .value = "Devam Sayısı";
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 13, rowIndex: 0))
                    .value = "İlk Keiko";
                sheet
                    .cell(CellIndex.indexByColumnRow(
                        columnIndex: 14, rowIndex: 0))
                    .value = "Son Seiko";
                for (int i = 0; i < result.length; i++) {
                  final r = result[i];
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 0, rowIndex: i + 1))
                      .value = r.uye_id;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 1, rowIndex: i + 1))
                      .value = r.ad;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 2, rowIndex: i + 1))
                      .value = r.email;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 3, rowIndex: i + 1))
                      .value = r.cinsiyet;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 4, rowIndex: i + 1))
                      .value = dateFormater(r.dogum_tarih, "dd/MM/yyyy");
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 5, rowIndex: i + 1))
                      .value = r.ekfno;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 6, rowIndex: i + 1))
                      .value = r.durum;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 7, rowIndex: i + 1))
                      .value = r.tahakkuk;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 8, rowIndex: i + 1))
                      .value = r.seviye;
                  sheet
                          .cell(CellIndex.indexByColumnRow(
                              columnIndex: 9, rowIndex: i + 1))
                          .value =
                      r.sinav_tarih != null
                          ? dateFormater(r.sinav_tarih!, "dd/MM/yyyy")
                          : null;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 10, rowIndex: i + 1))
                      .value = r.borc_tutar;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 11, rowIndex: i + 1))
                      .value = r.borc_sayi;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 12, rowIndex: i + 1))
                      .value = r.devam_sayi;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 13, rowIndex: i + 1))
                      .value = r.ilk;
                  sheet
                      .cell(CellIndex.indexByColumnRow(
                          columnIndex: 14, rowIndex: i + 1))
                      .value = r.son;
                }
                if (context.mounted) openExcel(context, "gelirgider", excel);
              } catch (err) {
                if (context.mounted) {
                  errorAlert(context, err.toString());
                }
              }
            },
            child: const Text("Excel Dökümanı .xlsx")));
  }
}
