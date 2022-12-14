// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'api.dart';
import 'package:flutter/cupertino.dart';

class UyeSeviye {
  DateTime tarih = DateTime.now();
  String aciklama = "";
  int deger = 0;
  String seviye = "";
}

class UyeTahakkuk {
  int uye_tahakkuk_id = 0;
  int yil = 0;
  int ay = 0;
  DateTime tahakkuk_tarih = DateTime.now();
  int muhasebe_id = 0;
  DateTime? odenme_tarih;
  String tanim = "";
  double borc = 0;
  double odenen = 0;
  String kasa = "";
  String tahsilatci = "";
  String yoklama = "";
  int yoklama_id = 0;
}

class UyeYoklama {
  DateTime tarih = DateTime.now();
  String tanim = "";
  int yoklama_id = 0;
  String ayyilid = "";
}

class UyeBilgi {
  String ad = "";
  String cinsiyet = "";
  String file_type = "";
  DateTime dogum_tarih = DateTime.now();
  Uint8List? image;
  String durum = "";
  int dosya_id = 0;
  String ekfno = "";
  String tahkkuk = "";
  int tahakkuk_id = 0;
  String email = "";
  int eksik_tahakkuk = 0;
  int son3Ay = 0;
  List<UyeSeviye> seviyeler = [];
  List<UyeTahakkuk> tahakuklar = [];
  List<UyeYoklama> yoklamalar = [];
}

class UyeListDetay {
  int uye_id = 0;
  String ad = "";
  int dosya_id = 0;
  String seviye = "";
  int odenmemis_aidat_syisi = 0;
  double odenmemis_aidat_borcu = 0;
  DateTime son_keiko = DateTime.now();
  int son3Ay = 0;
  String image_type = "";
  Uint8List? image;
}

class Tahakkuk {
  int tahakkuk_id = 0;
  String tanim = "";
  double tutar = 0;
}

class Sabitler {
  List<Tahakkuk> tatakkuklar = [];
}

Future<Uint8List> uyeResim(Api api, {BoxFit fit = BoxFit.fill}) async {
  dynamic r = await api.call("/member/foto");
  String b64s = r["content"];
  return base64Decode(b64s);
}

Future<List<UyeListDetay>> uye_listele(Api api, {required String durumlar}) async {
  dynamic r = await api.call("/admin/uyeler", data: {"durumlar": durumlar});

  List<UyeListDetay> l = [];
  for (final urd in r) {
    UyeListDetay uld = UyeListDetay();
    uld.ad = urd["ad"];
    uld.dosya_id = int.parse(urd["dosya_id"].toString());
    uld.odenmemis_aidat_borcu = double.parse(urd["odenmemis_aidat_borcu"].toString());
    uld.odenmemis_aidat_syisi = int.parse(urd["odenmemis_aidat_syisi"].toString());
    uld.seviye = urd["seviye"];
    uld.son_keiko = urd["son_keiko"] == null ? DateTime.now() : DateTime.parse(urd["son_keiko"].toString());
    uld.son3Ay = int.parse(urd["son3Ay"].toString());
    uld.uye_id = int.parse(urd["uye_id"].toString());
    uld.image_type = urd["image_type"];
    String? image = urd["image"];
    if (image != null && image.isNotEmpty) {
      uld.image = base64Decode(urd["image"]);
    } else {
      uld.image = null;
    }

    l.add(uld);
  }
  return l;
}

Future<UyeBilgi> uyeBilgi(Api api, {int uye_id = 0}) async {
  UyeBilgi ub = UyeBilgi();

  dynamic r = await api.call("/admin/uye/$uye_id");
  ub.ad = r[0][0]["ad"];
  ub.email = r[0][0]["email"];
  ub.cinsiyet = r[0][0]["cinsiyet"];
  ub.dogum_tarih = (r[0][0]["dogum_tarih"] == null ? DateTime.now() : DateTime.parse(r[0][0]["dogum_tarih"]));
  ub.dosya_id = r[0][0]["dosya_id"] == null ? 0 : int.parse(r[0][0]["dosya_id"]);
  ub.durum = r[0][0]["durum"];
  ub.ekfno = r[0][0]["ekfno"] ?? "";
  ub.son3Ay = int.parse(r[0][0]["son3Ay"] ?? "0");

  ub.file_type = r[0][0]["file_type"] ?? "";
  ub.image = r[0][0]["img64"] == null ? null : base64Decode(r[0][0]["img64"]);
  ub.tahkkuk = r[0][0]["tahakkuk"] ?? "";
  ub.tahakkuk_id = int.parse(r[0][0]["tahakkuk_id"]);
  for (final s in r[1]) {
    UyeSeviye us = UyeSeviye();
    us.aciklama = s["aciklama"] ?? "";
    us.deger = int.parse(s["deger"] ?? "0");
    us.tarih = DateTime.parse(s["tarih"]);
    us.seviye = s["seviye"];
    ub.seviyeler.add(us);
  }

  ub.eksik_tahakkuk = 0;
  for (final t in r[2]) {
    UyeTahakkuk ut = UyeTahakkuk();
    ut.ay = int.parse(t["ay"] ?? "0");
    ut.borc = double.parse(t["borc"] ?? "0");
    ut.kasa = t["kasa"] ?? "";
    ut.muhasebe_id = int.parse(t["muhasebe_id"] ?? "0");
    ut.odenen = double.parse(t["odenen"] ?? "0");
    ut.odenme_tarih = t["odenme_tarih"] == null ? null : DateTime.parse(t["odenme_tarih"]);
    ut.tahakkuk_tarih = DateTime.parse(t["tahakkuk_tarih"]);
    ut.tahsilatci = t["tahsilatci"] ?? "";
    ut.tanim = t["tanim"] ?? "--";
    ut.uye_tahakkuk_id = int.parse(t["uye_tahakkuk_id"]);
    ut.yil = int.parse(t["yil"] ?? "0");
    ut.yoklama = t["yoklama"] ?? "";
    ut.yoklama_id = int.parse(t["yoklama_id"] ?? "0");

    ub.tahakuklar.add(ut);
    ub.eksik_tahakkuk += t["muhasebe_id"] == null ? 1 : 0;
  }

  for (final y in r[3]) {
    UyeYoklama uy = UyeYoklama();
    DateTime dt = DateTime.parse(y["tarih"]!);
    uy.tanim = y["tanim"] ?? "";
    uy.tarih = dt;
    uy.yoklama_id = int.parse(y["yoklama_id"]);
    uy.ayyilid = "${dt.month},${dt.year},${uy.yoklama_id}";
    ub.yoklamalar.add(uy);
  }
  return ub;
}

Future<void> parolaDegistir(Api api, {required String oldpass, required String newpass}) async {
  //String json = jsonEncode({oldpass,newpass});
  await api.call("/member/password", data: {"oldpass": oldpass, "newpass": newpass});
}

Future<Sabitler> sabitGetir(Api api) async {
  dynamic r = await api.call("/admin/sabitler");
  List<Tahakkuk> tlist = [];
  for (final t in r["tahakkuklar"]) {
    Tahakkuk tahakkuk = Tahakkuk();
    tahakkuk.tahakkuk_id = int.parse(t["tahakkuk_id"]);
    tahakkuk.tanim = t["tanim"];
    tahakkuk.tutar = double.parse(t["tutar"]);
    tlist.add(tahakkuk);
  }
  Sabitler s = Sabitler();
  s.tatakkuklar = tlist;
  return s;
}

typedef UpdateParentData = void Function(UyeBilgi ub, bool reload);

Color tileColorByIndex(int index) {
  return index % 2 == 1 ? const Color.fromARGB(255, 208, 224, 233) : const Color.fromARGB(255, 229, 233, 208);
}

String trAy(int index) {
  return ["Ocak", "??ubat", "Mart", "Nisan", "May??s", "Haziran", "Temmuz", "A??ustos", "Eyl??l", "Ekim", "Kas??m", "Aral??k"][index % 12];
}
