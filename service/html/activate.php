<?php
require_once "settings.php";
require_once "page.php";
require_once "./customized/db.php";
$code = $_GET["code"] ?? "";
if ( !$code ) {
    die("Invalid code");
}
$err = "";
initSecret();
uye_eposta_onay($code, $err);
page(function () {
    global $err;
?>
    <div class="body">
        <div class="form">
            <div class="item">
                <?php if (!$err) : ?>
                    <h1 style="color:darkgreen">E-Postanız Doğrulanmıştır</h1>
                <?php else : ?>
                    <h1 style="color:brown"><?php echo strip_tags($err); ?></h1>
                <?php endif; ?>
            </div>

            <div class="link">
                <a href="login.php">Üye Girişi ve Şifre Alma</a>
            </div>

        </div>
    </div>
<?php
});
