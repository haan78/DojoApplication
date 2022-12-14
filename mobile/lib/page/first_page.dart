import 'package:dojo_mobile/page/kendoka.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:intl/intl.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MenuAction { load, filter, sort }

enum FilterAction { debt, last, name }

List<UyeListDetay> listData = [];
final _araKey = GlobalKey<FormState>();

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() {
    return _AdminPageState();
  }
}

class _AdminPageState extends State<FirstPage> {
  late Store store;
  bool _reload = true;
  FilterAction _filterAction = FilterAction.name;
  int tahakkuk_id = 1;
  bool activemembers = true;

  String search = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    store = Provider.of<Store>(context);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: scaffoldKey,
        drawer: app_drawer(store.AppName, context, scaffoldKey, (aw) {}),
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset(
                "assets/logo.png",
                fit: BoxFit.contain,
                height: 32,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(store.AppName)
            ],
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              activemembers = true;
                              _reload = true;
                            });
                          },
                          child: Row(
                            children: const [Icon(Icons.group), Text("Aktif ??yeler")],
                          ))),
                  PopupMenuItem(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              activemembers = false;
                              _reload = true;
                            });
                          },
                          child: Row(
                            children: const [Icon(Icons.person_off), Text("Pasif ??yeler")],
                          )))
                ];
              },
              child: const Icon(Icons.filter_list),
            ),
            IconButton(
                onPressed: () {
                  kendokaGetir(context, 0);
                },
                icon: const Icon(Icons.person_add))
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(3),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                    key: _araKey,
                    decoration: const InputDecoration(labelText: "Ara", prefixIcon: Icon(Icons.search)),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                        _reload = false;
                      });
                    },
                  )),
                  PopupMenuButton(
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filterAction = FilterAction.debt;
                                    _reload = false;
                                  });
                                },
                                child: Row(
                                  children: const [Icon(Icons.payments), Text("Aidat Borcu")],
                                ))),
                        PopupMenuItem(
                            child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _filterAction = FilterAction.last;
                                    _reload = false;
                                  });
                                },
                                child: Row(
                                  children: const [Icon(Icons.calendar_month), Text("Gelmeyenler")],
                                ))),
                        PopupMenuItem(
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _filterAction = FilterAction.name;
                                  _reload = false;
                                });
                              },
                              child: Row(
                                children: const [Icon(Icons.sort_by_alpha), Text("??sime G??re")],
                              )),
                        )
                      ];
                    },
                    child: const Icon(Icons.sort),
                  ),
                ],
              ),
            ),
            Expanded(
                child: FutureBuilder<List<UyeListDetay>>(
                    future: uyeler(activemembers, search, _filterAction, store, _reload, tahakkuk_id),
                    builder: (BuildContext context, AsyncSnapshot<List<UyeListDetay>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (!snapshot.hasError && snapshot.data != null) {
                          List<UyeListDetay> data = snapshot.data!;
                          return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              String info1 = "Aidat Borcu ${data[index].odenmemis_aidat_syisi}";
                              String info2 = "Son Keiko: ${DateFormat.yMd().format(data[index].son_keiko)}";
                              String info3 = "Son3Ay: ${data[index].son3Ay.toString()}";
                              return Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: ListTile(
                                    visualDensity: const VisualDensity(vertical: 4),
                                    leading: data[index].image != null
                                        ? Padding(
                                            padding: const EdgeInsets.only(bottom: 7),
                                            child: Image.memory(data[index].image!),
                                          )
                                        : const Icon(Icons.accessibility_outlined),
                                    title: Text("${data[index].ad} / ${data[index].seviye}"),
                                    subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(info1, style: TextStyle(fontSize: 12, color: renkver(data[index].odenmemis_aidat_syisi))),
                                      Row(children: [
                                        Text(info2, style: TextStyle(fontSize: 12, color: renkver2(data[index].son_keiko))),
                                        const SizedBox(width: 10),
                                        Text(info3, style: TextStyle(fontSize: 12, color: renkver3(data[index].son3Ay)))
                                      ])
                                    ]),
                                    tileColor: tileColorByIndex(index),
                                    dense: true,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.arrow_forward),
                                      onPressed: () {
                                        kendokaGetir(context, data[index].uye_id);
                                      },
                                    ),
                                  ));
                            },
                          );
                        } else {
                          return const Text("No Data");
                        }
                      } else if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Loading...");
                      } else {
                        return const Text("Service Error");
                      }
                    }))
          ],
        ));
  }
}

Future<List<UyeListDetay>> uyeler(bool active, String search, FilterAction fa, Store store, bool reload, int tahakkukId) async {
  List<UyeListDetay> data = [];
  if (reload) {
    Api api = Api(url: store.ApiUrl, authorization: store.ApiToken);
    listData = await uye_listele(api, durumlar: active ? "active,admin,super-admin" : "passive");
  }

  if (search.isNotEmpty) {
    data = listData.where((element) {
      if (element.ad.toLowerCase().startsWith(search.toLowerCase()) || element.seviye.startsWith(search.toUpperCase())) {
        return true;
      } else {
        return false;
      }
    }).toList();
  } else {
    data = listData;
  }

  if (fa == FilterAction.debt) {
    data.sort(((a, b) {
      return b.odenmemis_aidat_borcu.compareTo(a.odenmemis_aidat_borcu);
    }));
  } else if (fa == FilterAction.last) {
    data.sort((a, b) {
      return a.son_keiko.compareTo(b.son_keiko);
    });
  } else {
    data.sort(((a, b) {
      return a.ad.compareTo(b.ad);
    }));
  }

  return Future<List<UyeListDetay>>(() => data);
}

Color renkver(int val) {
  if (val < 3) {
    return Colors.green;
  } else if (val < 5) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

Color renkver2(DateTime val) {
  DateTime n = DateTime.now();
  int m = n.difference(val).inDays ~/ 30;
  if (m < 1) {
    return Colors.green;
  } else if (m < 2) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

Color renkver3(int val) {
  if (val > 15) {
    return Colors.green;
  } else if (val > 10) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

void kendokaGetir(BuildContext context, int uye_id) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => Kendoka(uye_id)));
}
