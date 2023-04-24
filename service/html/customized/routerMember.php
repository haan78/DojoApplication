<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function routerMember(DefaultJsonRouter $router)
{
    $router->add("/member/password", function (Request $req) {
        $uye_id = $req->local()->uye_id;
        $params = $req->json();
        if (!password($uye_id, $params->oldpass, $params->newpass, $err)) {
            throw new MinmiExeption($err, 401);
        }
    });

    $router->add("/member/foto", function (Request $req) {
        return download($req->local()->dosya_id);
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
}
