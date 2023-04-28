import 'package:better_open_file/better_open_file.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

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
  DateTime tarih = DateTime.now();
  final tbas =
      dateTimeSum(DateTime.now(), const Duration(days: 30), subtract: false);
  final tbit =
      dateTimeSum(DateTime.now(), const Duration(days: 30), subtract: true);
  bool reload = true;
  late ScrollController _scrollController;
  double _offset = 0;
  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    reload = true;
  }

  Future<void> bos() async {}

  @override
  Widget build(BuildContext context) {
    _scrollController =
        ScrollController(keepScrollOffset: true, initialScrollOffset: _offset);
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(title: appTitle(text: "Kyu Sınavı"), actions: [
        IconButton(
            onPressed: () async {
              setState(() {
                _offset = 0;
                reload = true;
              });
            },
            icon: const Icon(Icons.refresh))
      ]),
      body: FBuilder<void>(
          future: reload ? kyuoneri(api, list) : bos(),
          builder: (data) {
            reload = false;
            return Padding(
                padding: appPading,
                child: Column(children: [
                  Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            Color c = renkver(-1 * list[index].sayi, -18, -12);
                            return Padding(
                                padding: appPading,
                                child: ListTile(
                                  title: Text(
                                    "${list[index].sinav} ${list[index].ad} ",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: c),
                                  ),
                                  subtitle: Text(
                                    "Son üç ayda keiko sayısı ${list[index].sayi}",
                                    style: TextStyle(color: c),
                                  ),
                                  tileColor: tileColorByIndex(index),
                                  trailing: Switch(
                                    value: list[index].kabuledildi,
                                    activeColor: colorGood,
                                    inactiveTrackColor: colorWarn,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _offset = _scrollController.offset;
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
                          final dt = await showDatePicker(
                              context: context,
                              initialDate: tarih,
                              firstDate: tbas,
                              lastDate: tbit);
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
                              final font = pw.Font.ttf(await rootBundle
                                  .load("fonts/turkish_times_new_roman.ttf"));

                              pdf.addPage(pw.Page(
                                  build: (context) => pw.Theme(
                                      data: pw.ThemeData(
                                          defaultTextStyle: pw.TextStyle(
                                              font: font, fontSize: 12)),
                                      child: uret())));

                              Directory tempDir = await getTemporaryDirectory();

                              final file = File(
                                  "${tempDir.path}/kyu${dateFormater(DateTime.now(), "yyyyMMddHHmmss")}.pdf");
                              await file.writeAsBytes(await pdf.save());
                              await OpenFile.open(file.path);
                            },
                            child: const Text("PDF Ouştur")))
                  ])
                ]));
          }),
    );
  }

  pw.Column uret() {
    List<pw.Widget> l = [];

    l.add(pw.Text(
        "${widget.store.AppName} Kyu Sınvı Listesi ${dateFormater(tarih, "dd.MM.yyyy")}",
        style: const pw.TextStyle(fontSize: 20)));
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
            l.add(pw.Text(sinav,
                style:
                    pw.TextStyle(fontSize: 14, fontBold: pw.Font.timesBold())));
            l.add(pw.Table(
                border: pw.TableBorder.all(style: const pw.BorderStyle()),
                tableWidth: pw.TableWidth.max,
                children: []));
            tind += 3;
          }
          num2 += 1;
          (l[tind] as pw.Table).children.add(pw.TableRow(
                  verticalAlignment: pw.TableCellVerticalAlignment.middle,
                  children: [
                    pw.SizedBox(
                      height: 22,
                      child: pw.Container(
                          child: pw.Text(" ${num1 + num2} ${list[i].ad}"),
                          alignment: pw.Alignment.centerLeft),
                    )
                  ]));
        }
      }
    }

    return pw.Column(children: l);
  }
}
