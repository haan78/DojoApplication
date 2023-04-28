<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function authOpen(Request $req) : void {
    session_start();
    if (isset($_SESSION["attempt"])) {
        $attempt = intval($_SESSION["attempt"] ?? 0);
        if ($attempt < MAX_LOGIN_ATTEMPT)  {
            $newnum = $attempt + 1;
            $_SESSION["attempt"] = $newnum;
            $req->setLocal((object)[
                "attempt" => $newnum
            ]);
        } else {
            throw new MinmiExeption("Too many attempt in session time",401);    
        }
    } else {        
        throw new MinmiExeption("No valid session!",401);
    }
}

function routerOpen(DefaultJsonRouter $router) {
    $router->add("/open/email", function (Request $request) {
        $jdata = $request->json();
        $email = $jdata->email ?? "";
    
        if ($email) {
            create_identity(0, $email, $ad, $code);
            sendinblue($email, 3, (object)[
                "AD" => $ad,
                "URL" => $GLOBALS["SERVICE_ROOT"] . "/reset.php?code=$code"
            ]);
        } else {
            throw new MinmiExeption("Email is required", 400);
        }
    });
    
    $router->add("/open/reset", function (Request $request) {
        $jdata = $request->json();
        $code = $jdata->code ?? "";
        $pass = $jdata->password ?? "";
        if ($code) {
            reset_password($code, $pass);
        } else {
            throw new MinmiExeption("Activation code is required", 400);
        }
    });
    
    $router->add("/open/token", function (Request $request) {
        $jdata = $request->json();
        $num = ($request->local())->attempt ?? -1;        
        $type = $jdata->type ?? "";
        $username = $password = "";
        if ($request->hasBasicAuth($username, $password)) {
            $user = validate(trim($username), trim($password), $type);
            if (!is_null($user)) {
                $token = "";
                if ($type == "mobile") {
                    $uye_id = intval($user->uye_id ?? 0);
                    $payload = [
                        "exp" => time() + TOKEN_TIME,
                        "durum" => $user->durum,
                        "uye_id" => $uye_id,
                        "ad" => $user->ad
                    ];
                    $token = \Firebase\JWT\JWT::encode($payload, $GLOBALS["JWT_KEY"], 'HS256');
                    session_unset();
                } else { // type == "web"
                    $_SESSION["attempt"] = 0;
                    $_SESSION["uye_id"] = $user->uye_id;
                    $_SESSION["ad"] = $user->ad;
                    $_SESSION["durum"] = $user->durum;
                }
                return [
                    "ad" => $user->ad,
                    "email" => trim($username),
                    "durum" => $user->durum,
                    "token" => $token
                ];
            } else {
                throw new MinmiExeption("Username or password is wrong (".$num.")", 402);
            }
        } else {
            throw new MinmiExeption("Username, password and captcha are required", 400);
        }
    });
}