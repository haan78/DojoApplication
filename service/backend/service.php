<?php

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./db.php";
require_once("./hcaptcha.php");

use Minmi\Response;
use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function tokenPars(string &$token) {
    $payload = null;
    try {
        $payload = \Firebase\JWT\JWT::decode($token, $_ENV["JWT_KEY"], array('HS256'));
    } catch (Exception $ex) {
        throw new MinmiExeption($ex->getMessage(),401);
    }
    
    if (property_exists($payload, "exp") && property_exists($payload, "uye_id") && property_exists($payload, "durum")) {
        $payload->exp = time() + $_ENV["TOKEN_TIME"];
        $token = \Firebase\JWT\JWT::encode($payload, $_ENV["JWT_KEY"], 'HS256');
        return [
            "uye_id" => $payload->uye_id,
            "durum" => $payload->durum
        ];
    } else {
        throw new MinmiExeption("Token does not contain necessary values");
    }
}

$router = new DefaultJsonRouter("", function (Request $req, Response $res) {
    return;
    $urlpattern = $req->getUriPattern();
    $token = $req->getBearerToken();

    if ($token) {
        $user = tokenPars($token);
        $durum = $user["durum"];
        if ( $durum == "passive" ) {
            throw new MinmiExeption("Membership is passive", 401);
        }
        if (str_starts_with($urlpattern, "/admin") && !in_array($durum, ["admin", "super-admin"])) {
            throw new MinmiExeption("Unauthorized request for admin action", 401);
        }
        $req->setLocal((object)$user);
    } elseif ( !in_array($urlpattern,["/token","/email","/reset"]) ) {
        throw new MinmiExeption("Unauthorized required", 401);
    }
    
});

$router->add("/email", function (Request $request) {
    $jdata = $request->json();
    $captcha = $jdata->captcha ?? "";
    $email = $jdata->email ?? "";

    if ($captcha && $email) {
        if (hcaptcha($captcha)) {
            create_identity(0, $email, $ad, $code);
            sendinblue($email, 3, (object)[
                "AD" => $ad,
                "URL" => $_ENV["SERVICE_ROOT"] . "/index.php?m=reset?code=$code"
            ]);
        } else {
            throw new MinmiExeption("Captcha is wrong", 401);
        }
    } else {
        throw new MinmiExeption("Email and captcha are required", 400);
    }
});

$router->add("/reset", function (Request $request) {
    $jdata = $request->json();
    $captcha = $jdata->captcha ?? "";
    $code = $jdata->code ?? "";
    $pass = $jdata->password ?? "";
    if ($captcha && $code) {
        if (hcaptcha($captcha)) {
            reset_password($code, $pass);
        } else {
            throw new MinmiExeption("Captcha is wrong", 401);
        }
    } else {
        throw new MinmiExeption("Activation is required", 400);
    }
});

$router->add("/token", function (Request $request) {
    $jdata = $request->json();
    $captcha = $jdata->captcha ?? "";
    $type = $jdata->type ?? "";
    $username = $password = "";    
    if ($request->hasBasicAuth($username, $password) && $captcha) {
        if (hcaptcha($captcha)) {
            //echo "$username / $password";
            $user = validate(trim($username), trim($password), trim($type));
            if (!is_null($user)) {
                $payload = [
                    "exp" => time() + $_ENV["TOKEN_TIME"],
                    "durum" => $user["durum"],
                    "uye_id" => $user["uye_id"]
                ];
                $token = \Firebase\JWT\JWT::encode($payload, $_ENV["JWT_KEY"], 'HS256');
                return [
                    "ad" => $user["ad"],
                    "uye_id" => $user["uye_id"],
                    "dosya_id" => $user["dosya_id"],
                    "email" => trim($username),
                    "durum" => $user["durum"],
                    "token" => $token
                ];
            } else {
                throw new MinmiExeption("Username or password is wrong", 402);
            }
        } else {
            throw new MinmiExeption("Captcha is wrong", 401);
        }
    } else {
        throw new MinmiExeption("Username, password and captcha are required", 400);
    }
});

$router->add("/admin/uye/#uye_id", function (Request $req) {
    return uye($req->params()["uye_id"]);
});

$router->add("/admin/uyeler",function(Request $req){
    $jdata = $req->json();    
    return uye_listele($jdata->durumlar);
});

$router->add("/admin/uye/kayit/#uye_id",function(Request $req) {
    $jdata = $req->json(); 
    $uye_id = $req->params()["uye_id"];
    return uye_eke($uye_id,$jdata->ad,$jdata->tahakkuk_id,$jdata->email,$jdata->cinsiyet,$jdata->dogum,$jdata->ekfno,$jdata->durum,$jdata->dosya,$jdata->file_type);
});

$router->add("/admin/uye/epostatest/#uye_id",function(Request $req) {
    $uye_id = intval($req->param("uye_id"));
    $ad = $email = $code = $err = "";
    if (uye_eposta_onkayit($uye_id,$ad,$email,$code,$err)) {
        sendinblue($email, 1, (object)[
            "AD" => $ad,
            "URL" => $_ENV["SERVICE_ROOT"] . "/backend/index.php?m=activate&code=$code"
        ]);
    } else {
        throw new Exception($err);
    }
});


$router->add("/admin/uye/seviye/ekle/#uye_id", function (Request $req) {
    $uye_id = $req->params()["uye_id"];
    $jdata = $req->json();
    if (!seviye_ekle($uye_id, $jdata->seviye, $jdata->tarih, $jdata->aciklama, $err)) {
        throw new Exception($err);
    }
});

$router->add("/admin/uye/seviye/sil/#uye_id", function (Request $req) {
    $uye_id = $req->param("uye_id");
    $jdata = $req->json();
    if (!seviye_sil($uye_id, $jdata->seviye, $err)) {
        throw new Exception($err);
    }
});

$router->add("/admin/uye/yoklama/#yoklama_id/#uye_id/@tarih", function (Request $req) {
    $yoklama_id = $req->param("yoklama_id");
    $uye_id = $req->param("uye_id");
    $tarih = $req->param("tarih");
    //var_dump([$yoklama_id,$uye_id,$tarih]);
    return uye_yoklama_eklesil($yoklama_id,$uye_id,$tarih);

});

$router->add("/admin/uye/tahakkuk/list/#uye_id",function(Request $req){
    $uye_id = $req->param("uye_id");
    return uyetahakkuklist($uye_id);
});

$router->add("/admin/uye/muhasebe/digerlist/#uye_id",function(Request $req) {
    $uye_id = $req->param("uye_id");
    return uyedigerodemelist($uye_id);
});
$router->add("/admin/uye/muhasebe/harcamalist/#uye_id",function(Request $req) {
    $uye_id = $req->param("uye_id");
    return uyeharcamalist($uye_id);
});


$router->add("/admin/muhasebe/aidatal",function(Request $req){
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

$router->add("/admin/muhasebe/aidatodemesil/#muhasebe_id",function(Request $req){
    $muhasebe_id = $req->param("muhasebe_id");
    return aidat_odeme_sil($muhasebe_id);
});

$router->add("/admin/muhasebe/aidatsil/#uye_tahakkuk_id",function(Request $req){
    $uye_tahakkuk_id = $req->param("uye_tahakkuk_id");
    return aidat_sil($uye_tahakkuk_id);
});

$router->add("/admin/muhasebe/sil/#muhasebe_id",function(Request $req){
    $muhasebe_id = $req->param("muhasebe_id");
    return muhasebe_sil($muhasebe_id);
});

$router->add("/admin/muhasebe/duzelt",function(Request $req){
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


$router->add("/admin/yoklamalar", function (Request $req) {    
    return yoklamalar();
});

$router->add("/admin/uye/yoklama/liste/#yoklama_id/@tarih", function (Request $req) {
    $yoklama_id = $req->param("yoklama_id");
    $tarih = $req->param("tarih");
    return yoklamaliste($yoklama_id,$tarih);
});



$router->add("/admin/download/#dosya_id", function (Request $req) {
    return download(intval($req->params()["dosya_id"]));
});

$router->add("/admin/upload", function () {
    if (!empty($_FILES)) {
        $f = $_FILES[array_key_first($_FILES)];
        if ($f["error"] == UPLOAD_ERR_OK) {
            $file_type = mime_content_type($f["tmp_name"]);
            $stream = fopen($f["tmp_name"], 'r');
            if ($stream) {
                $icerik = base64_encode(stream_get_contents($stream, -1, 0));
                $dosya_id = upload($icerik, $file_type);
                fclose($stream);
                return $dosya_id;
            } else {
                throw new Exception("Upload file can't read");
            }
        } else {
            throw new Exception("Upload error");
        }
    } else {
        throw new Exception("No Upload file");
    }
});

$router->add("admin/sabitler",function(){
    return sabitler();
});

$router->add("/member/password", function (Request $req) {
    $uye_id = $req->local()->uye_id;
    $params = $req->json();
    if (!password($uye_id, $params->oldpass, $params->newpass, $err)) {
        throw new MinmiExeption($err,401);
    }
});

$router->add("/member/foto", function (Request $req) {
    return download($req->local()->dosya_id);
});

$router->add("/member/bilgi", function (Request $req) {
    return uye($req->local()->uye_id);
});

$router->add("/member/email", function (Request $req) {
    $params = $req->json();
    $email = $params->email;
    create_identity($req->local()->uye_id, $email, $ad, $code);
    sendinblue($email, 3, (object)[
        "AD" => $ad,
        "URL" => $_ENV["SERVICE_ROOT"] . "/backend/index.php?m=reset&code=$code"
    ]);
});

$router->add("/admin/kyu/oneri",function(Request $req){
    return kyu_oneri();
});

(Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env"))->load();
$router->execute();
