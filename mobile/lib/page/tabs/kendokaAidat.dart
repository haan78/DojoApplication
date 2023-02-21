import 'package:flutter/material.dart';

import '../../service.dart';
import '../../store.dart';
import '../appwindow.dart';
import '../payment.dart';

class KendokaAidat extends StatelessWidget {
  final UyeBilgi bilgi;
  final Store store;
  final UpdateParentData updateParentData;
  final Sabitler sabitler;
  final String uyeAd;
  const KendokaAidat({super.key, required this.sabitler, required this.bilgi, required this.store, required this.updateParentData, required this.uyeAd});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(uyeAd),
            Expanded(
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return Payment(context, bilgi: UyeTahakkukBilgi(uyeTahakkuk: UyeTahakkuk(), store: store, uyeAd: uyeAd, uyeId: bilgi.uye_id));
                      }));
                    },
                    child: Row(
                      children: const [Icon(Icons.add), Text("Ödeme Al")],
                    )))
          ],
        ),
        Expanded(
            child: ListView.builder(
                itemCount: bilgi.tahakuklar.length,
                itemBuilder: (context, index) {
                  Text info1 = Text(bilgi.tahakuklar[index].tanim);
                  Text info2;
                  if (bilgi.tahakuklar[index].ay > 0 && bilgi.tahakuklar[index].muhasebe_id == 0) {
                    info2 = Text("${bilgi.tahakuklar[index].borc.toString()} TL ${trAy(bilgi.tahakuklar[index].ay)} / ${bilgi.tahakuklar[index].yil}",
                        style: const TextStyle(color: colorBad));
                  } else if (bilgi.tahakuklar[index].ay > 0 && bilgi.tahakuklar[index].muhasebe_id > 0) {
                    info2 = Text("${bilgi.tahakuklar[index].odenen.toString()} TL ${trAy(bilgi.tahakuklar[index].ay)} / ${bilgi.tahakuklar[index].yil}",
                        style: const TextStyle(color: colorGood));
                  } else if (bilgi.tahakuklar[index].ay == 0 && bilgi.tahakuklar[index].muhasebe_id == 0) {
                    info2 = Text("${bilgi.tahakuklar[index].borc.toString()} TL", style: const TextStyle(color: colorBad));
                  } else if (bilgi.tahakuklar[index].ay == 0 && bilgi.tahakuklar[index].muhasebe_id > 0) {
                    info2 = Text("${bilgi.tahakuklar[index].odenen.toString()} TL", style: const TextStyle(color: colorGood));
                  } else {
                    info2 = const Text("");
                  }
                  return Padding(
                      padding: const EdgeInsets.all(3),
                      child: ListTile(
                          visualDensity: const VisualDensity(vertical: 0),
                          title: info1,
                          subtitle: info2,
                          tileColor: tileColorByIndex(index),
                          leading: bilgi.tahakuklar[index].muhasebe_id > 0
                              ? const Icon(
                                  Icons.thumb_up_alt,
                                  color: colorGood,
                                )
                              : const Icon(
                                  Icons.thumb_down_alt,
                                  color: colorBad,
                                ),
                          trailing: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return Payment(context, bilgi: UyeTahakkukBilgi(uyeTahakkuk: bilgi.tahakuklar[index], store: store, uyeAd: uyeAd, uyeId: bilgi.uye_id));
                              }));
                            },
                          )));
                }))
      ],
    );
  }
}
