import 'dart:async';

import 'package:flutter/material.dart';

typedef IntervalFnc = void Function(int);

class Zamanlayici {
  int _sure = 0;
  Timer? timer;

  IntervalFnc? intFnc;

  Zamanlayici();

  void start() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _sure += 1;
      if (intFnc != null) {
        intFnc!(_sure);
      }
    });
  }

  void _stop() {
    timer?.cancel();
    timer = null;
  }

  void stop() {
    _stop();
    if (intFnc != null) {
      intFnc!(_sure);
    }
  }

  void startStop() {
    if (timer == null) {
      start();
    } else {
      stop();
    }
  }

  void reset() {
    _stop();
    _sure = 0;
    if (intFnc != null) {
      intFnc!(_sure);
    }
  }

  get sure {
    return _sure;
  }
}

class Saat extends StatefulWidget {
  final Zamanlayici z;
  const Saat({super.key, required this.z});

  @override
  State<StatefulWidget> createState() {
    return _Saat();
  }

  void stop() {}
}

class _Saat extends State<Saat> {
  int sure = 0;
  String zamangoster(int s) {
    int saat = (s ~/ 3600);
    int dakika = (s % 3600) ~/ 60;
    int saniye = s % 60;
    return "${saat.toString().padLeft(2, "0")}:${dakika.toString().padLeft(2, "0")}:${saniye.toString().padLeft(2, "0")}";
  }

  @override
  void initState() {
    super.initState();
    sure = widget.z.sure;
    widget.z.intFnc = zaman;
  }

  void zaman(int s) {
    if (mounted) {
      setState(() {
        sure = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const sty = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      ElevatedButton(
          onPressed: () {
            widget.z.startStop();
          },
          child: Text(
            zamangoster(sure),
            style: sty,
          )),
      const SizedBox(width: 10),
      ElevatedButton(
          onPressed: () {
            widget.z.reset();
          },
          child: const Text("RESET", style: sty))
    ]);
  }
}
