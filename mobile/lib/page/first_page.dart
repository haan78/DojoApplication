import 'package:dojo_mobile/page/kendoka.dart';
import 'package:dojo_mobile/page/widget/list_items.dart';
import 'package:dojo_mobile/page/widget/app_drawer.dart';
import '../api.dart';
import '../service.dart';
import '../store.dart';
import 'package:flutter/material.dart';

import 'appwindow.dart';

enum MenuAction { load, filter, sort }

enum FilterAction { debt, last, name }

List<UyeListDetay> listData = [];

class FirstPage extends StatefulWidget {
  final Store store;
  const FirstPage({super.key, required this.store});

  @override
  State<FirstPage> createState() {
    return _AdminPageState();
  }
}

enum ListType { active, passive, registerd }

class _AdminPageState extends State<FirstPage> {
  final _araKey = GlobalKey<FormState>();
  bool _reload = true;
  FilterAction _filterAction = FilterAction.name;
  int tahakkukId = 1;
  ListType listType = ListType.active;
  late Api api;

  String search = "";

  @override
  void initState() {
    super.initState();
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    //GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
        drawer: appDrawer(context),
        appBar: AppBar(
          title: appTitle(text: "Üyeler"),
          actions: [
            PopupMenuButton(
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              listType = ListType.active;
                              _reload = true;
                            });
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.group),
                              Text("Aktif Üyeler")
                            ],
                          ))),
                  PopupMenuItem(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              listType = ListType.passive;
                              _reload = true;
                            });
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.group_off),
                              Text("Pasif Üyeler")
                            ],
                          ))),
                  PopupMenuItem(
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              listType = ListType.registerd;
                              _reload = true;
                            });
                          },
                          child: Row(
                            children: const [
                              Icon(Icons.group_add),
                              Text("Bekleyenler")
                            ],
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                key: _araKey,
                decoration: InputDecoration(
                    labelText: "Ara",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: PopupMenuButton(
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
                                    children: const [
                                      Icon(Icons.payments),
                                      Text("Aidat Borcu")
                                    ],
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
                                    children: const [
                                      Icon(Icons.calendar_month),
                                      Text("Gelmeyenler")
                                    ],
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
                                  children: const [
                                    Icon(Icons.sort_by_alpha),
                                    Text("İsime Göre")
                                  ],
                                )),
                          )
                        ];
                      },
                      child: const Icon(Icons.sort),
                    )),
                onChanged: (value) {
                  setState(() {
                    search = value;
                    _reload = false;
                  });
                },
              ),
              FBuilder<List<UyeListDetay>>(
                future: uyeler(listType, search, _filterAction, store, _reload),
                builder: (data) {
                  return Expanded(
                      child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return uyeListItem(data[index], () {
                        kendokaGetir(context, data[index].uye_id);
                      }, tileColorByIndex(index));
                    },
                  ));
                },
              )
            ],
          ),
        ));
  }

  Future<List<UyeListDetay>> uyeler(ListType type, String search,
      FilterAction fa, Store store, bool reload) async {
    List<UyeListDetay> data = [];
    String durumlar = "active,admin,super-admin";
    if (type == ListType.registerd) {
      durumlar = "registered";
    } else if (type == ListType.passive) {
      durumlar = "passive";
    }
    if (reload) {
      try {
        listData = await uye_listele(api, durumlar: durumlar);
      } catch (err) {
        return Future.error(err);
      }
    }

    if (search.isNotEmpty) {
      data = listData.where((element) {
        if (element.ad.toLowerCase().startsWith(search.toLowerCase()) ||
            element.seviye.startsWith(search.toUpperCase())) {
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
}

void kendokaGetir(BuildContext context, int uyeId) {
  Navigator.push(
      context, MaterialPageRoute(builder: (context) => Kendoka(uyeId)));
}
