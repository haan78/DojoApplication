<?php

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";
require_once "./lib/Minmi.php";
require_once "./db.php";
require_once "./sendinblue.php";
require_once "./customized/routerAdmin.php";
require_once "./customized/routerMember.php";
require_once "./customized/routerOpen.php";

use Minmi\Response;
use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function tokenPars(Request $req, array $status) : bool {
    $token = $req->getBearerToken();
    if (empty($token)) {
        return false;
    }
    $payload = null;
    try {
        $payload = \Firebase\JWT\JWT::decode($token, $_ENV["JWT_KEY"], array('HS256'));
    } catch (Exception $ex) {
        throw new MinmiExeption($ex->getMessage(), 401);
    }

    if (property_exists($payload, "exp") && property_exists($payload, "uye_id") && property_exists($payload, "durum")) {
        //$payload->exp = time() + $_ENV["TOKEN_TIME"];
        //$token = \Firebase\JWT\JWT::encode($payload, $_ENV["JWT_KEY"], 'HS256');
        if ( in_array($payload->durum,$status) ) {
            $req->setLocal((object)[
                "uye_id" => $payload->uye_id,
                "durum" => $payload->durum,
                "ad" => $payload->ad ?? "?"
            ]);
            return true;
        } else {
            return false;
        }
    } else {
        throw new MinmiExeption("Token does not contain necessary values");
    }
}

$router = new DefaultJsonRouter("", function (Request $req, Response $res) {
    $urlpattern = $req->getUriPattern();
    if (str_starts_with($urlpattern,"/open")) {
        if (in_array($urlpattern,["/open/email","/open/reset","/open/token"])) {
            return;
        }
    } elseif (str_starts_with($urlpattern,"/member")) {
        if(tokenPars($req,["active", "admin", "super-admin"])) {
            return;
        }
    } elseif (str_starts_with($urlpattern,"/admin")) {
        if(tokenPars($req,["admin", "super-admin"])) {
            return;
        }
    }
    throw new MinmiExeption("Unauthorized request", 401);
});

routerOpen($router);
routerAdmin($router);
routerMember($router);

(Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env"))->load();
$router->execute();
