<?php
require_once "vendor/autoload.php";
require_once './db.php';

date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);
(Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env"))->load();


$t = time();
validate("haan78@gmail.com","123456","admin");
$t = $t - time();
echo "Sure $t";