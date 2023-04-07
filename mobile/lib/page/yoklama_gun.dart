import 'package:dojo_mobile/page/appwindow.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../service.dart';
import '../store.dart';

class YoklamaGun extends StatefulWidget {
  final Keiko keiko;
  final Store store;
  const YoklamaGun(BuildContext context, {super.key, required this.keiko, required this.store});

  @override
  State<StatefulWidget> createState() {
    return _YoklamaGun();
  }
}

class _YoklamaGun extends State<YoklamaGun> {
  List<KeikoKendoka> list = [];
  bool reload = true;
  late ScrollController _scrollController;
  final tbas = DateTime.now().add(const Duration(days: -14));
  final tbit = DateTime.now().add(const Duration(days: 14));
  late Api api;
  late LoadingDialog loadingdlg;
  double _offset = 0;

  Future<List<KeikoKendoka>> getList() async {
    if (reload) {
      try {
        loadingdlg.push();
        KeikoListe kl = await yoklamaliste(api, tarih: widget.keiko.tarih, yoklama_id: widget.keiko.yoklama_id);
        loadingdlg.pop();
        reload = false;
        if (widget.keiko.sayi != kl.katilanSayisi) {
          setState(() {
            widget.keiko.sayi = kl.katilanSayisi;
          });
        }
        list = kl.list;
      } catch (err) {
        errorAlert(context, err.toString());
      } finally {
        loadingdlg.pop();
      }
    }
    return list;
  }

  List<DropdownMenuItem<int>> yoklamaitmes(List<Yoklama> yoklamalar) {
    List<DropdownMenuItem<int>> result = [];
    for (int i = 0; i < list.length; i++) {
      result.add(DropdownMenuItem<int>(value: yoklamalar[i].yoklama_id, child: Text(yoklamalar[i].tanim)));
    }
    return result;
  }

  @override
  void initState() {
    api = Api(url: widget.store.ApiUrl, authorization: widget.store.ApiToken);
    if (widget.keiko.yoklama_id == 0 && widget.store.sabitler.yoklamalar.length == 1) {
      widget.keiko.tanim = widget.store.sabitler.yoklamalar[0].tanim;
      widget.keiko.yoklama_id = widget.store.sabitler.yoklamalar[0].yoklama_id;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController = ScrollController(keepScrollOffset: true, initialScrollOffset: _offset);
    return Scaffold(
      appBar: AppBar(title: appTitle(text: "Keikoda Olan Kişiler"), actions: [
        IconButton(
            onPressed: () {
              setState(() {
                reload = true;
              });
            },
            icon: const Icon(Icons.refresh))
      ]),
      body: Padding(
          padding: AppPading,
          child: Column(children: [
            Row(
              children: [
                widget.store.sabitler.yoklamalar.length == 1
                    ? Text(widget.keiko.tanim)
                    : DropdownButtonFormField(
                        items: yoklamaitmes(widget.store.sabitler.yoklamalar),
                        value: widget.keiko.yoklama_id,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              widget.keiko.yoklama_id = value;
                            });
                          }
                        },
                      ),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () async {
                      final dt = await showDatePicker(context: context, initialDate: widget.keiko.tarih, firstDate: tbas, lastDate: tbit);
                      if (dt != null) {
                        setState(() {
                          widget.keiko.tarih = dt;
                          _offset = 0;
                          reload = true;
                        });
                      }
                    },
                    child: Text(dateFormater(widget.keiko.tarih, "dd.MM.yyyy"))),
                const SizedBox(width: 10),
                Text("Katılımcı ${widget.keiko.sayi} / ${list.length}")
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
                child: FutureBuilder<List<KeikoKendoka>>(
              future: getList(),
              builder: (context, AsyncSnapshot<List<KeikoKendoka>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<KeikoKendoka> data = snapshot.data!;

                  return GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        child: Card(
                          shadowColor: data[index].katilim ? Colors.green.shade500 : Colors.black54,
                          elevation: 9,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), side: BorderSide(color: data[index].katilim ? Colors.green.shade900 : Colors.white, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  //borderRadius: BorderRadius.circular(25),

                                  child: Image.memory(data[index].image!),
                                ),
                                Text(
                                  data[index].ad,
                                  maxLines: 2,
                                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                        onTap: () async {
                          try {
                            loadingdlg.push();
                            final result = await uyeYoklama(api, yoklama_id: widget.keiko.yoklama_id, uye_id: data[index].uye_id, tarih: widget.keiko.tarih);
                            loadingdlg.pop();
                            setState(() {
                              _offset = _scrollController.offset;
                              if (result == 1) {
                                list[index].katilim = true;
                                widget.keiko.sayi += 1;
                              } else {
                                list[index].katilim = false;
                                widget.keiko.sayi -= 1;
                              }
                            });
                          } catch (err) {
                            errorAlert(context, err.toString());
                          } finally {
                            loadingdlg.pop();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("Loading...");
                } else {
                  return const Text("Service Error");
                }
              },
            ))
          ])),
    );
  }
}
