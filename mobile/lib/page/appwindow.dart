import 'dart:io';

import 'package:better_open_file/better_open_file.dart';
import 'package:dojo_mobile/page/widget/alert.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../service.dart';

const Color colorGood = Color.fromARGB(255, 88, 153, 78);
const Color colorBad = Color.fromARGB(255, 221, 27, 27);
const Color colorWarn = Color.fromARGB(255, 129, 122, 23);
const colorTile1 = Color.fromARGB(255, 195, 204, 194);
const colorTile2 = Color.fromARGB(255, 188, 201, 201);
const colorInfo = Color.fromARGB(255, 16, 148, 148);
const appVersion = "1.0.6-beta";
const programerEmail = "alibarisozturk@gmail.com";
const appPading = EdgeInsets.all(3);

ButtonStyle goodBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorGood));
ButtonStyle badBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad));
ButtonStyle warnBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorWarn));

//enum AppWindow { harcamalar, uyeler, yoklamalar, ayarlar, raporlar }

final buYil = DateTime.now().year;

yesNoDialog(BuildContext context, {required String text, String title = "Onay", required Function() onYes, Function()? onNo}) {
  showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(text),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onYes();
                },
                //style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorGood)),
                style: goodBtnStyle,
                child: const Text("EVET")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onNo != null) {
                    onNo();
                  }
                },
                //style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
                style: badBtnStyle,
                child: const Text("HAYIR"))
          ],
        );
      }));
}

class MultiSelectOption {
  String name = "";
  bool checked = false;
  MultiSelectOption(this.name, this.checked);
}

void multiSelectDialog(BuildContext context,
    {required List<MultiSelectOption> list, required Function(List<MultiSelectOption> options) onOk, Function()? onCancel, Widget? title}) {
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          final wlist = <CheckboxListTile>[];
          for (int i = 0; i < list.length; i++) {
            wlist.add(CheckboxListTile(
                title: Text(list[i].name),
                value: list[i].checked,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => list[i].checked = value);
                  }
                }));
          }
          return AlertDialog(title: title, content: Column(children: wlist), actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onOk(list);
                },
                //style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorGood)),
                style: goodBtnStyle,
                child: const Text("Tamam")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onCancel != null) {
                    onCancel();
                  }
                },
                //style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
                style: badBtnStyle,
                child: const Text("İptal"))
          ]);
        });
      });
}

String trAy(int ayint) {
  final ind = ayint - 1;
  return ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"][ind % 12];
}

const aylarText = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
const List<DropdownMenuItem<int>> aylarMenuItem = [
  DropdownMenuItem(value: 0, child: Text("[Seçiniz]")),
  DropdownMenuItem(value: 1, child: Text("Ocak")),
  DropdownMenuItem(value: 2, child: Text("Şubat")),
  DropdownMenuItem(value: 3, child: Text("Mart")),
  DropdownMenuItem(value: 4, child: Text("Nisan")),
  DropdownMenuItem(value: 5, child: Text("Mayıs")),
  DropdownMenuItem(value: 6, child: Text("Haziran")),
  DropdownMenuItem(value: 7, child: Text("Tammuz")),
  DropdownMenuItem(value: 8, child: Text("Ağustos")),
  DropdownMenuItem(value: 9, child: Text("Eylül")),
  DropdownMenuItem(value: 10, child: Text("Ekim")),
  DropdownMenuItem(value: 11, child: Text("Kasım")),
  DropdownMenuItem(value: 12, child: Text("Aralık"))
];
bool isEmail(String value) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
}

List<DropdownMenuItem<int>> yoklamaMenuItems(List<Yoklama> yoklamalar, {bool bosSecenek = true}) {
  List<DropdownMenuItem<int>> l = yoklamalar.asMap().entries.map((e) {
    return DropdownMenuItem<int>(value: e.value.yoklama_id, child: Text(e.value.tanim));
  }).toList();
  if (bosSecenek) {
    l.insert(0, const DropdownMenuItem<int>(value: 0, child: Text("Seçiniz")));
  }
  return l;
}

Widget yoklamaSelect(List<Yoklama> yoklamalar, int yoklamaId, {bool bosSecenek = true, required void Function(int?) onChange}) {
  if (yoklamalar.length == 1) {
    onChange(yoklamalar[0].yoklama_id);
    return Text(yoklamalar[0].tanim);
  } else if (yoklamalar.length > 1) {
    return DropdownButton<int>(items: yoklamaMenuItems(yoklamalar, bosSecenek: bosSecenek), value: yoklamaId, onChanged: onChange);
  } else {
    return const Text("");
  }
}

String dateFormater(DateTime value, String format) {
  DateFormat df = DateFormat(format);
  return df.format(value);
}

String trKisaDate(DateTime tarih) {
  const hafta = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
  const aylar = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"];

  final gun = tarih.day.toString().padLeft(2, "0");
  final hg = hafta[tarih.weekday - 1];
  final ay = aylar[tarih.month - 1];
  final yil = (tarih.year - 2000).toString().padLeft(2, "0");
  return "$gun $ay $yil ($hg)";
}

DateTime dateTimeSum(DateTime date, Duration d, {bool subtract = false}) {
  if (subtract) {
    return date.add(d);
  } else {
    return date.subtract(d);
  }
}

final List<DropdownMenuItem> seviyeler = [
  const DropdownMenuItem(value: "", child: Text("")),
  DropdownMenuItem(value: "7 KYU", child: Text("7 KYU", style: TextStyle(color: Colors.pink.shade200))),
  DropdownMenuItem(value: "6 KYU", child: Text("6 KYU", style: TextStyle(color: Colors.pink.shade200))),
  DropdownMenuItem(value: "5 KYU", child: Text("5 KYU", style: TextStyle(color: Colors.pink.shade200))),
  DropdownMenuItem(value: "4 KYU", child: Text("4 KYU", style: TextStyle(color: Colors.pink.shade200))),
  DropdownMenuItem(value: "3 KYU", child: Text("3 KYU", style: TextStyle(color: Colors.pink.shade400))),
  DropdownMenuItem(value: "2 KYU", child: Text("2 KYU", style: TextStyle(color: Colors.pink.shade400))),
  DropdownMenuItem(value: "1 KYU", child: Text("1 KYU", style: TextStyle(color: Colors.pink.shade600))),
  DropdownMenuItem(value: "1 DAN", child: Text("1 DAN", style: TextStyle(color: Colors.pink.shade600))),
  DropdownMenuItem(value: "2 DAN", child: Text("2 DAN", style: TextStyle(color: Colors.pink.shade600))),
  DropdownMenuItem(value: "3 DAN", child: Text("3 DAN", style: TextStyle(color: Colors.red.shade400))),
  DropdownMenuItem(value: "4 DAN", child: Text("4 DAN", style: TextStyle(color: Colors.red.shade600))),
  DropdownMenuItem(value: "5 DAN", child: Text("5 DAN", style: TextStyle(color: Colors.red.shade600))),
  DropdownMenuItem(value: "6 DAN", child: Text("6 DAN", style: TextStyle(color: Colors.red.shade900))),
  DropdownMenuItem(value: "7 DAN", child: Text("7 DAN", style: TextStyle(color: Colors.brown.shade800)))
];

const kasalar = [
  DropdownMenuItem(value: "", child: Text("[Seçiniz]")),
  DropdownMenuItem(value: "Elden", child: Text("Elden")),
  DropdownMenuItem(value: "Sayman Banka", child: Text("Sayman Banka")),
  DropdownMenuItem(value: "Dernek Banka", child: Text("Dernek Banka"))
];

// ignore: unnecessary_const

Row appTitle({required String text}) {
  return Row(
    children: [
      Image.asset(
        "assets/logo.png",
        fit: BoxFit.contain,
        height: 32,
      ),
      const SizedBox(
        width: 10,
      ),
      Text(text)
    ],
  );
}

class FBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(T data) builder;

  const FBuilder({super.key, required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
        future: future,
        builder: (context, AsyncSnapshot<T> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!snapshot.hasError) {
              return builder(snapshot.data as T);
            } else {
              return Center(
                  child: Text(
                "Hata Oluştu\n${snapshot.error.toString()}",
                maxLines: 2,
                style: const TextStyle(color: colorBad),
              ));
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("Bilinmeyen Durum"));
          }
        });
  }
}

Scaffold uyeScaffold({required String uyeAd, required Widget body}) {
  return Scaffold(
    appBar: AppBar(title: appTitle(text: uyeAd)),
    body: Padding(padding: const EdgeInsets.all(10), child: body),
  );
}

enum MuhasebeTanimEnum { gelir, gider }

List<DropdownMenuItem<int>> getMuhasebeTanimItems(List<MuhasebeTanim> tanimlar, MuhasebeTanimEnum tur, {bool bosDeger = true}) {
  List<DropdownMenuItem<int>> l = [];
  if (bosDeger) {
    l.add(const DropdownMenuItem<int>(value: 0, child: Text("[Seçiniz]")));
  }
  for (final tanim in tanimlar) {
    if (tur == MuhasebeTanimEnum.gelir && tanim.tur == 'GELIR' && tanim.muhasebe_tanim_id != 9) {
      // aidati buraya alma
      l.add(DropdownMenuItem<int>(value: tanim.muhasebe_tanim_id, child: Text(tanim.tanim)));
    } else if (tur == MuhasebeTanimEnum.gider && tanim.tur == 'GIDER') {
      l.add(DropdownMenuItem<int>(value: tanim.muhasebe_tanim_id, child: Text(tanim.tanim)));
    }
  }
  return l;
}

class LoadingDialog {
  final BuildContext context;
  bool _started = false;
  LoadingDialog(this.context);

  bool get started {
    return _started;
  }

  void push() {
    if (!_started) {
      _started = true;
      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator())).then((value) {
        _started = false;
      });
    }
  }

  void pop() {
    if (context.mounted && _started) {
      Navigator.of(context).pop();
      _started = false;
    }
  }

  @protected
  @mustCallSuper
  void dispose() {
    pop();
  }
}

class FullDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> rows;
  final DataColumn Function(String name)? customColumn;
  final DataCell Function(String name, int rowIndex, Map<String, dynamic> row)? customCell;

  const FullDataTable({super.key, required this.rows, this.customColumn, this.customCell});

  List<DataColumn> createColumns() {
    final l = <DataColumn>[];
    if (rows.isNotEmpty) {
      final fr = rows[0];
      for (int ci = 0; ci < fr.keys.length; ci++) {
        l.add(customColumn != null ? customColumn!(fr.keys.elementAt(ci)) : DataColumn(label: Text(fr.keys.elementAt(ci))));
      }
    }
    return l;
  }

  List<DataRow> createRows() {
    final l = <DataRow>[];
    for (int i = 0; i < rows.length; i++) {
      final drl = <DataCell>[];
      for (final k in rows[i].keys) {
        drl.add(customCell != null ? customCell!(k, i, rows[i]) : DataCell(Text(rows[i][k].toString())));
      }
      l.add(DataRow(cells: drl));
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child:
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(columns: createColumns(), rows: createRows(), border: TableBorder.all(color: Colors.black))));
  }
}

Color renkver(int val, double min, double max) {
  if (val < min) {
    return colorGood;
  } else if (val < max) {
    return colorWarn;
  } else {
    return colorBad;
  }
}

Color tileColorByIndex(int index) {
  return index % 2 == 1 ? colorTile1 : colorTile2;
}

Future<void> openExcel(BuildContext context, String reportName, Excel excel) async {
  Directory tempDir = await getTemporaryDirectory();

  final fname = "${tempDir.path}/$reportName${dateFormater(DateTime.now(), "yyyyMMddHHmmss")}.xlsx";
  final file = File(fname);
  await file.writeAsBytes(excel.save(fileName: fname)!);

  final result = await OpenFile.open(file.path);
  if (result.type != ResultType.done) {
    if (context.mounted) errorAlert(context, result.message);
  }
}
