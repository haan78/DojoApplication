<?php

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./db.php";

use Minmi\Response;
use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function tokenPars(string &$token) {
    if ($token) {
        $payload = \Firebase\JWT\JWT::decode($token, $_ENV["JWT_KEY"], array('HS256'));
        if (property_exists($payload, "exp") && property_exists($payload,"uye_id") && property_exists($payload,"durum")) {
            $payload["exp"] = time() + $_ENV["TOKEN_TIME"];
            $token = \Firebase\JWT\JWT::encode($payload, $_ENV["JWT_KEY"], 'HS256');
            return [
                "uye_id" => $payload["uye_id"],            
                "durum" => $payload["durum"]
            ];
        } else {
            throw new MinmiExeption("Token does not contain necessary values");
        }
    } else {
        return null;
    }
    
}

$router = new DefaultJsonRouter("", function (Request $req,Response $res) {

    $urlpattern = $req->getUriPattern();
    $token = $req->getBearerToken();
    $user = tokenPars($token);
    $durum = !is_null($user) ? $user["durum"] : "";

    if (str_starts_with($urlpattern, "/admin") && !in_array($durum,["admin", "super-admin"])) {
        throw new MinmiExeption("Unauthorized request for admin action");
    } elseif (str_starts_with($urlpattern, "/member") && !in_array($durum,["admin", "super-admin", "active"])) {
        throw new MinmiExeption("Unauthorized request");
    }
    $req->setLocal($user);
});

$router->add("/reset-identity",function(Request $request) {
    $jdata = $request->json();
    $captcha = $jdata->captcha ?? "";
    $email = $jdata->captcha ?? "";
    
    
});

$router->add("/token", function (Request $request) {
    $jdata = $request->json();
    $captcha = $jdata->captcha ?? "";
    $username = $password = "";
    if ($request->hasBasicAuth($username, $password) && $captcha) {
        require_once("hcaptcha.php");
        if (hcaptcha($captcha)) {
            $user = validate(trim($username), trim($password));
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

$router->add("admin/uye/#uye_id", function (Request $req) {
    return uye($req->params()["uye_id"]);
});

$router->add("admin/uyeseviyeekle", function (Request $req) {
    $jdata = $req->json();
    if (!seviye_ekle($jdata->uye_id, $jdata->seviye, $jdata->tarih, $jdata->aciklama, $err)) {
        throw new Exception($err);
    }
});

$router->add("admin/uyeseviyesil/#uye_id/@seviye", function (Request $req) {
    $uye_id = $req->params()["uye_id"];
    $seviye = $req->params()["seviye"];
    if (!seviye_sil($uye_id, $seviye, $err)) {
        throw new Exception($err);
    }
});

$router->add("admin/download/#dosya_id", function (Request $req) {
    return download(intval($req->params()["dosya_id"]));
});

$router->add("admin/upload", function () {
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

$router->add("/member/password", function (Request $req) {
    $uye_id = $req->local()->uye_id;
    $params = $req->json();
    if (!password($uye_id, $params->oldpass, $params->newpass, $err)) {
        throw new MinmiExeption($err);
    }
});

$router->add("member/foto", function (Request $req) {
    return download($req->local()->dosya_id);
});

$router->add("member/bilgi", function (Request $req) {
    return uye($req->local()->dosya_id);
});

(Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env"))->load();
$router->execute();
