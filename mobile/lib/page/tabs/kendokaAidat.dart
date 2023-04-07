import 'package:dojo_mobile/page/harcama.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api.dart';
import '../../service.dart';
import '../../store.dart';
import '../appwindow.dart';
import '../aidat.dart';
import '../odeme.dart';

class KendokaAidat extends StatefulWidget {
  final UyeBilgi bilgi;
  final Store store;
  final Sabitler sabitler;
  const KendokaAidat({super.key, required this.sabitler, required this.bilgi, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _KendokaAidat();
  }
}

class _KendokaAidat extends State<KendokaAidat> with TickerProviderStateMixin {
  late Api api;
  late TabController tbc;
  @override
  void initState() {
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    tbc = TabController(length: 3, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: TabBar(
            labelColor: Colors.black,
            controller: tbc,
            tabs: const [Tab(text: "Aidatlar"), Tab(text: "Diğer Ödemeler"), Tab(text: "Harcamalar")],
          ))
        ]),
        Expanded(
            //uyetahakkuklist(api, uye_id: widget.bilgi.uye_id)
            child: TabBarView(controller: tbc, children: [
          FBuilder<List<UyeTahakkuk>>(
              future: uyetahakkuklist(api, uye_id: widget.bilgi.uye_id),
              builder: (data) {
                return Column(children: [
                  Row(children: [
                    Expanded(
                        child: ElevatedButton(
                      child: const Text("İleri Tarihli Aidat Tahsilat"),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return Aidat(
                            context,
                            uyeTahakkuk: UyeTahakkuk(),
                            store: widget.store,
                            uyeAd: widget.bilgi.ad,
                            uyeId: widget.bilgi.uye_id,
                            tahakkukId: widget.bilgi.tahakkuk_id,
                          );
                        })).then((value) {
                          setState(() {});
                        });
                      },
                    ))
                  ]),
                  Expanded(
                      child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Text info1 = Text(data[index].tanim);
                      Text info2;
                      if (data[index].ay > 0 && data[index].muhasebe_id == 0) {
                        info2 = Text("${data[index].borc.toString()} TL ${trAy(data[index].ay)} / ${data[index].yil}", style: const TextStyle(color: colorBad));
                      } else if (data[index].ay > 0 && data[index].muhasebe_id > 0) {
                        info2 = Text("${data[index].odenen.toString()} TL ${trAy(data[index].ay)} / ${data[index].yil}", style: const TextStyle(color: colorGood));
                      } else if (data[index].ay == 0 && data[index].muhasebe_id == 0) {
                        info2 = Text("${data[index].borc.toString()} TL", style: const TextStyle(color: colorBad));
                      } else if (data[index].ay == 0 && data[index].muhasebe_id > 0) {
                        info2 = Text("${data[index].odenen.toString()} TL", style: const TextStyle(color: colorGood));
                      } else {
                        info2 = const Text("");
                      }
                      return Padding(
                          padding: const EdgeInsets.all(3),
                          child: ListTile(
                              visualDensity: const VisualDensity(vertical: 0),
                              title: info1,
                              subtitle: info2,
                              tileColor: tileColorByIndex(index),
                              leading: data[index].muhasebe_id > 0
                                  ? const Icon(
                                      Icons.thumb_up_alt,
                                      color: colorGood,
                                    )
                                  : const Icon(
                                      Icons.thumb_down_alt,
                                      color: colorBad,
                                    ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return Aidat(
                                      context,
                                      uyeTahakkuk: data[index],
                                      store: widget.store,
                                      uyeAd: widget.bilgi.ad,
                                      uyeId: widget.bilgi.uye_id,
                                      tahakkukId: widget.bilgi.tahakkuk_id,
                                    );
                                  })).then((value) {
                                    setState(() {});
                                  });
                                },
                              )));
                    },
                  ))
                ]);
              }),
          FBuilder<List<MuhasebeDiger>>(
            future: uyedigerodemelist(api, widget.bilgi.uye_id),
            builder: (data) {
              return Column(children: [
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                    child: const Text("Yeni Ödeme Al"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return Odeme(
                          context,
                          muhasebe: MuhasebeDiger(),
                          store: widget.store,
                          uyeAd: widget.bilgi.ad,
                          uyeId: widget.bilgi.uye_id,
                        );
                      })).then((value) {
                        setState(() {});
                      });
                    },
                  ))
                ]),
                Expanded(
                    child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final numfor = NumberFormat("#,##0.00", "tr_TR");

                    return Padding(
                        padding: const EdgeInsets.all(3),
                        child: ListTile(
                            visualDensity: const VisualDensity(vertical: 0),
                            title: Text(data[index].tanim),
                            subtitle: Text(
                              "${dateFormater(data[index].tarih, "dd.MM.yyyy")}  ${data[index].kasa} ${numfor.format(data[index].tutar)} TL:\n ${data[index].aciklama}",
                              maxLines: 2,
                            ),
                            tileColor: tileColorByIndex(index),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return Odeme(
                                    context,
                                    muhasebe: data[index],
                                    store: widget.store,
                                    uyeAd: widget.bilgi.ad,
                                    uyeId: widget.bilgi.uye_id,
                                  );
                                })).then((value) {
                                  setState(() {});
                                });
                              },
                            )));
                  },
                ))
              ]);
            },
          ),
          FBuilder<List<MuhasebeDiger>>(
            future: uyeharcamalist(api, widget.bilgi.uye_id),
            builder: (data) {
              return Column(children: [
                Row(children: [
                  Expanded(
                      child: ElevatedButton(
                    child: const Text("Yeni Harcama"),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return Harcama(
                          context,
                          muhasebe: MuhasebeDiger(),
                          store: widget.store,
                          uyeAd: widget.bilgi.ad,
                          uyeId: widget.bilgi.uye_id,
                        );
                      })).then((value) {
                        setState(() {});
                      });
                    },
                  ))
                ]),
                Expanded(
                    child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.all(3),
                        child: ListTile(
                            visualDensity: const VisualDensity(vertical: 0),
                            title: Text(data[index].tanim),
                            subtitle: Text(
                              "${data[index].kasa} / ${data[index].tutar}:\n ${data[index].aciklama}",
                              maxLines: 2,
                            ),
                            tileColor: tileColorByIndex(index),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return Harcama(
                                    context,
                                    muhasebe: data[index],
                                    store: widget.store,
                                    uyeAd: widget.bilgi.ad,
                                    uyeId: widget.bilgi.uye_id,
                                  );
                                })).then((value) {
                                  setState(() {});
                                });
                              },
                            )));
                  },
                ))
              ]);
            },
          ),
        ]))
      ],
    );
  }
}
