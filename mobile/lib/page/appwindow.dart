import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const Color colorGood = Color.fromARGB(255, 19, 94, 9);
const Color colorBad = Color.fromARGB(255, 173, 5, 5);
const Color colorWarn = Color.fromARGB(255, 204, 191, 11);

const AppTitleText = "Ankara Kendo";
const AppPading = EdgeInsets.all(3);

ButtonStyle goodBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorGood));
ButtonStyle badBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorBad));
ButtonStyle warnBtnStyle = ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => colorWarn));

enum AppWindow { harcamalar, uyeler, yoklamalar, ayarlar, raporlar }

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

List<DropdownMenuItem> Seviyeler = [
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

const Dikey = SizedBox(height: 10);
const Dikey2 = SizedBox(height: 20);
const Yatay = SizedBox(width: 10);
const Yatay2 = SizedBox(width: 20);

// ignore: unnecessary_const
final AppTitle = Row(
  children: [
    Image.asset(
      "assets/logo.png",
      fit: BoxFit.contain,
      height: 32,
    ),
    const SizedBox(
      width: 10,
    ),
    const Text(AppTitleText)
  ],
);
