<?php 
date_default_timezone_set('Europe/Istanbul');
error_reporting(E_ALL);
ini_set('display_errors', TRUE);
ini_set('display_startup_errors', TRUE);

require_once "vendor/autoload.php";

$dotenv = Dotenv\Dotenv::createImmutable("/etc", "dojo_service.env");
$dotenv->load();

function page(callable $content) {
    $rnd = rand(1,99999);
    ?><!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" />
    <script src="/assets/panel.js?rnd=<?php echo $rnd; ?>"></script>
    <link rel="stylesheet" href="/assets/panel.css?rnd=<?php echo $rnd; ?>" />
    <title>Ankara Kendo</title>
</head>
<body>
    <div class="main">
        <?php $content(); ?>
    </div>
</body>
</html><?
}