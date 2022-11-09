<?php

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./db.php";

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

$router = new DefaultJsonRouter("", function (Request $req) {

    $dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
    $dotenv->load();

    if ($req->getUriPattern() != "/token") {
        $headers = getallheaders();
        $h = trim($headers["Authorization"] ?? $headers["authorization"] ?? $headers['HTTP_AUTHORIZATION'] ?? "");
        if (!empty($h) && preg_match('/Bearer\s(\S+)/', $h, $matches)) {
            $token = $matches[1];
            $user = \Firebase\JWT\JWT::decode($token, $_ENV["JWT_KEY"], array('HS256'));
            
            if (!property_exists($user, "exp")) {
                throw new MinmiExeption("exp is required in token");
            }

            if (!in_array($user->durum ?? "", ["admin", "super-admin"]) && str_starts_with($req->getUriPattern(),"/admin") ) {
                throw new MinmiExeption("Unauthorized request for admin action");
            }

            $user->exp = time() + 3600;
            $token = \Firebase\JWT\JWT::encode($user, $_ENV["JWT_KEY"], 'HS256');
            $req->setLocal($user);
            header("Authorization: Bearer $token", true);            
        } else {
            throw new MinmiExeption("Authorization is required == " . $h);
        }
    }
});

$router->add("/token", function (Request $request) {    
    if (isset($_SERVER["PHP_AUTH_USER"]) && isset($_SERVER["PHP_AUTH_PW"])) {
        $user = validate(trim($_SERVER["PHP_AUTH_USER"]), trim($_SERVER["PHP_AUTH_PW"]));
        if ($user) {
            if ($user["durum"] != "passive") {
                $user["exp"] = time() + 600;
                $token = \Firebase\JWT\JWT::encode($user, $_ENV["JWT_KEY"], 'HS256');
                header("Authorization: Bearer $token", true);
                return [
                    "ad" => $user["ad"],
                    "uye_id" => $user["uye_id"],
                    "email" => trim($_SERVER["PHP_AUTH_USER"]),
                    "durum" => $user["durum"]
                ];
            } else {
                throw new MinmiExeption("Unauthorized request", 403);
            }
        } else {
            throw new MinmiExeption("Username or password is wrong", 401);
        }
    } else {
        throw new MinmiExeption("Username and password are required", 400);
    }
});

$router->add("admin/uye/#uye_id", function (Request $req) {
    return uye($req->params()["uye_id"]);
});

$router->add("admin/uyeseviyeekle",function(Request $req){
    $jdata = $req->json();
    if (!seviye_ekle($jdata->uye_id,$jdata->seviye,$jdata->tarih,$jdata->aciklama,$err)) {
        throw new Exception($err);
    }
});

$router->add("admin/uyeseviyesil/#uye_id/@seviye",function(Request $req){
    $uye_id = $req->params()["uye_id"];
    $seviye = $req->params()["seviye"];
    if (!seviye_sil($uye_id,$seviye,$err)) {
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

$router->execute();
