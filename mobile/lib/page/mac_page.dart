import 'dart:async';

import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/page/widget/list_items.dart';
import 'package:dojo_mobile/service.dart';
import 'package:dojo_mobile/store.dart';
import 'package:flutter/material.dart';

import 'package:trotter/trotter.dart';

class MacCalismasi extends StatefulWidget {
  final Store store;

  const MacCalismasi({super.key, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _MacCalismasi();
  }
}

enum ScreenType { secim, hesap, takim }

const ipponSymbols = ["", " M ", " K ", " D ", " T ", " H ", " Ht "];

class IpponAndHansoku {
  int ippon1 = 0;
  int ippon2 = 0;
  int hansoku = 0;
}

class MacSonuc {
  IpponAndHansoku aka = IpponAndHansoku();
  IpponAndHansoku sihro = IpponAndHansoku();
}

class TakimSitesi {
  List<MacCalismasiKendocu> red = [];
  List<MacCalismasiKendocu> white = [];
  List<MacSonuc> sonuclar = [];
}

class _MacCalismasi extends State<MacCalismasi> {
  ScreenType ekran = ScreenType.secim;
  final List<MacCalismasiKendocu> kendocular = [];
  final List<DateTime> tarihler = [];
  final _formKey = GlobalKey<FormState>();
  int yoklamaId = 0;
  int seciliksayi = 0;
  DateTime? tarih;
  List<TakimSitesi> takimlisteleri = [];
  TakimSitesi seciliTakimListesi = TakimSitesi();
  bool reload = true;
  final minTar = DateTime.now().subtract(const Duration(days: 90));
  final maxTar = DateTime.now();
  late Api api;
  late ScrollController _scrollController;
  double _offset = 0;
  int gecensure = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);

    if (widget.store.sabitler.yoklamalar.isNotEmpty) {
      yoklamaId = widget.store.sabitler.yoklamalar[0].yoklama_id;
    }
  }

  Future<void> initData() async {
    if (reload) {
      ekran = ScreenType.secim;
      if (tarih == null) {
        await yoklama10listesi(api, yoklamaId, tarihler);
        tarih = tarihler[0];
      }

      seciliksayi = 0;
      if (tarihler.isNotEmpty) {
        await maccalismasi_listesi(api, yoklamaId, tarih!, kendocular);
        for (int i = 0; i < kendocular.length; i++) {
          if (kendocular[i].seviye == "6 KYU" ||
              kendocular[i].seviye == "7 KYU" ||
              kendocular[i].seviye == "5 KYU" ||
              kendocular[i].seviye == "5 DAN" ||
              kendocular[i].seviye == "6 DAN") {
            kendocular[i].secildi = false;
          } else {
            seciliksayi += 1;
          }
        }
      } else {
        kendocular.clear();
      }
    }
    reload = false;
  }

  bool hesapicinuygun() {
    return seciliksayi % 2 == 0 && seciliksayi > 2;
  }

  Widget ekranSecim(BuildContext context) {
    return Column(children: [
      Form(
          key: _formKey,
          child: Row(
            children: [
              yoklamaSelect(widget.store.sabitler.yoklamalar, yoklamaId, onChange: (value) {
                yoklamaId = value ?? 0;
              }),
              const SizedBox(width: 10),
              DropdownButton<DateTime>(
                value: tarih,
                items: tarihler.map<DropdownMenuItem<DateTime>>((e) => DropdownMenuItem<DateTime>(value: e, child: Text(dateFormater(e, "dd.MM.yyyy")))).toList(),
                onChanged: (DateTime? value) {
                  if (value != null) {
                    setState(() {
                      tarih = value;
                      reload = true;
                      _offset = 0;
                    });
                  }
                },
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: hesapicinuygun()
                      ? () {
                          takimlisteleri = hesapla(kendocular);
                          setState(() {
                            ekran = ScreenType.hesap;
                          });
                        }
                      : null,
                  child: Text("$seciliksayi Takım Olasılıkları"))
            ],
          )),
      Expanded(
          child: ListView.builder(
              controller: _scrollController,
              itemCount: kendocular.length,
              itemBuilder: (context, index) {
                return macCalismasiKendocuItem(widget.store, kendocular[index], (val) {
                  setState(() {
                    kendocular[index].secildi = val;
                    if (val) {
                      seciliksayi += 1;
                    } else {
                      seciliksayi -= 1;
                    }
                    _offset = _scrollController.offset;
                  });
                });
              }))
    ]);
  }

  List<TakimSitesi> hesapla(List<MacCalismasiKendocu> orjinal, {int hassiyet = 10}) {
    int degerleme(MacCalismasiKendocu kendocu) {
      if (kendocu.seviye == "6 DAN") {
        return 60;
      } else if (kendocu.seviye == "5 DAN") {
        return 50;
      } else if (kendocu.seviye == "4 DAN") {
        return 40;
      } else if (kendocu.seviye == "3 DAN") {
        return 30;
      } else if (kendocu.seviye == "2 DAN") {
        return 20;
      } else if (kendocu.seviye == "1 DAN") {
        return 10;
      } else if (kendocu.seviye == "1 KYU") {
        return 9;
      } else if (kendocu.seviye == "2 KYU") {
        return 8;
      } else if (kendocu.seviye == "3 KYU") {
        return 6;
      } else if (kendocu.seviye == "4 KYU") {
        return 4;
      } else if (kendocu.seviye == "5 KYU") {
        return 2;
      } else if (kendocu.seviye == "6 KYU") {
        return 1;
      } else if (kendocu.seviye == "7 KYU") {
        return 1;
      }
      return 0;
    }

    int sirala(MacCalismasiKendocu a, MacCalismasiKendocu b) {
      final da = degerleme(a);
      final db = degerleme(b);
      if (da > db) {
        return -1;
      } else if (db > da) {
        return 1;
      } else {
        return a.tarih.compareTo(b.tarih);
      }
    }

    int topdeger = 0;
    List<MacCalismasiKendocu> l = [];
    for (int i = 0; i < orjinal.length; i++) {
      if (orjinal[i].secildi) {
        l.add(orjinal[i]);
        topdeger += degerleme(orjinal[i]);
      }
    }
    final takimsayi = l.length ~/ 2;
    final degalt = (topdeger ~/ 2) - (hassiyet ~/ 2);
    final degust = (topdeger ~/ 2) + (hassiyet ~/ 2);

    final alternatifler1 = Combinations(takimsayi, l);

    List<TakimSitesi> alternatifler2 = [];
    for (int i = 0; i < alternatifler1.length.toInt(); i++) {
      int toplam = 0;
      TakimSitesi tl = TakimSitesi();
      for (int j = 0; j < alternatifler1[i].length; j++) {
        toplam += degerleme(alternatifler1[i][j]);
        tl.sonuclar.add(MacSonuc());
        tl.red.add(alternatifler1[i][j]);
      }
      if (toplam >= degalt && toplam <= degust) {
        //if (toplam >= 0 && toplam <= 10000) {
        for (int j = 0; j < l.length; j++) {
          if (tl.red.where((element) => element.uye_id == l[j].uye_id).isEmpty) {
            tl.white.add(l[j]);
          }
        }
        tl.white.sort(sirala);
        tl.red.sort(sirala);
        alternatifler2.add(tl);
      }
    }
    return alternatifler2;
  }

  Widget ekranHesap(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    ekran = ScreenType.secim;
                  });
                },
                child: const Text("Oyuncu Seçim Ekranı"))),
        Expanded(
            child: ListView.builder(
                itemCount: takimlisteleri.length,
                itemBuilder: (context, index) {
                  final tl = takimlisteleri[index];
                  String tRed = "KIRMIZI";
                  String tWhite = "BEYAZ";
                  for (final r in tl.red) {
                    tRed += "\n${r.seviye} ${r.ad}";
                  }
                  for (final w in tl.white) {
                    tWhite += "\n${w.ad} ${w.seviye}";
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Container(
                          color: Colors.red,
                          child: Text(
                            tRed,
                            style: const TextStyle(color: Colors.white),
                          )),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            seciliTakimListesi = takimlisteleri[index];
                            ekran = ScreenType.takim;
                          });
                        },
                        child: Text("${index + 1} SEÇ"),
                      ),
                      Container(
                          color: Colors.white,
                          child: Text(
                            tWhite,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.black),
                          ))
                    ]),
                  );
                }))
      ],
    );
  }

  void anaformuyenile() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
  }

  void sayitablosu(int index, {bool beyaz = false}) {
    const sayilar = [
      DropdownMenuItem(value: 0, child: Text("SEÇ")),
      DropdownMenuItem(
        value: 1,
        child: Text("M"),
      ),
      DropdownMenuItem(
        value: 2,
        child: Text("K"),
      ),
      DropdownMenuItem(
        value: 3,
        child: Text("D"),
      ),
      DropdownMenuItem(
        value: 4,
        child: Text("T"),
      ),
      DropdownMenuItem(
        value: 5,
        child: Text("H"),
      ),
      DropdownMenuItem(
        value: 6,
        child: Text("Ht"),
      )
    ];
    String oyuncu = beyaz ? "${seciliTakimListesi.white[index].ad} (BEYAZ)" : "${seciliTakimListesi.red[index].ad} (KIRMIZI)";
    IpponAndHansoku ih = beyaz ? seciliTakimListesi.sonuclar[index].sihro : seciliTakimListesi.sonuclar[index].aka;

    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  scrollable: true,
                  title: Text(oyuncu, style: const TextStyle(color: Colors.blue)),
                  content: Column(children: [
                    Row(children: [
                      const Text("1. Sayı"),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                          value: ih.ippon1,
                          items: sayilar,
                          onChanged: (value) {
                            setState(() {
                              if (beyaz) {
                                seciliTakimListesi.sonuclar[index].sihro.ippon1 = value ?? ih.ippon1;
                              } else {
                                seciliTakimListesi.sonuclar[index].aka.ippon1 = value ?? ih.ippon1;
                              }
                            });
                          })
                    ]),
                    Row(children: [
                      const Text("2. Sayı"),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                          value: ih.ippon2,
                          items: sayilar,
                          onChanged: (value) {
                            setState(() {
                              if (beyaz) {
                                seciliTakimListesi.sonuclar[index].sihro.ippon2 = value ?? ih.ippon2;
                              } else {
                                seciliTakimListesi.sonuclar[index].aka.ippon2 = value ?? ih.ippon2;
                              }
                            });
                          })
                    ]),
                    Row(children: [
                      const Text("Hansoku"),
                      const SizedBox(width: 10),
                      DropdownButton<int>(
                          value: ih.hansoku,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text("SEÇ")),
                            DropdownMenuItem(
                              value: 1,
                              child: Text("1. Hansoku"),
                            ),
                            DropdownMenuItem(value: 2, child: Text("2. Hansoku")),
                            DropdownMenuItem(value: 3, child: Text("3. Hansoku")),
                            DropdownMenuItem(value: 4, child: Text("4. Hansoku"))
                          ],
                          onChanged: (value) {
                            setState(() {
                              if (beyaz) {
                                seciliTakimListesi.sonuclar[index].sihro.hansoku = value ?? ih.hansoku;
                              } else {
                                seciliTakimListesi.sonuclar[index].aka.hansoku = value ?? ih.hansoku;
                              }
                            });
                          })
                    ])
                  ]),
                  actions: [
                    TextButton(
                      child: const Text('Tamam'),
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          anaformuyenile();
                        }
                      },
                    )
                  ],
                ))));
  }

  String sembolgoster(IpponAndHansoku ih) {
    String str = ipponSymbols[ih.ippon1] + ipponSymbols[ih.ippon2];
    if (ih.ippon1 > 0 || ih.ippon2 > 0) {
      str += "\n";
    }
    if (ih.hansoku == 1) {
      str += " ■ ";
    } else if (ih.hansoku == 2) {
      str += " ■ ■ ";
    } else if (ih.hansoku == 3) {
      str += " ■ ■ \n ■";
    } else if (ih.hansoku == 4) {
      str += " ■ ■ \n ■ ■ ";
    }

    return str;
  }

  Widget ekranTakim(BuildContext context) {
    List<TableRow> tablosatirlari() {
      List<TableRow> l = [];
      const style = TextStyle(fontSize: 24);

      l.add(TableRow(children: [
        TableCell(
            child: Container(
                color: Colors.red,
                child: const Text(
                  "",
                  style: style,
                ))),
        const TableCell(child: SizedBox(width: 40)),
        TableCell(
            child: Container(
                color: Colors.white,
                child: const Text(
                  "",
                  style: style,
                )))
      ]));

      for (int i = 0; i < seciliTakimListesi.red.length; i++) {
        l.add(TableRow(children: [
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () {
                      sayitablosu(i, beyaz: false);
                    },
                    child: Text(seciliTakimListesi.red[i].ad, style: const TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.left),
                  ))),
          TableCell(
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(sembolgoster(seciliTakimListesi.sonuclar[i].aka), style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      sembolgoster(seciliTakimListesi.sonuclar[i].sihro),
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                    )
                  ],
                )),
          ),
          TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: TextButton(
                    onPressed: () {
                      sayitablosu(i, beyaz: true);
                    },
                    child: Text(seciliTakimListesi.white[i].ad, style: const TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.right),
                  )))
        ]));
      }
      return l;
    }

    return Column(
      children: [
        Row(children: [
          ElevatedButton(
              onPressed: () {
                setState(() {
                  ekran = ScreenType.secim;
                });
              },
              child: const Text("Oyuncu Seçim Ekranı")),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  ekran = ScreenType.hesap;
                });
              },
              child: const Text("Takım Seçim Ekranı"))
        ]),
        Expanded(child: Table(border: TableBorder.all(color: Colors.white), children: tablosatirlari())),
        Row(children: [
          ElevatedButton(
              onPressed: () {
                if (timer == null) {
                  timer = Timer.periodic(const Duration(seconds: 1), (timer) {
                    if (timer.isActive) {
                      setState(() {
                        gecensure += 1;
                      });
                    }
                  });
                } else {
                  timer = null;
                }
              },
              child: Text("${(gecensure ~/ 60).toString().padLeft(2, "0")}:${(gecensure % 60).toString().padLeft(2, "0")}")),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: (() {
                gecensure = 0;
                if (timer != null) timer!.cancel();
              }),
              child: const Text("Reset"))
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController(keepScrollOffset: true, initialScrollOffset: _offset);
    return Scaffold(
      drawer: appDrawer(context),
      appBar: AppBar(title: appTitle(text: "Maç Çalışması"), actions: [
        IconButton(
            onPressed: () async {
              setState(() {
                reload = true;
                _offset = 0;
              });
            },
            icon: const Icon(Icons.refresh))
      ]),
      body: FBuilder<void>(
          future: initData(),
          builder: ((data) {
            Widget module;
            if (ekran == ScreenType.secim) {
              module = ekranSecim(context);
            } else if (ekran == ScreenType.hesap) {
              module = ekranHesap(context);
            } else {
              module = ekranTakim(context);
            }
            return Padding(
              padding: appPading,
              child: module,
            );
          })),
    );
  }
}
