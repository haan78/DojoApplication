import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color colorGood = Color.fromARGB(255, 19, 94, 9);
const Color colorBad = Color.fromARGB(255, 173, 5, 5);

enum AppWindow { harcamalar, uyeler, yoklamalar, ayarlar }

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
                style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorGood)),
                child: const Text("EVET")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (onNo != null) {
                    onNo();
                  }
                },
                style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad)),
                child: const Text("HAYIR"))
          ],
        );
      }));
}

Color tileColorByIndex(int index) {
  return index % 2 == 1 ? const Color.fromARGB(255, 208, 224, 233) : const Color.fromARGB(255, 229, 233, 208);
}

String trAy(int index) {
  return ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"][index % 12];
}

const List<DropdownMenuItem> Aylar = [
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
  DropdownMenuItem(value: 12, child: Text("Aralık")),
  DropdownMenuItem(value: 0, child: Text("[Seçiniz]")),
];

bool isEmail(String value) {
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
}

String dateFormater(DateTime value, String format) {
  DateFormat df = DateFormat(format);
  return df.format(value);
}
