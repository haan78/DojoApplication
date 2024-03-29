import 'package:dojo_mobile/page/widget/app_drawer.dart';
import 'package:dojo_mobile/page/yoklama_gun.dart';
import 'package:dojo_mobile/service/servicemethods.dart';
import 'package:dojo_mobile/service/servicetypes.dart';
import 'package:flutter/material.dart';

import '../tools/api.dart';
import '../store.dart';
import 'appwindow.dart';

class YoklamaPage extends StatefulWidget {
  final Store store;
  const YoklamaPage({super.key, required this.store});

  @override
  State<YoklamaPage> createState() {
    return _YoklamaPage();
  }
}

class _YoklamaPage extends State<YoklamaPage> {
  int selectedYoklamaId = 0;
  late Store store;
  DateTime tarih = DateTime.now();
  final tbas = DateTime.now().add(const Duration(days: -14));
  final tbit = DateTime.now().add(const Duration(days: 14));
  late Api api;

  @override
  void initState() {
    super.initState();
    store = widget.store;
    if (store.sabitler.yoklamalar.isNotEmpty) {
      selectedYoklamaId = store.sabitler.yoklamalar[0].yoklama_id;
    }
    api = Api(url: store.ApiUrl, authorization: store.ApiToken);
  }

  List<DropdownMenuItem<int>> yoklamaitmes(List<Yoklama> list) {
    List<DropdownMenuItem<int>> result = [];
    for (int i = 0; i < list.length; i++) {
      result.add(DropdownMenuItem<int>(value: list[i].yoklama_id, child: Text(list[i].tanim)));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: appDrawer(context),
        appBar: AppBar(
          title: appTitle(text: "Yoklamalar"),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return YoklamaGun(
                      context,
                      keiko: Keiko(),
                      store: store,
                    );
                  }));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Padding(
            padding: appPading,
            child: Column(
              children: [
                Expanded(
                  child: FBuilder(
                    future: yoklamalar(api),
                    builder: (data) {
                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final tanim = data[index].tanim;
                          final sayi = data[index].sayi.toString();
                          final tar = trKisaDate(data[index].tarih);
                          return Padding(
                              padding: appPading,
                              child: ListTile(
                                  leading: Text(tanim, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  title: Text(tar, style: const TextStyle(color: colorInfo, fontWeight: FontWeight.bold)),
                                  subtitle: Text("Ksatılan Sayısı $sayi", style: const TextStyle(color: colorInfo)),
                                  dense: true,
                                  tileColor: tileColorByIndex(index),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward, color: colorMenuFG),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                                        return YoklamaGun(
                                          context,
                                          keiko: data[index],
                                          store: store,
                                        );
                                      })).then((value) {
                                        setState(() {});
                                      });
                                    },
                                  )));
                        },
                      );
                    },
                  ),
                )
              ],
            )));
  }
}
