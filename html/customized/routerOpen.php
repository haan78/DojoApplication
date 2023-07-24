<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function authOpen(Request $req) : void {
}

function routerOpen(DefaultJsonRouter $router) {
    $router->add("/open/email", function (Request $request) {
        $jdata = $request->json();
        $email = $jdata->email ?? "";
    
        if ($email) {
            create_identity(0, $email, $ad, $code);
            sendinblue($email, 3, (object)[
                "AD" => $ad,
                "URL" => SERVICE_ROOT . "/reset.php?code=$code"
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

        function versionnum(string $ver) : float {    
            if (preg_match_all("/^([0-9]{1,2})\.([0-9]{1,2})\.([0-9]{1,2})($|-.*)/",$ver,$matches)) {
                $strval = $matches[1][0].str_pad($matches[2][0],2,"0",STR_PAD_LEFT).".".str_pad($matches[3][0],2,"0",STR_PAD_LEFT);
                return floatval($strval);
            } else {        
                return 0;
            }    
        }

        $jdata = $request->json();     
        $type = $jdata->type ?? "";
        $username = $password = "";
        $clientversion = versionnum($jdata->version ?? "");
        $minversion = versionnum(MIN_MOBILE_CLIENT_VERSION);
        
        if ( $type == "mobile" && $clientversion < $minversion ) {
            throw new MinmiExeption("Client version is older than =".($jdata->version ?? "")." / ".MIN_MOBILE_CLIENT_VERSION, 402);
        }
        
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
                } else { // type == "web"
                    if (!isset($_SESSION)) {
                        session_start();
                    }                    
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
                throw new MinmiExeption("Username or password is wrong", 402);
            }
        } else {
            throw new MinmiExeption("Username, password and captcha are required", 400);
        }
    });
}