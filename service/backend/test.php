<?php require_once "vendor/autoload.php";
$dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
$dotenv->load();

require_once "./db.php";
require_once "./hcaptcha.php";

$ad = $email = $code = $err = "";
if (uye_eposta_onkayit(1, $ad, $email, $code, $err)) {
    sendinblue($email, 1, (object)[
        "AD" => $ad,
        "URL" => $_ENV["SERVICE_ROOT"] . "/backend/index.php?m=activate&code=$code"
    ]);
} else {
    throw new Exception($err);
}
