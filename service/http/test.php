<?php
date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";

use \Firebase\JWT\JWT;

$key = "example_key";
$payload = array(
    "iss" => "http://example.org",
    "aud" => "http://example.com",
    "iat" => 1356999524,
    "nbf" => 1357000000,
    "exp" => time() - 600
);

$jwt = JWT::encode($payload, $key);

echo $jwt;

$key = "example_key";

try {
$decoded = JWT::decode($jwt, $key, array('HS256'));
    print_r($decoded);
} catch ( \Firebase\JWT\ExpiredException $exception ) {
    
    echo $exception->getMessage();// Tell the user that their JWT has expired
}

$o = (object)["a"=>1];
echo $o->a." - ".($o->b ?? "omadi");
