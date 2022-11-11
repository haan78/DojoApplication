<?php
function hcaptcha(string $captcha): bool {
    //return true;    
    $secret = $_ENV["HCAPTCHA_SECRET"];
    $verifyResponse = file_get_contents('https://hcaptcha.com/siteverify?secret=' . $secret . '&response=' . $captcha . '&remoteip=' . $_SERVER['REMOTE_ADDR']);
    $responseData = json_decode($verifyResponse);
    if ($responseData->success) {
        return true;
    } else {
        return false;
    }
}
