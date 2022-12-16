<?php require_once "vendor/autoload.php";
$dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
$dotenv->load();

$HCAPTCHA_SITEKEY = $_ENV["HCAPTCHA_SITEKEY"];

$module = trim($_GET["m"] ?? "login");
if ( !in_array($module,["login","email","reset"])) {
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

?><!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <script src="https://hcaptcha.com/1/api.js?hl=tr" async defer></script>
    <script src="html/panel.js?rnd=<?php echo "".(rand(1,99999)); ?>"></script>
    <link rel="stylesheet" href="html/panel.css" />
    <title>Ankara Kendo</title>
</head>

<body>
    <div class="main">
        <?php require("html/$module.php"); ?>
    </div>

</body>

</html>