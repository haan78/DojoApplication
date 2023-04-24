<?php

use Minmi\DefaultJsonRouter;
use Minmi\Request;
use Minmi\MinmiExeption;

function testAttemtp() : int {
    session_start();
    if (isset($_SESSION["attemtp"])) {
        $attempt = intval($_SESSION["attemtp"]);
        if ($attempt < MAX_LOGIN_ATTEMPT)  {
            $newnum = $attempt + 1;
            $_SESSION["attemtp"] = $newnum;
            return $newnum;
        } else {
            throw new MinmiExeption("Too many attempt in session time",401);    
        }
    } else {
        throw new MinmiExeption("No valid session!",401);
    }
}

function routerOpen(DefaultJsonRouter $router) {
    $router->add("/open/email", function (Request $request) {
        $num = testAttemtp();
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
        $num = testAttemtp();
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
        $num = testAttemtp();
        $jdata = $request->json();
        $type = $jdata->type ?? "";
        $username = $password = "";
        if ($request->hasBasicAuth($username, $password)) {
            $user = validate(trim($username), trim($password), trim($type));
            if (!is_null($user)) {
                $payload = [
                    "exp" => time() + TOKEN_TIME,
                    "durum" => $user["durum"],
                    "uye_id" => $user["uye_id"],
                    "ad" => $user["ad"]
                ];
                $token = \Firebase\JWT\JWT::encode($payload, $GLOBALS["JWT_KEY"], 'HS256');
                return [
                    "ad" => $user["ad"],
                    "uye_id" => $user["uye_id"],
                    "dosya_id" => $user["dosya_id"],
                    "email" => trim($username),
                    "durum" => $user["durum"],
                    "token" => $token
                ];
            } else {
                throw new MinmiExeption("Username or password is wrong ($num)", 402);
            }
        } else {
            throw new MinmiExeption("Username, password and captcha are required", 400);
        }
    });
}