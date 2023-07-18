<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function authMember(Request $req) : void {
    session_start();
    $uye_id = $_SESSION["uye_id"] ?? 0;
    if ($uye_id) {
        $req->setLocal((object)[
            "uye_id" => $uye_id,
            "durum" => $_SESSION["durum"] ?? "",
            "ad" => $_SESSION["ad"] ?? ""
        ]);        
    } else {
        throw new MinmiExeption("Unauthorized request", 401);
    }
}

function routerMember(DefaultJsonRouter $router)
{
    $router->add("/member/password", function (Request $req) {
        $uye_id = $req->local()->uye_id;
        $params = $req->json();
        $old = trim($params->oldpass);
        $new = trim($params->newpass);
        if (strlen($new)>=6 && $old != $new) {
            password($uye_id, $old, $new);    
        } else {
            throw new MinmiExeption("Old and new passwords are not the same", 400);
        }
    });

    $router->add("/member/bilgi", function (Request $req) {
        return uye($req->local()->uye_id);
    });

    $router->add("/member/tahakkuk/list", function (Request $req) {
        return uyetahakkuklist($req->local()->uye_id);
    });

    $router->add("/member/email", function (Request $req) {
        $params = $req->json();
        $email = $params->email;
        create_identity($req->local()->uye_id, $email, $ad, $code);
        sendinblue($email, 3, (object)[
            "AD" => $ad,
            "URL" => $GLOBALS["SERVICE_ROOT"] . "/reset.php?code=$code"
        ]);
    });

    $router->add("/member/logout", function (Request $req) {
        session_unset();
        return "OK";
    });

    $router->add("/member/scores", function (Request $req) {
        return maccalismasi_kisibazli($req->local()->uye_id);
    });
}
