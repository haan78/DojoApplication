import 'package:flutter/material.dart';

import '../../service.dart';
import '../appwindow.dart';

Widget uyeListItem(
    UyeListDetay data, VoidCallback? btnCallback, Color? bgColor) {
  return Padding(
    padding: const EdgeInsets.all(5),
    child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          color: bgColor,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 75,
                      height: 90,
                      child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Image.memory(data.image!, fit: BoxFit.fill))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: SizedBox(
                          height: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${data.ad} ${data.seviye}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Aidat Borcu ${data.odenmemis_aidat_syisi}",
                                  style: TextStyle(
                                      color: renkver(
                                          data.odenmemis_aidat_syisi, 3, 5))),
                              const SizedBox(height: 10),
                              Text(
                                  "Son Keiko: ${dateFormater(data.son_keiko, "dd.MM.yyyy")}\nSon3Ay: ${data.son3Ay.toString()}",
                                  style: TextStyle(
                                      color:
                                          renkver(-1 * data.son3Ay, -18, -12)))
                            ],
                          ))),
                  IconButton(
                    onPressed: btnCallback,
                    icon: const Icon(
                      Icons.arrow_circle_right_sharp,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
              )),
        )),
  );
}
