import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/service.dart';
import 'package:flutter/material.dart';
import 'package:d_chart/d_chart.dart';

import '../api.dart';
import '../store.dart';

class GrafiklerPage extends StatefulWidget {
  final Store store;
  const GrafiklerPage({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _GrafiklerPage();
  }
}

class _GrafiklerPage extends State<GrafiklerPage> with TickerProviderStateMixin {
  late TabController tbc;
  late Api api;
  int page = 1;
  int pageY = 1;

  int limit = 6;
  int yoklamaId = 0;
  late List<DropdownMenuItem> yoklamaItems;

  List<GelirGiderAylik> listGelirGider = [];
  List<YoklamaAylik> listYoklama = [];
  List<SeviyeRap> listSeviye = [];
  List<MultiSelectOption> listSeviyeOptions = [
    MultiSelectOption("7 DAN", false),
    MultiSelectOption("6 DAN", true),
    MultiSelectOption("5 DAN", true),
    MultiSelectOption("4 DAN", true),
    MultiSelectOption("3 DAN", true),
    MultiSelectOption("2 DAN", true),
    MultiSelectOption("1 DAN", true),
    MultiSelectOption("1 KYU", true),
    MultiSelectOption("2 KYU", true),
    MultiSelectOption("3 KYU", true),
    MultiSelectOption("Altı", false)
  ];
  @override
  void initState() {
    super.initState();

    if (widget.store.sabitler.yoklamalar.isNotEmpty) {
      yoklamaId = widget.store.sabitler.yoklamalar[0].yoklama_id;
    }

    tbc = TabController(length: 3, vsync: this, initialIndex: 0);
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    yoklamaItems = yoklamaMenuItems(widget.store.sabitler.yoklamalar, bosSecenek: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: appDrawer(context),
        appBar: AppBar(title: appTitle(text: "Grafikler")),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            TabBar(
              onTap: (value) {},
              //labelStyle: const TextStyle(fontSize: 12),
              labelColor: Colors.black,
              controller: tbc,
              tabs: const [
                Tab(text: "Mali Durum"),
                Tab(text: "Katılım"),
                Tab(
                  text: "Seviyeler",
                )
              ],
            ),
            Expanded(
                child: TabBarView(controller: tbc, children: [
              FBuilder<void>(
                  future: rapor_gelirgider(api, listGelirGider),
                  builder: (val) {
                    final int pageCount = (listGelirGider.length / limit).ceil();
                    final pList = <DropdownMenuItem<int>>[];
                    for (int p = 1; p <= pageCount; p++) {
                      pList.add(DropdownMenuItem(value: p, child: Text("Sayfa $p")));
                    }
                    List<Map<String, dynamic>> dGelir = [];
                    List<Map<String, dynamic>> dGider = [];
                    List<Map<String, dynamic>> dAidat = [];

                    int bas = listGelirGider.length - (page * limit) > 0 ? listGelirGider.length - (page * limit) : 0;
                    int bit = listGelirGider.length > bas + limit ? bas + limit : listGelirGider.length;

                    for (int i = bit - 1; i >= bas; i--) {
                      final row = listGelirGider[i];
                      final label = "${row.yil.toString().substring(2, 4)}/${row.ay.toString().padLeft(2, '0')}";
                      dGelir.add({'domain': label, 'measure': row.gelir});
                      dAidat.add({'domain': label, 'measure': row.aidat});
                      dGider.add({'domain': label, 'measure': row.gider * -1});
                    }
                    return Column(children: [
                      Row(children: [
                        DropdownButton(
                            items: pList,
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  page = value;
                                });
                              }
                            },
                            value: page),
                        const Spacer(),
                        Text("Gelir", style: TextStyle(color: Colors.green.shade800)),
                        const SizedBox(width: 10),
                        Text("Gider", style: TextStyle(color: Colors.red.shade800)),
                        const SizedBox(width: 10),
                        Text("Aidat", style: TextStyle(color: Colors.blue.shade800)),
                      ]),
                      Expanded(
                          child: DChartBar(
                        data: [
                          {'id': 'Gelir', 'data': dGelir},
                          {'id': 'Aidat', 'data': dAidat},
                          {'id': 'Gider', 'data': dGider}
                        ],
                        domainLabelPaddingToAxisLine: 16,
                        axisLineTick: 2,
                        axisLinePointTick: 1,
                        axisLinePointWidth: 5,
                        axisLineColor: Colors.black,
                        measureLabelPaddingToAxisLine: 16,
                        barColor: (barData, index, id) {
                          if (id == "Gelir") {
                            return Colors.green.shade800;
                          } else if (id == "Gider") {
                            return Colors.red.shade800;
                          } else {
                            return Colors.blue.shade800;
                          }
                        },
                        showBarValue: true,
                        showMeasureLine: false,
                        barValueFontSize: 10,
                        barValueColor: Colors.white,
                        verticalDirection: false,
                        barValuePosition: BarValuePosition.inside,
                        barValueAnchor: BarValueAnchor.end,
                        barValue: (barData, index) {
                          final text = "${barData['measure'] ?? "0"} TL";
                          return text;
                        },
                      ))
                    ]);
                  }),
              FBuilder<void>(
                future: rapor_aylikyoklama(api, yoklamaId, listYoklama),
                builder: (data) {
                  final int pageCount = (listYoklama.length / limit).ceil();
                  final pList = <DropdownMenuItem<int>>[];
                  for (int p = 1; p <= pageCount; p++) {
                    pList.add(DropdownMenuItem(value: p, child: Text("Sayfa $p")));
                  }
                  List<Map<String, dynamic>> dOrt = [];
                  List<Map<String, dynamic>> dMax = [];
                  List<Map<String, dynamic>> dMin = [];

                  int bas = listYoklama.length - (pageY * limit) > 0 ? listYoklama.length - (pageY * limit) : 0;
                  int bit = listYoklama.length > bas + limit ? bas + limit : listYoklama.length;
                  for (int i = bit - 1; i >= bas; i--) {
                    final row = listYoklama[i];
                    final label = "${row.yil.toString().substring(2, 4)}/${row.ay.toString().padLeft(2, '0')}\n${row.keiko} Keiko";
                    dOrt.add({'domain': label, 'measure': row.ortalama});
                    dMax.add({'domain': label, 'measure': row.ust});
                    dMin.add({'domain': label, 'measure': row.alt});
                  }

                  return Column(children: [
                    Row(children: [
                      DropdownButton(
                          items: pList,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                pageY = value;
                              });
                            }
                          },
                          value: pageY),
                      const SizedBox(width: 10),
                      DropdownButton(
                          items: yoklamaItems,
                          value: yoklamaId,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                yoklamaId = value;
                              });
                            }
                          }),
                      const Spacer(),
                      Text("Max", style: TextStyle(color: Colors.green.shade800)),
                      const SizedBox(width: 10),
                      Text("Min", style: TextStyle(color: Colors.red.shade800)),
                      const SizedBox(width: 10),
                      Text("Ort", style: TextStyle(color: Colors.blue.shade800))
                    ]),
                    Expanded(
                        child: DChartBar(
                            data: [
                          {'id': 'Max', 'data': dMax},
                          {'id': 'Ort', 'data': dOrt},
                          {'id': 'Min', 'data': dMin}
                        ],
                            barColor: (barData, index, id) {
                              if (id == "Max") {
                                return Colors.green.shade800;
                              } else if (id == "Min") {
                                return Colors.red.shade800;
                              } else {
                                return Colors.blue.shade800;
                              }
                            },
                            showBarValue: true,
                            showMeasureLine: false,
                            barValueFontSize: 10,
                            barValueColor: Colors.white,
                            verticalDirection: false,
                            barValuePosition: BarValuePosition.inside,
                            barValueAnchor: BarValueAnchor.end,
                            barValue: (barData, index) {
                              final text = "${barData['measure'] ?? "0"}";
                              return text;
                            }))
                  ]);
                },
              ),
              FBuilder<void>(
                  future: rapor_seviye(api, listSeviye),
                  builder: (data) {
                    final int pageCount = (listSeviye.length / limit).ceil();
                    final pList = <DropdownMenuItem<int>>[];
                    for (int p = 1; p <= pageCount; p++) {
                      pList.add(DropdownMenuItem(value: p, child: Text("Sayfa $p")));
                    }
                    List<Map<String, dynamic>> dGenel = [];
                    List<Map<String, dynamic>> dKadin = [];
                    List<Map<String, dynamic>> dErkek = [];

                    for (int i = 0; i < listSeviye.length; i++) {
                      final row = listSeviye[i];
                      if (listSeviyeOptions.any((element) => (element.name == row.seviye) && (element.checked == true))) {
                        dGenel.add({'domain': row.seviye, 'measure': row.genelSayi, 'ort': row.genelOrt});
                        dKadin.add({'domain': row.seviye, 'measure': row.kadinSayi, 'ort': row.kadinOrt});
                        dErkek.add({'domain': row.seviye, 'measure': row.erkekSayi, 'ort': row.erkekOrt});
                      }
                    }
                    return Column(children: [
                      Row(children: [
                        ElevatedButton(
                            onPressed: () {
                              multiSelectDialog(context, list: listSeviyeOptions, onOk: (options) {
                                setState(() {
                                  listSeviyeOptions = options;
                                });
                              });
                            },
                            child: const Text("Seviyeler")),
                        const Spacer(),
                        Text("Genel", style: TextStyle(color: Colors.green.shade800)),
                        const SizedBox(width: 10),
                        Text("Kadın", style: TextStyle(color: Colors.red.shade800)),
                        const SizedBox(width: 10),
                        Text("Erkek", style: TextStyle(color: Colors.blue.shade800))
                      ]),
                      Expanded(
                          child: DChartBar(
                              data: [
                            {'id': 'Genel', 'data': dGenel},
                            {'id': 'Erkek', 'data': dErkek},
                            {'id': 'Kadin', 'data': dKadin}
                          ],
                              barColor: (barData, index, id) {
                                if (id == "Genel") {
                                  return Colors.green.shade800;
                                } else if (id == "Kadin") {
                                  return Colors.red.shade800;
                                } else {
                                  return Colors.blue.shade800;
                                }
                              },
                              showBarValue: true,
                              showMeasureLine: false,
                              barValueFontSize: 10,
                              barValueColor: Colors.white,
                              verticalDirection: false,
                              barValuePosition: BarValuePosition.inside,
                              barValueAnchor: BarValueAnchor.end,
                              barValue: (barData, index) {
                                final text = "${barData['measure']} / ${barData['ort']}";
                                return text;
                              }))
                    ]);
                  }),
            ]))
          ]),
        ));
  }
}
