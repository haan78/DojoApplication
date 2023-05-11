<?php
require_once "./settings.php";

initSecret();

function setSessionAttempt() {
    session_start();
    $_SESSION['attempt'] = $_SESSION['attempt'] ?? 0;
}

function page(callable $content) {
    $rnd = rand(1,99999);
    ?><!DOCTYPE html>
<html lang="tr">
<head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/png" sizes="32x32" href="/assets/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <script src="/assets/panel.js?rnd=<?php echo $rnd; ?>"></script>
    <link rel="stylesheet" href="/assets/panel.css?rnd=<?php echo $rnd; ?>" />
    <title>Ankara Kendo</title>
</head>
<body>
    <div class="main">
        <?php $content(); ?>
    </div>
</body>
</html><?php
}