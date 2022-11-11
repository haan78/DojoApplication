<?php 
$module = trim($_GET["m"] ?? "login");
if ( !in_array($module,["login","forgot","new"])) {
    $module = "login";
}
?><!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="https://hcaptcha.com/1/api.js?hl=tr" async defer></script>
    <script src="panel.js"></script>
    <link rel="stylesheet" href="panel.css" />
    <title>Ankara Kendo</title>
</head>

<body>
    <div class="main">
        <?php require("$module.php"); ?>
        
    </div>

</body>

</html>