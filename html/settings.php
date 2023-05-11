<?php

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

define("MAX_LOGIN_ATTEMPT",5);
define("TOKEN_TIME",7200);
define("SECRET_FILE_PATH","/etc/.secrets/dojo.json");

function initSecret():void {
    $file = @file_get_contents(SECRET_FILE_PATH);
    if ($file) {
        $json = json_decode($file,true);
        if ($json) {
            foreach($json as $key => $value) {
                $GLOBALS[$key] = $value;
            }
        } else {
            die("Secret parse error");
        }        
    } else {
        die("Secret file read error");
    }
}