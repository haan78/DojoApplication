// ignore_for_file: non_constant_identifier_names

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
  DateTime dogum_tarih = DateTime.now();
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
  //int dosya_id = 0;
  String seviye = "";
  int odenmemis_aidat_syisi = 0;
  double odenmemis_aidat_borcu = 0;
  DateTime son_keiko = DateTime.now();
  int son3Ay = 0;
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

class EldenTahsilat {
  String ad = "";
  DateTime tarih = DateTime.now();
  double tutar = 0;
  String tanim = "";
  int ay = 0;
  int yil = 0;
  String aciklama = "";
  DateTime zaman = DateTime.now();
}

class MacCalismasiKendocu {
  int uye_id = 0;
  String ad = "";
  String seviye = "";
  DateTime tarih = DateTime.now();
  String cinsiyet = "";
  int yas = 0;
  bool secildi = true;
}

class MacCalismasiKayit {
  int yoklama_id = 0;
  int aka = 0;
  int shiro = 0;
  String tur = "";
  DateTime tarih = DateTime.now();
  String aka_ippon = "";
  String shiro_ippon = "";
  int aka_hansoku = 0;
  int shiro_hansoku = 0;
}

class MacCalismasiIcinYoklama {
  DateTime tarih = DateTime.now();
  bool macyaipmis = false;
}
