<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function authAdmin(Request $req): void
{
    $token = $req->getBearerToken();
    if ($token=="labidur" && APP_MODE == "development") {
        $req->setLocal((object)[
            "uye_id" => 1,
            "durum" => "super-admin",
            "ad" => "Sensei"
        ]);
        return;
    }
    if (empty($token)) {
        throw new MinmiExeption("Token is required",401);
    }
    $payload = null;
    try {
        $payload = \Firebase\JWT\JWT::decode($token, $GLOBALS["JWT_KEY"], array('HS256'));
    } catch (Exception $ex) {
        throw new MinmiExeption($ex->getMessage(), 401);
    }

    if (property_exists($payload, "exp") && property_exists($payload, "uye_id") && property_exists($payload, "durum")) {
        //$payload->exp = time() + $GLOBALS["TOKEN_TIME"];
        //$token = \Firebase\JWT\JWT::encode($payload, $GLOBALS["JWT_KEY"], 'HS256');
        $req->setLocal((object)[
            "uye_id" => $payload->uye_id,
            "durum" => $payload->durum,
            "ad" => $payload->ad
        ]);
    } else {
        throw new MinmiExeption("Token does not contain necessary values",401);
    }
}

function routerAdmin(DefaultJsonRouter $router)
{
    $router->add("/admin/uye/#uye_id", function (Request $req) {
        return uye($req->params()["uye_id"]);
    });

    $router->add("/admin/uyeler", function (Request $req) {
        $jdata = $req->json();
        return uye_listele($jdata->durumlar);
    });

    $router->add("/admin/uye/kayit/#uye_id", function (Request $req) {
        $jdata = $req->json();
        $uye_id = $req->params()["uye_id"];
        return uye_eke($uye_id, $jdata->ad, $jdata->tahakkuk_id, $jdata->email, $jdata->cinsiyet, $jdata->dogum, $jdata->ekfno, $jdata->durum);
    });

    $router->add("/admin/uye/foto/#uye_id", function (Request $req) {
        $uye_id = $req->params()["uye_id"];
        return uploadUyeFoto($uye_id);
    });

    $router->add("/admin/uye/epostatest/#uye_id", function (Request $req) {
        $uye_id = intval($req->param("uye_id"));
        $ad = $email = $code = $parola = "";
        uye_eposta_onkayit($uye_id, $ad, $email, $code,$parola);
        sendinblue($email, 5, (object)[
            "AD" => $ad,
            "URL" => SERVICE_ROOT. "/activate.php?code=$code",
            "PAROLA" => $parola,
            "EPOSTA" => $email,
            "ADRES" => SERVICE_ROOT
        ]);
    });


    $router->add("/admin/uye/seviye/ekle/#uye_id", function (Request $req) {
        $uye_id = $req->params()["uye_id"];
        $jdata = $req->json();
        seviye_ekle($uye_id, $jdata->seviye, $jdata->tarih, $jdata->aciklama);
    });

    $router->add("/admin/uye/seviye/sil/#uye_id", function (Request $req) {
        $uye_id = $req->param("uye_id");
        $jdata = $req->json();
        seviye_sil($uye_id, $jdata->seviye);
    });

    $router->add("/admin/uye/yoklama/#yoklama_id/#uye_id/@tarih", function (Request $req) {
        $yoklama_id = $req->param("yoklama_id");
        $uye_id = $req->param("uye_id");
        $tarih = $req->param("tarih");
        return uye_yoklama_eklesil($yoklama_id, $uye_id, $tarih);
    });

    $router->add("/admin/uye/tahakkuk/list/#uye_id", function (Request $req) {
        $uye_id = $req->param("uye_id");
        return uyetahakkuklist($uye_id);
    });

    $router->add("/admin/uye/muhasebe/digerlist/#uye_id", function (Request $req) {
        $uye_id = $req->param("uye_id");
        return uyedigerodemelist($uye_id);
    });
    $router->add("/admin/uye/muhasebe/harcamalist/#uye_id", function (Request $req) {
        $uye_id = $req->param("uye_id");
        return uyeharcamalist($uye_id);
    });

    $router->add("/admin/muhasebe/aidatal", function (Request $req) {
        $jdata = $req->json();
        $uye_id = $jdata->uye_id ?? 0;
        $tutar = $jdata->tutar ?? 0;
        $tarih = $jdata->tarih ?? "";
        $kasa = $jdata->kasa ?? "";
        $aciklama = $jdata->aciklama ?? "";
        $tahsilatci = $req->local()->ad ?? "";
        $yoklama_id =  $jdata->yoklama_id ?? 0;
        $yil = $jdata->yil ?? 0;
        $ay = $jdata->ay ?? 0;
        return aidat_odeme_al($uye_id, $yoklama_id, $tarih, $yil, $ay, $kasa, $tutar, $aciklama, $tahsilatci);
    });

    $router->add("/admin/muhasebe/aidatodemesil/#muhasebe_id", function (Request $req) {
        $muhasebe_id = $req->param("muhasebe_id");
        return aidat_odeme_sil($muhasebe_id);
    });

    $router->add("/admin/muhasebe/aidatsil/#uye_tahakkuk_id", function (Request $req) {
        $uye_tahakkuk_id = $req->param("uye_tahakkuk_id");
        return aidat_sil($uye_tahakkuk_id);
    });

    $router->add("/admin/muhasebe/sil/#muhasebe_id", function (Request $req) {
        $muhasebe_id = $req->param("muhasebe_id");
        return muhasebe_sil($muhasebe_id);
    });

    $router->add("/admin/muhasebe/duzelt", function (Request $req) {
        $jdata = $req->json();
        $muhasebe_id = $jdata->muhasebe_id ?? 0;
        $uye_id = $jdata->uye_id ?? 0;
        $tutar = $jdata->tutar ?? null;
        $tarih = $jdata->tarih ?? "";
        $kasa = $jdata->kasa ?? "";
        $aciklama = $jdata->aciklama ?? "";
        $muhasebe_tanim_id = $jdata->muhasebe_tanim_id ?? 0;
        $belge = $jdata->belge ?? null;
        $tahsilatci = $req->local()->ad ?? "";
        return  muhasebe_duzelt($muhasebe_id, $uye_id, $tarih, $tutar, $kasa, $muhasebe_tanim_id, $aciklama, $belge, $tahsilatci);
    });

    $router->add("/admin/muhasebe/tahsilatcilar/@bas/@bit",function(Request $req){
        return tahsilatci_list($req->param("bas"),$req->param("bit"));
    });

    $router->add("/admin/yoklamalar", function (Request $req) {
        return yoklamalar();
    });

    $router->add("/admin/uye/yoklama/liste/#yoklama_id/@tarih", function (Request $req) {
        $yoklama_id = $req->param("yoklama_id");
        $tarih = $req->param("tarih");
        return yoklamaliste($yoklama_id, $tarih);
    });

    $router->add("admin/sabitler", function () {
        return sabitler();
    });

    $router->add("/admin/kyu/oneri", function (Request $req) {
        return kyu_oneri();
    });

    $router->add("/admin/rapor/gelirgider", function (Request $req) {
        return rapor_gelirgider();
    });

    $router->add("/admin/rapor/gelirgiderdetay/@baslangic/@bitis", function (Request $req) {
        return rapor_gelirgider_detay($req->param("baslangic"), $req->param("bitis"));
    });

    $router->add("/admin/rapor/aylikyoklama/#yoklama_id", function (Request $req) {
        return rapor_aylikyoklama($req->param("yoklama_id"));
    });

    $router->add("/admin/rapor/seviye", function (Request $req) {
        return rapor_seviye();
    });

    $router->add("/admin/rapor/seviyebildirim", function (Request $req) {
        return rapor_seviyebildirim();
    });

    $router->add("/admin/rapor/geneluyeraporu", function (Request $req) {
        return rapor_geneluyeraporu();
    });

    $router->add("/admin/rapor/eldentahsilat/@tahsilatci/@baslangic/@bitis", function (Request $req) {
        return rapor_eldentahsilat($req->param("tahsilatci"), $req->param("baslangic"), $req->param("bitis"));
    });

    $router->add("/admin/mac/yoklama10/#yoklama_id",function(Request $req) {
        return yoklama10listesi($req->param("yoklama_id"));
    });

    $router->add("/admin/mac/liste/#yoklama_id/@tarih",function(Request $req) {
        return maccalismasi_listesi($req->param("yoklama_id"),$req->param("tarih"));
    });

    $router->add("/admin/mac/tumunusil/@tarih/#yoklama_id/@tur",function(Request $req) {
        return maccliasmasi_tumunusil($req->param("tarih"),$req->param("yoklama_id"),$req->param("tur"));
    });

    $router->add("/admin/mac/kayit",function(Request $req) {
        $data = $req->json();
        return maccalismasi_kayit($data);
    });

    $router->add("/admin/rapor/mac",function(Request $req){
        return rapor_maccalismasi();
    });

}
