<?php 
date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";

$dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
$dotenv->load();



$module = trim($_GET["m"] ?? "login");
if ( $module == "activate" ) {
    require_once "./db.php";
    $code = $_GET["code"] ?? "";
    $err = "";
    if (!uye_eposta_onay($code,$err)) {
        $GLOBALS["err"] = $err;
    }
} elseif ( !in_array($module,["login","email","reset"])) {
    $module = "login";
}

function button(string $action, string $title) {
    ?>
    <button type="button" class="button" onclick="<?php echo $action; ?>(this)">
    <img src="html/loading.svg" style="width: 1.5em;height: 1.5em; vertical-align: middle; display: none;" />
    <span><?php echo $title; ?></span>
    </button>
    <?php
}

function page(callable $content) {
    ?><!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <script src="panel.js?rnd=<?php echo rand(1,99999); ?>"></script>
    <link rel="stylesheet" href="panel.css?rnd=<?php echo rand(1,99999); ?>" />
    <title>Ankara Kendo</title>
</head>

<body>
    <div class="main">
        <?php $content(); ?>
    </div>

</body>

</html><?
}