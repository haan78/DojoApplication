import 'package:better_open_file/better_open_file.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';

import '../api.dart';
import '../store.dart';

import 'dart:io';

import 'package:pdf/widgets.dart' as pw;

class KyuSinaviPage extends StatefulWidget {
  final Store store;
  const KyuSinaviPage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _KyuSinaviPage();
  }
}

class _KyuSinaviPage extends State<KyuSinaviPage> {
  late Api api;
  final List<KyuOneri> list = [];
  late LoadingDialog loading;
  bool reload = false;
  DateTime tarih = DateTime.now();
  final tbas = dateTimeSum(DateTime.now(), const Duration(days: 17), subtract: false);
  final tbit = dateTimeSum(DateTime.now(), const Duration(days: 17), subtract: true);
  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    loading = LoadingDialog(context);
    reload = true;
    Future.delayed(
      const Duration(seconds: 2),
      () {
        loadData();
      },
    );
  }

  Future<void> loadData() async {
    loading.push();
    await kyuoneri(api, list);
    loading.pop();
    setState(() {
      reload = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(title: appTitle(text: "Kyu Sınavı"), actions: [
        IconButton(
            onPressed: () async {
              loadData();
            },
            icon: const Icon(Icons.refresh))
      ]),
      body: reload
          ? const Text("Loading...")
          : Padding(
              padding: AppPading,
              child: Column(children: [
                Expanded(
                    child: ListView.builder(
                        itemBuilder: (context, index) {
                          Color c = list[index].sayi >= 12 ? Colors.green.shade900 : Colors.red.shade400;
                          return Padding(
                              padding: AppPading,
                              child: ListTile(
                                title: Text(
                                  "${list[index].sinav} ${list[index].ad} ",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: c),
                                ),
                                subtitle: Text(
                                  list[index].sayi >= 12 ? "Son üç ayda keiko sayısı ${list[index].sayi}" : "Son üç ayda ${12 - list[index].sayi} keiko eksiği var",
                                  style: TextStyle(color: c),
                                ),
                                tileColor: tileColorByIndex(index),
                                trailing: Switch(
                                  value: list[index].kabuledildi,
                                  activeColor: colorGood,
                                  inactiveTrackColor: colorWarn,
                                  onChanged: (bool value) {
                                    setState(() {
                                      list[index].kabuledildi = value;
                                    });
                                  },
                                ),
                              ));
                        },
                        itemCount: list.length)),
                Row(children: [
                  ElevatedButton(
                      onPressed: () async {
                        final dt = await showDatePicker(context: context, initialDate: tarih, firstDate: tbas, lastDate: tbit);
                        if (dt != null) {
                          setState(() {
                            tarih = dt;
                          });
                        }
                      },
                      child: Text(dateFormater(tarih, 'dd.MM.yyyy'))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            final pdf = pw.Document();
                            //final font = await PdfGoogleFonts.
                            final font = pw.Font.ttf(await rootBundle.load("fonts/turkish_times_new_roman.ttf"));

                            pdf.addPage(
                                pw.Page(build: (context) => pw.Theme(data: pw.ThemeData(defaultTextStyle: pw.TextStyle(font: font, fontSize: 12)), child: uret())));

                            Directory tempDir = await getTemporaryDirectory();

                            final file = File("${tempDir.path}/kyu${dateFormater(DateTime.now(), "yyyyMMddHHmmss")}.pdf");
                            await file.writeAsBytes(await pdf.save());
                            await OpenFile.open(file.path);
                          },
                          child: const Text("PDF Ouştur")))
                ])
              ])),
    );
  }

  pw.Column uret() {
    List<pw.Widget> l = [];

    l.add(pw.Text("${widget.store.AppName} Kyu Sınvı Listesi ${dateFormater(tarih, "dd.MM.yyyy")}", style: const pw.TextStyle(fontSize: 20)));
    int tind = 0;
    if (list.isNotEmpty) {
      String sinav = "";
      int num1 = 0;
      int num2 = 0;
      for (int i = 0; i < list.length; i++) {
        if (list[i].kabuledildi) {
          if (sinav != list[i].sinav) {
            sinav = list[i].sinav;
            num1 = int.parse(sinav.split(" ")[0].trim()) * 100;
            num2 = 0;
            l.add(pw.SizedBox(height: 20));
            l.add(pw.Text(sinav, style: pw.TextStyle(fontSize: 14, fontBold: pw.Font.timesBold())));
            l.add(pw.Table(border: pw.TableBorder.all(style: const pw.BorderStyle()), tableWidth: pw.TableWidth.max, children: []));
            tind += 3;
          }
          num2 += 1;
          (l[tind] as pw.Table).children.add(pw.TableRow(verticalAlignment: pw.TableCellVerticalAlignment.middle, children: [
                pw.SizedBox(
                  height: 22,
                  child: pw.Container(child: pw.Text(" ${num1 + num2} ${list[i].ad}"), alignment: pw.Alignment.centerLeft),
                )
              ]));
        }
      }
    }

    return pw.Column(children: l);
  }
}
