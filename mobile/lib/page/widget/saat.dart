import 'dart:async';

import 'package:flutter/material.dart';

class Saat extends StatefulWidget {
  Timer? timer;
  const Saat({super.key});

  @override
  State<StatefulWidget> createState() {
    return _Saat();
  }
}

class _Saat extends State<Saat> {  
  int sure = 0;
  void _start() {
    widget.timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        sure += 1;
      });
    });
  }

  void _stop(bool reset) {
    widget.timer?.cancel();
    widget.timer = null;
    if (reset) {
      setState(() {
        sure = 0;
      });
    }
  }

  String zamangoster(int s) {
    int saat = (s ~/ 3600);
    int dakika = (s % 3600) ~/ 60;
    int saniye = s % 60;
    return "${saat.toString().padLeft(2, "0")}:${dakika.toString().padLeft(2, "0")}:${saniye.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    const sty = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
          onPressed: () {
            if (widget.timer == null) {
              _start();
            } else {
              _stop(false);
            }
          },
          child: Text(
            zamangoster(sure),
            style: sty,
          )),
      const SizedBox(width: 10),
      ElevatedButton(
          onPressed: () {
            _stop(true);
          },
          child: const Text("RESET", style: sty))
    ]);
  }
}
