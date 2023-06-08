import 'package:dojo_mobile/store.dart';
import 'package:flutter/material.dart';

import '../../service.dart';
import '../appwindow.dart';

Widget uyeListItem(Store store, UyeListDetay uyeData, VoidCallback? btnCallback, Color? bgColor) {
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
                  SizedBox(width: 90, height: 120, child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(10)), child: uyeImageLoad(store, uyeData.uye_id))),
                  const SizedBox(width: 10),
                  Expanded(
                      child: SizedBox(
                          height: 90,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${uyeData.ad} ${uyeData.seviye}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text("Aidat Borcu ${uyeData.odenmemis_aidat_syisi}", style: TextStyle(color: renkver(uyeData.odenmemis_aidat_syisi, 3, 5))),
                              const SizedBox(height: 10),
                              Text("Son Keiko: ${dateFormater(uyeData.son_keiko, "dd.MM.yyyy")}\nSon3Ay: ${uyeData.son3Ay.toString()}",
                                  style: TextStyle(color: renkver(-1 * uyeData.son3Ay, -18, -12)))
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
