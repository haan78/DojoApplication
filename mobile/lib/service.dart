// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:core';
import 'package:dojo_mobile/page/appwindow.dart';
import 'package:flutter/services.dart';
import 'api.dart';

class UyeSeviye {
  DateTime tarih = DateTime.now();
  String aciklama = "";
  int deger = 0;
  String seviye = "";
}

class UyeTahakkuk {
  int uye_tahakkuk_id = 0;
  int tahakkuk_id = 0;
  int yil = 0;
  int ay = 0;
  DateTime tahakkuk_tarih = DateTime.now();
  int muhasebe_id = 0;
  DateTime? odeme_tarih;
  String tanim = "";
  double borc = 0;
  double odenen = 0;
  String kasa = "";
  String tahsilatci = "";
  String yoklama = "";
  int yoklama_id = 0;
  String aciklama = "";
  List<DateTime> keikolar = [];
}

class MuhasebeDiger {
  int muhasebe_id = 0;
  int muhasebe_tanim_id = 0;
  String tanim = "";
  String aciklama = "";
  String kasa = "";
  DateTime tarih = DateTime.now();
  double tutar = 0;
  String belge = "";
}

class MuhasebeTanim {
  int muhasebe_tanim_id = 0;
  String tanim = "";
  String tur = "";
}

class UyeYoklama {
  DateTime tarih = DateTime.now();
  String tanim = "";
  int yoklama_id = 0;
  String ayyilid = "";
}

class UyeBilgi {
  int uye_id = 0;
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
  int son3Ay = 0;
  List<UyeSeviye> seviyeler = [];
  List<UyeTahakkuk> tahakkuklar = [];
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

class Yoklama {
  int yoklama_id = 0;
  String tanim = "";
}

class Sabitler {
  List<Tahakkuk> tahakkuklar = [];
  List<Yoklama> yoklamalar = [];
  List<MuhasebeTanim> muhasebeTanimlar = [];
}

class Keiko {
  DateTime tarih = DateTime.now();
  int sayi = 0;
  int yoklama_id = 0;
  String tanim = "";
}

class KeikoListe {
  List<KeikoKendoka> list = [];
  int katilanSayisi = 0;
}

class KeikoKendoka {
  String ad = "";
  int uye_id = 0;
  bool katilim = false;
  String file_type = "";
  Uint8List? image;
}

class KyuOneri {
  String ad = "";
  String sinav = "";
  int sayi = 0;
  bool kabuledildi = false;
}

class GelirGiderAylik {
  int yil = 0;
  int ay = 0;
  double net = 0;
  double gelir = 0;
  double gider = 0;
  double aidat = 0;
  double digergelir = 0;
}

class YoklamaAylik {
  int yil = 0;
  int ay = 0;
  double ortalama = 0;
  int alt = 0;
  int ust = 0;
  int keiko = 0;
}

class SeviyeRap {
  String seviye = "";
  int erkekSayi = 0;
  int kadinSayi = 0;
  int genelSayi = 0;
  double erkekOrt = 0;
  double kadinOrt = 0;
  double genelOrt = 0;
}

class GenelRap {
  int uye_id = 0;
  String ad = "";
  String email = "";
  String cinsiyet = "";
  DateTime dogum_tarih = DateTime.now();
  String ekfno = "";
  String durum = "";
  String tahakkuk = "";
  String seviye = "";
  DateTime? sinav_tarih;
  double borc_tutar = 0;
  int borc_sayi = 0;
  int devam_sayi = 0;
  DateTime? ilk;
  DateTime? son;
}

class SeviyeBildirim {
  String ad = "";
  String ekfno = "";
  DateTime dogum_tarih = DateTime.now();
  String seviye = "";
  DateTime tarih = DateTime.now();
  String aciklama = "";
}

class GelirGiderDetay {
  DateTime tarih = DateTime.now();
  String tanim = "";
  String tur = "";
  String ad = "";
  double tutar = 0;
  String kasa = "";
  String tahsilatci = "";
  String aciklama = "";
}

Future<List<UyeListDetay>> uye_listele(Api api,
    {required String durumlar}) async {
  dynamic r =
      await api.call("/admin/uyeler", data: {"durumlar": durumlar}, tryit: 5);

  List<UyeListDetay> l = [];
  for (final urd in r) {
    UyeListDetay uld = UyeListDetay();
    uld.ad = urd["ad"];
    uld.dosya_id = int.parse(urd["dosya_id"].toString());
    uld.odenmemis_aidat_borcu =
        double.parse(urd["odenmemis_aidat_borcu"].toString());
    uld.odenmemis_aidat_syisi =
        int.parse(urd["odenmemis_aidat_syisi"].toString());
    uld.seviye = urd["seviye"];
    uld.son_keiko = urd["son_keiko"] == null
        ? DateTime.now()
        : DateTime.parse(urd["son_keiko"].toString());
    uld.son3Ay = int.parse(urd["son3Ay"].toString());
    uld.uye_id = int.parse(urd["uye_id"].toString());
    uld.image_type = urd["image_type"] ?? "";
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
  dynamic r;
  try {
    r = await api.call("/admin/uye/$uye_id");
  } catch (err) {
    Future.error(err.toString());
  }

  ub.uye_id = uye_id;
  ub.ad = r[0][0]["ad"];
  ub.email = r[0][0]["email"];
  ub.cinsiyet = r[0][0]["cinsiyet"];
  ub.dogum_tarih = (r[0][0]["dogum_tarih"] == null
      ? DateTime.now()
      : DateTime.parse(r[0][0]["dogum_tarih"]));
  ub.dosya_id =
      r[0][0]["dosya_id"] == null ? 0 : int.parse(r[0][0]["dosya_id"]);
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

  for (final y in r[2]) {
    //3
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

Future<void> parolaDegistir(Api api,
    {required String oldpass, required String newpass}) async {
  //String json = jsonEncode({oldpass,newpass});
  await api
      .call("/member/password", data: {"oldpass": oldpass, "newpass": newpass});
}

Future<Sabitler> sabitGetir(Api api) async {
  dynamic r;
  Sabitler sabitler = Sabitler();
  try {
    r = await api.call("/admin/sabitler");
  } catch (err) {
    Future.error(err.toString());
    return sabitler;
  }
  for (final t in r["tahakkuklar"]) {
    Tahakkuk tahakkuk = Tahakkuk();
    tahakkuk.tahakkuk_id = int.parse(t["tahakkuk_id"]);
    tahakkuk.tanim = t["tanim"];
    tahakkuk.tutar = double.parse(t["tutar"]);
    sabitler.tahakkuklar.add(tahakkuk);
  }
  for (final y in r["yoklamalar"]) {
    Yoklama yoklama = Yoklama();
    yoklama.yoklama_id = int.parse(y["yoklama_id"]);
    yoklama.tanim = y["tanim"];
    sabitler.yoklamalar.add(yoklama);
  }
  for (final mtraw in r["muhasebe_tanimlar"]) {
    MuhasebeTanim mt = MuhasebeTanim();
    mt.muhasebe_tanim_id = int.parse(mtraw["muhasebe_tanim_id"]);
    mt.tanim = mtraw["tanim"];
    mt.tur = mtraw["tur"];
    sabitler.muhasebeTanimlar.add(mt);
  }

  return sabitler;
}

Future<void> uyeSeviyeEkle(Api api,
    {required int uye_id, required UyeSeviye us}) async {
  await api.call("/admin/uye/seviye/ekle/$uye_id", data: {
    "seviye": us.seviye,
    "tarih": dateFormater(us.tarih, "yyyy-MM-dd"),
    "aciklama": us.aciklama
  });
}

Future<void> uyeSeviyeSil(Api api,
    {required int uye_id, required UyeSeviye us}) async {
  await api.call("/admin/uye/seviye/sil/$uye_id", data: {"seviye": us.seviye});
}

Future<void> epostaTest(Api api, {required int uye_id}) async {
  await api.call("/admin/uye/epostatest/$uye_id");
}

Future<int> uyeKayit(Api api, {required UyeBilgi ub}) async {
  dynamic response = await api.call("/admin/uye/kayit/${ub.uye_id}", data: {
    "ad": ub.ad,
    "tahakkuk_id": ub.tahakkuk_id,
    "email": ub.email,
    "cinsiyet": ub.cinsiyet,
    "dogum": dateFormater(ub.dogum_tarih, "yyyy-MM-dd"),
    "ekfno": ub.ekfno,
    "durum": ub.durum,
    "dosya": base64.encode(ub.image!),
    "file_type": ub.file_type
  });
  final int uye_id = int.parse(response as String);
  if (ub.durum == "registered") {
    await epostaTest(api, uye_id: uye_id);
  }
  return uye_id;
}

Future<int> uyeYoklama(Api api,
    {required int yoklama_id,
    required int uye_id,
    required DateTime tarih}) async {
  dynamic response = await api.call(
      "/admin/uye/yoklama/$yoklama_id/$uye_id/${dateFormater(tarih, "yyyy-MM-dd")}");
  final int result = int.parse(response[0][0]["result"] as String);
  return result;
}

Future<List<Keiko>> yoklamalar(Api api) async {
  List<Keiko> l = [];
  dynamic response;
  try {
    response = await api.call("/admin/yoklamalar");
  } catch (err) {
    return Future.error(err.toString());
  }

  for (final k in response) {
    Keiko keiok = Keiko();
    keiok.yoklama_id = int.parse(k["yoklama_id"]);
    keiok.tanim = k["tanim"];
    keiok.sayi = k["sayi"] as int;
    keiok.tarih = DateTime.parse(k["tarih"]!);
    l.add(keiok);
  }
  return l;
}

Future<KeikoListe> yoklamaliste(Api api,
    {required int yoklama_id, required DateTime tarih}) async {
  List<KeikoKendoka> l = [];
  dynamic response;
  try {
    response = await api.call(
        "/admin/uye/yoklama/liste/$yoklama_id/${dateFormater(tarih, "yyyy-MM-dd")}");
  } catch (err) {
    return Future.error(err);
  }

  int katilim = 0;
  for (final kk in response) {
    KeikoKendoka kendoka = KeikoKendoka();
    kendoka.ad = kk["ad"];
    if (kk["icerik"] != null && kk["file_type"] != null) {
      kendoka.file_type = kk["file_type"];
      kendoka.image = base64Decode(kk["icerik"]);
    } else {
      kendoka.image =
          (await rootBundle.load("assets/kendoka.jpg")).buffer.asUint8List();
      kendoka.file_type = "image/jpeg";
    }

    kendoka.uye_id = kk["uye_id"];
    kendoka.katilim = kk["katilim"] == 1 ? true : false;
    l.add(kendoka);
    if (kendoka.katilim) {
      katilim++;
    }
  }
  KeikoListe kl = KeikoListe();
  kl.list = l;
  kl.katilanSayisi = katilim;
  return kl;
}

Future<List<UyeTahakkuk>> uyetahakkuklist(Api api,
    {required int uye_id}) async {
  List<UyeTahakkuk> l = [];
  dynamic response;
  try {
    response = await api.call("/admin/uye/tahakkuk/list/$uye_id");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    UyeTahakkuk ut = UyeTahakkuk();
    ut.ay = raw["ay"] as int;
    ut.borc = double.parse(raw["borc"] ?? "0");
    ut.kasa = raw["kasa"] ?? "";
    ut.muhasebe_id = raw["muhasebe_id"] != null ? raw["muhasebe_id"] as int : 0;
    ut.odenen = double.parse(raw["odeme_tutar"] ?? "0");
    ut.odeme_tarih =
        raw["odeme_tarih"] == null ? null : DateTime.parse(raw["odeme_tarih"]);
    ut.tahakkuk_tarih = DateTime.parse(raw["tahakkuk_tarih"]);
    ut.tahsilatci = raw["tahsilatci"] ?? "";
    ut.tanim = raw["tanim"] ?? "--";
    ut.uye_tahakkuk_id = raw["uye_tahakkuk_id"] as int;
    ut.yil = raw["yil"] as int;
    ut.yoklama = raw["yoklama"] ?? "";
    ut.yoklama_id = raw["yoklama_id"] as int;
    ut.aciklama = raw["aciklama"] ?? "";
    ut.tahakkuk_id = raw["tahakkuk_id"] as int;
    if (raw["keikolar"] != null) {
      String keikolar = raw["keikolar"] as String;
      final keikolarlist = keikolar.split(",");
      for (final keikot in keikolarlist) {
        ut.keikolar.add(DateTime.parse(keikot.trim()));
      }
    }
    l.add(ut);
  }
  return l;
}

Future<int> aidatodemeal(Api api, UyeTahakkuk ut, int uye_id) async {
  final result = await api.call("/admin/muhasebe/aidatal", data: {
    "uye_id": uye_id,
    "tutar": ut.odenen,
    "tarih": dateFormater(ut.odeme_tarih!, "yyyy-MM-dd"),
    "kasa": ut.kasa,
    "aciklama": ut.aciklama.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
    "ay": ut.ay,
    "yil": ut.yil,
    "yoklama_id": ut.yoklama_id
  });
  return result as int;
}

Future<int> digerodemeal(Api api, MuhasebeDiger muh, int uye_id,
    {bool negative = false}) async {
  final result = await api.call("/admin/muhasebe/duzelt", data: {
    "uye_id": uye_id,
    "tutar": negative ? -1 * muh.tutar : muh.tutar,
    "tarih": dateFormater(muh.tarih, "yyyy-MM-dd"),
    "kasa": muh.kasa,
    "muhasebe_tanim_id": muh.muhasebe_tanim_id,
    "aciklama": muh.aciklama.replaceAll(RegExp(r'[^\x20-\x7E]'), ''),
    "muhasebe_id": muh.muhasebe_id,
    "belge": muh.belge.trim().isEmpty ? null : muh.belge.trim()
  });
  return result as int;
}

Future<void> aidatodemesil(Api api, int muhasebei_id) async {
  await api.call("/admin/muhasebe/aidatodemesil/$muhasebei_id");
}

Future<void> aidatsil(Api api, int uye_tahakkuk_id) async {
  await api.call("/admin/muhasebe/aidatsil/$uye_tahakkuk_id");
}

Future<void> odemesil(Api api, int muhasebei_id) async {
  await api.call("/admin/muhasebe/sil/$muhasebei_id");
}

Future<List<MuhasebeDiger>> uyedigerodemelist(Api api, int uye_id) async {
  List<MuhasebeDiger> l = [];
  dynamic response;
  try {
    response = await api.call("/admin/uye/muhasebe/digerlist/$uye_id");
  } catch (err) {
    return Future.error(err);
  }

  for (final mdr in response) {
    final md = MuhasebeDiger();
    md.muhasebe_id = mdr["muhasebe_id"] as int;
    md.aciklama = mdr["aciklama"];
    md.kasa = mdr["kasa"];
    md.tanim = mdr["tanim"];
    md.muhasebe_tanim_id = mdr["muhasebe_tanim_id"] as int;
    md.tarih = DateTime.parse(mdr["tarih"]);
    md.tutar = double.parse(mdr["tutar"] ?? "0");
    md.belge = mdr["tutar"] ?? "";
    l.add(md);
  }
  return l;
}

Future<List<MuhasebeDiger>> uyeharcamalist(Api api, int uye_id) async {
  List<MuhasebeDiger> l = [];
  dynamic response;
  try {
    response = await api.call("/admin/uye/muhasebe/harcamalist/$uye_id");
  } catch (err) {
    return Future.error(err);
  }
  for (final mdr in response) {
    final md = MuhasebeDiger();
    md.muhasebe_id = mdr["muhasebe_id"] != null ? mdr["muhasebe_id"] as int : 0;
    md.aciklama = mdr["aciklama"] ?? "";
    md.kasa = mdr["kasa"] ?? "";
    md.tanim = mdr["tanim"];
    md.muhasebe_tanim_id =
        mdr["muhasebe_tanim_id"] != null ? mdr["muhasebe_tanim_id"] as int : 0;
    md.tarih = DateTime.parse(mdr["tarih"]);
    md.tutar = -1 * double.parse(mdr["tutar"] ?? "0");
    md.belge = mdr["belge"] ?? "";
    l.add(md);
  }
  return l;
}

Future<void> kyuoneri(Api api, List<KyuOneri> list) async {
  list.clear();
  dynamic response;
  try {
    response = await api.call("/admin/kyu/oneri");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final ko = KyuOneri();
    ko.ad = raw["ad"];
    ko.sayi = int.parse(raw["sayi"]);
    ko.sinav = raw["sinav"];
    ko.kabuledildi = (ko.sayi >= 12);
    list.add(ko);
  }
}

Future<void> rapor_gelirgiderAylik(Api api, List<GelirGiderAylik> list) async {
  list.clear();
  dynamic response;
  try {
    response = await api.call("/admin/rapor/gelirgider");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = GelirGiderAylik();
    obj.ay = int.parse(raw["_ay"]);
    obj.yil = int.parse(raw["_yil"]);
    obj.gelir = double.parse(raw["gelir"]);
    obj.gider = double.parse(raw["gider"]);
    obj.aidat = double.parse(raw["aidat"]);
    obj.digergelir = obj.gelir - obj.aidat;
    obj.net = obj.gelir + obj.gider;
    list.add(obj);
  }
}

Future<void> rapor_aylikyoklama(
    Api api, int yoklama_id, List<YoklamaAylik> list) async {
  list.clear();
  dynamic response;
  try {
    response = await api.call("/admin/rapor/aylikyoklama/$yoklama_id");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = YoklamaAylik();
    obj.ay = int.parse(raw["_ay"]);
    obj.yil = int.parse(raw["_yil"]);
    obj.ortalama = double.parse(raw["ortalama"]);
    obj.alt = int.parse(raw["alt"]);
    obj.ust = int.parse(raw["ust"]);
    obj.keiko = int.parse(raw["keiko"]);
    list.add(obj);
  }
}

Future<void> rapor_seviye(Api api, List<SeviyeRap> list) async {
  list.clear();
  dynamic response;
  try {
    response = await api.call("/admin/rapor/seviye");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = SeviyeRap();
    obj.seviye = raw["seviye"];
    obj.genelSayi = int.parse(raw["genel_sayi"]);
    obj.erkekSayi = int.parse(raw["erkek_sayi"]);
    obj.kadinSayi = int.parse(raw["kadin_sayi"]);
    obj.genelOrt = double.parse(raw["genel_ort"]);
    obj.erkekOrt = double.parse(raw["erkek_ort"]);
    obj.kadinOrt = double.parse(raw["kadin_ort"]);
    list.add(obj);
  }
}

Future<void> rapor_seviyebildirim(Api api, List<SeviyeBildirim> list) async {
  list.clear();
  dynamic response;
  try {
    response = await api.call("/admin/rapor/seviyebildirim");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = SeviyeBildirim();
    obj.ad = raw["ad"];
    obj.aciklama = raw["aciklama"] ?? "";
    obj.dogum_tarih = DateTime.parse(raw["dogum_tarih"]);
    obj.ekfno = raw["ekfno"] ?? "";
    obj.seviye = raw["seviye"] ?? "";
    obj.tarih = DateTime.parse(raw["tarih"]);
    list.add(obj);
  }
}

Future<void> rapor_gelirgider_detay(Api api, DateTime baslangic, DateTime bitis,
    List<GelirGiderDetay> list) async {
  list.clear();
  dynamic response;
  try {
    final bas = dateFormater(baslangic, "yyyy-MM-dd");
    final bit = dateFormater(bitis, "yyyy-MM-dd");
    response = await api.call("/admin/rapor/gelirgiderdetay/$bas/$bit");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = GelirGiderDetay();
    obj.aciklama = raw["aciklama"] ?? "";
    obj.ad = raw["ad"] ?? "";
    obj.kasa = raw["kasa"] ?? "";
    obj.tahsilatci = raw["tahsilatci"] ?? "";
    obj.tanim = raw["tanim"] ?? "";
    obj.tarih = DateTime.parse(raw["tarih"]);
    obj.tur = raw["tur"] ?? "";
    obj.tutar = double.parse(raw["tutar"]);
    list.add(obj);
  }
}

Future<List<GenelRap>> rapor_geneluyeraporu(Api api) async {
  List<GenelRap> list = [];
  dynamic response;
  try {
    response = await api.call("/admin/rapor/geneluyeraporu");
  } catch (err) {
    return Future.error(err);
  }
  for (final raw in response) {
    final obj = GenelRap();
    obj.ad = raw["ad"] ?? "";
    obj.borc_sayi = int.parse(raw["borc_sayi"]);
    obj.borc_tutar = double.parse(raw["borc_tutar"]);
    obj.cinsiyet = raw["cinsiyet"] ?? "";
    obj.devam_sayi = int.parse(raw["devam_sayi"]);
    obj.dogum_tarih = DateTime.parse(raw["dogum_tarih"]);
    obj.durum = raw["durum"] ?? "";
    obj.ekfno = raw["ekfno"] ?? "";
    obj.ilk = raw["ilk"] != null ? DateTime.parse(raw["ilk"]) : null;
    obj.son = raw["son"] != null ? DateTime.parse(raw["son"]) : null;
    obj.seviye = raw["seviye"] ?? "";
    obj.sinav_tarih =
        raw["sinav_tarih"] != null ? DateTime.parse(raw["sinav_tarih"]) : null;
    obj.tahakkuk = raw["tahakkuk"] ?? "";
    obj.uye_id = int.parse(raw["uye_id"]);
    list.add(obj);
  }
  return list;
}
