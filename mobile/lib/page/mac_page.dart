import 'dart:async';

import 'package:dojo_mobile/api.dart';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/radio_group.dart';
import 'package:dojo_mobile/page/widget/saat.dart';
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

const ipponSymbols = [" M ", " K ", " D ", " T ", " H ", " Ht "];

class IpponAndHansoku {
  int ippon1 = -1;
  int ippon2 = -1;
  int hansoku = 0;
}

class MacSonuc {
  IpponAndHansoku aka = IpponAndHansoku();
  IpponAndHansoku shiro = IpponAndHansoku();
}

class TakimSitesi {
  List<MacCalismasiKendocu> red = [];
  List<MacCalismasiKendocu> white = [];
  List<MacSonuc> sonuclar = [];
}

class _MacCalismasi extends State<MacCalismasi> {
  late LoadingDialog loadingdlg;
  ScreenType ekran = ScreenType.secim;
  final List<MacCalismasiKendocu> kendocular = [];
  final List<MacCalismasiIcinYoklama> tarihler = [];
  final _formKey = GlobalKey<FormState>();
  int yoklamaId = 0;
  int seciliksayi = 0;
  MacCalismasiIcinYoklama? yoklama;
  List<TakimSitesi> takimlisteleri = [];
  TakimSitesi seciliTakimListesi = TakimSitesi();
  bool reload = true;
  final minTar = DateTime.now().subtract(const Duration(days: 90));
  final maxTar = DateTime.now();
  late Api api;
  late ScrollController _scrollController;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    loadingdlg = LoadingDialog(context);
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);

    if (widget.store.sabitler.yoklamalar.isNotEmpty) {
      yoklamaId = widget.store.sabitler.yoklamalar[0].yoklama_id;
    }
  }

  Future<void> initData() async {
    if (reload) {
      ekran = ScreenType.secim;
      if (yoklama == null) {
        await yoklama10listesi(api, yoklamaId, tarihler);
        if (tarihler.isNotEmpty) {
          yoklama = tarihler[0];
        }
      }

      seciliksayi = 0;
      if (yoklama != null) {
        await maccalismasi_listesi(api, yoklamaId, yoklama!.tarih, kendocular);
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
              DropdownButton<MacCalismasiIcinYoklama>(
                value: yoklama,
                items: tarihler
                    .map<DropdownMenuItem<MacCalismasiIcinYoklama>>(
                        (e) => DropdownMenuItem<MacCalismasiIcinYoklama>(value: e, child: Text(dateFormater(e.tarih, "dd.MM.yyyy") + (e.macyaipmis ? " *" : ""))))
                    .toList(),
                onChanged: (MacCalismasiIcinYoklama? value) {
                  if (value != null) {
                    setState(() {
                      yoklama = value;
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
        return 1;
      } else if (db > da) {
        return -1;
      } else {
        return -1 * a.tarih.compareTo(b.tarih);
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
  }

  void sayitablosu(int index, {bool beyaz = false}) {
    const sayilar = [Text("M"), Text("K"), Text("D"), Text("T"), Text("H"), Text("Ht")];
    String oyuncu = beyaz ? "${seciliTakimListesi.white[index].ad} (BEYAZ)" : "${seciliTakimListesi.red[index].ad} (KIRMIZI)";
    IpponAndHansoku ih = beyaz ? seciliTakimListesi.sonuclar[index].shiro : seciliTakimListesi.sonuclar[index].aka;

    showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
            builder: ((context, setState) => AlertDialog(
                  scrollable: true,
                  title: Text(oyuncu, style: const TextStyle(color: Colors.blue)),
                  content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("1. Ippon"),
                    RadioGroup(
                        selectedIndex: ih.ippon1,
                        onSelect: (v) {
                          if (beyaz) {
                            seciliTakimListesi.sonuclar[index].shiro.ippon1 = v;
                          } else {
                            seciliTakimListesi.sonuclar[index].aka.ippon1 = v;
                          }
                        },
                        children: sayilar),
                    const SizedBox(height: 10),
                    const Text("2. Ippon"),
                    RadioGroup(
                        selectedIndex: ih.ippon2,
                        onSelect: (v) {
                          if (beyaz) {
                            seciliTakimListesi.sonuclar[index].shiro.ippon2 = v;
                          } else {
                            seciliTakimListesi.sonuclar[index].aka.ippon2 = v;
                          }
                        },
                        children: sayilar),
                    const SizedBox(height: 10),
                    const Text("Hansoku"),
                    RadioGroup(
                        selectedIndex: ih.hansoku - 1,
                        onSelect: (v) {
                          if (beyaz) {
                            seciliTakimListesi.sonuclar[index].shiro.hansoku = v + 1;
                          } else {
                            seciliTakimListesi.sonuclar[index].aka.hansoku = v + 1;
                          }
                        },
                        children: const [Text("1"), Text("2"), Text("3"), Text("4")])
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
    String str = ih.ippon1 > -1 ? ipponSymbols[ih.ippon1] : "";
    str += ih.ippon2 > -1 ? ipponSymbols[ih.ippon2] : "";
    if (ih.ippon1 > 0 || ih.ippon2 > 0) {
      str += "\n";
    }
    if (ih.hansoku == 1) {
      str += " ▲ ";
    } else if (ih.hansoku == 2) {
      str += " ▲ ▲ ";
    } else if (ih.hansoku == 3) {
      str += " ▲ ▲ \n ▲ ";
    } else if (ih.hansoku == 4) {
      str += " ▲ ▲ \n ▲ ▲ ";
    }

    return str;
  }

  String sayistr(IpponAndHansoku ih) {
    String str = "";
    if (ih.ippon1 > -1) {
      str += ih.ippon1.toString();
    }
    if (ih.ippon2 > -1) {
      str += ih.ippon2.toString();
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
                      sembolgoster(seciliTakimListesi.sonuclar[i].shiro),
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
              child: const Text("Başa Dön")),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  ekran = ScreenType.hesap;
                });
              },
              child: const Text("Takım Seç")),
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () async {
                loadingdlg.push();
                List<MacCalismasiKayit> mckl = [];
                for (int i = 0; i < seciliTakimListesi.sonuclar.length; i++) {
                  final mck = MacCalismasiKayit();
                  mck.yoklama_id = yoklamaId;
                  mck.aka = seciliTakimListesi.red[i].uye_id;
                  mck.shiro = seciliTakimListesi.white[i].uye_id;
                  mck.tarih = yoklama!.tarih;
                  mck.tur = 'TAKIM';
                  mck.aka_hansoku = seciliTakimListesi.sonuclar[i].aka.hansoku;
                  mck.shiro_hansoku = seciliTakimListesi.sonuclar[i].shiro.hansoku;
                  mck.aka_ippon = sayistr(seciliTakimListesi.sonuclar[i].aka);
                  mck.shiro_ippon = sayistr(seciliTakimListesi.sonuclar[i].shiro);
                  mckl.add(mck);
                }
                await maccalismasi_kayit(api, mckl);
                loadingdlg.pop();
              },
              child: const Text("Kaydet"))
        ]),
        Expanded(child: Table(border: TableBorder.all(color: Colors.white), children: tablosatirlari())),
        const Saat(),
        const SizedBox(height: 20)
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
